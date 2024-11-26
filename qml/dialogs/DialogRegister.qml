import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Dialog {
    id: registerDialog
    title: qsTr("Create new account")
    standardButtons: Dialog.Close

    signal registerResult(bool register_success)
    Component.onCompleted: auth_manager.on_register_success.connect(registerResult)

    onRegisterResult: {
        if (register_success === true) {
            registerDialog.close()
        }
    }

    onOpened: {
        auth_manager.refresh_captcha()
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.horizontal.z: -1
        ScrollBar.vertical.policy: applicationWindow.height < 444 ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        clip: true

        ColumnLayout {
            width: registerDialog.width - 2*registerDialog.padding

            TextField {
               id: emailTextField
               Layout.fillWidth: true
               Layout.topMargin: 10
               placeholderText: qsTr("Email")
            }

            RowLayout {
                Layout.fillWidth: true

                TextField {
                   id: firstnameTextField
                   Layout.fillWidth: true
                   placeholderText: qsTr("First name")
                }

                TextField {
                   id: lastnameTextField
                   Layout.fillWidth: true
                   placeholderText: qsTr("Last name")
                }
            }

            TextField {
               id: passwordTextField
               Layout.fillWidth: true
               placeholderText: qsTr("Password")
               echoMode: TextInput.PasswordEchoOnEdit
            }

            TextField {
               id: passwordConfirmTextField
               Layout.fillWidth: true
               placeholderText: qsTr("Confirm Password")
               echoMode: TextInput.Password
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter

                Image {
                    asynchronous: true
                    id: captchaImage
                    source: auth_manager.captcha_image_loading ? "" : "image://captcha_image_provider/captcha_image"
                    cache: false
                    width: 200
                    height: 50
                    Layout.leftMargin: 60

                    BusyIndicator {
                        running: auth_manager.captcha_image_loading
                        anchors.centerIn: parent
                        z: parent.z + 1
                    }
                }

                Button {
                    id: refreshCaptchaImageButton
                    display: AbstractButton.IconOnly
                    flat: true
                    icon.source: "../../resources/icons/refresh.svg"
                    icon.color: "transparent"
                    icon.height: 20
                    icon.width: 20
                    width: 60
                    height: 50

                    onClicked: {
                        auth_manager.refresh_captcha()
                    }
                }
            }

            TextField {
               id: captchaTextField
               Layout.fillWidth: true
               placeholderText: qsTr("Type code here")
            }

            Button {
               id: registerButton
               text: qsTr("Register")
               font.capitalization: Font.MixedCase
               Layout.fillWidth: true
               Layout.topMargin: 10
               Material.background: Material.Blue
               Material.foreground: "white"
               onClicked: {
                   auth_manager.register(emailTextField.text, firstnameTextField.text, lastnameTextField.text, passwordTextField.text, captchaTextField.text)
                   emailTextField.enabled = false
                   firstnameTextField.enabled = false
                   lastnameTextField.enabled = false
                   passwordTextField.enabled = false
                   passwordConfirmTextField.enabled = false
                   captchaImage.opacity = 0.8
                   captchaTextField.enabled = false
                   refreshCaptchaImageButton.enabled = false
                   registerButton.enabled = false
                   signinButton.enabled = false

               }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                Text {
                    id: registerText
                    text: qsTr("Already have an account?")
                }

                Button {
                    id: signinButton
                    text: qsTr("Sign in")
                    flat: true
                    font.capitalization: Font.MixedCase
                    Material.foreground: Material.Blue
                    onClicked: {
                        registerDialog.close()
                        loginDialog.open()
                    }
                }
            }
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: auth_manager.register_loading
        z: parent.z + 1
    }
}
