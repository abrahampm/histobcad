from PySide2.QtCore import QObject, QTranslator, Slot, Signal


class Translator(QObject):
    updateAppLanguage = Signal()

    def __init__(self):
        super(Translator, self).__init__()
        self.translator = QTranslator()

    @Slot(str)
    def set_language(self, language):
        self.translator.load("i18n/qml_" + language + ".qm")
        self.updateAppLanguage.emit()
