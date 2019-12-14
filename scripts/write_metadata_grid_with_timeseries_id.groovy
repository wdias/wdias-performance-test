import groovy.transform.Field

String id = vars.get("id").trim()
String timeseriesId = vars.get("timeseriesId").trim()
String moduleId = vars.get("moduleId").trim()
String valueType = vars.get("valueType").trim()
String parameter = vars.get("parameter").trim()
String location = vars.get("location").trim()
String timeseriesType = vars.get("timeseriesType").trim()
String timeStep = vars.get("timeStep").trim()

def metadataGridFile = new File('./data/ts_meta_grid_tmp.csv')
if (id == "1" && metadataGridFile.exists()) {
    log.info("Delete Grid metadata file.......... Id: ${id}");
    metadataGridFile.delete()
}
metadataGridFile.append("\n${id};${timeseriesId}; ${moduleId}; ${valueType}; ${parameter}; ${location}; ${timeseriesType}; ${timeStep}")
// log.info("\n${id};${timeseriesId}; ${moduleId}; ${valueType}; ${parameter}; ${location}; ${timeseriesType}; ${timeStep}")

int metadataGridSize = vars.get("metadataGridSize").trim() as Integer
if (id == "${metadataGridSize}") {
    @Field Map<Integer, String> gridTimeseries = new HashMap<Integer, String>();
    metadataGridFile.eachLine { line, number ->
        if (number == 1)
            return
        String[] str = line.split(';')
        if (str.length != 8)
            return
        gridTimeseries.put(str[0].trim() as Integer, line)
    }
    gridTimeseries = gridTimeseries.sort { a, b -> a.key <=> b.key }

    log.info("Rearrange ts Grid metadata CSV <${gridTimeseries.size()}> ..........")
    if (gridTimeseries.size() != metadataGridSize) {
        prev.setSuccessful(false)
    }
    // -- grid
    fileGrid = new File('./data/ts_meta_grid.csv')
    if (fileGrid.exists()) {
        fileGrid.delete()
    }
    fileGrid.write("id;timeseriesId; moduleId; valueType; parameter; location; timeseriesType; timeStep")

    gridTimeseries.each { key, line ->
        fileGrid.append("\n${line}")
    }

    // log.info("Rearrange Grid Timeseries. Delete metadata file.......... Id: ${id}");
    metadataGridFile.delete()
}
