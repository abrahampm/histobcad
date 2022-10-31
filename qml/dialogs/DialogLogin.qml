import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.11

Dialog {
    id: loginDialog
    title: qsTr("Sign in")
    standardButtons: Dialog.Close

    signal loginResult(bool login_success)
    Component.onCompleted: auth_manager.on_login_success.connect(loginResult)

    onLoginResult: {
        if (login_success === true) {
            loginDialog.close()
        }
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.horizontal.z: -1
        ScrollBar.vertical.policy: applicationWindow.height < 444 ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        clip: true

        ColumnLayout {
            width: loginDialog.width - 2*loginDialog.padding

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                Image {
                    id: userloginImage
                    source: "../../resources/icons/user.svg"
                    sourceSize.width: 120
                    sourceSize.height: 120
                    opacity: 0.1
                }
            }

            TextField {
               id: emailTextField
               Layout.fillWidth: true
               placeholderText: qsTr("Email")
            }

            TextField {
               id: passwordTextField
               Layout.fillWidth: true
               placeholderText: qsTr("Password")
               echoMode: TextInput.Password
            }

            Button {
               id: signinButton
               text: qsTr("Sign in")
               font.capitalization: Font.MixedCase
               Layout.fillWidth: true
               Material.background: Material.Blue
               Material.foreground: "white"
               onClicked: {
                   auth_manager.login(emailTextField.text, passwordTextField.text)
                   signinButton.enabled = false
                   registerButton.enabled = false
                   emailTextField.enabled = false
                   passwordTextField.enabled = false
                   registerText.color = Material.color(Material.Grey)
               }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                Text {
                    id: registerText
                    text: qsTr("Don't have an account?")
                }

                Button {
                    id: registerButton
                    text: qsTr("Register")
                    flat: true
                    font.capitalization: Font.MixedCase
                    Material.foreground: Material.Blue
                    onClicked: {
                        loginDialog.close()
                        registerDialog.open()
                    }
                }
            }

        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: auth_manager.login_loading
        z: parent.z + 1
    }
}
