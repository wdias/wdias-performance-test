def moduleIds = ["HEC-HMS", "FLO2D", "WRF", "HEC-RAS"]

class Location {
    String locationId
    String name
    float lat
    float lon
}

List<Location> locations = new ArrayList<>()

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

def parameter = '{"parameterId":"O.Precipitation","variable":"Precipitation","unit":"mm","parameterType":"Instantaneous"}'
def timeStep = "{\"timeStepId\":\"each_15_min\",\"unit\":\"Minute\",\"multiplier\":15}"

file = new File('./data/ts_meta.csv')
file.write("id; moduleId; valueType; parameter; location; timeseriesType; timeStep\n")
def id = 1
moduleIds.each { moduleId ->
    locations.each { l ->
        def location = "{\"locationId\":\"${l.locationId}\",\"name\":\"${l.name}\",\"lat\":${l.lat},\"lon\":${l.lon}}"
        file.append("${id}; ${moduleId}; Scalar; ${parameter}; ${location}; ExternalHistorical; ${timeStep}")
        id++
        if (id <= moduleIds.size() * locations.size()) {
            file.append("\n")
        }
    }
}
