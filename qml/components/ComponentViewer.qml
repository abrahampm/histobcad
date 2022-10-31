import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.11

Rectangle {
    id: visor
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
                id: viewerMaskImage
                z:dragArea.z + 2
                source: viewer.mask_image_enabled ? "image://viewer_image_provider/mask_image" : ""
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
        visible: viewer.mask_image_enabled

        RowLayout {
            Slider {
                id: maskOpacitySlider
                from: 0.0
                to: 1.0
                value: 1
                stepSize: 0.1
                onValueChanged: {
                    viewerMaskImage.opacity = maskOpacitySlider.value
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
        visible: analysis_manager.running
        value: analysis_manager.progress
        Behavior on value { NumberAnimation {} }
    }
}
