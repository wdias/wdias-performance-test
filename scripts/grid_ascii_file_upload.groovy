import org.apache.jmeter.protocol.http.util.HTTPFileArgs
import org.apache.jmeter.util.JMeterUtils

def reqSizeMap = [
        24  : 60,
        288 : 30,
        1440: 15
]
def dateMap = [
        24  : '2017-05-24',
        288 : '2017-05-25',
        1440: '2017-05-26'
]

int id = vars.get("id") as Integer
int reqSize = vars.get("reqSize") as Integer
String date = vars.get("date").trim()
boolean realData = vars.get("realData") as Boolean

int noHr = 24
int gap = reqSizeMap.get(reqSize)
int noMin = (int) (60 / gap)

HTTPFileArgs filesToSend = new HTTPFileArgs()

String dateStr = dateMap.get(reqSize)
String day = date.split('-')[2]
noHr.times {
    def hour = it
    noMin.times {
        String path
        if (realData) {
            path = "./water_level_grid/${gap}_min/2018-05-${day}/2018-05-${day}_${String.format("%02d", hour)}-${String.format("%02d", it*gap)}-00.asc"
        } else {
            path = "./water_level_grid/${gap}_min/${dateStr}_${String.format("%02d", hour)}-${String.format("%02d", it*gap)}-00.asc"
        }
        def paramName = "${date}T${String.format("%02d", hour)}:${String.format("%02d", it*gap)}:00Z"
        filesToSend.addHTTPFileArg(path, paramName, "text/plain")
    }
}
// https://jmeter.apache.org/api/org/apache/jmeter/protocol/http/sampler/HTTPSamplerBase.html#setHTTPFiles-org.apache.jmeter.protocol.http.util.HTTPFileArg:A-
// 4. HTTPSamplerProxy Class - https://www.blazemeter.com/blog/top-8-jmeter-java-classes-you-should-be-using-with-groovy
sampler.setHTTPFiles(filesToSend.asArray())
sampler.getHeaderManager().removeHeaderNamed("Content-Type");
sampler.setDoMultipart(true)
log.info("#${id}: Upload ASCII Grid Files (realData=${realData}) >> #files:${noHr * noMin}, reqSize:${reqSize}, date:${date} with noMin:${noMin}")
