//+------------------------------------------------------------------+
//|                                                 MTF_atrstops.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
//----
extern int TimeFrame=0;
extern int    Length=10;
extern int    ATRperiod=5;
extern double Kv=2.5;
//----
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double smin[];
double smax[];
double trend[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   IndicatorBuffers(5);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,smin);
   SetIndexBuffer(3,smax);
   SetIndexBuffer(4,trend);
//---- name for DataWindow and indicator subwindow label
   short_name="ATRStops("+(string)Length+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Up");
   SetIndexLabel(1,"Dn");
//----
   SetIndexDrawBegin(0,Length);
   SetIndexDrawBegin(1,Length);
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
   IndicatorShortName("MTF_atrstops("+(string)Length+","+(string)ATRperiod+","+(string)Kv+")("+TimeFrameStr+")");
  return(0);
  }
//----
   
//+------------------------------------------------------------------+
//| MTF MACD                                                         |
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
   Add your main indicator loop below.  You can reference an existing
   indicator with its iName  or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator time frame
   Rule 3:  Use 'y' for your indicator's shift value
**********************************************************/
      ExtMapBuffer1[i]=iCustom(NULL,TimeFrame,"ATRStops_v1[1].1",Length,ATRperiod,Kv,0,y);
      ExtMapBuffer2[i]=iCustom(NULL,TimeFrame,"ATRStops_v1[1].1",Length,ATRperiod,Kv,0,y);
     }
   //----
   return(0);
  }
//+--------------------------------------------------