//+------------------------------------------------------------------+
//|                                       #MTF_Heiken_Ashi.mq4       |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 IndianRed
#property indicator_color2 MediumSeaGreen
#property indicator_color3 IndianRed
#property indicator_color4 MediumSeaGreen
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
**************************************************************************/
extern int TimeFrame=0;
extern int Shift=0;
//----
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   SetIndexStyle(0,DRAW_SECTION, 0, 1, IndianRed);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexShift(0, Shift);
   SetIndexStyle(1,DRAW_SECTION, 0, 1, MediumSeaGreen);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexShift(1, Shift);
   SetIndexStyle(2,DRAW_SECTION, 0, 3, IndianRed);
   SetIndexBuffer(2, ExtMapBuffer3);
   SetIndexShift(2, Shift);
   SetIndexStyle(3,DRAW_SECTION, 0, 3, MediumSeaGreen);
   SetIndexBuffer(3, ExtMapBuffer4);
   SetIndexShift(3, Shift);
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
   IndicatorShortName("MTF_Heikin_Ashi ("+TimeFrameStr+")");
  return(0);
  }
//----
   
//+------------------------------------------------------------------+
//| MTF Parabolic Sar                                                |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,limit,y=0,counted_bars=IndicatorCounted();
   // Plot defined time frame on to current time frame
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
//----
   limit=Bars-counted_bars;
   for(i=0,y=0;i<limit;i++)
     {
      if (Time[i]<TimeArray[y]) y++;
/***********************************************************   
   Add your main indicator loop below.  You can add the full
      indicator code or you can just reference an existing
      indicator with its iValue or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator time frame
   Rule 3:  Use 'y' for your indicator's shift value
 **********************************************************/
      ExtMapBuffer1[i]=iCustom(NULL,TimeFrame,"Heiken Ashi",0,y);
      ExtMapBuffer2[i]=iCustom(NULL,TimeFrame,"Heiken Ashi",1,y);
      ExtMapBuffer3[i]=iCustom(NULL,TimeFrame,"Heiken Ashi",2,y);
      ExtMapBuffer4[i]=iCustom(NULL,TimeFrame,"Heiken Ashi",3,y);
     }
   //----
   return(0);
  }
//+------------------------------------------------------------------+