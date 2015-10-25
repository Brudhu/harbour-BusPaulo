import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../ApiAccess.js" as ApiBus

Page {
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

    Component.onCompleted:
    {
        ApiBus.buscarLinha(nomeDaLinha)
        ApiBus.getFavoriteNames();
    }

    function delFav(nomeFavorito)
    {
        var db = LocalStorage.openDatabaseSync("BusPaulo Database", "1.0", "Database for the BusPaulo app!", 1000000);

        db.transaction(
            function(tx) {
                var rs = tx.executeSql('delete from fav_route_stop_times where NOME_FAV = "' + nomeFavorito + '"');
                rs = tx.executeSql('delete from favorites where NAME = "' + nomeFavorito + '"');
            }
        )
    }

    function insertNewFav(nomeFavorito)
    {
        var db = LocalStorage.openDatabaseSync("BusPaulo Database", "1.0", "Database for the BusPaulo app!", 1000000);

        db.transaction(
            function(tx) {
                var rs = tx.executeSql('insert into favorites values ("' + nomeFavorito + '")');
                ApiBus.getFavoriteNames();
            }
        )
    }

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: column.height

        Column
        {
            id: column
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.paddingSmall

            PageHeader {
                id: headerTitle
                title: qsTr("Manage Favorites")
            }

            TextField {
                id: textFieldNewFavorite
                label: qsTr("Favorite Name")
                text: ""
                maximumLength: 12
                width: parent.width * 0.8
                placeholderText: label
            }

            Button {
                text: qsTr("Add New Favorite")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked:
                {
                    insertNewFav(textFieldNewFavorite.text)
                }
            }
        }

        ListModel {
            id: favoritesNamesModel
        }
        Component {
            id: favoritesDelegate
            ListItem {
                id: container
                contentHeight: Theme.itemSizeSmall
                width: ListView.view.width;
                menu: contextMenu

                Rectangle {
                    id: containerRectangle
                    color: "transparent"
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.paddingSmall
                        rightMargin: Theme.paddingSmall
                    }

                    Text {
                        id: favoriteText
                        text: name
                        horizontalAlignment: Text.AlignHCenter
                        //height: Theme.itemSizeSmall
                        width: parent.width
                        font.pixelSize: Theme.fontSizeMedium
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        color: container.highlighted ? Theme.highlightColor : Theme.primaryColor;
                    }


                    /*function deleteRemorse() {
                        remorseAction(qsTr("Delete", "Delete item"),
                        function() {
                            if(favoritesModel.get(index).favorite !== "Other")
                                delfavorite(favoritesModel.get(index).favorite)
                        })
                    }*/

                    RemorseItem { id: deleteRemorseItem }
                    function deleteRemorse() {

                        deleteRemorseItem.execute(container, qsTr("Excluindo"),
                                                      function() {
                                                          delFav(favoritesNamesModel.get(index).name)
                                                          favoritesNamesModel.remove(index)
                                                      })
                    }

                    Component {
                        id: contextMenu
                        ContextMenu {
                            anchors.horizontalCenter: container.horizontalCenter
                            /*MenuItem {
                                text: qsTr("Edit")
                                onClicked: {
                                    //var dialog = pageStack.push("EditfavoriteDialog.qml", {"oldfavorite": favoritesNamesModel.get(index).favorite})
                                }
                            }*/
                            MenuItem {
                                text: qsTr("Delete")
                                onClicked: {
                                    containerRectangle.deleteRemorse()
                                }
                            }
                        }
                    }
                }
            }
        }
        SilicaListView {
            id: favoritesListView
            height: favoritesNamesModel.count * Theme.itemSizeSmall
            anchors.top: column.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            clip: true
            model: favoritesNamesModel
            delegate: favoritesDelegate
            focus: true
            //Behavior on height { PropertyAnimation { easing.type: Easing.InOutCubic; duration: 250; } }
        }
    }
}

