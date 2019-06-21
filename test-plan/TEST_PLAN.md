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
- `./test-plan/test_plan.sh ~/wdias run`
