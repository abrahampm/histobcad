import QtQuick
import QtQuick.Controls

Dialog {
    id: about

    signal licenseRequested()

    contentWidth: Math.max(imageAppIcon.width + labelAbout.implicitWidth > 400 ? 400 : imageAppIcon.width + labelAbout.implicitWidth)
    contentHeight: flickable.contentHeight

    title: qsTr("About") + " " + Qt.application.name
    standardButtons: Dialog.Close

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.height
        leftMargin: 2
        rightMargin: 2
        clip: true

        Column {
            id: column
            spacing: 20
            width: parent.width

            Image {
                id: imageAppIcon
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: "qrc:/images/icons/app/appIcon.svg"
                sourceSize: Qt.size(148, 148)

                opacity: 0.0
                rotation: -30

                ParallelAnimation {
                    running: imageAppIcon.visible && imageAppIcon.rotation < 0

                    RotationAnimation {
                        target: imageAppIcon
                        property: "rotation"
                        duration: 2000
                        alwaysRunToEnd: true
                        to: 0
                        easing.type: Easing.OutQuint
                    }
                    NumberAnimation {
                        target: imageAppIcon
                        property: "opacity"
                        duration: 2000
                        alwaysRunToEnd: true
                        to: 1.0
                        easing.type: Easing.OutQuint
                    }
                }
            } // Image (app's icon)

            Label {
                id: labelAbout
                width: parent.width
                text: "<p><b>" + Qt.application.name + ' v' + Qt.application.version + "</b><br>"
                    + "<i>" + qsTr("Just an example") + "</i><br>"
                    + "Copyright © 2020 " + Qt.application.organization + "</p><br>"

                    + qsTr("<p><b>License terms and disclaimer</b><br>"
                    + "This program is free software; you can redistribute it and/or modify "
                    + "it under the terms of the <a href=\"License\">GNU General Public License</a> as published by "
                    + "the Free Software Foundation; either version 3 of the License, or "
                    + "(at your option) any later version.<br>"
                    + "This program is distributed in the hope that it will be useful, "
                    + "but WITHOUT ANY WARRANTY; without even the implied warranty of "
                    + "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the "
                    + "<a href=\"License\">GNU General Public License</a> for more details.<br>"
                    + "You should have received a copy of the <a href=\"License\">GNU General Public License</a> along "
                    + "with this program; if not, see <a href=\"%1\">%1</a>.</p><br>").arg("http://www.gnu.org/licenses/")

                    + qsTr("<b>Contact information:</b> <a href=\"mailto:%1\">%1</a>").arg("example@mail.com")
                wrapMode: Label.Wrap
                onHoveredLinkChanged: {
                    mouseAreaLinkHovered.cursorShape = hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
                onLinkActivated: {
                    if (link === qsTr("License")) {
                        licenseRequested()
                    } else {
                        Qt.openUrlExternally(link)
                    }
                }

                MouseArea {
                    id: mouseAreaLinkHovered
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                }
            } // Label
        } // Column

        ScrollIndicator.vertical: ScrollIndicator {
            parent: about.contentItem
            anchors.top: flickable.top
            anchors.bottom: flickable.bottom
            anchors.right: parent.right
            anchors.rightMargin: -about.rightPadding + 1
        }
    } // Flickable
}
