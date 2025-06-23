//+------------------------------------------------------------------+
//|                                                   MarketTime.mq4 |
//|                                  Copyright © 2007, GwadaTradeBoy |
//|                                           gwadatradeboy@yahoo.fr |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, GwadaTradeBoy"
#property link      "gwadatradeboy@yahoo.fr"
#property indicator_chart_window
//----
extern int     NumberOfDays=50;
extern string  AsiaBegin   ="01:00";
extern string  AsiaEnd     ="10:00";
extern color   AsiaColor   =Goldenrod;
extern string  EurBegin    ="07:00";
extern string  EurEnd      ="16:00";
extern color   EurColor    =Tan;
extern string  USABegin    ="14:00";
extern string  USAEnd      ="23:00";
extern color   USAColor    =PaleGreen;
//----- Variabes
datetime       DateTrade, TimeBeginObject, TimeEndObject;
int            i, BarBegin, BarEnd;
double         PriceHighObject, PriceLowObject;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   DeleteObjects();
   for(i=0; i<NumberOfDays; i++)
     {
      CreateObjects("AS"+i, AsiaColor);
      CreateObjects("EU"+i, EurColor);
      CreateObjects("US"+i, USAColor);
     }
   Comment("");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   DeleteObjects();
   Comment("");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
   DateTrade=CurTime();
   for(i=0; i<NumberOfDays; i++)
     {
      DrawObjects(DateTrade, "AS"+i, AsiaBegin, AsiaEnd);
      DrawObjects(DateTrade, "EU"+i, EurBegin, EurEnd);
      DrawObjects(DateTrade, "US"+i, USABegin, USAEnd);
      DateTrade=decDateTradeDay(DateTrade);
      while(TimeDayOfWeek(DateTrade)> 5)
         DateTrade=decDateTradeDay(DateTrade);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateObjects(string NameObject, color ColorObject)
  {
   ObjectCreate(NameObject, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
   ObjectSet(NameObject, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(NameObject, OBJPROP_COLOR, ColorObject);
   ObjectSet(NameObject, OBJPROP_BACK, True);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteObjects()
  {
   for(i=0; i < NumberOfDays; i++)
     {
      ObjectDelete("AS"+i);
      ObjectDelete("EU"+i);
      ObjectDelete("US"+i);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawObjects(datetime DateTrade, string NameObject, string TimeBegin, string TimeEnd)
  {
   TimeBeginObject=StrToTime(TimeToStr(DateTrade, TIME_DATE)+" "+TimeBegin);
   TimeEndObject=StrToTime(TimeToStr(DateTrade, TIME_DATE)+" "+TimeEnd);
   BarBegin=iBarShift(NULL, 0, TimeBeginObject);
   BarEnd=iBarShift(NULL, 0, TimeEndObject);
   PriceHighObject=High[iHighest(NULL, 0, MODE_HIGH, BarBegin - BarEnd, BarEnd)];
   PriceLowObject=Low [iLowest (NULL, 0, MODE_LOW , BarBegin - BarEnd, BarEnd)];
   ObjectSet(NameObject, OBJPROP_TIME1 , TimeBeginObject);
   ObjectSet(NameObject, OBJPROP_PRICE1, PriceHighObject);
   ObjectSet(NameObject, OBJPROP_TIME2 , TimeEndObject);
   ObjectSet(NameObject, OBJPROP_PRICE2, PriceLowObject);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime decDateTradeDay (datetime DateTrade)
  {
   int ty=TimeYear(DateTrade);
   int tm=TimeMonth(DateTrade);
   int td=TimeDay(DateTrade);
   int th=TimeHour(DateTrade);
   int ti=TimeMinute(DateTrade);
//----
   td--;
   if (td==0)
     {
      tm--;
      if (tm==0)
        {
         ty--;
         tm=12;
        }
      if (tm==1 || tm==3 || tm==5 || tm==7 || tm==8 || tm==10 || tm==12)
         td=31;
      if (tm==2)
         if (MathMod(ty, 4)==0)
            td=29;
         else
            td=28;
      if (tm==4 || tm==6 || tm==9 || tm==11)
         td=30;
     }
//----   
   return(StrToTime(ty+"."+tm+"."+td+" "+th+":"+ti));
  }
//+------------------------------------------------------------------+