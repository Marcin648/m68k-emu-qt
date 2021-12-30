import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Fusion
import QtQuick.Layouts

ColumnLayout{
    property int address: 0
    property var dump: qm68k.generation, qm68k.memoryDump(((address >> 4) << 4), Math.floor(Math.max(dump_text_area.height-10, 0)/18)*16)

    TextArea {
        id: dump_text_area
        Layout.fillHeight: true
        readOnly: true
        textFormat: "RichText"
        text: "<pre style='font-size:16px;margin: 0px;'>" + dump + "</pre>"
    }
    RowLayout{
        ToolButton{
            text: "<"
            onClicked: address = Math.max(address - 16, 0)
        }
        TextField{
            text: address.toString(16).toUpperCase()
            onTextChanged: {
                let value = Math.min(Math.max(parseInt(this.text, 16), 0), 0xFFFFFF)
                if(!isNaN(value)){
                    address = value
                }
            }

        }
        ToolButton{
            text: ">"
            onClicked: address = Math.min(address + 16, 0xFFFFFF)
        }
        ToolSeparator{

        }
        Repeater {
            model: 8
            ToolButton{
                text: "A" + index.toString()
                onClicked: address = Math.min(Math.max(qm68k.getRegister(8+index), 0), 0xFFFFFF)
            }
        }
        ToolButton{
            text: "USP"
            onClicked: address = Math.min(Math.max(qm68k.getRegister(15), 0), 0xFFFFFF)
        }
        ToolButton{
            text: "PC"
            onClicked: address = Math.min(Math.max(qm68k.getRegister(16), 0), 0xFFFFFF)
        }
        Item {
            Layout.fillWidth: true
        }
    }
}


