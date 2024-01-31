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
    onCenterChanged: {
        var currentVisibleRegionRect = deepzoom_map.visibleRegion.boundingGeoRectangle();
        var currentTopLeft = deepzoom_map.fromCoordinate(currentVisibleRegionRect.topLeft);
        var currentBottomRight = deepzoom_map.fromCoordinate(currentVisibleRegionRect.bottomRight);
        var currentWidth = currentBottomRight.x - currentTopLeft.x;
        var currentHeight = currentBottomRight.y - currentTopLeft.y;
        var originTopLeft = deepzoom_map.fromCoordinate(deepzoom_map_rect_region.topLeft, false);
        var originBottomRight = deepzoom_map.fromCoordinate(deepzoom_map_rect_region.bottomRight, false);
        var originWidth = originBottomRight.x - originTopLeft.x;
        var originHeight = originBottomRight.y - originTopLeft.y;

        console.log("Current visible region top left:", currentTopLeft);
        console.log("Current visible region bottom right:", currentBottomRight);
        console.log("Origin visible region top left:", originTopLeft);
        console.log("Origin visible region bottom right:", originBottomRight);

        var xScaleFactor = currentWidth / originWidth;
        var yScaleFactor = currentHeight / originHeight;
        var xPosFactor = (currentTopLeft.x - originTopLeft.x) / originWidth;
        var yPosFactor = (currentTopLeft.y - originTopLeft.y) / originHeight;
        if (xScaleFactor > 1) {
            xScaleFactor = 1;
        }
        if (yScaleFactor > 1) {
            yScaleFactor = 1;
        }
        if (xPosFactor > 1) {
            xPosFactor = 1;
        }
        if (xPosFactor < 0) {
            xPosFactor = 0;
        }
        if (yPosFactor > 1) {
            yPosFactor = 1;
        }
        if (yPosFactor < 0) {
            yPosFactor = 0;
        }

        console.log("xScale factor", xScaleFactor);
        console.log("yScale factor", yScaleFactor);
        console.log("xPost factor", xPosFactor);
        console.log("yPost factor", yPosFactor);

        var widthPreview = deepzoom_map_preview.width * xScaleFactor;
        var heightPreview = deepzoom_map_preview.height * yScaleFactor;
        var xOffsetPreview = deepzoom_map_preview.width * xPosFactor;
        var yOffsetPreview = deepzoom_map_preview.height * yPosFactor;

        if (widthPreview + xOffsetPreview > deepzoom_map_preview.width) {
            xOffsetPreview = deepzoom_map_preview.width - widthPreview;
        }
        if (heightPreview + yOffsetPreview > deepzoom_map_preview.height) {
            yOffsetPreview = deepzoom_map_preview.height - heightPreview;
        }

        deepzoom_map_preview_focus_rect.width = widthPreview;
        deepzoom_map_preview_focus_rect.height =heightPreview;
        deepzoom_map_preview_focus_rect.x = xOffsetPreview;
        deepzoom_map_preview_focus_rect.y = yOffsetPreview;

    }

    Rectangle {
        id: deepzoom_map_preview
        width: height * viewer.dzi_max_width / viewer.dzi_max_height
        height: parent.height * 0.2
        color: "white"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 10
        anchors.topMargin: 10
        border.width: 2
        border.color: Material.color(Material.Grey, Material.Shade700)
        z: parent.z + 2
        Image {
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            source: viewer.selected_file_thumbnail
            width: parent.width - 2
            height: parent.height - 2
            sourceSize.width: 256
            sourceSize.height: 256
            anchors.centerIn: parent
            z: parent.z - 1
            BusyIndicator {
                running: parent.status === Image.Loading
                anchors.centerIn: parent
            }
        }
        Rectangle {
            id: deepzoom_map_preview_focus_rect
            x: parent.width * 0.5
            y: parent.height * 0.5
            z: parent.z + 3
            width: parent.width * 0.5
            height: parent.height * 0.5
            color: "transparent"
            border.color: "red"
            border.width: 2
        }
    }
    MapRectangle {
        id: deepzoom_map_rect_region
        border.width: 1
        border.color: Material.color(Material.Grey, Material.Shade300)
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
        deepzoom_map_rect_region.topLeft = topLeftCoordinate;
        deepzoom_map_rect_region.bottomRight = bottomRightCoordinate;
        console.log("Visible region before: ", deepzoom_map.visibleRegion.boundingGeoRectangle())
        deepzoom_map.visibleRegion = QtPositioning.rectangle(topLeftCoordinate, bottomRightCoordinate);
        console.log("Visible region after: ", deepzoom_map.visibleRegion.boundingGeoRectangle())
    }

    function tile2coordinate(xtile, ytile, zoom) {
        var n = 1 << zoom;
        var lon_deg = xtile / n * 360.0 - 180.0;
        var lat_rad = Math.atan(Math.sinh(Math.PI * (1 - 2 * ytile / n)));
        var lat_deg = lat_rad * (180.0 / Math.PI);
        return QtPositioning.coordinate(lat_deg, lon_deg);
    }

    Button {
        text: qsTr("Fit to screen")
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        onClicked: {
            setVisibleRegion();
        }
    }
}
