//+------------------------------------------------------------------+
//|                                               i-MorningRange.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//|  08.02.2006  Индикатор утреннего диапазона.                      |
//+------------------------------------------------------------------+
#property copyright "Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Orange
//------- Внешние параметры индикатора -------------------------------
extern string CheckTime   ="08:00";  // Время проверки диапазона
extern bool   ShowHistory =True;     // Показывать исторические уровни
extern int    NumberOfDays=5;        // Количество дней истории
extern bool   ShowComment =True;     // Показывать комментарии
//------- Буферы индикатора ------------------------------------------
double dBuf0[], dBuf1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  void init() 
  {
   SetIndexArrow (0, 217);
   SetIndexBuffer(0, dBuf0);
   SetIndexStyle (0, DRAW_ARROW, 1, 1);
   SetIndexArrow (1, 218);
   SetIndexBuffer(1, dBuf1);
   SetIndexStyle (1, DRAW_ARROW, 1, 1);
   DeleteLines();
     for(int i=0; i<2; i++) 
     {
      ObjectCreate("HLine"+i, OBJ_HLINE, 0, 0,0);
     }
     for(i=0; i<NumberOfDays; i++) 
     {
      CreateLines("upLine"+i, indicator_color1);
      CreateLines("dnLine"+i, indicator_color2);
     }
  }
//+------------------------------------------------------------------+
//| Создание объектов Линия прошлых дней                             |
//| Параметры:                                                       |
//|   no - наименование линии                                        |
//|   cl - цвет линии                                                |
//+------------------------------------------------------------------+
  void CreateLines(string no, color cl) 
  {
   ObjectCreate(no, OBJ_TREND, 0, 0,0, 0,0);
   ObjectSet(no, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(no, OBJPROP_WIDTH, 1);
   ObjectSet(no, OBJPROP_COLOR, cl);
   ObjectSet(no, OBJPROP_RAY, False);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
  void deinit() 
  {
   DeleteLines();
   Comment("");
  }
//+------------------------------------------------------------------+
//| Удаление горизонтальных линий.                                   |
//+------------------------------------------------------------------+
  void DeleteLines() 
  {
     for(int i=0; i<2; i++) 
     {
      ObjectDelete("HLine"+i);
     }
     for(i=0; i<NumberOfDays; i++) 
     {
      ObjectDelete("upLine"+i);
      ObjectDelete("dnLine"+i);
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
  void start() 
  {
   datetime t1, t2, dt;
   double   p1, p2;
   int      b1, b2, sd=0;
//----
   t1=StrToTime(TimeToStr(CurTime(), TIME_DATE)+" 00:00");
   t2=StrToTime(TimeToStr(CurTime(), TIME_DATE)+" "+CheckTime);
   b1=iBarShift(NULL, 0, t1);
   b2=iBarShift(NULL, 0, t2);
   p1=High[Highest(NULL, 0, MODE_HIGH, b1-b2+1, b2)];
   p2=Low [Lowest (NULL, 0, MODE_LOW , b1-b2+1, b2)];
   SetHLine(0, p1);
   SetHLine(1, p2);
     if (ShowHistory) 
     {
      dt=decDateTradeDay(CurTime());
        for(int i=0; i<NumberOfDays; i++) 
        {
         DrawLines(dt, i);
         dt=decDateTradeDay(dt);
         while(TimeDayOfWeek(dt)<1 || TimeDayOfWeek(dt)>5) dt=decDateTradeDay(dt);
        }
     }
   if (ShowComment) Comment("CheckTime="+CheckTime);
  }
//+------------------------------------------------------------------+
//| Устанавливает реквизиты горизонтальной линии текущего дня.       |
//+------------------------------------------------------------------+
  void SetHLine(int nl, double pp) 
  {
   color cl;
     if (pp!=EMPTY_VALUE) 
     {
        switch(nl) 
        {
            case 0: cl=indicator_color1; break;
            case 1: cl=indicator_color2; break;
           }
         ObjectSet("HLine"+nl, OBJPROP_PRICE1, pp);
         ObjectSet("HLine"+nl, OBJPROP_COLOR , cl);
        }
           }
//+------------------------------------------------------------------+
//| Прорисовка линий на графике                                      |
//| Параметры:                                                       |
//|   dt - дата торгового дня                                        |
//|   nd - номер дня (для нумерации объектов)                        |
//+------------------------------------------------------------------+
  void DrawLines(datetime dt, int nd) 
   {
                  datetime t1, t2;
                  double   p1, p2;
                  int      b1, b2;

                  t1=StrToTime(TimeToStr(dt, TIME_DATE)+" 00:00");
                  t2=StrToTime(TimeToStr(dt, TIME_DATE)+" "+CheckTime);
                  b1=iBarShift(NULL, 0, t1);
                  b2=iBarShift(NULL, 0, t2);
                  p1=High[Highest(NULL, 0, MODE_HIGH, b1-b2+1, b2)];
                  p2=Low [Lowest (NULL, 0, MODE_LOW , b1-b2+1, b2)];

                  ObjectSet("upLine"+nd, OBJPROP_TIME1 , t1);
                  ObjectSet("upLine"+nd, OBJPROP_PRICE1, p1);
                  ObjectSet("upLine"+nd, OBJPROP_TIME2 , t2);
                  ObjectSet("upLine"+nd, OBJPROP_PRICE2, p1);

                  ObjectSet("dnLine"+nd, OBJPROP_TIME1 , t1);
                  ObjectSet("dnLine"+nd, OBJPROP_PRICE1, p2);
                  ObjectSet("dnLine"+nd, OBJPROP_TIME2 , t2);
                  ObjectSet("dnLine"+nd, OBJPROP_PRICE2, p2);
                 }

//+------------------------------------------------------------------+
//| Уменьшение даты на один торговый день                            |
//| Параметры:                                                       |
//|   dt - дата торгового дня                                        |
//+------------------------------------------------------------------+
                 datetime decDateTradeDay(datetime dt) 
                 {
                  int ty=TimeYear(dt);
                  int tm=TimeMonth(dt);
                  int td=TimeDay(dt);
                  int th=TimeHour(dt);
                  int ti=TimeMinute(dt);
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
                     if (tm==1 || tm==3 || tm==5 || tm==7 || tm==8 || tm==10 || tm==12) td=31;
                     if (tm==2) if (MathMod(ty, 4)==0) td=29; else td=28;
                     if (tm==4 || tm==6 || tm==9 || tm==11) td=30;
                    }
                  return(StrToTime(ty+"."+tm+"."+td+" "+th+":"+ti));
                 }
//+------------------------------------------------------------------+

