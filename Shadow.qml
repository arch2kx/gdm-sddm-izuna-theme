import QtQuick
import QtQuick.Effects

MultiEffect {
    property Item target: null
    source: target
    autoPaddingEnabled: true
    blurMax: 100
    shadowEnabled: true
    shadowColor: "#000000"
    shadowOpacity: 0.8
    shadowBlur: 0.2
    shadowHorizontalOffset: 0
    shadowVerticalOffset: 0
}
