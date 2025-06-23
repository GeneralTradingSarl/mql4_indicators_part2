//+------------------------------------------------------------------+
//|                                                  IndexDollar.mq4 |
//|                          Copyright © 2005, Zmiuka Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Zmiuka Software Corp."
//----
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DeepPink
//---- input parameters
extern double GBP0=1.9272;
extern double EUR0=1.3471;
extern double CHF0=1.1486;
extern double JPY0=103.78;
//---- buffers
double IndexBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,IndexBuffer);
   SetIndexEmptyValue(0,0);
   ArrayInitialize(IndexBuffer,0);
//---- name for DataWindow and indicator subwindow label
   short_name="Index =";
   IndicatorShortName(short_name);
   SetIndexDrawBegin(0,2);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int    i;
   double USD;
   double Data1,Data2,Data3,Data4;
   i=(3000-counted_bars)+1;
//----
   while(i>=0)
     {
      Data1=iClose("GBPUSD",NULL,i); if(Data1==0) {Print("Not enough history for GBPUSD!");break;}
      Data2=iClose("EURUSD",NULL,i); if(Data2==0) {Print("Not enough history for EURUSD!");break;}
      Data3=iClose("USDCHF",NULL,i); if(Data3==0) {Print("Not enough history for USDCHF!");break;}
      Data4=iClose("USDJPY",NULL,i); if(Data4==0) {Print("Not enough history for USDJPY!");break;}
      USD=(GBP0-Data1)*100000
          +((EUR0-Data2)*100000)
          +((Data3-CHF0)*100000/Data3)
          +((Data4-JPY0)*100000/Data4);
      IndexBuffer[i]=USD; Comment("IndexDollar");
      i--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+ 
