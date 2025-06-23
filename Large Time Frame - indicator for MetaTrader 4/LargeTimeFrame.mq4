//+------------------------------------------------------------------+
//|                                               LargeTimeFrame.mq4 |
//|                                      Copyright © 2005, Miramaxx. |
//|                                    mailto: morrr2001[dog]mail.ru |
//+------------------------------------------------------------------+
//|Построение на графике свечей старшего таймфрейма.                 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Miramaxx."
#property link "mailto: morrr2001[dog]mail.ru"
//----
#property indicator_chart_window
//----
extern string Timeframe="D1";
extern int CountBars=10;
extern color Bear=Maroon;
extern color Bull=MidnightBlue;
//----
   datetime time1;
   datetime time2;
   double open_price,close_price;
   int bar_tf;
   int PeriodName=0;
   int num=0;
   string error="Параметр Timeframe задан не верно \nПример: для часового графика выберите параметр D1.";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   void ObjDel()
  {
   for(;num>=0;num--)
      ObjectDelete("Objtf"+num);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   if (Timeframe=="M1") PeriodName=PERIOD_M1; //в том же порядке, что и кнопки на панели
   else
      if (Timeframe=="M5") PeriodName=PERIOD_M5;
      else
         if (Timeframe=="M15")PeriodName=PERIOD_M15;
         else
            if (Timeframe=="M30")PeriodName=PERIOD_M30;
            else
               if (Timeframe=="H1") PeriodName=PERIOD_H1;
               else
                  if (Timeframe=="H4") PeriodName=PERIOD_H4;
                  else
                     if (Timeframe=="D1") PeriodName=PERIOD_D1;
                     else
                        if (Timeframe=="W1") PeriodName=PERIOD_W1;
                        else
                           if (Timeframe=="MN") PeriodName=PERIOD_MN1;
                           else
                             {
                              Comment(error);
                              return(0);
                             }
   Comment("LargeTimeframe(",Timeframe,")");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjDel();
   Comment("");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int i;
   ObjDel();
   num=0;
//----
   if (PeriodName<=Period())
     {
      Comment(error);
      return(0);
     }
//----
   for(bar_tf=CountBars;bar_tf>=0;bar_tf--)
     {
      time1=iTime(NULL,PeriodName,bar_tf);
      i=bar_tf-1;
      if (i<0)
         time2=Time[0];
      else
         time2=iTime(NULL,PeriodName,i)-Period()*60;
      open_price=iOpen(NULL,PeriodName,bar_tf);
      close_price=iClose(NULL,PeriodName,bar_tf);
//---
      ObjectCreate("Objtf"+num,OBJ_RECTANGLE,0,time1,open_price,time2,close_price);
      if (time2-time1<PeriodName*60/2)
         time2=Time[0];
      else
         time2=time1+PeriodName*60/2;
      num++;
//----      
      ObjectCreate("Objtf"+num,OBJ_TREND,0,time2,iHigh(NULL,PeriodName,bar_tf),time2,iLow(NULL,PeriodName,bar_tf));
      ObjectSet("Objtf"+num, OBJPROP_WIDTH, 2);
      ObjectSet("Objtf"+num, OBJPROP_RAY, false);
      ObjectSet("Objtf"+num, OBJPROP_BACK, true);
//----      
      if (close_price>open_price)
        {
         ObjectSet("Objtf"+(num-1),OBJPROP_COLOR, Bull);
         ObjectSet("Objtf"+num,OBJPROP_COLOR, Bull);
        }
      else
        {
         ObjectSet("Objtf"+(num-1),OBJPROP_COLOR, Bear);
         ObjectSet("Objtf"+num,OBJPROP_COLOR, Bear);
        }
      num++;
     }
   return(0);
  }
//+------------------------------------------------------------------+