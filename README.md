# wdias-performance-test
Distributed performance testing based on JMeter.

### Run via Command Line
```
./apache-jmeter-5.0/bin/jmeter.sh -n -t wdias_performance_test.jmx -l testresults.jtl -j non-ui.log -JreqSize=24
```
- https://stackoverflow.com/questions/14317715/jmeter-changing-user-defined-variables-from-command-line
- Variable can be provide as properties file - https://gerardnico.com/jmeter/property_file#userproperties
