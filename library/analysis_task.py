import sys
import signal
from abc import abstractmethod
from multiprocessing import Queue
from numpy import ndarray


class AnalysisTask:
    _message_queue: Queue

    def run(self, image: ndarray, message_queue: Queue):
        self._message_queue = message_queue
        signal.signal(signal.SIGTERM, self._close)
        signal.signal(signal.SIGINT, self._close)
        signal.signal(signal.SIGQUIT, self._close)
        try:
            output = self._process(image)
            message_queue.put({'success': True, 'output': output})
        except Exception as e:
            message_queue.put({'success': False, 'error': e})

    @abstractmethod
    def _process(self, image: ndarray) -> dict: raise NotImplementedError

    def _close(self, signum, frame):
        self._message_queue.put({'success': False, 'status': 'stopped'})
        sys.exit(0)

    def __getstate__(self):
        state = self.__dict__.copy()
        del state['_message_queue']
        return state

    def __setstate__(self, state):
        self.__dict__.update(state)
