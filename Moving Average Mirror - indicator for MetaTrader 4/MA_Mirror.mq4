
//+------------------------------------------------------------------+
//|                                                    MA_Mirror.mq4 |
//|                                   Copyright © 2010, Andy Tjatur. |
//|                                            andy.tjatur@gmail.com |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2010, Andy Tjatur."
#property  link      "andy.tjatur@gmail.com"
//---- indicator settings
#property  indicator_separate_window
#property indicator_level1 1
#property indicator_levelcolor White
#property  indicator_buffers 2
#property  indicator_color1  Red
#property  indicator_color2  Blue
#property  indicator_width1 2
#property  indicator_width2 2

extern double MovingPeriod       = 20;
extern double MovingShift        = 0;
double     MacdBuffer1[];
double     MacdBuffer2[];
double     ma1,ma2;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);

   
   IndicatorDigits(Digits+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,MacdBuffer1);
   SetIndexBuffer(1,MacdBuffer2);
 
   

   IndicatorShortName("MA_Mirror by Andy Tjatur");
   SetIndexLabel(0,"MA_CO");
   SetIndexLabel(1,"MA_OC");
 
   

   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Mirror                                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();

   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

  
   for(int i=0; i<limit; i++)
      MacdBuffer1[i]=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,i)-iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_OPEN,i);
    
   for(i=0; i<limit; i++)
      MacdBuffer2[i]=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_OPEN,i)-iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,i);
    


   return(0);
  }
//+------------------------------------------------------------------+