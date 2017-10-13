#!/usr/bin/env bash

: ${AWS_ACCESS_KEY_ID:?"Need to set environment variable AWS_ACCESS_KEY_ID"}
: ${AWS_SECRET_ACCESS_KEY:?"Need to set environment variable AWS_SECRET_ACCESS_KEY"}
: ${AWS_DEFAULT_REGION:?"Need to set environment variable AWS_DEFAULT_REGION"}

exec "$@"
