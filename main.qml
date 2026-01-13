import QtQuick 2.15
import QtQuick.Window 2.15
import QtWebSockets
import QtQuick.Controls.Material

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: qsTr("WebSocketClient")

    property var textButton: ["Start", "Stop"]
    property bool autoReconnect: true
    property int reconnectInterval: 3000
    property bool connecting: false

    WebSocket {
        id: socket
        // url: "ws://localhost:12345"
        url: "ws://192.9.192.229:12345"

        onTextMessageReceived: function(message) {
            addMessage("Received: " + message)
        }

        onStatusChanged: {
            switch(socket.status) {
                case WebSocket.Error:
                    if (connecting === false) addMessage(socket.errorString)
                    scheduleReconnect()
                    break

                case WebSocket.Closed:
                    scheduleReconnect()
                    break

                case WebSocket.Open:
                    connecting = false
                    addMessage("Connected")
                    break

                case WebSocket.Connecting:
                    connecting = true
                    break
            }
        }

        active: true
    }

    Timer {
        id: reconnectTimer
        interval: reconnectInterval
        repeat: false
        onTriggered: {
            socket.active = false
            if (autoReconnect && socket.status !== WebSocket.Open) {
                var currentTime = new Date()
                addMessage("Connecting..." + Qt.formatDateTime(currentTime, "hh:mm:ss"))
                socket.active = true
            }
        }
    }

    function addMessage(message) {
        messageBox.text = messageBox.text + "\n" + message
    }

    function scheduleReconnect() {
        if (autoReconnect && socket.status !== WebSocket.Open) {
            console.log("Scheduling reconnect in", reconnectInterval, "ms")
            reconnectTimer.restart()
        }
    }

    Text {
        id: messageBox
        text: qsTr("Connecting...")
        anchors.centerIn: parent
        anchors.rightMargin: 20
    }

    onClosing: {
        autoReconnect = false
        socket.active = false
    }
}





// import QtQuick 2.15
// import QtQuick.Window 2.15
// import QtWebSockets
// import QtQuick.Controls.Material

// Window {
//     width: 640
//     height: 480
//     visible: true
//     title: qsTr("WebSocket")
//     property var textButton: ["Start", "Stop"]

//     WebSocket {
//         id: socket
//         url: "ws://192.9.192.229:12345"
//         onTextMessageReceived: function(message) {
//             messageBox.text = messageBox.text + "\nReceived message: " + message
//         }
//         onStatusChanged: if (socket.status == WebSocket.Error) {
//                              console.log("Error: " + socket.errorString)
//                              // active: false
//                          } else if (socket.status == WebSocket.Open) {
//                              socket.sendTextMessage("Hello World")
//                          } else if (socket.status == WebSocket.Closed) {
//                              messageBox.text += "\nSocket closed"
//                          }
//         active: false
//     }

//     Text {
//         id: messageBox
//         text: socket.status == WebSocket.Open ? qsTr("Sending...") : qsTr("Welcome!")
//         anchors.verticalCenter: parent.verticalCenter
//         anchors.right: parent.right
//         anchors.rightMargin: 20
//     }

//     Button {
//         anchors.verticalCenter: parent.verticalCenter
//         anchors.left: parent.left
//         anchors.leftMargin: 20
//         width: parent.width * .4
//         height: parent.height * .4
//         text: socket.active ? textButton[1] : textButton[0]
//         font.pixelSize: 20

//         onClicked: {
//             socket.active = !socket.active
//             console.log(socket.active ? textButton[0] : textButton[1])
//         }
//     }
// }
