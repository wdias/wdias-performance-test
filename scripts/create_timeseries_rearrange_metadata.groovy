import groovy.transform.Field

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
timeseries = timeseries.sort {a,b -> a.value < b.value}

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
