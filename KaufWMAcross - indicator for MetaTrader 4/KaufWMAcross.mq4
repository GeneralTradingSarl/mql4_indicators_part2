//+------------------------------------------------------------------+
//|                                                 KaufWMAcross.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link "http://www.metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters
extern int KaufPeriod=9;
extern int WMAPeriod=5;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//----
double kf0,kf1,wma0,wma1;
int    nShift;
datetime Newbar;
bool Alerts_on= true;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW, 0, 1);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, ExtMapBuffer1);
//----
   SetIndexStyle(1, DRAW_ARROW, 0, 1);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, ExtMapBuffer2);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("KaufWMAcrosses("+KaufPeriod+","+WMAPeriod);
   SetIndexLabel(0, "CrossUp");
   SetIndexLabel(1, "CrossDn");
//----
   switch(Period())
     {
      case     1: nShift=1;   break;
      case     5: nShift=3;   break;
      case    15: nShift=5;   break;
      case    30: nShift=10;  break;
      case    60: nShift=15;  break;
      case   240: nShift=20;  break;
      case  1440: nShift=80;  break;
      case 10080: nShift=100; break;
      case 43200: nShift=200; break;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
   int limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars < 0)
      return(-1);
//---- last counted bar will be recounted
   if(counted_bars > 0)
      counted_bars--;
   limit=Bars - counted_bars;
//----
   for(int i=0; i < limit; i++)
     {
      kf1=iCustom(NULL, 0,"Kaufman",KaufPeriod,2,30,2, 0, i + 1);
      kf0=iCustom(NULL, 0,"Kaufman",KaufPeriod,2,30,2, 0, i);
      wma1=iMA(NULL, 0, WMAPeriod, 0,MODE_LWMA,PRICE_CLOSE, i + 1);
      wma0=iMA(NULL, 0, WMAPeriod, 0,MODE_LWMA,PRICE_CLOSE, i );
      //----
      if(kf1 > wma1 && kf0 < wma0)
        { ExtMapBuffer1[i]=Low[i] - nShift*Point;
         if(Alerts_on && Newbar!=Time[0])
           Alert("WMA crossed KaufamnMA to the Upside in the "+Period()+" minute "+Symbol()+" chart");}
      //----
      if(kf1 < wma1 && kf0 > wma0)
        {ExtMapBuffer2[i]=High[i] + nShift*Point;
         if(Alerts_on && Newbar!=Time[0])
           Alert("WMA crossed KaufamnMA to the Downside in the "+Period()+" minute "+Symbol()+" chart");}
      Newbar=Time[0];
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+

