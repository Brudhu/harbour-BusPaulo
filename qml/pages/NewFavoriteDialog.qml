import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../ApiAccess.js" as ApiBus

Dialog {
    id: root

    canAccept: textInputName.text.length
    onAccepted:
    {
        insertNewFavName(textInputName.text)
    }

    function insertNewFavName(name)
    {
        var db = LocalStorage.openDatabaseSync("BusPaulo Database", "1.0", "Database for the BusPaulo app!", 1000000);

        db.transaction(
            function(tx) {
                var rs = tx.executeSql('INSERT INTO FAVORITES VALUES ("' + name + '")');
            }
        )
    }

    SilicaFlickable {
        id: header
        anchors.fill: parent
        contentHeight: column.height
        Column
        {
            id: column
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            PageHeader {
                id: headerTitle
                title: qsTr("Add")
            }
            TextField {
                id: textInputName
                width: 0.75 * parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: TextInput.AlignHCenter
                label: qsTr("Nome do novo favorito")
                placeholderText: qsTr("Nome do novo favorito")
                maximumLength: 26
                font.pixelSize: Theme.fontSizeMedium;
            }
        }
    }
}
