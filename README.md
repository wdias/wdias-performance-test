# wdias-performance-test
Distributed performance testing based on JMeter.

## Dev Guide
#### How to run grrovy code
- Download Groovy same as JMeter JSR223 version and extract into the folder (Add permission to run, if required)
- `./groovy-2.4.16/bin/groovy ./scripts/wait_for_extension_timeseries.groovy`
#### Evaluate the Bash Script
- `bash -x ./bin/macos/test-dev  enable import scalar`

## Test Plan
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

## Help
- Enable one of MODULE: import(i) | export(e) | extension(x) | all(a)
  - `./bin/macos/test-dev enable import`
- Disable one of MODULE
  - `./bin/macos/test-dev disable import`
- Run test case with given MODULE, DATA_TYPE and REQ_SIZE
  - MODULE: import(i) | export(e) | extension(x) | all(a)
  - DATA_TYPE: scalar(s) | vector(v) | grid(g)
  - REQ_SIZE: 24(1) | 288(2) | 1044(3)
  - `./bin/macos/test-dev up import scalar 24` or `./bin/macos/test-dev up i s 1`
Using above commands it's possible to cover the "Test Plan" above.
It's possible to run the test cases in two modes: `prod` or `dev`. In each envirnment, configure the `./bin/macos/test.conf` as appropriate. 

### Prod testing
- Change the `ENV` value to `prod` in `test.conf`
- 

### Dev testing


## Support
### Run via Command Line
```
./apache-jmeter-5.0/bin/jmeter.sh -n -t wdias_performance_test.jmx -l testresults.jtl -j non-ui.log -JreqSize=24
```
- https://stackoverflow.com/questions/14317715/jmeter-changing-user-defined-variables-from-command-line
- Variable can be provide as properties file - https://gerardnico.com/jmeter/property_file#userproperties
