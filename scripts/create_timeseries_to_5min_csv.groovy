def noHr = 24
def gap = 5
def noMin = 60 / gap

file = new File('./data/ts_5min.csv')

file.write("TIMESTAMP, VALUE\n")
Date date = new Date()
String dateStr = date.format("yyyy-MM-dd")
noHr.times {
    def hour = it
    noMin.times {
        file.append("${dateStr}T${String.format("%02d", hour)}:${String.format("%02d", it*gap)}:00Z, ${(hour*100 + it*gap)*0.001}")
        if(!(hour == noHr - 1 && it == noMin - 1)) {
            file.append("\n")
        }
    }
}
