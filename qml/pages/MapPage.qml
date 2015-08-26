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
import QtLocation 5.0
import QtQuick.LocalStorage 2.0
import QtPositioning 5.0


Page {
    id: root
    backNavigation: headerTitle.show

    property real distanceToLook: 0.003
    property real zoomLevelStandard: 18

    /*Image {
        height: 50
        width: 50
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
        source: "qrc:/images/harbour-BusPaulo.png"
    }*/
    function lookForStops(latLow, latHigh, lonLow, lonHigh)
    {
        //var db = LocalStorage.openDatabaseSync("BusPaulo Database", "1.0", "Database for the BusPaulo app!", 1000000);

        map.clearMapItems();
        map.updatePosition();

        var rs = saoPauloDB.returnNearStops(latLow, latHigh, lonLow, lonHigh);

        for (var i = 0; i < rs.length; ++i)
        {
            var stop_id = rs[i].substring(0, rs[i].indexOf(';'))
            rs[i] = rs[i].substring(rs[i].indexOf(';') + 1, rs[i].length);
            var stop_name = rs[i].substring(0, rs[i].indexOf(';'))
            rs[i] = rs[i].substring(rs[i].indexOf(';') + 1, rs[i].length);
            var stop_desc = rs[i].substring(0, rs[i].indexOf(';'))
            rs[i] = rs[i].substring(rs[i].indexOf(';') + 1, rs[i].length);
            var stop_lat = rs[i].substring(0, rs[i].indexOf(';'))
            rs[i] = rs[i].substring(rs[i].indexOf(';') + 1, rs[i].length);
            var stop_lon = rs[i]

            var stop = Qt.createQmlObject('import Sailfish.Silica 1.0; import QtQuick 2.0; import QtLocation 5.0; MapQuickItem{zoomLevel: 0; anchorPoint.x: rectangleStop.width / 2; anchorPoint.y: rectangleStop.height; sourceItem: Rectangle { id: rectangleStop; property string stop_id: "' + stop_id + '"; property string stop_name: "' + stop_name + '"; property string stop_desc: "' + stop_desc + '"; property real stop_lat: ' + stop_lat + '; property real stop_lon: ' + stop_lon + ';opacity: 1; width: 60;height: width; color: "transparent"; Image{anchors.fill: parent; fillMode: Image.PreserveAspectFit; source: "qrc:/images/harbour-BusPaulo.png"; anchors.centerIn: parent;} MouseArea {anchors.fill: parent; onClicked: {pageStack.push(Qt.resolvedUrl("StopPage.qml"), {"stop_id":parent.stop_id, "stop_name":parent.stop_name, "stop_desc":parent.stop_desc, "stop_lat":parent.stop_lat, "stop_lon":parent.stop_lon})}}}}', map);

            stop.coordinate.latitude = parseFloat(stop_lat) - parseFloat(0.00002); // ajuste para ficar certo no MapPage
            stop.coordinate.longitude = parseFloat(stop_lon)// - parseFloat(0.000140); // ajuste para ficar certo no mapa
            map.addMapItem(stop);
        }
    }

    Column {
        id: column

        width: root.width
        spacing: 0//Theme.paddingMedium
        PageHeader {
            id: headerTitle
            title: qsTr("Mapa")

            property bool show: true
            height: show ? page && page.isLandscape ? Theme.itemSizeSmall : Theme.itemSizeLarge : 0
            Behavior on height { PropertyAnimation { easing.type: Easing.InOutQuad; duration: 300; } }
        }
        Rectangle
        {
            height: root.height - headerTitle.height
            anchors.left: parent.left
            anchors.right: parent.right
            Plugin {
                id: somePlugin
                preferred: ["here", "osm"]
            }

            PositionSource
            {
                id: src
                updateInterval: 1000
                active: Qt.application.active

                property var coord;
                onPositionChanged: {
                    coord = src.position.coordinate;
                    map.updatePosition();
                    if(map.followCurrentPosition)
                    {
                        map.zoomLevel = zoomLevelStandard
                        map.center = map.circle.coordinate;
                    }
                }
            }


            Map {
                id: map
                property MapQuickItem circle
                property real lastCenterLat: 0;
                property real lastCenterLon: 0;
                property bool followCurrentPosition: true
                onFollowCurrentPositionChanged:
                {
                    map.zoomLevel = zoomLevelStandard
                    map.center = map.circle.coordinate;
                }

                anchors.fill: parent
                plugin: somePlugin

                Behavior on center { PropertyAnimation { easing.type: Easing.InOutCubic; duration: 400; } }
                Behavior on zoomLevel { PropertyAnimation { easing.type: Easing.InOutCubic; duration: 400; } }

                Timer {
                    property real lastCenterLatTimer: 0
                    property real lastCenterLonTimer: 0
                    interval: 350
                    repeat: true
                    running: Qt.application.active
                    onTriggered:
                    {
                        if(lastCenterLatTimer === map.center.latitude && lastCenterLonTimer === map.center.longitude)
                        {
                            if(Math.sqrt(Math.pow(map.center.latitude - map.lastCenterLat, 2) + Math.pow(map.center.longitude - map.lastCenterLon, 2)) > distanceToLook )//- 0.001)
                            {
                                map.lastCenterLat = map.center.latitude;
                                map.lastCenterLon = map.center.longitude;
                                lookForStops(map.center.latitude - distanceToLook, map.center.latitude + distanceToLook, map.center.longitude - distanceToLook, map.center.longitude + distanceToLook);
                            }
                        }
                        lastCenterLatTimer = map.center.latitude;
                        lastCenterLonTimer = map.center.longitude;
                    }
                }

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

                onCenterChanged:
                {
                    //console.log("Centro: " + center.latitude + ", " + center.longitude);
                    //console.log("Visualizar pontos: " + (center.latitude + 0.03) + ", " + (center.longitude + 0.03))
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

                Component.onCompleted: {
                    //circle = Qt.createQmlObject('import QtLocation 5.0; MapCircle {}', map)
                    circle = Qt.createQmlObject('import Sailfish.Silica 1.0; import QtQuick 2.0; import QtLocation 5.0; MapQuickItem{zoomLevel: 0; sourceItem: Rectangle {opacity: 0.9;width: 30;height: 30;radius: 15;color: Theme.highlightColor;border.width: 2; border.color: Theme.secondaryHighlightColor}}', map)
                    updatePosition();
                    zoomLevel = zoomLevelStandard
                    map.center = src.position.coordinate;
                }
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
}
