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
    // zoomLevel: viewer.dzi_min_zoom_level
    minimumZoomLevel: viewer.dzi_min_zoom_level
    maximumZoomLevel: viewer.dzi_max_zoom_level
    //center: QtPositioning.coordinate(90, 180)
    activeMapType: supportedMapTypes[supportedMapTypes.length - 1]
    onMapReadyChanged: {
        setVisibleRegion();
    }
    // onCenterChanged: {
    //     console.log("Current visible area:", deepzoom_map.visibleArea);
    //     console.log("Current visible region bounding box:", deepzoom_map.visibleRegion.boundingGeoRectangle());
    //     console.log("Current center:", deepzoom_map.center);
    // }
    MapRectangle {
        id: map_rect_region
        border.width: 1
        border.color: 'red'
        color: 'transparent'
    }
    // MapRectangle {
    //     id: map_rect_region2
    //     border.width: 2
    //     border.color: 'red'
    //     topLeft: tile2coordinate(0,0, 11)
    //     bottomRight: tile2coordinate(1,1, 11)
    // }
    // MapRectangle {
    //     id: map_rect_region3
    //     border.width: 2
    //     border.color: 'green'
    //     topLeft: tile2coordinate(0,0, 11)
    //     bottomRight: tile2coordinate(5,5, 11)
    // }
    function setVisibleRegion() {
        console.log("Min zoom level", viewer.dzi_min_zoom_level);
        console.log("Max zoom level", viewer.dzi_max_zoom_level);
        var max_zoom_level = viewer.dzi_max_zoom_level;
        var max_width = viewer.dzi_max_width / 256;
        var max_height = viewer.dzi_max_height / 256;
        var origin = (1 << max_zoom_level) / 2;
        var topLeftCoordinate = tile2coordinate(origin, origin, max_zoom_level);
        var bottomRightCoordinate = tile2coordinate(origin + max_width, origin + max_height, max_zoom_level);
        map_rect_region.topLeft = topLeftCoordinate;
        map_rect_region.bottomRight = bottomRightCoordinate;
        console.log("Visible region before: ", deepzoom_map.visibleRegion.boundingGeoRectangle())
        var r = QtPositioning.rectangle(topLeftCoordinate, bottomRightCoordinate)
        console.log("Geo rectangle", r);
        deepzoom_map.visibleRegion = r;
        console.log("Visible region after: ", deepzoom_map.visibleRegion.boundingGeoRectangle())
    }

    function tile2coordinate(xtile, ytile, zoom) {
        var n = 1 << zoom;
        var lon_deg = xtile / n * 360.0 - 180.0;
        var lat_rad = Math.atan(Math.sinh(Math.PI * (1 - 2 * ytile / n)));
        var lat_deg = lat_rad * (180.0 / Math.PI);
        return QtPositioning.coordinate(lat_deg, lon_deg);
    }

    // Rectangle {
    //     anchors.fill: parent
    //     border.color: 'red'
    //     border.width: 3
    //     color: 'transparent'
    // }
    Button {
        text: qsTr("Fit to size")
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        onClicked: {
            setVisibleRegion();
        }
    }
}
