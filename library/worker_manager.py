from PySide2.QtCore import QObject, Signal, Property, Slot
from numpy import ndarray


class WorkerManager(QObject):
    def __init__(self):
        QObject.__init__(self)
        self._progress = 0
        self._running = False
        self._status = ""

    @Slot(str)
    def start_worker(self, target):
        self.start.emit(target)
        self._set_running(True)

    @Slot()
    def stop_worker(self):
        self.stop.emit()
        self._set_running(False)

    def receive_msg(self, msg):
        if isinstance(msg, dict):
            if 'status' in msg:
                self._set_status(msg['status'])
            if 'progress' in msg:
                self._set_progress(msg['progress'])
            if 'error' in msg or 'stop' in msg:
                self._set_running(False)
            if 'success' in msg:
                self._set_running(False)
                if msg['success'] is True and 'output' in msg:
                    if 'mask' in msg['output']:
                        self.on_output_mask.emit(msg['output']['mask'])

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
    start = Signal(str)
    stop = Signal(str)

    progress = Property(float, _get_progress, _set_progress, notify=on_progress)
    running = Property(bool, _get_running, _set_running, notify=on_running)
    status = Property(str, _get_status, _set_status, notify=on_status)
