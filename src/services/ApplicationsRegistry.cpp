#include "ApplicationsRegistry.h"

#include <utility>

#include <QDebug>
#include <QVector>
#include <appimagetools.h>

ApplicationsRegistry::ApplicationsRegistry(QStringList appDirs, QMap<QString, ApplicationData> applications)
    : _applications(applications)
    , _appDirs(std::move(appDirs))
{
    qRegisterMetaType<ApplicationData>();
    qRegisterMetaType<ApplicationBundle>();
}
void ApplicationsRegistry::addBundle(const ApplicationBundle &bundle)
{
    auto appId = bundle.app->getId();
    if (_applications.contains(appId)) {
        auto &app = _applications[appId];
        app.addBundle(bundle);

        emit(applicationUpdated(app));
        updateDesktopIntegration(app);
    } else {
        ApplicationData data;
        data.addBundle(bundle);
        _applications.insert(appId, data);

        emit(applicationAdded(data));
        updateDesktopIntegration(data);
    }
}
ApplicationData ApplicationsRegistry::getApplication(const QString &appId) const
{
    return _applications.value(appId);
}
void ApplicationsRegistry::removeBundleByPath(const QString &path)
{
    ApplicationBundle targetBundle;

    const auto &apps = _applications.values();
    for (const auto &app : apps) {
        const auto &bundles = app.getBundles();
        for (const auto &bundle : bundles) {
            if (bundle.path == path) {
                targetBundle = bundle;
                break;
            }
        }
    }

    if (!targetBundle.path.isEmpty())
        removeBundle(targetBundle);
    else
        qWarning() << "Unable to remove bundle " << path << " as it isn't found.";
}
void ApplicationsRegistry::removeBundle(const ApplicationBundle &bundle)
{
    if (bundle.app.isNull()) {
        qWarning() << "Unable to remove bundle " << bundle.path << " as it doesn't contain application data.";
        return;
    }

    auto appId = bundle.app->getId();
    if (_applications.contains(appId)) {
        auto &app = _applications[appId];
        app.removeBundle(bundle);

        if (app.getBundles().length() == 0) {
            auto deletedApp = _applications.take(appId);

            emit(applicationRemoved(deletedApp));
        } else {
            emit(applicationUpdated(app));
        }

        // remove deleted bundle integration
        AppImageTools::unintegrate(QUrl::fromLocalFile(bundle.path));

        // integrate remaining bundles if any
        updateDesktopIntegration(app);
    } else {
        qWarning() << "Unable to remove bundle " << bundle.path << " as it isn't found.";
    }
}
bool ApplicationsRegistry::applicationExist(const QString &appId) const
{
    return _applications.contains(appId);
}
const QStringList &ApplicationsRegistry::getAppDirs()
{
    return _appDirs;
}

ApplicationsList ApplicationsRegistry::getApplications() const
{
    return QVector<ApplicationData>::fromList(_applications.values());
}

int ApplicationsRegistry::getApplicationsCount() const
{
    return _applications.size();
}
void ApplicationsRegistry::updateDesktopIntegration(const ApplicationData &applicationData) const
{
    const auto &bundles = applicationData.getBundles();
    if (bundles.length() > 0) {
        const auto &latestVersion = bundles[0];
        AppImageTools::integrate(QUrl::fromLocalFile(latestVersion.path));

        // un integrate previous versions
        for (int i = 1; i < bundles.length(); i++)
            AppImageTools::unintegrate(QUrl::fromLocalFile(bundles[i].path));
    }
}
