#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import re
import sys

# from PySide2.QtQuick import QQuickView
from PySide2.QtCore import QThread, QObject, QUrl, Signal, Slot, Property, QStringListModel, QAbstractItemModel
from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine

from multiprocessing import Process, Queue
from library.parallel_worker import predict


class Worker(QObject):

    msg_from_job = Signal(object)

    def __init__(self, start_signal):
        super(Worker, self).__init__()
        self.job_input = None
        self.worker_process = None
        self.worker_queue = None
        start_signal.connect(self._run)
        # print('Init runner thread')
        # print(self.thread().objectName())

    @Slot()
    def _run(self):
        # print('Run runner method thread')
        # print(self.thread().objectName())
        app.processEvents()
        self.worker_queue = Queue()
        self.worker_process = Process(target=predict, args=(self.worker_queue, self.job_input))
        self.worker_process.start()
        while True:
            msg = self.worker_queue.get()
            self.msg_from_job.emit(msg)
            if isinstance(msg, dict):
                if 'status' in msg:
                    if msg['status'] == 'done' or msg['status'] == 'stop':
                        break

    @Slot()
    def stop(self):
        # self.worker_process.close()
        self.worker_process.terminate()
        self.thread().exit()


class WorkerManager(QObject):
    def __init__(self):
        QObject.__init__(self)
        self._progress = 0
        self._running = False
        self._status = ""

    @Slot()
    def start(self):
        if viewer.get_selected_file():
            worker.job_input = viewer.get_selected_file()
            worker_thread.start()
            self._set_running(True)

    @Slot()
    def stop(self):
        worker.stop()
        worker_thread.quit()
        worker_thread.wait()
        self._set_running(False)

    def receive_msg(self, msg):
        if isinstance(msg, dict):
            if 'status' in msg:
                # print(msg['status'])
                if msg['status'] == 'done':
                    self._set_running(False)
                    viewer.set_mask_file('output.png')
                    worker_thread.quit()
                    worker_thread.wait()
                else:
                    self._set_status(msg['status'])
            elif 'progress' in msg:
                self._set_progress(msg['progress'])

    def _get_progress(self):

        return self._progress

    def _get_running(self):
        return self._running

    def _get_status(self):
        return self._status

    def _set_progress(self, progress):
        self._progress = progress
        self.on_progress.emit()

    def _set_running(self, running):
        self._running = running
        self.on_running.emit()

    def _set_status(self, status):
        self._status = status
        self.on_status.emit()

    on_progress = Signal()
    on_running = Signal()
    on_status = Signal()

    progress = Property(float, _get_progress, _set_progress, notify=on_progress)
    running = Property(bool, _get_running, _set_running, notify=on_running)
    status = Property(str, _get_status, _set_status, notify=on_status)


class Viewer(QObject):
    def __init__(self):
        QObject.__init__(self)
        self._selected_file = ""
        self._mask_file = ""
        self._selected_file_siblings = QStringListModel(self)
        self._supported_file_extensions = r'.png$|.jpg$'

    def get_selected_file(self):
        return self._selected_file

    def get_mask_file(self):
        return self._mask_file

    def get_selected_file_siblings(self):
        return self._selected_file_siblings

    def set_selected_file(self, file):
        if isinstance(file, QUrl):
            self._selected_file = file.toLocalFile()
        elif isinstance(file, str):
            self.selected_file = file
        self.on_selected_file.emit()
#        print(self._selected_file)
        self._detect_selected_file_siblings()

    def set_mask_file(self, file):
        if isinstance(file, QUrl):
            self._mask_file = file.toLocalFile()
        elif isinstance(file, str):
            self._mask_file = file
        self.on_mask_file.emit()

    @Slot(list)
    def set_selected_file_siblings(self, files):
        self._selected_file_siblings.setStringList(files)
        self.on_selected_file_siblings.emit()

    def _detect_selected_file_siblings(self):
        selected_file_folder = os.path.dirname(self._selected_file)
        temp_siblings = []
        with os.scandir(selected_file_folder) as d:
            for entry in d:
                if entry.is_file() and re.search(self._supported_file_extensions, entry.name):
                    # if entry.name != self._selected_file:
                    file_path = os.path.abspath(os.path.join(selected_file_folder, entry.name))
                    temp_siblings.append(file_path)
        # print(temp_siblings)
        self.set_selected_file_siblings(temp_siblings)

    on_mask_file = Signal()
    on_selected_file = Signal()
    on_selected_file_siblings = Signal()

    mask_file = Property(QUrl, get_mask_file, set_mask_file, notify=on_mask_file)
    selected_file = Property(QUrl, get_selected_file, set_selected_file, notify=on_selected_file)
    selected_file_siblings = Property(QAbstractItemModel, get_selected_file_siblings, set_selected_file_siblings, notify=on_selected_file_siblings)


if __name__ == '__main__':
    os.environ['QT_QUICK_CONTROLS_CONF'] = 'resources/qtquickcontrols2.conf'

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

    # view = QQuickView()
    # view.setResizeMode(QQuickView.SizeRootObjectToView)
    # view.rootContext().setContextProperty("worker", worker_interface)
    # view.setSource(QUrl(qml_file))
    # view.show()

    engine = QQmlApplicationEngine()

    engine.rootContext().setContextProperty("worker", worker_manager)
    engine.rootContext().setContextProperty("viewer", viewer)

    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)

    root = engine.rootObjects()[0]

    rc = app.exec_()

    if worker_manager.running:
        worker.stop()

    sys.exit(rc)

