import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.11
import QtLocation 5.15
import QtPositioning 5.15

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

    // BusyIndicator {
    //     running: deepzoom_map.status === Map.Loading
    //     anchors.centerIn: parent
    //     // z: dragArea.z + 4
    //     z: 2004
    // }

    Plugin {
        id: deepzoom_plugin
        name: "osm"


        PluginParameter {
            name: "osm.mapping.custom.host"
            value: viewer.selected_file.toString()
        }

        PluginParameter
        {
            name: "osm.mapping.custom.format"
            value: "jpg"
        }

        PluginParameter {
            name: "osm.mapping.providersrepository.disabled"
            value: true
        }
    }

    Map {
        id: deepzoom_map
        anchors.fill: parent
        plugin: deepzoom_plugin
        zoomLevel: 0
        minimumZoomLevel: 0
        maximumZoomLevel: 10
        center: QtPositioning.coordinate(0, 0)
        // visibleRegion:
        // fieldOfView:
        activeMapType: supportedMapTypes[supportedMapTypes.length - 1]
    }


}
