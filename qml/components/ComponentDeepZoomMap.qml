import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.11
import QtLocation 5.15
import QtPositioning 5.15


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
    }
    onCenterChanged: {
        setPreviewRegion();
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
                        previewFadeOutTimer.restart()
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
    function fitToViewPort() {
        console.log("Min zoom level", viewer.dzi_min_zoom_level);
        console.log("Max zoom level", viewer.dzi_max_zoom_level);
        var maxZoomLevel = viewer.dzi_max_zoom_level;
        var maxWidth = viewer.dzi_max_width / 256;
        var maxHeight = viewer.dzi_max_height / 256;
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
        var origin = deepZoomMap.fromCoordinate(deepZoomMapOriginRegion.topLeft, false);
        var previewCenterX = deepZoomMapPreviewNavigator.x + deepZoomMapPreviewNavigator.width / 2;
        var previewCenterY = deepZoomMapPreviewNavigator.y + deepZoomMapPreviewNavigator.height / 2;
        var currentCenterX = deepZoomMapOriginRegion.width * (previewCenterX / deepZoomMapPreview.width);
        var currentCenterY = deepZoomMapOriginRegion.height * (previewCenterY / deepZoomMapPreview.height);

        var center = Qt.point(origin.x + currentCenterX, origin.y + currentCenterY);

        deepZoomMap.center = deepZoomMap.toCoordinate(center, false);
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
