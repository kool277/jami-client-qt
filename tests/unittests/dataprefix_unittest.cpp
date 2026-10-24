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

#include "app/utils.h"

#include <QDir>
#include <QTemporaryDir>

#include <gtest/gtest.h>

// Each test lays out directories under a temporary root: the compiled-in
// install prefix (<root>/build/install/share, where the build installed Jami)
// and the directory of the binary (<root>/home/jami/bin, where a release
// archive was extracted).
class DataPrefixFixture : public ::testing::Test
{
protected:
    void SetUp() override
    {
        ASSERT_TRUE(root.isValid());
        installPrefix = root.filePath("build/install/share");
        applicationDir = root.filePath("home/jami/bin");
        ASSERT_TRUE(QDir().mkpath(applicationDir));
    }

    void makeDir(const QString& path) { ASSERT_TRUE(QDir().mkpath(root.filePath(path))); }

    QTemporaryDir root;
    QString installPrefix;
    QString applicationDir;
};

TEST_F(DataPrefixFixture, UsesTheInstallPrefixWhenItHasJamiData)
{
    makeDir("build/install/share/jami");
    makeDir("home/jami/share/jami");

    EXPECT_EQ(Utils::dataPrefix(installPrefix, applicationDir), installPrefix);
}

TEST_F(DataPrefixFixture, UsesTheShareDirectoryNextToTheBinaryWhenTheInstallPrefixIsMissing)
{
    makeDir("home/jami/share/jami");

    EXPECT_EQ(Utils::dataPrefix(installPrefix, applicationDir), root.filePath("home/jami/share"));
}

TEST_F(DataPrefixFixture, KeepsTheInstallPrefixWhenNeitherHasJamiData)
{
    // A share/ directory next to the binary, but without Jami's data.
    makeDir("home/jami/share");

    EXPECT_EQ(Utils::dataPrefix(installPrefix, applicationDir), installPrefix);
}

TEST_F(DataPrefixFixture, LeavesTheDaemonItsOwnDataDirectoryWhenInstalled)
{
    makeDir("build/install/share/jami");
    makeDir("home/jami/share/jami");

    EXPECT_TRUE(Utils::daemonResourceDir(installPrefix, applicationDir).isEmpty());
}

TEST_F(DataPrefixFixture, GivesTheDaemonTheDataDirectoryNextToTheBinary)
{
    // An extracted release archive: the daemon's ringtones are in share/jami
    // next to bin/, not under the prefix it was built for.
    makeDir("home/jami/share/jami");

    EXPECT_EQ(Utils::daemonResourceDir(installPrefix, applicationDir), root.filePath("home/jami/share/jami"));
}
