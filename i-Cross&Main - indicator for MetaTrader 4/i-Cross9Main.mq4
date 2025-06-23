//+------------------------------------------------------------------+
//|                                                 i-Cross&Main.mq4 |
//|                                              Поручик & aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//|  07.01.2006  Индикатор кросса и произведения основных пар.       |
//+------------------------------------------------------------------+
#property copyright "Поручик & aka KimIV"
#property link      "http://www.kimiv.ru"
//----
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Aqua
#property indicator_color2 Blue
//------- Внешние параметры индикатора -------------------------------
extern string NameCross   ="GBPCHF"; // Наименование кросса
extern string NameMain1   ="GBPUSD"; // Наименование основной пары 1
extern string NameMain2   ="USDCHF"; // Наименование основной пары 2
extern int    NumberOfBars=1000;     // Количество баров обсчёта (0-все)
//------- Буферы индикатора ------------------------------------------
double buf0[], buf1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  void init() 
  {
   SetIndexBuffer(0, buf0);
   SetIndexLabel (0, NameCross);
   SetIndexStyle (0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexEmptyValue(0, 0);
   SetIndexBuffer(1, buf1);
   SetIndexLabel (1, NameMain1+"*"+NameMain2);
   SetIndexStyle (1, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexEmptyValue(1, 0);
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
   int LoopBegin, sh;
//----   
   if (NumberOfBars==0) LoopBegin=Bars-1;
   else LoopBegin=NumberOfBars-1;
   LoopBegin=MathMin(Bars-1, LoopBegin);
     for(sh=LoopBegin; sh>=0; sh--) 
     {
      buf0[sh]=iClose(NameCross, 0, sh);
      buf1[sh]=iClose(NameMain1, 0, sh)*iClose(NameMain2, 0, sh);
     }
  }
//+------------------------------------------------------------------+