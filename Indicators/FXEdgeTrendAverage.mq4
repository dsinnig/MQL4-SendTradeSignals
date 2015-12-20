//+------------------------------------------------------------------+
//|                                                  FXEdgeTrend.mq4 |
//|                                                    Daniel Sinnig |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Daniel Sinnig"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
//AverageLine
#property indicator_color1  clrBlue
#property indicator_width1  2
//#property indicator_minimum -1.2
//#property indicator_maximum  1.2

input int period=20;   // Number of bars overwhich the trend average is calculated

double histoBufferAve[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(1);
   SetIndexBuffer(0,histoBufferAve,INDICATOR_DATA);
   SetIndexStyle(0,DRAW_LINE);
   ArraySetAsSeries(histoBufferAve,true); 

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int pos;
   if (prev_calculated > 1)
      pos = prev_calculated -1;
   else 
      pos = 0;

   for (int i = 0; i<rates_total-period; ++i) {
      double trendSum = 0;
      for (int  j = i; j < i+period; ++j) {
         trendSum += iCustom(NULL, 0, "FXEdgeTrend_noDraw_3", 0, j);
      }
      double trendAverage = trendSum / period;
      histoBufferAve[i] = trendAverage;
      //histoBufferAve[i] = trendSum;
   }
   return rates_total;
   
   /*
   if (prev_calculated == 0) {
      for (int i = 0; i<rates_total-period; ++i) {
         double trendSum = 0;
         for (int  j = i; j < i+period; ++j) {
               //trendSum += iCustom(NULL, 0, "FXEdgeTrend_noDraw", 0, j);
               trendSum++;
         }
         double trendAverage = trendSum / period;
         histoBufferAve[i] = trendAverage;
      }
      return rates_total;
   }
   
   if (prev_calculated == rates_total) {
      return rates_total;
   }
   
   if (prev_calculated != rates_total) {
      double trendSum = 0;
      for (int  i=0; i < period; ++i) {
         //trendSum += iCustom(NULL, 0, "FXEdgeTrend_noDraw", 0, i);
         trendSum++;
      }
      double trendAverage = trendSum / period;
      histoBufferAve[0] = trendAverage;
      return rates_total;
   }
   return rates_total;
   */
  }
//+------------------------------------------------------------------+
