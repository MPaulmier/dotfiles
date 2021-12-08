#!/usr/bin/env sh

./configure --with-cairo --with-modules --without-compress-install --with-x-toolkit --with-gnutls --without-gconf --with-xwidgets --with-toolkit-scroll-bars --without-xaw3d --without-gsettings --with-mailutils --with-native-compilation --with-json --with-harfbuzz --without-imagemagick --with-jpeg --with-png --with-rsvg --with-tiff --with-wide-int --with-xft --with-xml2 --with-xpm CFLAGS="-O3 -mtune=native -march=native -fomit-frame-pointer" prefix=/usr/local

make

sudo make install
