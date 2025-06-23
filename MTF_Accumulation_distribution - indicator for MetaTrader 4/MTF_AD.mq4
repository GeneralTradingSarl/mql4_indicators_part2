//+------------------------------------------------------------------+
//|                                MTF_Accumulation/distribution.mq4 |
//|          MTF_AD                        http://www.metaquotes.net |
//|                                                www.forex-tsd.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © www.metaquotes.net"
#property link      "http://www.forex-tsd.com"
//----
#property indicator_separate_window
#property indicator_color1 SlateBlue
//---- input parameters
/*************************************************************************
PERIOD_M1   1
PERIOD_M5   5
PERIOD_M15  15
PERIOD_M30  30 
PERIOD_H1   60
PERIOD_H4   240
PERIOD_D1   1440
PERIOD_W1   10080
PERIOD_MN1  43200
You must use the numeric value of the timeframe that you want to use
when you set the TimeFrame' value with the indicator inputs.
---------------------------------------
MODE_SMA    0 Simple moving average, 
MODE_EMA    1 Exponential moving average, 
MODE_SMMA   2 Smoothed moving average, 
MODE_LWMA   3 Linear weighted moving average. 
You must use the numeric value of the MA Method that you want to use
when you set the 'ma_method' value with the indicator inputs.
**************************************************************************/
extern int TimeFrame=0;
//----
double ExtMapBuffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexLabel(0,"MTF_AD TF"+TimeFrame+"");
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
   IndicatorShortName("MTF_AD (TF "+TimeFrame+"");
   return(0);
  }
//----
//+------------------------------------------------------------------+
//| MTF                                                              |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,shift,y=0;
   // Plot defined timeframe on to current timeframe   
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
//----
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+TimeFrame/Period();
   
   //limit=Bars-counted_bars+TimeFrame/Period();
   for(i=0,y=0;i<limit;i++)
     {
      if (Time[i]<TimeArray[y]) y++;
 /***********************************************************   
   Add your main indicator loop below.  You can reference an existing
   indicator with its iName  or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator timeframe
   Rule 3:  Use 'y' for the indicator's shift value
 **********************************************************/
      ExtMapBuffer1[i]=iAD(NULL,TimeFrame, y);
     }
   //----
   return(0);
  }
//+------------------------------------------------------------------+