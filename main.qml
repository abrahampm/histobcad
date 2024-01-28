import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.4
import QtQuick.Layouts 1.11
import QtQuick.Dialogs 1.0
import "qml/dialogs" as Dialogs
import "qml/components" as Components

ApplicationWindow {
    id: applicationWindow
    title: qsTr("HistoBCAD")
    visible: true
    width: 1024
    height: 576

    menuBar: MenuBar {
        id: mainMenuBar

        Menu {
            title: qsTr("File")
            Action {
                text: qsTr("Open")
                onTriggered: openFileDialog.open()
            }
            Action { text: qsTr("Save") }
            Action { text: qsTr("Save as...")}
            MenuSeparator {}
            Action { text: qsTr("Exit")}
        }
        Menu {
            title: qsTr("Analysis")
            enabled: viewer.selected_file
            Menu {
                title: qsTr("IDC Detection")
                Action {
                    text: qsTr("RF Model")
                    onTriggered: {
                        analysis_manager.start_analysis(viewer.selected_file, 'idc_detection_model1')
                    }
                }                
                Action {
                    text: qsTr("RF Model1")
                    onTriggered: {
                        analysis_manager.start_analysis(viewer.selected_file, 'idc_detection_model3')
                    }
                }
                Action {
                    text: qsTr("SVM Model")
                    onTriggered: {
                        analysis_manager.start_analysis(viewer.selected_file, 'idc_detection_model2')
                    }
                }
            }
            Action {
                text: qsTr("Manual delineation")
            }
            Action {
                text: qsTr("Stop analysis")
                enabled: analysis_manager.running
            }
        }
        Menu {
            title: qsTr("Diagnostic")
            enabled: viewer.selected_file

            Action {
                text: qsTr("Create diagnostic")
            }
            Action {
                text: qsTr("Edit diagnostic")
            }
            Action {
                text: qsTr("Share diagnostic")
            }
        }
        Menu {
            title: qsTr("Configuration")
            Menu {
                title: qsTr("Language")
                Action {
                    text: qsTr("English")
                    onTriggered: {
                        translator.set_language("en")
                    }
                }
                Action {
                    text: qsTr("Spanish")
                    onTriggered: {
                        translator.set_language("es")
                    }
                }
                Action {
                    text: qsTr("French")
                    onTriggered: {
                        translator.set_language("fr")
                    }
                }
            }
            Action {
                text: qsTr("Server settings")
            }
        }
        Menu {
            title: qsTr("Help")
            Action { text: qsTr("User manual")}
            Action {
                text: qsTr("About HistoBCAD")
                onTriggered: aboutDialog.open()
            }
            Action {
                text: qsTr("About License")
                onTriggered: aboutLicenseDialog.open()
            }
            Action {
                text: qsTr("About Qt")
                onTriggered: aboutQtDialog.open()
            }
        }

        background: Rectangle {
            implicitWidth: 40
            implicitHeight: 40
            color: "#ffffff"

            Rectangle {
                color: "#eeeeee"
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
            }
        }
    }

    Row {
        id:rightToolbar
        anchors.right: parent.right
        anchors.bottom: parent.top
        height: mainMenuBar.height
        z: 100

        ToolButton {
            height: parent.height
            font.capitalization: Font.MixedCase
            icon.source: "resources/icons/notifications.svg"
            icon.color: "transparent"
            icon.height: parent.height * 0.5
            icon.width: parent.height * 0.5
            visible: auth_manager.user.authenticated === true
            onClicked: {
                rightPanelContentLoader.source = "qml/components/ComponentNotificationsPanel.qml"
                rightPanel.visible = true
            }
        }
        ToolButton {
            text: auth_manager.user.authenticated === true ? auth_manager.user.email : qsTr("Sign in")
            height: parent.height
            font.capitalization: Font.MixedCase
            icon.source: "resources/icons/user.svg"
            icon.color: "transparent"
            icon.height: parent.height * 0.5
            icon.width: parent.height * 0.5
            onClicked: {
                if (auth_manager.user.authenticated === true) {
                    rightPanelContentLoader.source = "qml/components/ComponentUserProfilePanel.qml"
                    rightPanel.visible = true
                } else {
                    loginDialog.open()
                }
            }
        }
    }




    SplitView {
        id: splitView
        anchors.fill: parent
        orientation: Qt.Horizontal

        Components.ComponentImageListPanel {
            SplitView.minimumWidth: parent.width*0.1
            SplitView.preferredWidth: parent.width * 0.15
            SplitView.maximumWidth: parent.width * 0.2
        }

        Components.ComponentDeepZoomViewer {
            SplitView.minimumWidth: parent.width*0.5
            SplitView.fillWidth: true
        }

        Rectangle {
            id: rightPanel
            SplitView.preferredWidth: parent.width * 0.3
            SplitView.minimumWidth: parent.width * 0.2
            SplitView.maximumWidth: parent.width * 0.4
            color: "white"
            visible: false
//            visible: true

            ScrollView {
                id: scrollViewRightPanel
                anchors.fill: parent
                padding: 10
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                Loader {
                    id: rightPanelContentLoader
                    source: ""
//                    source: "qml/components/ComponentUserProfilePanel.qml"
                }

            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        height: labelStatus.height
        width: labelStatus.width
        border.color: Material.color(Material.Grey, Material.Shade200)
        color: Material.color(Material.Grey, Material.Shade100)
        visible: labelStatus.text.length > 0
        z: 30
        Label {
            id:labelStatus
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            padding: 5
            elide: Text.ElideRight
            text: analysis_manager.status
        }
    }

    Dialogs.DialogOpenFile {
        id: openFileDialog
    }

    Dialogs.DialogLogin {
        id: loginDialog
        anchors.centerIn: Overlay.overlay
        width: applicationWindow.width < 410 ? applicationWindow.width : 410
        height: applicationWindow.height < 444 ? applicationWindow.height : 444
        modal: true
        focus: visible
    }

    Dialogs.DialogRegister {
        id: registerDialog
        anchors.centerIn: Overlay.overlay
        width: applicationWindow.width < 410 ? applicationWindow.width : 410
        height: applicationWindow.height < 524 ? applicationWindow.height : 524
        modal: true
        focus: visible
    }

    Dialogs.DialogAbout {
        id: aboutDialog
        anchors.centerIn: Overlay.overlay
        width: implicitWidth > applicationWindow.width - 40 ? applicationWindow.width - 40 : implicitWidth
        height: implicitHeight > applicationWindow.height - 40 ? applicationWindow.height - 40 : implicitHeight
        modal: true
        focus: visible
    }

    Dialogs.DialogAboutLicense {
        id: aboutLicenseDialog
        anchors.centerIn: Overlay.overlay
        width: implicitWidth > applicationWindow.width - 40 ? applicationWindow.width - 40 : implicitWidth
        height: implicitHeight > applicationWindow.height - 40 ? applicationWindow.height - 40 : implicitHeight
        modal: true
        focus: visible
    }

    Dialogs.DialogAboutQt {
        id: aboutQtDialog
        anchors.centerIn: Overlay.overlay
        width: implicitWidth > applicationWindow.width - 40 ? applicationWindow.width - 40 : implicitWidth
        height: implicitHeight > applicationWindow.height - 40 ? applicationWindow.height - 40 : implicitHeight
        modal: true
        focus: visible
    }
}



