import groovy.transform.Field

String id = vars.get("id").trim()
String timeseriesId = vars.get("timeseriesId").trim()
String moduleId = vars.get("moduleId").trim()
String valueType = vars.get("valueType").trim()
String parameter = vars.get("parameter").trim()
String location = vars.get("location").trim()
String timeseriesType = vars.get("timeseriesType").trim()
String timeStep = vars.get("timeStep").trim()

f = new File('./data/ts_meta_created.csv')
if (id == "1") {
    log.info("Delete file.......... Id: ${id}");
    f.delete()
}
f.append("\n${id}; ${timeseriesId}; ${moduleId}; ${valueType}; ${parameter}; ${location}; ${timeseriesType}; ${timeStep}")

log.info("\n${id}; ${timeseriesId}; ${moduleId}; ${valueType}; ${parameter}; ${location}; ${timeseriesType}; ${timeStep}")

String metadataSize = vars.get("metadataSize").trim()
if (id == '1000') {
    @Field def noTS = 1000
    @Field def gap = 10

    @Field Map<Integer, String> timeseries = new HashMap<Integer, String>();
    def metadataFile = new File('./data/ts_meta_created.csv')
    metadataFile.eachLine { line, number ->
        if (number == 1)
            return
        String[] str = line.split(';')
        if (str.length != 8)
            return
        timeseries.put(str[0].trim() as Integer, line)
    }
    timeseries = timeseries.sort { a, b -> a.key <=> b.key }

    log.info('Rearrange ts metadata CSV ..........')
    // -- main
    file = new File('./data/ts_meta123.csv')
    file.write("id; timeseriesId; moduleId; valueType; parameter; location; timeseriesType; timeStep")
    // -- grid
    fileGrid = new File('./data/ts_meta_grid123.csv')
    fileGrid.write("id; timeseriesId; moduleId; valueType; parameter; location; timeseriesType; timeStep")

    timeseries.each { key, line ->
        file.append("\n${line}")
        String[] str = line.split(';')
        if ((str.length != 8) && str[3].trim() == 'Grid') {
            fileGrid.append("\n${line}")
        }
    }
}
