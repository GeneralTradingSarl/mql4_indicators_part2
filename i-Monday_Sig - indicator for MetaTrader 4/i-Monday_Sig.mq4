//+------------------------------------------------------------------+
//|                                                 i-Monday_Sig.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//| 01.12.2005  Сигналы входов и выходов по системе Понедельник.     |
//+------------------------------------------------------------------+
#property copyright "Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//------- Внешние параметры индикатора -------------------------------
extern int HourOpenPos =11;     // Время открытия покупки
extern int NumberOfBars=10000;  // Количество баров обсчёта (0-все)
//------- Глобальные переменные --------------------------------------
int ArrowInterval;
//------- Поключение внешних модулей ---------------------------------
//------- Буферы индикатора ------------------------------------------
double SigBuy[];
double SigSell[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  void init() 
  {
   SetIndexBuffer(0, SigBuy);
   SetIndexStyle (0, DRAW_ARROW);
   SetIndexArrow (0, 233);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexBuffer(1, SigSell);
   SetIndexStyle (1, DRAW_ARROW);
   SetIndexArrow (1, 234);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   ArrowInterval=GetArrowInterval();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
  void start() 
  {
   double ms[2];
   int    loopbegin, shift;
//----
   if (NumberOfBars==0) loopbegin=Bars-1;
   else loopbegin=NumberOfBars-1;
     for(shift=loopbegin; shift>=0; shift--) 
     {
      ms[0]=EMPTY_VALUE;
      ms[1]=EMPTY_VALUE;
      GetSignals(shift, ms);
      SigBuy[shift]=ms[0];
      SigSell[shift]=ms[1];
     }
  }
//+------------------------------------------------------------------+
//| Возвращает сигналы                                               |
//+------------------------------------------------------------------+
  void GetSignals(int nb, double& ms[]) 
  {
   int    nsb=iBarShift(NULL, PERIOD_D1, Time[nb]);
   double Op1=iOpen (NULL, PERIOD_D1, nsb+1);
   double Cl1=iClose(NULL, 0, nb+1);
     if (TimeDayOfWeek(Time[nb])==1 && TimeHour(Time[nb])==HourOpenPos && TimeMinute(Time[nb])==0) 
     {
      if (Op1>Cl1) ms[0]=Low[nb]-ArrowInterval*Point;
      if (Op1<Cl1) ms[1]=High[nb]+ArrowInterval*Point;
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
         case 1440:  return(80);
         case 10080: return(150);
         case 43200: return(250);
        }
     }
//+------------------------------------------------------------------+

