# wdias-performance-test
Distributed performance testing based on JMeter.

## Dev Guide
#### How to run grrovy code
- Download Groovy same as JMeter JSR223 version and extract into the folder (Add permission to run, if required)
- `./groovy-2.4.16/bin/groovy ./scripts/wait_for_extension_timeseries.groovy`
#### Evaluate the Bash Script
- `bash -x ./bin/macos/test-dev  enable import scalar`

## Installation
- Downalod Apache JMeter 5.0 - `wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.0.tgz`
- Extract `tar -xzf apache-jmeter-5.0.tgz`
- Run JMeter - `./apache-jmeter-5.0/bin/jmeter &`
- Download JMeter Plugin Manager - `curl -O -J -L https://jmeter-plugins.org/get/  && mv jmeter-plugins-manager-1.3.jar apache-jmeter-5.0/lib/ext`
- Open the `wdias_performance_test.jmx` test cases, then JMeter will asked to install the requered plugins

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
- Enable one of MODULE (and DATA_TYPE on prod)
  - MODULE: import(i) | export(e) | extension(x) | all(a)
  - DATA_TYPE: scalar(s) | vector(v) | grid(g)
  - `./bin/macos/test-dev enable import scalar`
- Disable one of MODULE
  - `./bin/macos/test-dev disable import scalar`
- Run test case with given MODULE, DATA_TYPE and REQ_SIZE
  - MODULE: import(i) | export(e) | extension(x) | all(a)
  - DATA_TYPE: scalar(s) | vector(v) | grid(g)
  - REQ_SIZE: 24(1) | 288(2) | 1044(3)
  - `./bin/macos/test-dev up import scalar 24` or `./bin/macos/test-dev up i s 1`
Using above commands it's possible to cover the "Test Plan" above.
It's possible to run the test cases in two modes: `prod` or `dev`. In each envirnment, configure the `./bin/macos/test.conf` as appropriate. 

### Prod testing
- Change the `ENV` value to `prod` in `test.conf`
- Change `TST_FEEDBACK_<MODULE>_prod_<DATA_TYPE>` as necessary according to Throughput Step Timer for each `tst-timer-<MODULE>_prod_<DATA_TYPE>`
  - Format: `<INITIAL_THREADS,MAXIMUM_THREADS,NUMBER_OF_THREADS_TO_KEEP_ONDEMAND>`
  - E.g. `"100,3000,50"` means;
    - init concurrency thread group with 100 threads
    - allow up to create 3000 threads in order to keep number of requests hold as mentioned in Throughput Step Timer
    - create extra 50 threads in order to provide more threads on demand
- Change `TST_HOLD_<MODULE>_prod_<DATA_TYPE>` as necessary
  - The period of time that test case is running as defined in the Throughput Step Timer for each `tst-timer-<MODULE>_prod_<DATA_TYPE>`

- Enable a module with given data type
  - `./bin/macos/test-dev enable import scalar`
- Run the test case for the scenario
  - `./bin/macos/test-dev up import scalar 24`
- Disable the module with given data type
  - `./bin/macos/test-dev disable import scalar`

Enable and run the test cases until it met the Test Plan conditions. If one instance can't run up to the given limits, then consider running multiple instance the same test case in order to fulfill given requirement.
E.g. Lets consider 2nd case of Test Plan. For Import Scalar, it should be able to run at maximum of 2100 concurent requests. If it's unable to archive with one instance, then consider using 3 instances running parallel with each one is creating 2100/3 = 700 concurent requests.

### Dev testing
- - Change the `ENV` value to `dev` in `test.conf`

## Support
### Run via Command Line
```
./apache-jmeter-5.0/bin/jmeter.sh -n -t wdias_performance_test.jmx -l testresults.jtl -j non-ui.log -JreqSize=24
```
- https://stackoverflow.com/questions/14317715/jmeter-changing-user-defined-variables-from-command-line
- Variable can be provide as properties file - https://gerardnico.com/jmeter/property_file#userproperties

## K8s - Distributed JMeter
Created using [JMeter Distributed](https://github.com/helm/charts/tree/master/stable/distributed-jmeter) Helm charts.
The original helm charts try to install some plugins while creating the Docker container. But when we want to install other set of plugins, there're some conflicts which difficult to resolve.
### Installation
- Build and deploy into K8s with `wdias build ~/wdias/wdias-performance-test && wdias helm_install wdias-performance-test/helm/wdias-performance-test`
  - `wdias` refer to `wdias="~/wdias/wdias/bin/macos/dev"` from [wdias](https://github.com/wdias/wdias)
### Configuration
In order to run the Distributed JMeter within the same cluster, it need to set up a proper domain. In that case, requests will go outside of the cluster and come back though the ingress/load balancer.
I that is not the case, it need to call via internal service calls. In order to support that, JMeter performance test contains User defined variable names for both the cases. Activate the appropriate User define variables as per the planing to do the performance test.
