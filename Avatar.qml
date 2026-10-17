import QtQuick 2.15

Canvas {
    id: avatar
    property url primary
    property url fallback
    property real iconScale: 1.0
    property color back: "#e02a2a2a"
    property color front: "#ececec"

    readonly property bool primaryOk: primaryProbe.status === Image.Ready
    readonly property bool fallbackOk: fallbackProbe.status === Image.Ready
    readonly property url active: primaryOk ? primary : (fallbackOk ? fallback : "")
    readonly property Image activeProbe: primaryOk ? primaryProbe : fallbackProbe

    Image {
        id: primaryProbe
        visible: false
        asynchronous: true
        source: avatar.primary
    }

    Image {
        id: fallbackProbe
        visible: false
        asynchronous: true
        source: avatar.fallback
    }

    onActiveChanged: {
        if (active.toString() !== "")
            loadImage(active)
        requestPaint()
    }
    onImageLoaded: requestPaint()
    onBackChanged: requestPaint()
    onFrontChanged: requestPaint()
    onIconScaleChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    Component.onCompleted: {
        if (active.toString() !== "")
            loadImage(active)
    }

    onPaint: {
        var ctx = getContext("2d")
        var w = width
        var h = height
        ctx.reset()
        ctx.beginPath()
        ctx.arc(w / 2, h / 2, w / 2, 0, Math.PI * 2)
        ctx.closePath()
        ctx.clip()
        ctx.fillStyle = back
        ctx.fillRect(0, 0, w, h)

        if (active.toString() !== "" && isImageLoaded(active) && activeProbe.implicitWidth > 0) {
            var iw = activeProbe.implicitWidth
            var ih = activeProbe.implicitHeight
            var k = primaryOk ? Math.max(w / iw, h / ih) : Math.min(w / iw, h / ih) * iconScale
            var dw = iw * k
            var dh = ih * k
            ctx.drawImage(active, (w - dw) / 2, (h - dh) / 2, dw, dh)
            return
        }

        ctx.fillStyle = front
        ctx.beginPath()
        ctx.arc(w / 2, h * 0.39, w * 0.15, 0, Math.PI * 2)
        ctx.fill()
        ctx.beginPath()
        ctx.ellipse(w * 0.25, h * 0.60, w * 0.50, h * 0.46)
        ctx.fill()
    }
}
