import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.11
import QtQuick.Dialogs 1.0

FileDialog {
    id: openFileDialog
    title: qsTr("Select an image")
//        folder: shortcuts.home
    nameFilters: [ qsTr("Image files ") + " (*.jpg *.png *.jpeg *.tif *.tiff *.dcm *.ndpi *.vms *.vmu *.scn *.mrxs *.svslide *.bif)" ]
    onAccepted: {
//            mapImage.source = fileDialog.fileUrl
//            background_image.z = -1
//             viewer.selected_file = fileDialog.fileUrl
        viewer.selected_file = openFileDialog.fileUrl
        // rightPanelContentLoader.source = "qml/components/ComponentDiagnosticForm.qml"
//            rightPanel.visible = true
    }
}