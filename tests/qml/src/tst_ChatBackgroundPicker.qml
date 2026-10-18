/*
 * Copyright (C) 2026 Savoir-faire Linux Inc.
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

import "../../../src/app/settingsview/components"

ChatBackgroundPicker {
    id: uut

    width: 400

    TestCase {
        name: "Chat background picker"
        when: windowShown

        readonly property var presetIds: ["sky", "mint", "sand", "rose", "lavender", "slate", "sunrise", "ocean", "meadow", "dusk"]

        function swatch(name) {
            const item = findChild(uut, name);
            verify(item, name);
            return item;
        }

        function chosenSwatches() {
            return ["defaultChatBackground", "customChatBackground"].concat(presetIds).filter(name => swatch(name).checked);
        }

        function cleanup() {
            UtilsAdapter.setToDefault(Settings.Key.ChatBackground);
        }

        function test_offersTheDefaultEveryPresetAndACustomColor() {
            compare(swatch("defaultChatBackground").Accessible.name, JamiStrings.chatBackgroundDefault);
            compare(swatch("sky").Accessible.name, JamiStrings.chatBackgroundSky);
            compare(swatch("dusk").Accessible.name, JamiStrings.chatBackgroundDusk);
            compare(swatch("customChatBackground").Accessible.name, JamiStrings.chatBackgroundCustomColor);
            for (const name of ["defaultChatBackground", "customChatBackground"].concat(presetIds))
                compare(swatch(name).Accessible.role, Accessible.RadioButton, name);
        }

        function test_showsThePresetsInTheVariantOfTheTheme() {
            const ocean = swatch("ocean");
            compare(ocean.colors[0].toString(), JamiTheme.darkTheme ? "#0e2a3a" : "#cde8f6");
            compare(ocean.colors[1].toString(), JamiTheme.darkTheme ? "#211c3e" : "#d9d4f5");
        }

        function test_marksOnlyTheChosenBackground() {
            compare(chosenSwatches(), ["defaultChatBackground"]);
            UtilsAdapter.setAppValue(Settings.Key.ChatBackground, "mint");
            compare(chosenSwatches(), ["mint"]);
            UtilsAdapter.setAppValue(Settings.Key.ChatBackground, "#336699");
            compare(chosenSwatches(), ["customChatBackground"]);
        }

        function test_marksTheDefaultForAStoredValueItCannotUse() {
            UtilsAdapter.setAppValue(Settings.Key.ChatBackground, "gone");
            compare(chosenSwatches(), ["defaultChatBackground"]);
        }

        function test_choosesAPresetOrTheDefault() {
            mouseClick(swatch("ocean"));
            compare(UtilsAdapter.getAppValue(Settings.Key.ChatBackground), "ocean");
            compare(chosenSwatches(), ["ocean"]);

            mouseClick(swatch("defaultChatBackground"));
            compare(UtilsAdapter.getAppValue(Settings.Key.ChatBackground), UtilsAdapter.getDefault(Settings.Key.ChatBackground));
            compare(chosenSwatches(), ["defaultChatBackground"]);
        }

        function test_choosesTheColorPickedInTheColorDialog() {
            uut.chooseCustomColor(Qt.rgba(0x12 / 255, 0x34 / 255, 0x56 / 255, 1));
            compare(UtilsAdapter.getAppValue(Settings.Key.ChatBackground), "#123456");
            compare(chosenSwatches(), ["customChatBackground"]);

            // The color dialog may hold an alpha channel; the chat background is opaque.
            uut.chooseCustomColor(Qt.rgba(0x65 / 255, 0x43 / 255, 0x21 / 255, 0.5));
            compare(UtilsAdapter.getAppValue(Settings.Key.ChatBackground), "#654321");
        }
    }
}
