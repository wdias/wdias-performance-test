def n = 24

file = new File('./data/ts_1hr.csv')

file.write("TIMESTAMP, VALUE\n")
Date date = new Date()
String dateStr = date.format("yyyy-MM-dd")
n.times {
    file.append("${dateStr}T${String.format("%02d", it)}:00:00Z, ${it * 0.1}")
    if (it < n - 1) {
        file.append("\n")
    }
}
