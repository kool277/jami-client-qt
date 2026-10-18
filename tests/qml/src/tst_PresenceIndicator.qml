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

import net.jami.Models 1.1
import net.jami.Constants 1.1

import "../../../src/app/commoncomponents"

PresenceIndicator {
    id: uut

    TestCase {
        name: "Presence Indicator Color Test"

        function test_color() {
            compare(uut.color, JamiTheme.presenceGreen)

            uut.status = Account.Status.TRYING

            compare(uut.color, JamiTheme.unPresenceOrange)

            uut.status = Account.Status.UNREGISTERED

            compare(uut.color, JamiTheme.notificationRed)
        }

        function test_announcesAnOnlineContact() {
            // 1 and 2 are a contact's presence, as the conversation list shows it.
            for (const presence of [1, 2]) {
                uut.status = presence
                compare(uut.Accessible.role, Accessible.Graphic)
                compare(uut.Accessible.name, JamiStrings.oneToOnePresenceOnline)
                verify(!uut.Accessible.ignored)
            }

            // An account's status is not announced as a contact's presence.
            uut.status = Account.Status.REGISTERED
            verify(uut.Accessible.ignored)
        }
    }
}
