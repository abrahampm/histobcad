import QtQuick
import QtQuick.Controls

Dialog {
    id: dialogAboutQt

    readonly property string qtVersionString: "6"

    contentWidth: Math.max(imageQtLogo.width + labelAboutQt.implicitWidth > 400 ? 400 : imageQtLogo.width + labelAboutQt.implicitWidth)
    contentHeight: flickable.contentHeight

    modal: true
    title: qsTr("About") + " Qt"
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
                id: imageQtLogo
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: "../../resources/icons/qt/qt_logo_green.svg"
                sourceSize: Qt.size(148, 148)
            }

            Label {
                id: labelAboutQt
                width: parent.width
                text: "<b>" + qsTr("This program uses Qt %1").arg(qtVersionString) + "</b><br>"
                    + qsTr("<p>Qt is a <i>C++ toolkit for cross-platform application " +
                           "development</i>.</p>" +
                           "<p>Qt provides single-source portability across all major desktop and mobile " +
                           "operating systems. It is also available for embedded Linux and other " +
                           "embedded operating systems.</p><br>" +
                           "<p>Qt offers both <i>commercial</i> and <i>opensource</i> licences. Please see <a href=\"http://%2/\">%2</a> " +
                           "for an overview of Qt licensing.</p><br>" +
                           "<p><i>Copyright © %1 The Qt Company Ltd</i> and other " +
                           "contributors. See <a href=\"http://%3/\">%3</a> for more information.</p>").arg("2020").arg("qt.io/licensing").arg("qt.io")
                wrapMode: Label.Wrap
                onHoveredLinkChanged: {
                    mouseAreaLinkHovered.cursorShape = hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
                onLinkActivated: { Qt.openUrlExternally(link) }

                MouseArea {
                    id: mouseAreaLinkHovered
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                }
            } // Label
        } // Column

        ScrollIndicator.vertical: ScrollIndicator {
            parent: dialogAboutQt.contentItem
            anchors.top: flickable.top
            anchors.bottom: flickable.bottom
            anchors.right: parent.right
            anchors.rightMargin: -dialogAboutQt.rightPadding + 1
        }
    } // Flickable
}
