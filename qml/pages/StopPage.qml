import QtQuick 2.0
import Sailfish.Silica 1.0
import QtLocation 5.0
import QtPositioning 5.0
import "../ApiAccess.js" as ApiBus

Page {
    id: page

    property string stop_id: ""
    property string stop_name: ""
    property string stop_desc: ""
    property real stop_lat: 0
    property real stop_lon: 0

    property string auxStringBuscarPrevisaoChegada: ""

    onAuxStringBuscarPrevisaoChegadaChanged:
    {
        var results = JSON.parse(auxStringBuscarPrevisaoChegada);

        console.log(results)

        if(results["p"])
            for(var j = 0; j < results["p"]["l"].length; ++j)
                for(var i = 0; i < results["p"]["l"][j]["vs"].length; ++i)
                {
                    ApiBus.createNewTimeStopPage(results["p"]["l"][j]["vs"][i]["t"], results["hr"], results["p"]["cp"], results["p"]["l"][j]["c"], Theme.fontSizeMedium, "secondaryColor", 50)
                }
    }

    function getRoutes(stopId)
    {
        stop1Model.clear();

        var rs = saoPauloDB.returnRoutesInStop(stopId)

        for (var i = 0; i < rs.length; ++i)
        {
            var sentido = parseInt(rs[i].substring(8, rs[i].indexOf(';'))) + 1
            var trip_id = rs[i].substring(0, rs[i].indexOf(';'))
            rs[i] = rs[i].substring(rs[i].indexOf(';') + 1, rs[i].length);
            var arrival_time = rs[i].substring(0, rs[i].indexOf(';'))
            rs[i] = rs[i].substring(rs[i].indexOf(';') + 1, rs[i].length);
            var departure_time = rs[i].substring(0, rs[i].indexOf(';'))
            rs[i] = rs[i].substring(rs[i].indexOf(';') + 1, rs[i].length);
            var stop_sequence = rs[i]
            //console.log(sentido);

            stop1Model.insert(stop1Model.count, {"textoDelegate":trip_id.substring(0, trip_id.length - 2), "codigoParada":stopId, "linha":trip_id.substring(0, trip_id.length - 2), "sentido":sentido, "tamanho":Theme.fontSizeMedium, "cor":"highlightColor", "leftMargin": Theme.paddingLarge, "isTime":false})

        }
        ApiBus.buscarPrevisaoChegadaPorParada(stopId)
    }

    SilicaFlickable {
        id: silicaFlickable
        anchors.fill: parent

        contentHeight: column.height + stop1ListView.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Atualizar")
                onClicked:
                {
                    getRoutes(stop_id);
                }
            }
        }
        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.

        Column {
            id: column

            width: page.width
            spacing: 0//Theme.paddingSmall

            PageHeader {
                id: headerTitle
                title: stop_name
            }

            Map {
                id: map
                property MapQuickItem circle

                Plugin {
                    id: somePlugin
                    preferred: ["here", "osm"]
                }

                width: parent.width
                height: page.height * 5 / 16
                plugin: somePlugin

                Component.onCompleted: {
                    circle = Qt.createQmlObject('import Sailfish.Silica 1.0; import QtQuick 2.0; import QtLocation 5.0; MapQuickItem{zoomLevel: 0; sourceItem: Rectangle { opacity: 1;width: 60;height: width; color: "transparent"; Image{anchors.fill: parent; fillMode: Image.PreserveAspectFit; source: "qrc:/images/harbour-BusPaulo.png"; /*anchors.centerIn: parent;*/}}}', map);
                    zoomLevel = 18;
                    circle.coordinate.latitude = parseFloat(stop_lat) + parseFloat(0.000265); // ajuste para ficar certo no MapPage
                    circle.coordinate.longitude = parseFloat(stop_lon) - parseFloat(0.000140); // ajuste para ficar certo no mapa
                    map.center.latitude = parseFloat(stop_lat)// + parseFloat(0.000265);
                    map.center.longitude = parseFloat(stop_lon)// - parseFloat(0.000140);
                    map.addMapItem(circle);

                    getRoutes(stop_id);
                }

                gesture.enabled: false
            }

            Label {
                text: "Linhas";
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge

                color: Theme.primaryColor
                font.family: Theme.fontFamilyHeading
                font.pixelSize: Theme.fontSizeLarge
            }
        }

        Rectangle {
            id: rectangleData1
            color: "transparent"

            anchors {
                top: column.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            ListModel {
                id: stop1Model
            }

            Component {
                id: stop1Delegate
                ListItem {
                    id: container
                    contentHeight: 1.1 * textAltura.height //1.7 * iconImage.height // 2.5 * textAltura.height
                    width: ListView.view.width;
                    menu: contextMenu

                    property bool canBeFavorited: !isTime

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
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.leftMargin: leftMargin
                            color: cor === "highlightColor" ? Theme.highlightColor : cor === "secondaryHighlightColor" ? Theme.secondaryHighlightColor : cor === "primaryColor"  ? Theme.primaryColor : cor === "secondaryColor" ? Theme.secondaryColor : "white";
                        }

                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked:
                            {
                                console.log(stop_lat + " " + stop_lon)
                                pageStack.push(Qt.resolvedUrl("BusesInMap.qml"), {"nomeDaLinha":stop1Model.get(index).textoDelegate, "stopId":stop_id, "sentido":stop1Model.get(index).sentido, "stop_lat":stop_lat, "stop_lon":stop_lon})
                            }
                        }

                        Component {
                            id: contextMenu

                            ContextMenu {
                                anchors.horizontalCenter: container.horizontalCenter

                                MenuItem {
                                    text: qsTr("Adicionar aos Favoritos")
                                    enabled: !stop1Model.get(index).isTime
                                    onClicked: {
                                        pageStack.push(Qt.resolvedUrl("AddToFavoriteDialog.qml"), {"codDaParada": stop_id, "endDaParada": stop_name, "codDaLinha":"", "nomeDaLinha": stop1Model.get(index).textoDelegate});
                                    }
                                }
                            }
                        }
                    }
                }
            }

            SilicaListView {
                id: stop1ListView
                spacing: 8
                anchors.fill: parent
                anchors.margins: 4
                clip: true
                model: stop1Model
                delegate: stop1Delegate
                focus: true
            }
        }
    }

}
