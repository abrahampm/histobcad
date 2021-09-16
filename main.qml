import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.4
import QtQuick.Layouts 1.11
import QtQuick.Dialogs 1.0



ApplicationWindow {
    id: applicationWindow
    title: qsTr("HistoBCAD")
    visible: true
    width: 1024
    height: 576

    menuBar: MenuBar {
        id: mainMenuBar

        Menu {
            title: qsTr("File")
            Action {
                text: qsTr("Open")
                onTriggered: fileDialog.open()
            }
            Action { text: qsTr("Save") }
            Action { text: qsTr("Save as...")}
            MenuSeparator {}
            Action { text: qsTr("Exit")}
        }
        Menu {
            title: qsTr("Analysis")
            enabled: viewer.selected_file
            Menu {
                title: qsTr("IDC Detection")
                Action {
                    text: worker_manager.running ? qsTr("Stop analysis") : qsTr("Start analysis")
                    onTriggered: {
                        worker_manager.running ? worker_manager.stop_worker() : worker_manager.start_worker(viewer.selected_file)
                    }
                }
            }
            Action {
                text: qsTr("Manual delineation")
            }
        }
        Menu {
            title: qsTr("Diagnostic")
            enabled: viewer.selected_file

            Action {
                text: qsTr("Create diagnostic")
            }
            Action {
                text: qsTr("Edit diagnostic")
            }
            Action {
                text: qsTr("Share diagnostic")
            }
        }
        Menu {
            title: qsTr("Configuration")
            Menu {
                title: qsTr("Language")
                Action {
                    text: qsTr("English")
                    onTriggered: {
                        translator.set_language("en")
                    }
                }
                Action {
                    text: qsTr("Spanish")
                    onTriggered: {
                        translator.set_language("es")
                    }
                }
                Action {
                    text: qsTr("French")
                    onTriggered: {
                        translator.set_language("fr")
                    }
                }
            }
            Action {
                text: qsTr("Server settings")
            }
        }
        Menu {
            title: qsTr("Help")
            Action { text: qsTr("User manual")}
            Action { text: qsTr("About HistoBCAD")}
        }

        background: Rectangle {
            implicitWidth: 40
            implicitHeight: 40
            color: "#ffffff"

            Rectangle {
                color: "#eeeeee"
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
            }
        }
    }

    Row {
        id:rightToolbar
        anchors.right: parent.right
        anchors.bottom: parent.top
        height: mainMenuBar.height
        z: 100

        ToolButton {
            height: parent.height
            font.capitalization: Font.MixedCase
            icon.source: "resources/icons/notifications.svg"
            icon.color: "transparent"
            icon.height: parent.height * 0.5
            icon.width: parent.height * 0.5
            visible: false
        }
        ToolButton {
            text: qsTr("Sign in")
            height: parent.height
            font.capitalization: Font.MixedCase
            icon.source: "resources/icons/user.svg"
            icon.color: "transparent"
            icon.height: parent.height * 0.5
            icon.width: parent.height * 0.5
        }
    }




    SplitView {
        id: splitView
        anchors.fill: parent
        orientation: Qt.Horizontal

        Rectangle {
            id: leftPanel
            color: Material.color(Material.Grey, Material.Shade50)
            SplitView.minimumWidth: parent.width * 0.1
            SplitView.preferredWidth: parent.width * 0.15
            SplitView.maximumWidth: parent.width * 0.2
            visible: viewer.selected_file.toString() !== ""
            ScrollView {
                anchors.fill: parent
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff // disable the horizontal scroll bar

                ListView {
                    id: listView
                    model: viewer.selected_file_siblings
                    width: parent.width
                    height: parent.height
                    anchors.fill: parent
                    spacing: 10

                    // The delegate presents the information stored in the model
                    delegate: Rectangle {
                        border.color: Material.color(Material.Grey, (display === viewer.selected_file) ? Material.Shade700 : Material.Shade300)
                        border.width: (display === viewer.selected_file) ? 3 : 1
                        width: parent.width
                        height: parent.width * 0.60

                        Image {
                            asynchronous: true
                            fillMode: Image.PreserveAspectCrop
                            source: display
                            width: parent.width - 20
                            height: parent.width * 0.56
                            sourceSize.width: 512
                            sourceSize.height: 512
                            anchors.centerIn: parent

                            BusyIndicator {
                                running: parent.status === Image.Loading
                                anchors.centerIn: parent
                            }
                        }
//                        Label {
//                            text: display
//                            anchors.centerIn: parent.Center
//                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                viewer.mask_file = ''
                                viewer.selected_file = display

                            }
                        }
                    }
                }
            }

//            Button {
//                text: qsTr("Select WSI")
////                Material.background: Material.Indigo
////                anchors.centerIn: parent

//                onClicked: {
//                    fileDialog.open()
//                }
//            }

//            Button {
//                text: qsTr("Stop worker")
////                Material.background: Material.Indigo
////                anchors.centerIn: parent

//                visible: worker_manager.running
//                onClicked: {
//                    worker_manager.stop_worker()
//                }
//            }

        }

        Rectangle {
            id: visor
            SplitView.minimumWidth: parent.width*0.5
            SplitView.fillWidth: true
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
                visible: worker_manager.running
                value: worker_manager.progress
                Behavior on value { NumberAnimation {} }
            }
        }

        Rectangle {
            id: rightPanel
            SplitView.preferredWidth: parent.width * 0.3
            SplitView.minimumWidth: parent.width * 0.2
            SplitView.maximumWidth: parent.width * 0.4
            color: "white"
//            visible: viewer.selected_file.toString() !== ""
            visible: false

            ScrollView {
                id: scrollViewRightPanel
                anchors.fill: parent
                padding: 10
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: scrollViewRightPanel.width - 2*scrollViewRightPanel.padding
                    spacing: 5
                    Text {
                        text: qsTr("Diagnostic")
                        font.bold: true
                        font.pointSize: 12
                    }
                    Label {
                        topPadding: 10
                        text: qsTr("Patient's information") + ":"
                    }
                    TextField {
                        id: patientFirstName
                        placeholderText: qsTr("First name")
                        width: parent.width
                    }
                    TextField {
                        id: patientLastName
                        placeholderText: qsTr("Last name")
                        width: parent.width
                    }
                    TextField {
                        id: patientAge
                        placeholderText: qsTr("Age")
                        validator: IntValidator {bottom: 10; top: 100;}
                        width: parent.width
                    }

                    Label {
                        topPadding: 10
                        text: qsTr("Histopathologic diagnostic")  + ":"
                    }
                    CheckBox {
                        id: breastCancerDetected
                        text: qsTr("Breast cancer")
                        padding: 0

                    }
                    ComboBox {
                        id: histSubtypeCombo
                        currentIndex: -1
                        editable: true
                        textRole: "text"
                        model: ListModel {
                            id: histSubtypeComboModel
                            ListElement { text: qsTr("In situ ductal carcinoma"); key: "in-situ-ductal-carcinoma" }
                            ListElement { text: qsTr("In situ lobular carcinoma"); key: "in-situ-lobular-carcinoma" }
                            ListElement { text: qsTr("Invasive ductal carcinoma"); key: "invasive-ductal-carcinoma" }
                            ListElement { text: qsTr("Invasive lobular carcinoma"); key: "invasive-lobular-carcinoma" }
                            ListElement { text: qsTr("Invasive ductal/lobular carcinoma"); key: "invasive-ductal-lobular-carcinoma" }
                            ListElement { text: qsTr("Invasive mucinous (colloid) carcinoma"); key: "invasive-mucinous-colloid-carcinoma" }
                            ListElement { text: qsTr("Invasive tubular carcinoma"); key: "invasive-tubular-carcinoma" }
                            ListElement { text: qsTr("Invasive medullary carcinoma"); key: "invasive-medullary-carcinoma" }
                            ListElement { text: qsTr("Invasive papillary carcinoma"); key: "invasive-papillary-carcinoma" }
                        }
                        contentItem: Text {
                            leftPadding: 0
                            rightPadding: histSubtypeCombo.indicator.width + histSubtypeCombo.spacing
                            color: histSubtypeCombo.currentIndex == -1 ? "grey" : "black"
                            text: histSubtypeCombo.currentIndex == -1 ? qsTr("Histologic subtype") : histSubtypeComboModel.get(histSubtypeCombo.currentIndex).text
                            font: histSubtypeCombo.font
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        visible: breastCancerDetected.checkState === Qt.Checked
                        width: parent.width
                    }
                    ComboBox {
                        id: inSituDuctalCombo
                        currentIndex: -1
                        editable: true
                        textRole: "text"
                        model: ListModel {
                            id: inSituDuctalComboModel
                            ListElement { text: qsTr("Comedo"); key: "comedo" }
                            ListElement { text: qsTr("Cribiform"); key: "cribiform" }
                            ListElement { text: qsTr("Micropapillary"); key: "micropapillary" }
                            ListElement { text: qsTr("Papillary"); key: "papillary" }
                            ListElement { text: qsTr("Solid"); key: "solid" }
                        }
                        contentItem: Text {
                            leftPadding: 0
                            rightPadding: inSituDuctalCombo.indicator.width + inSituDuctalCombo.spacing
                            color: inSituDuctalCombo.currentIndex == -1 ? "grey" : "black"
                            text: inSituDuctalCombo.currentIndex == -1 ? qsTr("Sub-classification") : inSituDuctalComboModel.get(inSituDuctalCombo.currentIndex).text
                            font: inSituDuctalCombo.font
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        visible: histSubtypeCombo.visible && histSubtypeCombo.currentIndex !== -1 && histSubtypeComboModel.get(histSubtypeCombo.currentIndex).key === "in-situ-ductal-carcinoma"
                        width: parent.width
                    }
                    ComboBox {
                        id: invasiveDuctalCombo
                        currentIndex: -1
                        editable: true
                        textRole: "text"
                        model: ListModel {
                            id: invasiveDuctalComboModel
                            ListElement { text: qsTr("Well-differentiated (grade 1)"); key: "grade-1" }
                            ListElement { text: qsTr("Moderately differentiated (grade 2)"); key: "grade-2" }
                            ListElement { text: qsTr("Poorly differentiated (grade 3)"); key: "grade-3" }
                        }
                        contentItem: Text {
                            leftPadding: 0
                            rightPadding: invasiveDuctalCombo.indicator.width + invasiveDuctalCombo.spacing
                            color: invasiveDuctalCombo.currentIndex == -1 ? "grey" : "black"
                            text: invasiveDuctalCombo.currentIndex == -1 ? qsTr("Sub-classification") : invasiveDuctalComboModel.get(invasiveDuctalCombo.currentIndex).text
                            font: invasiveDuctalCombo.font
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        visible: histSubtypeCombo.visible && histSubtypeCombo.currentIndex !== -1 && histSubtypeComboModel.get(histSubtypeCombo.currentIndex).key === "invasive-ductal-carcinoma"
                        width: parent.width
                    }
                    ScrollView {
                        width: parent.width
                        height: parent.height * 0.3

                        TextArea {
                            id: diagnosticAdditionalInfo
                            anchors.fill: parent
                            selectByMouse: true
                            wrapMode: TextEdit.Wrap
                            placeholderText: qsTr("Additional diagnostic information")

                        }
                    }
                    Button {
                        id: diagnosticAddImage
                        text: qsTr("Attach images")
                        font.capitalization: Font.MixedCase
                        flat: true
                        icon.source: "resources/icons/attach.svg"
                        icon.color: "transparent"
                        icon.height: 20
                        icon.width: 20
                    }
                    Row {
                        spacing: 10

                        Button {
                            text: qsTr("Save")
                            font.capitalization: Font.MixedCase
                            Material.background: Material.Blue
                            Material.foreground: "white"

                        }
                        Button {
                            text: qsTr("Share")
                            font.capitalization: Font.MixedCase
                            Material.background: Material.Grey
                            Material.foreground: "white"

                        }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        height: labelStatus.height
        width: labelStatus.width
        border.color: Material.color(Material.Grey, Material.Shade200)
        color: Material.color(Material.Grey, Material.Shade100)
        visible: labelStatus.text.length > 0
        z: 30
        Label {
            id:labelStatus
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            padding: 5
            elide: Text.ElideRight
            text: worker_manager.status
        }
    }


    FileDialog {
        id: fileDialog
        title: qsTr("Select an image")
//        folder: shortcuts.home
        nameFilters: [ qsTr("Image files ") + " (*.jpg *.png *.bmp)" ]
        onAccepted: {
//            mapImage.source = fileDialog.fileUrl
//            background_image.z = -1
            viewer.selected_file = fileDialog.fileUrl
        }
    }
}



