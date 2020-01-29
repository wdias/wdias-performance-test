# !/bin/bash
set -e

export MASTER_NAME=$(kubectl get pods -l wdias=jmeter-master -o jsonpath='{.items[*].metadata.name}')

# Setup test cases
misc_setup() {
  export MASTER_NAME=$(kubectl get pods -l wdias=jmeter-master -o jsonpath='{.items[*].metadata.name}')
  kubectl exec -it $MASTER_NAME -- bash -c "./test-plan/test_plan.sh /jmeter setup 1440" && sleep 3 && \
  kubectl exec -it $MASTER_NAME -- bash -c "./test-plan/test_plan.sh /jmeter create_timeseries 1440"
}

misc_run() {
  TEST_CASE=$1
  REQ_SIZE=$2
  echo "Running test: ${TEST_CASE} for reqSize: ${REQ_SIZE}"
  kubectl exec -it $MASTER_NAME -- bash -c "./test-plan/test_plan.sh /jmeter ${TEST_CASE} ${REQ_SIZE}"
  echo "Copy jmeter output wdias_${TEST_CASE}.jtl >> wdias_${TEST_CASE}_${REQ_SIZE}.jtl"
  kubectl get pods | grep 'wdias-performance-test-master' | awk '{print $1}' | xargs -o -I {} kubectl cp default/{}:/jmeter/logs/wdias_${TEST_CASE}.jtl ./logs/wdias_${TEST_CASE}_${REQ_SIZE}.jtl
  echo "Copy SQLite database wdias.db >> wdias_${TEST_CASE}_${REQ_SIZE}.db"
  kubectl get pods | grep 'wdias-data-collector' | awk '{print $1}' | xargs -o -I {} kubectl cp default/{}:/go/src/app/wdias.db ./db/wdias_${TEST_CASE}_${REQ_SIZE}.db
}

misc_run all 24
misc_run all 288
misc_run all 1440
