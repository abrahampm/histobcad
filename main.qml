import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.4
import QtQuick.Layouts 1.11
import QtQuick.Dialogs 1.0



ApplicationWindow {
    id: applicationWindow
    title: qsTr("HistopathApp")
    visible: true
    width: 1024
    height: 576

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            Action {
                text: qsTr("Open")
                onTriggered: fileDialog.open()
            }
            Action { text: qsTr("Save") }
            Action { text: qsTr("Save as...")}
        }

        Menu {
            title: qsTr("Processing")
            enabled: viewer.selected_file
            Action {
                text: worker_manager.running ? qsTr("Stop processing") : qsTr("Start processing")
                onTriggered: {
                    worker_manager.running ? worker_manager.stop_worker() : worker_manager.start_worker(viewer.selected_file)
                }
            }
        }
        Menu {
            title: qsTr("Help")
            Action { text: qsTr("Open help")}
        }
    }

    SplitView {
        id: splitView
        anchors.fill: parent
        orientation: Qt.Horizontal
        Rectangle {
            id: leftPanel
            SplitView.preferredWidth: (viewer.selected_file.toString() === "") ? 0 : parent.width * 0.2
//            SplitView.preferredWidth: parent.width * 0.2
//            SplitView.minimumWidth: parent.width * 0.15
            SplitView.maximumWidth: parent.width * 0.5

            color: Material.color(Material.Grey, Material.Shade50)

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
                        width: parent.width
                        height: parent.width * 0.60

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

//            Button {
//                text: qsTr("Select WSI")
////                Material.background: Material.Indigo
////                anchors.centerIn: parent

//                onClicked: {
//                    fileDialog.open()
//                }
//            }

//            Button {
//                text: qsTr("Stop worker")
////                Material.background: Material.Indigo
////                anchors.centerIn: parent

//                visible: worker_manager.running
//                onClicked: {
//                    worker_manager.stop_worker()
//                }
//            }

        }
        Rectangle {
            id: visor
            Layout.fillWidth: true
            color: "white"

            Rectangle {
                anchors.fill: parent
                z: dragArea.z+1
                visible: (viewer.selected_file.toString() === "")
                Label {
                    text: qsTr("Drag and drop an image here to open it")
                    color: Material.color(Material.Grey, Material.Shade400)
                    anchors.centerIn: parent
                }
            }

            BusyIndicator {
                running: mapImage.status === Image.Loading
                anchors.centerIn: parent
                z: dragArea.z + 4
            }



            Flickable {
                id: flick
                anchors.fill: parent
                clip: true

                Rectangle {
                    id: rect
                    width: Math.max(mapImage.sourceSize.width, flick.width)
                    height: Math.max(mapImage.sourceSize.height, flick.height)
                    transform: Scale {
                        id: scaler
                        origin.x: pinchArea.m_x2
                        origin.y: pinchArea.m_y2
                        xScale: pinchArea.m_zoom2
                        yScale: pinchArea.m_zoom2
                    }

                    Image
                    {
                        asynchronous: true
                        id: mapImage
                        z: dragArea.z+1
                        source: viewer.selected_file
                        //anchors.centerIn: parent
                        //fillMode: Image.PreserveAspectFit
                        anchors.fill: parent
                    }
                    Image {
                        asynchronous: true
                        id: maskImage
                        z:dragArea.z + 2
                        source: viewer.mask_file
                        anchors.fill: parent
                    }

                    PinchArea {
                        id: pinchArea
                        anchors.fill: parent
                        property real m_x1: 0
                        property real m_y1: 0
                        property real m_y2: 0
                        property real m_x2: 0
                        property real m_zoom1: 0.5
                        property real m_zoom2: 0.5
                        property real m_max: 2
                        property real m_min: 0.2

                        onPinchStarted: {
                            m_x1 = scaler.origin.x
                            m_y1 = scaler.origin.y
                            m_x2 = pinch.startCenter.x
                            m_y2 = pinch.startCenter.y
                            rect.x = rect.x + (pinchArea.m_x1-pinchArea.m_x2)*(1-pinchArea.m_zoom1)
                            rect.y = rect.y + (pinchArea.m_y1-pinchArea.m_y2)*(1-pinchArea.m_zoom1)
                        }
                        onPinchUpdated: {
                            m_zoom1 = scaler.xScale
                            var dz = pinch.scale-pinch.previousScale
                            var newZoom = m_zoom1+dz
                            if (newZoom <= m_max && newZoom >= m_min) {
                                m_zoom2 = newZoom
                            }
                        }
                        MouseArea {
                            id: dragArea
                            hoverEnabled: true
                            anchors.fill: parent
                            drag.target: rect
                            drag.filterChildren: true

                            onWheel: {
                                pinchArea.m_x1 = scaler.origin.x
                                pinchArea.m_y1 = scaler.origin.y
                                pinchArea.m_zoom1 = scaler.xScale
                                pinchArea.m_x2 = mouseX
                                pinchArea.m_y2 = mouseY

                                var newZoom
                                if (wheel.angleDelta.y > 0) {
                                    newZoom = pinchArea.m_zoom1+0.1
                                    if (newZoom <= pinchArea.m_max) {
                                        pinchArea.m_zoom2 = newZoom
                                    } else {
                                        pinchArea.m_zoom2 = pinchArea.m_max
                                    }
                                } else {
                                    newZoom = pinchArea.m_zoom1-0.1
                                    if (newZoom >= pinchArea.m_min) {
                                        pinchArea.m_zoom2 = newZoom
                                    } else {
                                        pinchArea.m_zoom2 = pinchArea.m_min
                                    }
                                }
                                rect.x = rect.x + (pinchArea.m_x1-pinchArea.m_x2)*(1-pinchArea.m_zoom1)
                                rect.y = rect.y + (pinchArea.m_y1-pinchArea.m_y2)*(1-pinchArea.m_zoom1)

                                console.debug(rect.width+" -- "+rect.height+"--"+rect.scale)

                            }
                        }
                    }
                }
            }
            Rectangle {
                anchors.bottom: parent.bottom
//                anchors.left: parent.left
                anchors.right: parent.right
                height: 35
                width: 200
                z: dragArea.z + 6
                color: "transparent"
                visible: !(viewer.mask_file.toString() === "")

                RowLayout {
                    Slider {
                        id: maskOpacitySlider
                        from: 0.0
                        to: 1.0
                        value: 1
                        stepSize: 0.1
                        onValueChanged: {
                            maskImage.opacity = maskOpacitySlider.value
                        }
                    }
                }
            }

//            Image {
//                id:background_image
//                z: 10
//                fillMode: Image.PreserveAspectFit
//                source: "/media/abraham/Datos/University/Tesis/Code/app/assets/background.png"
//                height: parent.height
//                width: parent.width
//            }

            ProgressBar {
                id: progressBar
                width: parent.width
                anchors.bottom: parent.bottom
                from: 0
                to: 100
                visible: worker_manager.running
                value: worker_manager.progress
                Behavior on value { NumberAnimation {} }
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
            text: worker_manager.status
        }
    }


    FileDialog {
        id: fileDialog
        title: qsTr("Select an image")
//        folder: shortcuts.home
        nameFilters: [ qsTr("Image files ") + " (*.jpg *.png *.bmp)" ]
        onAccepted: {
//            mapImage.source = fileDialog.fileUrl
//            background_image.z = -1
            viewer.selected_file = fileDialog.fileUrl
        }
    }
}



