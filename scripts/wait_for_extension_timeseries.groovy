// def DOMAIN = "wdias.com"
def DOMAIN = vars.get("DOMAIN") as String
int MaxRetry = 3

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

def requestId = args[0]
// def requestId =  vars.get("requestId").trim()
// log.info("requestId: " + requestId)

def url = new URL("https://api.${DOMAIN}/status/import/scalar/${requestId}")
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
