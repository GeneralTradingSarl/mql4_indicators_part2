//+------------------------------------------------------------------+
//|                                                          PPO.mq4 |
//|                                                Grigori Minassian |
//+------------------------------------------------------------------+
#property copyright "Grigori Minassian"


#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Silver
#property  indicator_color2  Red
#property  indicator_color3  Green
#property  indicator_width1  3
#property  indicator_width3  1


extern int FastEMA = 12;
extern int SlowEMA = 26;
extern int SignalSMA=9;

double     Buffer[];
double     SignalBuffer[];
double     SignalHistogram[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {

   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(0,SignalHistogram);
   SetIndexBuffer(1,SignalBuffer);
   SetIndexBuffer(2,Buffer);

   IndicatorDigits(Digits+1);

   IndicatorShortName("PPO("+(string)FastEMA+", "+(string)SlowEMA+", "+(string)SignalSMA+")");
   SetIndexLabel(0,"HISTOGRAM");
   SetIndexLabel(1,"SIGNAL");
   SetIndexLabel(2,"MAIN");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int i,limit;
   int counted_bars=IndicatorCounted();

   
   limit=Bars-counted_bars;
   if(counted_bars==0)  limit-=SlowEMA;
   Print("counted_bars = ",counted_bars," limit = ",limit,"Bars=",Bars);
   for(i=0; i<limit; i++)
     {
      Buffer[i]=OsPPO(i)/Point;
     }
   if(counted_bars==0)  limit-=(SignalSMA-1);
   for(i=0; i<limit; i++)
     {
      SignalBuffer[i]=OsPPO_Signal(i)/Point;
      SignalHistogram[i]=Buffer[i]-SignalBuffer[i];
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OsPPO(int shift)
  {
   double fast_ema = iMA(NULL, 0, FastEMA, 0, MODE_EMA, PRICE_CLOSE, shift);
   double slow_ema = iMA(NULL, 0, SlowEMA, 0, MODE_EMA, PRICE_CLOSE, shift);
   if(shift>Bars-20)
     {
      Print("shift = ",shift," fast_ema = ",fast_ema," slow_ema = ",slow_ema);
     }

   double result=((fast_ema-slow_ema)/slow_ema);

   return(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OsPPO_Signal(int shift)
  {
   double result=0;

   for(int i = 0; i<SignalSMA; i++)
      result+= OsPPO(shift + i);

   return(result/SignalSMA);
  }
//+------------------------------------------------------------------+
