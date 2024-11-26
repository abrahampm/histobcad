from PySide6.QtCore import QObject, Signal, Slot
from PySide6.QtGui import QGuiApplication
from multiprocessing import Process, Queue
from library.analysis_task import AnalysisTask
from numpy import ndarray
from skimage import io


class AnalysisRunner(QObject):

    msg_from_job = Signal(object)

    def __init__(self, start_signal, stop_signal):
        super(AnalysisRunner, self).__init__()
        self.analysis_process = None
        self.message_queue = None
        start_signal.connect(self._run_analysis)
        stop_signal.connect(self._close_analysis)

    @Slot(str, object)
    def _run_analysis(self, image_path: str, task_type):
        image = io.imread(image_path)
        try:
            task = task_type()
            if isinstance(task, AnalysisTask):
                self.message_queue = Queue()
                self.analysis_process = Process(target=task.run, args=(image, self.message_queue))
                self.analysis_process.start()

                while True:
                    msg = self.message_queue.get()
                    QGuiApplication.instance().processEvents()
                    if isinstance(msg, dict):
                        self.msg_from_job.emit(msg)
                        if 'error' in msg:
                            print(str(msg['error']))
                        if 'success' in msg:
                            break

            else:
                self.msg_from_job.emit({'success': False})
        except NotImplementedError:
            self.msg_from_job.emit({'success': False})

    @Slot()
    def _close_analysis(self):
        self.analysis_process.terminate()
