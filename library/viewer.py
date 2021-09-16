import os
import re

from PySide2.QtCore import QObject, QStringListModel, QUrl, Signal, Property, Slot, QAbstractItemModel
from PySide2.QtGui import QImage
from numpy import ndarray


class Viewer(QObject):
    def __init__(self):
        QObject.__init__(self)
        self._mask_image = QImage()
        self._mask_image_enabled = False
        self._selected_file = ""
        self._selected_file_folder = ""
        self._selected_file_siblings = QStringListModel(self)
        self._supported_file_extensions = r'.png$|.jpg$'

    def get_selected_file(self):
        return self._selected_file

    def get_mask_image(self):
        return self._mask_image

    def get_mask_image_enabled(self):
        return self._mask_image_enabled

    def get_selected_file_siblings(self):
        return self._selected_file_siblings

    def set_selected_file(self, file):
        if isinstance(file, QUrl):
            self._selected_file = file.toLocalFile()
        elif isinstance(file, str):
            self.selected_file = file
        self.on_selected_file.emit()
        self._detect_selected_file_siblings()

    @Slot(ndarray)
    def set_mask_image(self, image_array):
        print("viewer set mask image " + str(image_array.shape))
        if isinstance(image_array, ndarray) and image_array.dtype == 'uint8':
            q_image = QImage()
            if len(image_array.shape) == 2:
                h, w = image_array.shape
                q_image = QImage(image_array.data, w, h, QImage.Format_Indexed8)
            elif len(image_array.shape) == 3:
                h, w, c = image_array.shape
                if c == 3:
                    q_image = QImage(image_array.data, w, h, QImage.Format_RGB888)
                elif c == 4:
                    q_image = QImage(image_array.data, w, h, QImage.Format_RGBA8888)

            self._mask_image = q_image.copy()
        else:
            self._mask_image = QImage()

        self.set_mask_image_enabled(False)
        self.on_mask_image.emit(self._mask_image)
        self.set_mask_image_enabled(True)

    def set_mask_image_enabled(self, value: bool):
        self._mask_image_enabled = value
        print("mask image enabled" + str(value))
        self.on_mask_image_enabled.emit(value)

    @Slot(list)
    def set_selected_file_siblings(self, files):
        self._selected_file_siblings.setStringList(files)
        self.on_selected_file_siblings.emit()

    def _detect_selected_file_siblings(self):
        if self._selected_file_folder != os.path.dirname(self._selected_file):
            self._selected_file_folder = os.path.dirname(self._selected_file)
            temp_siblings = []
            with os.scandir(self._selected_file_folder) as d:
                for entry in d:
                    if entry.is_file() and re.search(self._supported_file_extensions, entry.name):
                        file_path = os.path.abspath(os.path.join(self._selected_file_folder, entry.name))
                        temp_siblings.append(file_path)
            temp_siblings = sorted(temp_siblings)
            self.set_selected_file_siblings(temp_siblings)

    on_mask_image = Signal(QImage)
    on_mask_image_enabled = Signal(bool)
    on_selected_file = Signal()
    on_selected_file_siblings = Signal()

    mask_image = Property(QImage, get_mask_image, set_mask_image, notify=on_mask_image)
    mask_image_enabled = Property(bool, get_mask_image_enabled, set_mask_image_enabled, notify=on_mask_image_enabled)
    selected_file = Property(QUrl, get_selected_file, set_selected_file, notify=on_selected_file)
    selected_file_siblings = Property(QAbstractItemModel, get_selected_file_siblings, set_selected_file_siblings, notify=on_selected_file_siblings)
