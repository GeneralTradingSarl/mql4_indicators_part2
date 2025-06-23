//+******************************************************************+
//|                                              i-DivergenceBar.mq4 |
//|                      Copyright © 2010, Dmitry Zhebrak aka Necron |
//|                                                  www.mqlcoder.ru |
//+------------------------------------------------------------------+
//|Данный продукт предназначен для некомерческого                    |
//|использования. Публикация разрешена только при указании имени     |
//|автора ( Necron ). Редактирование исходного разрешается только при|
//|условии сохранения данного текста, ссылок и имени автора. Продажа |
//|индикатора или отдельных его частей ЗАПРЕЩЕНА.                    |
//|Автор не несет ответственности за возможные убытки, полученные в  |
//|результате использования индикатора.                              |
//|По всем вопросам, связанными с работой индикатора или             |
//|или предложениями по его доработке обращаться на email:           |
//|mqlcoder@yandex.ru                                                |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, D.Zhebrak aka Necron"
#property link      "www.mqlcoder.ru"
#property link      "mailto: mqlcoder@yandex.ru"
//---
#define   version   "1.0.0.0"
//---- подключаем ядро системы Profitunity_MT4
//---- настройки цветов для отображения
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Lime
#property indicator_color4 Lime
//---- внешние настройки индикатора
extern int     BarsToProcess=200;   //максимальное колличество баров для расчета (-1 все)
extern int width=2;                 //толщина отображения тела развротного бара 
//---- буферы для отображения индикатора
double   UpBuffer1[],
         DnBuffer1[],
         UpBuffer2[],
         DnBuffer2[];
//+------------------------------------------------------------------+
//| Инциализация индикатора                                          |
//+------------------------------------------------------------------+
int init()
  {
//---- начало инциализации индикатора  
//---- связываем массив с буфером индикатора   
   SetIndexBuffer(0,UpBuffer1);
   SetIndexBuffer(1,DnBuffer1);
   SetIndexBuffer(2,UpBuffer2);
   SetIndexBuffer(3,DnBuffer2);
//---- установим стиль отображения линий
   SetIndexStyle(0,DRAW_HISTOGRAM,0,width);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,width);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,width);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,width);
//---- установим короткое имя индикатора и каждой линии в отдельности
   IndicatorShortName("i-DiverBar");
   SetIndexLabel(0,NULL);
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
   SetIndexLabel(4,NULL);
   SetIndexLabel(5,NULL);
//---- инициализация завершена
   return(0);
  }
//+------------------------------------------------------------------+
//| Деинициализация индикатора                                       |
//+------------------------------------------------------------------+   
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+ 
//| Расчет индикатора                                                | 
//+------------------------------------------------------------------+   
int start()
  {
   int  i,counted_bars=IndicatorCounted(),limit;
   double lips,teeth,jaw,up,dn;
//---- проверка на возможные ошибки
   if(counted_bars<0) return(-1);
//---- проверка наличия истории  
   if(iBars(Symbol(),Period())<14)
     {
      Print("Недостаточно баров для расчета индикатора!");
      return(-1);
     }
//---- найдем количество баров для расчета индикатора    
   limit=Bars-counted_bars-1;
   if(Bars-counted_bars>2) limit=Bars-35;
   if(limit>BarsToProcess && BarsToProcess>0) limit=BarsToProcess;
//---- отобразим индикатор 
   for(i=limit;i>=0;i--)
     {
      UpBuffer1[i] =EMPTY;
      UpBuffer2[i] =EMPTY;
      //---
      DnBuffer1[i] =EMPTY;
      DnBuffer2[i] =EMPTY;
      //---
      lips=iAlligator(Symbol(),Period(),13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,i);
      teeth=iAlligator(Symbol(),Period(),13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,i);
      jaw=iAlligator(Symbol(),Period(),13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,i);
      //---
      up=MathMax(lips,MathMax(teeth,jaw));
      dn=MathMin(lips,MathMin(teeth,jaw));
      //---
      if(High[i]>High[i+1] && Close[i]<High[i]-0.5*(High[i]-Low[i]) && Low[i]>up)
        {
         UpBuffer1[i] = Low[i]+(High[i]-Low[i])/2+(High[i]-Low[i])/10;
         DnBuffer1[i] = Low[i]+(High[i]-Low[i])/2-(High[i]-Low[i])/10;
        }
      else
      if(Low[i]<Low[i+1] && Close[i]>Low[i]+0.5*(High[i]-Low[i]) && High[i]<dn)
        {
         UpBuffer2[i] = Low[i]+(High[i]-Low[i])/2+(High[i]-Low[i])/10;
         DnBuffer2[i] = Low[i]+(High[i]-Low[i])/2-(High[i]-Low[i])/10;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
