import QtQuick 2.15

Canvas {
    id: icon
    property string kind: "gear"
    property color tint: "white"

    onKindChanged: requestPaint()
    onTintChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        var w = width
        var h = height
        ctx.reset()
        ctx.strokeStyle = tint
        ctx.fillStyle = tint
        ctx.lineCap = "round"
        ctx.lineJoin = "round"

        if (kind === "gear") {
            ctx.translate(w / 2, h / 2)
            for (var i = 0; i < 8; i++) {
                ctx.save()
                ctx.rotate(i * Math.PI / 4)
                ctx.fillRect(-w * 0.07, -h * 0.47, w * 0.14, h * 0.17)
                ctx.restore()
            }
            ctx.lineWidth = w * 0.14
            ctx.beginPath()
            ctx.arc(0, 0, w * 0.29, 0, Math.PI * 2)
            ctx.stroke()
        } else if (kind === "power") {
            var cx = w / 2
            var cy = h / 2
            var r = w * 0.32
            ctx.lineWidth = w * 0.1
            ctx.beginPath()
            ctx.arc(cx, cy, r, -Math.PI / 2 + 0.6, -Math.PI / 2 - 0.6 + Math.PI * 2)
            ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(cx, cy - r * 1.15)
            ctx.lineTo(cx, cy)
            ctx.stroke()
        } else {
            ctx.lineWidth = w * 0.09
            ctx.beginPath()
            ctx.moveTo(w * 0.04, h / 2)
            ctx.quadraticCurveTo(w / 2, h * -0.15, w * 0.96, h / 2)
            ctx.quadraticCurveTo(w / 2, h * 1.15, w * 0.04, h / 2)
            ctx.stroke()
            ctx.beginPath()
            ctx.arc(w / 2, h / 2, w * 0.13, 0, Math.PI * 2)
            ctx.fill()
            if (kind === "eyeoff") {
                ctx.beginPath()
                ctx.moveTo(w * 0.15, h * 0.88)
                ctx.lineTo(w * 0.85, h * 0.12)
                ctx.stroke()
            }
        }
    }
}
