//+------------------------------------------------------------------+
//|                                                   Instrument.mq4 |
//|                                                      Denis Orlov |
//|                                    http://denis-or-love.narod.ru |
/*

Displaying of candles of any instrument, synchronisation on bars or on day
http://codebase.mql4.com/ru/6637

Отображение произвольного инструмента, синхронизация по барам или по дням.
http://codebase.mql4.com/ru/6638

Денис Орлов
http://denis-or-love.narod.ru

***
Все мои индикаторы:
http://codebase.mql4.com/ru/author/denis_orlov
***
ПОЛЬЗУЙТЕСЬ И ПРОЦВЕТАЙТЕ!

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

extern string Instrument="GBPUSD";
extern int TimeFrame=0;
extern bool DaySynch=false;
extern int HorizShift=0;
extern int History=1000;
extern color HandleColor=Red;
extern bool GoldColor=False;


double VertShift=0;
bool init_flag=false;
bool prepare_objects()
  {
if (init_flag) return(true);
    DrawText( Instrument+" "+PeriodToStr(TimeFrame)+" VertShift", 
    Time[0], Low[0]-30*Point, "", 71, HandleColor, 12,0) ;  
    init_flag=true;
  }
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
     
    if(DaySynch)HandleColor=CLR_NONE;

    init_flag=false; 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
    //if(UninitializeReason()!=REASON_CHARTCHANGE)
        // {
            ObjectDelete(Instrument+" "+PeriodToStr(TimeFrame)+" VertShift");

        // }
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
      //DrawText( Instrument+PeriodToStr(TimeFrame)+" VertShift", 
    //Time[0 ], High[0], "", 69, HandleColor, 12,0) ; 
    if (!init_flag) prepare_objects();
    
    int HandBar=iBarShift(NULL, 0, ObjectGet(Instrument+" "+PeriodToStr(TimeFrame)+" VertShift",OBJPROP_TIME1));
     double pVertShift=ObjectGet(Instrument+" "+PeriodToStr(TimeFrame)+" VertShift",OBJPROP_PRICE1)-iLow(Instrument, TimeFrame, HandBar);
     if(VertShift!=pVertShift)
      {
            VertShift=pVertShift;
           i=Bars-1;            
            if (History>0&&i>History)i=History;  
            
            //Print("ObjectGet="+ObjectGet(Instrument+PeriodToStr(TimeFrame)+" VertShift",OBJPROP_PRICE1));
           // Print("iHigh="+iHigh(Instrument, TimeFrame, WindowFirstVisibleBar()));
            //Print("pVertShift="+pVertShift);
            
            IndicatorShortName(Instrument+" "+PeriodToStr(TimeFrame)+": shift "+DoubleToStr(VertShift, Digits)); 
      }
     
      while(i>=0)                      // Цикл по непосчитанным барам     
      {
          if(DaySynch)
            {
               int firstBar=iBarShift(NULL, 0, StrToTime(TimeToStr(Time[i], TIME_DATE)+" 00:00"));
               VertShift=iLow(NULL, 0, firstBar)-iLow(Instrument, TimeFrame, firstBar); 
               
               //if(i==0) Alert(iLow(NULL, 1, firstBar)+" firstBar"+firstBar);
            }
          
            double
           H=iHigh(Instrument, TimeFrame,i),
           L=iLow(Instrument, TimeFrame,i),
           O=iOpen(Instrument,TimeFrame,i),
           C=iClose(Instrument, TimeFrame,i);
           
           if(C>O)
            {
               Line1[i]=C+VertShift*1.0; Line2[i]=O+VertShift*1.0;
               Line3[i]=H+VertShift*1.0; Line4[i]=L+VertShift*1.0; 
            }
            else
            if(C<O)
            {
               Line1[i]=C+VertShift*1.0; Line2[i]=O+VertShift*1.0;
               Line3[i]=L+VertShift*1.0; Line4[i]=H+VertShift*1.0; 
            }
            else
            if(C==O)
            {
               Line1[i]=O+VertShift*1.0; Line2[i]=Line1[i]+0.01*Point;
               Line3[i]=L+VertShift*1.0; Line4[i]=H+VertShift*1.0; 
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
int DrawText( string name, datetime T, double P, string Text, int code=0, color Clr=Green,  int Fsize=10, int Win=0)
   { 
      if (name=="") name="Text_"+T;
      
      int Error=ObjectFind(name);// Запрос 
   if (Error!=Win)// Если объекта в ук. окне нет :(
    { 
      ObjectCreate(name, OBJ_TEXT, Win, T, P);
      ObjectSet(name, OBJPROP_PRICE1, P);
      }
      
      ObjectSet(name, OBJPROP_TIME1, T);
      
      if(code==0)
      ObjectSetText(name, Text ,Fsize,"Arial",Clr);
      else
      ObjectSetText(name, CharToStr(code), Fsize,"Wingdings",Clr);
   }
///================================