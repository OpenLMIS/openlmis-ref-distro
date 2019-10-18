#!/bin/bash
set -e
cd "$(dirname "$0")"
npm --version
node --version
yarn install
npm run build

# Sync
rm ../static/assets/dist/*
cp dist/* ../static/assets/dist/
