//+------------------------------------------------------------------+
//|                                           i-PassLevCCI_v.1.2.mq4 |
//|                              Идея Gentor, реализация в МТ4 KimIV |
//|                                              http://www.kimiv.ru |
//|   23.08.2005 v.1.0                                               |
//| Последовательный проход ССИ через уровни -100, 0 и 100           |
//|   24.08.2005 v.1.1                                               |
//| Исправляю ошибку в алгоритме.                                    |
//|   25.08.2005 v.1.2                                               |
//| Исправил ошибку, найденную extesy. Respect                       |
//|   26.08.2005 v.1.3                                               |
//| Оптимизирован алгоритм. Исправлены баги.                         |
//+------------------------------------------------------------------+
#property copyright "Gentor, KimIV, extesy"
#property link      "http://www.kimiv.ru"
//----
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 PaleTurquoise
#property indicator_color2 LightSalmon
#property indicator_color3 Red
//------- Внешние параметры ------------------------------------------
extern int CCI_Period  =14;   // Период CCI
extern int BarsForCheck=9;    // Количество баров для проверки
extern int MaxLevel    =100;  // Максимальное значение уровня
extern int MinLevel    =-100; // Минимальное значение уровня
extern int NumberOfBars=0;    // Количество баров обсчёта (0-все)
//------- Буферы индикатора ------------------------------------------
double SigBuy[];
double SigSell[];
double SigExit[];
//------- Глобальные переменные --------------------------------------
bool firstTime=True;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  void init() 
  {
   SetIndexBuffer(0, SigBuy);
   SetIndexStyle (0, DRAW_ARROW);
   SetIndexArrow (0, 233);
   SetIndexBuffer(1, SigSell);
   SetIndexStyle (1, DRAW_ARROW);
   SetIndexArrow (1, 234);
   SetIndexBuffer(2, SigExit);
   SetIndexStyle (2, DRAW_ARROW);
   SetIndexArrow (2, 251);
   Comment("");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
  void start() 
  {
   bool     fsb=False, fss=False, sig;
   double   cci0, cci1, cci2, cci3;
   int      loopbegin, shift, sh, i;
//----   
     if (firstTime) 
     {
      if (NumberOfBars==0) loopbegin=Bars - 1 - CCI_Period;
      else loopbegin=NumberOfBars - 1;
     }
   if (BarsForCheck<2) BarsForCheck=2;
     for(shift=loopbegin; shift>=0; shift--) 
     {
      SigBuy[shift]=EMPTY_VALUE;
      SigSell[shift]=EMPTY_VALUE;
      SigExit[shift]=EMPTY_VALUE;
      cci0=iCCI(NULL, 0, CCI_Period, PRICE_TYPICAL, shift+1);
      sig=False;
      // Сигнал на покупку
        if (cci0>MaxLevel) 
        {
           for(sh=2; sh<=BarsForCheck; sh++) 
           {
            if (fsb) break;
            cci1=iCCI(NULL, 0, CCI_Period, PRICE_TYPICAL, shift+sh-1);
            cci2=iCCI(NULL, 0, CCI_Period, PRICE_TYPICAL, shift+sh);
              if (cci1>cci2) 
              {
                 if (cci2<MinLevel) 
                 {
                  SigBuy[shift]=Low[shift] - 10 * Point;
                  fsb=True; fss=False; sig=True; break;
                 }
              } 
              else break;
           }
        }
      // Сигнал на продажу
        if (cci0<MinLevel) 
        {
           for(sh=2; sh<=BarsForCheck; sh++) 
           {
            if (fss) break;
            cci1=iCCI(NULL, 0, CCI_Period, PRICE_TYPICAL, shift+sh-1);
            cci2=iCCI(NULL, 0, CCI_Period, PRICE_TYPICAL, shift+sh);
              if (cci1<cci2) 
              {
                 if (cci2>MaxLevel) 
                 {
                  SigSell[shift]=High[shift] + 10 * Point;
                  fss=True; fsb=False; sig=True; break;
                 }
              } 
              else break;
           }
        }
      // Сигналы на выход
      cci3=iCCI(NULL, 0, CCI_Period, PRICE_TYPICAL, shift+2);
        if (cci0*cci3<0 && (fsb || fss) && !sig) 
        {
         SigExit[shift]=Close[shift];
         fsb=False;
         fss=False;
        }
     }
  }
//+------------------------------------------------------------------+

