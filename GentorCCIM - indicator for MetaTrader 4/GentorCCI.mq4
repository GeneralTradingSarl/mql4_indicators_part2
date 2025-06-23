//+------------------------------------------------------------------+
//|                                                   GentorCCIM .mq4|
//|                                                   Egorov Gennadiy|  
//+------------------------------------------------------------------+
#property copyright "Egorov Gennadiy"
#property link      ""
#property indicator_separate_window
#property indicator_buffers 5
//----
#property indicator_color1 Red
#property indicator_color2 Black
#property indicator_color3 Lime
#property indicator_color4 Yellow
#property indicator_color5 Green
//---
#property indicator_level1 300
#property indicator_level2 200
#property indicator_level3 100
#property indicator_level4 50
#property indicator_level5 -50
#property indicator_level6 -100
#property indicator_level7 -200
#property indicator_level8 -300
//---- input parameters
extern int       A_period=14;
extern int       B_period=6;
extern int       EMA=34;
extern int       num_bars=300;
// parameters
int shift=0;
//---- buffers
double FastWoodieCCI[];
double SlowWoodieCCI[];
double HistoWoodieCCI[];
double LineHighEMA[];
double LineLowEMA[];
//---- indicator buffers
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorDigits(2);
//---- indicators
   SetIndexStyle(0,DRAW_LINE,0,1);
   SetIndexBuffer(0,FastWoodieCCI);
   SetIndexStyle(1,DRAW_LINE,0,2);
   SetIndexBuffer(1,SlowWoodieCCI);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,1);
   SetIndexBuffer(2,HistoWoodieCCI);
   SetIndexStyle(3,DRAW_LINE,1,3);
   SetIndexBuffer(3,LineHighEMA);
   SetIndexStyle(4,DRAW_LINE,1,3);
   SetIndexBuffer(4,LineLowEMA);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int   i;
   int   counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0)
      return(-1);
//---- last counted bar will be recounted
   if(counted_bars > 0)
      counted_bars--;
//----
   counted_bars=Bars - counted_bars;
//----
   for(shift=0; shift < counted_bars; shift++)
     {
      //
      FastWoodieCCI[shift]=iCCI(NULL,0,B_period,PRICE_TYPICAL,shift);
      SlowWoodieCCI[shift]=iCCI(NULL,0,A_period,PRICE_TYPICAL,shift);
      HistoWoodieCCI[shift]=iCCI(NULL,0,A_period,PRICE_TYPICAL,shift);
      //----------------color coding---------------------------
      LineLowEMA[shift]=0;
      LineHighEMA[shift]=0;
//----
      double EmaValue=iMA( NULL, 0, EMA, 0, MODE_EMA, PRICE_TYPICAL, shift );
      if(Close[shift] > EmaValue )
         LineHighEMA[shift]=EMPTY_VALUE;
      else
         if (Close[shift] < EmaValue )
            LineLowEMA[shift]=EMPTY_VALUE;
     }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+