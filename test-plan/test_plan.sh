# !/bin/bash
set -e
# Features:
# - Should be able to run test plan for dev and prod
# - Should be able to run for 1hr, 5min & 1min separately
#   - Will be able to run test cases with different required resources (low cost of running)
# - Should be able to run for different requestSize 24(1) | 288(2) | 1044(3)

DIR=$(pwd)
ROOT_DIR=${1-$DIR}
shift
test_cmd=$@
echo "Set ROOT_DIR=$ROOT_DIR"
[[ -n $SERVER_IPS ]] && echo "Running with Distributed Mode with SERVER_IPS=${SERVER_IPS}"
echo "Make sure all wdias-performance-test repo files and dirs avaiable in $ROOT_DIR"
CMD="$ROOT_DIR/bin/macos/test-dev"

exec_all_req_size() {
  echo "Execute for all req sizes"
  $CMD run 1
  $CMD run 2
  $CMD run 3
}

exec_all_once_req_size() {
  echo "Execute for all req sizes: Once"
  $CMD once 1 $1
  $CMD once 2 $1
  $CMD once 3 $1
}

test_setup() {
  echo "1. Setup Test"
  $CMD once 24 Setup # Independent of ReqSize
  $CMD once 24 CreateTimeseries # Independent of ReqSize
  echo "Done 1. Setup \n"
}

test_import() {
  REQ_SIZE=$1
  echo "2. Import Timeseries REQ_SIZE: ${REQ_SIZE}"
  echo "NOTE: Make sure to setup before running import"
  $CMD enable Import
  if [[ -z ${REQ_SIZE} ]]; then
    exec_all_req_size
  else
    $CMD run ${REQ_SIZE}
  fi
  $CMD disable Import
  echo "Done 1. Import: ${REQ_SIZE} \n"
}

test_create_extension() {
  REQ_SIZE=$1
  echo "3.0 Create Extensions"
  echo "NOTE: Make sure to setup before running create_extension"
  if [[ -z ${REQ_SIZE} ]]; then
    exec_all_once_req_size CreateExtensions
  else
    $CMD once ${REQ_SIZE} CreateExtensions
  fi
  echo "Done Create Extensions: ${REQ_SIZE} \n"
}

test_extension() {
  REQ_SIZE=$1
  echo "3. Extension Timeseries: ${REQ_SIZE}"
  echo "NOTE: Make sure to setup before running extension"
  $CMD enable Extension
  if [[ -z ${REQ_SIZE} ]]; then
    exec_all_req_size
  else
    $CMD run ${REQ_SIZE}
  fi
  $CMD disable Extension
  echo "Done 3. Extensions: ${REQ_SIZE} \n"
}

test_export() {
  REQ_SIZE=$1
  echo "4. Export Timeseries: ${REQ_SIZE}"
  echo "NOTE: Make sure to setup before running export"
  $CMD enable Export
  if [[ -z ${REQ_SIZE} ]]; then
    exec_all_req_size
  else
    $CMD run ${REQ_SIZE}
  fi
  $CMD disable Export
  echo "Done 4. Export: ${REQ_SIZE} \n"
}

test_all() {
  REQ_SIZE=$1
  echo "5. All Timeseries: ${REQ_SIZE}"
  echo "NOTE: Make sure to setup before running all"
  $CMD enable All
  if [[ -z ${REQ_SIZE} ]]; then
    exec_all_req_size
  else
    $CMD run ${REQ_SIZE}
  fi
  $CMD disable All
  echo "Done 5. All: ${REQ_SIZE} \n"
}

test_query() {
  REQ_SIZE=$1
  echo "5.1 Query Timeseries"
  echo "NOTE: Make sure to setup before running query"
  if [[ -z ${REQ_SIZE} ]]; then
    exec_all_once_req_size Query
  else
    $CMD once ${REQ_SIZE} Query
  fi
  echo "Done 5.1 Query: ${REQ_SIZE} \n"
}

test_run() {
  echo "Start running all the test plan : $@"
  test_setup $@
  test_import $@
  test_create_extension $@
  test_extension $@
  test_export $@
  test_all $@
  test_query $@
  echo "Successfully run full test plan"
}

# ---- Grid Setup
test_setup_grid() {
  echo "EXTRA: Setup Grid Test"
  $CMD once 24 Setup # Independent of ReqSize
  $CMD once 24 CreateGridTimeseries # Independent of ReqSize
  echo "EXTRA: Done. Setup Grid \n"
}
test_grid() {
  REQ_SIZE=$1
  echo "EXTRA: Grid Timeseries: ${REQ_SIZE}"
  $CMD enable Grid
  if [[ -z ${REQ_SIZE} ]]; then
    exec_all_req_size
  else
    $CMD run ${REQ_SIZE}
  fi
  $CMD disable Grid
  echo "EXTRA: Grid: ${REQ_SIZE} \n"
}
test_run_grid() {
  echo "EXTRA: Start running Grid test plan : $@"
  test_setup_grid $@
  test_grid $@
  echo "EXTRA: Successfully run Grid test plan"
}

test_help() {
  progName=`basename "$0"`
  echo "-h | --help: Usage
  $progName  <ROOT_DIR> <COMMAND> <REQ_SIZE>
    - REQ_SIZE (optional): 24(1) | 288(2) | 1044(3)
  NOTE: Modify test.conf as necessary
  e.g.
  $progName ~/wdias/wdias-performance-test run
  $progName ~/wdias/wdias-performance-test run 2
  - Run all the steps in order of setup, import, create_extension, extension, export, all, query

  $progName ~/wdias/wdias-performance-test setup
  $progName ~/wdias/wdias-performance-test import 24
  $progName ~/wdias/wdias-performance-test create_extension 24
  $progName ~/wdias/wdias-performance-test extension 24
  $progName ~/wdias/wdias-performance-test export 24
  $progName ~/wdias/wdias-performance-test all 24
  $progName ~/wdias/wdias-performance-test query 24

  Distibuted Mode
  SERVER_IPS=<IP1,IP2...> $progName ~/wdias/wdias-performance-test run
  "
}

test_cmd=$1
case $test_cmd in
  "" | "-h" | "--help")
    test_help
    ;;
  *)
    shift
    test_${test_cmd} $@
    if [ $? = 127 ]; then
      echo "'${test_cmd}' command not found." >&2
      echo "List available commands with '$progName --help'" >&2
      exit 1
    fi
    ;;
esac
