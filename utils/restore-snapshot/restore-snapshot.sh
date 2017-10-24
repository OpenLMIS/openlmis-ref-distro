
#!/usr/bin/env bash

: ${AWS_DEFAULT_REGION:?"Need to set AWS_DEFAULT_REGION"}
: ${SNAPSHOT_NAME:?"Need to set SNAPSHOT_NAME"}
: ${TARGET_INSTANCE:?"Need to set TARGET_INSTANCE"}
: ${MASTER_USER_PASSWORD:?"Need to set MASTER_USER_PASSWORD"}
: ${SECURITY_GROUP:?"Need to set SECURITY_GROUP"}

restore_db_from_snapshot() {
  # find named snapshot
  echo "Finding Snapshot $SNAPSHOT_NAME"
  SNAPSHOT=`aws rds describe-db-snapshots \
    --region $AWS_DEFAULT_REGION \
    --db-snapshot-identifier $SNAPSHOT_NAME`
  echo "Snapshot to restore from: $SNAPSHOT"

  # get details from target instance
  DB_DETAILS=`aws rds describe-db-instances \
    --region $AWS_DEFAULT_REGION \
    --db-instance-identifier $TARGET_INSTANCE`
  echo "Target instance details: $DB_DETAILS"

  # parse class from target
  DB_CLASS=`echo $DB_DETAILS | jq -r .DBInstances[0].DBInstanceClass`
  echo "Target instance class: $DB_CLASS"

  # parse subnet group name from target
  DB_SUBNET_GROUP=`echo $DB_DETAILS | jq -r .DBInstances[0].DBSubnetGroup.DBSubnetGroupName`
  echo "Subnet group: $DB_SUBNET_GROUP"

  # restore snapshot as temporary instance
  SNAPSHOT_NAME_TMP="$SNAPSHOT_NAME-tmp"
	echo "Restoring snapshot $SNAPSHOT_NAME -> $SNAPSHOT_NAME_TMP"
	aws rds restore-db-instance-from-db-snapshot \
    --db-instance-class $DB_CLASS \
    --no-publicly-accessible \
    --db-subnet-group-name $DB_SUBNET_GROUP \
		--db-instance-identifier $SNAPSHOT_NAME_TMP\
		--db-snapshot-identifier $SNAPSHOT_NAME \
		--region $AWS_DEFAULT_REGION

  # remove existing target instance - if needed
  echo "Removing existing target $TARGET_INSTANCE"
	aws rds delete-db-instance \
		--region $AWS_DEFAULT_REGION \
		--db-instance-identifier $TARGET_INSTANCE \
		--skip-final-snapshot

  echo "Waiting for $SNAPSHOT_NAME_TMP to be available"
  wait_available $SNAPSHOT_NAME_TMP

  echo "$SNAPSHOT_NAME_TMP is available, setting master user password and VPC security group"
  aws rds modify-db-instance \
    --region $AWS_DEFAULT_REGION \
    --db-instance-identifier $SNAPSHOT_NAME_TMP \
    --master-user-password $MASTER_USER_PASSWORD \
    --vpc-security-group-ids $SECURITY_GROUP \
    --apply-immediately

  # once target is gone, rename restored temp to target
  aws rds wait db-instance-deleted --db-instance-identifier $TARGET_INSTANCE
	echo "Renaming the $SNAPSHOT_NAME_TMP -> $TARGET_INSTANCE"
	aws rds modify-db-instance \
		--region $AWS_DEFAULT_REGION \
		--db-instance-identifier $SNAPSHOT_NAME_TMP \
		--new-db-instance-identifier $TARGET_INSTANCE \
		--apply-immediately

  wait_available $TARGET_INSTANCE
}

wait_available() {
	INST_ID=${1}
	SLEEP_TIME=10
	STATUS=none
	while true; do
		current_status=`aws rds describe-db-instances \
			--query 'DBInstances[?DBInstanceIdentifier==\`'${INST_ID}'\`]'.DBInstanceStatus \
			--output text \
			--region ${AWS_DEFAULT_REGION}`
		if [[ "$current_status" = "$STATUS" ]]; then
			echo -n "."
		else
			if [[ "$STATUS" != "none" ]]; then echo; fi
			echo -n "Status ($INST_ID): ${current_status:-none}"
		fi
		if [[ "$current_status" = "available" ]]; then
			echo
			break
		fi
		STATUS=$current_status
		sleep ${SLEEP_TIME}
	done
}

restore_db_from_snapshot
