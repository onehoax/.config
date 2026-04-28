#!/usr/bin/env bash

set_ipv6() {
  local action="$1"
  local value="$2"

  echo "$action IPv6..."
  sudo sysctl -w net.ipv6.conf.all.disable_ipv6="$value"
  sudo sysctl -w net.ipv6.conf.default.disable_ipv6="$value"
}

case "$1" in
  on)
    set_ipv6 "Enabling" 0
    ;;
  off)
    set_ipv6 "Disabling" 1
    ;;
  status)
    sysctl net.ipv6.conf.all.disable_ipv6
    ;;
  *)
    echo "Usage: $0 {on|off|status}"
    exit 1
    ;;
esac

curl -6 ifconfig.me
