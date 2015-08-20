#include "managedb.h"
#include <QSqlRecord>
#include <QDebug>

manageDb::manageDb(QObject *parent) :
    QObject(parent)
{
    Q_INIT_RESOURCE(res);
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("/usr/share/harbour-BusPaulo/qml/dbSptrans.sqlite");
    qDebug() << "db.open(): " << db.open();
    query = new QSqlQuery(db);
}

QList<QString> manageDb::returnNearStops(double latLow, double latHigh, double lonLow, double lonHigh)
{
    QList<QString> returnList;
    QString stop_id;
    QString stop_name;
    QString stop_desc;
    double stop_lat;
    double stop_lon;

    query->exec("SELECT * FROM PONTOS_SAO_PAULO WHERE stop_lat > " + QString::number(latLow, 'g', 12) + " AND stop_lat < " + QString::number(latHigh, 'g', 12) + " AND stop_lon > " + QString::number(lonLow, 'g', 12) + " AND stop_lon < " + QString::number(lonHigh, 'g', 12));
    while(query->next())
    {
        stop_id = query->value(query->record().indexOf("stop_id")).toString(); //.value(0).toString();
        stop_name = query->value(query->record().indexOf("stop_name")).toString();
        stop_desc = query->value(query->record().indexOf("stop_desc")).toString();
        stop_lat = query->value(query->record().indexOf("stop_lat")).toDouble();
        stop_lon = query->value(query->record().indexOf("stop_lon")).toDouble();
        QString aux = stop_id + ";" + stop_name + ";" + stop_desc + ";" + QString::number(stop_lat, 'g', 12) + ";" + QString::number(stop_lon, 'g', 12);
        returnList << aux;
    }
    //qDebug() << returnList;

    return returnList;
}

QList<QString> manageDb::returnRoutesInStop(QString stop_id)
{
    QList<QString> returnList;
    QString trip_id;
    QString arrival_time;
    QString departure_time;
    int stop_sequence;

    qDebug() << "SELECT * FROM HORARIOS_SAO_PAULO WHERE stop_id = " + stop_id;
    query->exec("SELECT * FROM HORARIOS_SAO_PAULO WHERE stop_id = " + stop_id);
    while(query->next())
    {
        trip_id = query->value(query->record().indexOf("trip_id")).toString(); //.value(0).toString();
        arrival_time = query->value(query->record().indexOf("arrival_time")).toString();
        departure_time = query->value(query->record().indexOf("departure_time")).toString();
        stop_sequence = query->value(query->record().indexOf("stop_sequence")).toInt();
        QString aux = trip_id + ";" + arrival_time + ";" + departure_time + ";" + QString::number(stop_sequence);
        returnList << aux;
    }

    return returnList;
}

/*
QList<QList<QString>> manageDb::returnNearStops(QString stop_id)
{
    query.exec("SELECT * FROM PONTOS_SAO_PAULO WHERE stop_id = " + stop_id);
    query.next();
}
*/
