//+------------------------------------------------------------------+
//|                      MTF_MA_Channel810_Env; mod. Envelopes.mq4 ik|
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                    www.forex-tsd.com;  http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net    www.forex-tsd.com"
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
//----
#property indicator_color1 RoyalBlue
#property indicator_color2 Maroon
#property indicator_width1 2
#property indicator_width2 2
//---- indicator parameters
extern int TimeFrame=0;
extern int MA_Hi_Period=10;
extern int MA_Hi_Method=0;
extern int MA_Hi_Price=2;
extern int MA_Lo_Period=8;
extern int MA_Lo_Method=0;
extern int MA_Lo_Price=3;
//extern int Channel_Shift=0;
extern int MA_Hi_Shift=0;
extern int MA_Lo_Shift=0;
extern double Deviation=0.0;
/*************************************************************************
PRICE_CLOSE    0 Close price. 
PRICE_OPEN     1 Open price. 
PRICE_HIGH     2 High price. 
PRICE_LOW      3 Low price. 
PRICE_MEDIAN   4 Median price, (high+low)/2. 
PRICE_TYPICAL  5 Typical price, (high+low+close)/3. 
PRICE_WEIGHTED 6 Weighted close price, (high+low+close+close)/4. 
You must use the numeric value of the Applied Price that you want to use
when you set the 'applied_price' value with the indicator inputs.
---------------------------------------
MODE_SMA    0 Simple moving average, 
MODE_EMA    1 Exponential moving average, 
MODE_SMMA   2 Smoothed moving average, 
MODE_LWMA   3 Linear weighted moving average. 
You must use the numeric value of the MA Method that you want to use
when you set the 'ma_method' value with the indicator inputs.
**************************************************************************/
//---- indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   int    draw_begin;
   string short_name;
//---- drawing settings
   if(TimeFrame==0) TimeFrame=Period();
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexShift(0,MA_Hi_Shift*TimeFrame/Period());
   SetIndexShift(1,MA_Lo_Shift*TimeFrame/Period());
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   if(MA_Hi_Period<2) MA_Hi_Period=10;
   if(MA_Lo_Period<2) MA_Lo_Period=8;
   draw_begin=MA_Hi_Period-1;
   draw_begin=MA_Lo_Period-1;
//---- indicator short name
   IndicatorShortName("MA_Channel("+MA_Hi_Period+","+MA_Lo_Period+" )");
   SetIndexLabel(0,"MA_C_Hi("+MA_Hi_Period+")tf"+TimeFrame+"");
   SetIndexLabel(1,"MA_C_Lo("+MA_Lo_Period+")tf"+TimeFrame+"");
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   if(Deviation<0) Deviation=0;
   if(Deviation>100.0) Deviation=100.0;
//---- name for DataWindow and indicator subwindow label   
   switch(TimeFrame)
     {
      case 1 : string TimeFrameStr="Period_M1"; break;
      case 5 : TimeFrameStr="Period_M5"; break;
      case 15 : TimeFrameStr="Period_M15"; break;
      case 30 : TimeFrameStr="Period_M30"; break;
      case 60 : TimeFrameStr="Period_H1"; break;
      case 240 : TimeFrameStr="Period_H4"; break;
      case 1440 : TimeFrameStr="Period_D1"; break;
      case 10080 : TimeFrameStr="Period_W1"; break;
      case 43200 : TimeFrameStr="Period_MN1"; break;
      default : TimeFrameStr="Current Timeframe";
     }
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| MTF                                                              |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,limit,y=0;
// Plot defined time frame on to current time frame
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
//----   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit--;

   for(i=0,y=0;i<limit;i++)
     {
      if(y<ArraySize(TimeArray)){  if(Time[i]<TimeArray[y]) y++;}
/***********************************************************   
   Add your main indicator loop below.  You can reference an existing
   indicator with its iName  or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator time frame
   Rule 3:  Use 'y' for your indicator's shift value
**********************************************************/
      //---- EnvelopesM counted in the buffers
      ExtMapBuffer1[i]=(1+Deviation/100)*iMA(NULL,TimeFrame,MA_Hi_Period,0,MA_Hi_Method,MA_Hi_Price,y);
      ExtMapBuffer2[i]=(1-Deviation/100)*iMA(NULL,TimeFrame,MA_Lo_Period,0,MA_Lo_Method,MA_Lo_Price,y);
     }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
