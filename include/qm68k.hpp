#pragma once

#include <QObject>
#include <QtQuick>

class QM68K : public QObject{
    Q_OBJECT
public:
    QM68K(QObject* parent = nullptr);

public slots:
    void test();
};
