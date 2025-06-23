//+------------------------------------------------------------------+
//|                                                  i-DayOfWeek.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//| 13.10.2005  Показывает выбранный день недели                     |
//+------------------------------------------------------------------+
#property copyright "Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Salmon
//------- Внешние параметры индикатора -------------------------------
extern int NumberDayOfWeek=1;   // Номер дня недели
extern int NumberOfBars   =0;   // Количество баров обсчёта (0-все)
//------- Глобальные переменные --------------------------------------
int ArrowInterval, prevDay;
//------- Поключение внешних модулей ---------------------------------
//------- Буферы индикатора ------------------------------------------
double UpLine[];
double DnLine[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  void init() 
  {
   SetIndexBuffer(0, UpLine);
   SetIndexStyle (0, DRAW_ARROW);
   SetIndexArrow (0, 159);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexBuffer(1, DnLine);
   SetIndexStyle (1, DRAW_ARROW);
   SetIndexArrow (1, 159);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   ArrowInterval=GetArrowInterval();
   Comment(NameDayOfWeek(NumberDayOfWeek));
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
  void deinit() 
  {
   Comment("");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
  void start() 
  {
   double dMax, dMin;
   int    loopbegin, nsb, shift;
//----
   if (NumberOfBars==0) loopbegin=Bars - 1;
   else loopbegin=NumberOfBars - 1;
     for(shift=0; shift<=loopbegin; shift++) 
     {
        if (prevDay!=TimeDay(Time[shift])) 
        {
         nsb=iBarShift(NULL, PERIOD_D1, Time[shift]);
         dMax=iHigh(NULL, PERIOD_D1, nsb)+ArrowInterval*Point;
         dMin=iLow (NULL, PERIOD_D1, nsb)-ArrowInterval*Point;
        }
        if (TimeDayOfWeek(Time[shift])==NumberDayOfWeek) 
        {
         UpLine[shift]=dMax;
         DnLine[shift]=dMin;
        }
      prevDay=TimeDay(Time[shift]);
     }
  }
//+------------------------------------------------------------------+
//| Возвращает интервал установки сигнальных указателей              |
//+------------------------------------------------------------------+
  int GetArrowInterval() 
  {
   int p=Period();
     switch(p) 
     {
         case 1:     return(5);
         case 5:     return(7);
         case 15:    return(10);
         case 30:    return(15);
         case 60:    return(20);
         case 240:   return(30);
         case 1440:  return(40);
         case 10080: return(150);
         case 43200: return(250);
        }
     }
//+------------------------------------------------------------------+
//| Возвращает наименование дня недели                               |
//+------------------------------------------------------------------+
           string NameDayOfWeek(int ndw) 
           {
            if (ndw==0) return("Воскресенье");
            if (ndw==1) return("Понедельник");
            if (ndw==2) return("Вторник");
            if (ndw==3) return("Среда");
            if (ndw==4) return("Четверг");
            if (ndw==5) return("Пятница");
            if (ndw==6) return("Суббота");
           }
//+------------------------------------------------------------------+

