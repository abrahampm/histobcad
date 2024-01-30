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
    // minimumZoomLevel: 5
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
    //     topLeft: tile2coordinate(0,0, 12)
    //     bottomRight: tile2coordinate(1,1, 12)
    // }
    // MapRectangle {
    //     id: map_rect_region3
    //     border.width: 2
    //     border.color: 'green'
    //     topLeft: tile2coordinate(0,0, 11)
    //     bottomRight: tile2coordinate(1,1, 11)
    // }
    function setVisibleRegion() {
        console.log("Min zoom level", viewer.dzi_min_zoom_level);
        console.log("Max zoom level", viewer.dzi_max_zoom_level);
        var viewport_width = deepzoom_map.width;
        var viewport_height = deepzoom_map.height;
        console.log(viewport_width);
        console.log(viewport_height);
        var fit_zoom_level = viewer.get_dzi_zoom_level_fit_to_viewport(viewport_width, viewport_height);
        var map_width = viewer.get_dzi_width_at_zoom_level(fit_zoom_level);
        var map_height = viewer.get_dzi_height_at_zoom_level(fit_zoom_level);
        console.log("Fit zoom level", fit_zoom_level);
        console.log("Map width", map_width);
        console.log("Map height", map_height);
        deepzoom_map.minimumZoomLevel = fit_zoom_level - 1;
        var topLeftCoordinate = tile2coordinate(0, 0, fit_zoom_level);
        var bottomRightCoordinate = tile2coordinate(map_width, map_height, fit_zoom_level);
        console.log("Visible region before: ", deepzoom_map.visibleRegion.boundingGeoRectangle())
        deepzoom_map.visibleRegion = QtPositioning.rectangle(topLeftCoordinate, bottomRightCoordinate);
        console.log("Visible region after: ", deepzoom_map.visibleRegion.boundingGeoRectangle())
        map_rect_region.topLeft = topLeftCoordinate;
        map_rect_region.bottomRight = bottomRightCoordinate;
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
}
