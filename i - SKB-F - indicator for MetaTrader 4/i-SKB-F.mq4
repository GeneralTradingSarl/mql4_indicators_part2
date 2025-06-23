//+------------------------------------------------------------------+
//|                                                      i-SKB-F.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//|  13.06.2006  Скользящие каналы Баришпольца на Фракталах.         |
//+------------------------------------------------------------------+
#property copyright "Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 SkyBlue
#property indicator_color2 Salmon
//------- Поключение внешних модулей ---------------------------------
//------- Внешние параметры индикатора -------------------------------
extern int  FixedTF=60;
extern int  OffSet =-3;
extern bool ShowRay=True;
//------- Глобальные переменные индикатора ---------------------------
double dBuf0[];
double dBuf1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  void init() 
  {
     if (ShowRay) 
     {
      ObjectCreate("HL", OBJ_TREND, 0, 0,0,0,0);
      ObjectCreate("LL", OBJ_TREND, 0, 0,0,0,0);
     }
   SetIndexBuffer(0, dBuf0);
   SetIndexLabel (0, "HL");
   SetIndexStyle (0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexBuffer(1, dBuf1);
   SetIndexLabel (1, "LL");
   SetIndexStyle (1, DRAW_LINE, STYLE_SOLID, 2);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
  void deinit() 
  {
   ObjectDelete("HL");
   ObjectDelete("LL");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
  void start() 
  {
   double y3=0, y2=0, y1=0, zz;    // фракталы
   double y4, u2, u1, d2, d1;      // ценовые уровни линий
   int    x3, x2, x1, sh=2;        // номера баров
   string sL1, sL2;
   color  clU, clD;
   // Берём три экстремума Зиг-Зага
     while(y3==0) 
     {
      zz=iFractals(NULL, FixedTF, MODE_UPPER, sh);
      if (zz==0) zz=iFractals(NULL, FixedTF, MODE_LOWER, sh);
        if (zz!=0) 
        {
         if      (y1==0) { x1=sh; y1=zz; }
         else if (y2==0) { x2=sh; y2=zz; }
            else if (y3==0) { x3=sh; y3=zz; }
        }
      sh++;
     }
   y4=EquationDirect(x3, y3, x1, y1, x2);
     if (y2>y1) 
     {
      u2=y3+y2-y4;
      u1=EquationDirect(x3, u2, x2, y2, 0);
      d2=y3;
      d1=EquationDirect(x3, y3, x1, y1, 0);
      }
       else 
      {
      u2=y3;
      u1=EquationDirect(x3, y3, x1, y1, 0);
      d2=y3+y2-y4;
      d1=EquationDirect(x3, d2, x2, y2, 0);
     }
   u2+=OffSet*Point; u1+=OffSet*Point;
   d2-=OffSet*Point; d1-=OffSet*Point;
   x2=iBarShift(NULL, 0, iTime(NULL, FixedTF, x3));
     for(sh=x2; sh>=0; sh--) 
     {
      dBuf0[sh]=EquationDirect(x2, u2, 0, u1, sh);
      dBuf1[sh]=EquationDirect(x2, d2, 0, d1, sh);
     }
     if (ShowRay) 
     {
      ObjectSet("HL", OBJPROP_TIME1 , iTime(NULL, FixedTF, x3));
      ObjectSet("HL", OBJPROP_TIME2 , Time[0]);
      ObjectSet("HL", OBJPROP_PRICE1, u2);
      ObjectSet("HL", OBJPROP_PRICE2, u1);
      ObjectSet("HL", OBJPROP_BACK  , True);
      ObjectSet("HL", OBJPROP_RAY   , True);
      ObjectSet("HL", OBJPROP_STYLE , STYLE_DOT);
      ObjectSet("HL", OBJPROP_WIDTH , 1);
      ObjectSet("HL", OBJPROP_COLOR , indicator_color1);
      //
      ObjectSet("LL", OBJPROP_TIME1 , iTime(NULL, FixedTF, x3));
      ObjectSet("LL", OBJPROP_TIME2 , Time[0]);
      ObjectSet("LL", OBJPROP_PRICE1, d2);
      ObjectSet("LL", OBJPROP_PRICE2, d1);
      ObjectSet("LL", OBJPROP_BACK  , True);
      ObjectSet("LL", OBJPROP_RAY   , True);
      ObjectSet("LL", OBJPROP_STYLE , STYLE_DOT);
      ObjectSet("LL", OBJPROP_WIDTH , 1);
      ObjectSet("LL", OBJPROP_COLOR , indicator_color2);
     }
  }
//+------------------------------------------------------------------+
//| Уравнение прямой.                                                |
//| Вычисляет значение Y для X в точке пересечения с прямой.         |
//| Параметры:                                                       |
//|   x1,y1 - координаты первой точки,                               |
//|   x2,y2 - координаты второй точки,                               |
//|   x     - значение, для которого вычислить Y                     |
//+------------------------------------------------------------------+
  double EquationDirect(double x1, double y1, double x2, double y2, double x) 
  {
   if ((x2-x1)*(x-x1)==0) return(y1);
   return((y2-y1)/(x2-x1)*(x-x1)+y1);
  }
//+------------------------------------------------------------------+

