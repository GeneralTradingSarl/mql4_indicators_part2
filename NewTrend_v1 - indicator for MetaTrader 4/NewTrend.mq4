//+------------------------------------------------------------------+
//|                                                  NewTrend_v1.mq4 |
//|                           Copyright © 2006, TrendLaboratory Ltd. |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                       E-mail: igorad2004@list.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, TrendLaboratory Ltd."
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
#property  indicator_buffers 2
//---- indicator settings
#property  indicator_separate_window
#property  indicator_level1 0.5
#property  indicator_level2 -0.5
//----
#property  indicator_color1  Silver
#property  indicator_color2  Orange
//---- indicator parameters
extern int Smooth=9;
extern int Signal=9;
//---- indicator buffers
double     Main_buffer[];
double     Sign_buffer[];
double     Fast_buffer[];
double     Slow_buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   IndicatorBuffers(4);
   SetIndexBuffer(0,Main_buffer);
   SetIndexBuffer(1,Sign_buffer);
   SetIndexBuffer(2,Fast_buffer);
   SetIndexBuffer(3,Slow_buffer);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(0,1);
   SetIndexDrawBegin(1,1);
   // IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- indicator buffers mapping
   // if(!SetIndexBuffer(0,Macd_buffer) && !SetIndexBuffer(1,Sign_buffer))
   // Print("cannot set indicator buffers!");
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("NewTrend("+Smooth+")");
   SetIndexLabel(0,"Trend");
   SetIndexLabel(1,"Signal");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|  MACD (DEMA) DiNapoli                                            |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+1;
   int i;   
//---- macd counted in the 1-st buffer      
   for(i=limit-1; i>=0; i--)
     {
      if (Close[i+1]>0)
        {
         double vA=(Close[i] - Open[i])/Open[i]/Point;
         double vB=(Open[i] - Close[i+1])/Close[i+1]/Point;
         //
         Fast_buffer[i]=Fast_buffer[i+1]+2.0/(1.0+Smooth)*(vA-Fast_buffer[i+1]);
         Slow_buffer[i]=Slow_buffer[i+1]+2.0/(1.0+Smooth)*(vB-Slow_buffer[i+1]);
         Main_buffer[i]=Fast_buffer[i]-Slow_buffer[i];
        }
     }
//---- signal line counted in the 2-nd buffer
   for(i=limit-1; i>=0; i--)
      Sign_buffer[i]=Sign_buffer[i+1]+2.0/(1.0+Signal)*(Main_buffer[i]-Sign_buffer[i+1]);
//---- done
   return(0);
  }
//+------------------------------------------------------------------+