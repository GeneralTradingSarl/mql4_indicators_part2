//+------------------------------------------------------------------+
//|                                                   Guppy Long.mq4 |
//|                                                           jnr314 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "jnr314"
#property link      "https://www.mql5.com"
#property version   "2.00"
#property strict
//---
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Lime
#property indicator_color2 Lime
#property indicator_color3 Lime
#property indicator_color4 Lime
#property indicator_color5 Lime
#property indicator_color6 Lime
//--- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
//--- input parameters
input int                 InpMAPeriod1=30;         // Period 1
input int                 InpMAPeriod2=35;         // Period 2
input int                 InpMAPeriod3=40;         // Period 3
input int                 InpMAPeriod4=45;         // Period 4
input int                 InpMAPeriod5=50;         // Period 5
input int                 InpMAPeriod6=60;         // Period 6
//---
input int                 InpMAShift1=0;            // Shift 1
input int                 InpMAShift2=0;            // Shift 2
input int                 InpMAShift3=0;            // Shift 3
input int                 InpMAShift4=0;            // Shift 4
input int                 InpMAShift5=0;            // Shift 5
input int                 InpMAShift6=0;            // Shift 6
//---
input ENUM_MA_METHOD      InpMAMethod=MODE_EMA;    // Method 
input ENUM_APPLIED_PRICE  InpMAPrice=0;            // Applied Price
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//--- indicator buffers mapping
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexShift(0,InpMAShift1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexShift(1,InpMAShift2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexShift(2,InpMAShift3);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexShift(3,InpMAShift4);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexShift(4,InpMAShift5);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexShift(5,InpMAShift6);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                            
//+------------------------------------------------------------------+
int deinit()
  {
    return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              
//+------------------------------------------------------------------+
int start()
  {
  int i,limit,counted_bars=IndicatorCounted();
//---
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---
     for(i=0; i<limit; i++)
     {
      ExtMapBuffer1[i]=iMA(NULL,0,InpMAPeriod1,0,InpMAMethod,InpMAPrice,i);
      ExtMapBuffer2[i]=iMA(NULL,0,InpMAPeriod2,0,InpMAMethod,InpMAPrice,i);
      ExtMapBuffer3[i]=iMA(NULL,0,InpMAPeriod3,0,InpMAMethod,InpMAPrice,i);
      ExtMapBuffer4[i]=iMA(NULL,0,InpMAPeriod4,0,InpMAMethod,InpMAPrice,i);
      ExtMapBuffer5[i]=iMA(NULL,0,InpMAPeriod5,0,InpMAMethod,InpMAPrice,i);
      ExtMapBuffer6[i]=iMA(NULL,0,InpMAPeriod6,0,InpMAMethod,InpMAPrice,i);
     }
   return(0);
  }
//+------------------------------------------------------------------+
