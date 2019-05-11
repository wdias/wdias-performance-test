# !/bin/bash
set -e
# Features:
# - Should be able to run test plan for dev and prod
# - Should be able to run for 1hr, 5min & 1min separately
#   - Will be able to run test cases with different required resources (low cost of running)
# - Should be able to run for Scalar, 

DIR=$(pwd)
ROOT_DIR=${1-$DIR}
shift
test_cmd=$@
echo "Set ROOT_DIR=$ROOT_DIR"
echo "Make sure wdias-performance-test repo avaiable in $ROOT_DIR"
CMD="$ROOT_DIR/wdias-performance-test/bin/macos/dev"

test_setup() {
  echo "1. Setup Test"
  $CMD once 24 Setup # Independent of ReqSize
}

run_all() {
  $CMD run 1
  $CMD run 2
  $CMD run 3
}

test_import() {
  REQ_SIZE=$1
  echo"2. Import Timeseries: ${REQ_SIZE}"
  $CMD enable Import
  if [[ -z ${REQ_SIZE} ]]; then
    $(run_all)
  else
    $CMD run ${REQ_SIZE}
  fi
  $CMD disable Import
}

test_create_extension() {
  REQ_SIZE=$1
  echo "Create Extensions"
  $CMD once ${REQ_SIZE} CreateExtensions
}

test_extension() {
  REQ_SIZE=$1
  echo"3. Extension Timeseries: ${REQ_SIZE}"
  $CMD enable Extension
  if [[ -z ${REQ_SIZE} ]]; then
    $(run_all)
  else
    $CMD run ${REQ_SIZE}
  fi
  $CMD disable Extension
}

test_export() {
  REQ_SIZE=$1
  echo"4. Export Timeseries: ${REQ_SIZE}"
  $CMD enable Export
  if [[ -z ${REQ_SIZE} ]]; then
    $(run_all)
  else
    $CMD run ${REQ_SIZE}
  fi
  $CMD disable Export
}

test_all() {
  REQ_SIZE=$1
  echo"5. All Timeseries: ${REQ_SIZE}"
  $CMD enable All
  if [[ -z ${REQ_SIZE} ]]; then
    $(run_all)
  else
    $CMD run ${REQ_SIZE}
  fi
  $CMD disable All
}

test_query() {
  REQ_SIZE=$1
  echo "Query Timeseries"
  $CMD once ${REQ_SIZE} Query
}

test_test_all() {
  echo "Start running all the test plan"
  test_setup
  test_import
  test_create_extension
  test_extension
  test_export
  test_all
  test_query
  echo "Successfully run full test plan"
}

test_help() {
  echo "-h | --help: Usage
  $progName run <ROOT_DIR> <REQ_SIZE>
    - REQ_SIZE (optional): 24(1) | 288(2) | 1044(3)
  NOTE: Modify test.conf as necessary
  e.g.
  $progName run ~/wdias
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
