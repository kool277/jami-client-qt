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

#pragma once

#include "appsettingsmanager.h"

#include <QColor>
#include <QList>
#include <QRegularExpression>
#include <QString>

#include <optional>

// The chat background chosen in the appearance settings (Settings::Key::ChatBackground): the
// setting's default for the theme's own background, the id of one of the presets below, or a
// custom "#rrggbb" color, painted as is in both themes.
namespace ChatBackground {

// A gradient from the top-left to the bottom-right corner, plain when both colors are the same.
struct Colors
{
    QColor start;
    QColor end;
};

// Each preset has a light and a dark variant, so that the text drawn on the chat background
// (dates, events) stays readable with both themes. The other Jami clients offer the same presets.
struct Preset
{
    QString id;
    Colors light;
    Colors dark;
};

inline const QList<Preset>&
presets()
{
    static const QList<Preset> presets {
        {"sky", {"#dceefb", "#dceefb"}, {"#0f2a3d", "#0f2a3d"}},
        {"mint", {"#dcf2e3", "#dcf2e3"}, {"#0f2e22", "#0f2e22"}},
        {"sand", {"#f5ead7", "#f5ead7"}, {"#2e2614", "#2e2614"}},
        {"rose", {"#f8dee5", "#f8dee5"}, {"#33161f", "#33161f"}},
        {"lavender", {"#e7e1f7", "#e7e1f7"}, {"#221a3a", "#221a3a"}},
        {"slate", {"#dde2e8", "#dde2e8"}, {"#1c232b", "#1c232b"}},
        {"sunrise", {"#fde2c8", "#f8c8dc"}, {"#3a2418", "#3a1a2a"}},
        {"ocean", {"#cde8f6", "#d9d4f5"}, {"#0e2a3a", "#211c3e"}},
        {"meadow", {"#dff2d8", "#cfeaf0"}, {"#13301a", "#0f2c33"}},
        {"dusk", {"#e3d9f2", "#f6d9e4"}, {"#2b2445", "#3b2236"}},
    };
    return presets;
}

// The choice a stored value holds: the value itself if it is a preset id or a #rrggbb color,
// otherwise the default, which is also what a value written by another version of Jami means.
inline QString
parse(const QString& value)
{
    static const QRegularExpression customColor(QRegularExpression::anchoredPattern("#[0-9a-fA-F]{6}"));
    if (customColor.match(value).hasMatch())
        return value;
    for (const auto& preset : presets()) {
        if (preset.id == value)
            return value;
    }
    return Settings::defaultValue(Settings::Key::ChatBackground).toString();
}

// The colors to paint for a stored value with the light or dark theme, or none to keep the
// theme's background.
inline std::optional<Colors>
colors(const QString& value, bool darkTheme)
{
    const auto choice = parse(value);
    if (choice.startsWith('#'))
        return Colors {QColor(choice), QColor(choice)};
    for (const auto& preset : presets()) {
        if (preset.id == choice)
            return darkTheme ? preset.dark : preset.light;
    }
    return std::nullopt;
}

} // namespace ChatBackground
