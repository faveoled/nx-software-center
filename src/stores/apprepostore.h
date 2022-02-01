/**
 * Fetches the apps list from api url https://apprepo.de/rest/api
 */

#pragma once

// system

// libraries
#include <QList>
#include <QNetworkReply>
#include <QString>
#include <QUrl>
#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QNetworkReply>
#include <QUrlQuery>

// local
#include "store.h"
#include "ResponseDTO/apprepo/apprepogroupresponsedto.h"
#include "ResponseDTO/apprepo/apprepopackageresponsedto.h"
#include "ResponseDTO/categoryresponsedto.h"
#include "ResponseDTO/category.h"
#include "ResponseDTO/applicationresponsedto.h"
#include "ResponseDTO/application.h"

class AppRepoStore : public QObject {
    Q_OBJECT

    public:

        AppRepoStore(QString apiBaseUrl);

        const QString name();
        
        void getGroups();
        void getPackages();
        void getPackagesBySlug(QString slug);
        void getPackagesByGroup(int group);

        Q_SIGNAL void groupsResponseReady(CategoryResponseDTO *response);
        Q_SIGNAL void packagesResponseReady(ApplicationResponseDTO *response);
        Q_SIGNAL void error(QNetworkReply::NetworkError error);
    private:
        enum SearchPackage {
            ALL,
            BY_SLUG,
            BY_GROUP
        };

        QString API_BASEURL;
        QString API_GROUPS_URL;
        QString API_PACKAGES_URL;
        QString API_PACKAGES_BY_SLUG_URL;
        QString API_PACKAGES_BY_GROUP_URL;
        
        void getPackages(SearchPackage criteria, QString value = "");

        void parseGetGroupsResponseAndReply(QNetworkReply *reply);
        void parseGetPackagesResponseAndReply(QNetworkReply *reply);

        CategoryResponseDTO *generateGroupResponse(QList<AppRepoGroupResponseDTO *> response);
        ApplicationResponseDTO *generatePackageResponse(QList<AppRepoPackageResponseDTO *> response);

        AppRepoPackageResponseDTO *createPackageResponseDTO(QJsonObject obj);
};