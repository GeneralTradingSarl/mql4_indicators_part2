//+------------------------------------------------------------------+ 
//| PChannel_m.mq4                                                   | 
//+------------------------------------------------------------------+ 
#property indicator_chart_window  
#property indicator_buffers 3  
#property indicator_color1 DodgerBlue  
#property indicator_color2 DodgerBlue  
#property indicator_color3 DodgerBlue  
//---- input parameters  
extern int Range=14;  
//---- buffers 
double UpBuffer[]; 
double DnBuffer[];  
double MdBuffer[]; 
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function | 
//+------------------------------------------------------------------+ 
int init() 
  {
   string short_name; 
//---- indicator line 
   SetIndexStyle(0,DRAW_LINE,1,2); //установка стиля для первого значения индикатора 
   SetIndexStyle(1,DRAW_LINE,1,2); //установка стиля для второго значения индикатора 
   SetIndexStyle(2,DRAW_LINE,2); //установка стиля для третьего значения индикатора 
   SetIndexBuffer(0,UpBuffer); //значение записываемое в 0 буфер равно переменной UpBuffer 
   SetIndexBuffer(1,DnBuffer); //значение записываемое в 1 буфер равно переменной DnBuffer 
   SetIndexBuffer(2,MdBuffer); //значение записываемое в 2 буфер равно переменной MdBuffer 
//---- name for DataWindow and indicator subwindow label 
   short_name="PriceChannel("+Range+")"; //переменной short_name присваиваем строковое 
   //значение равное выражению 
   IndicatorShortName(short_name); //для отображения на графике присвоим индикатору краткое 
   //наименование 
   SetIndexLabel(0,"Up Channel"); //для отображения на графике присвоим метке отображающей 
   //значения 0 буфера имя Up Channel 
   SetIndexLabel(1,"Down Channel"); //для отображения на графике присвоим метке отображающей 
   //значения 1 буфера имя Down Channel 
   SetIndexLabel(2,"Middle Channel"); //для отображения на графике присвоим метке отображающей 
   //значения 2 буфера имя Middle Channel 
//---- 
   SetIndexDrawBegin(0,0); //установка начальной точки прорисовки для 0 буфера 
   SetIndexDrawBegin(1,0); //установка начальной точки прорисовки для 1 буфера 
   SetIndexDrawBegin(2,0); //установка начальной точки прорисовки для 2 буфера 
//---- 
   return(0); //возврат из секции инициализации 
  }
//+------------------------------------------------------------------+ 
//| PriceChannel                                                     | 
//+------------------------------------------------------------------+ 

int start() //начало программы (расчета) 
  {
   int i; //объявление целочисленной переменной i,k,sch 
//---- 
   for(i=Bars-1;i>=0;i--)
     {
      UpBuffer[i]=High[Highest(NULL,0,MODE_HIGH,Range,i)];
      DnBuffer[i]=Low[Lowest(NULL,0,MODE_LOW,Range,i)];
      MdBuffer[i]=(UpBuffer[i]+DnBuffer[i])/2;
     }
   return(0);
  }
//+------------------------------------------------------------------+