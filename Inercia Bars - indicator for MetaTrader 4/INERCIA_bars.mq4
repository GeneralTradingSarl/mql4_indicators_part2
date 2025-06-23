//+------------------------------------------------------------------+
//|   INERCIA_bars.mq4                                               |
//|   Translated by KimIV                                            |
//|	Author := BOL                                                  |
//|   Name := INERCIA_bars                                           |
//|   http://www.kimiv.ru                                            |
//|                                                                  |
//| 10.11.2005  Шаблон индикатора с двумя сигналами                  |
//+------------------------------------------------------------------+
#property copyright "NICTRADER"
#property link      "http://nyctrader.ru/"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//------- Внешние параметры индикатора -------------------------------
extern int body        =7;
extern int NumberOfBars=400;     // Количество баров обсчёта (0-все)
//------- Буферы индикатора ------------------------------------------
double buf0[];
double buf1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  void init() 
  {
   SetIndexBuffer(0, buf0);
   SetIndexStyle (0, DRAW_HISTOGRAM);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   //
   SetIndexBuffer(1, buf1);
   SetIndexStyle (1, DRAW_HISTOGRAM);
   SetIndexEmptyValue(1, EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
  void start() 
  {
   int LoopBegin, sh;
//----
   if (NumberOfBars==0) LoopBegin=Bars-1;
   else LoopBegin=NumberOfBars-1;
   LoopBegin=MathMin(Bars-25, LoopBegin);
     for(sh=LoopBegin; sh>=0; sh--) 
     {
      buf0[sh]=EMPTY_VALUE;
      buf1[sh]=EMPTY_VALUE;
        if (Close[sh]>Open[sh] && Close[sh]-Open[sh]>body*Point) 
        {
         buf0[sh]=High[sh];
         buf1[sh]=Low[sh];
        }
        if (Close[sh]<Open[sh] && Open[sh]-Close[sh]>body*Point) 
        {
         buf0[sh]=Low[sh];
         buf1[sh]=High[sh];
        }
     }
  }
//+------------------------------------------------------------------+

