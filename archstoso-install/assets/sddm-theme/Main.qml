// ArchStoso SDDM Theme — Main.qml
// Uses SddmComponents only — no QtQuick.Controls dependency

import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: root
    width:  geometry.width
    height: geometry.height
    color:  "#1a110f"

    // Background image
    Image {
        id:       backgroundImage
        anchors.fill: parent
        source:   config.background !== undefined ? config.background : ""
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: if (status === Image.Error) visible = false
    }

    // Dark overlay — only shown when image loaded successfully
    Rectangle {
        anchors.fill: parent
        color:   "#000000"
        opacity: 0.45
        visible: backgroundImage.visible && backgroundImage.status === Image.Ready
    }

    function login() {
        errorText.visible = false
        sddm.login(usernameField.text, passwordField.text, sessionSelector.index)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorText.text     = "Login failed — check your password"
            errorText.visible  = true
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80
        spacing: 16

        // Logo
        Image {
            source:   "assets/archstoso.svg"
            width:    120
            height:   120
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            onStatusChanged: if (status === Image.Error) visible = false
        }

        // Title
        Text {
            text:           "ArchStoso"
            color:          "#f1dfda"
            font.family:    "sans-serif"
            font.pixelSize: 28
            font.bold:      true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Subtitle
        Text {
            text:           "Arch Linux / Hyprland"
            color:          "#a08d87"
            font.family:    "sans-serif"
            font.pixelSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item { width: 1; height: 8 }

        // Username
        TextBox {
            id:    usernameField
            width: 280
            text:  userModel.lastUser
            anchors.horizontalCenter: parent.horizontalCenter
            KeyNavigation.tab: passwordField
        }

        // Password
        PasswordBox {
            id:    passwordField
            width: 280
            anchors.horizontalCenter: parent.horizontalCenter
            Keys.onReturnPressed: root.login()
            Keys.onEnterPressed:  root.login()
            KeyNavigation.tab: loginButton
        }

        // Error message
        Text {
            id:             errorText
            visible:        false
            text:           ""
            color:          "#ffb4ab"
            font.family:    "sans-serif"
            font.pixelSize: 11
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Login button
        Button {
            id:    loginButton
            text:  "Login"
            width: 280
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.login()
            Keys.onReturnPressed: root.login()
            Keys.onEnterPressed:  root.login()
        }

        Item { width: 1; height: 8 }

        // Session + user selectors
        Row {
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            ComboBox {
                id:    sessionSelector
                width: 135
                model: sessionModel
                index: sessionModel.lastIndex
            }

            ComboBox {
                id:    userSelector
                width: 135
                model: userModel
                index: userModel.lastIndex
                onValueChanged: usernameField.text = userSelector.value
            }
        }
    }

    Component.onCompleted: {
        if (usernameField.text !== "")
            passwordField.forceActiveFocus()
        else
            usernameField.forceActiveFocus()
    }
}
