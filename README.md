# wdias-performance-test
Distributed performance testing based on JMeter.

## Run via Command Line
```
./apache-jmeter-5.0/bin/jmeter.sh -n -t wdias_performance_test.jmx -l testresults.jtl -j non-ui.log -JreqSize=24
```
- https://stackoverflow.com/questions/14317715/jmeter-changing-user-defined-variables-from-command-line
- Variable can be provide as properties file - https://gerardnico.com/jmeter/property_file#userproperties

## Dev Guide
#### How to run grrovy code
- Download Groovy same as JMeter JSR223 version and extract into the folder (Add permission to run, if required)
- `./groovy-2.4.16/bin/groovy ./scripts/wait_for_extension_timeseries.groovy`
