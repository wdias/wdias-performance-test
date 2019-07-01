/**
 * According to the JMeter Dist testing, it's running the same test cases over the given number of clients.
 * As per my initial design, it's difficult to create different client for each data type (Scalar, Vector & Grid)
 * Thus, it's better to handle the data percentage of each type in the JMeter level rather depend on a external ENV.
 * So the idea is, create one single ts_meta.csv which is a combination of timeseries of different data types
 * with given ratios.
 * Since it assumed to have Scalar-70%, Vector-20% & Grid-10% in the WDIAS operations, this script will create
 * a ts_meta.csv timeseries meta series which has random timeseries with above percentages.
 * Here it'll create unique random 3 values between 1-10 and one will fill with grid data, two will fill with
 * vector data. Remain values between 1-10 will fill with scalar data.
 **/
import groovy.transform.Field

@Field def noTS = 1000
@Field def gap = 10
@Field def scalarModuleIds = ["HEC-HMS", "WRF", "HEC-RAS", "MIKE"]
@Field def vectorModuleIds = ["Radar", "Satellite"]
@Field def gridModuleIds = ["FLO2D"]
@Field def parameterMap = [
        "Scalar": '{"parameterId":"O.Precipitation","variable":"Precipitation","unit":"mm","parameterType":"Instantaneous"}',
        "Vector": '{"parameterId":"O.Precipitation","variable":"Precipitation","unit":"mm","parameterType":"Instantaneous"}',
        "Grid"  : '{"parameterId":"O.Waterlevel","variable":"Waterlevel","unit":"m","parameterType":"Instantaneous"}',
]
@Field def timeStep = "{\"timeStepId\":\"each_15_min\",\"unit\":\"Minute\",\"multiplier\":15}"

class Location {
    String locationId
    String name
    float lat
    float lon
}

@Field List<Location> locations = new ArrayList<>()
// Locations source: https://developers.google.com/public-data/docs/canonical/countries_csv
def locationsFile = new File('./data/locations.csv')
locationsFile.eachLine { line, number ->
    if (number == 1)
        return
    String[] str = line.split(',')
    if (str.length != 4)
        return
    locations.add(new Location(locationId: str[0].trim(), name: str[1].trim(), lat: Float.parseFloat(str[2].trim()), lon: Float.parseFloat(str[3].trim())))
}

class GridLocation {
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

@Field List<GridLocation> gridLocations = new ArrayList<>()
// Locations source: https://developers.google.com/public-data/docs/canonical/countries_csv
def gridsFile = new File('./data/grids.csv')
gridsFile.eachLine { line, number ->
    if (number == 1)
        return
    String[] str = line.split(',')
    if (str.length != 9)
        return
    gridLocations.add(new GridLocation(
            locationId: str[0].trim(), description: str[1].trim(),
            rows: Integer.parseInt(str[2].trim()), columns: Integer.parseInt(str[3].trim()), geoDatum: str[4].trim(),
            firstCellCeter_x: Float.parseFloat(str[5].trim()), firstCellCeter_y: Float.parseFloat(str[6].trim()),
            xCellSize: Integer.parseInt(str[7].trim()), yCellSize: Integer.parseInt(str[8].trim())
    ))
}

// -- Locations
def getLocation(index) {
    def l = locations.get(index)
    return "{\"locationId\":\"${l.locationId}\",\"name\":\"${l.name}\",\"lat\":${l.lat},\"lon\":${l.lon}}"
}

def getGridLocation(index) {
    def l = gridLocations.get(index)
    def firstCellCenter = "{\"x\":${l.firstCellCeter_x},\"y\":${l.firstCellCeter_y}}"
    def gridFirstCell = "{\"firstCellCenter\":${firstCellCenter},\"xCellSize\":${l.xCellSize},\"yCellSize\":${l.yCellSize}}"
    return "{\"locationId\":\"${l.locationId}\",\"description\":\"${l.description}\",\"rows\":${l.rows},\"columns\":${l.columns},\"geoDatum\":\"${l.geoDatum}\",\"gridFirstCell\":${gridFirstCell}}"

}
// -- Handle DataTypes
def getScalar(id) {
    def moduleId = scalarModuleIds.get(Math.abs(new Random().nextInt() % scalarModuleIds.size()))
    def parameter = parameterMap.get("Scalar")
    def location = getLocation(id % locations.size())
    return "${moduleId}; Scalar; ${parameter}; ${location}; ExternalHistorical; ${timeStep}"
}

def getVector(id) {
    def moduleId = vectorModuleIds.get(Math.abs(new Random().nextInt() % vectorModuleIds.size()))
    def parameter = parameterMap.get("Vector")
    def location = getLocation(id % locations.size())
    return "${moduleId}; Vector; ${parameter}; ${location}; ExternalHistorical; ${timeStep}"
}

def getGrid(id) {
    def moduleId = gridModuleIds.get(0)
    def parameter = parameterMap.get("Grid")
    def location = getGridLocation(id % gridLocations.size())
    return "${moduleId}; Grid; ${parameter}; ${location}; ExternalHistorical; ${timeStep}"
}

// -- Helpers
def getUnique() {
    Random random = new Random()
    def uniqueList = [
            Math.abs(random.nextInt() % gap),
            Math.abs(random.nextInt() % gap),
            Math.abs(random.nextInt() % gap),
    ]
    uniqueList.unique()
    while (uniqueList.size < 3) {
        uniqueList.add(Math.abs(random.nextInt() % gap))
    }
    def values = ["Scalar"] * gap
    values.set(uniqueList.get(0), "Vector")
    values.set(uniqueList.get(1), "Vector")
    values.set(uniqueList.get(2), "Grid")
    return values
}

// -- main
file = new File('./data/ts_meta.csv')
file.write("id; moduleId; valueType; parameter; location; timeseriesType; timeStep")
// -- grid
fileGrid = new File('./data/ts_meta_grid.csv')
fileGrid.write("id; moduleId; valueType; parameter; location; timeseriesType; timeStep")
def id = 0
def gridId = 0
(noTS / gap).times {
    def step = it
    getUnique().each { dataType ->
        def ts = (dataType == "Scalar") ? getScalar(id) : (dataType == "Vector") ? getVector(id) : getGrid(id)
        file.append("\n${id+1}; ${ts}")
        id++
        if (dataType == "Grid") {
            fileGrid.append("\n${gridId+1}; ${getGrid(gridId)}")
            gridId++
        }
    }
}
