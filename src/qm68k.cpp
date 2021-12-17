#include "qm68k.hpp"
#include <QDebug>

QM68K::QM68K(QObject* parent) : QObject(parent){
    qInfo() << "QM68K Hello";
}

void QM68K::test(){
    qInfo() << "QM68K Hello TEST";
}
