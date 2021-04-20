/*
 * Copyright (c) 2021 Open Mobile Platform LLC.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import QtQuick 2.2
import QtQuick.Window 2.2 as QuickWindow
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Sailfish.Browser 1.0
import Sailfish.Policy 1.0
import Sailfish.WebView.Controls 1.0
import Sailfish.WebEngine 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.dbus 2.0
import "." as Browser
import "../../shared" as Shared

Item {
    id: root
    property int horizontalOffset
    property int iconWidth
    readonly property int verticalPadding: 3 * Theme.paddingSmall

    height: content.height + verticalPadding * 2

    Column {
        id: content
        width: parent.width
        spacing: Theme.paddingLarge
        y: verticalPadding

        Column {
            width: parent.width

            OverlayListItem {
                height: Theme.itemSizeSmall
                iconWidth: root.iconWidth
                horizontalOffset: root.horizontalOffset
                iconSource: "image://theme/icon-m-tab-new"
                //% "New tab"
                text: qsTrId("sailfish_browser-la-new_tab")
                onClicked: {
                    webView.privateMode = false
                    overlay.toolBar.enterNewTabUrl()
                }
            }

            OverlayListItem {
                height: Theme.itemSizeSmall
                iconWidth: root.iconWidth
                horizontalOffset: root.horizontalOffset
                iconSource: "image://theme/icon-m-incognito-new"
                //% "New private tab"
                text: qsTrId("sailfish_browser-la-new_private_tab")
                onClicked: {
                    webView.privateMode = true
                    overlay.toolBar.enterNewTabUrl()
                }
            }
        }

        Column {
            width: parent.width

            OverlayListItem {
                height: Theme.itemSizeSmall
                iconWidth: root.iconWidth
                horizontalOffset: root.horizontalOffset
                iconSource: "image://theme/icon-m-search-on-page"
                enabled: webView.contentItem
                //% "Search on page"
                text: qsTrId("sailfish_browser-la-search_on_page")

                onClicked: {
                    overlay.toolBar.findInPageActive = true
                    overlay.toolBar.findInPage()
                }
            }

            OverlayListItem {
                height: Theme.itemSizeSmall
                iconWidth: root.iconWidth
                horizontalOffset: root.horizontalOffset
                iconSource: "image://theme/icon-m-add-to-grid"
                //% "Add to apps grid"
                text: qsTrId("sailfish_browser-la-add_to_apps_grid")
                onClicked: pageStack.animatorPush("AddToAppGridDialog.qml",
                                                  {
                                                      "url": url,
                                                      "title": title,
                                                      "desktopBookmarkWriter": desktopBookmarkWriter,
                                                      "bookmarkWriterParent": pageStack
                                                  })
            }

            OverlayListItem {
                height: Theme.itemSizeSmall
                iconWidth: root.iconWidth
                horizontalOffset: root.horizontalOffset
                iconSource: "image://theme/icon-m-file-download-as-pdf"
                //% "Save web page as PDF"
                text: qsTrId("sailfish_browser-la-save_as-pdf")

                onClicked: {
                    if (DownloadManager.pdfPrinting) {
                        pdfPrintingNotice.show()
                    } else {
                        overlay.toolBar.savePageAsPDF()
                    }
                }
            }
        }

        TextSwitch {
            // When changing theme or orientation, the offset changes. Strange behavior.
            leftMargin: Theme.paddingLarge * 2 + (Theme.colorScheme === Theme.LightOnDark ? Theme.paddingMedium * 2 : Theme.paddingMedium)

            height: Theme.itemSizeSmall
            enabled: webView.contentItem
            automaticCheck: false

            //: Label for text switch that reloads page in desktop mode
            //% "Desktop site"
            text: qsTrId("settings_browser-la-desktop_site")
            checked: webView.contentItem ? webView.contentItem.desktopMode : false
            onClicked: {
                overlay.animator.showChrome()
                webView.contentItem.desktopMode = !checked
            }
        }

        Column {
            width: parent.width

            OverlayListItem {
                height: Theme.itemSizeSmall
                iconWidth: root.iconWidth
                horizontalOffset: root.horizontalOffset
                iconSource: "image://theme/icon-m-favorite-selected"
                //% "Bookmarks"
                text: qsTrId("sailfish_browser-la-bookmarks")

                onClicked: {
                    overlay.animator.showChrome()
                    pageStack.push("../BookmarkPage.qml", { bookmarkModel: overlay.favoriteModel })
                }
            }

            OverlayListItem {
                height: Theme.itemSizeSmall
                iconWidth: root.iconWidth
                horizontalOffset: root.horizontalOffset
                //% "History"
                text: qsTrId("sailfish_browser-la-history")
                iconSource: "image://theme/icon-m-history"

                onClicked: {
                    overlay.animator.showChrome()
                    pageStack.push("../HistoryPage.qml", { model: overlay.historyModel })
                }
            }

            OverlayListItem {
                height: Theme.itemSizeSmall
                iconWidth: root.iconWidth
                horizontalOffset: root.horizontalOffset
                //% "Downloads"
                text: qsTrId("sailfish_browser-la-downloads")
                iconSource: "image://theme/icon-m-downloads"
                onClicked: settingsApp.call("showTransfers", [])
            }

            OverlayListItem {
                height: Theme.itemSizeSmall
                iconWidth: root.iconWidth
                horizontalOffset: root.horizontalOffset
                //% "Settings"
                text: qsTrId("sailfish_browser-la-setting")
                iconSource: "image://theme/icon-m-setting"

                onClicked: {
                    overlay.animator.showChrome()
                    pageStack.push(Qt.resolvedUrl("../SettingsPage.qml"))
                }
            }
        }
    }

    Notice {
        id: pdfPrintingNotice
        duration: 3000
        //% "Already saving pdf"
        text: qsTrId("sailfish_browser-la-already_printing_pdf")
        verticalOffset: -overlay.toolBar.rowHeight * overlay.toolBar.maxRowCount
    }

    DBusInterface {
        id: settingsApp
        service: "com.jolla.settings"
        iface: "com.jolla.settings.ui"
        path: "/com/jolla/settings/ui"
    }

    Component {
        id: desktopBookmarkWriter
        DesktopBookmarkWriter {
            onSaved: destroy()
        }
    }
}
