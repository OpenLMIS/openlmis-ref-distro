#!/usr/bin/env bash

: ${TARGET_INSTANCE_ID:?"Need to set TARGET_INSTANCE_ID"}

start_instance() {
  # starting instance
	echo "Stopping instance $TARGET_INSTANCE_ID"
	aws ec2 start-instances --instance-ids $TARGET_INSTANCE_ID

  echo "Waiting for $TARGET_INSTANCE_ID to be available"
  aws ec2 instance-status-ok --instance-ids $TARGET_INSTANCE_ID
}

start_instance
