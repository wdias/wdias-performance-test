# Test Plan

1. Test Setup to create timeseries in 1hr, 5min and 1min intervals and create metadata of the timeseries
2. Import Timeseries
  - Plan for test run of 1 hour. In each test run change the request size from 1hr, 5min to 1min. (total 3 hours)
  - Have mixture of data: Scalar - 70%(max 2100req), Vector (Multi-Scalar) - 20% (max 600req), Grid - 10% (max 300req)
3. Extensions
  - Create Extensions for /Aggregation_Accumulative, /Interpolation Linear, /Validation Missing Values (OnChange and OnTime)
  - 1 hour of test run. Just for 1min data. (total 1 hours)
  - Do with Import Timeseries with error data which will go through extensions.
4. Export Timeseries
  - 1 hour test run. Change request size from 1hr, 5min to 1min. (total 3 hours)
  - Have mixture of data: Scalar - 70%, Vector (Multi-Scalar) - 20%, Grid - 10% (Use the Imported - - - Data before and verify against Extensions)
5. Import + Extension + Export + Timeseries Queries
  - 1 hour test run. Change with request size from 1hr, 5min to 1min. (total 3 hours)

# Help
```bash
-h | --help: Usage
    <ROOT_DIR> <COMMAND> <REQ_SIZE>
    - REQ_SIZE (optional): 24(1) | 288(2) | 1044(3)
  NOTE: Modify test.conf as necessary
  e.g.
  test_plan.sh ~/wdias/wdias-performance-test run
  test_plan.sh ~/wdias/wdias-performance-test run 2
  - Run all the steps in order of setup, import, create_extension, extension, export, all, query

  test_plan.sh ~/wdias/wdias-performance-test setup
  test_plan.sh ~/wdias/wdias-performance-test import 24
  test_plan.sh ~/wdias/wdias-performance-test create_extension 24
  test_plan.sh ~/wdias/wdias-performance-test extension 24
  test_plan.sh ~/wdias/wdias-performance-test export 24
  test_plan.sh ~/wdias/wdias-performance-test all 24
  test_plan.sh ~/wdias/wdias-performance-test query 24

  Distibuted Mode
  SERVER_IPS=<IP1,IP2...> test_plan.sh ~/wdias/wdias-performance-test run
```

Run all test cases
- `./test-plan/test_plan.sh ~/wdias/wdias-performance-test run`
Run all test cases in Distributed Mode
- `SERVER_IPS=<IP1,IP2...> ./test-plan/test_plan.sh ~/wdias/wdias-performance-test run`
