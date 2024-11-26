from PySide6.QtQuick import QQuickImageProvider
from PySide6.QtCore import QSize, Slot, Signal
from PySide6.QtGui import QImage
from PySide6.QtQml import QQmlImageProviderBase


class CaptchaImageProvider (QQuickImageProvider):
    def __init__(self, type=QQmlImageProviderBase.ImageType.Image):
        super().__init__(type)
        self.__captcha_image = QImage()

    def requestImage(self, id: str, size: QSize, requestedSize: QSize) -> QImage:
        print("captcha image provider request image function. id: " + id)
        if id == "captcha_image" or id == "captcha_image1":
            return self.__captcha_image

    @Slot(QImage)
    def set_captcha_image(self, image):
        print("captcha image provider set mask image function.")
        self.__captcha_image = image
