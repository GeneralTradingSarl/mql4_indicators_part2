//+------------------------------------------------------------------+
//|                                                    InfoLabel.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

extern string  _1="// --- Place settings ---";
extern int     Corner=2;
extern string  Corner_tips="// 0=upper left, 1=upper right, 2=lower left, 3=lower right";
extern int     XMargin=5;
extern int     YMargin=10;
extern string  _2="// --- Font settings ---";
extern string  Font="Arial";
extern color   Color=Yellow;
extern int     Size=10;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

   if((Corner==1 || Corner==3) && XMargin<1)  XMargin=1;
   if(XMargin<0)  XMargin=0;

   if(Corner>1 && YMargin<1)  YMargin=1;
   if(YMargin<0)  YMargin=0;
//---
   ObjectCreate("InfoLabel1",OBJ_LABEL, 0, 0, 0);
   ObjectSet(   "InfoLabel1",OBJPROP_CORNER,   Corner);
   ObjectSet(   "InfoLabel1",OBJPROP_XDISTANCE,XMargin);
   ObjectSet(   "InfoLabel1",OBJPROP_YDISTANCE,YMargin);

   ObjectCreate("InfoLabel2",OBJ_LABEL, 0, 0, 0);
   ObjectSet(   "InfoLabel2",OBJPROP_CORNER,   Corner);
   ObjectSet(   "InfoLabel2",OBJPROP_XDISTANCE,XMargin);
   ObjectSet(   "InfoLabel2",OBJPROP_YDISTANCE,YMargin+1.5*Size);

   ObjectCreate("InfoLabel3",OBJ_LABEL, 0, 0, 0);
   ObjectSet(   "InfoLabel3",OBJPROP_CORNER,   Corner);
   ObjectSet(   "InfoLabel3",OBJPROP_XDISTANCE,XMargin);
   ObjectSet(   "InfoLabel3",OBJPROP_YDISTANCE,YMargin+3*Size);

//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   ObjectDelete("InfoLabel1");
   ObjectDelete("InfoLabel2");
   ObjectDelete("InfoLabel3");
//---
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator Start Function
//+------------------------------------------------------------------+
int start()
{
   ObjectSetText("InfoLabel1",
   "Bid: " + DoubleToString(Bid,Digits) + 
   " Ask: " + DoubleToString(Ask,Digits) +
   " Spread: " + DoubleToString(MarketInfo(Symbol(), MODE_SPREAD),0) +
   " RCT: " +  RemainingCandleTime()
   ,Size,Font,Color);
   
   ObjectSetText("InfoLabel2",
   "O: " + DoubleToString(Open[0],Digits) + 
   " H: " + DoubleToString(High[0],Digits) + 
   " L: " + DoubleToString(Low[0],Digits) + 
   " C: " + DoubleToString(Close[0],Digits) + 
   " V: " + DoubleToString(Volume[0],0)  
   ,Size,Font,Color);
   
   ObjectSetText("InfoLabel3",
   "Local-Time: " + TimeToString(TimeLocal(),TIME_SECONDS) +
   " Server-Time: " + TimeToString(TimeCurrent(),TIME_SECONDS)
   ,Size,Font,Color);
   
//---
   return(0);
}

string RemainingCandleTime()
{
   return TimeToStr(((Period()*60)-(TimeCurrent()-Time[0])),TIME_SECONDS);
}