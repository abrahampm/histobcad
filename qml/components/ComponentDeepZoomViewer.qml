import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Rectangle {
    id: deepzoom_viewer
    color: "white"

    Rectangle {
        anchors.fill: parent
        z: parent.z + 1
        visible: (viewer.selected_file.toString() === "")
        Label {
            text: qsTr("Drag and drop an image here to open it")
            color: Material.color(Material.Grey, Material.Shade400)
            anchors.centerIn: parent
        }
    }

    Loader{
        id: deepzoom_map_loader
        anchors.fill: parent

        z: parent.z + 2
        onStatusChanged: if (deepzoom_map_loader.status === Loader.Ready) console.log('New map loaded')
    }

    Connections {
        target: viewer
        function onReload() {
            console.log("Reloading map");
            deepzoom_map_loader.setSource("ComponentDeepZoomMap.qml");
        }
    }

    DropArea {
        id: viewerDropArea
        anchors.fill: parent
        anchors.margins: 25
        z: parent.z + 3

        onEntered: {
            // Provide visual feedback when dragging over the drop area
            console.log("Entered");
            drag.accept(Qt.LinkAction);
            viewerDropAreaFadeInAnimation.start()
        }

        onExited: {
            // Reset visual feedback when not dragging over the drop area
            console.log("Exited");
            viewerDropAreaFadeOutAnimation.start()
        }

        onDropped: {
            // Load the dropped image
            console.log("Dropped");
            console.log(drop.urls)
            if (drop.urls.length > 0) {
                viewer.selected_file = drop.urls[0];
            }
            viewerDropAreaFadeOutAnimation.start()
        }

        Rectangle {
            id: viewerDropAreaRect
            anchors.fill: parent
            color: "white"
            border.color: Material.color(Material.Grey, Material.Shade300)
            border.width: 2
            opacity: 0

            Text {
                anchors.centerIn: parent
                text: "Drag and Drop Image Here"
                font.pixelSize: 26
            }
            PropertyAnimation {
                id: viewerDropAreaFadeInAnimation
                target: viewerDropAreaRect
                property: "opacity"
                from: 0
                to: 1
                duration: 200 // 200 millisecond for fade in

                running: false
            }
            PropertyAnimation {
                id: viewerDropAreaFadeOutAnimation
                target: viewerDropAreaRect
                property: "opacity"
                to: 0
                duration: 200 // 200 millisecond for fade out
                running: false
            }
        }
    }

}
