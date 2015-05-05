### LOCALE ###
_build_locale() {
mkdir -p "${DEST}/bin" "${DEST}/usr/share" "${DEST}/usr/lib/locale"
cp "${TOOLCHAIN}/${HOST}/libc/usr/bin/localedef" "${DEST}/bin/"
cp "${TOOLCHAIN}/${HOST}/libc/usr/bin/locale" "${DEST}/bin/"
cp -R "${TOOLCHAIN}/${HOST}/libc/usr/share/i18n" "${DEST}/usr/share/"
}

### BUILD ###
_build() {
  _build_locale
  _package
}
