import org.apache.jmeter.util.JMeterUtils

int metadataSize = vars.get("metadataSize") as Integer
int metadataGridSize = vars.get("metadataGridSize") as Integer
int id = vars.get("id") as Integer
String dateStr = JMeterUtils.getPropDefault("date","2017-01-01").trim() as String

def size = args.size() > 0 ? metadataGridSize : metadataSize

// log.info("id:" + id)
if (id == size) {
    Date date = Date.parse("yyyy-MM-dd", dateStr) + 1
    JMeterUtils.setProperty("date", date.format("yyyy-MM-dd"))
    log.info("id:${id} / size:${size} >> Increment date to :" + date.format("yyyy-MM-dd"))
}
