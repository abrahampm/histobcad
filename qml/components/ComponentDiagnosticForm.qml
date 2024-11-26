import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

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
        icon.source: "../../resources/icons/attach.svg"
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
