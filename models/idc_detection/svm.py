import os
import sys
import joblib
from utils.wsi import split_image, create_heatmap
from library.analysis_task import AnalysisTask
from multiprocessing import Pool, cpu_count
from SimpleITK import GetImageFromArray, VectorIndexSelectionCast
from radiomics.featureextractor import RadiomicsFeatureExtractor
from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler
from numpy import ndarray, array, ones, zeros
from pandas import DataFrame


class SVM100(AnalysisTask):
    __pool: Pool
    __num_of_workers: int
    __model: SVC
    __scaler: StandardScaler
    __tile_width = 50
    __tile_height = 50
    __r_chan_extractor: RadiomicsFeatureExtractor
    __g_chan_extractor: RadiomicsFeatureExtractor
    __b_chan_extractor: RadiomicsFeatureExtractor
    __selected_features: list

    def _process(self, image: ndarray) -> dict:
        base = os.path.dirname(__file__)
        model_path = os.path.abspath(os.path.join(base, 'svm_100_classifier.C30_coef01.0_degree3_kernelpoly_histomics_rgb_color_histogram_rgb.joblib.pkl'))
        self.__model = joblib.load(model_path)

        scaler_path = os.path.abspath(os.path.join(base, 'svm_100_feature_scaler.joblib.pkl'))
        self.__scaler = joblib.load(scaler_path)

        features_path = os.path.abspath(os.path.join(base, 'svm_100_selected_features.pkl'))
        self.__selected_features = joblib.load(features_path)

        r_chan_params = os.path.abspath(os.path.join(base, 'svm_100_pyradiomics_params_r_chan.yaml'))
        self.__r_chan_extractor = RadiomicsFeatureExtractor(r_chan_params)

        g_chan_params = os.path.abspath(os.path.join(base, 'svm_100_pyradiomics_params_g_chan.yaml'))
        self.__g_chan_extractor = RadiomicsFeatureExtractor(g_chan_params)

        b_chan_params = os.path.abspath(os.path.join(base, 'svm_100_pyradiomics_params_b_chan.yaml'))
        self.__b_chan_extractor = RadiomicsFeatureExtractor(b_chan_params)

        self.__num_of_workers = cpu_count()
        if self.__num_of_workers < 1:
            self.__num_of_workers = 1

        self.__pool = Pool(self.__num_of_workers)

        tiles = split_image(image, self.__tile_width, self.__tile_height)

        jobs = []
        for i in range(0, tiles.shape[0]):
            for j in range(0, tiles.shape[1]):
                jobs.append({'x': i, 'y': j, 'tile': tiles[i, j]})

        total_jobs = len(jobs)
        data = []

        for i, d in enumerate(self.__pool.imap_unordered(self.predict, jobs, chunksize=20)):
            data.append(d)
            progress = ((i + 1) / total_jobs) * 100
            self._message_queue.put({'progress': round(progress, 2)})
            self._message_queue.put({'status': "{:.0f}% ({} de {}) processed".format(progress, i + 1, total_jobs)})
        self.__pool.close()
        self.__pool.join()

        # joblib.dump(data, 'data.pkl')
        # data = joblib.load('data.pkl')
        mask = zeros([image.shape[0], image.shape[1]])

        for d in data:
            mask[d['y']:d['y'] + self.__tile_height, d['x']:d['x'] + self.__tile_width] = d['lbl']

        msk = create_heatmap(mask, 30)
        return {'mask': msk, 'data': data}

    def predict(self, data):
        im = GetImageFromArray(data['tile'], isVector=True)
        msk_arr = ones(im.GetSize()[::-1], dtype='uint8')
        msk = GetImageFromArray(msk_arr)
        msk.CopyInformation(im)

        # Extract red channel image's features
        rc = VectorIndexSelectionCast(im, 0)
        rcf = self.__r_chan_extractor.execute(rc, msk, label=1)

        # Extract green channel image's features
        gc = VectorIndexSelectionCast(im, 1)
        gcf = self.__g_chan_extractor.execute(gc, msk, label=1)

        # Extract blue channel image's features
        bc = VectorIndexSelectionCast(im, 2)
        bcf = self.__b_chan_extractor.execute(bc, msk, label=1)

        features = array(list(rcf.values()) + list(gcf.values()) + list(bcf.values()))
        features = features.reshape(1, len(features))

        features = self.__scaler.transform(features)

        cols = (['r_chan_' + x for x in list(rcf.keys())] + ['g_chan_' + x for x in list(gcf.keys())]
                + ['b_chan_' + x for x in list(bcf.keys())])

        rf = DataFrame(features, columns=cols)

        y_pred = self.__model.predict(rf[self.__selected_features])

        return {'x': data['x'] * self.__tile_width, 'y': data['y'] * self.__tile_height, 'lbl': int(y_pred[0])}

    def _close(self, signum, frame):
        self.__pool.close()
        self.__pool.terminate()
        self._message_queue.put({'success': False, 'status': 'stopped'})
        sys.exit(0)

    def __getstate__(self):
        state = self.__dict__.copy()
        del state['_message_queue']
        del state['_SVM100__pool']
        return state

    def __setstate__(self, state):
        self.__dict__.update(state)
