#pragma once

#include <QObject>
#include <QString>
#include <QUrl>
#include <QtQuick>

#include <mutex>
#include <atomic>
#include <thread>

#include "m68k.hpp"

class QM68K : public QObject{
    Q_OBJECT
    Q_PROPERTY(int generation READ generation WRITE setGeneration NOTIFY generationChanged)
    Q_PROPERTY(bool isRun READ isRun NOTIFY isRunChanged)
public:
    M68K::CPU cpu;

    QM68K(QObject* parent = nullptr);
    int generation();
    void setGeneration(int value);

    bool isRun();

public slots:
    void step();
    void run();
    bool loadELF(QUrl path);
    void setRegister(size_t reg, uint32_t value);
    void setFlag(size_t flag, bool value);
    size_t getRegister(size_t reg);
    bool getFlag(size_t flag);
    QString memoryDump(size_t address, size_t count);
    QString disassembly(uint32_t address);
signals:
    void generationChanged();
    void isRunChanged();
protected:
    int m_generation = 0;
    std::atomic_bool m_is_run = false;
    std::mutex m_cpu_mutex;
    std::thread m_cpu_worker;

    static void worker(QM68K* qm68k);
};