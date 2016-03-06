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
#property indicator_buffers 3
//Uptrend
#property indicator_color1  clrGreen
#property indicator_width1  2

//Sideways
#property indicator_color2  clrOrange
#property indicator_width2  2

//Downtrend
#property indicator_color3  clrRed
#property indicator_width3  2

double histoBufferUp[];
double histoBufferSide[];
double histoBufferDown[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(3);
   SetIndexBuffer(0,histoBufferUp,INDICATOR_DATA);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   ArraySetAsSeries(histoBufferUp,true); 
   
   SetIndexBuffer(1,histoBufferSide,INDICATOR_DATA);
   SetIndexStyle(1,DRAW_HISTOGRAM); 
   ArraySetAsSeries(histoBufferSide, true);
   
   SetIndexBuffer(2,histoBufferDown,INDICATOR_DATA); 
   ArraySetAsSeries(histoBufferDown, true);
   SetIndexStyle(2,DRAW_HISTOGRAM);

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
   if (prev_calculated == 0) {
         for (int i = 0; i<rates_total; ++i) {
            double trend = iCustom(NULL, 0, "FXEdgeTrend_noDraw2", 0, i);
            double barsSinceTrendChange = iCustom(NULL, 0, "FXEdgeTrend_noDraw2", 1, i);
            
            if (trend == -1.0) {
               histoBufferDown[i] = open[i];
               //Print ("Bars since trend change: ", DoubleToString(barsSinceTrendChange, 0));
               continue; 
            }
            
            if (trend == 1.0) {
               histoBufferUp[i] = open[i]; 
               //Print ("Bars since trend change: ", DoubleToString(barsSinceTrendChange, 0));
               continue;
            }
            
            histoBufferSide[i] = open[i]; 
            //Print ("Bars since trend change: ", DoubleToString(barsSinceTrendChange, 0));
         } 
         return rates_total;
   }
   
   if (prev_calculated == rates_total) {
      return rates_total;
   }
   
   if (prev_calculated != rates_total) {
      double trend = iCustom(NULL, 0, "FXEdgeTrend_noDraw2", 0, 0);
      double barsSinceTrendChange = iCustom(NULL, 0, "FXEdgeTrend_noDraw2", 1, 0);
      double priceSinceTrendChange = iCustom(NULL, 0, "FXEdgeTrend_noDraw2", 2, 0);
      if (trend == -1.0) {
          histoBufferDown[0] = open[0];
          Print ("Bars since trend change: ", DoubleToString(barsSinceTrendChange, 0));
          Print ("Price at trend change: ", DoubleToString(priceSinceTrendChange, Digits));
          return rates_total;
      }
            
      if (trend == 1.0) {
          histoBufferUp[0] = open[0]; 
          Print ("Bars since trend change: ", DoubleToString(barsSinceTrendChange, 0));
          Print ("Price at trend change: ", DoubleToString(priceSinceTrendChange, Digits));
          return rates_total;
      }
            
      histoBufferSide[0] = open[0]; 
      Print ("Bars since trend change: ", DoubleToString(barsSinceTrendChange, 0));
      Print ("Price at trend change: ", DoubleToString(priceSinceTrendChange, Digits));
      return rates_total;
   }
   return rates_total;
  }
//+------------------------------------------------------------------+
