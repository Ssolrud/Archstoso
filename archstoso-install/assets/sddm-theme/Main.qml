// ArchStoso SDDM Theme — Main.qml
// Compatible with SDDM 0.21+ / Qt 6
// Color palette derived from ArchStoso Matugen theme seed.

import QtQuick
import QtQuick.Controls
import SddmComponents 2.0

Rectangle {
    id: root

    // -----------------------------------------------------------------------
    // Screen geometry — SDDM sets this via geometry property
    // -----------------------------------------------------------------------
    width:  geometry.width  || Screen.width
    height: geometry.height || Screen.height

    // Background
    color: "#1a110f"

    // -----------------------------------------------------------------------
    // Helper: trigger login
    // -----------------------------------------------------------------------
    function login() {
        errorText.visible = false
        sddm.login(usernameField.text, passwordField.text, sessionSelector.currentIndex)
    }

    // -----------------------------------------------------------------------
    // SDDM signal handlers
    // -----------------------------------------------------------------------
    Connections {
        target: sddm

        function onLoginFailed() {
            errorText.text    = "Login failed — check your password"
            errorText.visible = true
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
    }

    // -----------------------------------------------------------------------
    // Central panel — Column vertically and horizontally centered
    // -----------------------------------------------------------------------
    Column {
        anchors.centerIn: parent
        spacing: 16

        // --- Logo -----------------------------------------------------------
        Rectangle {
            width:  120
            height: 120
            color:  "transparent"
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id:       logoImage
                source:   "assets/archstoso.svg"
                width:    120
                height:   120
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent

                // Graceful fallback: if SVG fails to load, show nothing
                onStatusChanged: {
                    if (status === Image.Error)
                        visible = false
                }
            }
        }

        // --- Title ----------------------------------------------------------
        Text {
            text:  "ArchStoso"
            color: "#f1dfda"
            font {
                family:    "sans-serif"
                pixelSize: 28
                bold:      true
            }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // --- Subtitle -------------------------------------------------------
        Text {
            text:  "Arch Linux / Hyprland"
            color: "#a08d87"
            font {
                family:    "sans-serif"
                pixelSize: 12
            }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Extra gap between subtitle and input fields
        Item { width: 1; height: 8 }

        // --- Username field -------------------------------------------------
        TextField {
            id:    usernameField
            width: 280

            placeholderText: "Username"
            text:            userModel.lastUser

            color: "#f1dfda"

            font {
                family:    "sans-serif"
                pixelSize: config.fontSize !== undefined ? parseInt(config.fontSize) : 11
            }

            // Remove the default platform-styled background and supply our own.
            background: Rectangle {
                color:  usernameField.activeFocus ? "#322825" : "#271d1b"
                radius: 6

                border.width: 1
                border.color: usernameField.activeFocus ? "#ffb59d" : "#a08d87"

                Behavior on color        { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }
            }

            // Placeholder text color override (Qt 6.2+)
            placeholderTextColor: "#a08d87"

            leftPadding:   12
            rightPadding:  12
            topPadding:    10
            bottomPadding: 10

            KeyNavigation.tab: passwordField

            anchors.horizontalCenter: parent.horizontalCenter
        }

        // --- Password field -------------------------------------------------
        TextField {
            id:       passwordField
            width:    280
            echoMode: TextInput.Password

            placeholderText: "Password"

            color: "#f1dfda"

            font {
                family:    "sans-serif"
                pixelSize: config.fontSize !== undefined ? parseInt(config.fontSize) : 11
            }

            background: Rectangle {
                color:  passwordField.activeFocus ? "#322825" : "#271d1b"
                radius: 6

                border.width: 1
                border.color: passwordField.activeFocus ? "#ffb59d" : "#a08d87"

                Behavior on color        { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }
            }

            placeholderTextColor: "#a08d87"

            leftPadding:   12
            rightPadding:  12
            topPadding:    10
            bottomPadding: 10

            KeyNavigation.tab: loginButton

            Keys.onReturnPressed:  root.login()
            Keys.onEnterPressed:   root.login()

            anchors.horizontalCenter: parent.horizontalCenter
        }

        // --- Error text -----------------------------------------------------
        Text {
            id:      errorText
            visible: false
            text:    ""
            color:   "#ffb4ab"
            font {
                family:    "sans-serif"
                pixelSize: 11
            }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // --- Login button ---------------------------------------------------
        Button {
            id:     loginButton
            text:   "Login"
            width:  280
            height: 40

            anchors.horizontalCenter: parent.horizontalCenter

            background: Rectangle {
                color:  loginButton.hovered ? "#ffc5b0" : "#ffb59d"
                radius: 6

                Behavior on color { ColorAnimation { duration: 120 } }
            }

            contentItem: Text {
                text:                loginButton.text
                color:               "#55200c"
                font.bold:           true
                font.family:         "sans-serif"
                font.pixelSize:      13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:   Text.AlignVCenter
            }

            onClicked: root.login()

            // Keyboard activation (Space / Return when focused)
            Keys.onReturnPressed:  root.login()
            Keys.onEnterPressed:   root.login()
            Keys.onSpacePressed:   root.login()
        }

        // Extra gap before session/user selectors
        Item { width: 1; height: 8 }

        // --- Session + User selectors ---------------------------------------
        Row {
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            // Session selector
            ComboBox {
                id:    sessionSelector
                width: 135

                model: sessionModel
                // sessionModel provides 'name' role
                textRole: "name"

                font.family:    "sans-serif"
                font.pixelSize: 11

                background: Rectangle {
                    color:  sessionSelector.hovered ? "#322825" : "#271d1b"
                    radius: 6
                    border.width: 1
                    border.color: sessionSelector.activeFocus ? "#ffb59d" : "#a08d87"
                }

                contentItem: Text {
                    leftPadding: 10
                    text:        sessionSelector.displayText
                    color:       "#f1dfda"
                    font:        sessionSelector.font
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                // Dropdown popup styling
                popup: Popup {
                    y:      sessionSelector.height
                    width:  sessionSelector.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1

                    contentItem: ListView {
                        clip:          true
                        implicitHeight: contentHeight
                        model:         sessionSelector.popup.visible ? sessionSelector.delegateModel : null

                        ScrollIndicator.vertical: ScrollIndicator {}
                    }

                    background: Rectangle {
                        color:        "#271d1b"
                        radius:       6
                        border.color: "#a08d87"
                        border.width: 1
                    }
                }

                delegate: ItemDelegate {
                    width:  sessionSelector.width
                    height: 32

                    contentItem: Text {
                        text:  modelData !== undefined ? modelData : model.name
                        color: "#f1dfda"
                        font:  sessionSelector.font
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 10
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        color: hovered ? "#322825" : "transparent"
                    }
                }
            }

            // User selector
            ComboBox {
                id:    userSelector
                width: 135

                model:    userModel
                textRole: "name"

                font.family:    "sans-serif"
                font.pixelSize: 11

                // Sync username field when selection changes
                onCurrentIndexChanged: {
                    usernameField.text = userModel.get(currentIndex).name
                }

                background: Rectangle {
                    color:  userSelector.hovered ? "#322825" : "#271d1b"
                    radius: 6
                    border.width: 1
                    border.color: userSelector.activeFocus ? "#ffb59d" : "#a08d87"
                }

                contentItem: Text {
                    leftPadding: 10
                    text:        userSelector.displayText
                    color:       "#f1dfda"
                    font:        userSelector.font
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                popup: Popup {
                    y:      userSelector.height
                    width:  userSelector.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1

                    contentItem: ListView {
                        clip:          true
                        implicitHeight: contentHeight
                        model:         userSelector.popup.visible ? userSelector.delegateModel : null

                        ScrollIndicator.vertical: ScrollIndicator {}
                    }

                    background: Rectangle {
                        color:        "#271d1b"
                        radius:       6
                        border.color: "#a08d87"
                        border.width: 1
                    }
                }

                delegate: ItemDelegate {
                    width:  userSelector.width
                    height: 32

                    contentItem: Text {
                        text:  modelData !== undefined ? modelData : model.name
                        color: "#f1dfda"
                        font:  userSelector.font
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 10
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        color: hovered ? "#322825" : "transparent"
                    }
                }
            }
        }
    }

    // -----------------------------------------------------------------------
    // Initial focus
    // -----------------------------------------------------------------------
    Component.onCompleted: {
        if (usernameField.text !== "")
            passwordField.forceActiveFocus()
        else
            usernameField.forceActiveFocus()
    }
}
