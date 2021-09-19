from PySide2.QtCore import QObject, Signal, Property, Slot
from library.analysis_task import AnalysisTask
from models.idc_detection.rf import RF100
from models.idc_detection.svm import SVM100
from numpy import ndarray


class AnalysisManager(QObject):
    def __init__(self):
        QObject.__init__(self)
        self._progress = 0
        self._running = False
        self._status = ""
        self._tasks = {
            "idc_detection_model1": RF100,
            "idc_detection_model2": SVM100,
        }

    @Slot(str, str)
    def start_analysis(self, image_path, task_name):
        if task_name in self._tasks:
            task = self._tasks[task_name]
            if issubclass(task, AnalysisTask):
                self.start.emit(image_path, task)
                self._set_running(True)

    @Slot()
    def stop_analysis(self):
        self.stop.emit()
        self._set_running(False)

    def receive_message(self, msg: dict):
        if 'status' in msg:
            self._set_status(msg['status'])
        if 'progress' in msg:
            self._set_progress(msg['progress'])
        if 'output' in msg:
            if 'mask' in msg['output']:
                self.on_output_mask.emit(msg['output']['mask'])
        if 'error' in msg or 'stop' in msg:
            self._set_running(False)
        if 'success' in msg:
            self._set_running(False)

    def _get_progress(self):
        return self._progress

    def _set_progress(self, progress):
        self._progress = progress
        self.on_progress.emit()

    def _get_running(self):
        return self._running

    def _set_running(self, running):
        self._running = running
        self.on_running.emit()

    def _get_status(self):
        return self._status

    def _set_status(self, status):
        self._status = status
        self.on_status.emit()

    on_output_mask = Signal(ndarray)
    on_progress = Signal()
    on_running = Signal()
    on_status = Signal()
    start = Signal(str, object)
    stop = Signal()

    progress = Property(float, _get_progress, _set_progress, notify=on_progress)
    running = Property(bool, _get_running, _set_running, notify=on_running)
    status = Property(str, _get_status, _set_status, notify=on_status)
