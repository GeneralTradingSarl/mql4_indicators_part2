//+------------------------------------------------------------------+
//|                                                                  |
//|                 PIPQind.mq4                                      |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "emsjoflo"
#property link      "automaticforec.invisionzone.com"
//----
#property indicator_chart_window
#include <stdlib.mqh>
#property indicator_buffers 5
#property indicator_color1 Lime
#property indicator_width1 2
#property indicator_color2 Red
#property indicator_width2 2
#property indicator_color3 DodgerBlue
#property indicator_color4 Tomato
#property indicator_color5 Black
//----
extern double nPips=65;
extern bool SendAlert=false ;
extern bool SendEmail=false;
extern int AlertMinutesB4Close =5;
extern int AlertEveryNMinutes =10;
extern double ATRmultiplier= 0.45; //  
//----
double stop,atr,atrstop;
double UpArrow[];
double DownArrow[];
double BlueBar[],RedBar[];
double TrStopDots[];
datetime alertsent;
string MinutesB4BarCloses;
int shift=0,i=0;
double cnt=0;
double TrStopLevel=0;
double PREV=0;
//void SetLoopCount(int loops)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, UpArrow);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, DownArrow);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(2,BlueBar);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(3,RedBar);
   SetIndexStyle(4, DRAW_LINE, STYLE_DOT,1,Black);
   SetIndexBuffer(4,TrStopDots);
   alertsent=CurTime();
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for(int shift=Bars-2;shift>=0 ;shift--)
     {
      if (ObjectFind(TimeToStr(Time[shift]))>-1) ObjectDelete(TimeToStr(Time[shift]));
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
//+------------------------------------------------------------------+
//| Local variables                                                  |
//+------------------------------------------------------------------+
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+2;
   
   for(shift=limit;shift>=0 ;shift--)
     {
      if((Close[shift]==PREV))
        {
         TrStopLevel=PREV;
        }
      else
        {
         if((Close[shift+1])<=PREV && (Close[shift]<PREV) )
           {
            TrStopLevel=MathMin(PREV,Close[shift]+nPips*Point);
           }
         else
           {
            if(((Close[shift+1])>=PREV) && (Close[shift]>PREV))
              {
               TrStopLevel=MathMax(PREV,Close[shift]-nPips*Point);
              }
            else
              {
               if((Close[shift]>PREV))
                 {
                  TrStopLevel=Close[shift]-nPips*Point;
                 }
               else TrStopLevel=Close[shift]+nPips*Point;
              }
           }
        }
      //Comment("TRStop = "+TrStopLevel);
      TrStopDots[shift]=TrStopLevel;
      if (UpArrow[shift]!=0 && UpArrow[shift]!=TrStopDots[shift]) UpArrow[shift]=0.0;
      if (DownArrow[shift]!=TrStopDots[shift]) DownArrow[shift]=0.0;
      if(Close[shift] > TrStopLevel &&  (Close[shift+1]<PREV || (Close[shift+1]<=TrStopDots[shift+1] && Close[shift+2]<TrStopDots[shift+2])) && PREV !=0)
        {
         atr=iATR(NULL,0,14,shift);
         stop=Low[Lowest(NULL,0,MODE_LOW,3,shift)];
         atrstop =NormalizeDouble(TrStopLevel-atr*ATRmultiplier,MarketInfo(Symbol(),MODE_DIGITS));
         if (atrstop > stop) stop=atrstop;
         if (ObjectFind(TimeToStr(Time[shift]))>-1) ObjectDelete(TimeToStr(Time[shift]));
         ObjectCreate(TimeToStr(Time[shift]),OBJ_TREND,0,Time[shift+2],stop,Time[shift],stop);
         ObjectSet(TimeToStr(Time[shift]),OBJPROP_RAY,0);
         ObjectSet(TimeToStr(Time[shift]),OBJPROP_COLOR,DodgerBlue);
         ObjectSet(TimeToStr(Time[shift]),OBJPROP_WIDTH,2);
         // Comment(stop);
         if ((Bid > TrStopDots[0]) &&  (Close[1]<=TrStopDots[1]) && ((CurTime()-Time[0])>=(Time[0]-Time[1]-AlertMinutesB4Close*60)) && (CurTime()-alertsent> AlertEveryNMinutes*60))
           {
            MinutesB4BarCloses=TimeToStr((Time[0]-Time[1])-(CurTime()-Time[0]),TIME_MINUTES);
            if(SendAlert) Alert("Look for Buying opportunity soon");
            if(SendEmail) SendMail("Possible Buy setup on "+Symbol(),"PIPQind anticpates a Buy signal on "+Symbol()+" in "+MinutesB4BarCloses+" minutes"+" at "+TimeToStr(CurTime())+" Bid: "+Bid+" Ask: "+Ask+" Close[0]:"+Close[0]+"Close[1]: "+Close[1]+" TrStopDots[1]: "+TrStopDots[1]+" PREV: "+PREV+" TrStopLevel: "+TrStopLevel+" TrStopDots[0]: "+TrStopDots[0]);
            alertsent=CurTime();
           }
         RedBar[shift]=Low[shift];
         BlueBar[shift]=High[shift];
         UpArrow[shift]=TrStopLevel;
        }
      if(Close[shift] < TrStopLevel &&  (Close[shift+1]>PREV || (Close[shift+1]>=TrStopDots[shift+1] && Close[shift+2]>=TrStopDots[shift+2])) && PREV !=0)
        {
         atr=iATR(NULL,0,14,shift);
         stop=High[Highest(NULL,0,MODE_HIGH,3,shift)];
         atrstop=NormalizeDouble(TrStopLevel+atr*ATRmultiplier,MarketInfo(Symbol(),MODE_DIGITS));
         if (atrstop < stop) stop =atrstop;
         if (ObjectFind(TimeToStr(Time[shift]))>-1) ObjectDelete(TimeToStr(Time[shift]));
         ObjectCreate(TimeToStr(Time[shift]),OBJ_TREND,0,Time[shift+2],stop,Time[shift],stop);
         ObjectSet(TimeToStr(Time[shift]),OBJPROP_RAY,0);
         ObjectSet(TimeToStr(Time[shift]),OBJPROP_COLOR,DodgerBlue);
         ObjectSet(TimeToStr(Time[shift]),OBJPROP_WIDTH,2);
         Comment(stop);
         if((Ask < TrStopDots[0]) &&  (Close[1]>=TrStopDots[1]) && ((CurTime()-Time[0])>=(Time[0]-Time[1]-AlertMinutesB4Close*60)) && (CurTime()-alertsent> AlertEveryNMinutes*60))
           {
            MinutesB4BarCloses=TimeToStr((Time[0]-Time[1])-(CurTime()-Time[0]),TIME_MINUTES);
            if (SendAlert)Alert("Look for Selling opportunity soon");
            if (SendEmail) SendMail("Possible Sell setup on "+Symbol(),"PIPQind anticipates a sell signal on "+Symbol()+" in "+MinutesB4BarCloses+" minutes "+" at " +TimeToStr(CurTime())+" Bid: "+Bid+" Ask: "+Ask+" Close[0]:"+Close[0]+"Close[1]: "+Close[1]+" TrStopDots[1]: "+TrStopDots[1]+" PREV: "+PREV+" TrStopLevel: "+TrStopLevel+" TrStopDots[0]: "+TrStopDots[0]);
            alertsent=CurTime();
           }
         BlueBar[shift]=Low[shift];
         RedBar[shift]=High[shift];
         DownArrow[shift]=TrStopLevel;
        }
      PREV=TrStopLevel;
     }
   //for (i=0;i>5;i++)
   // {
   i=1;
   if (UpArrow[i]>0 && UpArrow[i]<TrStopDots[i]) UpArrow[i]=0.0;
   if (DownArrow[i]>TrStopDots[i]) DownArrow[i]=0.0;
   //}
   return(0);
  }
//+------------------------------------------------------------------+