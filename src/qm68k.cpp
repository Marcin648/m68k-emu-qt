#include "qm68k.hpp"
#include <vector>
#include <sstream>
#include <iomanip>
#include <cctype>
#include <iostream>
#include <thread>
#include <QDebug>

QM68K::QM68K(QObject* parent) : QObject(parent){
    qInfo() << "QM68K Hello";
}

int QM68K::generation(){
    return this->m_generation;
}

void QM68K::setGeneration(int value){
    this->m_generation = value;
    emit generationChanged();
}

bool QM68K::isRun(){
    return m_is_run;
}

void QM68K::step(){
    try {
        std::lock_guard<std::mutex> locker(this->m_cpu_mutex);
        this->cpu.step();
    } catch (const std::exception& e) {
        qDebug() << "step -> " << e.what();
    }
    emit generationChanged();
}

void QM68K::run(){
    if(!this->m_is_run){
        this->m_is_run = true;
        this->m_cpu_worker = std::thread(QM68K::worker, this);
    }else{
        this->m_is_run = false;
        this->m_cpu_worker.join();
    }
    emit isRunChanged();
}

void QM68K::reset(){
    if(this->m_program_path.isEmpty() || this->m_is_run){
        return;
    }
    this->loadELF(this->m_program_path);
}

bool QM68K::loadELF(QUrl path){
    std::lock_guard<std::mutex> locker(this->m_cpu_mutex);
    bool result = this->cpu.loadELF(path.toLocalFile().toStdString());
    this->m_program_path = path;
    locker.~lock_guard();
    emit generationChanged();
    return result;
}

void QM68K::setRegister(size_t reg, uint32_t value){
    std::lock_guard<std::mutex> locker(this->m_cpu_mutex);
    if(reg <= 16){
        this->cpu.state.registers.set((M68K::RegisterType)reg, M68K::SIZE_LONG, value);
    }
    qDebug() << "Set register -> " << reg << " Value ->" << value;
    emit generationChanged();
}

void QM68K::setFlag(size_t flag, bool value){
    std::lock_guard<std::mutex> locker(this->m_cpu_mutex);
    this->cpu.state.registers.set((M68K::StatusRegisterFlag)flag, value);
    qDebug() << "Set flag -> " << flag << " Value ->" << value;
    emit generationChanged();
}

size_t QM68K::getRegister(size_t reg){
    std::lock_guard<std::mutex> locker(this->m_cpu_mutex);
    uint32_t value = 0;
    if(reg <= 16){
        value = this->cpu.state.registers.get((M68K::RegisterType)reg, M68K::SIZE_LONG);
    }
    qDebug() << "Get register -> " << reg << " Value ->" << value;
    return value;
}

bool QM68K::getFlag(size_t flag){
    std::lock_guard<std::mutex> locker(this->m_cpu_mutex);
    bool value = 0;
    value = this->cpu.state.registers.get((M68K::StatusRegisterFlag)flag);
    qDebug() << "Get flag -> " << flag << " Value ->" << value;
    return value;
}

QString QM68K::memoryDump(size_t start_address, size_t count){
    std::lock_guard<std::mutex> locker(this->m_cpu_mutex);
    qDebug() << "Memory dump -> " << start_address << " Lines ->" << (count/16);
    std::vector<uint8_t> buffer;
    buffer.reserve(count);
    for(size_t address = start_address; address < start_address+count; address++){
        if(address < 0 || address >= M68K::MEMORY_SIZE){
            break;
        }
        uint8_t byte = this->cpu.state.memory.get(address, M68K::DataSize::SIZE_BYTE);
        buffer.push_back(byte);
    }
    
    std::ostringstream stream;

    for(size_t i = 0; i < buffer.size(); i+=16){
        size_t address = start_address + i;
        stream << std::hex << std::setfill('0');
        stream << std::setw(8) << std::uppercase << address << ' ';
        for(size_t j = 0; j < 16; j++){
            size_t index = i+j;
            if(j == 8){
                stream << ' ';
            }
            if(index < buffer.size()){
                stream << ' ' << std::setw(2) << (uint32_t)buffer.at(index);
            }else{
                stream << "   ";
            }
        }

        stream << "  ";
        for(size_t j = 0; j < 16; j++){
            size_t index = i+j;
            if(index < buffer.size()){
                uint8_t byte = buffer.at(index);
                stream << (isprint(byte) ? (char)byte : '.');
            }else{
                stream << ' ';
            }
        }
        stream << std::endl;
    }
    return QString::fromStdString(stream.str());
}

QString QM68K::disassembly(uint32_t address){
    std::lock_guard<std::mutex> locker(this->m_cpu_mutex);
    const size_t max_lines = 64;
    static uint32_t last_start_address = 0xFFFFFFFF;
    static uint32_t last_end_address = 0xFFFFFFFF;

    if(address >= last_start_address && address <= last_end_address){
        address = last_start_address;
    }else{
        last_start_address = address;
    }

    M68K::CPUState state = this->cpu.state;
    std::ostringstream stream;

    uint32_t real_pc = state.registers.get(M68K::REG_PC);
    state.registers.set(M68K::REG_PC, M68K::DataSize::SIZE_LONG, address);
    
    size_t lines = 0;
    bool stop = false;
    while(!stop){
        try {
            uint32_t pc = state.registers.get(M68K::REG_PC);
            uint16_t opcode = state.memory.get(pc, M68K::DataSize::SIZE_WORD);

            auto instruction = this->cpu.instruction_decoder.Decode(opcode);
            //std::cout << typeid(*instruction).name() << std::endl;
            std::string instruction_str = instruction->disassembly(state);
            stream << (real_pc == pc ? "-> " : "   ");
            stream << std::hex << std::setfill('0');
            stream << std::setw(8) << std::uppercase << pc << " ";

            stream << instruction_str << std::endl;

            if(typeid(*instruction) == typeid(M68K::INSTRUCTION::Illegal)){
                stop = true;
            }
            lines++;
            if(lines > max_lines){
                stop = true;
            }
        } catch (const std::exception& e) {
            qDebug() << "disassembly -> " << e.what();
            stop = true;
        }
    }

    last_end_address = state.registers.get(M68K::REG_PC);

    return QString::fromStdString(stream.str());
}

void QM68K::worker(QM68K* qm68k){
    while(qm68k->m_is_run){
        try {
            std::lock_guard<std::mutex> locker(qm68k->m_cpu_mutex);
            qm68k->cpu.step();
        } catch (const std::exception& e) {
            qDebug() << "worker -> " << e.what();
            qm68k->m_is_run = false;
            emit qm68k->isRunChanged();
        }
    }
}