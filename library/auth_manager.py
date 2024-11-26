from PySide6.QtCore import QObject, Signal, Property, Slot
from PySide6.QtGui import QImage
from library.user_model import User


class AuthManager(QObject):
    __user: User
    __login_success: bool
    __login_message: str
    __login_loading: bool
    __register_success: bool
    __register_message: str
    __register_loading: bool
    __captcha_image_loading: bool

    def __init__(self):
        QObject.__init__(self)
        self.__user = User()
        self.__login_loading = False
        self.__register_loading = False
        self.__captcha_image_loading = True

    @Slot(str, str)
    def login(self, email, password):
        self.set_login_loading(True)
        self.do_login.emit(email, password)

    @Slot(str, str, str, str, str)
    def register(self, email, firstname, lastname, password, captcha):
        self.set_register_loading(True)
        self.do_register.emit(email, firstname, lastname, password, captcha)

    @Slot()
    def refresh_captcha(self):
        self.set_captcha_image_loading(True)
        self.on_refresh_captcha.emit()

    @Slot(bool, str, dict)
    def on_login_result(self, success: bool, message: str, user_data: dict):
        self.set_login_success(success)
        self.set_login_message(message)
        if success:
            self.set_user(User(**user_data))
            self.__user.set_authenticated(True)
        self.set_login_loading(False)

    @Slot(bool, str, dict)
    def on_register_result(self, success: bool, message: str, user_data):
        self.set_register_success(success)
        self.set_register_message(message)
        if success:
            self.set_user(User(**user_data))
        self.set_register_loading(False)

    @Slot(QImage)
    def on_captcha_image_result(self, image):
        self.on_captcha_image.emit(image)
        self.set_captcha_image_loading(False)

    def get_user(self):
        return self.__user

    def set_user(self, user):
        self.__user = user
        self.on_user.emit()

    def get_login_success(self):
        return self.__login_success

    def set_login_success(self, login_success):
        self.__login_success = login_success
        self.on_login_success.emit(login_success)

    def get_register_success(self):
        return self.__register_success

    def set_register_success(self, register_success):
        self.__register_success = register_success
        self.on_register_success.emit(register_success)

    def get_login_message(self):
        return self.__login_message

    def set_login_message(self, login_message):
        self.__login_message = login_message
        self.on_login_message.emit(login_message)

    def get_register_message(self):
        return self.__register_message

    def set_register_message(self, register_message):
        self.__register_message = register_message
        self.on_register_message.emit(register_message)

    def get_captcha_image_loading(self):
        return self.__captcha_image_loading

    def set_captcha_image_loading(self, status):
        self.__captcha_image_loading = status
        self.on_captcha_image_loading.emit(status)

    def get_login_loading(self):
        return self.__login_loading

    def set_login_loading(self, status):
        self.__login_loading = status
        self.on_login_loading.emit()

    def get_register_loading(self):
        return self.__register_loading

    def set_register_loading(self, status):
        self.__register_loading = status
        self.on_register_loading.emit()

    do_login = Signal(str, str)
    do_register = Signal(str, str, str, str, str)

    on_user = Signal()
    on_login_success = Signal(bool)
    on_login_message = Signal(str)
    on_login_loading = Signal()
    on_register_success = Signal(bool)
    on_register_message = Signal(str)
    on_register_loading = Signal()
    on_refresh_captcha = Signal()
    on_captcha_image = Signal(QImage)
    on_captcha_image_loading = Signal(bool)

    user = Property(User, get_user, set_user, notify=on_user)
    login_success = Property(bool, get_login_success, set_login_success, notify=on_login_success)
    login_message = Property(str, get_login_message, set_login_message, notify=on_login_message)
    login_loading = Property(bool, get_login_loading, set_login_loading, notify=on_login_loading)
    register_success = Property(bool, get_register_success, set_register_success, notify=on_register_success)
    register_message = Property(str, get_register_message, set_register_message, notify=on_register_message)
    register_loading = Property(bool, get_register_loading, set_register_loading, notify=on_register_loading)
    captcha_image_loading = Property(bool, get_captcha_image_loading, set_captcha_image_loading, notify=on_captcha_image_loading)

