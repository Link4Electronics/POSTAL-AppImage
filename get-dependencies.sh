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
if [ "$ARCH" = "aarch64" ]; then
    sed -i 's|CLIENTEXE := $(BINDIR)/postal1-x86_64|CLIENTEXE := $(BINDIR)/postal1-aarch64|' makefile
fi
make -j$(nproc)
mv -v bin/postal1-$ARCH ../AppDir/bin/postal1
sed -i -e '/DeviceBufTime = 200/a DeviceRate = 22050\nDeviceBits = 16' \
       -e 's|File = res\\levels\\realms.ini|File = res/levels/postal_plus_realms.ini|' \
       -e 's/RecentDifficulty = 11/RecentDifficulty = 5/' \
       -e 's/UseMouse[[:space:]]*= 0/UseMouse = 1/' DefaultPostal.ini
mv -v DefaultPostal.ini ../AppDir/bin/POSTAL.INI
