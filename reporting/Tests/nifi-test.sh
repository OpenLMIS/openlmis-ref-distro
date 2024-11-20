testContainersState() {
    container_count=$(docker ps | wc -l)
    running_status_containers=$(docker ps --filter status=running | wc -l)
    running_containers_list=($(docker ps --filter status=running --format {{.Names}} | sort | tr '\n' ' '))
    expected_containers_list=(reporting_consul_1 reporting_db_1 reporting_kafka_1 reporting_log_1 reporting_nginx_1 reporting_nifi_1 reporting_superset_1 reporting_zookeeper_1)

    if [ ${container_count} == ${running_status_containers} ] && [ "${running_containers_list[*]}" == "${expected_containers_list[*]}" ];
    then
        echo "All containers started successfully"
    else
        echo "The following containers are not started: \n"
        echo ${running_containers_list[@]} ${expected_containers_list[@]} |tr ' ' '\n' | sort  | uniq -u
    fi
}

testTemplatesLoaded() {
    processGroups=$(curl -u "admin:changeme" -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/root/process-groups | jq -r ".[]")
    loadedProcessGroups=()
    for i in "${processGroups[@]}";
    do
    loadedProcessGroups+=("$(echo $i | jq -r ".[].component.name")")
    done

    expectedProcessGroups=(Generate MeasureReports Generate Measures Materialized Views Reference Data Connector Requsitions connector Superset Permissions)
    sortedloadedProcessGroups=$(echo ${loadedProcessGroups[*]} | sort | tr '\n' ' ')

    if [ "${sortedloadedProcessGroups[*]}" == "${expectedProcessGroups[*]}" ];
    then
        echo "All process groups have been loaded successfully"
    else
        echo "The following process groups are not loaded: \n"
        echo ${sortedloadedProcessGroups[@]} ${expectedProcessGroups[@]} |tr ' ' '\n' | sort  | uniq -u
    fi
}