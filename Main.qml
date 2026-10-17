import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#0b0710"
    focus: true

    property bool locked: true
    property date now: new Date()
    property real uiScale: config.uiScale ? Number(config.uiScale) : 1.0
    property real s: (height / 1080) * uiScale
    property string fontFamily: config.fontFamily ? config.fontFamily : "Cantarell"
    property color accent: config.accent ? config.accent : "#c6a2ff"
    property bool showDate: String(config.showDate) === "true"
    property bool userList: String(config.userList) === "true"
    property string timeFormat: config.timeFormat ? config.timeFormat : "HH:mm"
    property string dateFormat: config.dateFormat ? config.dateFormat : "dddd, d MMMM"

    function unlock() {
        if (!locked)
            return
        locked = false
        password.forceActiveFocus()
    }

    function lock() {
        locked = true
        password.text = ""
        root.forceActiveFocus()
    }

    function login() {
        if (password.text.length === 0 || users.currentItem === null)
            return
        sddm.login(users.currentItem.loginName, password.text, sessions.currentIndex)
    }

    Keys.onPressed: function(event) {
        if (locked) {
            unlock()
            event.accepted = true
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = ""
            failLabel.opacity = 1
            shake.restart()
            password.forceActiveFocus()
        }
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: config.background ? config.background : "assets/wallpaper.png"
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    Loader {
        anchors.fill: parent
        source: "Blur.qml"
        opacity: root.locked ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
        onLoaded: item.target = wallpaper
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: root.locked ? 0.12 : 0.4
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
    }

    Item {
        id: loginLayer
        anchors.fill: parent
        opacity: root.locked ? 0 : 1
        enabled: !root.locked
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

        Row {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 36 * root.s
            spacing: 12 * root.s

            Repeater {
                model: [
                    { label: "Suspend", show: sddm.canSuspend },
                    { label: "Restart", show: sddm.canReboot },
                    { label: "Power Off", show: sddm.canPowerOff }
                ]
                delegate: Rectangle {
                    visible: modelData.show
                    width: powerLabel.implicitWidth + 44 * root.s
                    height: 48 * root.s
                    radius: height / 2
                    color: powerArea.containsMouse ? "#44ffffff" : "#22ffffff"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        id: powerLabel
                        anchors.centerIn: parent
                        text: modelData.label
                        color: "white"
                        font.family: root.fontFamily
                        font.pixelSize: 20 * root.s
                    }

                    MouseArea {
                        id: powerArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (index === 0)
                                sddm.suspend()
                            else if (index === 1)
                                sddm.reboot()
                            else
                                sddm.powerOff()
                        }
                    }
                }
            }
        }

        Column {
            id: loginBox
            anchors.centerIn: parent
            width: 460 * root.s
            spacing: 22 * root.s

            Item {
                width: parent.width
                height: 270 * root.s

                ListView {
                    id: users
                    anchors.fill: parent
                    orientation: ListView.Horizontal
                    model: userModel
                    currentIndex: userModel.lastIndex
                    snapMode: ListView.SnapOneItem
                    highlightRangeMode: ListView.StrictlyEnforceRange
                    highlightMoveDuration: 250
                    interactive: count > 1
                    clip: true

                    delegate: Item {
                        property string loginName: model.name
                        width: users.width
                        height: users.height

                        Column {
                            anchors.centerIn: parent
                            spacing: 18 * root.s

                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 160 * root.s
                                height: 160 * root.s
                                radius: width / 2
                                color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.28)
                                border.width: 3 * root.s
                                border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.7)

                                Text {
                                    anchors.centerIn: parent
                                    text: (model.realName ? model.realName : model.name).charAt(0).toUpperCase()
                                    color: "white"
                                    font.family: root.fontFamily
                                    font.pixelSize: 70 * root.s
                                    font.weight: Font.DemiBold
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: model.realName ? model.realName : model.name
                                color: "white"
                                font.family: root.fontFamily
                                font.pixelSize: 34 * root.s
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }

                Text {
                    visible: users.count > 1 && !root.userList
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "‹"
                    color: "white"
                    font.pixelSize: 60 * root.s
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -12 * root.s
                        onClicked: users.decrementCurrentIndex()
                    }
                }

                Text {
                    visible: users.count > 1 && !root.userList
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "›"
                    color: "white"
                    font.pixelSize: 60 * root.s
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -12 * root.s
                        onClicked: users.incrementCurrentIndex()
                    }
                }
            }

            TextField {
                id: password
                width: parent.width
                height: 68 * root.s
                echoMode: TextInput.Password
                placeholderText: "Password"
                placeholderTextColor: "#aaffffff"
                color: "white"
                font.family: root.fontFamily
                font.pixelSize: 24 * root.s
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                leftPadding: 26 * root.s
                rightPadding: 26 * root.s
                selectByMouse: true

                transform: Translate { id: shift }

                background: Rectangle {
                    radius: height / 2
                    color: password.activeFocus ? "#33ffffff" : "#22ffffff"
                    border.width: 2 * root.s
                    border.color: password.activeFocus ? root.accent : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                onAccepted: root.login()
                onTextChanged: failLabel.opacity = 0
                Keys.onEscapePressed: root.lock()

                SequentialAnimation {
                    id: shake
                    NumberAnimation { target: shift; property: "x"; to: -18 * root.s; duration: 60 }
                    NumberAnimation { target: shift; property: "x"; to: 18 * root.s; duration: 90 }
                    NumberAnimation { target: shift; property: "x"; to: -10 * root.s; duration: 70 }
                    NumberAnimation { target: shift; property: "x"; to: 0; duration: 60 }
                }
            }

            Text {
                id: failLabel
                width: parent.width
                opacity: 0
                text: "Sorry, that didn't work. Please try again."
                horizontalAlignment: Text.AlignHCenter
                color: "#ffb4ab"
                font.family: root.fontFamily
                font.pixelSize: 19 * root.s
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            ComboBox {
                id: sessions
                anchors.horizontalCenter: parent.horizontalCenter
                width: 300 * root.s
                height: 46 * root.s
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex

                background: Item {}
                indicator: Item {}
                contentItem: Text {
                    text: sessions.displayText
                    color: "#ddffffff"
                    font.family: root.fontFamily
                    font.pixelSize: 19 * root.s
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                delegate: ItemDelegate {
                    width: sessions.width
                    height: 46 * root.s
                    highlighted: sessions.highlightedIndex === index
                    contentItem: Text {
                        text: model.name
                        color: "#1c1424"
                        font.family: root.fontFamily
                        font.pixelSize: 19 * root.s
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: 12 * root.s
                        color: highlighted ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.35) : "transparent"
                    }
                }

                popup: Popup {
                    y: sessions.height
                    width: sessions.width
                    padding: 6 * root.s
                    implicitHeight: contentItem.implicitHeight + 12 * root.s
                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: sessions.popupVisible ? sessions.delegateModel : null
                        currentIndex: sessions.highlightedIndex
                    }
                    background: Rectangle {
                        radius: 16 * root.s
                        color: "#f5ffffff"
                    }
                }
            }
        }

        Row {
            id: userRow
            visible: root.userList && users.count > 1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 56 * root.s
            spacing: 40 * root.s

            Repeater {
                model: userModel
                delegate: Item {
                    property bool current: users.currentIndex === index
                    width: 130 * root.s
                    height: 150 * root.s
                    opacity: current ? 1 : 0.65
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Rectangle {
                        id: miniAvatar
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 88 * root.s
                        height: 88 * root.s
                        radius: width / 2
                        color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.28)
                        border.width: (current ? 4 : 1) * root.s
                        border.color: current ? root.accent : Qt.rgba(1, 1, 1, 0.4)

                        Text {
                            anchors.centerIn: parent
                            text: (model.realName ? model.realName : model.name).charAt(0).toUpperCase()
                            color: "white"
                            font.family: root.fontFamily
                            font.pixelSize: 38 * root.s
                            font.weight: Font.DemiBold
                        }
                    }

                    Text {
                        anchors.top: miniAvatar.bottom
                        anchors.topMargin: 12 * root.s
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        text: model.realName ? model.realName : model.name
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        font.family: root.fontFamily
                        font.pixelSize: 20 * root.s
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            users.currentIndex = index
                            password.forceActiveFocus()
                        }
                    }
                }
            }
        }
    }

    Item {
        id: lockLayer
        width: parent.width
        height: parent.height
        y: root.locked ? 0 : -height
        visible: y > -height
        Behavior on y { NumberAnimation { duration: 450; easing.type: Easing.InOutCubic } }

        Column {
            id: clockBox
            anchors.horizontalCenter: parent.horizontalCenter
            y: root.height * 0.07
            spacing: 4

            Item {
                width: clockText.width
                height: clockText.height
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    x: 0
                    y: 6 * root.s
                    text: clockText.text
                    font: clockText.font
                    color: "#55000000"
                }

                Text {
                    id: clockText
                    text: Qt.formatTime(root.now, root.timeFormat)
                    color: "white"
                    font.family: root.fontFamily
                    font.pixelSize: root.height * 0.2
                    font.weight: Font.Black
                    font.letterSpacing: -root.height * 0.006
                }
            }

            Text {
                visible: root.showDate
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(root.now, root.dateFormat)
                color: "white"
                font.family: root.fontFamily
                font.pixelSize: root.height * 0.036
                font.weight: Font.DemiBold
            }
        }

        Text {
            id: hint
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.height * 0.05
            text: "Click or press any key to unlock"
            color: "white"
            font.family: root.fontFamily
            font.pixelSize: 22 * root.s

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: root.locked
                NumberAnimation { to: 0.35; duration: 1600; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.9; duration: 1600; easing.type: Easing.InOutSine }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.unlock()
            onWheel: root.unlock()
        }
    }

    Component.onCompleted: root.forceActiveFocus()
}
