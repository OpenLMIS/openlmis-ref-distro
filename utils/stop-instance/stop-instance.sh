#!/usr/bin/env bash

: ${TARGET_INSTANCE_ID:?"Need to set TARGET_INSTANCE_ID"}

stop_instance() {
  # stopping instance
	echo "Stopping instance $TARGET_INSTANCE_ID"
	aws ec2 stop-instances --instance-ids $TARGET_INSTANCE_ID

	echo "Waiting for $TARGET_INSTANCE_ID to be available"
  aws ec2 instance-stopped --instance-ids $TARGET_INSTANCE_ID
}

stop_instance
