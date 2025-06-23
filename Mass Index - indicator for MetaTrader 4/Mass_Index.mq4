//+------------------------------------------------------------------+
//|                                                   Mass Index.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//----
#property  indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_level1 27
#property indicator_level2 26.5
#property indicator_levelcolor Blue
//---- input parameters
extern int  EMAPeriod = 9;
extern int  SecondPeriod = 9;
extern int  SumPeriod = 25;
//---- buffers
double MI[];
double HL[];
double HLaverage[];
double EMA2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   string name;
   name = "Mass Index(" + EMAPeriod + "," + SecondPeriod + "," + SumPeriod + ")";
   IndicatorBuffers(4);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, MI);
   SetIndexLabel(0, name);
   SetIndexEmptyValue(0, 0.0);
   SetIndexBuffer(1, HL);
   SetIndexEmptyValue(1, 0.0);
   SetIndexBuffer(2, HLaverage);
   SetIndexEmptyValue(2, 0.0);
   SetIndexBuffer(3, EMA2);
   SetIndexEmptyValue(3, 0.0);
   IndicatorShortName(name);
   IndicatorDigits(2);   
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
   int limit,i;
//----
   if(counted_bars < 0) 
      return(-1);
   if(counted_bars == 0) 
     {
       limit = Bars - 1;
       for(i = limit; i >= 0; i--)
           HL[i] = High[i] - Low[i];
       for(i = limit - EMAPeriod; i >= 0; i--)
           HLaverage[i]=iMAOnArray(HL,0,EMAPeriod,0,MODE_EMA,i);
       for(i = limit - EMAPeriod - SecondPeriod; i >= 0; i--)
           EMA2[i] = HLaverage[i] / iMAOnArray(HLaverage, 0, SecondPeriod, 0, MODE_EMA, i);
       for(i = limit - EMAPeriod - SecondPeriod - SumPeriod; i >= 0; i--)
           MI[i] = iMAOnArray(EMA2, 0, SumPeriod, 0, MODE_SMA, i)*SumPeriod;
     }
   if(counted_bars > 0) 
     {
       limit = Bars - counted_bars;
       for(i = limit; i >= 0; i--)
           HL[i] = High[i] -Low[i];
       for(i = limit; i >= 0; i--)
           HLaverage[i] = iMAOnArray(HL, 0, EMAPeriod, 0, MODE_EMA, i);
       for(i = limit; i >= 0; i--)
           EMA2[i] = HLaverage[i] / iMAOnArray(HLaverage, 0, SecondPeriod, 0, MODE_EMA, i);
       for(i = limit; i >= 0; i--)
           MI[i] = iMAOnArray(EMA2, 0, SumPeriod, 0, MODE_SMA, i)*SumPeriod;
     }            
//----
   return(0);
  }
//+------------------------------------------------------------------+