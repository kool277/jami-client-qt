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
import Qt.labs.platform
import Qt5Compat.GraphicalEffects
import net.jami.Adapters 1.1
import net.jami.Constants 1.1
import net.jami.Enums 1.1
import "../../commoncomponents"

// The chat backgrounds to choose from, as round swatches: the theme's own background, the
// presets in the variant of the current theme, and a color picked in a color dialog.
Flow {
    id: root

    readonly property string defaultChoice: UtilsAdapter.getDefault(Settings.Key.ChatBackground)
    readonly property bool customColorChosen: UtilsAdapter.chatBackground.startsWith("#")
    readonly property var presetNames: ({
            "sky": JamiStrings.chatBackgroundSky,
            "mint": JamiStrings.chatBackgroundMint,
            "sand": JamiStrings.chatBackgroundSand,
            "rose": JamiStrings.chatBackgroundRose,
            "lavender": JamiStrings.chatBackgroundLavender,
            "slate": JamiStrings.chatBackgroundSlate,
            "sunrise": JamiStrings.chatBackgroundSunrise,
            "ocean": JamiStrings.chatBackgroundOcean,
            "meadow": JamiStrings.chatBackgroundMeadow,
            "dusk": JamiStrings.chatBackgroundDusk
        })

    function choose(chatBackground) {
        UtilsAdapter.setAppValue(Settings.Key.ChatBackground, chatBackground);
    }

    // Chooses a color picked in the color dialog, which may hold an alpha channel.
    function chooseCustomColor(color) {
        choose(Qt.rgba(color.r, color.g, color.b, 1).toString());
    }

    spacing: 6

    Swatch {
        objectName: "defaultChatBackground"

        text: JamiStrings.chatBackgroundDefault
        checked: UtilsAdapter.chatBackground === root.defaultChoice

        onClicked: root.choose(root.defaultChoice)

        // The theme's background, crossed out.
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: JamiTheme.globalBackgroundColor

            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: 2
                rotation: -45
                color: JamiTheme.menuSeparatorColor
            }
        }
    }

    Repeater {
        model: UtilsAdapter.getChatBackgroundPresetIds()

        Swatch {
            id: presetSwatch

            required property string modelData
            readonly property var colors: UtilsAdapter.getChatBackgroundColors(modelData, JamiTheme.darkTheme)

            objectName: modelData

            text: root.presetNames[modelData]
            checked: UtilsAdapter.chatBackground === modelData

            onClicked: root.choose(modelData)

            // Turned so that the gradient goes from the top-left to the bottom-right.
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                rotation: -45
                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: presetSwatch.colors[0]
                    }
                    GradientStop {
                        position: 1
                        color: presetSwatch.colors[1]
                    }
                }
            }
        }
    }

    Swatch {
        objectName: "customChatBackground"

        text: JamiStrings.chatBackgroundCustomColor
        checked: root.customColorChosen

        onClicked: colorDialogComponent.createObject(root).open()

        // The chosen color, or a rainbow until one is chosen.
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: root.customColorChosen ? UtilsAdapter.chatBackground : "transparent"
            visible: root.customColorChosen
        }

        Rectangle {
            id: rainbowShape

            anchors.fill: parent
            radius: width / 2
            visible: false
        }

        ConicalGradient {
            anchors.fill: parent
            source: rainbowShape
            visible: !root.customColorChosen
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#f44336"
                }
                GradientStop {
                    position: 1 / 6
                    color: "#ffeb3b"
                }
                GradientStop {
                    position: 2 / 6
                    color: "#4caf50"
                }
                GradientStop {
                    position: 3 / 6
                    color: "#00bcd4"
                }
                GradientStop {
                    position: 4 / 6
                    color: "#3f51b5"
                }
                GradientStop {
                    position: 5 / 6
                    color: "#e91e63"
                }
                GradientStop {
                    position: 1
                    color: "#f44336"
                }
            }
        }

        Component {
            id: colorDialogComponent

            ColorDialog {
                title: JamiStrings.chatBackgroundCustomColor
                currentColor: root.customColorChosen ? UtilsAdapter.chatBackground : JamiTheme.globalBackgroundColor

                onAccepted: {
                    root.chooseCustomColor(color);
                    destroy();
                }
                onRejected: destroy()
            }
        }
    }

    // A round swatch showing a chat background, outlined in the accent color when chosen.
    component Swatch: AbstractButton {
        id: swatch

        // What the swatch shows, inside its round border.
        default property alias face: face.data

        implicitWidth: 50
        implicitHeight: 50
        padding: 5

        Accessible.role: Accessible.RadioButton
        Accessible.name: text

        contentItem: Item {
            Item {
                id: face

                anchors.fill: parent
            }

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.width: 1
                border.color: JamiTheme.menuSeparatorColor
            }
        }

        background: Rectangle {
            radius: width / 2
            color: "transparent"
            border.width: 3
            border.color: JamiTheme.tintedBlue
            opacity: swatch.checked ? 1 : 0.5
            visible: swatch.checked || swatch.visualFocus
        }

        MaterialToolTip {
            parent: swatch
            visible: swatch.hovered
            delay: Qt.styleHints.mousePressAndHoldInterval
            text: swatch.text
        }
    }
}
