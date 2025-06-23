//+==================================================================+
//|                                                 Heiken AshiR.mq4 |
//|                      Copyright c 2004, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+==================================================================+
//| For Heiken Ashi we recommend next chart settings ( press F8 or   |
//| select on menu 'Charts'->'Properties...'):                       |
//|  - On 'Color' Tab select 'Black' for 'Line Graph'                |
//|  - On 'Common' Tab disable 'Chart on Foreground' checkbox and    |
//|    select 'Line Chart' radiobutton                               |
//+==================================================================+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 4 
//---- цвета индикатора 
#property indicator_color1 Red  
#property indicator_color2 LimeGreen 
#property indicator_color3 Red
#property indicator_color4 LimeGreen
//---- толщина индикаторных линий
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3 
#property indicator_width4 3
//---- индикаторные буфферы
double L_Buffer[];
double H_Buffer[];
double O_Buffer[];
double C_Buffer[];
//---- переменные с плавающей точкой  
double haOpen, haHigh, haLow, haClose;
//+==================================================================+
//| Heiken AshiR initialization function                             |
//+==================================================================+
int init()
  {
//---- стиль изображени€ индикатора
   SetIndexStyle(0,DRAW_HISTOGRAM,0);
   SetIndexStyle(1,DRAW_HISTOGRAM,0);
   SetIndexStyle(2,DRAW_HISTOGRAM,0);
   SetIndexStyle(3,DRAW_HISTOGRAM,0);
//---- установка номера бара, 
              //начина€ с которого будет отрисовыватьс€ индикатор  
   SetIndexDrawBegin(0,10);
   SetIndexDrawBegin(1,10);
   SetIndexDrawBegin(2,10);
   SetIndexDrawBegin(3,10);
//---- 4 индикаторных буффера использованы дл€ счЄта
   SetIndexBuffer(0,L_Buffer);
   SetIndexBuffer(1,H_Buffer);
   SetIndexBuffer(2,O_Buffer);
   SetIndexBuffer(3,C_Buffer);
//---- завершение инициализации
   return(0);
  }
//+==================================================================+
//| Heiken AshiiR teration function                                  |
//+==================================================================+
int start()
  {
if (Bars<=10) return(0);
//----+ ¬ведение целых переменных и получение уже подсчитанных баров
int bar,counted_bars=IndicatorCounted(); 
//---- проверка на возможные ошибки
if (counted_bars<0)return(-1);
//---- последний подсчитанный бар должен быть пересчитан 
if (counted_bars>0) counted_bars--;
//---- определение номера самого старого бара, 
            //начина€ с которого будет произедЄн пересчЄт новых баров
bar=Bars-counted_bars-1;
if (bar>Bars-2)bar=Bars-2;
//----
while(bar>=0)
     {
      haOpen=(O_Buffer[bar+1]+C_Buffer[bar+1])/2;
      haClose=(Open[bar]+High[bar]+Low[bar]+Close[bar])/4;
      haHigh=MathMax(High[bar], MathMax(haOpen, haClose));
      haLow=MathMin(Low[bar], MathMin(haOpen, haClose));
      if (haOpen<haClose) 
        {
         L_Buffer[bar]=haLow;
         H_Buffer[bar]=haHigh;
        } 
      else
        {
         L_Buffer[bar]=haHigh;
         H_Buffer[bar]=haLow;
        } 
      O_Buffer[bar]=haOpen;
      C_Buffer[bar]=haClose;
 	   bar--;
     }
//----
   return(0);
  }
//+-----------------------------------------------------------------+

