#pragma once

#include <QObject>
#include <QtQuick>

#include "m68k.hpp"

class QM68K : public QObject{
    Q_OBJECT
public:
    QM68K(QObject* parent = nullptr);

public slots:
    void test();

protected:
    M68K::CPU cpu;
};
