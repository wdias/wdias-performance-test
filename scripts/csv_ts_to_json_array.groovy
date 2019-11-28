import org.apache.jmeter.protocol.http.control.Header
import groovy.json.JsonBuilder

def reqSizeMap = [
        24  : 'ts_1hr',
        288 : 'ts_5min',
        1440: 'ts_1min'
]
def reqSizeRealDataMap = [
        24  : 60,
        288 : 30,
        1440: 15
]
def locationMap = [
        0: 'attidiya',
        1: 'battaramulla',
        2: 'ibattara',
        3: 'kottawa',
        4: 'waga'
]

class Point {
    String time;
    float value
}

List<Point> pointList = new ArrayList<>()

int id = vars.get("id") as Integer
int reqSize = vars.get("reqSize") as Integer
String date = JMeterUtils.getPropDefault("date", "2017-01-01").trim()
boolean realData = vars.get("realData") as Boolean

//log.info("Req Size:" + reqSizeMap.get(reqSize))
String day = date.split('-')[2]
File file = new File("./data/${reqSizeMap.get(reqSize)}.csv")
if (realData) {
    String location = locationMap.get((id + day.toInteger()) % 5)
    file = new File("./precipitation/${reqSizeRealDataMap.get(reqSize)}_min/${location}/2019-07-${day}_${location}.csv")
}
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

// log.info("Message:" + vars.get(jsonBuilder.toPrettyString()))
sampler.getHeaderManager().removeHeaderNamed("Content-Type");
sampler.getHeaderManager().add(new Header("Content-Type", "application/json"));
sampler.addNonEncodedArgument("", jsonBuilder.toPrettyString(), "")
sampler.setPostBodyRaw(true)
