#!/bin/bash
BASE="$(cd `dirname "$0"` && pwd)"

main () {
  local cmd="$1"
  case $cmd in
    'setup')
      shift
      setup "$@"
      ;;
    'devserver')
      shift
      devserver "$@"
      ;;
    'server')
      shift
      server "$@"
      ;;
    'clean')
      shift
      clean "$@"
      ;;
    * )
      echo "
Exiting without running any operations.
Possible operations include:

  setup - Install dependencies.
    Usage: ./manage.sh setup

  devserver - Run the deverserver for local development.
    Usage: ./manage.sh devserver

  server - Run the HTTP server in production environment.
    Usage: ./manage.sh server

  clean - Remove everything generated by this script.
    Usage: ./manage.sh clean
            "
      ;;
  esac
}

setup () {
  if ! [ -d "$BASE/node_modules" ]; then
    cd "$BASE/"
    mkdir "$BASE/node_modules"
    npm install http-server
  fi
}

devserver () {
  setup
  node_modules/.bin/http-server "$BASE/public/" -p 8080 -a 127.0.0.1
}

server () {
  setup
  node_modules/.bin/http-server "$BASE/public/" -p 8009 -a 127.0.0.1 -d "false"
}

clean () {
  rm -rf "$BASE/node_modules/"
}

main "$@"
