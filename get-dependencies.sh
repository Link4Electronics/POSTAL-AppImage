#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    libdecor \
    sdl2

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here
echo "Making nightly build of POSTAL..."
echo "---------------------------------------------------------------"
REPO="https://github.com/RWS-Studios/POSTAL-SourceCode"
VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
git clone "$REPO" ./POSTAL
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./POSTAL
patch -Np1 -i ../fixes.patch
if [ "$ARCH" = "x86_64" ]; then
    sed -i 's|CLIENTEXE := $(BINDIR)/postal1-x86_64|CLIENTEXE := $(BINDIR)/postal1-aarch64|' makefile
fi
make -j$(nproc)
mv -v bin/postal1-$ARCH ../AppDir/bin/postal1
mv -v DefaultPostal.ini ../AppDir/bin/POSTAL.INI
