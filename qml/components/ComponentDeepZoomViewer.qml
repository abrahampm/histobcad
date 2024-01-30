import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.11

Rectangle {
    id: deepzoom_viewer
    color: "white"

    Rectangle {
        anchors.fill: parent
        // z: dragArea.z+1
        z: 2001
        visible: (viewer.selected_file.toString() === "")
        Label {
            text: qsTr("DeepZoom viewer")
            color: Material.color(Material.Grey, Material.Shade400)
            anchors.centerIn: parent
        }
    }

    Loader{
        id: deepzoom_map_loader
        anchors.fill: parent

        z: 2002
        onStatusChanged: if (deepzoom_map_loader.status === Loader.Ready) console.log('New map loaded')
    }

    Connections {
        target: viewer
        function onReload() {
            console.log("Reloading map");
            deepzoom_map_loader.setSource("ComponentDeepZoomMap.qml");
        }
    }

}
