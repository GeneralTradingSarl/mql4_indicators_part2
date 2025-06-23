//+------------------------------------------------------------------+
//|                                             MMR_HighLowLines.mq4 |
//|                                    Copyright © 2010, EADeveloper |
//|                                                                  |
//+------------------------------------------------------------------+



#property copyright "Copyright © 2010, EADeveloper"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Lime
#property indicator_width1 1
#property indicator_color2 Red
#property indicator_width2 1
#property indicator_color3 Orange
#property indicator_width3 1
extern int BarsBack=12;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexLabel(0,"Last High");
   SetIndexLabel(1,"Last Low");
   SetIndexLabel(2,"Average");
   IndicatorShortName("MMR HighLow Lines"); 

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
   double h,l;
   int counted_bars=IndicatorCounted();
   int limit=Bars-counted_bars;
   
   for(int i=0; i<limit; i++)
   {
   double hh=High[iHighest(Symbol(),0,MODE_HIGH,BarsBack,i)];
   double ll=Low[iLowest(Symbol(),0,MODE_LOW,BarsBack,i)];
   double av=(hh+ll)/2;
   ExtMapBuffer1[i]=hh;
   ExtMapBuffer2[i]=ll; 
   ExtMapBuffer3[i]=av;
   }
   return(0);
  }
//+------------------------------------------------------------------+