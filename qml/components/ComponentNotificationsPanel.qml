import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Column {
    anchors.horizontalCenter: parent.horizontalCenter
    width: scrollViewRightPanel.width - 2*scrollViewRightPanel.padding
    spacing: 5
    Text {
        text: qsTr("Notifications")
        font.bold: true
        font.pointSize: 12
    }
}
