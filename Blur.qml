import QtQuick
import QtQuick.Effects

MultiEffect {
    property Item target: null
    anchors.fill: parent
    source: target
    autoPaddingEnabled: false
    blurEnabled: true
    blurMax: 64
    blur: 1.0
}
