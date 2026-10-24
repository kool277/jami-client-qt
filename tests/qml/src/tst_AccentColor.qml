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
import QtQuick.Controls
import QtQuick.Controls.Universal
import QtTest

import net.jami.Constants 1.1

import "../../../src/app/commoncomponents"

Item {
    id: root

    width: 400
    height: 200

    NewMaterialButton {
        id: accentButton

        filledButton: true
        iconSource: JamiResources.add_24dp_svg
        text: "Accent"
    }

    NewMaterialButton {
        id: redButton

        y: 50
        filledButton: true
        iconSource: JamiResources.add_24dp_svg
        text: "Red"
        color: JamiTheme.buttonTintedRed
    }

    TextField {
        id: textField

        y: 100
    }

    // Gives the style the theme's accent, as the application window does.
    Item {
        y: 150
        width: 400
        height: 50

        Universal.accent: JamiTheme.tintedBlue

        MaterialLineEdit {
            id: lineEdit

            width: 200
        }
    }

    TestCase {
        name: "Accent color"
        when: windowShown

        property bool initialDarkTheme

        function initTestCase() {
            initialDarkTheme = JamiTheme.darkTheme;
        }

        function cleanup() {
            JamiTheme.setTheme(initialDarkTheme);
        }

        function test_accentIsKhakiInBothThemes() {
            JamiTheme.setTheme(false);
            compare(JamiTheme.tintedBlue.toString(), "#666600");
            compare(JamiTheme.buttonTintedBlue.toString(), "#666600");
            JamiTheme.setTheme(true);
            compare(JamiTheme.tintedBlue.toString(), "#caca73");
            compare(JamiTheme.buttonTintedBlue.toString(), "#caca73");
        }

        // The label and the icon fade to their color when the theme changes.
        function compareContentColor(button, expected) {
            tryCompare(button.contentItem, "color", expected);
            wait(JamiTheme.shortFadeDuration + 100);
            compare(button.icon.color, expected);
        }

        function test_filledAccentButtonContentContrastsWithItsFill() {
            JamiTheme.setTheme(false);
            compareContentColor(accentButton, JamiTheme.whiteColor);
            // The dark theme's accent is light, so what is drawn on it is dark.
            JamiTheme.setTheme(true);
            compareContentColor(accentButton, JamiTheme.primaryTextColor);
        }

        function test_filledRedButtonContentStaysWhite() {
            for (const dark of [false, true]) {
                JamiTheme.setTheme(dark);
                compareContentColor(redButton, JamiTheme.whiteColor);
            }
        }

        function test_textSelectionUsesTheAccent() {
            compare(textField.selectionColor.toString(), "#666600");
            compare(textField.selectedTextColor.toString(), "#ffffff");
        }

        function test_selectedTextContrastsWithTheThemeAccent() {
            JamiTheme.setTheme(false);
            compare(lineEdit.selectionColor.toString(), "#666600");
            compare(lineEdit.selectedTextColor.toString(), "#ffffff");
            // The dark theme's accent is light, so the selected text is dark.
            JamiTheme.setTheme(true);
            compare(lineEdit.selectionColor.toString(), "#caca73");
            compare(lineEdit.selectedTextColor.toString(), "#000000");
        }
    }
}
