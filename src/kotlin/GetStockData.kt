// https://futures.io/reviews-brokers-data-feeds/31385-google-finance-historical-daily-data-retrieved-programmatically.html

import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.PrintWriter
import java.io.File
import java.net.URL
import java.net.URLConnection

object App {
  val stocks = listOf("MCD", "CL", "ORCL", "WFC", "COST")
  // Costco is missing 1 April, 2016... Forget it...
  //val stocks = List("MCD", "CL", "ORCL", "WFC")
  val template = "http://www.google.com/finance/historical?q=TICKER&histperiod=daily&startdate=Jan+1+2010&enddate=Jan+1+2017&output=csv"

  fun getTickerInfo(ticker: String): List<String> {
    val url = URL(template.replace("TICKER", ticker))
    val urlConn = url.openConnection()
    val inputStreamReader = InputStreamReader(urlConn.getInputStream())
    val bufferedReader = BufferedReader(inputStreamReader)

    fun loop(acc: List<String>): List<String> {
      val line = bufferedReader.readLine()
      return when{
        line is String -> loop(listOf(line) +  acc)
        else -> { //null
          bufferedReader.close()
          inputStreamReader.close()
          listOf(acc.last()) + acc.dropLast(1)
        }
      }
    }

    return loop(emptyList<String>())
  }

  @JvmStatic fun main(args: Array<String>) {
    val dir = "csv/"
    stocks.forEach{ticker -> run {
      val pw = PrintWriter(File(dir + ticker + ".csv" ))
      val lines = getTickerInfo(ticker)
      //lines.foreach(line => pw.write(line + "\n"))
      pw.write(lines.joinToString("\n"))
      pw.close()
    }}
  }
}


// assigns x to the output of the block. keyword: `run`
//val x = run {
//  var out = emptyList<Int>()
//  for (i in listOf(1,2,3)) {
//    out += i
//  }
//  out
//}

// compile: kotlinc -d GetStockData.jar GetStockData.kt
// run: kotlin -cp GetStockData.jar App
// Or:
// compile: kotlinc -include-runtime -d GetStockData.jar GetStockData.kt
// compile: java -cp GetStockData.jar App
