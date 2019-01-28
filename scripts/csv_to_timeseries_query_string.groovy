import groovy.json.JsonSlurper

def jsonSlurper = new JsonSlurper()

def params = [
        moduleId      : vars.get("moduleId").trim(),
        valueType     : vars.get("valueType").trim(),
        parameterId   : jsonSlurper.parseText(vars.get("parameter").trim()).parameterId,
        locationId    : jsonSlurper.parseText(vars.get("location").trim()).locationId,
        timeseriesType: vars.get("timeseriesType").trim(),
        timeStepId    : jsonSlurper.parseText(vars.get("timeStep").trim()).timeStepId
]
def query_string = params.collect { k, v -> "$k=$v" }.join('&')

vars.put("query_string", query_string)
