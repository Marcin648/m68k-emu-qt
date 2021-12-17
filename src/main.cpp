#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "qm68k.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QM68K qm68k;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("qm68k", &qm68k);

    const QUrl url(u"qrc:/m68k_emu_qt/qml/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    

    return app.exec();
}
