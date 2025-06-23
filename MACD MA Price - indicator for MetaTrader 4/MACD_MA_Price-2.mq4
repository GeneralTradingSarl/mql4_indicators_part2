//+------------------------------------------------------------------+
//|                                              MACD MA Price-2.mq4 |
//|                                                        Paladin80 |
//|                                                  forevex@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Paladin80"
#property link      "forevex@mail.ru"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Silver
#property  indicator_color2  Red
#property  indicator_width1  2
//---- indicator parameters
extern int Fast_period=12;
extern int Slow_period=26;
extern int Signal_period=9;
//----
extern int MACD_MA_method_1=1;
extern int MACD_MA_method_2=1;
extern int Signal_MA_method=0;
extern int Applied_price=0;
bool       error=false;
/* MACD_MA_method_1, MACD_MA_method_2 and Signal_MA_method: 
              0 - Simple moving average,
              1 - Exponential moving average,
              2 - Smoothed moving average,
              3 - Linear weighted moving average.
Applied_price: 0 - Close price,
               1 - Open price,
               2 - High price,
               3 - Low price,
               4 - Median price,
               5 - Typical price,
               6 - Weighted close price, */
//---- indicator buffers
double     MacdBuffer[];
double     SignalBuffer[]; 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(1,Signal_period);
   IndicatorDigits(Digits+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,MacdBuffer);
   SetIndexBuffer(1,SignalBuffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD("+Fast_period+","+Slow_period+","+Signal_period+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
//---- initialization done
   if (MACD_MA_method_1<0 || MACD_MA_method_1>3)
   {  error=true;
      Alert("Please select correct MACD_MA_method_1 (0-3) for indicator MACD MA Price-2");
   }
   if (MACD_MA_method_2<0 || MACD_MA_method_2>3)
   {  error=true;
      Alert("Please select correct MACD_MA_method_2 (0-3) for indicator MACD MA Price-2");
   }
   if (Signal_MA_method<0 || Signal_MA_method>3)
   {  error=true;
      Alert("Please select correct Signal_MA_method (0-3) for indicator MACD MA Price-2");
   }
   if (Applied_price<0 || Applied_price>6)
   {  error=true;
      Alert("Please select correct Applied_price (0-6) for indicator MACD MA Price-2");
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
//----
   if (error==true) return(0);
//----
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd counted in the 1-st buffer
   for(int i=0; i<limit; i++)
      MacdBuffer[i]=iMA(NULL,0,Fast_period,0,MACD_MA_method_1,Applied_price,i)-iMA(NULL,0,Slow_period,0,MACD_MA_method_2,Applied_price,i);
//---- signal line counted in the 2-nd buffer
   for(i=0; i<limit; i++)
      SignalBuffer[i]=iMAOnArray(MacdBuffer,Bars,Signal_period,0,Signal_MA_method,i);
//---- done
   return(0);
  }
//+------------------------------------------------------------------+