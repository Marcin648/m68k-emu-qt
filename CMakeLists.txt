cmake_minimum_required(VERSION 3.16)
project(m68k-emu-qt LANGUAGES CXX VERSION 0.1.0)

add_subdirectory(libs/m68k-emu)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(SRC
    src/main.cpp
    src/qm68k.cpp
)

set(INCLUDES
    include/qm68k.hpp
)

set(QML
    qml/main.qml
    qml/DisassemblerView.qml
    qml/MemoryView.qml
    qml/RegisterView.qml
)

set(RES
    
)

include_directories(include)
include_directories(libs/m68k-emu/include)

find_package(Qt6 COMPONENTS Core Quick REQUIRED)

qt_add_executable(m68k-emu-qt
    ${SRC}
    ${INCLUDES}
)

qt_add_qml_module(m68k-emu-qt
    URI m68k_emu_qt
    VERSION 1.0
    QML_FILES ${QML}
    RESOURCES ${RES}
)



target_compile_definitions(m68k-emu-qt PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(m68k-emu-qt PRIVATE Qt6::Core Qt6::Quick m68k-emu)
