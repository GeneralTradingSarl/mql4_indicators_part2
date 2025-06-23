//+------------------------------------------------------------------+
//|                                                       OsMACD.mq4 |
//|                                            Copyright © 2007, SOK |
//|                                         http://SOK.LiteForex.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, SOK"
#property link      "http://sok.liteforex.net"
//----
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Blue
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 Red
//---- input parameters
extern int FastEMA = 12;
extern int SlowEMA = 26;
extern int SignalSMA = 9;
extern int AplyingPrice = 0;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, 159);
   SetIndexBuffer(2, ExtMapBuffer3);
   SetIndexStyle(3, DRAW_HISTOGRAM);
   SetIndexBuffer(3, ExtMapBuffer4);
   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(4, ExtMapBuffer5);
   SetIndexStyle(5, DRAW_ARROW);
   SetIndexArrow(5, 159);
   SetIndexBuffer(5, ExtMapBuffer6);
   SetIndexEmptyValue(0, 0);
   SetIndexEmptyValue(1, 0);
   SetIndexEmptyValue(2, 0);
   SetIndexEmptyValue(3, 0);
   SetIndexEmptyValue(4, 0);
   SetIndexEmptyValue(5, 0);
//----
   IndicatorShortName("OsMACD(" + FastEMA + ", " + SlowEMA + ", " + 
                      SignalSMA + ")"); 
   SetIndexLabel(0, "MACD");
   SetIndexLabel(1, "Signal");
   SetIndexLabel(2, "OsMA");
   SetIndexLabel(3, "MACD");
   SetIndexLabel(4, "Signal");
   SetIndexLabel(5, "OsMA");
//----
   SetIndexDrawBegin(0, MathMax(FastEMA, MathMax(SlowEMA, SignalSMA))); 
   SetIndexDrawBegin(1, MathMax(FastEMA, MathMax(SlowEMA, SignalSMA))); 
   SetIndexDrawBegin(2, MathMax(FastEMA, MathMax(SlowEMA, SignalSMA))); 
   SetIndexDrawBegin(3, MathMax(FastEMA, MathMax(SlowEMA, SignalSMA))); 
   SetIndexDrawBegin(4, MathMax(FastEMA, MathMax(SlowEMA, SignalSMA))); 
   SetIndexDrawBegin(5, MathMax(FastEMA, MathMax(SlowEMA, SignalSMA))); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
//----
   int limit;
//---- последний посчитанный бар будет пересчитан
   if(counted_bars > 0) 
       counted_bars--;
   else
     {
       ArrayInitialize(ExtMapBuffer1, 0); 
       ArrayInitialize(ExtMapBuffer2, 0); 
       ArrayInitialize(ExtMapBuffer3, 0); 
       ArrayInitialize(ExtMapBuffer4, 0); 
       ArrayInitialize(ExtMapBuffer5, 0); 
       ArrayInitialize(ExtMapBuffer6, 0); 
     }
   limit = Bars - counted_bars;
   if(counted_bars==0) limit--;
//---- основной цикл
   for(int i = limit; i >= 0; i--)
     {
       ExtMapBuffer1[i] = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, 
                                AplyingPrice, MODE_MAIN, i);
       if(iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, AplyingPrice, 
          MODE_MAIN, i + 1) > ExtMapBuffer1[i])
            ExtMapBuffer4[i] = ExtMapBuffer1[i];
       ExtMapBuffer2[i] = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, 
                                AplyingPrice, MODE_SIGNAL, i);
       if(iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, AplyingPrice, 
          MODE_SIGNAL, i + 1) > ExtMapBuffer2[i])
            ExtMapBuffer5[i] = ExtMapBuffer2[i];
       ExtMapBuffer3[i] = iOsMA(NULL, 0, FastEMA, SlowEMA, SignalSMA, 
                                AplyingPrice, i);
       if(iOsMA(NULL, 0, FastEMA, SlowEMA, SignalSMA, AplyingPrice, 
          i + 1) > ExtMapBuffer3[i])
           ExtMapBuffer6[i]=ExtMapBuffer3[i];
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+