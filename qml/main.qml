import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Fusion
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 640
    height: 480
    visible: true
    title: qsTr("M68K-EMU")

    header: ToolBar{
        RowLayout {
            anchors.fill: parent
            Text {
                text: qsTr("M68K-EMU M68000 CPU Emulator")
            }
            ToolSeparator {}
            ToolButton {
                text: "Open ELF"
                onClicked: qm68k.test()
            }
            Item {
                Layout.fillWidth: true
            }
            ToolSeparator {}
            ToolButton {
                text: "Reset"
            }
            ToolButton {
                text: "Run"
            }
            ToolButton {
                text: "Next"
            }
        }
    }

    SplitView{
        anchors.fill: parent
        orientation: "Vertical"
        SplitView{
            SplitView.fillHeight: true
            orientation: "Horizontal"
            DisassemblerView {
                SplitView.fillWidth: true
            }

            RegisterView  {
                implicitWidth: parent.width * 0.3
            }
        }

        MemoryView {
            implicitHeight: parent.height * 0.3
        }
    }

    Timer {
        id: timer
        interval: 2000

        onTriggered: Qt.quit()
    }
}
