#!/usr/bin/env python3
"""Install Qt for the kool277-desktop workflow from the Qt online repository
(download.qt.io), the way aqtinstall does. aqtinstall 3.3.0, its latest
release, does not know Qt 6.12's repository: the Windows packages have a
folder per compiler, and the WebEngine and PDF extensions have versions of
their own (aqtinstall issue #1047).

    kool277-install-qt.py <windows|mac> <Qt version> <output dir> <module>...

installs Qt's essential modules and the named add-ons and extensions into
<output dir>/<version>/<msvc2022_64|macos>, extensions at their newest
version for that Qt. download.qt.io sends the archives from mirrors: each
must match the SHA-1 sum that download.qt.io publishes next to it.
"""

import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.request
import xml.etree.ElementTree as ET

REPO = "https://download.qt.io/online/qtsdkrepository"
# system: host folder, suffix of the desktop folder, package architecture,
# extension folder, installed folder.
SYSTEMS = {
    "windows": ("windows_x86", "_msvc2022_64", "win64_msvc2022_64", "msvc2022_64", "msvc2022_64"),
    "mac": ("mac_x64", "", "clang_64", "clang_64", "macos"),
}
# The folders at the top of a Qt installation.
QT_FOLDERS = {"bin", "doc", "include", "lib", "libexec", "metatypes", "mkspecs",
              "modules", "phrasebooks", "plugins", "qml", "resources", "sbom",
              "translations"}


def retrying(what, action, tries=5):
    for attempt in range(1, tries + 1):
        try:
            return action()
        except OSError as e:
            if attempt == tries:
                raise
            print(f"{what}: {e}; trying again", flush=True)
            time.sleep(15 * attempt)


def read(url):
    def action():
        with urllib.request.urlopen(url, timeout=60) as response:
            return response.read()
    return retrying(url, action)


def packages(folder):
    """The packages that the Updates.xml of folder lists, by name."""
    root = ET.fromstring(read(f"{folder}/Updates.xml"))
    return {p.findtext("Name"): p for p in root.iter("PackageUpdate")}


def archives(folder, package):
    name, version = package.findtext("Name"), package.findtext("Version")
    for archive in (package.findtext("DownloadableArchives") or "").split(","):
        if archive.strip():
            yield f"{folder}/{name}/{version}{archive.strip()}"


def download(url, path):
    """Download url to path; it must match its published SHA-1 sum."""
    want = read(url + ".sha1").decode().split()[0].lower()

    def action():
        sha1 = hashlib.sha1()
        with urllib.request.urlopen(url, timeout=60) as response, open(path, "wb") as f:
            while chunk := response.read(1 << 20):
                sha1.update(chunk)
                f.write(chunk)
        if sha1.hexdigest() != want:
            raise OSError(f"SHA-1 {sha1.hexdigest()}, expected {want}")
    retrying(url, action)


def qt_root(tree):
    """The folder of an extracted archive that holds Qt's top folders, the
    shallowest one: an archive may hold them at its top or under a prefix.
    None when it holds none."""
    level = [tree]
    while level:
        for folder in level:
            if QT_FOLDERS & set(os.listdir(folder)):
                return folder
        level = [os.path.join(f, n) for f in level for n in sorted(os.listdir(f))
                 if os.path.isdir(os.path.join(f, n)) and not os.path.islink(os.path.join(f, n))]
    return None


def merge(source, target):
    """Move what source holds into target, merging the folders both have."""
    for name in os.listdir(source):
        s, t = os.path.join(source, name), os.path.join(target, name)
        if os.path.isdir(t) and not os.path.islink(t) and os.path.isdir(s) and not os.path.islink(s):
            merge(s, t)
            continue
        if os.path.isdir(t) and not os.path.islink(t):
            shutil.rmtree(t)
        elif os.path.lexists(t):
            os.remove(t)
        os.replace(s, t)


def main():
    system, version, out, *modules = sys.argv[1:]
    host, desktop_suffix, arch, extension_arch, installed = SYSTEMS[system]
    v = version.replace(".", "")
    desktop = f"{REPO}/{host}/desktop/qt6_{v}/qt6_{v}{desktop_suffix}"
    desktop_packages = packages(desktop)
    urls = list(archives(desktop, desktop_packages[f"qt.qt6.{v}.{arch}"]))
    for module in modules:
        addon = desktop_packages.get(f"qt.qt6.{v}.addons.{module}.{arch}")
        if addon is not None:
            urls += archives(desktop, addon)
            continue
        # Not an add-on: an extension, in a folder per version of its own.
        listing = read(f"{REPO}/{host}/extensions/{module}/{v}/").decode()
        versions = sorted(int(n) for n in re.findall(r'href="(\d+)/"', listing))
        if not versions:
            sys.exit(f"{module}: neither an add-on nor an extension of Qt {version}")
        folder = f"{REPO}/{host}/extensions/{module}/{v}/{versions[-1]}/{extension_arch}"
        name = f"extensions.{module}.{v}.{versions[-1]}.{arch}"
        urls += archives(folder, packages(folder)[name])

    sevenzip = shutil.which("7z") or r"C:\Program Files\7-Zip\7z.exe"
    target = os.path.join(out, version, installed)
    os.makedirs(target, exist_ok=True)
    for url in urls:
        print(f"{url.rsplit('/', 2)[-2]}: {url.rsplit('/', 1)[-1]}", flush=True)
        stage = tempfile.mkdtemp(dir=out)
        archive = os.path.join(stage, "archive.7z")
        download(url, archive)
        tree = os.path.join(stage, "tree")
        subprocess.run([sevenzip, "x", "-y", "-bd", f"-o{tree}", archive],
                       check=True, stdout=subprocess.DEVNULL)
        root = qt_root(tree)
        if root is not None:
            print(f"  holds {os.path.relpath(root, tree)}/", flush=True)
            merge(root, target)
        else:
            # The DLLs that Qt ships for Windows beside its own (Direct3D's
            # shader compiler, a software OpenGL) come without a folder:
            # they go next to Qt's, in bin/.
            files = [os.path.join(d, f) for d, _, fs in os.walk(tree) for f in fs]
            if not files or not all(f.lower().endswith(".dll") for f in files):
                sys.exit(f"an archive holds neither Qt folders nor only DLLs: {files}")
            os.makedirs(os.path.join(target, "bin"), exist_ok=True)
            for f in files:
                os.replace(f, os.path.join(target, "bin", os.path.basename(f)))
            print(f"  holds {', '.join(os.path.relpath(f, tree) for f in files)}: into bin/", flush=True)
        shutil.rmtree(stage)
    if not os.path.isfile(os.path.join(target, "lib", "cmake", "Qt6", "Qt6Config.cmake")):
        sys.exit(f"no lib/cmake/Qt6 in {target}")
    print(f"Qt {version} in {target}")


if __name__ == "__main__":
    main()
