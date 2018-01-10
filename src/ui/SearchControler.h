#ifndef SEARCHCONTROLER_H
#define SEARCHCONTROLER_H

#include <QDebug>
#include <QObject>
#include "entities/Application.h"
#include "entities/Repository.h"
#include "ApplicationListModel.h"
#include "interactors/FetchApplicationsInteractor.h"

class SearchControler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(ApplicationListModel *model MEMBER model NOTIFY modelChanged);

    ApplicationListModel *model;
    Repository *repository;
    QString query;
public:
    explicit SearchControler(Repository *repository, QObject *parent = nullptr);

signals:
    void updateRepositoryStarted();
    void updateRepositoryCompleted();
    void updateRepositoryError();

    void searching();
    void resultsReady();

    void modelChanged(ApplicationListModel *model);
public slots:
    void updateRepository();

    void search(const QString &query);

protected slots:
    void handleUpdateRepositoryCompleted();

protected:
    void filterApplications();
};

#endif // SEARCHCONTROLER_H
