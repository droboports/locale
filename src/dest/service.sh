#!/usr/bin/env sh
#
# Locale support

# import DroboApps framework functions
. /etc/service.subr

# DroboApp framework version
framework_version="2.0"

# app description
name="locale"
version="2.5"
description="Support for filenames with international characters."

# framework-mandated variables
pidfile="/tmp/DroboApps/${name}/pid.txt"
logfile="/tmp/DroboApps/${name}/log.txt"
statusfile="/tmp/DroboApps/${name}/status.txt"
errorfile="/tmp/DroboApps/${name}/error.txt"

# app-specific variables
prog_dir=$(dirname $(readlink -fn ${0}))

# script hardening
set -o errexit  # exit on uncaught error code
set -o nounset  # exit on unset variable
set -o pipefail # propagate last error code on pipe

# ensure log folder exists
logfolder="$(dirname ${logfile})"
if [[ ! -d "${logfolder}" ]]; then mkdir -p "${logfolder}"; fi

# redirect all output to logfile
exec 3>&1 1>> "${logfile}" 2>&1

# log current date, time, and invocation parameters
echo $(date +"%Y-%m-%d %H-%M-%S"): ${0} ${@}

# enable script tracing
set -o xtrace

_mkdir() {
  if [[ ! -d "$1" ]]; then mkdir -p "$1"; fi
}

_link() {
  if [[ ! -h "$1" ]]; then ln -fs "$2" "$1"; fi
}

_create_locale() {
  local locale inputfile charmap charalt exists
  for loc in "${prog_dir}/etc/locale.d"/*; do
    locale="$(basename ${loc})"
    inputfile="$(echo ${locale} | awk -F. '{print $1}')"
    charmap="$(echo ${locale} | awk -F. '{print $2}')"
    if [[ "${charmap}" == "UTF-8" ]]; then
      charalt="utf8"
    else
      charalt="${charmap}"
    fi
    if ("${prog_dir}/bin/localedef" --list-archive "${prog_dir}/usr/lib/locale/locale-archive" | grep -q "${inputfile}.${charalt}"); then
      echo ${loc} already exists.
    else
      "${prog_dir}/bin/localedef" -f "${charmap}" -i "${inputfile}" "${locale}"
    fi
  done
}

_start() {
  _mkdir "/usr/share"
  _mkdir "/usr/lib"
  _link "/usr/share/i18n" "${prog_dir}/usr/share/i18n"
  _link "/usr/lib/locale" "${prog_dir}/usr/lib/locale"
  _create_locale
}

_status() {
  local enabled running localecount

  if [[ -h "/usr/lib/locale" ]]; then
    enabled="enabled"
  else
    enabled="disabled"
  fi

  localecount=$("${prog_dir}/bin/locale" -a | wc -l)
  if [[ "${localecount}" -le 2 ]]; then
    running="running"
  else
    running="stopped"
  fi

  echo ${name} is ${enabled} and ${running}
}

case "$1" in
  start)   _start ;;
  stop)    ;;
  restart) _start ;;
  status)  _status ;;
  *) echo "Usage: $0 [start|stop|restart|status]" ; exit 1 ;;
esac
