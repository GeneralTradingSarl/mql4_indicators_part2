//+------------------------------------------------------------------+
//|                                                   i-Sessions.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//|  16.11.2005  Индикатор торговых сессий                           |
//+------------------------------------------------------------------+
#property copyright "Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"
//----
#property indicator_chart_window
//------- Внешние параметры индикатора -------------------------------
extern int    NumberOfDays=50;
extern string S1Begin   ="00:55";
extern string S1End     ="03:55";
extern color  S1Color   =DarkSlateGray;
extern string S2Begin   ="03:55";
extern string S2End     ="06:55";
extern color  S2Color   =DarkSlateGray;
extern string S3Begin   ="06:55";
extern string S3End     ="09:55";
extern color  S3Color   =DarkSlateGray;
extern string S4Begin   ="09:55";
extern string S4End     ="12:55";
extern color  S4Color   =DarkSlateGray;
extern string S5Begin   ="12:55";
extern string S5End     ="15:55";
extern color  S5Color   =DarkSlateGray;
extern string S6Begin   ="15:55";
extern string S6End     ="18:55";
extern color  S6Color   =DarkSlateGray;
extern string S7Begin   ="18:55";
extern string S7End     ="21:55";
extern color  S7Color   =DarkSlateGray;
extern string S8Begin   ="21:55";
extern string S8End     ="23:55";
extern color  S8Color   =DarkSlateGray;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  void init() 
  {
   DeleteObjects();
     for(int i=0; i<NumberOfDays; i++) 
     {
      CreateObjects("S1"+i, S1Color);
      CreateObjects("S2"+i, S2Color);
      CreateObjects("S3"+i, S3Color);
      CreateObjects("S4"+i, S4Color);
      CreateObjects("S5"+i, S5Color);
      CreateObjects("S6"+i, S6Color);
      CreateObjects("S7"+i, S7Color);
      CreateObjects("S8"+i, S8Color);
     }
   Comment("");
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
  void deinit() 
  {
   DeleteObjects();
   Comment("");
  }
//+------------------------------------------------------------------+
//| Создание объектов индикатора                                     |
//| Параметры:                                                       |
//|   no - наименование объекта                                      |
//|   cl - цвет объекта                                              |
//+------------------------------------------------------------------+
  void CreateObjects(string no, color cl) 
  {
   ObjectCreate(no, OBJ_RECTANGLE, 0, 0,0, 0,0);
   ObjectSet(no, OBJPROP_STYLE, 2);
   ObjectSet(no, OBJPROP_COLOR, cl);
   ObjectSet(no, OBJPROP_BACK, True);
  }
//+------------------------------------------------------------------+
//| Удаление объектов индикатора                                     |
//+------------------------------------------------------------------+
  void DeleteObjects() 
  {
     for(int i=0; i<NumberOfDays; i++) 
     {
      ObjectDelete("S1"+i);
      ObjectDelete("S2"+i);
      ObjectDelete("S3"+i);
      ObjectDelete("S4"+i);
      ObjectDelete("S5"+i);
      ObjectDelete("S6"+i);
      ObjectDelete("S7"+i);
      ObjectDelete("S8"+i);
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
  void start() 
  {
   datetime dt=CurTime();
     for(int i=0; i<NumberOfDays; i++) 
     {
      DrawObjects(dt, "S1"+i, S1Begin, S1End);
      DrawObjects(dt, "S2"+i, S2Begin, S2End);
      DrawObjects(dt, "S3"+i, S3Begin, S3End);
      DrawObjects(dt, "S4"+i, S4Begin, S4End);
      DrawObjects(dt, "S5"+i, S5Begin, S5End);
      DrawObjects(dt, "S6"+i, S6Begin, S6End);
      DrawObjects(dt, "S7"+i, S7Begin, S7End);
      DrawObjects(dt, "S8"+i, S8Begin, S8End);
      dt=decDateTradeDay(dt);
      while(TimeDayOfWeek(dt)>5) dt=decDateTradeDay(dt);
     }
  }
//+------------------------------------------------------------------+
//| Прорисовка объектов на графике                                   |
//| Параметры:                                                       |
//|   dt - дата торгового дня                                        |
//|   no - наименование объекта                                      |
//|   tb - время начала сессии                                       |
//|   te - время окончания сессии                                    |
//+------------------------------------------------------------------+
  void DrawObjects(datetime dt, string no, string tb, string te) 
  {
   datetime t1, t2;
   double   p1, p2;
   int      b1, b2;
//----
   t1=StrToTime(TimeToStr(dt, TIME_DATE)+" "+tb);
   t2=StrToTime(TimeToStr(dt, TIME_DATE)+" "+te);
   b1=iBarShift(NULL, 0, t1);
   b2=iBarShift(NULL, 0, t2);
   p1=High[Highest(NULL, 0, MODE_HIGH, b1-b2, b2)];
   p2=Low [Lowest (NULL, 0, MODE_LOW , b1-b2, b2)];
   ObjectSet(no, OBJPROP_TIME1 , t1);
   ObjectSet(no, OBJPROP_PRICE1, p1);
   ObjectSet(no, OBJPROP_TIME2 , t2);
   ObjectSet(no, OBJPROP_PRICE2, p2);
  }
//+------------------------------------------------------------------+
//| Уменьшение даты на один торговый день                            |
//| Параметры:                                                       |
//|   dt - дата торгового дня                                        |
//+------------------------------------------------------------------+
  datetime decDateTradeDay (datetime dt) 
  {
   int ty=TimeYear(dt);
   int tm=TimeMonth(dt);
   int td=TimeDay(dt);
   int th=TimeHour(dt);
   int ti=TimeMinute(dt);
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

