/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Vesa-Matti Hartikainen <vesa-matti.hartikainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import "components"

Page {
    id: page
    backNavigation: false

    property BrowserPage browserPage

    SilicaListView {
        id: list
        anchors.fill: parent

        header: Item {
            width: list.width
            height: tabs.height + 2 * Theme.paddingMedium

            Grid {
                id: tabs
                columns: 2
                rows: Math.ceil(browserPage.tabs.count / 2)
                spacing: Theme.paddingMedium
                anchors {
                    margins: Theme.paddingMedium
                    top: parent.top;
                    left: parent.left
                }

                Repeater {
                    model: browserPage.tabs
                    BackgroundItem {
                        width: list.width / 2 - 2 * Theme.paddingMedium
                        height: width

                        Rectangle {
                            anchors.fill: parent
                            color: Theme.highlightBackgroundColor
                            opacity: Theme.highlightBackgroundOpacity
                            visible: !thumb.visible
                        }

                        Label {
                            width: parent.width
                            anchors.centerIn: parent.Center
                            text: url
                            visible: !thumb.visible
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: Theme.secondaryColor
                            wrapMode:Text.WrapAnywhere
                        }

                        Image {
                            id: thumb
                            asynchronous: true
                            source: thumbPath.path
                            fillMode: Image.PreserveAspectCrop
                            sourceSize {
                                width: parent.width
                                height: width
                            }
                            visible: status !== Image.Error && thumbPath.path !== ""
                        }
                        onClicked: {
                            browserPage.loadTab(model.index)
                            window.pageStack.pop(browserPage, true)
                        }

                        Rectangle {
                            anchors.fill: parent

                            property bool active: pressed
                            property real highlightOpacity: 0.5

                            color: Theme.highlightBackgroundColor
                            opacity: active ? highlightOpacity : 0.0
                            Behavior on opacity {
                                FadeAnimation {
                                    duration: 100
                                }
                            }
                        }
                    }
                }
            }
        }

        PullDownMenu {
            MenuItem {
                //% "Close all tabs"
                text: qsTrId("sailfish_browser-me-close_all")
                onClicked: browserPage.closeAllTabs()
            }
        }

        model: browserPage.favorites

        delegate: BackgroundItem {
            width: list.width
            anchors.topMargin: Theme.paddingLarge

            FaviconImage {
                id: faviconImage
                anchors {
                    verticalCenter: titleLabel.verticalCenter
                    left: parent.left; leftMargin: Theme.paddingMedium
                }
                favicon: model.favicon
                link: url
            }

            Label {
                id: titleLabel
                anchors {
                    leftMargin: Theme.paddingMedium
                    left: faviconImage.right
                    verticalCenter: parent.verticalCenter
                }
                width: parent.width - x
                text: title
                truncationMode: TruncationMode.Fade
            }

            onClicked: {
                browserPage.load(url)
                window.pageStack.pop(browserPage, true)
            }
        }

        VerticalScrollDecorator {}
    }
}
