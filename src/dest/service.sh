#!/usr/bin/env sh
#
# Locale support

# import DroboApps framework functions
. /etc/service.subr

# DroboApp framework version
framework_version="2.0"

# app description
name="locale"
version="2.11.1"
description="Support for filenames with international characters."

# framework-mandated variables
pidfile="/tmp/DroboApps/${name}/pid.txt"
logfile="/tmp/DroboApps/${name}/log.txt"
statusfile="/tmp/DroboApps/${name}/status.txt"
errorfile="/tmp/DroboApps/${name}/error.txt"

# app-specific variables
prog_dir=$(dirname $(readlink -fn ${0}))
inputfile="en_US"
charmap="UTF-8"

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

if_mkdir() {
  if [ ! -d "$1" ]; then mkdir -p "$1"; fi
}

if_link() {
  if [ ! -h "$1" ]; then ln -fs "$2" "$1"; fi
}

if_create_locale() {
  local localecount
  localecount=$("${prog_dir}/bin/locale" -a | wc -l)
  if [[ ${localecount} -le 2 ]]; then
    "${prog_dir}/bin/localedef" -f "${charmap}" -i "${inputfile}" "${inputfile}.${charmap}"
  fi
}

start() {
  if_mkdir "/usr/share"
  if_mkdir "/usr/lib"
  if_link "/usr/share/i18n" "${prog_dir}/usr/share/i18n"
  if_link "/usr/lib/locale" "${prog_dir}/usr/lib/locale"
  if_create_locale
}

status() {
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
  start)   start ;;
  stop)    ;;
  restart) start ;;
  status)  status ;;
  *) echo "Usage: $0 [start|stop|restart|status]" ; exit 1 ;;
esac
