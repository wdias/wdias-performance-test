import org.apache.jmeter.protocol.http.control.Header
import org.apache.jmeter.util.JMeterUtils
import groovy.json.JsonBuilder
import groovy.json.JsonSlurper

def timeStepMap = [
        24  : "{\"timeStepId\":\"each_hour\",\"unit\":\"Hour\",\"multiplier\":1}",
        288 : "{\"timeStepId\":\"each_5_min\",\"unit\":\"Minute\",\"multiplier\":5}",
        1440: "{\"timeStepId\":\"each_min\",\"unit\":\"Minute\",\"multiplier\":1}"
]
def gridTimeStepMap = [
        24  : "{\"timeStepId\":\"each_60_min\",\"unit\":\"Minute\",\"multiplier\":60}",
        288 : "{\"timeStepId\":\"each_30_min\",\"unit\":\"Minute\",\"multiplier\":30}",
        1440: "{\"timeStepId\":\"each_15_min\",\"unit\":\"Minute\",\"multiplier\":15}"
]
int reqSize = vars.get("reqSize") as Integer
def DataType = vars.get("valueType").trim()
int id = vars.get("id") as Integer
String dateStr = vars.get("date").trim() as String

def jsonSlurper = new JsonSlurper()
def jsonBuilder = new JsonBuilder()
def timeStepTxt = (DataType == "Grid") ? gridTimeStepMap.get(reqSize) : timeStepMap.get(reqSize)
jsonBuilder {
    moduleId vars.get("moduleId").trim()
    valueType vars.get("valueType").trim()
    parameter jsonSlurper.parseText(vars.get("parameter").trim())
    location jsonSlurper.parseText(vars.get("location").trim())
    timeseriesType vars.get("timeseriesType").trim()
    timeStep jsonSlurper.parseText(timeStepTxt)
}

//log.info("Message:" + jsonBuilder.toPrettyString());
sampler.getHeaderManager().removeHeaderNamed("Content-Type");
sampler.getHeaderManager().add(new Header("Content-Type", "application/json"));
sampler.addNonEncodedArgument("", jsonBuilder.toPrettyString(), "")
sampler.setPostBodyRaw(true)
