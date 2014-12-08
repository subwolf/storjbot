# StorjBot price ticker
# (c) Robin Beckett 2014

# Melotic: https://www.melotic.com/api/markets/sjcx-btc/ticker
# Poloniex: https://poloniex.com/public?command=returnTicker

package require json
package require http
package require tls

::http::register https 443 [ list ::tls::socket -tls1 true ]

set meloticUrl "https://www.melotic.com/api/markets/sjcx-btc/ticker"
set poloniexUrl "https://poloniex.com/public?command=returnTicker"
set blockscanUrl "http://api.blockscan.com/api2?module=address&action=balance&asset=SJCX&btc_address="

proc commify {num {sep ,}} {
    while {[regsub {^([-+]?\d+)(\d\d\d)} $num "\\1$sep\\2" num]} {}
    return $num
}

proc getMelotic {nick uhost handle chan text} {
	global meloticUrl
        set xml [http::data [http::geturl $meloticUrl -timeout 30000]]
        set latestPriceFloat [dict get [json::json2dict $xml] "latest_price"]
	set latestPriceInt [format {%0.8f} [expr double($latestPriceFloat)]]

        puthelp "PRIVMSG $chan :Melotic SJCX/BTC\: $latestPriceInt"
}

proc getPoloniex {nick uhost handle chan text} {
	global poloniexUrl
        set xml [http::data [http::geturl $poloniexUrl -timeout 30000]]
        set latestPriceFloat [dict get [dict get [json::json2dict $xml] "BTC_SJCX"] "last"]
        set latestPriceInt [format {%0.8f} [expr double($latestPriceFloat)]]

        puthelp "PRIVMSG $chan :Poloniex SJCX/BTC\: $latestPriceInt"
}

proc getMarkets {nick uhost handle chan text} {
	getMelotic $nick $uhost $handle $chan $text
	getPoloniex $nick $uhost $handle $chan $text
}

proc getBalance {nick uhost handle chan text} {
	global blockscanUrl
	putlog "$blockscanUrl$text"
	set xml [http::data [http::geturl "$blockscanUrl$text" -timeout 30000]]
        set latestPriceFloat [dict get [lindex [dict get [json::json2dict $xml] "data"] 0] "balance"]
        set latestPriceInt [commify [format {%d} $latestPriceFloat]]

        puthelp "PRIVMSG $chan :Balance for $text: $latestPriceInt"
}


bind pub - ".melotic" getMelotic
bind pub - ".poloniex" getPoloniex
bind pub - ".markets" getMarkets
bind pub - ".balance" getBalance

putlog "StorjBot loaded..."


