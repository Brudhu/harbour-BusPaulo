#ifndef MANAGEDB_H
#define MANAGEDB_H

#include <QObject>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>

namespace optionsExp { namespace cascades { class Application; }}

class manageDb : public QObject
{
    Q_OBJECT
public:
    explicit manageDb(QObject *parent = 0);
    Q_INVOKABLE QList<QString> returnNearStops(double latLow, double latHigh, double lonLow, double lonHigh);
    Q_INVOKABLE QList<QString> returnRoutesInStop(QString stop_id);

signals:

public slots:


private:
    QByteArray fileBytes;
    QSqlDatabase db;
    QSqlQuery * query;

};

#endif // MANAGEDB_H
