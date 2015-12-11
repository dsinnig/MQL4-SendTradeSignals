//+------------------------------------------------------------------+
//|                                             SendTradeSignals.mq4 |
//|                                                    Daniel Sinnig |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Daniel Sinnig"
#property link      "https://www.mql5.com"
#property version   "1.1"
#property description "HTTP and Email Broadcast of Trend Information"
#property strict

input string symbolList1 = "EURUSD_GBPUSD_AUDUSD_NZDUSD_USDCAD_USDJPY_USDCHF_EURGBP_EURAUD_EURNZD_EURCAD_EURJPY_EURCHF_GBPAUD_GBPNZD_GBPCAD";
input string symbolList2 = "";
input string symbolList3 = "";
input string symbolList4 = "";
input string symbolList5 = "";
input string intervals = "5M_15M_1H_4H_1D_1W";
input int timeZoneOffset = 0; //Offset for the date/time of the trendchange in hours. 

string symbols[300]; 
int numberOfCandles[300][6];
bool emailSent[300][6];
int numberOfTotalSymbols;
int numberOfSymbols1;
int numberOfSymbols2;
int numberOfSymbols3;
int numberOfSymbols4;
int numberOfSymbols5;
string timeFrames[6];
int mql4TimeFrames[6];
int numberOfTimeframes; 
int offset = timeZoneOffset *60*60;
//+------------------------------------------------------------------+
int OnInit()
  {
   //parsing the symbols
   ushort u_sep = StringGetCharacter("_", 0);
   string symbolString1[50];
   string symbolString2[50];
   string symbolString3[50];
   string symbolString4[50];
   string symbolString5[50];
     
   numberOfSymbols1=StringSplit(symbolList1,u_sep,symbolString1);
   numberOfSymbols2=StringSplit(symbolList2,u_sep,symbolString2);
   numberOfSymbols3=StringSplit(symbolList3,u_sep,symbolString3);
   numberOfSymbols4=StringSplit(symbolList4,u_sep,symbolString4);
   numberOfSymbols5=StringSplit(symbolList5,u_sep,symbolString5);
   
   //copy individual arrays to one big arrays (symbols)
   
   for (int i = 0; i < numberOfSymbols1; ++i) {
      symbols[i] = symbolString1[i];
   }
   
   for (int i = 0; i < numberOfSymbols2; ++i) {
      symbols[i+numberOfSymbols1] = symbolString2[i];
   }
   
   for (int i = 0; i < numberOfSymbols3; ++i) {
      symbols[i+numberOfSymbols1+numberOfSymbols2] = symbolString3[i];
   }
   
   for (int i = 0; i < numberOfSymbols4; ++i) {
      symbols[i+numberOfSymbols1+numberOfSymbols2+numberOfSymbols3] = symbolString4[i];
   }
   
      for (int i = 0; i < numberOfSymbols5; ++i) {
      symbols[i+numberOfSymbols1+numberOfSymbols2+numberOfSymbols3+numberOfSymbols4] = symbolString5[i];
   }
   
   numberOfTotalSymbols = numberOfSymbols1 + numberOfSymbols2 + numberOfSymbols3 + numberOfSymbols4 + numberOfSymbols5;
   
   numberOfTimeframes=StringSplit(intervals,u_sep,timeFrames);
   
   for (int i = 0; i < numberOfTimeframes; ++i) {
      mql4TimeFrames[i] = stringToPeriod(timeFrames[i]);
   }
   
   for (int i = 0; i < numberOfTotalSymbols; ++i)
      for (int j = 0; j < numberOfTimeframes; ++j) {
         numberOfCandles[i][j] = -1;
         emailSent[i][j] = false;
      }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+

int stringToPeriod(string timeframe) {
   if (StringCompare(timeframe, "1M") == 0) return PERIOD_M1;
   if (StringCompare(timeframe, "5M") == 0) return PERIOD_M5;
   if (StringCompare(timeframe, "15M") == 0) return PERIOD_M15;
   if (StringCompare(timeframe, "30M") == 0) return PERIOD_M30;
   if (StringCompare(timeframe, "1H") == 0) return PERIOD_H1;
   if (StringCompare(timeframe, "4H") == 0) return PERIOD_H4;
   if (StringCompare(timeframe, "1D") == 0) return PERIOD_D1;
   if (StringCompare(timeframe, "1W") == 0) return PERIOD_W1;
   return 0;
}

void OnDeinit(const int reason)
  {
   
}

string datetimeToString(datetime _date) {
    if (_date == -1) return "";
    else return IntegerToString(TimeYear(_date),4,'0') + "-" + 
                IntegerToString(TimeMonth(_date),2,'0') + "-" + 
                IntegerToString(TimeDay(_date),2,'0') + " " + 
                IntegerToString(TimeHour(_date),2,'0') + ":" + 
                IntegerToString(TimeMinute(_date),2,'0') + ":" + 
                IntegerToString(TimeSeconds(_date),2,'0');
    
}

string trendToString(double trend) {
   if (trend == 1.0) return "UP";
   if (trend == -1.0) return "DOWN";
   return "SIDE";
}

string escapeAmpersand(string symbol) {
   StringReplace(symbol, "&", "%26");
   return symbol;
}

void OnTick()  {
   if (bNewBar()) {
      for (int i = 0; i < numberOfTotalSymbols; ++i) {
         double currentPrice = iOpen(symbols[i], PERIOD_M1, 0);
         for (int j = 0; j < numberOfTimeframes; ++j) {
            double trend = iCustom(symbols[i], mql4TimeFrames[j], "FXEdgeTrend_noDraw", 0, 0);
            int barsSinceTrendChange = (int) iCustom(symbols[i], mql4TimeFrames[j], "FXEdgeTrend_noDraw", 1, 0);
            double priceAtTrendChange = iCustom(symbols[i], mql4TimeFrames[j], "FXEdgeTrend_noDraw", 2, 0);
            //if (numberOfCandles[i][j] != barsSinceTrendChange) {
               numberOfCandles[i][j] = barsSinceTrendChange;
               string singleSymbolString = symbols[i];
               StringReplace(singleSymbolString, "&", "%26"); //escape &
               StringReplace(singleSymbolString, "#", "%23"); //escape #
               
               datetime dateTimeAtTrendChange = iTime(symbols[i], mql4TimeFrames[j], barsSinceTrendChange) + offset;
                              
               string parameters = "symbol=" + singleSymbolString + "&" + 
                           "cprice=" + DoubleToStr(currentPrice,5) + "&" + 
                           "timeframe=" + timeFrames[j] + "&" +
                           "datetime=" + datetimeToString(dateTimeAtTrendChange) + "&" +
                           "direction=" + trendToString(trend) + "&" +
                           "duration=" + IntegerToString(barsSinceTrendChange) + "&" +
                           "tprice=" + DoubleToStr(priceAtTrendChange,5);
               Print (parameters);
               if (!IsTesting()) {
                  char response[];
                  string responseHeader;
                  char data[];
                  ArrayResize(data,StringToCharArray(parameters,data,0,WHOLE_ARRAY,CP_UTF8)-1);
                  int res=200; 
                  int timeout = 0; 
                  int numAttemps = 0; 
                  const int maxAttempts = 20; 
                  do {
                     if (res != 200) {
                        Print("Error #"+(string)res+", LastError="+(string)GetLastError());
                     }
                     res=WebRequest("POST","http://elliottwavedesk.com/heatmap-update.php", NULL, NULL, timeout, data, ArraySize(data), response,responseHeader);
                     numAttemps++;
                  } while ((res!=200) && (numAttemps < maxAttempts));
                  
                  if (res == 200) {
                     Print ("Transmission successful");
                     //Print ("Header: ", responseHeader); 
                     //Print ("Body: : ",CharArrayToString(response));
                  }
               }
               
               //email 
               if ((barsSinceTrendChange == 1) && (!emailSent[i][j]))               {
                  emailSent[i][j] = true;
                  double previousTrend = iCustom(symbols[i], mql4TimeFrames[j], "FXEdgeTrend_noDraw", 0, 1);
                  string subject = symbols[i] + " (" + timeFrames[j] + "): TREND CHANGE FROM " + trendToString(previousTrend) + " TO " + trendToString(trend);
                  string body = "Symbol: " + symbols[i] + "\r\n" + 
                                "Timeframe: " + timeFrames[j] + "\r\n" + 
                                "Date / Time: " + datetimeToString(dateTimeAtTrendChange) + "\r\n" + 
                                "Price: " + DoubleToStr(currentPrice,5) + "\r\n" + 
                                "New Trend: " + trendToString(trend) + "\r\n" + 
                                "Previous Trend: " + trendToString(previousTrend) + "\r\n" + 
                                "\r\n" + 
                                "***Trends across all timeframes***" + "\r\n";
                  
                  for (int k = 0; k < numberOfTimeframes; ++k) {
                     double tr = iCustom(symbols[i], mql4TimeFrames[k], "FXEdgeTrend_noDraw", 0, 0);
                     int bars = (int) iCustom(symbols[i], mql4TimeFrames[k], "FXEdgeTrend_noDraw", 1, 0);
                     string barStr;
                     if (bars == 1) barStr = "bar";
                     else barStr = "bars";
                     double price = iCustom(symbols[i], mql4TimeFrames[k], "FXEdgeTrend_noDraw", 2, 0);
                     body += timeFrames[k] + ": " + trendToString(tr) + " (" + IntegerToString(bars)  +" " + barStr + ")" + "\r\n";
                  }
                  
                  if (!IsTesting()) {
                     SendMail(subject, body);
                  } else 
                  {
                     Print ("Subject: ", subject);
                     Print ("Body:\r\n", body);
                  }
               } 
               if ((barsSinceTrendChange > 1) && (emailSent[i][j])) {
                  emailSent[i][j] = false; 
               }
               
            //}
            
         }
      } 
   }
}


bool bNewBar() {                                                              
   static datetime iTime_0 = 0; 
   if (iTime_0 < iTime (NULL , 0 , 0)) {
      iTime_0 = iTime ( NULL , 0 , 0 );
      return (TRUE);
   } else   {
      return (FALSE);
   } 
}   

string periodToString(int period) {
   switch (period) {
      case PERIOD_M1: return "M1";
      case PERIOD_M5: return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1: return "H1";
      case PERIOD_H4: return "H4";
      case PERIOD_D1: return "D1";
      case PERIOD_W1: return "W1";
      case PERIOD_MN1: return "M1";
      default: return "UNKNOWN";
   }
}