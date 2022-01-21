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
                icon.source: "qrc:/m68k_emu_qt/res/icon_load.png"
                onClicked: file_dialog.open()
            }
            Item {
                Layout.fillWidth: true
            }
            ToolSeparator {}
            ToolButton {
                text: "Reset"
                icon.source: "qrc:/m68k_emu_qt/res/icon_reset.png"
                onClicked: qm68k.reset()
            }
            ToolButton {
                text: qm68k.isRun ? "Pause" : "Run"
                icon.source: qm68k.isRun ? "qrc:/m68k_emu_qt/res/icon_pause.png" : "qrc:/m68k_emu_qt/res/icon_run.png"
                
                onClicked: qm68k.run()
            }
            ToolButton {
                text: "Step"
                icon.source: "qrc:/m68k_emu_qt/res/icon_step.png"
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
        interval: 100
        running: qm68k.isRun
        repeat: true
        onTriggered: qm68k.generation++
    }
}
