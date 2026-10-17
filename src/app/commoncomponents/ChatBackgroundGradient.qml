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
import Qt5Compat.GraphicalEffects

// Paints the colors of a chat background like the other Jami clients, as CSS
// linear-gradient(135deg, start, end) over `area`: the color changes along lines at 45 degrees,
// from the area's top-left corner to its bottom-right one. Two equal colors paint it plain, and
// nothing is painted without colors. With a `source`, only where that item is opaque is painted.
LinearGradient {
    id: root

    // The start and end colors, as UtilsAdapter.getChatBackgroundColors gives them.
    property var colors: []
    // The rectangle the gradient spans, in this item's coordinates.
    property rect area: Qt.rect(0, 0, width, height)
    readonly property bool painted: colors.length === 2

    visible: painted

    // The shader measures positions in fractions of this item's size: an end point on this
    // item's diagonal gives lines at 45 degrees, and this distance puts the end color at the
    // area's bottom-right corner.
    start: Qt.point(area.x, area.y)
    end: {
        const diagonal = Math.sqrt(width * width + height * height);
        const distance = diagonal > 0 ? (area.width + area.height) / (Math.SQRT2 * diagonal) : 1;
        return Qt.point(area.x + distance * width, area.y + distance * height);
    }
    gradient: Gradient {
        GradientStop {
            position: 0
            color: root.painted ? root.colors[0] : "transparent"
        }
        GradientStop {
            position: 1
            color: root.painted ? root.colors[1] : "transparent"
        }
    }
}
