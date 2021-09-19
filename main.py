#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
from PySide2.QtCore import QThread, Slot
from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from library.translator import Translator
from library.viewer import Viewer
from library.viewer_image_provider import ViewerImageProvider
from library.analysis_runner import AnalysisRunner
from library.analysis_manager import AnalysisManager
from resources import resources_rc

@Slot()
def update_app_language():
    app.installTranslator(translator.translator)
    engine.retranslate()


if __name__ == '__main__':

    app = QGuiApplication(sys.argv)
    app.instance().thread().setObjectName('HistoBCAD')

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

    translator = Translator()
    translator.updateAppLanguage.connect(update_app_language)

    qml_file = os.path.abspath(os.path.join(os.path.dirname(__file__), 'main.qml'))

    engine = QQmlApplicationEngine()

    engine.addImageProvider("viewer_image_provider", viewer_image_provider)
    engine.rootContext().setContextProperty("analysis_manager", analysis_manager)
    engine.rootContext().setContextProperty("translator", translator)
    engine.rootContext().setContextProperty("viewer", viewer)
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)

    rc = app.exec_()

    if analysis_manager.running:
        analysis_manager.stop_analysis()

    analysis_runner_thread.quit()
    analysis_runner_thread.wait()

    sys.exit(rc)

