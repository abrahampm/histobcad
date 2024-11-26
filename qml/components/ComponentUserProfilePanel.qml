import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

ColumnLayout {
    width: scrollViewRightPanel.width - 2*scrollViewRightPanel.padding

    Image {
        id: userProfileImage
        source: "../../resources/icons/user.svg"
        sourceSize.width: 120
        sourceSize.height: 120
        opacity: 0.4
        Layout.alignment: Qt.AlignHCenter
    }

    Text {
        text: qsTr("Welcome") + ", " + auth_manager.user.firstname
        font.bold: true
        font.pointSize: 14
        Layout.topMargin: 10
        Layout.alignment: Qt.AlignHCenter
    }

    RowLayout {
        spacing: 10
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 20

        Button {
            text: qsTr("Edit My Profile")
            font.capitalization: Font.MixedCase
            Material.background: Material.Blue
            Material.foreground: "white"

        }

        Button {
            text: qsTr("Logout")
            font.capitalization: Font.MixedCase
            Material.background: Material.Grey
            Material.foreground: "white"
        }
    }
}
