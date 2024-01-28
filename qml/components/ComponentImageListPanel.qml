import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.11

Rectangle {
    id: imageListPanel
    color: Material.color(Material.Grey, Material.Shade50)
    visible: viewer.selected_file.toString() !== ""
    ScrollView {
        anchors.fill: parent
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff // disable the horizontal scroll bar

        ListView {
            id: listView
            model: viewer.selected_file_siblings
            width: parent.width
            height: parent.height
            anchors.fill: parent
            spacing: 10

            // The delegate presents the information stored in the model
            delegate: Rectangle {
                border.color: Material.color(Material.Grey, (display === viewer.selected_file) ? Material.Shade700 : Material.Shade300)
                border.width: (display === viewer.selected_file) ? 3 : 1
                width: listView.width
                height: listView.width * 0.60

                Image {
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    source: display
                    width: parent.width - 20
                    height: parent.width * 0.56
                    sourceSize.width: 512
                    sourceSize.height: 512
                    anchors.centerIn: parent

                    BusyIndicator {
                        running: parent.status === Image.Loading
                        anchors.centerIn: parent
                    }
                }
//                        Label {
//                            text: display
//                            anchors.centerIn: parent.Center
//                        }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        viewer.mask_file = ''
                        viewer.selected_file = display

                    }
                }
            }
        }
    }
}