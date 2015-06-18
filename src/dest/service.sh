#!/usr/bin/env sh
#
# Locale support

# import DroboApps framework functions
. /etc/service.subr

framework_version="2.1"
name="locale"
version="2.5.0-1"
description="Support for filenames with international characters."
depends=""
webui=""

prog_dir="$(dirname "$(realpath "${0}")")"
tmp_dir="/tmp/DroboApps/${name}"
pidfile="${tmp_dir}/pid.txt"
logfile="${tmp_dir}/log.txt"
statusfile="${tmp_dir}/status.txt"
errorfile="${tmp_dir}/error.txt"

# backwards compatibility
if [ -z "${FRAMEWORK_VERSION:-}" ]; then
  . "${prog_dir}/libexec/service.subr"
fi

_mkdir() {
  if [ ! -d "${1}" ]; then mkdir -p "${1}"; fi
}

_link() {
  if [ ! -h "${1}" ]; then ln -fs "${2}" "${1}"; fi
}

_create_locale() {
  local locale inputfile charmap charalt
  for loc in "${prog_dir}/etc/locale.d"/*; do
    locale="$(basename "${loc}")"
    inputfile="$(echo "${locale}" | awk -F. '{print $1}')"
    charmap="$(echo "${locale}" | awk -F. '{print $2}')"
    if [ "${charmap}" = "UTF-8" ]; then
      charalt="utf8"
    else
      charalt="${charmap}"
    fi
    if ("${prog_dir}/bin/localedef" --list-archive "${prog_dir}/usr/lib/locale/locale-archive" | grep -q "${inputfile}.${charalt}"); then
      echo "${loc} already exists."
    else
      "${prog_dir}/bin/localedef" -f "${charmap}" -i "${inputfile}" "${locale}"
    fi
  done
}

start() {
  _mkdir "/usr/share"
  _mkdir "/usr/lib"
  _link "/usr/share/i18n" "${prog_dir}/usr/share/i18n"
  _link "/usr/lib/locale" "${prog_dir}/usr/lib/locale"
  _create_locale
  rm -f "${errorfile}"
  echo "Locale is configured." > "${statusfile}"
  touch "${pidfile}"
}

is_running() {
  if [ -f "${pidfile}" ]; then
    return 0
  fi
  return 1
}

stop() {
  rm -f "${pidfile}"
}

force_stop() {
  rm -f "${pidfile}"
}

# boilerplate
if [ ! -d "${tmp_dir}" ]; then mkdir -p "${tmp_dir}"; fi
exec 3>&1 4>&2 1>> "${logfile}" 2>&1
STDOUT=">&3"
STDERR=">&4"
echo "$(date +"%Y-%m-%d %H-%M-%S"):" "${0}" "${@}"
set -o errexit  # exit on uncaught error code
set -o nounset  # exit on unset variable
set -o xtrace   # enable script tracing

main "${@}"
