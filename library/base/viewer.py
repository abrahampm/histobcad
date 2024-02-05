import os
import re

from PySide2.QtCore import QObject, Signal, Property, QUrl, QAbstractItemModel, QStringListModel


class Viewer(QObject):
    def __init__(self):
        QObject.__init__(self)
        self._selected_file_url = ""
        self._selected_file_name = ""
        self._selected_file_folder = ""
        self._selected_file_thumbnail_url = ""
        self._last_selected_file_folder = ""
        self._selected_file_siblings = QStringListModel(self)
        self._supported_file_extensions = ""

    def get_selected_file(self):
        return self._selected_file_url

    def set_selected_file(self, file_url):
        raise NotImplementedError

    def get_selected_file_siblings(self):
        return self._selected_file_siblings

    def set_selected_file_siblings(self):
        raise NotImplementedError

    def get_selected_file_thumbnail(self):
        return self._selected_file_thumbnail_url

    def set_selected_file_thumbnail(self):
        raise NotImplementedError

    def get_supported_file_extensions(self):
        raise NotImplementedError

    def set_supported_file_extensions(self):
        raise NotImplementedError

    def _set_selected_file(self, file):
        if isinstance(file, QUrl):
            if file.isLocalFile():
                self._selected_file_path = file.toLocalFile()
            else:
                file_name = file.toString().split('/')[3]
                self._selected_file_path = os.path.join(self._selected_file_folder, file_name)
        elif isinstance(file, str):
            self._selected_file_path = file
        else:
            return
        self._selected_file_name = os.path.basename(self._selected_file_path)
        self._selected_file_folder = os.path.dirname(self._selected_file_path)

    def _scan_working_dir(self):
        if self._selected_file_folder != self._last_selected_file_folder:
            self._last_selected_file_folder = self._selected_file_folder
            temp_siblings = []
            with os.scandir(self._selected_file_folder) as d:
                for entry in d:
                    supported_file_extensions_re = re.compile('.' + '$|.'.join(self._supported_file_extensions) + '$')
                    if entry.is_file() and re.search(supported_file_extensions_re, entry.name):
                        temp_siblings.append(entry.name)
                return sorted(temp_siblings)

    reload = Signal()
    on_selected_file = Signal()
    on_selected_file_thumbnail = Signal()
    on_selected_file_siblings = Signal()
    on_supported_file_extensions = Signal()

    selected_file = Property(QUrl, get_selected_file, set_selected_file, notify=on_selected_file)
    selected_file_thumbnail = Property(QUrl, get_selected_file_thumbnail, set_selected_file_thumbnail, notify=on_selected_file_thumbnail)
    selected_file_siblings = Property(QAbstractItemModel, get_selected_file_siblings, set_selected_file_siblings, notify=on_selected_file_siblings)
    supported_file_extensions = Property(str, get_supported_file_extensions, notify=on_supported_file_extensions)
