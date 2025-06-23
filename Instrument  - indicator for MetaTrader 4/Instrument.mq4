//+------------------------------------------------------------------+
//|                                                   Instrument.mq4 |
//|                                                      Denis Orlov |
//|                                    http://denis-or-love.narod.ru |
/*

Денис Орлов
http://denis-or-love.narod.ru

***
Все мои индикаторы:
http://codebase.mql4.com/ru/author/denis_orlov
***
ПОЛЬЗУЙТЕСЬ И ПРОЦВЕТАЙТЕ!

Sorry for my English!)

Denis Orlov
http://denis-or-love.narod.ru
***
All my indicators:

http://codebase.mql4.com/author/denis_orlov

*/
//+------------------------------------------------------------------+
#property copyright "Denis Orlov"
#property link      "http://denis-or-love.narod.ru"

#property indicator_chart_window
#property indicator_buffers 4

#property indicator_color1 DarkTurquoise
#property indicator_color2 DarkBlue
#property indicator_color3 DarkTurquoise
#property indicator_color4 DarkBlue

double Line1[], Line2[], Line3[], Line4[];

extern string Instrument="";
extern int TimeFrame=0;
extern int VertShift=0;
extern int HorizShift=0;
extern int History=1000;
extern bool GoldColor=False;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM,0,3);
   SetIndexBuffer(0,Line1);
   SetIndexShift( 0, HorizShift); 
     
   SetIndexStyle(1,DRAW_HISTOGRAM,0,3);
   SetIndexBuffer(1,Line2);  
   SetIndexShift( 1, HorizShift);
   
   SetIndexStyle(2,DRAW_HISTOGRAM,0,1);
   SetIndexBuffer(2,Line3);
   SetIndexShift( 2, HorizShift);
   
   SetIndexStyle(3,DRAW_HISTOGRAM,0,1);
   SetIndexBuffer(3,Line4);
   SetIndexShift( 3, HorizShift);
   
      if(GoldColor)
      {
         SetIndexStyle(0,DRAW_HISTOGRAM,0,3,Yellow);
         SetIndexStyle(1,DRAW_HISTOGRAM,0,3,Orange);
         SetIndexStyle(2,DRAW_HISTOGRAM,0,1,Yellow);
         SetIndexStyle(3,DRAW_HISTOGRAM,0,1,Orange);
      }
      
    if (Instrument=="") Instrument=Symbol();
    if (TimeFrame==0) TimeFrame=Period();
    IndicatorShortName(Instrument+" "+PeriodToStr(TimeFrame)+": shift "+VertShift);  
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
int start()
  {
      int    Counted_bars=IndicatorCounted();
//----
      int      i=Bars-Counted_bars-1;           // Индекс первого непосчитанного  
     if (History>0&&i>History)                 // Если много баров то ..      
       i=History; 
       
      while(i>=0)                      // Цикл по непосчитанным барам     
      {
      
             double
           H=iHigh(Instrument, TimeFrame,i),
           L=iLow(Instrument, TimeFrame,i),
           O=iOpen(Instrument,TimeFrame,i),
           C=iClose(Instrument, TimeFrame,i);
           
           if(C>O)
            {
               Line1[i]=C+VertShift*Point; Line2[i]=O+VertShift*Point;
               Line3[i]=H+VertShift*Point; Line4[i]=L+VertShift*Point; 
            }
            else
            if(C<O)
            {
               Line1[i]=C+VertShift*Point; Line2[i]=O+VertShift*Point;
               Line3[i]=L+VertShift*Point; Line4[i]=H+VertShift*Point; 
            }
            else
            if(C==O)
            {
               Line1[i]=O+VertShift*Point; Line2[i]=Line1[i]+0.01*Point;
               Line3[i]=L+VertShift*Point; Line4[i]=H+VertShift*Point; 
            }
      
      
      i--;
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+
string PeriodToStr(int Per)
   {
      switch(Per)                 // Расчёт коэффициентов для..     
      {                              // .. различных ТФ      
      case     1: return("M1");  // Таймфрейм М1      
      case     5: return("M5");  // Таймфрейм М5      
      case    15: return("M15");  // Таймфрейм М15      
      case    30: return("M30");  // Таймфрейм М30      
      case    60: return("H1");  // Таймфрейм H1      
      case   240: return("H4");  // Таймфрейм H4      
      case  1440: return("D1");  // Таймфрейм D1      
      case 10080: return("W1");  // Таймфрейм W1      
      case 43200: return("МN");  // Таймфрейм МN     
      }
   }
///=======================