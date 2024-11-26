from PySide6.QtQuick import QQuickImageProvider
from PySide6.QtCore import QSize, Slot, Signal
from PySide6.QtGui import QImage
from PySide6.QtQml import QQmlImageProviderBase


class ViewerImageProvider (QQuickImageProvider):
    def __init__(self, type=QQmlImageProviderBase.ImageType.Image):
        super().__init__(type)
        self._mask_image = QImage()

    def requestImage(self, id: str, size: QSize, requestedSize: QSize) -> QImage:
        print("provider request image function. id: " + id)
        if id == 'mask_image':
            return self._mask_image

    @Slot(QImage)
    def set_mask_image(self, image):
        print("provider set mask image function.")

        self._mask_image = image
