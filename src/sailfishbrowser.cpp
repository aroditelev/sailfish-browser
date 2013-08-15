/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Vesa-Matti Hartikainen <vesa-matti.hartikainen@jollamobile.com>
**
****************************************************************************/

#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include <QQmlEngine>
#include <QtQml>
#include <QTimer>
#include <QTranslator>
#include <QDir>
#include <QScreen>
#include <QDBusConnection>

//#include "qdeclarativemozview.h"
#include "quickmozview.h"
#include "qmozcontext.h"

#include "declarativebrowsertab.h"
#include "declarativebookmarkmodel.h"
#include "declarativewebutils.h"
#include "browserservice.h"
#include "declarativewebthumbnail.h"
#include "downloadmanager.h"
#include "settingmanager.h"

#ifdef HAS_BOOSTER
#include <MDeclarativeCache>
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    // Gecko embedding crashes with threaded render loop
    // that's why this workaround.
    // See JB#7358
    setenv("QML_BAD_GUI_RENDER_LOOP", "1", 1);
#ifdef HAS_BOOSTER
    QScopedPointer<QGuiApplication> app(MDeclarativeCache::qApplication(argc, argv));
    QScopedPointer<QQuickView> view(MDeclarativeCache::qQuickView());
#else
    QScopedPointer<QGuiApplication> app(new QApplication(argc, argv));
    QScopedPointer<QQuickView> view(new QQuickView);
#endif
    app->setQuitOnLastWindowClosed(true);

    BrowserService *service = new BrowserService(app.data());
    // Handle command line launch
    if (!service->registered()) {
        QDBusMessage message = QDBusMessage::createMethodCall(service->serviceName(), "/",
                                                              service->serviceName(), "openUrl");
        QStringList args;
        // Pass url argument if given
        if (app->arguments().count() > 1) {
            args << app->arguments().at(1);
        }
        message.setArguments(QVariantList() << args);

        QDBusConnection::sessionBus().asyncCall(message);
        if (QCoreApplication::hasPendingEvents()) {
            QCoreApplication::processEvents();
        }

        return 0;
    }

    QString translationPath("/usr/share/translations/");
    QTranslator engineeringEnglish;
    engineeringEnglish.load("sailfish-browser_eng_en", translationPath);
    qApp->installTranslator(&engineeringEnglish);

    QTranslator translator;
    translator.load(QLocale(), "sailfish-browser", "-", translationPath);
    qApp->installTranslator(&translator);

    qmlRegisterType<DeclarativeBookmarkModel>("Sailfish.Browser", 1, 0, "BookmarkModel");
    qmlRegisterType<DeclarativeWebThumbnail>("Sailfish.Browser", 1, 0, "WebThumbnail");

    QString componentPath(DEFAULT_COMPONENTS_PATH);
    QMozContext::GetInstance()->addComponentManifest(componentPath + QString("/components/EmbedLiteBinComponents.manifest"));
    QMozContext::GetInstance()->addComponentManifest(componentPath + QString("/components/EmbedLiteJSComponents.manifest"));
    QMozContext::GetInstance()->addComponentManifest(componentPath + QString("/chrome/EmbedLiteJSScripts.manifest"));
    QMozContext::GetInstance()->addComponentManifest(componentPath + QString("/chrome/EmbedLiteOverrides.manifest"));

    app->setApplicationName(QString("sailfish-browser"));
    app->setOrganizationName(QString("org.sailfishos"));

    DeclarativeBrowserTab * tab = new DeclarativeBrowserTab(view.data(), app.data());
    DeclarativeWebUtils * utils = new DeclarativeWebUtils(app->arguments(), service, app.data());
    view->rootContext()->setContextProperty("WebUtils", utils);
    view->rootContext()->setContextProperty("MozContext", QMozContext::GetInstance());

    DownloadManager dlMgr(service);
    QObject::connect(app.data(), SIGNAL(lastWindowClosed()),
                     &dlMgr, SLOT(cancelActiveTransfers()));

    SettingManager * settingMgr = new SettingManager(app.data());
    QObject::connect(QMozContext::GetInstance(), SIGNAL(onInitialized()),
                     settingMgr, SLOT(initialize()));

    bool isDesktop = qApp->arguments().contains("-desktop");

    QString path;
    if (isDesktop) {
        path = qApp->applicationDirPath() + QDir::separator();
    } else {
        path = QString(DEPLOYMENT_PATH);
    }
    view->setSource(QUrl::fromLocalFile(path+"browser.qml"));
    view->showFullScreen();

    // Setup embedding
    QObject::connect(app.data(), SIGNAL(lastWindowClosed()),
                     QMozContext::GetInstance(), SLOT(stopEmbedding()));
    QTimer::singleShot(0, QMozContext::GetInstance(), SLOT(runEmbedding()));

    return app->exec();
}
