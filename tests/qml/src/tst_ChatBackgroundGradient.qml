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

import "../../../src/app/commoncomponents"

Item {
    width: 300
    height: 100

    ChatBackgroundGradient {
        id: background

        anchors.fill: parent
        colors: ["#cde8f6", "#d9d4f5"]
    }

    // The top of the same background, as faded under the chat header.
    ChatBackgroundGradient {
        id: band

        width: 300
        height: 40
        colors: background.colors
        area: Qt.rect(0, 0, 300, 100)
    }

    ChatBackgroundGradient {
        id: none

        anchors.fill: parent
    }

    TestCase {
        name: "Chat background gradient"

        // The gradient position the LinearGradient shader of Qt5Compat.GraphicalEffects paints
        // at a point of an item: it measures positions in fractions of the item's size.
        function gradientPosition(item, x, y) {
            const dx = item.end.x - item.start.x;
            const dy = item.end.y - item.start.y;
            const l = 1 / Math.sqrt(Math.pow(dx / item.width, 2) + Math.pow(dy / item.height, 2));
            const angle = Math.atan2(dx, dy);
            return l * ((x - item.start.x) / item.width * Math.sin(angle) + (y - item.start.y) / item.height * Math.cos(angle));
        }

        // Like CSS linear-gradient(135deg, start, end).
        function test_goesFromTheTopLeftToTheBottomRightCornerAlongLinesAt45Degrees() {
            fuzzyCompare(gradientPosition(background, 0, 0), 0, 1e-9);
            fuzzyCompare(gradientPosition(background, 300, 100), 1, 1e-9);
            fuzzyCompare(gradientPosition(background, 150, 50), 0.5, 1e-9);
            fuzzyCompare(gradientPosition(background, 90, 10), gradientPosition(background, 10, 90), 1e-9);
        }

        function test_continuesTheBackgroundOverAPartOfIt() {
            for (const point of [[0, 0], [300, 40], [120, 30], [10, 5]])
                fuzzyCompare(gradientPosition(band, point[0], point[1]), gradientPosition(background, point[0], point[1]), 1e-9, point);
        }

        function test_paintsNothingWithoutColors() {
            verify(background.visible);
            verify(!none.visible);
        }
    }
}
