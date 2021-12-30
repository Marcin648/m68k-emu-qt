import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Fusion
import QtQuick.Layouts

ColumnLayout {
//    function update(){
//        for(let i = 0; i < 8; i++){
//            data_registers.children[i].reg_value = qm68k.getRegister(i)
//        }
//        for(let i = 0; i < 8; i++){
//            address_registers.children[i].reg_value = qm68k.getRegister(i+8)
//        }

//        address_registers.children[9].reg_value = qm68k.getRegister(15)
//        address_registers.children[10].reg_value = qm68k.getRegister(16)

//        for(let i = 0; i < 5; i++){
//            flags_register.children[i].flag_value = qm68k.getFlag(flags_register.children[i].flag_shift) ? 1 : 0
//        }
//    }

    RowLayout{
        ColumnLayout{
            id: data_registers
            Repeater {
                model: 8
                RowLayout{
                    property var reg_value: qm68k.generation, qm68k.getRegister(index)
                    Label {
                        text: "D" + index.toString()
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    TextField{
                        text: parent.reg_value.toString(16).toUpperCase()
                        implicitWidth: 70
                        onTextEdited: {
                            let value = Math.min(Math.max(parseInt(this.text, 16), 0), 0xFFFFFFFF)
                            if(!isNaN(value)){
                                qm68k.setRegister(index, value)
                            }
                        }
                    }
                }
            }
            Item {
                Layout.fillHeight: true
            }
        }

        ColumnLayout{
            id: address_registers
            Repeater {
                model: 8
                RowLayout{
                    property var reg_value: qm68k.generation, qm68k.getRegister(8+index)
                    Label {
                        text: "A" + index.toString()
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    TextField{
                        text: parent.reg_value.toString(16).toUpperCase()
                        implicitWidth: 70
                        onTextEdited: {
                            let value = Math.min(Math.max(parseInt(this.text, 16), 0), 0xFFFFFFFF)
                            if(!isNaN(value)){
                                qm68k.setRegister(8+index, value)
                            }
                        }
                    }
                }
            }
            RowLayout{
                property var reg_value: qm68k.generation, qm68k.getRegister(15)
                Label {
                    text: "USP"
                }
                Item {
                    Layout.fillWidth: true
                }
                TextField{
                    text: parent.reg_value.toString(16).toUpperCase()
                    implicitWidth: 70
                    onTextEdited: {
                        let value = Math.min(Math.max(parseInt(this.text, 16), 0), 0xFFFFFFFF)
                        if(!isNaN(value)){
                            qm68k.setRegister(15, value)
                        }
                    }
                }
            }
            RowLayout{
                property var reg_value: qm68k.generation, qm68k.getRegister(16)
                Label {
                    text: "PC"
                }
                Item {
                    Layout.fillWidth: true
                }
                TextField{
                    text: parent.reg_value.toString(16).toUpperCase()
                    implicitWidth: 70
                    onTextEdited: {
                        let value = Math.min(Math.max(parseInt(this.text, 16), 0), 0xFFFFFFFF)
                        if(!isNaN(value)){
                            qm68k.setRegister(16, value)
                        }
                    }
                }
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }

    RowLayout{
        id: flags_register
        Layout.alignment: "AlignHCenter"
        property var flags: [
            {name: "X", shift: 16},
            {name: "N", shift: 8},
            {name: "Z", shift: 4},
            {name: "O", shift: 2},
            {name: "C", shift: 1}
        ]

        Repeater{
            model: 5
            RowLayout{
                property int flag_value: qm68k.generation, qm68k.getFlag(flags_register.flags[index].shift) ? 1 : 0
                Label {
                    text: flags_register.flags[index].name
                }
                TextField{
                    text: parent.flag_value
                    implicitWidth: 20
                    onTextEdited: {
                        let value = parseInt(this.text)
                        if(!isNaN(value)){
                            qm68k.setFlag(flags_register.flags[index].shift, (value === 0 ? 0 : 1))
                        }
                    }
                }
            }
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
