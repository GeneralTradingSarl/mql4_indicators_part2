//+------------------------------------------------------------------+
//|                                           Intensivnost_Tikov.mq4 |
//|                                          Copyright © 2007, DRKNN |
//|                                                    drknn@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, DRKNN"
#property link      "drknn@mail.ru"

#property indicator_separate_window
#property indicator_buffers 3
//Цвет индикаторных линий
#property indicator_color1 ForestGreen
#property indicator_color2 Crimson
#property indicator_color3 Gray
//Толщина индикаторных линий
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
// --- Вспомогательные переменные ----------
int    TickCounter=0;//счётчик тиков
int myBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,ExtMapBuffer3);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){

   if(isNewBar()==true){//Появился новый бар
     if(Open[1]<Close[1]){//если бычья
      ExtMapBuffer1[1]=TickCounter;
      TickCounter=0;
     }
     if(Open[1]>Close[1]){//если медвежья
      ExtMapBuffer2[1]=TickCounter;
      TickCounter=0;
     }
     if(Open[1]==Close[1]){//если додж
      ExtMapBuffer3[1]=TickCounter;
      TickCounter=0;
     }
   }
   TickCounter++;//на каждом тике увеличиваем счётчик тиков

   return(0);
  }
//+------------------------------------------------------------------+


// ------- Пользовательские подпрограммы -------------------

//+------------------------------------------------------------------+
//| функция isNewBar() - возвращает признак нового бара              |
//+------------------------------------------------------------------+
bool isNewBar(){
  bool res=false;
  if(myBars!=Bars){
    res=true;
    myBars=Bars;
  }   
//----
   return(res);
  }
//---------------------------------------------------------------  