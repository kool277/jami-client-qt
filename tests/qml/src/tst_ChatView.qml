/*
 * Copyright (C) 2021-2026 Savoir-faire Linux Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick
import QtTest

import net.jami.Adapters 1.1
import net.jami.Models 1.1
import net.jami.Constants 1.1
import net.jami.Enums 1.1

import "../../../src/app/"
import "../../../src/app/mainview"
import "../../../src/app/mainview/components"
import "../../../src/app/commoncomponents"

TestWrapper {
    ListSelectionView {
        id: viewNode
        objectName: "ConversationView"
        managed: false

        leftPaneItem: Rectangle {}

        rightPaneItem: ChatView {
            id: uut

            inCallView: false

            TestCase {
                name: "Check basic visibility for header buttons"
                function test_checkBasicVisibility() {
                    const chatviewHeader = findChild(uut, "chatViewHeader")
                    const detailsButton = findChild(uut, "detailsButton")
                    CurrentConversation.isRequest = false
                    compare(detailsButton.visible, true)

                    const chatViewFooter = findChild(uut, "chatViewFooter")
                    CurrentConversation.isTemporary = true
                    compare(chatViewFooter.visible, true)
                    CurrentConversation.isTemporary = false
                    CurrentConversation.isRequest = true
                    compare(chatViewFooter.visible, false)
                    CurrentConversation.isRequest = false
                    CurrentConversation.needsSyncing = true
                    compare(chatViewFooter.visible, false)
                }

                function test_headerTitleUpdatesOnConversationTitleChange() {
                    const chatviewHeader = findChild(uut, "chatViewHeader")
                    const titleLabel = findChild(chatviewHeader, "chatViewHeaderTitle")

                    verify(titleLabel !== null)

                    CurrentConversation.title = "Name A"
                    tryCompare(titleLabel, "eText", "Name A", 1000)

                    CurrentConversation.title = "Name B"
                    tryCompare(titleLabel, "eText", "Name B", 1000)
                }

                function test_paintsTheChatBackgroundChosenInTheSettings() {
                    const chatBackground = findChild(uut, "chatBackground")
                    const headerGradient = findChild(uut, "chatViewHeaderGradient")

                    // By default, the conversation colour shows through.
                    UtilsAdapter.setToDefault(Settings.Key.ChatBackground)
                    verify(!chatBackground.painted)
                    verify(!headerGradient.layer.enabled)

                    // The messages fade under the header into the chosen background.
                    UtilsAdapter.setAppValue(Settings.Key.ChatBackground, "ocean")
                    verify(chatBackground.painted)
                    compare(chatBackground.colors[0].toString(), JamiTheme.darkTheme ? "#0e2a3a" : "#cde8f6")
                    compare(chatBackground.colors[1].toString(), JamiTheme.darkTheme ? "#211c3e" : "#d9d4f5")
                    verify(headerGradient.layer.enabled)

                    UtilsAdapter.setToDefault(Settings.Key.ChatBackground)
                    verify(!chatBackground.painted)
                    verify(!headerGradient.layer.enabled)
                }
            }
        }
    }
}
