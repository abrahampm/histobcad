from PySide2.QtCore import QObject, Signal, Property, Slot, QByteArray
from PySide2.QtGui import QImage
import requests
from library.user_model import User
from datetime import datetime


class PersonalAccessToken:
    token: str
    token_type: str
    token_expires: datetime

    def __init__(self, access_token=None, token_type=None, token_expires=None):
        self.token = access_token
        self.token_type = token_type
        if type(token_expires) == datetime:
            self.token_expires = token_expires
        elif type(token_expires) == str:
            try:
                self.token_expires = datetime.strptime(token_expires, "%Y-%m-%d %H:%M:%S")
            except ValueError as e:
                print(e)

    def is_expired(self):
        return datetime.now() > self.token_expires


class AuthService(QObject):
    __user: User
    __token: PersonalAccessToken
    __session: requests.Session
    __api_base: str

    def __init__(self, on_login: Signal, on_register: Signal, on_refresh_captcha: Signal,
                 api_base: str, requests_session: requests.Session):
        QObject.__init__(self)
        self.__user = User()
        self.__api_base = api_base
        self.__session = requests_session
        on_login.connect(self.login)
        on_register.connect(self.register)
        on_refresh_captcha.connect(self.get_captcha_image)

    @Slot(str, str)
    def login(self, email, password):
        login_response = self.__session.post(self.__api_base + "/auth/login", {"email": email, "password": password})
        login_data = login_response.json()
        if login_response.status_code == 200:
            self.__token = PersonalAccessToken(**login_data["token"])
            user_data = {**login_data["user"], "authenticated": True, "authenticated_at": datetime.now()}
            self.__user = User(**user_data)
            self.on_login_result.emit(True, login_data["login"], user_data)

        elif login_response.status_code == 401:
            self.on_login_result.emit(False, login_data["message"], dict())

        else:
            print(login_response.content)

    @Slot(str, str, str, str, str)
    def register(self, email, firstname, lastname, password, captcha):
        user_data = {
            "email": email,
            "firstname": firstname,
            "lastname": lastname,
            "password": password,
            "captcha": captcha
        }
        register_response = self.__session.post(self.__api_base + "/auth/register", user_data, allow_redirects=False)
        if register_response.status_code == 201:
            register_data = register_response.json()
            self.on_register_result.emit(True, register_data["register"], dict())

        else:
            print(register_response.content)

    @Slot()
    def get_captcha_image(self):
        captcha_response = self.__session.get(self.__api_base + "/captcha/create")
        captcha_src = captcha_response.json()
        if captcha_response.status_code == 200 and "captcha" in captcha_src:
            captcha_image = self.__session.get(captcha_src["captcha"])
            if captcha_image.status_code == 200:
                q_image = QImage()
                q_image.loadFromData(QByteArray(captcha_image.content), "PNG")
                self.on_captcha_image.emit(q_image.copy())

    on_captcha_image = Signal(QImage)
    on_login_result = Signal(bool, str, dict)
    on_register_result = Signal(bool, str, dict)
