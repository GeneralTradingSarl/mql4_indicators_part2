//+------------------------------------------------------------------+
//|                                          i-IntradayFibonacci.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//| 14.10.2005  Внутридневные уровни Фибоначчи                       |
//+------------------------------------------------------------------+
#property copyright "Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"
//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Aqua
#property indicator_color2 Lime
#property indicator_color3 Yellow
#property indicator_color4 Salmon
//------- Глобальные переменные --------------------------------------
//------- Поключение внешних модулей ---------------------------------
//------- Внешние параметры индикатора -------------------------------
extern int NumberOfBars=1000;  // Количество баров обсчёта (0-все)
//------- Буферы индикатора ------------------------------------------
double buf24[];
double buf38[];
double buf62[];
double buf76[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  void init() 
  {
   SetIndexBuffer(0, buf24);
   SetIndexStyle (0, DRAW_LINE, STYLE_DOT);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexBuffer(1, buf38);
   SetIndexStyle (1, DRAW_LINE, STYLE_DOT);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexBuffer(2, buf62);
   SetIndexStyle (2, DRAW_LINE, STYLE_DOT);
   SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexBuffer(3, buf76);
   SetIndexStyle (3, DRAW_LINE, STYLE_DOT);
   SetIndexEmptyValue(3, EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
  void start() 
  {
   double dMax, dMin;
   int    loopbegin, nsb, prevDay, shift;
//----
   if (NumberOfBars==0) loopbegin=Bars - 1;
   else loopbegin=NumberOfBars - 1;
     for(shift=loopbegin; shift>=0; shift--) 
     {
        if (prevDay!=TimeDay(Time[shift])) 
        {
         nsb=iBarShift(NULL, PERIOD_D1, Time[shift]);
         dMax=iHigh(NULL, PERIOD_D1, nsb);
         dMin=iLow (NULL, PERIOD_D1, nsb);
        }
      buf24[shift]=dMin-(dMin-dMax)*0.236;
      buf38[shift]=dMin-(dMin-dMax)*0.382;
      buf62[shift]=dMin-(dMin-dMax)*0.618;
      buf76[shift]=dMin-(dMin-dMax)*0.764;
      prevDay=TimeDay(Time[shift]);
     }
  }
//+------------------------------------------------------------------+

