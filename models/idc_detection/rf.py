import os
import sys
from datetime import datetime
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
from radiomics import firstorder, glcm, glrlm, glszm, gldm
from skimage.exposure import histogram


class RF100(AnalysisTask):
    __pool: Pool
    __num_of_workers: int
    __model: RandomForestClassifier
    __scaler: StandardScaler
    __tile_width = 50
    __tile_height = 50
    __extractor_settings = {"binWidth": 3, "label": 1, "interpolator": 'sitkBSpline', "resampledPixelSpacing": None, "weightingNorm": None, "force2D": True, "force2Ddimension": 1, "additionalInfo": False}
    __first_order_features = {'10Percentile': True, '90Percentile': True, 'Energy': True, 'InterquartileRange': True, 'Kurtosis': True, 'Maximum': True, 'MeanAbsoluteDeviation': True, 'Mean': True, 'Median': True, 'Minimum': True, 'Range': True, 'RobustMeanAbsoluteDeviation': True, 'RootMeanSquared': True, 'Skewness': True, 'TotalEnergy': True, 'Variance': True}
    __glcm_features = {'Autocorrelation': True, 'JointAverage': True, 'ClusterProminence': True, 'ClusterShade': True, 'ClusterTendency': True, 'Contrast': True, 'Correlation': True, 'DifferenceAverage': True, 'DifferenceEntropy': True, 'DifferenceVariance': True, 'JointEnergy': True, 'JointEntropy': True, 'Imc1': True, 'Imc2': True, 'Idm': True, 'Idmn': True, 'Id': True, 'Idn': True, 'InverseVariance': True, 'MaximumProbability': True, 'SumEntropy': True, 'SumSquares': True}

    def _process(self, image: ndarray) -> dict:
        base = os.path.dirname(__file__)
        model_path = os.path.abspath(os.path.join(base, 'rf_100_classifier.max_leaf_nodes500_min_samples_leaf10_n_estimators100_n_jobs1.histomics_gray_scale.color_histogram_rgb.joblib.pkl'))
        self.__model = joblib.load(model_path)

        scaler_path = os.path.abspath(os.path.join(base, 'rf_100_feature_scaler_gray_level.joblib.pkl'))
        self.__scaler = joblib.load(scaler_path)

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

        elapsed = []
        for d in data:
            elapsed.append(d['elapsed'].total_seconds())
            mask[d['y']:d['y'] + self.__tile_height, d['x']:d['x'] + self.__tile_width] = d['lbl']
        elapsed = array(elapsed)
        self._message_queue.put({'status': "Mean {:.4f}% Std {:.4f}% Max {:.4f}% Min {:.4f}%".format(elapsed.mean(), elapsed.std(), elapsed.max(), elapsed.min())})

        msk = create_heatmap(mask, 30)
        return {'mask': msk, 'data': data}

    def predict(self, data):

        start = datetime.now()

        rch, _ = histogram(data['tile'][:, :, 0].astype('float64'), nbins=12, normalize=True)
        gch, _ = histogram(data['tile'][:, :, 1].astype('float64'), nbins=12, normalize=True)
        bch, _ = histogram(data['tile'][:, :, 2].astype('float64'), nbins=12, normalize=True)

        im_gl = rgb2gray(data['tile'])
        im_gl = (im_gl * 255).astype('uint8')
        im = GetImageFromArray(im_gl)
        msk_arr = ones(im.GetSize()[::-1], dtype='uint8')
        msk = GetImageFromArray(msk_arr)
        msk.CopyInformation(im)

        ford_extractor = firstorder.RadiomicsFirstOrder(im, msk, **self.__extractor_settings)
        ford_extractor.enabledFeatures = self.__first_order_features

        glcm_extractor = glcm.RadiomicsGLCM(im, msk, **self.__extractor_settings)
        glcm_extractor.enabledFeatures = self.__glcm_features

        glrlm_extractor = glrlm.RadiomicsGLRLM(im, msk, **self.__extractor_settings)
        glrlm_extractor.enableAllFeatures()

        glszm_extractor = glszm.RadiomicsGLSZM(im, msk, **self.__extractor_settings)
        glszm_extractor.enableAllFeatures()

        gldm_extractor = gldm.RadiomicsGLDM(im, msk, **self.__extractor_settings)
        gldm_extractor.enableAllFeatures()

        ford_features = ford_extractor.execute()
        glcm_features = glcm_extractor.execute()
        glrlm_features = glrlm_extractor.execute()
        glszm_features = glszm_extractor.execute()
        gldm_features = gldm_extractor.execute()

        features = array(list(ford_features.values()) + list(glcm_features.values()) + list(glrlm_features.values()) + list(glszm_features.values()) + list(gldm_features.values()))

        features = features.reshape(1, len(features))
        features = self.__scaler.transform(features)

        features = concatenate((rch.reshape(1, len(rch)), gch.reshape(1, len(gch)), bch.reshape(1, len(bch)), features), axis=1)

        y_pred = self.__model.predict(features)

        end = datetime.now()

        return {'x': data['x'] * self.__tile_width, 'y': data['y'] * self.__tile_height, 'lbl': int(y_pred[0]), 'elapsed': end - start}

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


class RF101(AnalysisTask):
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

        # joblib.dump(data, 'data.pkl')
        # data = joblib.load('data.pkl')
        mask = zeros([image.shape[0], image.shape[1]])

        elapsed = []
        for d in data:
            elapsed.append(d['elapsed'].total_seconds())
            mask[d['y']:d['y'] + self.__tile_height, d['x']:d['x'] + self.__tile_width] = d['lbl']
        elapsed = array(elapsed)
        self._message_queue.put({'status': "Mean {:.4f}% Std {:.4f}% Max {:.4f}% Min {:.4f}%".format(elapsed.mean(), elapsed.std(), elapsed.max(), elapsed.min())})

        msk = create_heatmap(mask, 30)
        return {'mask': msk, 'data': data}

    def predict(self, data):

        start = datetime.now()

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

        end = datetime.now()

        return {'x': data['x'] * self.__tile_width, 'y': data['y'] * self.__tile_height, 'lbl': int(y_pred[0]), 'elapsed': end - start}

    def _close(self, signum, frame):
        self.__pool.close()
        self.__pool.terminate()
        self._message_queue.put({'success': False, 'status': 'stopped'})
        sys.exit(0)

    def __getstate__(self):
        state = self.__dict__.copy()
        del state['_message_queue']
        del state['_RF101__pool']
        return state

    def __setstate__(self, state):
        self.__dict__.update(state)
