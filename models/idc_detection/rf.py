import os
import sys
import joblib
from utils.wsi import split_image, create_heatmap
from library.analysis_task import AnalysisTask
from multiprocessing import Pool, cpu_count
from SimpleITK import GetImageFromArray
from radiomics.featureextractor import RadiomicsFeatureExtractor
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
from numpy import ndarray, array, ones, zeros, concatenate
from skimage.color import rgb2gray
from skimage.exposure import histogram


class RF100(AnalysisTask):
    __pool: Pool
    __num_of_workers: int
    __model: RandomForestClassifier
    __scaler: StandardScaler
    __tile_width = 50
    __tile_height = 50
    __extractor: RadiomicsFeatureExtractor

    def _process(self, image: ndarray) -> dict:
        base = os.path.dirname(__file__)
        model_path = os.path.abspath(os.path.join(base, 'rf_100_classifier.max_leaf_nodes500_min_samples_leaf10_n_estimators100_n_jobs1.histomics_gray_scale.color_histogram_rgb.joblib.pkl'))
        self.__model = joblib.load(model_path)

        scaler_path = os.path.abspath(os.path.join(base, 'rf_100_feature_scaler_gray_level.joblib.pkl'))
        self.__scaler = joblib.load(scaler_path)

        extractor_params = os.path.abspath(os.path.join(base, 'rf_100_pyradiomics_params.yaml'))
        self.__extractor = RadiomicsFeatureExtractor(extractor_params)

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

        mask = zeros([image.shape[0], image.shape[1]])

        for d in data:
            mask[d['y']:d['y'] + self.__tile_height, d['x']:d['x'] + self.__tile_width] = d['lbl']

        msk = create_heatmap(mask, 30)
        return {'mask': msk, 'data': data}

    def predict(self, data):
        rch, _ = histogram(data['tile'][:, :, 0].astype('float64'), nbins=12, normalize=True)
        gch, _ = histogram(data['tile'][:, :, 1].astype('float64'), nbins=12, normalize=True)
        bch, _ = histogram(data['tile'][:, :, 2].astype('float64'), nbins=12, normalize=True)

        im_gl = rgb2gray(data['tile'])
        im_gl = (im_gl * 255).astype('uint8')
        im = GetImageFromArray(im_gl)
        msk_arr = ones(im.GetSize()[::-1], dtype='uint8')
        msk = GetImageFromArray(msk_arr)
        msk.CopyInformation(im)

        # Extract grayscale image's features
        glf = self.__extractor.execute(im, msk, label=1)
        features = array(list(glf.values()))

        features = features.reshape(1, len(features))
        features = self.__scaler.transform(features)

        features = concatenate((rch.reshape(1, len(rch)), gch.reshape(1, len(gch)), bch.reshape(1, len(bch)), features), axis=1)

        y_pred = self.__model.predict(features)

        return {'x': data['x'] * self.__tile_width, 'y': data['y'] * self.__tile_height, 'lbl': int(y_pred[0])}

    def _close(self, signum, frame):
        self.__pool.close()
        self.__pool.terminate()
        self._message_queue.put({'success': False, 'status': 'stopped'})
        sys.exit(0)

    def __getstate__(self):
        state = self.__dict__.copy()
        del state['_message_queue']
        del state['_RF100__pool']
        return state

    def __setstate__(self, state):
        self.__dict__.update(state)
