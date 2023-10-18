#!/usr/bin/env bash

case 1 in
  "app")
    export RODBOT_APP_HOST=0.0.0.0
    bundle exec rodbot start app
    ;;
  "relay")
    bundle exec rodbot start relay
    ;;
  "schedule")
    bundle exec rodbot start schedule
    ;;
  *)
    echo "Invalid argument"
    exit 1
    ;;
esac
