# !/bin/bash
set -e
# USAGE:
# ./misc_test.sh
# ./misc_test.sh setup

CMD="~/wdias/wdias/bin/macos/test-dev"
export MASTER_NAME=$(kubectl get pods -l wdias=jmeter-master -o jsonpath='{.items[*].metadata.name}')

# Setup test cases
misc_setup() {
  export MASTER_NAME=$(kubectl get pods -l wdias=jmeter-master -o jsonpath='{.items[*].metadata.name}')
  kubectl exec -it $MASTER_NAME -- bash -c "./test-plan/test_plan.sh /jmeter setup 1440"
  echo "Copy jmeter output wdias_setup.jtl >> wdias_setup.jtl"
  kubectl get pods | grep 'wdias-performance-test-master' | awk '{print $1}' | xargs -o -I {} kubectl cp default/{}:/jmeter/logs/wdias_setup.jtl ./logs/wdias_setup.jtl
  sleep 3 && echo -e "\n\n"
  kubectl exec -it $MASTER_NAME -- bash -c "./test-plan/test_plan.sh /jmeter create_timeseries 1440"
  echo "Copy jmeter output wdias_create_timeseries.jtl >> wdias_create_timeseries.jtl"
  kubectl get pods | grep 'wdias-performance-test-master' | awk '{print $1}' | xargs -o -I {} kubectl cp default/{}:/jmeter/logs/wdias_create_timeseries.jtl ./logs/wdias_create_timeseries.jtl
  echo "Setup the MISC test complete. Exit"
}

misc_wait_for_pod() {
  POD_NAME=$1
  while [ $(kubectl get pods -l app=$POD_NAME -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]; do echo "waiting for pod ${POD_NAME}" && sleep 1; done
  echo "${POD_NAME} is ready"
}


misc_free_pods() {
  SLEEP=${2:-15}
  echo "Clean memory leaks of netCDF"
  kubectl get pods | grep 'adapter-grid' | awk '{print $1}' | xargs -o -I {} nohup kubectl delete pod {} > /tmp/misc_logs.out 2>&1 &
  kubectl get pods | grep 'import-ascii-grid-upload' | awk '{print $1}' | xargs -o -I {} nohup kubectl delete pod {} > /tmp/misc_logs.out 2>&1 &
  echo "Flush InfluxDBs"
  kubectl get pods | grep 'adapter-scalar' | awk '{print $1}' | xargs -o -I {} nohup kubectl delete pod {} > /tmp/misc_logs.out 2>&1 &
  kubectl get pods | grep 'adapter-vector' | awk '{print $1}' | xargs -o -I {} nohup kubectl delete pod {} > /tmp/misc_logs.out 2>&1 &
  kubectl get pods | grep 'adapter-redis' | awk '{print $1}' | xargs -o -I {} nohup kubectl delete pod {} > /tmp/misc_logs.out 2>&1 &
  sleep $SLEEP
  misc_wait_for_pod adapter-scalar-influxdb
  misc_wait_for_pod adapter-vector-influxdb
}

misc_cleanup() {
  TEST_CASE=$1
  # Do the cleanups before run test cases
  echo "Clean up wdias-data-collector"
  kubectl get pods | grep 'wdias-data-collector' | awk '{print $1}' | xargs -o -I {} nohup kubectl delete pod {} > /tmp/misc_logs.out 2>&1 &
  kubectl exec -it $MASTER_NAME -- bash -c "rm -f ./logs/wdias_${TEST_CASE}.jtl"
  echo "Removed jmeter log in order to avoid prepend > > > > >"
  if [ "${2}" = "pod" ]; then
    misc_free_pods
  fi
}

misc_run() {
  TEST_CASE=$1
  REQ_SIZE=$2
  echo -e "\n\nRunning test: ${TEST_CASE} for reqSize: ${REQ_SIZE}"
  kubectl exec -it $MASTER_NAME -- bash -c "./test-plan/test_plan.sh /jmeter ${TEST_CASE} ${REQ_SIZE}"
  echo "Copy jmeter output wdias_${TEST_CASE}.jtl >> wdias_${TEST_CASE}_${REQ_SIZE}.jtl"
  kubectl get pods | grep 'wdias-performance-test-master' | awk '{print $1}' | xargs -o -I {} kubectl cp default/{}:/jmeter/logs/wdias_${TEST_CASE}.jtl ./logs/wdias_${TEST_CASE}_${REQ_SIZE}.jtl
  echo "Copy SQLite database wdias.db >> wdias_${TEST_CASE}_${REQ_SIZE}.db"
  kubectl get pods | grep 'wdias-data-collector' | awk '{print $1}' | xargs -o -I {} kubectl cp default/{}:/go/src/app/wdias.db ./db/wdias_${TEST_CASE}_${REQ_SIZE}.db
}

misc_all() {
  misc_cleanup all pod && misc_run all 24
  misc_cleanup all pod && misc_run all 288
  misc_cleanup all pod && misc_run all 1440
}

misc_other() {
  misc_cleanup import pod && misc_run import 1440
  misc_cleanup "export" && misc_run "export" 1440
  misc_cleanup query && misc_run query 1440
  misc_cleanup create_extensions pod && misc_run create_extensions 1440
  misc_cleanup extension && misc_run extension 1440
}

misc_help() {
  progName=`basename "$0"`
  echo "-h | --help: Usage
  $progName <COMMAND>
    - COMMAND: setup | all | other | cleanup
  "
}


misc_cmd=$1
case $misc_cmd in
  "" | "-h" | "--help")
    misc_help
    ;;
  *)
    shift
    misc_${misc_cmd} $@
    if [ $? = 127 ]; then
      echo "'${misc_cmd}' command not found." >&2
      echo "List available commands with '$progName --help'" >&2
      exit 1
    fi
    ;;
esac
