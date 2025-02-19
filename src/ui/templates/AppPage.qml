import QtQuick 2.7
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.0 as FB

import QtGraphicalEffects 1.0

import NXModels 1.0 as NX

import "../views/store"

Maui.Page
{
    id: control
    title: appInfo.name

    property alias appInfo : _appHandler.info
    property alias imagesInfo : _appHandler.images
    property alias downloadsInfo : _appHandler.downloads
    property alias urlsInfo : _appHandler.urls

    property alias buttonActions : _actionButtons.data
    property alias data : _appHandler.data
    property alias app : _appHandler

    property bool shouldAnimateScroll: false
    readonly property int scrollAnimationDuration: 1000

    //    flickable: _scrollablePage.flickable
    //    floatingHeader: true
    //    headerPositioning: ListView.PullBackHeader
    //    headerBackground.color: "transparent"

    enum Sections
    {
        Description,
        Details,
        Packages,
        Screenshots,
        Changelog,
        Comments
    }

    signal packageClicked(int index)
    signal tagClicked(string tag)

    Timer
    {
        id: scrollAnimationResetTimer
        interval: scrollAnimationDuration
        repeat: false
        onTriggered: {
            shouldAnimateScroll = false;
        }
    }

    NX.App
    {
        id: _appHandler
    }

    ScrollView
    {
        id: _scrollablePage
        anchors.fill: parent
        clip: control.clip
        contentHeight: _pageLayout.implicitHeight
        contentWidth: availableWidth
        padding: Maui.Handy.isMobile ? Maui.Style.space.medium : Maui.Style.space.big

        Flickable
        {
            Behavior on contentX
            {
                enabled: shouldAnimateScroll

                NumberAnimation
                {
                    duration: scrollAnimationDuration
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on contentY
            {
                enabled: shouldAnimateScroll

                NumberAnimation
                {
                    duration: scrollAnimationDuration
                    easing.type: Easing.InOutQuad
                }
            }

            ColumnLayout
            {
                id: _pageLayout
                width: parent.width
                spacing: Maui.Style.space.huge

                Item
                {
                    id: _header
                    Layout.preferredHeight: _bannerInfo.implicitHeight + Maui.Style.space.enormous
                    Layout.fillWidth: true
                    clip: true

                    Maui.FlexListItem
                    {
                        id: _bannerInfo
                        width: parent.width
                        padding: Maui.Style.space.medium
                        //                    anchors.fill: parent
                        anchors.centerIn: parent
                        wide: root.isWide
                        iconSource: "package"
                        iconSizeHint: Maui.Style.iconSizes.huge
                        imageSource: appInfo.smallpic
                        template.fillMode: Image.PreserveAspectFit
                        label1.text: appInfo.name
                        label1.elide: Text.ElideMiddle
                        label1.wrapMode: Text.WrapAnywhere
                        label1.font.weight: Font.Bold
                        label1.font.bold: true
                        label1.font.pointSize: Maui.Style.fontSizes.enormous *2
                        label2.text: String("<a href='%1'>%1</a>").arg(appInfo.personid)
                        template.leftLabels.spacing: Maui.Style.space.medium
                        rowSpacing: Maui.Style.space.big
                        template.spacing: Maui.Style.space.huge
                        //                    label3.text: appInfo.personid

                        template.leftLabels.data: Row
                        {
                            id: _actionButtons
                            //                        Layout.fillWidth: parent.wide
                            //                        Layout.margins: Maui.Style.space.big
                            //                        spacing: Maui.Style.space.medium
                            Layout.preferredHeight: implicitHeight
                        }

                        Maui.Chip
                        {

                            color: "#21be2b"
                            label.text: appInfo.server


                        }

                        RowLayout
                        {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignCenter
                            spacing: Maui.Style.space.big

                            Maui.GridItemTemplate
                            {
                                Layout.fillWidth: true
                                implicitWidth:  64
                                implicitHeight: 64
                                isMask: true

                                iconSource: "rating"
                                iconSizeHint: Maui.Style.iconSizes.medium
                                labelSizeHint: 22
                                label1.text: appInfo.score
                                label1.font.bold: true
                                label1.font.weight: Font.Bold
                                label1.font.pointSize: Maui.Style.fontSizes.big
                            }

                            Maui.GridItemTemplate
                            {
                                Layout.fillWidth: true
                                implicitWidth:  64
                                implicitHeight: 64
                                iconSource: "download"
                                iconSizeHint: Maui.Style.iconSizes.medium
                                labelSizeHint: 22
                                isMask: true
                                label1.text: appInfo.totaldownloads
                                label1.font.bold: true
                                label1.font.weight: Font.Bold
                                label1.font.pointSize: Maui.Style.fontSizes.big
                            }

                            Maui.GridItemTemplate
                            {
                                Layout.fillWidth: true

                                implicitWidth:  64
                                implicitHeight: 64
                                isMask: true

                                iconSource: "license"
                                iconSizeHint: Maui.Style.iconSizes.medium
                                labelSizeHint: 22
                                label1.text: appInfo.license || i18n("Unkown")
                                label1.font.bold: true
                                label1.font.weight: Font.Bold
                                label1.font.pointSize: Maui.Style.fontSizes.big

                            }
                        }
                    }
                }

                SectionTitle
                {
                    id: _div1

                    title: appInfo.name
                    description: appInfo.description
                    template.label2.wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }


                Maui.Separator
                {
                    Layout.fillWidth: true
                }

                SectionTitle
                {
                    id: _div2
                    title: i18n("Packages")
                    description: i18n("Avaliable packages to download.")

                    GridView
                    {
                        id: _packagesGrid
                        implicitHeight: contentHeight
                        Layout.fillWidth: true
                        model: control.downloadsInfo
                        cellWidth: Math.min(360, width * 0.5)
                        cellHeight: 100

                        delegate: Item
                        {
                            property var info : modelData

                            width: GridView.view.cellWidth
                            height: GridView.view.cellHeight

                            FloatingCardDelegate
                            {
                                id: _delegate

                                anchors.fill: parent
                                anchors.margins: Maui.Style.space.medium
                                label1.text: info.name
                                label1.font.pointSize: Maui.Style.fontSizes.big
                                label1.font.weight: Font.Bold
                                label1.font.bold: true
                                label3.text: info.packageArch
                                label2.text: Maui.Handy.formatSize(info.size)
                                iconSource: FB.FM.iconName(info.name)
                                iconSizeHint: Maui.Style.iconSizes.large

                                onClicked:
                                {
                                    _packagesGrid.currentIndex = index

                                    if(Maui.Handy.singleClick || Maui.Handy.hasTransientTouchInput)
                                    {
                                        animate( _delegate.mapToItem(control, 0, 0), FB.FM.iconName(info.name))
                                        control.packageClicked(index)
                                    }
                                }

                                onDoubleClicked:
                                {
                                    _packagesGrid.currentIndex = index
                                    if(!Maui.Handy.singleClick)
                                    {
                                        animate(_delegate.mapToItem(control, 0, 0), FB.FM.iconName(info.name))
                                        control.packageClicked(index)
                                    }
                                }
                            }
                        }
                    }
                }

                SectionTitle
                {
                    id: _div3
                    title: i18n("Screenshots")
                    description: i18n("Previews of the package running.")

                    ListView
                    {
                        id: _screenshotsSection

                        Layout.fillWidth: true
                        Layout.preferredHeight: 500
                        model: control.imagesInfo
                        spacing: 0
                        orientation: ListView.Horizontal

                        highlightFollowsCurrentItem: true
                        highlightMoveDuration: 0
                        snapMode: ListView.SnapOneItem
                        highlightRangeMode: ListView.StrictlyEnforceRange
                        keyNavigationEnabled: true
                        keyNavigationWraps : true

                        BusyIndicator
                        {
                            anchors.centerIn: parent
                            running: _screenshotsSection.count === 0
                        }

                        Timer
                        {
                            id: _screenshotsSectionTimer
                            interval: 8000
                            repeat: true
                            running: true
                            onTriggered: _screenshotsSection.cycleSlideForward()
                        }

                        Row
                        {
                            spacing: Maui.Style.space.medium
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.margins: Maui.Style.space.big

                            Repeater
                            {
                                model: _screenshotsSection.count

                                Rectangle
                                {
                                    width: Maui.Style.iconSizes.tiny
                                    height: width
                                    radius: width
                                    color: Maui.Theme.textColor
                                    opacity: index === _screenshotsSection.currentIndex ? 1 : 0.5
                                }
                            }
                        }

                        delegate: MouseArea
                        {
                            height: ListView.view.height
                            width: ListView.view.width

                            onClicked:
                            {
                                if(Maui.Handy.singleClick || Maui.Handy.hasTransientTouchInput)
                                {
                                    _imageViewerDialog.source = modelData.pic
                                    _imageViewerDialog.open()
                                }
                            }

                            onDoubleClicked:
                            {
                                if(!Maui.Handy.singleClick)
                                {
                                    _imageViewerDialog.source = modelData.pic
                                    _imageViewerDialog.open()
                                }
                            }

                            BusyIndicator
                            {
                                anchors.centerIn: parent
                                running: _img.status === Image.Loading
                            }

                            Image
                            {
                                id: _img
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectFit

                                source: modelData.pic

                                verticalAlignment: Qt.AlignVCenter
                                horizontalAlignment: Qt.AlignHCenter
                            }
                        }

                        function cycleSlideForward() {
                            _screenshotsSectionTimer.restart();

                            if (_screenshotsSection.currentIndex === _screenshotsSection.count - 1) {
                                _screenshotsSection.currentIndex = 0;
                            } else {
                                _screenshotsSection.incrementCurrentIndex();
                            }
                        }

                        function cycleSlideBackward() {
                            _screenshotsSectionTimer.restart();

                            if (_screenshotsSection.currentIndex === 0) {
                                _screenshotsSection.currentIndex = _screenshotsSection.count - 1;
                            } else {
                                _screenshotsSection.decrementCurrentIndex();
                            }
                        }
                    }
                }


                Flow
                {
                    Layout.fillWidth: true
                    //                    Layout.preferredHeight: Maui.Style.toolBarHeight* 1.5
                    //                    Layout.margins: Maui.Style.space.medium

                    spacing: Maui.Style.space.big

                    Repeater
                    {
                        model: String(appInfo.tags).split(",")

                        delegate: Maui.Chip
                        {
                            showCloseButton: false
                            //                            width: implicitWidth
                            label.text: modelData
                            iconSource: "tag"
                            color: "yellow"
                            onClicked: control.tagClicked(modelData)
                        }
                    }


                }

                FeatureStrip
                {
                    id: _moreLike

                    title: i18n("More from ") + appInfo.personid
                    subtitle: i18n("More packages from this user")
                    category: _categoriesList.baseCategory()
                    list.user: appInfo.personid

                    pageSize: 4
                    sort: NX.Store.HIGHEST_RATED
                }
            }
        }
    }

    Maui.Icon
    {
        id: _aniImg
        visible: _aniX.running
        parent: ApplicationWindow.overlay
        source: imagesInfo[0].pic
        height: 200
        width: 200

        NumberAnimation on height
        {
            running: _aniY.running
            from: 200
            to: Maui.Style.iconSizes.medium
            duration: _aniY.duration
        }

        NumberAnimation on width
        {
            running: _aniY.running
            from: 200
            to: Maui.Style.iconSizes.medium
            duration: _aniY.duration
        }

        NumberAnimation on x
        {
            id: _aniX
            running: false
            from: _aniImg.x; to: (_swipeView.width/2)
            duration: Maui.Style.units.longDuration * 5
            loops: 1
            easing.type: Easing.OutQuad
        }

        NumberAnimation on y
        {
            id: _aniY
            running: false
            easing.type: Easing.OutQuad
            from: _aniImg.y; to: 0
            duration: Maui.Style.units.longDuration * 5
            loops: 1
        }

        Connections
        {
            target: _aniY
            function onFinished()
            {
                goToProgressView()
            }
        }
    }

    Popup
    {
        id: _imageViewerDialog
        parent: control
        background: Rectangle
        {
            color: "#333"
            opacity: 0.5
        }

        modal: true

        property alias source :_imageViewer.source
        height: control.height
        width: control.width

        Maui.ImageViewer
        {
            id: _imageViewer

            anchors.fill: parent
        }

        Maui.CloseButton
        {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: Maui.Style.space.big

            onClicked: _imageViewerDialog.close()
        }
    }

    function goToProgressView()
    {
        _swipeView.currentIndex = root.views.progress
    }

    function animate(pos, icon)
    {
        _aniImg.source = icon

        _aniImg.x = pos.x
        _aniImg.y = pos.y

        _aniX.start()
        _aniY.start()
    }

    function scrollTo(section)
    {
        shouldAnimateScroll = true;

        switch (section) {
        case AppPage.Sections.Description:
            _scrollablePage.contentItem.contentY = _div1.y;
            break;
        case AppPage.Sections.Details:
            _scrollablePage.contentItem.contentY = _div2.y;
            break;
        case AppPage.Sections.Packages:
            _scrollablePage.contentItem.contentY = _div2.y;
            break;
        case AppPage.Sections.Screenshots:
            _scrollablePage.contentItem.contentY = _screenshotsSection.y;
            break;
        case AppPage.Sections.Changelog:
            _scrollablePage.contentItem.contentY = _div5.y;
            break;
        case AppPage.Sections.Comments:
            _scrollablePage.contentItem.contentY = _div6.y;
            break;
        }

        scrollAnimationResetTimer.start()
    }
}
