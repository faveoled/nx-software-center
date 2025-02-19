import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui

import org.maui.nxsc 1.0
import NXModels 1.0 as NX
import "../../templates"

Maui.Page
{
    id: control

    Maui.Dialog
    {
        id: appLaunchErrorDialog

        title: i18n("Error")
        message: i18n("Error launching application")
        rejectButton.visible: false

        acceptButton.onClicked:
        {
            appLaunchErrorDialog.visible = false;
        }

        function showDialog(fileName, errCode)
        {
            switch (errCode)
            {
            case 0:
                message = "Error launching application <b>" + fileName + "</b>. Please check if you have correct permission"
                break;

            default:
                message = "Error launching application " + fileName
                break;
            }

            appLaunchErrorDialog.visible = true;
        }
    }

    Maui.Dialog
    {
        id: appUpdateDialog

        title: i18n("AppImage Update")
        message: i18n("Please wait...")
        rejectButton.visible: false

        acceptButton.onClicked:
        {
            appUpdateDialog.visible = false;
        }

        function showDialog(fileName, status)
        {
            message = status

            appUpdateDialog.visible = true;
        }
    }

    Maui.Dialog
    {
        id: appRemoveDialog

        property var targetAppName;
        property var targetAppData;

        title: i18n("Remove")
        message: i18n("Are you sure you want to remove " + targetAppName + "?")
        template.iconSource: "emblem-warning"
        page.margins: Maui.Style.space.big
        spacing: Maui.Style.space.medium
        onRejected: appRemoveDialog.close()
        onAccepted: {
            DeleteService.deleteApplication(targetAppData);
            appRemoveDialog.close()

            targetAppName = "";
            targetApp = null;
        }
    }

    headBar.forceCenterMiddleContent: isWide
    headBar.middleContent: Maui.SearchField
    {
        id: _filterBar
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        Layout.alignment: Qt.AlignCenter
        placeholderText: i18n("Filter installed apps")
        onTextChanged: ApplicationsListModel.filterRegExp = RegExp(text)
        onCleared:  ApplicationsListModel.filterRegExp = ""
    }

    headBar.rightContent: [
        Button
        {
            text: qsTr("Update All")
            visible: _appsList.isUpdateAvailable
            onClicked:
            {
                var appList = ApplicationsRegistry.getApplications();
                UpdateService.update(appList);
            }
        },

        Maui.ToolButtonMenu
        {
            icon.name: "view-sort"

            MenuItem
            {
                text: i18n("Name")
                checkable: true
                autoExclusive: true
                checked: ApplicationsListModel.sortRole === ApplicationModelRole.Name
                onTriggered: ApplicationsListModel.sortRole = ApplicationModelRole.Name
            }

            MenuItem
            {
                text: i18n("Category")
                checkable: true
                autoExclusive: true
                checked: ApplicationsListModel.sortRole === ApplicationModelRole.XdgCategories
                onTriggered: ApplicationsListModel.sortRole = ApplicationModelRole.XdgCategories
            }
        }
    ]

    Maui.Holder
    {
        anchors.fill: parent
        title: i18n("Get started")
        body: i18n("Your installed AppImages will appear here")
        visible: _appsListView.count === 0
        emoji: "qrc:/store.svg"
        emojiSize: Maui.Style.iconSizes.huge
    }

    Maui.ListBrowser
    {
        id: _appsListView
        anchors.fill: parent
        orientation: ListView.Vertical
        spacing: Maui.Style.space.medium
        section.property: ApplicationsListModel.sortRoleName
        section.criteria:  ApplicationsListModel.sortRole === ApplicationModelRole.Name ? ViewSection.FirstCharacter : ViewSection.FullString
        section.delegate: Maui.LabelDelegate
        {
            id: delegate
            label:   String(section)

            isSection: true

            height: Maui.Style.toolBarHeightAlt
            width: parent.width
        }

        model: ApplicationsListModel

        delegate: Maui.SwipeBrowserDelegate
        {
            id: swipeBrowserDelegateItem
            height: 64
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            label1.text: model.name
            label2.text: model.description
            label3.text: model.version
            label4.text: Maui.Handy.formatSize(model.mainBundleSize)
            imageSource: "file://" + model.icon
            iconSizeHint: Maui.Style.iconSizes.large
            iconSource: "application-vnd.appimage"

            Rectangle {
                height: parent.height
                width: swipeBrowserDelegateItem.iconItem.width
                color: "transparent"

                Rectangle {
                    height: 20
                    width: 20
                    radius: 20
                    color: "#43A047"
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    visible: model.update_available

                    Rectangle {
                        height: 14
                        width: 14
                        radius: 14
                        color: "#33ffffff"
                        anchors.centerIn: parent

                        Image {
                            anchors.fill: parent
                            source: "qrc:/app-update-available.svg"
                        }
                    }
                }

                Rectangle {
                    height: 20
                    width: 20
                    radius: 20
                    color: "#FF9800"
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    visible: model.related_task

                    Rectangle {
                        height: 14
                        width: 14
                        radius: 14
                        color: "#33ffffff"
                        anchors.centerIn: parent

                        Image {
                            anchors.fill: parent
                            source: "qrc:/app-update-progress.svg"
                        }

                        RotationAnimation on rotation {
                            loops: Animation.Infinite
                            from: 0
                            to: 360
                            duration: 1000
                            running: true
                        }
                    }
                }
            }

            actionRow: Maui.ToolButtonMenu {
                id: runOptionsMenu
                property var appModel: model

                visible: appModel.bundles.length > 1
                text: "Configure"
                icon.name: "configure"

                Repeater {
                    model: runOptionsMenu.appModel.bundles
                    MenuItem {
                        text: modelData
                        checkable: true
                        autoExclusive: true
                        checked: index === runOptionsMenu.appModel.mainBundleIndex
                        onClicked: {runOptionsMenu.appModel.mainBundleIndex = index}
                    }
                }
            }

            quickActions: [
                Action
                {
                    icon.name: "download"
                    text: "Update"
                    enabled: model.update_available
                    onTriggered: UpdateService.update(model.data);
                },
                Action
                {
                    icon.name: "entry-delete"
                    text: "Remove"
                    onTriggered:  {
                        appRemoveDialog.targetAppName = model.name
                        appRemoveDialog.targetAppData = model.data;
                        appRemoveDialog.open();
                    }
                }
            ]

            onClicked: LaunchService.launch(model.data)
        }
    }

    Connections
    {
        target: _appsList

        function onAppLaunchError(err) {
            console.log("App Launch Error", err);
            appLaunchErrorDialog.showDialog(_appsListView.model.get(_appsListView.currentIndex).path.split("/").pop(), err);
            _appsListView.currentIndex = -1;
        }



        function onAppUpdateError(err) {
            console.log("AppImage update error.");
            appUpdateDialog.showDialog(_appsListView.model.get(_appsListView.currentIndex).path.split("/").pop(),
                err);
        }
    }
    Component.onCompleted:
    {
            var appList = ApplicationsRegistry.getApplications();
//            UpdateService.checkUpdates(appList);
    }
}



