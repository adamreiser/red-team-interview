#!/bin/bash

set -eu

# utility script for tunneled vnc access
# usage: ./vnc.sh <uuid> kali

#vnc_binary="/Applications/TigerVNC Viewer 1.9.0.app/Contents/MacOS/TigerVNC Viewer"

# brew cask install real-vnc - for Catalina
vnc_binary="/Applications/VNC Viewer.app/Contents/MacOS/vncviewer"

exit_cmd() {
    ssh -F ".ssh/${TF_VAR_session}_config" -S ".ssh/${TF_VAR_session}_%h" -O exit "${remote_host}"
}

TF_VAR_session=$(echo -n "${1}" | cut -d. -f1 | tr -d "\n")

remote_host="${2}"

ssh -fNMT -F ".ssh/${TF_VAR_session}_config" -S ".ssh/${TF_VAR_session}_%h" -L 127.0.0.1:5900:127.0.0.1:5901 -o "ExitOnForwardFailure=yes" "${remote_host}"

trap exit_cmd INT ERR

# hardcoded password 'vncpass'
"${vnc_binary}" 127.0.0.1 --ColorLevel=full --WarnUnencrypted=0 -passwd <(echo 'zZVpdIbNra4=' | openssl base64 -d)

# tiger-vnc
#"${vnc_binary}" 127.0.0.1 -passwd <(echo 'zZVpdIbNra4=' | openssl base64 -d)

exit_cmd
