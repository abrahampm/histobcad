import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs

FileDialog {
    id: openFileDialog
    title: qsTr("Select an image")
//        folder: shortcuts.home
    nameFilters: [ qsTr("Image files ") + " " + viewer.supported_file_extensions ]
    onAccepted: {
//             viewer.selected_file = fileDialog.fileUrl
        viewer.selected_file = openFileDialog.currentFile;
        // rightPanelContentLoader.source = "qml/components/ComponentDiagnosticForm.qml"
//            rightPanel.visible = true
    }
}