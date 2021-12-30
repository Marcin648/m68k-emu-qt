import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Fusion
import QtQuick.Layouts


ScrollView{
    property var address: qm68k.generation, qm68k.getRegister(16)
    property var dump: qm68k.disassembly(address)
    anchors.centerIn: parent
    TextArea {
        id: dump_text_area
        Layout.fillHeight: true
        readOnly: true
        textFormat: "RichText"
        text: "<pre style='font-size:16px;margin: 0px;'>" + dump + "</pre>"
    }

}
