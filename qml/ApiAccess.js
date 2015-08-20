function autenticar()
{
    var xhr = new XMLHttpRequest;
    xhr.open("POST", "http://api.olhovivo.sptrans.com.br/v0/Login/Autenticar?token=54c7fed94632df0494816bdcadab906c0d524179e4c190b8f403fe82ecf3ad2e");

    console.log("Mandei Autenticar!")
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            console.log("oi")
            if (xhr.responseText === "true")
            {
                authenticated = true;
            }
            else
                authenticated = false;
        }
    }
    xhr.send();
}

function buscarLinha(linha)
{
    var xhr = new XMLHttpRequest;
    xhr.open("GET",
             "http://api.olhovivo.sptrans.com.br/v0/Linha/Buscar?termosBusca=" + linha);
    xhr.setRequestHeader("User-Agent", "BusPaulo")
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            auxStringBuscar = xhr.responseText;
        }
    }
    xhr.send()
}

function buscarParadaPorLinha(linha)
{
    var xhr = new XMLHttpRequest;
    xhr.open("GET",
             "http://api.olhovivo.sptrans.com.br/v0/Parada/BuscarParadasPorLinha?codigoLinha=" + linha);
    xhr.setRequestHeader("User-Agent", "BusPaulo")
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            auxStringBuscar = xhr.responseText;
        }
    }
    xhr.send()
}

function buscarPrevisaoChegadaPorParadaELinha(parada, linha)
{
    var xhr2 = new XMLHttpRequest;
    xhr2.open("GET",
             "http://api.olhovivo.sptrans.com.br/v0/Previsao?codigoParada=" + parada + "&codigoLinha=" + linha);
    xhr2.setRequestHeader("User-Agent", "BusPaulo")
    xhr2.onreadystatechange = function() {
        if (xhr2.readyState === XMLHttpRequest.DONE) {
            auxStringBuscarPrevisaoChegada = xhr2.responseText;
        }
    }
    xhr2.send()
}

function buscarPrevisaoChegadaPorParada(parada)
{
    var xhr = new XMLHttpRequest;
    xhr.open("GET",
             "http://api.olhovivo.sptrans.com.br/v0/Previsao/Parada?codigoParada=" + parada);
    xhr.setRequestHeader("User-Agent", "BusPaulo")
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            auxStringBuscarPrevisaoChegada = xhr.responseText;
        }
    }
    xhr.send()
}

function getFavoriteRouteStopTimes(favoriteName)
{

    var db = LocalStorage.openDatabaseSync("BusPaulo Database", "1.0", "Database for the BusPaulo app!", 1000000);

    db.transaction(
        function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS FAV_ROUTE_STOP_TIMES (COD_PARADA TEXT NOT NULL, END_PARADA TEXT NOT NULL, COD_LINHA TEXT NOT NULL, NOME_LINHA TEXT NOT NULL, NOME_FAV TEXT NOT NULL, UNIQUE (COD_PARADA, END_PARADA, COD_LINHA, NOME_LINHA, NOME_FAV))');

            eraseColumn();
            var xhr2 = new XMLHttpRequest;

            var rs = tx.executeSql('SELECT * FROM FAV_ROUTE_STOP_TIMES WHERE NOME_FAV = "' + favoriteName + '"ORDER BY COD_PARADA');

            for (var i = 0; i < rs.rows.length; ++i)
            {
                if(rs.rows.item(i).END_PARADA !== lastParada)
                {
                    lastParada = rs.rows.item(i).END_PARADA;
                    createNewItem(rs.rows.item(i).END_PARADA, rs.rows.item(i).COD_PARADA, rs.rows.item(i).NOME_LINHA, Theme.fontSizeMedium, "highlightColor", 30, false)
                }
                if(rs.rows.item(i).NOME_LINHA !== lastLinha)
                {
                    lastLinha = rs.rows.item(i).NOME_LINHA;
                    createNewItem(rs.rows.item(i).NOME_LINHA, rs.rows.item(i).COD_PARADA, rs.rows.item(i).NOME_LINHA, Theme.fontSizeMedium, "secondaryHighlightColor", 60, true)
                }
            }

        }
    )

    var xhr = new XMLHttpRequest;
    xhr.open("POST", "http://api.olhovivo.sptrans.com.br/v0/Login/Autenticar?token=54c7fed94632df0494816bdcadab906c0d524179e4c190b8f403fe82ecf3ad2e");

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.responseText === "true")
            {
                authenticated = true;

                db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS FAV_ROUTE_STOP_TIMES (COD_PARADA TEXT NOT NULL, END_PARADA TEXT NOT NULL, COD_LINHA TEXT NOT NULL, NOME_LINHA TEXT NOT NULL, NOME_FAV TEXT NOT NULL, UNIQUE (COD_PARADA, END_PARADA, COD_LINHA, NOME_LINHA, NOME_FAV))');

                        eraseColumn();
                        var xhr2 = new XMLHttpRequest;

                        var rs = tx.executeSql('SELECT * FROM FAV_ROUTE_STOP_TIMES WHERE NOME_FAV = "' + favoriteName + '"ORDER BY COD_PARADA');

                        for (var i = 0; i < rs.rows.length; ++i)
                        {
                            buscarPrevisaoChegadaPorParadaELinha(rs.rows.item(i).COD_PARADA, rs.rows.item(i).COD_LINHA);
                        }
                    }
                )
            }
            else
                authenticated = false;
        }
    }
    xhr.send();
    //autenticar();
}

function createNewItem(texto, codigoParada, linha, tamanho, cor, leftMargin, isErasable)
{
    for (var i = 0; i < linha1Model.count; ++i)
    {
        if (linha1Model.get(i).textoDelegate == texto && linha1Model.get(i).codigoParada == codigoParada && linha1Model.get(i).linha == linha)
            return;
    }
    linha1Model.insert(linha1Model.count, {"textoDelegate":texto, "codigoParada":codigoParada, "linha":linha, "tamanho":tamanho, "cor":cor, "leftMargin": leftMargin, "isErasable": isErasable})
}

function createNewRoute(texto, pai)
{
    var newObject = Qt.createQmlObject('import Sailfish.Silica 1.0; Label {x: Theme.paddingLarge; text: "' + texto + '"; color: Theme.secondaryHighlightColor; font.pixelSize: Theme.fontSizeLarge;}',
        pai);
}

function createNewTimeStopPage(texto, horaAtual, codigoParada, linha, tamanho, cor, leftMargin)
{
    var position = 0;

    for (var i = 0; i < stop1Model.count; ++i)
    {
        //console.log(linha)
        if(stop1Model.get(i).codigoParada == codigoParada && stop1Model.get(i).linha == linha)
        {
            position = i + 1;
        }
    }

    var time = Date.fromLocaleString(Qt.locale(), horaAtual, "hh:mm");
    var time2 = Date.fromLocaleString(Qt.locale(), texto, "hh:mm");
    var timeDiff = ((Math.abs(time2 - time) / 1000) / 60);
    timeDiff = "(" + timeDiff.toString() + " min)";
    stop1Model.insert(position, {"textoDelegate":texto + " " + timeDiff, "codigoParada":codigoParada.toString(), "linha":linha, "tamanho":tamanho, "cor":cor, "leftMargin": leftMargin, "isTime":true})
}

function createNewTime(texto, horaAtual, codigoParada, linha, tamanho, cor, leftMargin)
{
    var position = 0;

    for (var i = 0; i < linha1Model.count; ++i)
    {
        if(linha1Model.get(i).codigoParada == codigoParada && linha1Model.get(i).linha == linha)
        {
            position = i + 1;
        }
    }

    var time = Date.fromLocaleString(Qt.locale(), horaAtual, "hh:mm");
    var time2 = Date.fromLocaleString(Qt.locale(), texto, "hh:mm");
    var timeDiff = ((Math.abs(time2 - time) / 1000) / 60);
    timeDiff = "(" + timeDiff.toString() + " min)";
    linha1Model.insert(position, {"textoDelegate":texto + " " + timeDiff, "codigoParada":codigoParada.toString(), "linha":linha, "tamanho":tamanho, "cor":cor, "leftMargin": leftMargin, "isErasable": false})

    var ok = 0;
    if(firstBus === "")
    {
        firstBus = linha1Model.get(position - 1).linha + " - ";
        firstBusTime = texto;
    }
    else if(secondBus === "")
    {
        secondBus = linha1Model.get(position - 1).linha + " - ";
        secondBusTime = texto;
    }
    else if(thirdBus === "")
    {
        thirdBus = linha1Model.get(position - 1).linha + " - ";
        thirdBusTime = texto;
    }
    else if(fourthBus === "")
    {
        fourthBus = linha1Model.get(position - 1).linha + " - ";
        fourthBusTime = texto;
    }
    else if(fifthBus === "")
    {
        fifthBus = linha1Model.get(position - 1).linha + " - ";
        fifthBusTime = texto;
    }
    if(texto < firstBusTime)
    {
        fifthBus = fourthBus;
        fifthBusTime = fourthBusTime;
        fourthBus = thirdBus;
        fourthBusTime = thirdBusTime;
        thirdBus = secondBus;
        thirdBusTime = secondBusTime;
        thirdBus = secondBus;
        thirdBusTime = secondBusTime;
        secondBus = firstBus;
        secondBusTime = firstBusTime;
        firstBus = linha1Model.get(position - 1).linha + " - ";
        firstBusTime = texto;
    }
    else if(texto < secondBusTime)
    {
        fifthBus = fourthBus;
        fifthBusTime = fourthBusTime;
        fourthBus = thirdBus;
        fourthBusTime = thirdBusTime;
        thirdBus = secondBus;
        thirdBusTime = secondBusTime;
        secondBus = linha1Model.get(position - 1).linha + " - ";
        secondBusTime = texto;
    }
    else if(texto < thirdBusTime)
    {
        fifthBus = fourthBus;
        fifthBusTime = fourthBusTime;
        fourthBus = thirdBus;
        fourthBusTime = thirdBusTime;
        thirdBus = linha1Model.get(position - 1).linha + " - ";
        thirdBusTime = texto;
    }
    else if(texto < fourthBusTime)
    {
        fifthBus = fourthBus;
        fifthBusTime = fourthBusTime;
        fourthBus = linha1Model.get(position - 1).linha + " - ";
        fourthBusTime = texto;
    }
    else if(texto < fourthBusTime)
    {
        fifthBus = linha1Model.get(position - 1).linha + " - ";
        fifthBusTime = texto;
    }

    //console.log(firstBus + ": " + firstBusTime)
    //console.log(secondBus + ": " + secondBusTime)
    //console.log(thirdBus + ": " + thirdBusTime)
}

function eraseColumn()
{
    //favName = ""
    fifthBus = "";
    fifthBusTime = "";
    fourthBus = "";
    fourthBusTime = "";
    thirdBus = "";
    thirdBusTime = "";
    secondBus = "";
    secondBusTime = "";
    firstBus = "";
    firstBusTime = "";
    //linha1Model.clear();
    lastParada = "";
    lastLinha = "";
    currentTime = "";
}

function getFavoriteNames()
{
    var db = LocalStorage.openDatabaseSync("BusPaulo Database", "1.0", "Database for the BusPaulo app!", 1000000);

    db.transaction(
        function(tx) {

            favoritesNamesModel.clear();
            var rs = tx.executeSql('SELECT NAME FROM FAVORITES');
            for (var i = 0; i < rs.rows.length; ++i)
            {
                favoritesNamesModel.insert(favoritesNamesModel.count, {"name":rs.rows.item(i).NAME})
            }
        }
    )
}

function buscarPosicaoVeiculos(codigoLinha)
{
    var xhr = new XMLHttpRequest;
    xhr.open("GET",
             "http://api.olhovivo.sptrans.com.br/v0/Posicao?codigoLinha=" + codigoLinha);
    xhr.setRequestHeader("User-Agent", "BusPaulo")
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            stringBuscarPosicoes = xhr.responseText;
        }
    }
    xhr.send()
}
