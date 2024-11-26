from PySide6.QtCore import QObject, Signal, Property
from datetime import datetime


class User(QObject):
    __id: str
    __email: str
    __email_verified_at: str
    __password: str
    __created_at: str
    __updated_at: str
    __firstname: str
    __lastname: str
    __avatar: str
    __role: str
    __username: str
    __notifications: list
    __authenticated: bool
    __authenticated_at: datetime

    def __init__(self,
                 id=None,
                 email=None,
                 email_verified_at=None,
                 password=None,
                 created_at=None,
                 updated_at=None,
                 firstname=None,
                 lastname=None,
                 avatar=None,
                 role=None,
                 username=None,
                 notifications=None,
                 authenticated=False,
                 authenticated_at=None):
        QObject.__init__(self)
        if notifications is None:
            notifications = []
        self.__id = id
        self.__email = email
        self.__email_verified_at = email_verified_at
        self.__password = password
        self.__created_at = created_at
        self.__updated_at = updated_at
        self.__firstname = firstname
        self.__lastname = lastname
        self.__avatar = avatar
        self.__role = role
        self.__username = username
        self.__notifications = notifications
        self.__authenticated = authenticated
        self.__authenticated_at = authenticated_at

    def get_id(self):
        return self.__id

    def set_id(self, id):
        self.__id = id
        self.on_id.emit()

    def get_email(self):
        return self.__email

    def set_email(self, email):
        self.__email = email
        self.on_email.emit()

    def get_email_verified_at(self):
        return self.__email_verified_at

    def set_email_verified_at(self, email_verified_at):
        self.__email_verified_at = email_verified_at
        self.on_email_verified_at.emit()

    def get_password(self):
        return self.__password

    def set_password(self, password):
        self.__password = password
        self.on_password.emit()

    def get_created_at(self):
        return self.__created_at

    def set_created_at(self, created_at):
        self.__created_at = created_at
        self.on_created_at.emit()

    def get_updated_at(self):
        return self.__updated_at

    def set_updated_at(self, updated_at):
        self.__updated_at = updated_at
        self.on_updated_at.emit()

    def get_firstname(self):
        return self.__firstname

    def set_firstname(self, firstname):
        self.__firstname = firstname
        self.on_firstname.emit()

    def get_lastname(self):
        return self.__lastname

    def set_lastname(self, lastname):
        self.__lastname = lastname
        self.on_lastname.emit()

    def get_avatar(self):
        return self.__avatar

    def set_avatar(self, avatar):
        self.__avatar = avatar
        self.on_avatar.emit()

    def get_role(self):
        return self.__role

    def set_role(self, role):
        self.__role = role
        self.on_role.emit()

    def get_notifications(self):
        return self.__notifications

    def set_notifications(self, notifications):
        self.__notifications = notifications
        self.on_notifications.emit()

    def get_authenticated(self):
        return self.__authenticated

    def set_authenticated(self, authenticated):
        self.__authenticated = authenticated
        self.on_authenticated.emit()

    def get_authenticated_at(self):
        return self.__authenticated_at

    def set_authenticated_at(self, authenticated_at):
        self.__authenticated_at = authenticated_at

    on_id = Signal()
    on_email = Signal()
    on_email_verified_at = Signal()
    on_password = Signal()
    on_created_at = Signal()
    on_updated_at = Signal()
    on_firstname = Signal()
    on_lastname = Signal()
    on_avatar = Signal()
    on_role = Signal()
    on_notifications = Signal()
    on_authenticated = Signal()

    id = Property(str, get_id, set_id, notify=on_id)
    email = Property(str, get_email, set_email, notify=on_email)
    email_verified_at = Property(str, get_email_verified_at, set_email_verified_at, notify=on_email_verified_at)
    password = Property(str, get_password, set_password, notify=on_password)
    created_at = Property(str, get_created_at, set_created_at, notify=on_created_at)
    updated_at = Property(str, get_updated_at, set_updated_at, notify=on_updated_at)
    firstname = Property(str, get_firstname, set_firstname, notify=on_firstname)
    lastname = Property(str, get_lastname, set_lastname, notify=on_lastname)
    avatar = Property(str, get_avatar, set_avatar, notify=on_avatar)
    role = Property(str, get_role, set_role, notify=on_role)
    notifications = Property(list, get_notifications, set_notifications, notify=on_notifications)
    authenticated = Property(bool, get_authenticated, set_authenticated, notify=on_authenticated)
