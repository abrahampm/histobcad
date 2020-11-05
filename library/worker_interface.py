from PySide2.QtCore import QObject, Signal, Slot
from multiprocessing import Process, Queue

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
