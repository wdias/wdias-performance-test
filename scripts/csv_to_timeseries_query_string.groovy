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
def DataType = vars.get("DataType")

def jsonSlurper = new JsonSlurper()

def params = [
        moduleId      : vars.get("moduleId").trim(),
        valueType     : DataType,
        parameterId   : jsonSlurper.parseText(vars.get("parameter").trim()).parameterId,
        locationId    : jsonSlurper.parseText(vars.get("location").trim()).locationId,
        timeseriesType: vars.get("timeseriesType").trim(),
        timeStepId    : jsonSlurper.parseText(timeStepMap.get(reqSize)).timeStepId
]
if (DataType == 'Grid') {
    params = [
            moduleId      : vars.get("gModuleId").trim(),
            valueType     : vars.get("gValueType").trim(),
            parameterId   : jsonSlurper.parseText(vars.get("gParameter").trim()).parameterId,
            locationId    : jsonSlurper.parseText(vars.get("gLocation").trim()).locationId,
            timeseriesType: vars.get("gTimeseriesType").trim(),
            timeStepId    : jsonSlurper.parseText(gridTimeStepMap.get(reqSize)).timeStepId
    ]
}

def query_string = params.collect { k, v -> "$k=$v" }.join('&')

vars.put("query_string", query_string)
