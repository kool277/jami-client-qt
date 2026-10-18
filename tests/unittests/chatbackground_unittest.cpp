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

#include "app/chatbackground.h"

#include <gtest/gtest.h>

namespace {

struct ExpectedPreset
{
    const char* id;
    const char* lightStart;
    const char* lightEnd;
    const char* darkStart;
    const char* darkEnd;
};

// The presets every Jami client offers, in the order they are offered.
const ExpectedPreset expectedPresets[] = {
    {"sky", "#dceefb", "#dceefb", "#0f2a3d", "#0f2a3d"},
    {"mint", "#dcf2e3", "#dcf2e3", "#0f2e22", "#0f2e22"},
    {"sand", "#f5ead7", "#f5ead7", "#2e2614", "#2e2614"},
    {"rose", "#f8dee5", "#f8dee5", "#33161f", "#33161f"},
    {"lavender", "#e7e1f7", "#e7e1f7", "#221a3a", "#221a3a"},
    {"slate", "#dde2e8", "#dde2e8", "#1c232b", "#1c232b"},
    {"sunrise", "#fde2c8", "#f8c8dc", "#3a2418", "#3a1a2a"},
    {"ocean", "#cde8f6", "#d9d4f5", "#0e2a3a", "#211c3e"},
    {"meadow", "#dff2d8", "#cfeaf0", "#13301a", "#0f2c33"},
    {"dusk", "#e3d9f2", "#f6d9e4", "#2b2445", "#3b2236"},
};

QString
defaultChoice()
{
    return Settings::defaultValue(Settings::Key::ChatBackground).toString();
}

} // namespace

TEST(ChatBackground, OffersThePresetsOfAllTheClientsInTheirOrder)
{
    QStringList ids;
    for (const auto& preset : ChatBackground::presets())
        ids << preset.id;

    QStringList expectedIds;
    for (const auto& preset : expectedPresets)
        expectedIds << preset.id;
    EXPECT_EQ(ids, expectedIds);
}

TEST(ChatBackground, PaintsEachPresetInTheVariantOfTheTheme)
{
    for (const auto& preset : expectedPresets) {
        const auto light = ChatBackground::colors(preset.id, false);
        ASSERT_TRUE(light) << preset.id;
        EXPECT_EQ(light->start, QColor(preset.lightStart)) << preset.id;
        EXPECT_EQ(light->end, QColor(preset.lightEnd)) << preset.id;

        const auto dark = ChatBackground::colors(preset.id, true);
        ASSERT_TRUE(dark) << preset.id;
        EXPECT_EQ(dark->start, QColor(preset.darkStart)) << preset.id;
        EXPECT_EQ(dark->end, QColor(preset.darkEnd)) << preset.id;
    }
}

// The text drawn on the chat background (dates, events) must stay readable.
TEST(ChatBackground, PresetsAreLightInTheLightThemeAndDarkInTheDarkOne)
{
    for (const auto& preset : ChatBackground::presets()) {
        for (const auto& color : {preset.light.start, preset.light.end})
            EXPECT_GT(color.lightness(), 192) << preset.id.toStdString();
        for (const auto& color : {preset.dark.start, preset.dark.end})
            EXPECT_LT(color.lightness(), 64) << preset.id.toStdString();
    }
}

TEST(ChatBackground, TheDefaultKeepsTheThemeBackground)
{
    EXPECT_FALSE(ChatBackground::colors(defaultChoice(), false));
    EXPECT_FALSE(ChatBackground::colors(defaultChoice(), true));
}

TEST(ChatBackground, PaintsACustomColorAsIsInBothThemes)
{
    for (const auto darkTheme : {false, true}) {
        const auto colors = ChatBackground::colors("#336699", darkTheme);
        ASSERT_TRUE(colors);
        EXPECT_EQ(colors->start, QColor(0x33, 0x66, 0x99));
        EXPECT_EQ(colors->end, QColor(0x33, 0x66, 0x99));
    }
}

TEST(ChatBackground, ReadsBackWhatWasStored)
{
    for (const auto& stored :
         {defaultChoice(), QString("mint"), QString("dusk"), QString("#a1b2c3"), QString("#A1B2C3")})
        EXPECT_EQ(ChatBackground::parse(stored), stored) << stored.toStdString();
}

// The settings file may hold anything: a value from another version of Jami, or one edited by hand.
TEST(ChatBackground, TakesAStoredValueItCannotUseForTheDefault)
{
    for (const auto& stored :
         {"", "gone", "Sky", "sky ", "red", "#12345", "#1234567", "#12345g", "#123456\n", "123456", "#80123456"}) {
        EXPECT_EQ(ChatBackground::parse(stored), defaultChoice()) << stored;
        EXPECT_FALSE(ChatBackground::colors(stored, false)) << stored;
        EXPECT_FALSE(ChatBackground::colors(stored, true)) << stored;
    }
}
