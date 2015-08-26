/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../ApiAccess.js" as ApiBus


Page {
    id: page

    property bool authenticated: false
    property bool refreshTimesModel: appWindow.refreshTimes

    property string lastLinha: ""
    property string lastParada: ""

    property string currentTime: ""

    onAuthenticatedChanged:
    {
        console.log("Autenticado: " + authenticated);
        if(authenticated)
        {
        }
    }

    onRefreshTimesModelChanged:
    {
        if(refreshTimesModel)
        {
            refresh();
        }
        appWindow.refreshTimes = false;
    }

    function refresh()
    {
        linha1Model.clear()
        ApiBus.eraseColumn()
        ApiBus.getFavoriteRouteStopTimes(comboboxFavName.value);
        appWindow.favName = comboboxFavName.value
    }

    function nextFavorite()
    {
        if(comboboxFavName.currentIndex < favoritesNamesModel.count - 1)
            ++comboboxFavName.currentIndex
        else
            comboboxFavName.currentIndex = 0;
    }

    function delItem(codParada, nomeLinha, nomeFav)
    {
        var db = LocalStorage.openDatabaseSync("BusPaulo Database", "1.0", "Database for the BusPaulo app!", 1000000);

        db.transaction(
            function(tx) {
                var rs = tx.executeSql('DELETE FROM FAV_ROUTE_STOP_TIMES WHERE COD_PARADA = "' + codParada + '" AND NOME_LINHA = "' + nomeLinha + '"AND NOME_FAV = "' + nomeFav + '"');
            }
        )
    }

    function createDatabases()
    {
        var db = LocalStorage.openDatabaseSync("BusPaulo Database", "1.0", "Database for the BusPaulo app!", 1000000);

        db.transaction(
            function(tx) {
                var rs = tx.executeSql('CREATE TABLE IF NOT EXISTS FAVORITES (NAME TEXT NOT NULL UNIQUE)');
                var rs = tx.executeSql('CREATE TABLE IF NOT EXISTS FAV_ROUTE_STOP_TIMES (COD_PARADA TEXT NOT NULL, END_PARADA TEXT NOT NULL, COD_LINHA TEXT NOT NULL, NOME_LINHA TEXT NOT NULL, NOME_FAV TEXT NOT NULL, UNIQUE (COD_PARADA, END_PARADA, COD_LINHA, NOME_LINHA, NOME_FAV))');
            }
        )
    }

    property string auxStringBuscar: ""
    onAuxStringBuscarChanged: console.log("buscarLinha: " + auxStringBuscar);

    property string auxStringBuscarPrevisaoChegada: ""
    onAuxStringBuscarPrevisaoChegadaChanged:
    {
        var results = JSON.parse(auxStringBuscarPrevisaoChegada);
        //console.log(results["hr"]);
        //console.log(results["p"]["cp"]);
        //console.log(results["p"]["l"][0]["c"]);
        //console.log(results["p"]["l"][0]["vs"].length)
        //var teste = results["p"]["l"][0]["sl"]
        //if(teste == 1)
        //    console.log(results["p"]["l"][0]["lt0"])
        //else
        //    console.log(results["p"]["l"][0]["lt1"])

        if(results["p"])
            for(var i = 0; i < results["p"]["l"][0]["vs"].length; ++i)
            {
                ApiBus.createNewTime(results["p"]["l"][0]["vs"][i]["t"], results["hr"], results["p"]["cp"], results["p"]["l"][0]["c"], Theme.fontSizeMedium, "secondaryColor", 90)
            }
    }

    Component.onCompleted:
    {
        createDatabases()
        timerPush.start()
        ApiBus.getFavoriteNames();
        ApiBus.autenticar();
    }

    onStatusChanged:
    {
        if (status === PageStatus.Active) {
            ApiBus.getFavoriteNames();
        }
    }

    Timer {
        id: timerPush
        interval: 5
        onTriggered:
        {
            pageStack.pushAttached(Qt.resolvedUrl("MapPage.qml"))
            //pageStack.navigateForward()
            //pageStack.completeAnimation()
        }
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Criar novo favorito")
                onClicked:
                {
                    pageStack.push(Qt.resolvedUrl("NewFavoriteDialog.qml"));
                }
            }
            MenuItem {
                text: qsTr("Mapa")
                onClicked:
                {
                    pageStack.push(Qt.resolvedUrl("MapPage.qml"));
                }
            }
            MenuItem {
                text: qsTr("Atualizar")
                onClicked:
                {
                    refresh();
                }
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: page.width
            spacing: Theme.paddingMedium
            PageHeader {
                id: headerTitle
                title: qsTr("Favoritos")
            }

            ComboBox {
                id: comboboxFavName
                width: parent.width
                label: qsTr("Nome")
                enabled: favoritesNamesModel.count

                menu: ContextMenu {
                      Repeater {
                           model: ListModel { id: favoritesNamesModel }
                           MenuItem { text: model.name }
                      }
                 }
                onValueChanged:
                {
                    refresh()
                }
            }

            TextSwitch {
                id: autoRefreshSwitch
                text: qsTr("Atualizar Automaticamente")
            }

            Timer {
                interval: 20000
                repeat: autoRefreshSwitch.checked && Qt.application.active
                running: autoRefreshSwitch.checked
                onTriggered:
                {
                    refresh()
                }
            }

            Rectangle {
                id: rectangleData1
                color: "transparent"

                height: page.height - headerTitle.height - autoRefreshSwitch.height - comboboxFavName.height - column.spacing * 3
                anchors {
                    left: parent.left
                    right: parent.right
                }

                ListModel {
                    id: linha1Model
                }

                Component {
                    id: linha1Delegate
                    ListItem {
                        id: container
                        contentHeight: Theme.itemSizeExtraSmall //1.1 * textAltura.height //1.7 * iconImage.height // 2.5 * textAltura.height
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
                                id: textAltura;
                                text: textoDelegate;
                                font.pixelSize: tamanho;
                                font.family: Theme.fontFamily
                                anchors.verticalCenter: parent.verticalCenter
                                //anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.leftMargin: leftMargin
                                color: cor === "highlightColor" ? Theme.highlightColor : cor === "secondaryHighlightColor" ? Theme.secondaryHighlightColor : cor === "primaryColor"  ? Theme.primaryColor : cor === "secondaryColor" ? Theme.secondaryColor : "white";
                            }

                            RemorseItem { id: deleteRemorseItem }
                            function deleteRemorse() {

                                deleteRemorseItem.execute(container, qsTr("Deletando"),
                                                              function() {
                                                                  var parada = linha1Model.get(index).codigoParada
                                                                  var linh = linha1Model.get(index).linha
                                                                  var nomFav = comboboxFavName.value
                                                                  delItem(linha1Model.get(index).codigoParada, linha1Model.get(index).linha, comboboxFavName.value)
                                                                  for(var i = 0; i < linha1Model.count; ++i)
                                                                  {
                                                                      if(linha1Model.get(i).codigoParada === parada && linha1Model.get(i).linha === linh)
                                                                        linha1Model.remove(index)
                                                                  }

                                                              })
                            }

                            Component {
                                id: contextMenu

                                ContextMenu {
                                    anchors.horizontalCenter: container.horizontalCenter

                                    MenuItem {
                                        text: qsTr("Deletar")
                                        enabled: linha1Model.get(index).isErasable
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
                    id: linha1ListView
                    spacing: 8
                    anchors.fill: parent
                    anchors.margins: 4
                    clip: true
                    model: linha1Model
                    delegate: linha1Delegate
                    focus: true
                }
            }
        }
    }
}


