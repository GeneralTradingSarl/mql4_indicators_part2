//+----------------------------------------------------------------------------+
//|  Setka_Final.mq4                                                        |
//|  Автор   : Сергей Привалов aka Prival,  Skype: privalov-sv                 |
//+----------------------------------------------------------------------------+
//| Версия  : 30.04.2010                                                       |
//| Описание: альтернативная сетка, рисует вертикальные линии начала часа, дня,|
//| недели и месяца, также рисует психологические горизонтальные уровни        |
//+----------------------------------------------------------------------------+
#property copyright "Привалов С.В."
#property link      "Skype -> privalov-sv"

#property indicator_chart_window
#property indicator_buffers 8

extern   double   Шаг=0;       // шаг сетки 0 выбор алгритма иначе задавайте сами

//---- buffers
double Ind_Buffer_0[],Ind_Buffer_1[];
double Ind_Buffer_2[],Ind_Buffer_3[];
double Ind_Buffer_4[],Ind_Buffer_5[];
double Ind_Buffer_6[],Ind_Buffer_7[];
double max;
color  LineColor;    // переменная для цвета горизонтальной линии
int    LineStile;    // переменная для стиля
int    LineWidth;    // переменная для ширины линии
int    Period_Ris;   // период графика для анализа отображения
bool   flag=true;
double   Window_Max=0, old_Window_Max=0;
double   Window_Min=0, old_Window_Min=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_HISTOGRAM, STYLE_DOT, 1, DimGray);
   SetIndexStyle(1,DRAW_HISTOGRAM, STYLE_DOT, 1, DimGray);
   SetIndexStyle(2,DRAW_HISTOGRAM, STYLE_DOT, 1, RoyalBlue);
   SetIndexStyle(3,DRAW_HISTOGRAM, STYLE_DOT, 1, RoyalBlue);
   SetIndexStyle(4,DRAW_HISTOGRAM, STYLE_DOT, 1, DeepPink);
   SetIndexStyle(5,DRAW_HISTOGRAM, STYLE_DOT, 1, DeepPink);
   SetIndexStyle(6,DRAW_HISTOGRAM, STYLE_DOT, 1, Gold);
   SetIndexStyle(7,DRAW_HISTOGRAM, STYLE_DOT, 1, Gold);
   SetIndexBuffer(0,Ind_Buffer_0);
   SetIndexBuffer(1,Ind_Buffer_1);
   SetIndexBuffer(2,Ind_Buffer_2);
   SetIndexBuffer(3,Ind_Buffer_3);
   SetIndexBuffer(4,Ind_Buffer_4);
   SetIndexBuffer(5,Ind_Buffer_5);
   SetIndexBuffer(6,Ind_Buffer_6);
   SetIndexBuffer(7,Ind_Buffer_7);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
  ObjectsDeleteAll(0,OBJ_HLINE);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    i, j, limit, counted_bars=IndicatorCounted();
   bool  new_Hour, new_Day, new_Week, new_Month;
   if(counted_bars <0) return(-1);
   if(counted_bars==0) limit=Bars-1;             // посчитанных баров еще нет, будет считать с бара,
   if(counted_bars >0) limit=Bars-counted_bars-1;// вычтем из числа доступных баров количество посчитанных
   
   if(counted_bars==0) limit-=2;
    
   if(flag)    max=iHigh(0,PERIOD_MN1,iHighest(NULL,PERIOD_MN1,MODE_HIGH,iBars(0,PERIOD_MN1),0));
   for(i = limit; i >= 0; i--)
     {
      new_Hour=TimeHour(Time[i]) != TimeHour(Time[i+1]); // новый час
      new_Day=TimeDay(Time[i]) != TimeDay(Time[i+1]);    // новый день
      new_Week=TimeDayOfWeek(Time[i])==1;                // новая неделя
      if(TimeMonth(Time[i]) != TimeMonth(Time[i+1])) new_Month=true; // новый месяц
      Ind_Buffer_0[i]=0;
      Ind_Buffer_1[i]=0;
      Ind_Buffer_2[i]=0;
      Ind_Buffer_3[i]=0;
      Ind_Buffer_4[i]=0;
      Ind_Buffer_5[i]=0;
      Ind_Buffer_6[i]=0;
      Ind_Buffer_7[i]=0;
      if(new_Hour && Period()<15 )              Ind_Buffer_0[i]=max;
      if(new_Day  && Period()<240)              Ind_Buffer_2[i]=max;
      if(new_Week && new_Day && Period()<1440)  Ind_Buffer_4[i]=max;
      if(new_Month && new_Day && new_Week)      {Ind_Buffer_6[i]=max; new_Month=false;}
     }// end for(i...
   Window_Max=WindowPriceMax();
   Window_Min=WindowPriceMin();  
   if((Window_Max!=old_Window_Max) || (Window_Min!=old_Window_Min)) SetGLine(); // отрисовка горизонтальных линий 
   return(0);
  }

// -------------- установка горизонтальных линий ---------------------------
// выполняется при изменении размеров окна (Window_Max или Window_Min)
void SetGLine()
   {
   double Uroven=0.0;               // уровень установки горизонтальной линии
   ObjectsDeleteAll(0,OBJ_HLINE);   // удаляем все горизонтальные линии
   int i=0;
   if(Шаг==0)  // 
      {
      Шаг=50;
      if(Digits==5)  Шаг=500;
      if(Digits==1)  Шаг=500;
      }
      old_Window_Min=Window_Min; 
      old_Window_Max=Window_Max; 
   while(Uroven<Window_Max) {
     i++;
     Uroven=i*Шаг*Point; 
     if(Uroven>=Window_Min) {
     if(MathMod(i,2)==0)   {
       LineColor=DodgerBlue;        // четная линия
       LineStile=STYLE_DASHDOTDOT;    
       Period_Ris=0x007F;           // отрисовка только на М1,М5,M15,M30 и H1
       }
     else {
       LineColor=DimGray;           // нечетная линия
       LineStile=STYLE_DASHDOTDOT;
       Period_Ris=0x001F;           // отрисовка только на М1,М5,M15,M30 и H1
     }  
     SetHLine(LineColor, "HLine_"+i, Uroven, LineStile,0,Period_Ris);
     }// end if(Uroven>Min)
   }// end while (Uroven<Max)
   flag=false;
  }//end установки горизонтальных линий
//+----------------------------------------------------------------------------+
//|  Автор    : Ким Игорь В. aka KimIV,  http://www.kimiv.ru                   |
//|  модификация: С.Привалов aka Prival                                        |
//+----------------------------------------------------------------------------+
//|  Версия   : 12.02.2009                                                     |
//|  Описание : Установка объекта OBJ_HLINE горизонтальная линия               |
//+----------------------------------------------------------------------------+
//|  Параметры:                                                                |
//|    cl - цвет линии                                                         |
//|    nm - наименование               ("" - время открытия текущего бара)     |
//|    p1 - ценовой уровень            (0  - Bid)                              |
//|    st - стиль линии                (0  - простая линия)                    |
//|    wd - ширина линии               (0  - по умолчанию)                     |
//|    pr - период отображения         (0  - по умолчанию -> на всех ТФ)       |
//+----------------------------------------------------------------------------+
void SetHLine(color cl, string nm="", double p1=0, int st=0, int wd=0, int pr=0) {
  if (nm=="") nm=DoubleToStr(Time[0], 0);
  if (p1<=0) p1=Bid;
  if (ObjectFind(nm)<0) ObjectCreate(nm, OBJ_HLINE, 0, 0,0); else Print("Ошибка");
  ObjectSet(nm, OBJPROP_PRICE1, p1);
  ObjectSet(nm, OBJPROP_COLOR , cl);
  ObjectSet(nm, OBJPROP_STYLE , st);
  ObjectSet(nm, OBJPROP_WIDTH , wd);
  ObjectSet(nm, OBJPROP_TIMEFRAMES , pr);
}

