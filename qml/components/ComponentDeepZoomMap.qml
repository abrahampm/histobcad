import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtLocation
import QtPositioning


Map {
    id: deepZoomMap
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
        fitToViewPort();
        setScaleBar();

    }
    onCenterChanged: {
        setPreviewRegion();
    }
    onZoomLevelChanged: {
        setScaleBar();
    }

    MapRectangle {
        id: deepZoomMapOriginRegion
        border.width: 1
        border.color: Material.color(Material.Grey, Material.Shade300)
        color: 'transparent'
    }

    Rectangle {
        id: deepZoomMapPreview
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
        opacity: 0
        Image {
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            source: viewer.selected_file_thumbnail
            width: parent.width - 4
            height: parent.height - 4
            sourceSize.width: 256
            sourceSize.height: 256
            anchors.centerIn: parent
            z: parent.z - 1
            BusyIndicator {
                running: parent.status === Image.Loading
                anchors.centerIn: parent
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var previewX = mouseX - deepZoomMapPreviewNavigator.width / 2;
                var previewY = mouseY - deepZoomMapPreviewNavigator.height / 2;
                if (previewX < 0) {
                    previewX = 0
                }
                if (previewX > deepZoomMapPreview.width) {
                    previewX = deepZoomMapPreview.width;
                }
                if (previewY < 0) {
                    previewY = 0
                }
                if (previewY > deepZoomMapPreview.height) {
                    previewY = deepZoomMapPreview.height;
                }

                deepZoomMapPreviewNavigator.x = previewX;
                deepZoomMapPreviewNavigator.y = previewY;
                setVisibleRegion();
            }
        }
        Rectangle {
            id: deepZoomMapPreviewNavigator
            x: parent.width * 0.5
            y: parent.height * 0.5
            z: parent.z + 3
            width: parent.width * 0.5
            height: parent.height * 0.5
            color: "transparent"
            border.color: "red"
            border.width: 2
            MouseArea {
                id: deepZoomMapPreviewNavigatorArea
                anchors.fill: parent
                drag {
                    target: deepZoomMapPreviewNavigator
                    axis: Drag.XAndYAxis
                    minimumX: 0
                    minimumY: 0
                    maximumX: deepZoomMapPreview.width - deepZoomMapPreviewNavigator.width
                    maximumY: deepZoomMapPreview.height - deepZoomMapPreviewNavigator.height
                }
                cursorShape: Qt.PointingHandCursor

                onPositionChanged: {
                    if (drag.active) {
                        setVisibleRegion();
                    }
                }
            }
        }
        PropertyAnimation {
            id: previewFadeInAnimation
            target: deepZoomMapPreview
            property: "opacity"
            from: 0
            to: 1
            duration: 200 // 200 millisecond for fade in

            running: false

            onStopped: {
                // Pause for 3 seconds before starting fade out
                previewFadeOutTimer.start();
            }
        }
        PropertyAnimation {
            id: previewFadeOutAnimation
            target: deepZoomMapPreview
            property: "opacity"
            to: 0
            duration: 200 // 200 millisecond for fade out
            running: false
        }
        Timer {
            id: previewFadeOutTimer
            interval: 3000 // 3 seconds
            onTriggered: {
                previewFadeOutAnimation.start();
            }
        }
    }

    Rectangle {
        id: deepZoomMapScaleBar
        width: 275
        height: 20
        opacity: 0.8
        color: "white"
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 10
        anchors.bottomMargin: 10
        z: parent.z + 2
        // border.color: "red"
        // border.width: 2
        Text {
            id: deepZoomMapScaleBarText
            text: ""
            anchors.centerIn: parent
        }
        Rectangle {
            height: 2
            width: parent.width
            anchors.bottom: parent.bottom
            z: parent.z + 1
            border.width: 1
            border.color: Material.color(Material.Grey, Material.Shade700)
            // border.color: "red"
            // border.width: 2
        }
    }

    function fitToViewPort() {
        console.log("Min zoom level", viewer.dzi_min_zoom_level);
        console.log("Max zoom level", viewer.dzi_max_zoom_level);
        var maxZoomLevel = viewer.dzi_max_zoom_level;
        var maxWidth = viewer.dzi_max_width / viewer.dzi_tile_size;
        var maxHeight = viewer.dzi_max_height / viewer.dzi_tile_size;
        var origin = (1 << maxZoomLevel) / 2;
        var topLeftCoordinate = tile2coordinate(origin, origin, maxZoomLevel);
        var bottomRightCoordinate = tile2coordinate(origin + maxWidth, origin + maxHeight, maxZoomLevel);
        deepZoomMapOriginRegion.topLeft = topLeftCoordinate;
        deepZoomMapOriginRegion.bottomRight = bottomRightCoordinate;
        // console.log("Visible region before: ", deepZoomMap.visibleRegion.boundingGeoRectangle())
        deepZoomMap.visibleRegion = QtPositioning.rectangle(topLeftCoordinate, bottomRightCoordinate);
        // console.log("Visible region after: ", deepZoomMap.visibleRegion.boundingGeoRectangle())
    }

    function setVisibleRegion() {
        previewFadeOutTimer.restart()
        var origin = deepZoomMap.fromCoordinate(deepZoomMapOriginRegion.topLeft, false);
        var previewCenterX = deepZoomMapPreviewNavigator.x + deepZoomMapPreviewNavigator.width / 2;
        var previewCenterY = deepZoomMapPreviewNavigator.y + deepZoomMapPreviewNavigator.height / 2;
        var currentCenterX = deepZoomMapOriginRegion.width * (previewCenterX / deepZoomMapPreview.width);
        var currentCenterY = deepZoomMapOriginRegion.height * (previewCenterY / deepZoomMapPreview.height);
        var center = Qt.point(origin.x + currentCenterX, origin.y + currentCenterY);

        deepZoomMap.center = deepZoomMap.toCoordinate(center, false);
    }

    function setScaleBar() {
        var topLeft = deepZoomMap.fromCoordinate(deepZoomMapOriginRegion.topLeft, false);
        var bottomRight = deepZoomMap.fromCoordinate(deepZoomMapOriginRegion.bottomRight, false);
        var imageWidth = bottomRight.x - topLeft.x;
        // console.log(topLeft, bottomRight);
        var viewportWidth = deepZoomMap.width;
        var zoom = imageWidth / viewportWidth;
        if (zoom < 1) {
            zoom = 1;
            viewportWidth = imageWidth;
        }
        var ratio = viewportWidth / viewer.dzi_max_width * zoom;
        var ppm = viewer.dzi_pixels_per_meter * ratio;
        var value = deepZoomMapScaleBar.width / ppm;
        // console.log(viewer.dzi_max_width, viewportWidth);
        // console.log(viewer.dzi_pixels_per_meter, ppm, zoom, value);
        var scaleBarText = "";
        if (value < 0.000001) {
            scaleBarText = (value * 1e9).toFixed(2) + " nm";
        } else if (value < 0.001) {
            scaleBarText = (value * 1e6).toFixed(2) + " μm";
        } else if (value < 1) {
            scaleBarText = (value * 1e3).toFixed(2) + " mm";
        } else {
            scaleBarText = value.toString();
        }
        deepZoomMapScaleBarText.text = scaleBarText;
    }

    function setPreviewRegion() {
        // Function to adjust the deepZoomMapPreviewNavigator of deepZoomMapPreview while navigating
        if (deepZoomMapPreviewNavigatorArea.drag.active) {
            return;
        }
        if (deepZoomMapPreview.opacity === 0) {
            previewFadeInAnimation.start()
        } else {
            previewFadeOutTimer.restart();
        }
        var currentVisibleRegionRect = deepZoomMap.visibleRegion.boundingGeoRectangle();
        var currentTopLeft = deepZoomMap.fromCoordinate(currentVisibleRegionRect.topLeft);
        var currentBottomRight = deepZoomMap.fromCoordinate(currentVisibleRegionRect.bottomRight);
        var currentWidth = currentBottomRight.x - currentTopLeft.x;
        var currentHeight = currentBottomRight.y - currentTopLeft.y;
        var originTopLeft = deepZoomMap.fromCoordinate(deepZoomMapOriginRegion.topLeft, false);
        var originBottomRight = deepZoomMap.fromCoordinate(deepZoomMapOriginRegion.bottomRight, false);
        var originWidth = originBottomRight.x - originTopLeft.x;
        var originHeight = originBottomRight.y - originTopLeft.y;

        // console.log("Current visible region top left:", currentTopLeft);
        // console.log("Current visible region bottom right:", currentBottomRight);
        // console.log("Origin visible region top left:", originTopLeft);
        // console.log("Origin visible region bottom right:", originBottomRight);

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

        // console.log("xScale factor", xScaleFactor);
        // console.log("yScale factor", yScaleFactor);
        // console.log("xPost factor", xPosFactor);
        // console.log("yPost factor", yPosFactor);

        var widthPreview = deepZoomMapPreview.width * xScaleFactor;
        var heightPreview = deepZoomMapPreview.height * yScaleFactor;
        var xOffsetPreview = deepZoomMapPreview.width * xPosFactor;
        var yOffsetPreview = deepZoomMapPreview.height * yPosFactor;

        if (widthPreview + xOffsetPreview > deepZoomMapPreview.width) {
            xOffsetPreview = deepZoomMapPreview.width - widthPreview;
        }
        if (heightPreview + yOffsetPreview > deepZoomMapPreview.height) {
            yOffsetPreview = deepZoomMapPreview.height - heightPreview;
        }

        deepZoomMapPreviewNavigator.width = widthPreview;
        deepZoomMapPreviewNavigator.height =heightPreview;
        deepZoomMapPreviewNavigator.x = xOffsetPreview;
        deepZoomMapPreviewNavigator.y = yOffsetPreview;
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
        anchors.rightMargin: 10
        anchors.bottomMargin: 5
        onClicked: {
            fitToViewPort();
        }
    }
}
