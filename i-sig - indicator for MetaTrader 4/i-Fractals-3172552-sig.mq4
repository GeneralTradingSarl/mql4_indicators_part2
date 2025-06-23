//+------------------------------------------------------------------+
//|                                                        i-sig.mq4 |
//|                                                  3172552 & KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//| 23.10.2005  Индикатор сигналов                                   |
//+------------------------------------------------------------------+
#property copyright "3172552 & KimIV"
#property link      "http://www.kimiv.ru"
//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Salmon
#property indicator_color3 Blue
#property indicator_color4 Salmon
//------- Внешние параметры индикатора -------------------------------
extern int NumberOfBars=2000;  // Количество баров обсчёта (0-все)
extern int bd =7;  //last bar body lenght 
extern int bdd=40; //body lenght for double top/buttom bars 
extern int sd =11; //shadow difference for fractal bars 
extern int sdd=6;  //shadow difference for double tops/buttoms bars 
//------- Глобальные переменные --------------------------------------
int ArrowInterval;
//------- Буферы индикатора ------------------------------------------
double SigBuy[];
double SigSell[];
double SigExitBuy[];
double SigExitSell[];
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
   SetIndexBuffer(2, SigExitBuy);
   SetIndexStyle (2, DRAW_ARROW);
   SetIndexArrow (2, 251);
   SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexBuffer(3, SigExitSell);
   SetIndexStyle (3, DRAW_ARROW);
   SetIndexArrow (3, 251);
   SetIndexEmptyValue(3, EMPTY_VALUE);
   ArrowInterval=GetArrowInterval();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
  void start() 
  {
   double ms[4];
   int    loopbegin, shift;
   if (NumberOfBars==0) loopbegin=Bars - 1;
   else loopbegin=NumberOfBars - 1;
     for(shift=loopbegin; shift>=0; shift--) 
     {
      ms[0]=EMPTY_VALUE;
      ms[1]=EMPTY_VALUE;
      ms[2]=EMPTY_VALUE;
      ms[3]=EMPTY_VALUE;
      GetSignals(shift, ms);
      SigBuy[shift]=ms[0];
      SigSell[shift]=ms[1];
      SigExitBuy[shift+1]=ms[2];
      SigExitSell[shift+1]=ms[3];
     }
  }
//+------------------------------------------------------------------+
//| Возвращает сигналы                                               |
//+------------------------------------------------------------------+
  void GetSignals(int nb, double& ms[]) 
  {
   bool bc1=False, bc2=False, bc3=False;
   bool sc1=False, sc2=False, sc3=False;
   //just unconfirmed fractal with last bar White
   bc1=( (Low[nb+3]-Low[nb+2])>(sd*Point)
      && (Low[nb+4]-Low[nb+2])>(sd*Point)
      && (Low[nb+1]-Low[nb+2])>(sd*Point)
      && (Close[nb+1]-Open[nb+1])>(bd*Point)
   );
   //just unconfirmed frsctal with last bar Black
   sc1=( (High[nb+2]-High[nb+3])>(sd*Point)
      && (High[nb+2]-High[nb+4])>(sd*Point)
      && (High[nb+2]-High[nb+1])>(sd*Point)
      && (Open[nb+1]-Close[nb+1])>(bd*Point)
   );
   //double buttom fractal
   bc2=( (Low[nb+4]-Low[nb+2])>(sd*Point)
      && (Low[nb+5]-Low[nb+2])>(sd*Point)
      && (Low[nb+1]-Low[nb+2])>(sd*Point)
      && (Close[nb+1]-Open[nb+1])>(bd*Point)
      && (MathAbs(Low[nb+3]-Low[nb+2]))<(sdd*Point)
   );
   //double top fractal
   sc2=( (High[nb+2]-High[nb+4])>(sd*Point)
      && (High[nb+2]-High[nb+5])>(sd*Point)
      && (High[nb+2]-High[nb+1])>(sd*Point)
      && (Open[nb+1]-Close[nb+1])>(bd*Point)
      && (MathAbs(High[nb+3]-High[nb+2]))<(sdd*Point)
   );
   //long bars double buttom fractal
   bc3=( (Low[nb+3]-Low[nb+2])>(sd*Point)
      && (Low[nb+4]-Low[nb+2])>(sd*Point)
      && (MathAbs(Low[nb+1]-Low[nb+2]))<(sdd*Point)
      && (Close[nb+1]-Open[nb+1])>(bdd*Point)
      && (Open[nb+2]-Close[nb+2])>(bdd*Point)
   );
   //long bars double top fractal
   sc3=( (High[nb+2]-High[nb+3])>(sd*Point)
      && (High[nb+2]-High[nb+4])>(sd*Point)
      && (MathAbs(High[nb+2]-High[nb+1]))<(sdd*Point)
      && (Open[nb+1]-Close[nb+1])>(bdd*Point)
      && (Close[nb+2]-Open[nb+2])>(bdd*Point)
   );
   if (bc1 || bc2 || bc3) ms[0]=Low[nb]-ArrowInterval*Point;
   if (sc1 || sc2 || sc3) ms[1]=High[nb]+ArrowInterval*Point;
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