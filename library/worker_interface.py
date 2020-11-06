from PySide2.QtCore import QObject, Signal, Slot
from PySide2.QtGui import QGuiApplication
from multiprocessing import Process, Queue
from library.worker_parallel import predict


class WorkerInterface(QObject):

    msg_from_job = Signal(object)

    def __init__(self, start_signal, stop_signal):
        super(WorkerInterface, self).__init__()
        self.worker_process = None
        self.worker_queue = None
        start_signal.connect(self._start_worker)
        stop_signal.connect(self._stop_worker)
        # print('Init runner thread')
        # print(self.thread().objectName())

    @Slot(str)
    def _start_worker(self, job_input):
        self.worker_queue = Queue()
        self.worker_process = Process(target=predict, args=(self.worker_queue, job_input))
        self.worker_process.start()
        while True:
            msg = self.worker_queue.get()
            self.msg_from_job.emit(msg)
            QGuiApplication.instance().processEvents()
            if isinstance(msg, dict):
                if 'status' in msg:
                    if msg['status'] == 'done' or msg['status'] == 'stop':
                        break

    @Slot()
    def _stop_worker(self):
        self.worker_process.terminate()
