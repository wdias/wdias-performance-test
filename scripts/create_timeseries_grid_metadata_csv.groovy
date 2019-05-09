def moduleIds = ["FLO2D"]

class Location {
    String locationId
    String description
    int rows
    int columns
    String geoDatum
    float firstCellCeter_x
    float firstCellCeter_y
    int xCellSize
    int yCellSize
}

List<Location> locations = new ArrayList<>()

// Locations source: https://developers.google.com/public-data/docs/canonical/countries_csv
def gridsFile = new File('./data/grids.csv')
gridsFile.eachLine { line, number ->
    if (number == 1)
        return
    String[] str = line.split(',')
    if (str.length != 9)
        return
    locations.add(new Location(
            locationId: str[0].trim(), description: str[1].trim(),
            rows: Integer.parseInt(str[2].trim()), columns: Integer.parseInt(str[3].trim()), geoDatum: str[4].trim(),
            firstCellCeter_x: Float.parseFloat(str[5].trim()), firstCellCeter_y: Float.parseFloat(str[6].trim()),
            xCellSize: Integer.parseInt(str[7].trim()), yCellSize: Integer.parseInt(str[8].trim())
    ))
}

def parameter = '{"parameterId":"O.Waterlevel","variable":"Waterlevel","unit":"m","parameterType":"Instantaneous"}'
def timeStep = "{\"timeStepId\":\"each_15_min\",\"unit\":\"Minute\",\"multiplier\":15}"

file = new File('./data/ts_grid_meta.csv')
file.write("gId; gModuleId; gValueType; gParameter; gLocation; gTimeseriesType; gTimeStep\n")
def id = 1
moduleIds.each { moduleId ->
    locations.each { l ->
        def firstCellCenter = "{\"x\":${l.firstCellCeter_x},\"y\":${l.firstCellCeter_y}}"
        def gridFirstCell = "{\"firstCellCenter\":${firstCellCenter},\"xCellSize\":${l.xCellSize},\"yCellSize\":${l.yCellSize}}"
        def location = "{\"locationId\":\"${l.locationId}\",\"description\":\"${l.description}\",\"rows\":${l.rows},\"columns\":${l.columns},\"geoDatum\":\"${l.geoDatum}\",\"gridFirstCell\":${gridFirstCell}}"
        file.append("${id}; ${moduleId}; Grid; ${parameter}; ${location}; ExternalHistorical; ${timeStep}")
        id++
        if (id <= moduleIds.size() * locations.size()) {
            file.append("\n")
        }
    }
}
