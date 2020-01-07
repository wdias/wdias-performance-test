import org.apache.jmeter.protocol.http.control.Header
import groovy.json.JsonBuilder

def reqSizeMap = [
        24  : 'ts_1hr',
        288 : 'ts_5min',
        1440: 'ts_1min'
]

class Point {
    String time;
    float value
}

List<Point> pointList = new ArrayList<>()

def reqSize = vars.get("reqSize") as Integer
String date = vars.get("date").trim() as String
//log.info("Req Size:" + reqSizeMap.get(reqSize))
def file = new File("./data/${reqSizeMap.get(reqSize)}.csv")
file.eachLine { line, number ->
    if (number == 1)
        return
    String[] str = line.split(',')
    if (str.length != 2)
        return
    time = "${date}T${str[0].trim().split('T')[1]}"
    pointList.add(new Point(time: time, value: Float.parseFloat(str[1].trim())))
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

// log.info("Message:" + vars.get(jsonBuilder.toPrettyString()))
sampler.getHeaderManager().removeHeaderNamed("Content-Type");
sampler.getHeaderManager().add(new Header("Content-Type", "application/json"));
sampler.addNonEncodedArgument("", jsonBuilder.toPrettyString(), "")
sampler.setPostBodyRaw(true)
