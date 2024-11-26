import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

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
