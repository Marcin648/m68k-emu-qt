#pragma once

#include <QObject>
#include <QString>
#include <QUrl>
#include <QtQuick>

#include "m68k.hpp"

class QM68K : public QObject{
    Q_OBJECT
    Q_PROPERTY(int generation READ generation WRITE setGeneration NOTIFY generationChanged)
private:
    int m_generation = 0;
public:
    QM68K(QObject* parent = nullptr);
    int generation();
    void setGeneration(int value);

public slots:
    void step();
    bool loadELF(QUrl path);
    void setRegister(size_t reg, uint32_t value);
    void setFlag(size_t flag, bool value);
    size_t getRegister(size_t reg);
    bool getFlag(size_t flag);
    QString memoryDump(size_t address, size_t count);
    QString disassembly(uint32_t address);
signals:
    void generationChanged();
protected:
    M68K::CPU cpu;
};
