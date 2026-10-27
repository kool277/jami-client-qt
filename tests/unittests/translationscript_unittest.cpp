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

#include "app/translationscript.h"

#include <QLocale>

#include <gtest/gtest.h>

TEST(TranslationScript, WritesUzbekInTheLatinAlphabetOf2026)
{
    EXPECT_EQ(inTranslationScript("chorshanba", "uz-Latn-2026"), QString("çorşanba"));
    EXPECT_EQ(inTranslationScript("DUSHANBA", "uz-Latn-2026"), QString("DUŞANBA"));
    EXPECT_EQ(inTranslationScript("Shanba", "uz-Latn-2026"), QString("Şanba"));
    EXPECT_EQ(inTranslationScript("Gʻalaba, oʻtgan hafta", "uz-Latn-2026"), QString("Ğalaba, ötgan hafta"));
}

TEST(TranslationScript, LeavesTheOtherTranslationsAsTheyAre)
{
    EXPECT_EQ(inTranslationScript("chorshanba", "uz"), QString("chorshanba"));
    EXPECT_EQ(inTranslationScript("chorshanba", "uz_UZ"), QString("chorshanba"));
    EXPECT_EQ(inTranslationScript("Thursday", "en"), QString("Thursday"));
}

TEST(TranslationScript, WritesWhatQLocaleWritesForTheTranslation)
{
    const QLocale locale("uz-Latn-2026");

    EXPECT_EQ(inTranslationScript(locale.dayName(3), "uz-Latn-2026"), QString("çorşanba"));
    // Named apart from the Latin alphabet of 1995 in the list of languages.
    EXPECT_EQ(inTranslationScript(locale.nativeLanguageName(), "uz-Latn-2026"), QString("özbek"));
    EXPECT_NE(inTranslationScript(locale.nativeLanguageName(), "uz-Latn-2026"), QLocale("uz").nativeLanguageName());
}
