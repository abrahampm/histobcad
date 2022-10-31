import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.11

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
