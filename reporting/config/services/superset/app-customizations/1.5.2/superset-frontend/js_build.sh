#!/bin/bash
set -e
cd "$(dirname "$0")"
npm --version
node --version
npm ci
npm run build

cp -r ../superset/static/assets ../static
