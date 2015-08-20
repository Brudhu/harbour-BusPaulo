import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../ApiAccess.js" as ApiBus

Dialog {
    id: root

    property string codDaParada: ""
    property string endDaParada: ""
    property string codDaLinha: ""
    property string nomeDaLinha: ""

    property var codigosLinha: []

    property string auxStringBuscar: ""
    onAuxStringBuscarChanged:
    {
        var results = JSON.parse(auxStringBuscar);
        for(var i = 0; i < results.length; ++i)
        {
            codigosLinha[i] = results[i].CodigoLinha
            codDaLinha = codigosLinha[i];
        }
    }

    onNomeDaLinhaChanged:
    {
    }

    canAccept: codDaLinha.length

    onAccepted:
    {
        for(var i = 0; i < codigosLinha.length; ++i)
            insertNewFav(codDaParada, endDaParada, codigosLinha[i], nomeDaLinha, comboboxFavName.value)
    }

    Component.onCompleted:
    {
        ApiBus.buscarLinha(nomeDaLinha)
        ApiBus.getFavoriteNames();
    }

    function insertNewFav(codParada, endParada, codLinha, nomeLinha, nomeFav)
    {
        var db = LocalStorage.openDatabaseSync("BusPaulo Database", "1.0", "Database for the BusPaulo app!", 1000000);

        db.transaction(
            function(tx) {
                var rs = tx.executeSql('INSERT INTO FAV_ROUTE_STOP_TIMES VALUES ("' + codParada + '", "' + endParada + '", "' + codLinha + '", "' + nomeLinha + '", "' + nomeFav + '")');
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
                title: qsTr("Add Favorite")
            }

            ComboBox {
                id: comboboxFavName
                width: parent.width
                label: qsTr("Nome")

                menu: ContextMenu {
                      Repeater {
                           model: ListModel { id: favoritesNamesModel }
                           MenuItem { text: model.name }
                      }
                 }
                onValueChanged:
                {
                }
            }

        }
    }
}
