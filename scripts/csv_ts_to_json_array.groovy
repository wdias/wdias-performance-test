import groovy.json.JsonBuilder

class Point {
    String time;
    float value
}

List<Point> pointList = new ArrayList<>()

def file = new File('./data/ts_1.csv')
file.eachLine { line, number ->
    if (number == 1)
        return
    String[] str = line.split(',')
    if (str.length != 2)
        return
    pointList.add(new Point(time: str[0].trim(), value: Float.parseFloat(str[1].trim())))
}

def jsonBuilder = new JsonBuilder()
jsonBuilder(
        pointList.collect { point ->
            [
                    time : point.time,
                    value: point.value
            ]
        }
)

// println jsonBuilder.toPrettyString()

sampler.addNonEncodedArgument("", jsonBuilder.toPrettyString(), "")
sampler.setPostBodyRaw(true)
