#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
from PySide2.QtCore import QThread
from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from library.viewer import Viewer
from library.worker_interface import Worker
from library.worker_manager import WorkerManager

if __name__ == '__main__':
    # os.environ['QT_QUICK_CONTROLS_CONF'] = 'resources/qtquickcontrols2.conf'

    app = QGuiApplication(sys.argv)
    # print('Main thread: ')
    # app.instance().thread().setObjectName('MainThread')
    # print(app.instance().thread().objectName())

    worker_manager = WorkerManager()
    worker_thread = QThread()
    worker_thread.setObjectName("WorkerThread")
    worker = Worker(start_signal=worker_thread.started)
    worker.msg_from_job.connect(worker_manager.receive_msg)
    worker.moveToThread(worker_thread)

    viewer = Viewer()

    qml_file = os.path.abspath(os.path.join(os.path.dirname(__file__), 'main.qml'))

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("worker_manager", worker_manager)
    engine.rootContext().setContextProperty("viewer", viewer)

    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)

    root = engine.rootObjects()[0]
    rc = app.exec_()

    if worker_manager.running:
        worker.stop()

    sys.exit(rc)

