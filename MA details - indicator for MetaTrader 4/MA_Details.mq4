//+------------------------------------------------------------------+
//|                                        Custom Moving Average.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_chart_window
#property indicator_buffers 1
//#property indicator_color1 Red
//---- indicator parameters
extern int MA_Period=13;
extern int MA_Shift=0;
extern int MA_Method=0;
extern int MA_Applied=0;
extern int Fontsize=10;
extern color Color_1 = Red;

//---- indicator buffers
double ExtMapBuffer[];
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   int    draw_begin;
   string short_name;
   SetIndexStyle(0,DRAW_LINE,EMPTY,EMPTY,Color_1);
   SetIndexShift(0,MA_Shift);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   if(MA_Period<2) MA_Period=13;
   draw_begin=MA_Period-1;
   
   switch(MA_Method)
   {
      case 1 : short_name="EMA(";  draw_begin=0; break;
      case 2 : short_name="SMMA("; break;
      case 3 : short_name="LWMA("; break;
      default :
         MA_Method=0;
         short_name="SMA(";
   }
   IndicatorShortName(short_name+MA_Period+")");
   SetIndexDrawBegin(0,draw_begin);
   SetIndexBuffer(0,ExtMapBuffer);
   return(0);
  }

int start()
 {
   int limit;
  string short_name;
   int counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   for(int i=0; i<limit; i++)
      ExtMapBuffer[i]=iMA(NULL,0,MA_Period,MA_Shift,MA_Method,MA_Applied,i);
    
   switch(MA_Method)
     {
      case 0 : short_name="SMA(";  break;
      case 1 : short_name="EMA(";  break;
      case 2 : short_name="SMMA("; break;
      case 3 : short_name="LWMA(";
     }   
       
double ma_1;
ma_1=iMA(0,0,MA_Period,MA_Shift,MA_Method,MA_Applied,0);
 
   ObjectDelete("MA"+MA_Period);
   ObjectCreate("MA"+MA_Period ,OBJ_TEXT, 0, Time[0], ma_1+0.0010); 
   ObjectSetText("MA"+MA_Period,"                                     "+short_name+ MA_Period+") "+GetMethodText(MA_Applied)+"  "+ (DoubleToStr(ma_1,Digits)) ,Fontsize, "MS Sans Serif", Color_1);  

 
   return(0);
}

string GetMethodText(int MA_Applied)
 {
 switch(MA_Applied)  
   {case 0: return("C"); break;    // Close
    case 1: return("O"); break;    // Open
    case 2: return("H"); break;    // High
    case 3: return("L"); break; }  // Low
  }