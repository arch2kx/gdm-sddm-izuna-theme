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
    property string fontFamily: config.fontFamily ? config.fontFamily : "Adwaita Sans"
    property color accent: config.accent ? config.accent : "#c7c1de"
    property bool showDate: String(config.showDate) === "true"
    property bool userList: String(config.userList) === "true"
    property string timeFormat: config.timeFormat ? config.timeFormat : "HH:mm"
    property string dateFormat: config.dateFormat ? config.dateFormat : "dddd, d MMMM"
    property string topBarFormat: config.topBarFormat ? config.topBarFormat : "ddd d MMM  HH:mm"
    property color panel: "#e61e1e1e"
    property color panelHover: "#e6333333"
    property real avatarIconScale: config.avatarIconScale ? Number(config.avatarIconScale) : 1.0
    property real shadowOffset: config.shadowOffset ? Number(config.shadowOffset) : 0.015
    property real shadowBlur: config.shadowBlur ? Number(config.shadowBlur) : 0.4
    property real shadowOpacity: config.shadowOpacity ? Number(config.shadowOpacity) : 0.75
    property url backIcon: Qt.resolvedUrl(config.backIcon ? config.backIcon : "assets/backicon.png")
    property real backIconSize: config.backIconSize ? Number(config.backIconSize) : 30
    property url powerIcon: Qt.resolvedUrl(config.powerIcon ? config.powerIcon : "assets/powericon.png")
    property real powerIconSize: config.powerIconSize ? Number(config.powerIconSize) : 34
    property url gearIcon: Qt.resolvedUrl(config.gearIcon ? config.gearIcon : "assets/settingsicon.png")
    property real gearIconSize: config.gearIconSize ? Number(config.gearIconSize) : 34
    property url defaultAvatar: Qt.resolvedUrl(config.defaultAvatar ? config.defaultAvatar : "assets/usericon.png")

    function faceFor(icon) {
        var path = String(icon)
        if (path === "" || path === "undefined" || path.indexOf("/usr/share/sddm/faces/.face.icon") !== -1)
            return ""
        return path
    }

    function unlock() {
        if (!locked)
            return
        locked = false
        password.forceActiveFocus()
    }

    function lock() {
        locked = true
        password.text = ""
        password.reveal = false
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

    ComboBox {
        id: sessions
        visible: false
        model: sessionModel
        textRole: "name"
        currentIndex: sessionModel.lastIndex
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

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 34 * root.s
            text: Qt.formatDateTime(root.now, root.topBarFormat)
            color: "white"
            font.family: root.fontFamily
            font.pixelSize: 24 * root.s
            font.weight: Font.DemiBold
        }

        Rectangle {
            id: powerButton
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 28 * root.s
            width: 56 * root.s
            height: 56 * root.s
            radius: width / 2
            color: powerArea.containsMouse || powerPopup.visible ? root.panelHover : root.panel
            Behavior on color { ColorAnimation { duration: 120 } }

            Image {
                id: powerImage
                anchors.centerIn: parent
                width: root.powerIconSize * root.s
                height: root.powerIconSize * root.s
                source: root.powerIcon
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                visible: status === Image.Ready
            }

            Icon {
                anchors.centerIn: parent
                width: 30 * root.s
                height: 30 * root.s
                kind: "power"
                visible: powerImage.status !== Image.Ready
            }

            MouseArea {
                id: powerArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: powerPopup.visible ? powerPopup.close() : powerPopup.open()
            }

            Popup {
                id: powerPopup
                x: powerButton.width - width
                y: powerButton.height + 10 * root.s
                width: 250 * root.s
                padding: 6 * root.s
                closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

                background: Rectangle {
                    radius: 12 * root.s
                    color: "#f2232323"
                }

                contentItem: Column {
                    Repeater {
                        model: [
                            { label: "Suspend", show: sddm.canSuspend },
                            { label: "Restart", show: sddm.canReboot },
                            { label: "Power Off", show: sddm.canPowerOff }
                        ]
                        delegate: ItemDelegate {
                            visible: modelData.show
                            width: 238 * root.s
                            height: 52 * root.s
                            contentItem: Text {
                                text: modelData.label
                                color: "white"
                                font.family: root.fontFamily
                                font.pixelSize: 21 * root.s
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10 * root.s
                            }
                            background: Rectangle {
                                radius: 8 * root.s
                                color: parent.hovered ? "#33ffffff" : "transparent"
                            }
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
        }

        Rectangle {
            id: gearButton
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 36 * root.s
            width: 60 * root.s
            height: 60 * root.s
            radius: width / 2
            color: gearArea.containsMouse || sessionPopup.visible ? root.panelHover : root.panel
            Behavior on color { ColorAnimation { duration: 120 } }

            Image {
                id: gearImage
                anchors.centerIn: parent
                width: root.gearIconSize * root.s
                height: root.gearIconSize * root.s
                source: root.gearIcon
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                visible: status === Image.Ready
            }

            Icon {
                anchors.centerIn: parent
                width: 32 * root.s
                height: 32 * root.s
                kind: "gear"
                visible: gearImage.status !== Image.Ready
            }

            MouseArea {
                id: gearArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: sessionPopup.visible ? sessionPopup.close() : sessionPopup.open()
            }

            Popup {
                id: sessionPopup
                x: gearButton.width - width
                y: -height - 12 * root.s
                width: 340 * root.s
                padding: 8 * root.s
                closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

                background: Rectangle {
                    radius: 18 * root.s
                    color: "#f5292929"
                }

                contentItem: Column {
                    spacing: 2 * root.s

                    Repeater {
                        model: sessionModel
                        delegate: ItemDelegate {
                            id: sessionItem
                            width: 324 * root.s
                            height: 52 * root.s
                            highlighted: sessions.currentIndex === index
                            leftPadding: 16 * root.s
                            contentItem: Row {
                                spacing: 16 * root.s

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 22 * root.s
                                    height: 22 * root.s
                                    radius: width / 2
                                    color: "transparent"
                                    border.width: 2 * root.s
                                    border.color: "#b3ffffff"

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 10 * root.s
                                        height: 10 * root.s
                                        radius: width / 2
                                        color: "white"
                                        visible: sessionItem.highlighted
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 262 * root.s
                                    text: model.name
                                    color: "white"
                                    font.family: root.fontFamily
                                    font.pixelSize: 21 * root.s
                                    elide: Text.ElideRight
                                }
                            }
                            background: Rectangle {
                                radius: 10 * root.s
                                color: sessionItem.highlighted ? "#40ffffff" : (sessionItem.hovered ? "#22ffffff" : "transparent")
                            }
                            onClicked: {
                                sessions.currentIndex = index
                                sessionPopup.close()
                                password.forceActiveFocus()
                            }
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

                            Avatar {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 160 * root.s
                                height: 160 * root.s
                                primary: root.faceFor(model.icon)
                                fallback: root.defaultAvatar
                                iconScale: root.avatarIconScale
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

            Item {
                width: parent.width
                height: password.height

                Rectangle {
                    id: backButton
                    anchors.right: password.left
                    anchors.rightMargin: 14 * root.s
                    anchors.verticalCenter: parent.verticalCenter
                    width: 52 * root.s
                    height: 52 * root.s
                    radius: width / 2
                    color: backArea.containsMouse ? root.panelHover : root.panel
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Image {
                        id: backImage
                        anchors.centerIn: parent
                        width: root.backIconSize * root.s
                        height: root.backIconSize * root.s
                        source: root.backIcon
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -3 * root.s
                        text: "‹"
                        color: "white"
                        font.pixelSize: 42 * root.s
                        visible: backImage.status !== Image.Ready
                    }

                    MouseArea {
                        id: backArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.lock()
                    }
                }

                TextField {
                    id: password
                    property bool reveal: false
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 400 * root.s
                    height: 60 * root.s
                    echoMode: reveal ? TextInput.Normal : TextInput.Password
                    placeholderText: "Password"
                    placeholderTextColor: "#99ffffff"
                    color: "white"
                    font.family: root.fontFamily
                    font.pixelSize: 24 * root.s
                    horizontalAlignment: TextInput.AlignLeft
                    verticalAlignment: TextInput.AlignVCenter
                    leftPadding: 18 * root.s
                    rightPadding: 64 * root.s
                    selectByMouse: true

                    transform: Translate { id: shift }

                    background: Rectangle {
                        radius: 8 * root.s
                        color: "#232227"
                        border.width: 2 * root.s
                        border.color: password.activeFocus ? root.accent : "#44ffffff"
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }

                    onAccepted: root.login()
                    onTextChanged: failLabel.opacity = 0
                    Keys.onEscapePressed: root.lock()

                    Icon {
                        anchors.right: parent.right
                        anchors.rightMargin: 18 * root.s
                        anchors.verticalCenter: parent.verticalCenter
                        width: 30 * root.s
                        height: 30 * root.s
                        kind: password.reveal ? "eye" : "eyeoff"
                        tint: "#e6ffffff"

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -10 * root.s
                            onClicked: {
                                password.reveal = !password.reveal
                                password.forceActiveFocus()
                            }
                        }
                    }

                    SequentialAnimation {
                        id: shake
                        NumberAnimation { target: shift; property: "x"; to: -18 * root.s; duration: 60 }
                        NumberAnimation { target: shift; property: "x"; to: 18 * root.s; duration: 90 }
                        NumberAnimation { target: shift; property: "x"; to: -10 * root.s; duration: 70 }
                        NumberAnimation { target: shift; property: "x"; to: 0; duration: 60 }
                    }
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

                    Avatar {
                        id: miniAvatar
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 88 * root.s
                        height: 88 * root.s
                        primary: root.faceFor(model.icon)
                        fallback: root.defaultAvatar
                        iconScale: root.avatarIconScale

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: "transparent"
                            border.width: (current ? 4 : 0) * root.s
                            border.color: root.accent
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
            y: root.height * 0.1
            spacing: 4

            Item {
                width: clockText.width
                height: clockText.height
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    visible: clockShadow.status !== Loader.Ready
                    x: 0
                    y: 6 * root.s
                    text: clockText.text
                    font: clockText.font
                    color: "#55000000"
                }

                Loader {
                    id: clockShadow
                    anchors.fill: parent
                    source: "Shadow.qml"
                    onLoaded: {
                        item.target = clockText
                        item.shadowVerticalOffset = root.height * root.shadowOffset
                        item.shadowBlur = root.shadowBlur
                        item.shadowOpacity = root.shadowOpacity
                    }
                }

                Text {
                    id: clockText
                    visible: clockShadow.status !== Loader.Ready
                    text: Qt.formatTime(root.now, root.timeFormat)
                    color: "white"
                    font.family: root.fontFamily
                    font.pixelSize: root.height * 0.25
                    font.weight: Font.Black
                    font.letterSpacing: -root.height * 0.009
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
