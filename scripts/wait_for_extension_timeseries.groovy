// def DOMAIN = "wdias.com"
def DOMAIN = vars.get("DOMAIN") as String
def DataType = vars.get("valueType").trim()
int MaxRetry = 3
// Not creating extensions for Grid DataType (it's possible to have extensions do complex task on Grid data)
if (DataType == "Grid") {
    SampleResult.setSuccessful(true)
    return
}

def nullTrustManager = [
    checkClientTrusted: { chain, authType ->  },
    checkServerTrusted: { chain, authType ->  },
    getAcceptedIssuers: { null }
]

def nullHostnameVerifier = [
    verify: { hostname, session -> 
        //true
        hostname.endsWith(DOMAIN)
    }
]

javax.net.ssl.SSLContext sc = javax.net.ssl.SSLContext.getInstance("SSL")
sc.init(null, [nullTrustManager as  javax.net.ssl.X509TrustManager] as  javax.net.ssl.X509TrustManager[], null)
javax.net.ssl.HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory())
javax.net.ssl.HttpsURLConnection.setDefaultHostnameVerifier(nullHostnameVerifier as javax.net.ssl.HostnameVerifier)
// -- Disable SSL: https://gist.github.com/barata0/63705c0bcdd1054af2405e90c06f6b71

if (args.size() < 1) {
    def timeseriesId =  vars.get("timeseriesId").trim()
    SampleResult.setSuccessful(false)
    SampleResult.setResponseMessage("Unable to get status of timeseriesId:" + timeseriesId)
    return
}
def requestId = args[0]
// def requestId =  vars.get("requestId").trim()
// log.info("requestId: " + requestId)

def protocol = vars.get("protocol")
def svc_status = vars.get("svc_status")
def path_status = vars.get("path_status")
def url = new URL("${protocol}://${svc_status}.${DOMAIN}${path_status}/import/${DataType.toLowerCase()}/${requestId}")
int retry = 1
while ({
    sleep(500)
    def get = url.openConnection()
    def getRC = get.getResponseCode()
    retry++
    SampleResult.setResponseCode(String.valueOf(getRC))
    SampleResult.setSuccessful(getRC < 400)
    retry <= 3 && getRC >= 400 // breaks if status code is 200
}()) continue // https://stackoverflow.com/a/22057667

SampleResult.setResponseMessage("Unable to get status of " + requestId)
