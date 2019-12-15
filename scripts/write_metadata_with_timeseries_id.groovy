import groovy.transform.Field

String id = vars.get("id").trim()
String timeseriesId = vars.get("timeseriesId").trim()
String moduleId = vars.get("moduleId").trim()
String valueType = vars.get("valueType").trim()
String parameter = vars.get("parameter").trim()
String location = vars.get("location").trim()
String timeseriesType = vars.get("timeseriesType").trim()
String timeStep = vars.get("timeStep").trim()

def metadataFile = new File('./data/ts_meta_tmp.csv')
if (id == "1" && metadataFile.exists()) {
    log.info("Delete metadata file.......... Id: ${id}");
    metadataFile.delete()
}
metadataFile.append("\n${id};${timeseriesId}; ${moduleId}; ${valueType}; ${parameter}; ${location}; ${timeseriesType}; ${timeStep}")
// log.info("\n${id};${timeseriesId}; ${moduleId}; ${valueType}; ${parameter}; ${location}; ${timeseriesType}; ${timeStep}")

int metadataSize = vars.get("metadataSize").trim() as Integer
if (id == "${metadataSize}") {
    @Field Map<Integer, String> timeseries = new HashMap<Integer, String>();
    metadataFile.eachLine { line, number ->
        if (number == 1)
            return
        String[] str = line.split(';')
        if (str.length != 8)
            return
        timeseries.put(str[0].trim() as Integer, line)
    }
    timeseries = timeseries.sort { a, b -> a.key <=> b.key }

    log.info("Rearrange ts metadata CSV <${timeseries.size()}> ..........")
    if (timeseries.size() != metadataSize) {
        prev.setSuccessful(false)
        return
    }
    // -- main
    def file = new File('./data/ts_meta.csv')
    if (file.exists()) {
        file.delete()
    }
    file.write("id;timeseriesId; moduleId; valueType; parameter; location; timeseriesType; timeStep")

    timeseries.each { key, line ->
        file.append("\n${line}")
    }

    // log.info("Rearrange Timeseries. Delete metadata file.......... Id: ${id}");
    metadataFile.delete()
}
