import org.apache.jmeter.protocol.http.control.Header
import groovy.json.JsonBuilder
import groovy.json.JsonSlurper

def timeStepMap = [
        24  : "{\"timeStepId\":\"each_hour\",\"unit\":\"Hour\",\"multiplier\":1}",
        288 : "{\"timeStepId\":\"each_5_min\",\"unit\":\"Minute\",\"multiplier\":5}",
        1440: "{\"timeStepId\":\"each_min\",\"unit\":\"Minute\",\"multiplier\":1}"
]

int reqSize = vars.get("reqSize") as Integer
def DataType = vars.get("valueType").trim()
// Not creating extensions for Grid DataType (it's possible to have extensions do complex task on Grid data)
if (DataType == "Grid") {
    return
}

class Parameter {
    String parameterId
    String variable
    String unit
    String parameterType
}

class Location {
    String locationId
    String name
    String lat
    String lon
}

class TimeStep {
    String timeStepId
    String unit
    String multiplier
}

class Variable {
    String variableId
    String moduleId
    String valueType
    Parameter parameter
    Location location
    String timeseriesType
    TimeStep timeStep
}

def jsonSlurper = new JsonSlurper()
List<Variable> variablesList = [new Variable(
        variableId: "Input",
        moduleId: vars.get("moduleId").trim(),
        valueType: DataType,
        parameter: jsonSlurper.parseText(vars.get("parameter").trim()),
        location: jsonSlurper.parseText(vars.get("location").trim()),
        timeseriesType: vars.get("timeseriesType").trim(),
        timeStep: jsonSlurper.parseText(timeStepMap.get(reqSize))
), new Variable(
        variableId: "Output",
        moduleId: vars.get("moduleId").trim(),
        valueType: DataType,
        parameter: jsonSlurper.parseText(vars.get("parameter").trim()),
        location: jsonSlurper.parseText(vars.get("location").trim()),
        timeseriesType: vars.get("timeseriesType").trim(),
        timeStep: jsonSlurper.parseText(timeStepMap.get(reqSize))
)]

def jsonBuilder = new JsonBuilder()
jsonBuilder {
    extensionId "validation_min_non_missing_values_check_on_time"
    extension "Validation"
    function "MinNonMissingValuesCheck"
    variables variablesList.collect { Variable v ->
        [
                variableId: v.variableId,
                metadata  : {
                    moduleId v.moduleId
                    valueType v.valueType
                    parameter v.parameter
                    location v.location
                    timeseriesType v.timeseriesType
                    timeStep v.timeStep
                }
        ]
    }
    inputVariables jsonSlurper.parseText("[\"Input\"]")
    outputVariables jsonSlurper.parseText("[\"Input\"]")
    trigger jsonSlurper.parseText('''
        [{
            "trigger_type": "OnTime",
            "trigger_on": ["*/10 * * * *"]
        }]
     ''')
    options jsonSlurper.parseText('''{
         "checkRelativePeriod": {
            "unit": "hour",
            "start": -12,
            "end": 0
        },
        "minNumberOfValues": 12
    }''')
}
//log.info("Message:" + jsonBuilder.toPrettyString())

sampler.getHeaderManager().add(new Header("Content-Type","application/json"));
sampler.addNonEncodedArgument("", jsonBuilder.toPrettyString(), "")
sampler.setPostBodyRaw(true)
