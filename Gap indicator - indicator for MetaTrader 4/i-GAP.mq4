//+------------------------------------------------------------------+
//|                                                        i-GAP.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//| 04.11.2005  Индикатор ГЭПов                                      |
//+------------------------------------------------------------------+
#property copyright "Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 LightBlue
#property indicator_color2 Salmon

//------- Внешние параметры индикатора -------------------------------
extern int SizeGAP      = 5;      // Размер ГЭПа
extern int NumberOfBars = 10000;  // Количество баров обсчёта (0-все)

//------- Глобальные переменные --------------------------------------
int ArrowInterval;

//------- Поключение внешних модулей ---------------------------------

//------- Буферы индикатора ------------------------------------------
double SigBuy[];
double SigSell[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
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
void start() {
  double ms[2];
  int    LoopBegin, sh;

 	if (NumberOfBars==0) LoopBegin=Bars-1;
  else LoopBegin=MathMin(NumberOfBars-1,Bars-2);

  for (sh=LoopBegin; sh>=0; sh--) {
    ms[0]=EMPTY_VALUE;
    ms[1]=EMPTY_VALUE;
    GetSignals(sh, ms);
    SigBuy[sh]=ms[0];
    SigSell[sh]=ms[1];
  }
}

//+------------------------------------------------------------------+
//| Возвращает сигналы                                               |
//+------------------------------------------------------------------+
void GetSignals(int nb, double& ms[]) {
  double Cl1=Close[nb+1];
  double Op0=Open [nb];

  if (Cl1>Op0+SizeGAP*Point) ms[0]=Low[nb]-ArrowInterval*Point;
  if (Cl1<Op0-SizeGAP*Point) ms[1]=High[nb]+ArrowInterval*Point;
}

//+------------------------------------------------------------------+
//| Возвращает интервал установки сигнальных указателей              |
//+------------------------------------------------------------------+
int GetArrowInterval() {
  int p=Period();

  switch (p) {
    case 1:     return(3);
    case 5:     return(5);
    case 15:    return(7);
    case 30:    return(10);
    case 60:    return(15);
    case 240:   return(20);
    case 1440:  return(50);
    case 10080: return(100);
    case 43200: return(200);
  }
}
//+------------------------------------------------------------------+

