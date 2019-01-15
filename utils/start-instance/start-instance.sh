#!/usr/bin/env bash

: ${TARGET_INSTANCE_ID:?"Need to set TARGET_INSTANCE_ID"}

start_instance() {
  # starting instance
	echo "Starting instance $TARGET_INSTANCE_ID"
	aws ec2 start-instances --instance-ids $TARGET_INSTANCE_ID

  wait_available $TARGET_INSTANCE_ID
}

wait_available() {
	INST_ID=${1}
	SLEEP_TIME=10
	STATUS=stopped
	while true; do
		current_status=`aws ec2 describe-instance-status \
			--query 'InstanceStatuses[?InstanceId==\`'${INST_ID}'\`]'.InstanceStatus.Status \
			--output text \
			--region ${AWS_DEFAULT_REGION}`
		if [[ "$current_status" = "$STATUS" ]]; then
			echo -n "."
		else
			if [[ "$STATUS" != "stopped" ]]; then echo; fi
			echo -n "Status ($INST_ID): ${current_status:-stopped}"
		fi
		if [[ "$current_status" = "ok" ]]; then
			echo
			break
		fi
		STATUS=$current_status
		sleep ${SLEEP_TIME}
	done
}

start_instance
