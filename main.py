#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
from PySide2.QtCore import QThread, Slot
from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine

from library.translator import Translator
from library.viewer import Viewer
from library.worker_interface import WorkerInterface
from library.worker_manager import WorkerManager


@Slot()
def update_app_language():
    app.installTranslator(translator.translator)
    engine.retranslate()


if __name__ == '__main__':
    os.environ['QT_QUICK_CONTROLS_CONF'] = 'resources/qtquickcontrols2.conf'

    app = QGuiApplication(sys.argv)
    app.instance().thread().setObjectName('MainThread')

    worker_manager = WorkerManager()
    worker_interface_thread = QThread()
    worker_interface_thread.setObjectName("WorkerInterfaceThread")
    worker_interface = WorkerInterface(start_signal=worker_manager.start, stop_signal=worker_manager.stop)
    worker_interface.msg_from_job.connect(worker_manager.receive_msg)
    worker_interface.moveToThread(worker_interface_thread)
    worker_interface_thread.start()

    viewer = Viewer()
    translator = Translator()
    translator.updateAppLanguage.connect(update_app_language)

    qml_file = os.path.abspath(os.path.join(os.path.dirname(__file__), 'main.qml'))

    engine = QQmlApplicationEngine()

    engine.rootContext().setContextProperty("worker_manager", worker_manager)
    engine.rootContext().setContextProperty("translator", translator)
    engine.rootContext().setContextProperty("viewer", viewer)

    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)

    root = engine.rootObjects()[0]
    rc = app.exec_()

    if worker_manager.running:
        worker_interface.stop()

    worker_interface_thread.quit()
    worker_interface_thread.wait()

    sys.exit(rc)

