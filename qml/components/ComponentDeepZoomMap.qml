import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.11
import QtLocation 5.15
import QtPositioning 5.15


Map {
    id: deepzoom_map
    anchors.fill: parent
    plugin: Plugin {
        name: "osm"
        PluginParameter {
            id: deepzoom_plugin_map_source
            name: "osm.mapping.custom.host"
            value: viewer.selected_file.toString()
        }
        PluginParameter
        {
            name: "osm.mapping.custom.format"
            value: "png"
        }
        PluginParameter
        {
            name: "osm.mapping.cache.disk.size"
            value: "0"
        }
        PluginParameter {
            name: "osm.mapping.providersrepository.disabled"
            value: true
        }
    }
    zoomLevel: 0
    minimumZoomLevel: 0
    maximumZoomLevel: 7
    center: QtPositioning.coordinate(0, 0)
    // visibleRegion:
    // fieldOfView:
    activeMapType: supportedMapTypes[supportedMapTypes.length - 1]
}

//
// BusyIndicator {
//     anchors.centerIn: parent
//     running: viewer.selected_file.toString() !== ""
//     // z: dragArea.z + 4
//     z: 2004
// }
