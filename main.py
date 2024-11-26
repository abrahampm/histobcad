#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import requests
from PySide6.QtCore import QThread, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from library.auth_service import AuthService
from library.deepzoom.deepzoom_server import DeepZoomServer
from library.deepzoom.deepzoom_viewer import DeepZoomViewer
from library.deepzoom.openslide_server import OpenSlideServer
from library.translator import Translator
from library.viewer import Viewer
from library.viewer_image_provider import ViewerImageProvider
from library.captcha_image_provider import CaptchaImageProvider
from library.analysis_runner import AnalysisRunner
from library.analysis_manager import AnalysisManager
from library.auth_manager import AuthManager
# noinspection PyUnresolvedReferences
from resources import resources_rc

@Slot()
def update_app_language():
    app.installTranslator(translator.translator)
    engine.retranslate()


API_URL = "http://histobcad-server.docksal/api"
DEEPZOOM_HOST = "localhost"
DEEPZOOM_PORT = 8989


if __name__ == '__main__':
    base_path = os.path.dirname(__file__)

    requests_session = requests.Session()
    requests_thread = QThread()
    requests_thread.setObjectName("HistoBCAD_Requests")

    app = QGuiApplication(sys.argv)
    app.instance().thread().setObjectName('SlideSimple')

    analysis_manager = AnalysisManager()
    analysis_runner_thread = QThread()
    analysis_runner_thread.setObjectName("HistoBCAD_Runner")
    analysis_runner = AnalysisRunner(start_signal=analysis_manager.start, stop_signal=analysis_manager.stop)
    analysis_runner.msg_from_job.connect(analysis_manager.receive_message)
    analysis_runner.moveToThread(analysis_runner_thread)
    analysis_runner_thread.start()

    viewer = Viewer()
    viewer_image_provider = ViewerImageProvider()
    viewer.on_mask_image.connect(viewer_image_provider.set_mask_image)
    analysis_manager.on_output_mask.connect(viewer.set_mask_image)

    deepzoom_server_thread = QThread()
    deepzoom_server_thread.setObjectName("HistoBCAD_DeepZoom")
    openslide_server = OpenSlideServer(base_path)
    deepzoom_server = DeepZoomServer(DEEPZOOM_HOST, DEEPZOOM_PORT, openslide_server)
    deepzoom_viewer = DeepZoomViewer(server=deepzoom_server)
    deepzoom_server.moveToThread(deepzoom_server_thread)
    deepzoom_server_thread.started.connect(deepzoom_server.run)
    deepzoom_server_thread.start()

    auth_manager = AuthManager()
    auth_service = AuthService(on_login=auth_manager.do_login, on_register=auth_manager.do_register,
                               on_refresh_captcha=auth_manager.on_refresh_captcha, api_base=API_URL,
                               requests_session=requests_session)
    captcha_image_provider = CaptchaImageProvider()
    auth_service.on_login_result.connect(auth_manager.on_login_result)
    auth_service.on_register_result.connect(auth_manager.on_register_result)
    auth_service.on_captcha_image.connect(auth_manager.on_captcha_image_result)
    auth_manager.on_captcha_image.connect(captcha_image_provider.set_captcha_image)

    auth_service.moveToThread(requests_thread)
    requests_thread.start()

    translator = Translator()
    translator.updateAppLanguage.connect(update_app_language)

    qml_file = os.path.abspath(os.path.join(os.path.dirname(__file__), 'main.qml'))

    engine = QQmlApplicationEngine()

    engine.addImageProvider("viewer_image_provider", viewer_image_provider)
    engine.addImageProvider("captcha_image_provider", captcha_image_provider)
    engine.rootContext().setContextProperty("analysis_manager", analysis_manager)
    engine.rootContext().setContextProperty("translator", translator)
    # engine.rootContext().setContextProperty("viewer", viewer)
    engine.rootContext().setContextProperty("viewer", deepzoom_viewer)
    engine.rootContext().setContextProperty("auth_manager", auth_manager)
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)

    rc = app.exec()

    if analysis_manager.running:
        analysis_manager.stop_analysis()
    try:
        deepzoom_server.stop()
    except KeyboardInterrupt:
        pass

    requests_thread.quit()
    requests_thread.wait()
    analysis_runner_thread.quit()
    analysis_runner_thread.wait()
    deepzoom_server_thread.quit()
    deepzoom_server_thread.wait()
    print("Shutting down")
    sys.exit(rc)

