#!/usr/bin/env bash

: ${TARGET_INSTANCE_ID:?"Need to set TARGET_INSTANCE_ID"}

stop_instance() {
  # stopping instance
	echo "Stopping instance $TARGET_INSTANCE_ID"
	aws ec2 stop-instances --instance-ids $TARGET_INSTANCE_ID

  # added 3 min sleep for making sure instance goes down before starting it
  sleep 180
}

stop_instance
