import org.apache.jmeter.protocol.http.control.Header
import groovy.json.JsonBuilder
import groovy.json.JsonSlurper

def jsonSlurper = new JsonSlurper()
def jsonBuilder = new JsonBuilder()
jsonBuilder {
    moduleId vars.get("moduleId").trim()
    valueType vars.get("valueType").trim()
    parameter jsonSlurper.parseText(vars.get("parameter").trim())
    location jsonSlurper.parseText(vars.get("location").trim())
    timeseriesType vars.get("timeseriesType").trim()
    timeStep jsonSlurper.parseText(vars.get("timeStep").trim())
}
// log.info("Message:" + jsonBuilder.toPrettyString());

sampler.getHeaderManager().add(new Header("Content-Type","application/json"));
sampler.addNonEncodedArgument("", jsonBuilder.toPrettyString(), "")
sampler.setPostBodyRaw(true)
