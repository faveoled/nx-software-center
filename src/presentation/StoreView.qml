import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import Snapd 1.0

import org.nx.softwarecenter 1.0

import "qrc:/scripts/Utils.js" as Utils
import "qrc:/actions/InstallSnapAction.js" as InstallSnapAction

Item {
    id: storeViewRoot

    SnapdClient {
        id: snapdClient
    }

    objectName: "storeView"
    Rectangle {
        color: "lightblue"
        anchors.fill: parent
        opacity: 0.1
    }

    Loader {
        id: contentLoader
        anchors.fill: parent

        sourceComponent: storeSnapsModel.busy
                         || storeSnapsModel.count == 0 ? searchView : snapsView
    }

    Component {
        id: searchView
        Item {
            PlasmaComponents.Label {
                id: messageText
                anchors.top: busyModelIndicator.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: 400
                height: 100

                text: storeSnapsModel.errorMessage
                      == "" ? storeSnapsModel.statusMessage : storeSnapsModel.errorMessage

                fontSizeMode: Text.Fit
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                minimumPixelSize: 10
                font.pixelSize: 20
            }

            PlasmaComponents.BusyIndicator {
                id: busyModelIndicator
                visible: storeSnapsModel.busy
                anchors.centerIn: parent
            }

            PlasmaCore.IconItem {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -20
                width: 64
                height: 64

                source: storeSnapsModel.statusMessageIcon
                visible: !busyModelIndicator.visible
            }
        }
    }

    Component {
        id: snapsView
        ScrollView {
            Flickable {
                contentWidth: snapsList.width
                contentHeight: snapsList.height + 40
                anchors.margins: 20

                Flow {
                    anchors.centerIn: parent
                    id: snapsList
                    width: storeViewRoot.width - 20

                    Repeater {
                        model: storeSnapsModel
                        delegate: snaptElementDelegate
                    }
                }
            }
        }
    }

    Component {
        id: snaptElementDelegate
        Item {
            width: 192
            height: 192
            property bool selected: false

            Rectangle {
                anchors.fill: parent
                anchors.margins: 6
                color: selected ? "lightblue" : "silver"
                opacity: 0.4
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 0
                Item {
                    Layout.alignment: Qt.AlignRight
                    height: snap_status_icon.height
                    width: snap_status_icon.width
                    Layout.topMargin: 10
                    Layout.rightMargin: 12

                    PlasmaCore.IconItem {
                        id: snap_status_icon
                        source: ""
                    }
                }

                PlasmaCore.IconItem {
                    id: snap_icon
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    Layout.alignment: Qt.AlignHCenter
                    source: model.icon ? model.icon : "package-available"
                }

                Text {
                    id: snap_pkg_name
                    text: name
                    elide: Text.ElideRight
                    Layout.topMargin: 14
                    Layout.leftMargin: 12
                    font.bold: true
                }

                Text {
                    id: snap_version
                    text: i18n("Version: ") + version
                    Layout.leftMargin: 12
                    font.italic: true
                }
                Text {
                    id: snap_installed_size
                    property string sizeString: Utils.formatSize(
                                                    model.downaloadSize)
                    text: model.downaloadSize ? sizeString : i18n(
                                                    "Unknown size")
                    Layout.leftMargin: 12
                    Layout.fillHeight: true
                }
            }

            MouseArea {
                id: snapElementArea
                anchors.fill: parent

                preventStealing: false
                propagateComposedEvents: true
                hoverEnabled: true

                onClicked: {
                    selected = !selected
                    if (selected)
                        storeSnapsModel.selectedItems[name] = "true"
                    else
                        delete storeSnapsModel.selectedItems[name]
                }
            }
        }
    }

    SnapsModel {
        id: storeSnapsModel

        property bool busy: false
        property string query: ""
        property string statusMessage: i18n("Type what are you looking for ...")
        property string errorMessage: ""
        property string statusMessageIcon: "face-laughing"

        Component.onCompleted: refresh()

        fetchSnapsFunc: function () {
            query = searchField.text

            // Ensure we are connected
            var connectRequest = snapdClient.connect()
            connectRequest.runSync()

            busy = true
            statusMessage = i18n("Lonking for snaps like: \"") + query + "\""
            var request = snapdClient.find(0, query)
            request.runSync()

            busy = false
            if (request.snapCount == 0) {
                statusMessage = i18n(
                            "No snaps where found with text \"") + query + "\" try something else."
                statusMessageIcon = "face-sad"
            }
            if (request.error) {
                errorMessage = i18n(
                            "There was an error while procesing your request. Please check your internet connection and try again.")
                statusMessageIcon = "face-uncertain"
            } else {
                errorMessage = ""
            }
            var list = []
            //            snapList.sort(function (a, b) { return a < b})
            for (var i = 0; i < request.snapCount; i++) {
                var snap = request.snap(i)
                list.push(snap)
            }

            return list
        }
    }

    Connections {
        target: searchField
        onEditingFinished: storeSnapsModel.refresh()
    }

    Component.onCompleted: {

        var actions = [InstallSnapAction.prepare(SnapdRootClient,
                                                 storeSnapsModel)]
        statusArea.updateContext("documentinfo",
                                 i18n("Available actions"), actions)
    }
}
