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

#include <QList>
#include <QPair>
#include <QString>

// Text that QLocale writes for a translation (language, day and month names), in the alphabet of
// the translation. QLocale writes Uzbek in the Latin alphabet of 1995 only; in the alphabet of
// 2026 (translation uz-Latn-2026, law OʻRQ-1184), oʻ, gʻ, sh and ch are ö, ğ, ş and ç.
inline QString
inTranslationScript(QString text, const QString& translation)
{
    if (translation != QStringLiteral("uz-Latn-2026"))
        return text;
    // QLocale writes oʻ and gʻ with ‘ (U+2018), the official spelling uses ʻ (U+02BB).
    static const QList<QPair<QString, QString>> letters {
        {QStringLiteral("O\u02BB"), QStringLiteral("Ö")},
        {QStringLiteral("o\u02BB"), QStringLiteral("ö")},
        {QStringLiteral("O\u2018"), QStringLiteral("Ö")},
        {QStringLiteral("o\u2018"), QStringLiteral("ö")},
        {QStringLiteral("G\u02BB"), QStringLiteral("Ğ")},
        {QStringLiteral("g\u02BB"), QStringLiteral("ğ")},
        {QStringLiteral("G\u2018"), QStringLiteral("Ğ")},
        {QStringLiteral("g\u2018"), QStringLiteral("ğ")},
        {QStringLiteral("SH"), QStringLiteral("Ş")},
        {QStringLiteral("Sh"), QStringLiteral("Ş")},
        {QStringLiteral("sh"), QStringLiteral("ş")},
        {QStringLiteral("CH"), QStringLiteral("Ç")},
        {QStringLiteral("Ch"), QStringLiteral("Ç")},
        {QStringLiteral("ch"), QStringLiteral("ç")},
    };
    for (const auto& [from, to] : letters)
        text.replace(from, to);
    return text;
}
