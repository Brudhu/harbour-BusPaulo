import QtQuick 2.0
import Sailfish.Silica 1.0
import QtLocation 5.0
import QtPositioning 5.0
import "../ApiAccess.js" as ApiBus

Page {
    id: page
    backNavigation: headerTitle.show

    property string codDaLinha: ""
    property string nomeDaLinha: ""
    property string stopId: ""
    property real stop_lat: 0
    property real stop_lon: 0
    property int sentido: 0

    property real zoomLevelStandard: 15

    property var codigosLinha: []

    property string auxStringBuscar: ""
    onAuxStringBuscarChanged:
    {
        if(auxStringBuscar)
        {
            var results = JSON.parse(auxStringBuscar);
            for(var i = 0; i < results.length; ++i)
            {
                if(results[i]["Sentido"] == sentido)
                {
                    codigosLinha[i] = results[i].CodigoLinha
                    codDaLinha = codigosLinha[i];
                    ApiBus.buscarPosicaoVeiculos(codigosLinha[i])
                }
            }
        }
        /*for(i = 0; i < codigosLinha.length; ++i)
            ApiBus.buscarPosicaoVeiculos(codigosLinha[i])*/
    }

    property string stringBuscarPosicoes: ""
    onStringBuscarPosicoesChanged:
    {
        //console.log(stringBuscarPosicoes)
        var results = JSON.parse(stringBuscarPosicoes);
        //console.log(results)
        map.clearMapItems()
        map.updatePosition()
        addStop()
        for(var i = 0; i < results["vs"].length; ++i)
        {
            //console.log(results["vs"][i]["py"])
            //console.log(results["vs"][i]["px"])
            var bus = Qt.createQmlObject('import Sailfish.Silica 1.0; import QtQuick 2.0; import QtLocation 5.0; MapQuickItem{zoomLevel: 0; anchorPoint.x: rectangleStop.width / 2; anchorPoint.y: rectangleStop.height / 2; sourceItem: Rectangle { id: rectangleStop; opacity: 1;width: 40;height: width; color: "transparent"; Image{anchors.fill: parent; fillMode: Image.PreserveAspectFit; source: "qrc:/images/bus.png";}}}', map);

            bus.coordinate.latitude = parseFloat(results["vs"][i]["py"]) + parseFloat(0.000265); // ajuste para ficar certo no MapPage
            bus.coordinate.longitude = parseFloat(results["vs"][i]["px"]) - parseFloat(0.000140); // ajuste para ficar certo no mapa
            map.addMapItem(bus);
        }
    }

    Component.onCompleted:
    {
        addStop()
        ApiBus.autenticar()
        ApiBus.buscarLinha(nomeDaLinha)
    }

    function addStop()
    {
        var stop = Qt.createQmlObject('import Sailfish.Silica 1.0; import QtQuick 2.0; import QtLocation 5.0; MapQuickItem{zoomLevel: 0; anchorPoint.x: rectangleStop.width / 2; anchorPoint.y: rectangleStop.height; sourceItem: Rectangle { id: rectangleStop; opacity: 1;width: 60;height: width; color: "transparent"; Image{anchors.fill: parent; fillMode: Image.PreserveAspectFit; source: "qrc:/images/harbour-BusPaulo.png";}}}', map);

        stop.coordinate.latitude = parseFloat(stop_lat) - parseFloat(0.00002); // ajuste para ficar certo no MapPage
        stop.coordinate.longitude = parseFloat(stop_lon)// - parseFloat(0.000140); // ajuste para ficar certo no mapa
        map.addMapItem(stop);
    }

    /*Button {
        y: 20
        text: "Voltar"
        onClicked:
        {
            pageStack.pop();
        }
    }*/

    Column {
        id: column

        width: page.width
        spacing: 0//Theme.paddingSmall

        PageHeader {
            id: headerTitle
            title: nomeDaLinha

            property bool show: true
            height: show ? page && page.isLandscape ? Theme.itemSizeSmall : Theme.itemSizeLarge : 0
            Behavior on height { PropertyAnimation { easing.type: Easing.InOutQuad; duration: 300; } }
        }

        PositionSource
        {
            id: src
            updateInterval: 1000
            active: Qt.application.active

            property var coord;
            onPositionChanged: {
                coord = src.position.coordinate;
                //console.log("Coordinate: ", coord.latitude, coord.longitude);
                //console.log("Coordinate: ", coord);
                map.updatePosition();
                if(map.followCurrentPosition)
                {
                    map.zoomLevel = zoomLevelStandard
                    map.center = map.circle.coordinate;
                    console.log("AQUI PORRA positionsource")
                }
            }
        }

        Map {
            id: map
            property MapQuickItem circle
            property bool followCurrentPosition: false
            onFollowCurrentPositionChanged:
            {
                if(followCurrentPosition)
                {
                    console.log("AQUI PORRA followcurrentposition")
                    map.zoomLevel = zoomLevelStandard
                    map.center = map.circle.coordinate;
                }
            }

            center.latitude: stop_lat
            center.longitude: stop_lon

            Plugin {
                id: somePlugin
                preferred: ["here", "osm"]
            }

            anchors.left: parent.left
            anchors.right: parent.right
            height: page.height - headerTitle.height

            plugin: somePlugin

            Behavior on center { PropertyAnimation { easing.type: Easing.InOutCubic; duration: 400; } }
            Behavior on zoomLevel { PropertyAnimation { easing.type: Easing.InOutCubic; duration: 400; } }

            /*Timer {
                id: updatePositions
                property real lastCenterLatTimer: 0
                property real lastCenterLonTimer: 0
                interval: 5000
                repeat: true
                running: Qt.application.active
                onTriggered:
                {
                    rect.width = rect.parent.width
                    animation.restart()
                    auxStringBuscar = "";
                    ApiBus.buscarLinha(nomeDaLinha)
                }
            }*/

            gesture.enabled: !headerTitle.show

            gesture.onFlickStarted:
            {
                followCurrentPosition = false
            }
            gesture.onPanStarted:
            {
                followCurrentPosition = false
            }
            gesture.onPinchStarted:
            {
                followCurrentPosition = false
            }

            Component.onCompleted: {
                circle = Qt.createQmlObject('import Sailfish.Silica 1.0; import QtQuick 2.0; import QtLocation 5.0; MapQuickItem{zoomLevel: 0; sourceItem: Rectangle {opacity: 0.9;width: 30;height: 30;radius: 15;color: Theme.highlightColor;border.width: 2; border.color: Theme.secondaryHighlightColor}}', map)
                updatePosition();
                zoomLevel = zoomLevelStandard
                //console.log(center.latitude)
                center.latitude = stop_lat
                //console.log(center.latitude)
                //console.log(stop_lat)
                /*var center = src.position.coordinate;
                center.latitude = stop_lat
                center.longitude = stop_lon
                console.log(stop_lat + " " + stop_lon)
                console.log(center.latitude + " " + center.longitude)
                map.center = center;
                console.log(map.center.latitude + " " + map.center.longitude)*/
            }

            MapMouseArea {
                anchors.fill: parent

                onPressAndHold: {
                }

                onClicked: {
                    headerTitle.show = !headerTitle.show
                }

                onDoubleClicked: {
                }
            }

            function updatePosition() {

                //circle.center = src.position.coordinate
                //circle.radius = 12.0
                //circle.color = 'green'
                //circle.border.width = 2
                circle.coordinate = src.position.coordinate;
                map.addMapItem(circle)
            }
        }
    }

    Rectangle
    {
        property bool pressedColor: centralizarButtonMouseArea.pressed
        anchors.right: parent.right
        anchors.rightMargin: 25
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 25
        width: 100
        height: width
        radius: 10
        color: "white"
        opacity: 0.75

        Rectangle
        {
            anchors.fill: parent
            anchors.margins: 10
            radius: 10
            color: parent.pressedColor ? Theme.highlightColor : "white"
            Behavior on color { PropertyAnimation { easing.type: Easing.InOutCubic; duration: 50; } }
            opacity: 0.95
        }

        Rectangle {
            anchors.centerIn: parent
            opacity: 0.9;
            width: parent.width / 2;
            height: width;
            radius: width / 2;
            color: Theme.highlightColor;
            border.width: 2;
            border.color: Theme.secondaryHighlightColor
        }

        Rectangle {
            anchors.centerIn: parent
            opacity: map.followCurrentPosition ? 0.5 : 0
            Behavior on opacity { PropertyAnimation { easing.type: Easing.InOutCubic; duration: 150; } }
            width: 2
            height: parent.height * 3 / 4
            color: "black"
        }

        Rectangle {
            anchors.centerIn: parent
            opacity: map.followCurrentPosition ? 0.5 : 0
            Behavior on opacity { PropertyAnimation { easing.type: Easing.InOutCubic; duration: 150; } }
            height: 2
            width: parent.height * 3 / 4
            color: "black"
        }

        MouseArea {
            id: centralizarButtonMouseArea
            anchors.fill: parent
            onClicked:
            {
                map.followCurrentPosition = !map.followCurrentPosition
            }
        }
    }

    Rectangle
    {
        id: rect
        width: parent.width
        height: Theme.paddingSmall / 2 + 4
        color: Theme.highlightColor
        anchors.top: parent.top
        anchors.topMargin: -2
        anchors.left: parent.left

        border.color: "black"
        border.width: 2

        SequentialAnimation {
            id: animation
            running: Qt.application.active
            NumberAnimation { target: rect; property: "width"; to: 0; duration: 7500 }//updatePositions.interval }
            onRunningChanged:
            {
                if(!running && Qt.application.active)
                {
                    rect.width = rect.parent.width
                    animation.restart()
                    auxStringBuscar = "";
                    ApiBus.buscarLinha(nomeDaLinha)
                }
            }
        }
    }
}
