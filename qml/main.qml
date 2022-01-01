import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Fusion
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt.labs.platform

ApplicationWindow {
    id: root
    width: 800
    height: 600
    visible: true
    title: qsTr("M68K-EMU")

    FileDialog {
        id: file_dialog
        fileMode: FileDialog.OpenFile
        title: "Open M68K ELF file"
        onAccepted: {
            console.log(file_dialog.currentFile)
            if(!qm68k.loadELF(file_dialog.currentFile)){
                console.log("Invalid ELF file")
            }
        }
    }

    header: ToolBar{
        RowLayout {
            anchors.fill: parent
            Text {
                text: qsTr("M68K-EMU M68000 CPU Emulator")
            }
            ToolSeparator {}
            ToolButton {
                text: "Open ELF"
                onClicked: file_dialog.open()
            }
            Item {
                Layout.fillWidth: true
            }
            ToolSeparator {}
            ToolButton {
                text: "Reset"
                onClicked: memory_view.address = 0xfffff0
            }
            ToolButton {
                text: qm68k.isRun ? "PAUSE" : "RUN"
                onClicked: qm68k.run()
            }
            ToolButton {
                text: "Next"
                onClicked: qm68k.step()
            }
        }
    }

    SplitView{
        anchors.fill: parent
        orientation: "Vertical"

        SplitView{
            SplitView.fillHeight: true
            orientation: "Horizontal"
            ScrollView{
                SplitView.fillWidth: true
                DisassemblerView {
                    anchors.fill: parent
                    id: disassembler_view
                }
            }

            ScrollView{
                implicitWidth: parent.width * 0.26
                RegisterView  {
                    anchors.fill: parent
                    id: register_view
                }
            }


        }

        MemoryView {
            id: memory_view
            implicitHeight: parent.height * 0.35
        }
    }

    Timer {
        id: qm68k_timer
        interval: 500
        running: qm68k.isRun

        onTriggered: qm68k.generation++
    }
}
