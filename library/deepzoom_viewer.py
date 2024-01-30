import os
import re

from PySide2.QtCore import QObject, QStringListModel, QUrl, Signal, Property, Slot, QAbstractItemModel
from PySide2.QtPositioning import QGeoCoordinate

from library.deepzoom_server import DeepZoomServer


class DeepZoomViewer(QObject):
    def __init__(self, server: DeepZoomServer):
        QObject.__init__(self)
        self._selected_file_url = ""
        self._selected_file_name = ""
        self._selected_file_folder = ""
        self._last_selected_file_folder = ""
        self._selected_file_siblings = QStringListModel(self)
        self._supported_file_extensions = r'.tif$|.tiff$|.dcm$|.ndpi$|.vms$|.vmu$|.scn$|.mrxs$|.svslide$|.bif$'
        self._server = server
        self._dzi_levels = tuple()
        self._dzi_dimensions = tuple()
        self._dzi_min_zoom_level = 0
        self._dzi_max_zoom_level = 0

    def get_selected_file(self):
        return self._selected_file_url

    def get_selected_file_siblings(self):
        return self._selected_file_siblings

    def set_selected_file(self, file):
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
        self._server.set_base_dir(self._selected_file_folder)
        self._set_dzi_info()
        self._selected_file_url = self._server.get_slide_url(self._selected_file_name)
        self.on_selected_file.emit()
        self.reload.emit()
        self._detect_selected_file_siblings()
        print("Selected file: ", self._selected_file_url)
        print("Selected file folder: ", self._selected_file_folder)

    @Slot(list)
    def set_selected_file_siblings(self, files):
        self._selected_file_siblings.setStringList(files)
        self.on_selected_file_siblings.emit()

    def _detect_selected_file_siblings(self):
        if self._selected_file_folder != self._last_selected_file_folder:
            self._last_selected_file_folder = self._selected_file_folder
            temp_siblings = []
            with os.scandir(self._selected_file_folder) as d:
                for entry in d:
                    if entry.is_file() and re.search(self._supported_file_extensions, entry.name):
                        slide_path = self._server.get_thumbnail_url(entry.name)
                        temp_siblings.append(slide_path)
            temp_siblings = sorted(temp_siblings)
            self.set_selected_file_siblings(temp_siblings)

    def _set_dzi_info(self):
        self._dzi_levels = self._server.get_level_tiles(self._selected_file_name)
        self._dzi_dimensions = self._server.get_level_dimensions(self._selected_file_name)
        print(self._dzi_levels)
        print(self._dzi_dimensions)
        self.set_dzi_min_zoom_level()
        self.set_dzi_max_zoom_level()
    
    def get_dzi_max_width(self):
        return self._dzi_dimensions[-1][0]

    def get_dzi_max_height(self):
        return self._dzi_dimensions[-1][1]

    def get_dzi_min_zoom_level(self):
        return self._dzi_min_zoom_level

    def set_dzi_min_zoom_level(self):
        self._dzi_min_zoom_level = next(x[0] for x in enumerate(self._dzi_levels) if max(x[1]) > 2)
        self.on_dzi_min_zoom_level.emit()

    def get_dzi_max_zoom_level(self):
        return self._dzi_max_zoom_level

    def set_dzi_max_zoom_level(self):
        self._dzi_max_zoom_level = len(self._dzi_levels) - 1
        self.on_dzi_max_zoom_level.emit()


    reload = Signal()
    on_dzi_max_width = Signal()
    on_dzi_max_height = Signal()
    on_dzi_min_zoom_level = Signal()
    on_dzi_max_zoom_level = Signal()
    on_selected_file = Signal()
    on_selected_file_siblings = Signal()

    dzi_max_width = Property(int, get_dzi_max_width, notify=on_dzi_max_width)
    dzi_max_height = Property(int, get_dzi_max_height, notify=on_dzi_max_height)
    dzi_min_zoom_level = Property(int, get_dzi_min_zoom_level, set_dzi_min_zoom_level, notify=on_dzi_min_zoom_level)
    dzi_max_zoom_level = Property(int, get_dzi_max_zoom_level, set_dzi_max_zoom_level, notify=on_dzi_max_zoom_level)
    selected_file = Property(QUrl, get_selected_file, set_selected_file, notify=on_selected_file)
    selected_file_siblings = Property(QAbstractItemModel, get_selected_file_siblings, set_selected_file_siblings, notify=on_selected_file_siblings)
