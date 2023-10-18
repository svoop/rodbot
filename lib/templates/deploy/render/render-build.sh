#!/usr/bin/env bash
set -euo pipefail

echo "--> Checking environment"
echo "RODBOT_ENV: $RODBOT_ENV"
echo "RODBOT_PLUGINS: $RODBOT_PLUGINS"

echo "--> Installing bundle"
bundle config set with $RODBOT_PLUGINS
bundle install
