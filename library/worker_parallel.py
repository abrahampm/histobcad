import os
import sys
import signal
import joblib
from multiprocessing import Pool, cpu_count
from datetime import datetime
from library.wsi_split import split_wsi
from numpy import ones, array
from pandas import DataFrame
from SimpleITK import GetImageFromArray, VectorIndexSelectionCast
from radiomics.featureextractor import RadiomicsFeatureExtractor
from PySide2.QtCore import QCoreApplication, QObject

translate = QCoreApplication.translate
tr = QObject().tr

NUM_OF_WORKERS = cpu_count()
if NUM_OF_WORKERS < 1:
    NUM_OF_WORKERS = 1


selected_features = ['r_chan_original_firstorder_RootMeanSquared', 'r_chan_original_firstorder_Energy', 'r_chan_original_glcm_Idn', 'r_chan_original_firstorder_TotalEnergy', 'r_chan_original_firstorder_10Percentile', 'r_chan_original_glcm_Id', 'r_chan_original_glrlm_RunPercentage', 'r_chan_original_gldm_LargeDependenceHighGrayLevelEmphasis', 'r_chan_original_glcm_ClusterShade', 'r_chan_original_firstorder_Mean', 'r_chan_original_glszm_LargeAreaHighGrayLevelEmphasis', 'b_chan_original_firstorder_Range', 'b_chan_original_glcm_Imc1', 'r_chan_original_glcm_Idmn', 'g_chan_original_firstorder_10Percentile', 'r_chan_original_firstorder_Maximum', 'r_chan_original_glcm_Autocorrelation', 'b_chan_original_glszm_HighGrayLevelZoneEmphasis', 'g_chan_original_glszm_GrayLevelVariance', 'b_chan_original_firstorder_Median', 'r_chan_original_glcm_JointEntropy', 'b_chan_original_firstorder_Minimum', 'g_chan_original_firstorder_Median', 'b_chan_original_firstorder_Variance', 'b_chan_original_glcm_Imc2', 'b_chan_original_glcm_ClusterProminence', 'b_chan_original_glszm_ZoneEntropy', 'g_chan_original_glszm_LargeAreaLowGrayLevelEmphasis', 'b_chan_original_firstorder_Mean', 'r_chan_original_firstorder_Skewness', 'r_chan_original_glrlm_LongRunHighGrayLevelEmphasis', 'r_chan_original_gldm_GrayLevelVariance', 'r_chan_original_glszm_HighGrayLevelZoneEmphasis', 'r_chan_original_firstorder_Kurtosis', 'r_chan_original_firstorder_90Percentile', 'r_chan_original_glcm_Imc1', 'r_chan_original_glcm_Imc2', 'r_chan_original_gldm_HighGrayLevelEmphasis', 'b_chan_original_glcm_JointEntropy', 'r_chan_original_glcm_Correlation', 'r_chan_original_glcm_DifferenceVariance', 'r_chan_original_glcm_JointEnergy', 'r_chan_original_firstorder_Median', 'r_chan_original_glszm_SmallAreaHighGrayLevelEmphasis', 'b_chan_original_glrlm_GrayLevelNonUniformityNormalized', 'g_chan_original_firstorder_Energy', 'b_chan_original_glcm_Contrast', 'b_chan_original_firstorder_10Percentile', 'r_chan_original_glrlm_GrayLevelVariance', 'b_chan_original_firstorder_RootMeanSquared', 'b_chan_original_gldm_DependenceEntropy', 'b_chan_original_glrlm_ShortRunHighGrayLevelEmphasis', 'g_chan_original_glcm_ClusterProminence', 'g_chan_original_glrlm_GrayLevelVariance', 'b_chan_original_glcm_ClusterTendency', 'r_chan_original_glszm_ZoneEntropy', 'g_chan_original_firstorder_Mean', 'r_chan_original_firstorder_MeanAbsoluteDeviation', 'r_chan_original_firstorder_Variance', 'b_chan_original_glszm_SmallAreaHighGrayLevelEmphasis', 'b_chan_original_gldm_HighGrayLevelEmphasis', 'r_chan_original_glcm_DifferenceAverage', 'g_chan_original_glrlm_LongRunLowGrayLevelEmphasis', 'b_chan_original_glcm_SumEntropy', 'g_chan_original_glcm_ClusterTendency', 'g_chan_original_glcm_Contrast', 'g_chan_original_glcm_JointEnergy', 'b_chan_original_glcm_DifferenceVariance', 'r_chan_original_glcm_JointAverage', 'r_chan_original_firstorder_Range', 'b_chan_original_glrlm_RunEntropy', 'r_chan_original_glcm_Contrast', 'r_chan_original_glcm_ClusterProminence', 'r_chan_original_glszm_ZonePercentage', 'b_chan_original_firstorder_Maximum', 'g_chan_original_glcm_SumSquares', 'g_chan_original_firstorder_90Percentile', 'r_chan_original_firstorder_Minimum', 'g_chan_original_firstorder_RootMeanSquared', 'r_chan_original_glcm_DifferenceEntropy', 'g_chan_original_firstorder_Variance', 'b_chan_original_glrlm_HighGrayLevelRunEmphasis', 'b_chan_original_gldm_SmallDependenceHighGrayLevelEmphasis', 'g_chan_original_gldm_GrayLevelNonUniformity', 'g_chan_original_glcm_SumEntropy', 'g_chan_original_gldm_LargeDependenceLowGrayLevelEmphasis', 'g_chan_original_glszm_GrayLevelNonUniformityNormalized', 'g_chan_original_gldm_GrayLevelVariance', 'b_chan_original_firstorder_Energy', 'b_chan_original_glcm_Autocorrelation', 'g_chan_original_firstorder_InterquartileRange', 'b_chan_original_firstorder_90Percentile', 'g_chan_original_glrlm_GrayLevelNonUniformityNormalized', 'b_chan_original_firstorder_TotalEnergy', 'g_chan_original_glszm_HighGrayLevelZoneEmphasis', 'r_chan_original_glrlm_HighGrayLevelRunEmphasis', 'g_chan_original_glrlm_RunEntropy', 'g_chan_original_glcm_DifferenceVariance', 'r_chan_original_glrlm_ShortRunHighGrayLevelEmphasis', 'g_chan_original_glcm_JointEntropy']


b_chan_extractor_params = {"setting": {"binWidth": 3,
                                       "label": 1,
                                       "interpolator": 'sitkBSpline',
                                       "resampledPixelSpacing": None,
                                       "weightingNorm": None,
                                       "force2D": True,
                                       "force2Ddimension": 1,
                                       "additionalInfo": False},
                           "imageType": {"Original": {}},
                           "featureClass": {
                              "firstorder": [
                                'Range',
                                'Median',
                                'Minimum',
                                'Variance',
                                'Mean',
                                '10Percentile',
                                'RootMeanSquared',
                                'Maximum',
                                'Energy',
                                '90Percentile',
                                'TotalEnergy'],
                              "glcm": [
                                'Imc1',
                                'Imc2',
                                'ClusterProminence',
                                'JointEntropy',
                                'Contrast',
                                'ClusterTendency',
                                'SumEntropy',
                                'DifferenceVariance',
                                'Autocorrelation'],
                              "glrlm": [
                                'GrayLevelNonUniformityNormalized',
                                'ShortRunHighGrayLevelEmphasis',
                                'RunEntropy',
                                'HighGrayLevelRunEmphasis'],
                              "glszm": [
                                'HighGrayLevelZoneEmphasis',
                                'ZoneEntropy',
                                'SmallAreaHighGrayLevelEmphasis'],
                              "gldm": [
                                'DependenceEntropy',
                                'HighGrayLevelEmphasis',
                                'SmallDependenceHighGrayLevelEmphasis']

                           }
                          }


g_chan_extractor_params = {"setting": {"binWidth": 3,
                                       "label": 1,
                                       "interpolator": 'sitkBSpline',
                                       "resampledPixelSpacing": None,
                                       "weightingNorm": None,
                                       "force2D": True,
                                       "force2Ddimension": 1,
                                       "additionalInfo": False},
                           "imageType": {"Original": {}},
                           "featureClass": {
                              "firstorder": [
                                '10Percentile',
                                'Median',
                                'Energy',
                                'Mean',
                                '90Percentile',
                                'RootMeanSquared',
                                'Variance',
                                'InterquartileRange'],
                              "glcm": [
                                'ClusterProminence',
                                'ClusterTendency',
                                'Contrast',
                                'JointEnergy',
                                'SumSquares',
                                'SumEntropy',
                                'DifferenceVariance',
                                'JointEntropy'],
                              "glrlm": [
                                'GrayLevelVariance',
                                'LongRunLowGrayLevelEmphasis',
                                'GrayLevelNonUniformityNormalized',
                                'RunEntropy'],
                              "glszm": [
                                'GrayLevelVariance',
                                'LargeAreaLowGrayLevelEmphasis',
                                'GrayLevelNonUniformityNormalized',
                                'HighGrayLevelZoneEmphasis'],
                              "gldm": [
                                'GrayLevelNonUniformity',
                                'LargeDependenceLowGrayLevelEmphasis',
                                'GrayLevelVariance']
                           }
                          }


r_chan_extractor_params = {"setting": {"binWidth": 3,
                                       "label": 1,
                                       "interpolator": 'sitkBSpline',
                                       "resampledPixelSpacing": None,
                                       "weightingNorm": None,
                                       "force2D": True,
                                       "force2Ddimension": 1,
                                       "additionalInfo": False},
                           "imageType": {"Original": {}},
                           "featureClass": {
                              "firstorder": [
                                'RootMeanSquared',
                                'Energy',
                                'TotalEnergy',
                                '10Percentile',
                                'Mean',
                                'Maximum',
                                'Skewness',
                                'Kurtosis',
                                '90Percentile',
                                'Median',
                                'MeanAbsoluteDeviation',
                                'Variance',
                                'Range',
                                'Minimum'],
                              "glcm": [
                                'Idn',
                                'Id',
                                'ClusterShade',
                                'Idmn',
                                'Autocorrelation',
                                'JointEntropy',
                                'Imc1',
                                'Imc2',
                                'Correlation',
                                'DifferenceVariance',
                                'JointEnergy',
                                'DifferenceAverage',
                                'JointAverage',
                                'Contrast',
                                'ClusterProminence',
                                'DifferenceEntropy'],
                              "glrlm": [
                                'RunPercentage',
                                'LongRunHighGrayLevelEmphasis',
                                'GrayLevelVariance',
                                'HighGrayLevelRunEmphasis',
                                'ShortRunHighGrayLevelEmphasis'],
                              "glszm": [
                                'LargeAreaHighGrayLevelEmphasis',
                                'HighGrayLevelZoneEmphasis',
                                'SmallAreaHighGrayLevelEmphasis',
                                'ZoneEntropy',
                                'ZonePercentage'],
                              "gldm": [
                                'LargeDependenceHighGrayLevelEmphasis',
                                'GrayLevelVariance',
                                'HighGrayLevelEmphasis']
                           }
                          }


base = os.path.dirname(__file__)
model_path = os.path.abspath(os.path.join(base, '../models/svmclassifier.C30_coef01.0_degree3_kernelpoly_selected_features100_histomics_rgb_color_histogram_rgb.joblib.pkl'))
model = joblib.load(model_path)

scaler_path = os.path.abspath(os.path.join(base, '../utils/scaler_gui_100_features.joblib.pkl'))
scaler = joblib.load(scaler_path)

tiles = []
tile_width, tile_height = 50, 50

r_chan_extractor = RadiomicsFeatureExtractor()
r_chan_extractor.settings = r_chan_extractor_params['setting']
r_chan_extractor.imageType = r_chan_extractor_params['imageType']
r_chan_extractor.enabledFeatures = r_chan_extractor_params['featureClass']

g_chan_extractor = RadiomicsFeatureExtractor()
g_chan_extractor.settings = g_chan_extractor_params['setting']
g_chan_extractor.imageType = g_chan_extractor_params['imageType']
g_chan_extractor.enabledFeatures = g_chan_extractor_params['featureClass']

b_chan_extractor = RadiomicsFeatureExtractor()
b_chan_extractor.settings = b_chan_extractor_params['setting']
b_chan_extractor.imageType = b_chan_extractor_params['imageType']
b_chan_extractor.enabledFeatures = b_chan_extractor_params['featureClass']


def run(d):
    global base
    global model
    global scaler
    global tiles
    global tile_width
    global tile_height
    global r_chan_extractor
    global g_chan_extractor
    global b_chan_extractor

    im = GetImageFromArray(tiles[d['x'], d['y']], isVector=True)
    msk_arr = ones(im.GetSize()[::-1], dtype='uint8')
    msk = GetImageFromArray(msk_arr)
    msk.CopyInformation(im)

    # Extract red channel image's features
    rc = VectorIndexSelectionCast(im, 0)
    rcf = r_chan_extractor.execute(rc, msk, label=1)

    # Extract green channel image's features
    gc = VectorIndexSelectionCast(im, 1)
    gcf = g_chan_extractor.execute(gc, msk, label=1)

    # Extract blue channel image's features
    bc = VectorIndexSelectionCast(im, 2)
    bcf = b_chan_extractor.execute(bc, msk, label=1)

    features = array(list(rcf.values()) + list(gcf.values()) + list(bcf.values()))
    features = features.reshape(1, len(features))

    features = scaler.transform(features)

    cols = (['r_chan_' + x for x in list(rcf.keys())] + ['g_chan_' + x for x in list(gcf.keys())]
            + ['b_chan_' + x for x in list(bcf.keys())])

    rf = DataFrame(features, columns=cols)

    y_pred = model.predict(rf[selected_features])

    return {'x': d['x']*tile_width, 'y': d['y']*tile_height, 'lbl': int(y_pred[0])}


def predict(queue, file_path):
    global model
    global tiles
    global tile_width
    global tile_height

    start = datetime.now()
    queue.put({'status': tr("Splitting image for processing")})
    wsi, tiles = split_wsi(file_path, tile_width, tile_height)

    pool = Pool(NUM_OF_WORKERS)

    def close(signum, frame):
        queue.put({'status': tr('Processing stopped')})
        queue.put({'status': 'stop'})
        pool.close()
        pool.terminate()
        sys.exit(0)

    signal.signal(signal.SIGTERM, close)
    signal.signal(signal.SIGINT, close)
    signal.signal(signal.SIGQUIT, close)

    jobs = []
    queue.put({'status': tr('Creating task list...')})
    for i in range(0, tiles.shape[0]):
        for j in range(0, tiles.shape[1]):
            jobs.append({'x': i, 'y': j})

    total_jobs = len(jobs)
    # queue.put({'status': "{} jobs loaded".format(total_jobs)})
    queue.put({'status': tr('Starting parallel processing with ' + str(NUM_OF_WORKERS) + ' paraller workers...')})

    data = []

    for i, d in enumerate(pool.imap_unordered(run, jobs)):
        data.append(d)
        progress = ((i + 1)/total_jobs)*100
        queue.put({'progress': round(progress, 2)})
        queue.put({'status': ("{:.0f}% ({} de {}) " + tr('processed')).format(progress, i + 1, total_jobs)})
    pool.close()
    pool.join()

    queue.put({'status': tr('Parallel processing finished')})
    # queue.put({'status': "{} jobs processed in {}".format(total_jobs, str(end - start))})

    queue.put({'status': tr('Creating highlighting mask...')})
    # msk_width = tiles.shape[0]*tile_width
    # msk_height = tiles.shape[1]*tile_height
    # msk = create_rgba_mask(data, msk_width, msk_height, tile_width, tile_height, 30)
    # queue.put({'status': 'Saving mask'})
    # fig = plt.figure(figsize=(wsi.shape[1] / 100, wsi.shape[0] / 100), dpi=100)
    # plt.gca().set_axis_off()
    # plt.subplots_adjust(top=1, bottom=0, right=1, left=0, hspace=0, wspace=0)
    # plt.margins(0, 0)
    # plt.gca().xaxis.set_major_locator(plt.NullLocator())
    # plt.gca().yaxis.set_major_locator(plt.NullLocator())
    # # plt.imshow(wsi, extent=(0, wsi.shape[1], 0, wsi.shape[0]))
    # plt.imshow(msk,  extent=(0, msk_width, 0, msk_height))
    # fig.savefig('output.png', format='png', dpi=100, bbox_inches='tight', pad_inches=0, transparent=True)
    end = datetime.now()
    queue.put({'status': (tr('Image processed in ') + '{}').format(end - start)})
    queue.put({'status': 'done'})
    return

