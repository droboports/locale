### LOCALE ###
_build_locale() {
mkdir -p "${DEST}/bin" "${DEST}/usr/share" "${DEST}/usr/lib/locale"
cp "${TOOLCHAIN}/arm-marvell-linux-gnueabi/libc/usr/bin/localedef" "${DEST}/bin/"
cp "${TOOLCHAIN}/arm-marvell-linux-gnueabi/libc/usr/bin/locale" "${DEST}/bin/"
cp -R "${TOOLCHAIN}/arm-marvell-linux-gnueabi/libc/usr/share/i18n" "${DEST}/usr/share/"
}

### BUILD ###
_build() {
  _build_locale
  _package
}
