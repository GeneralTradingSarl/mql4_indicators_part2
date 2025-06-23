//+------------------------------------------------------------------+
//|                                       Ind_VilkaFractals_v1.2.mq4 |
//|                      Copyright © 2009, Alexey Sleptsov (lekhach) |
//|                                             lekhach18@rambler.ru |
//+------------------------------------------------------------------+
// Индикатор работает по стратегии "Вилка Чувашова".
// Версия 1.2:
// 1. Добавлена функция удаления объектов при выгрузке индикатора.
// 2. Удалены лишние строки из кода.
// 3. Переделан Alert.
// 4. Добавлен FractalsTrue.
//--------------------------------------------------------------------
#property copyright "lekhach © 2009"
#property link      "lekhach18@rambler.ru"
//--------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 1
#property indicator_width2 1
//---- input parameters
extern int   Lines=20;           // Количество видимых/невидимых фрактальных линий
extern bool  FractalsTrue=true;  // Вкл/выкл значков фракталов
extern bool  AlertTrue=true;     // Вкл/выкл сигнала
extern color LinesColorUp=Blue;  // Цвет верхних фрактальных линий
extern color LinesColorDown=Red; // Цвет нижних фрактальных линий
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//--- my variables
int Up=0;
int BufUp=0;
int Down=0;
int BufDown=0;
double BufPriceUp[100000];
double BufDateUp[100000];
double BufPriceDown[100000];
double BufDateDown[100000];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,217);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,218);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(1,0.0);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Fractals");
   SetIndexLabel(0,"FractalsUp");
   SetIndexLabel(1,"FractalsDown");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for (int j=0; j<100000; j++)
     {
      ObjectDelete("LineUp"+j);
      ObjectDelete("LineDown"+j);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   //int counted_bars=IndicatorCounted();
   //int limit;
//---- Последний посчитанный бар будет пересчитан
   //if (counted_bars>0) counted_bars--;
   //limit=Bars-counted_bars;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit--;   
   
//---- Основной цикл
   for (int i=limit; i>2; i--)
     {
      if (FractalsTrue==true)
        {
         ExtMapBuffer1[i]=iFractals(NULL,0,MODE_UPPER,i);
         ExtMapBuffer2[i]=iFractals(NULL,0,MODE_LOWER,i);
        } 
//---- Блок Up-фракталов
      if (iFractals(NULL,0,MODE_UPPER,i)!=0)
        {
         Up++;
         BufPriceUp[Up]=iFractals(NULL,0,MODE_UPPER,i);
         BufDateUp[Up]=Time[i];
         if (Up>2 && Up-BufUp>1 && BufPriceUp[Up]<BufPriceUp[Up-1] && BufPriceUp[Up-1]<BufPriceUp[Up-2])
           {
            BufUp=Up;
            ObjectCreate("LineUp"+(Up-1),OBJ_TREND,0,BufDateUp[Up-1],BufPriceUp[Up-1],BufDateUp[Up],BufPriceUp[Up]);
            ObjectCreate("LineUp"+Up,OBJ_TREND,0,BufDateUp[Up-2],BufPriceUp[Up-2],BufDateUp[Up-1],BufPriceUp[Up-1]);
            if (ObjectGetValueByShift("LineUp"+Up,i-1)>ObjectGetValueByShift("LineUp"+(Up-1),i-1))
              {
               ObjectDelete("LineUp"+Up);
               ObjectDelete("LineUp"+(Up-1));
              }
              else if (AlertTrue==true) Alert(Symbol(),Period()," Низходящая вилка! ",TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
           } 
         ObjectSet("LineUp"+(Up-1),OBJPROP_COLOR,LinesColorUp);
         ObjectSet("LineUp"+(Up-1),OBJPROP_WIDTH,2);
         ObjectSet("LineUp"+(Up-1),OBJPROP_RAY,True);
         ObjectSet("LineUp"+Up,OBJPROP_COLOR,LinesColorUp);
         ObjectSet("LineUp"+Up,OBJPROP_WIDTH,2);
         ObjectSet("LineUp"+Up,OBJPROP_RAY,True);         
         if (Up>Lines+1) ObjectDelete("LineUp"+(Up-Lines-1));
        }
//---- Блок Down-фракталов
      if (iFractals(NULL,0,MODE_LOWER,i)!=0)
        {
         Down++;
         BufPriceDown[Down]=iFractals(NULL,0,MODE_LOWER,i);
         BufDateDown[Down]=Time[i];
         if (Down>2 && Down-BufDown>1 && BufPriceDown[Down]>BufPriceDown[Down-1] && BufPriceDown[Down-1]>BufPriceDown[Down-2])
           {
            BufDown=Down;
            ObjectCreate("LineDown"+(Down-1),OBJ_TREND,0,BufDateDown[Down-1],BufPriceDown[Down-1],BufDateDown[Down],BufPriceDown[Down]);
            ObjectCreate("LineDown"+Down,OBJ_TREND,0,BufDateDown[Down-2],BufPriceDown[Down-2],BufDateDown[Down-1],BufPriceDown[Down-1]);
            if (ObjectGetValueByShift("LineDown"+Down,i-1)<ObjectGetValueByShift("LineDown"+(Down-1),i-1))
              {
               ObjectDelete("LineDown"+Down);
               ObjectDelete("LineDown"+(Down-1));
              } 
              else if (AlertTrue==true) Alert(Symbol(),Period()," Восходящая вилка! ",TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
           } 
         ObjectSet("LineDown"+(Down-1),OBJPROP_COLOR,LinesColorDown);
         ObjectSet("LineDown"+(Down-1),OBJPROP_WIDTH,2);
         ObjectSet("LineDown"+(Down-1),OBJPROP_RAY,True);
         ObjectSet("LineDown"+Down,OBJPROP_COLOR,LinesColorDown);
         ObjectSet("LineDown"+Down,OBJPROP_WIDTH,2);
         ObjectSet("LineDown"+Down,OBJPROP_RAY,True);
         if (Down>Lines+1) ObjectDelete("LineDown"+(Down-Lines-1));
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+