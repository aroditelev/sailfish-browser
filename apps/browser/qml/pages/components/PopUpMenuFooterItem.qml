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

Rectangle {
    id: root
    property int iconWidth
    readonly property real overlayOpacity: 0.15

    height: Theme.itemSizeMedium
    color: Theme.colorScheme === Theme.LightOnDark ? "black" : "white"

    ColorOverlay {
        anchors.fill: parent
        source: parent
        color: Theme.primaryColor
        opacity: overlayOpacity
    }

    Row {
        id: content
        height: parent.height
        spacing: Theme.paddingLarge + Theme.paddingSmall + Theme.paddingSmall / 2
        anchors.centerIn: parent

        Shared.ExpandingButton {
            id: forwardButton
            expandedWidth: root.iconWidth
            icon.source: "image://theme/icon-m-forward"
            icon.opacity: enabled ? 1.0 : Theme.opacityLow
            enabled: webView.canGoForward
            onTapped: {
                webView.goForward()
                overlay.animator.showChrome()
            }
        }

        Shared.ExpandingButton {
            id: shareButton
            expandedWidth: root.iconWidth
            icon.source: "image://theme/icon-m-share"
            icon.opacity: enabled ? 1.0 : Theme.opacityLow
            enabled: webView.contentItem
            onTapped: {
                overlay.toolBar.shareActivePage()
                overlay.animator.showChrome()
            }
        }

        Shared.ExpandingButton {
            expandedWidth: root.iconWidth
            icon.source: overlay.toolBar.bookmarked ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
            icon.opacity: enabled ? 1.0 : Theme.opacityLow
            enabled: webView.contentItem
            onTapped: {
                if (overlay.toolBar.bookmarked) {
                    overlay.toolBar.removeActivePageFromBookmarks()
                } else {
                    overlay.toolBar.bookmarkActivePage()
                }
            }
        }

        Shared.ExpandingButton {
            id: reloadButton
            expandedWidth: root.iconWidth
            icon.source: webView.loading ? "image://theme/icon-m-reset" : "image://theme/icon-m-refresh"
            icon.opacity: enabled ? 1.0 : Theme.opacityLow
            enabled: webView.contentItem
            onTapped: {
                if (webView.loading) {
                    webView.stop()
                } else {
                    webView.reload()
                }
                overlay.animator.showChrome()
            }
        }
    }
}
