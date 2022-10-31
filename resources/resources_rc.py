# Resource object code (Python 3)
# Created by: object code
# Created by: The Resource Compiler for Qt version 5.15.1
# WARNING! All changes made in this file will be lost!

from PySide2 import QtCore

qt_resource_data = b"\
\x00\x00\x019\
#\
This file can be\
 edited to chang\
e the style of t\
he application\x0a#\
Read \x22Qt Quick C\
ontrols 2 Config\
uration File\x22 fo\
r details:\x0a#http\
://doc.qt.io/qt-\
5/qtquickcontrol\
s2-configuration\
.html\x0a\x0a[Controls\
]\x0aStyle=Material\
\x0a\x0a[Material]\x0aThe\
me=Light\x0aAccent=\
Blue\x0a#Primary=Bl\
ueGray\x0a#Foregrou\
nd=Brown\x0a#Backgr\
ound=Grey\x0aVarian\
t=Dense\x0a\
"

qt_resource_name = b"\
\x00\x15\
\x08\x1e\x16f\
\x00q\
\x00t\x00q\x00u\x00i\x00c\x00k\x00c\x00o\x00n\x00t\x00r\x00o\x00l\x00s\x002\x00.\
\x00c\x00o\x00n\x00f\
"

qt_resource_struct = b"\
\x00\x00\x00\x00\x00\x02\x00\x00\x00\x01\x00\x00\x00\x01\
\x00\x00\x00\x00\x00\x00\x00\x00\
\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\
\x00\x00\x01{\xcb\x097s\
"

def qInitResources():
    QtCore.qRegisterResourceData(0x03, qt_resource_struct, qt_resource_name, qt_resource_data)

def qCleanupResources():
    QtCore.qUnregisterResourceData(0x03, qt_resource_struct, qt_resource_name, qt_resource_data)

qInitResources()
