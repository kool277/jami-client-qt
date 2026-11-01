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
#include <QFile>
#include <QFileInfo>
#include <QTemporaryDir>

#include <gtest/gtest.h>

// Each test lays out directories under a temporary root: the compiled-in
// install prefix (<root>/build/install/share, where the build installed Jami)
// and the binary (<root>/home/jami/bin/jami, where a release archive was
// extracted).
class DataPrefixFixture : public ::testing::Test
{
protected:
    void SetUp() override
    {
        ASSERT_TRUE(root.isValid());
        installPrefix = root.filePath("build/install/share");
        applicationFile = root.filePath("home/jami/bin/jami");
        ASSERT_TRUE(QDir().mkpath(root.filePath("home/jami/bin")));
        QFile binary(applicationFile);
        ASSERT_TRUE(binary.open(QIODevice::WriteOnly));
    }

    void makeDir(const QString& path) { ASSERT_TRUE(QDir().mkpath(root.filePath(path))); }

    // dataPrefix() resolves symlinks: the root's own path must have none.
    QTemporaryDir root {QFileInfo(QDir::tempPath()).canonicalFilePath() + "/dataprefix-XXXXXX"};
    QString installPrefix;
    QString applicationFile;
};

TEST_F(DataPrefixFixture, UsesTheInstallPrefixWhenItHasJamiData)
{
    makeDir("build/install/share/jami");
    makeDir("home/jami/share/jami");

    EXPECT_EQ(Utils::dataPrefix(installPrefix, applicationFile), installPrefix);
}

TEST_F(DataPrefixFixture, UsesTheShareDirectoryNextToTheBinaryWhenTheInstallPrefixIsMissing)
{
    makeDir("home/jami/share/jami");

    EXPECT_EQ(Utils::dataPrefix(installPrefix, applicationFile), root.filePath("home/jami/share"));
}

TEST_F(DataPrefixFixture, FollowsASymlinkToTheBinary)
{
    // Started through a symlink in another directory, such as
    // /usr/local/bin/jami, which has no share/ next to it.
    makeDir("home/jami/share/jami");
    makeDir("usr/local/bin");
    auto link = root.filePath("usr/local/bin/jami");
    ASSERT_TRUE(QFile::link(applicationFile, link));

    EXPECT_EQ(Utils::dataPrefix(installPrefix, link), root.filePath("home/jami/share"));
}

TEST_F(DataPrefixFixture, KeepsTheInstallPrefixWhenNeitherHasJamiData)
{
    // A share/ directory next to the binary, but without Jami's data.
    makeDir("home/jami/share");

    EXPECT_EQ(Utils::dataPrefix(installPrefix, applicationFile), installPrefix);
}

TEST_F(DataPrefixFixture, LeavesTheDaemonItsOwnDataDirectoryWhenInstalled)
{
    makeDir("build/install/share/jami");
    makeDir("home/jami/share/jami");

    EXPECT_TRUE(Utils::daemonResourceDir(installPrefix, applicationFile).isEmpty());
}

TEST_F(DataPrefixFixture, GivesTheDaemonTheDataDirectoryNextToTheBinary)
{
    // An extracted release archive: the daemon's ringtones are in share/jami
    // next to bin/, not under the prefix it was built for.
    makeDir("home/jami/share/jami");

    EXPECT_EQ(Utils::daemonResourceDir(installPrefix, applicationFile), root.filePath("home/jami/share/jami"));
}
