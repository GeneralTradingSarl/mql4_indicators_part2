//+------------------------------------------------------------------+
//|                            MTF_ChandelierStops_60min.mq4         |
//|                            by Zathar                             |
//+------------------------------------------------------------------+
#property indicator_chart_window
//----
#property indicator_buffers 2
#property indicator_color1 Orchid
#property indicator_color2 LightSkyBlue
#property indicator_width1 3
#property indicator_width2 3
//----
int TimeFrame=PERIOD_H1;
double ExtMapBuffer1[];
double ExtMapBuffer2[];
datetime TimeArray[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(1,DRAW_LINE);
   IndicatorShortName("MTF_Chandelier(14)_m60");
   SetIndexLabel(0,"Up");
   SetIndexLabel(1,"Dn");
   return(0);
  }
//----  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    i,shift,limit,y=0;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit--;
//----
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
   for(i=0,y=0;i<limit;i++)
     {
      if(y<ArraySize(TimeArray)){ if(Time[i]<TimeArray[y]) {y++;}}
      ExtMapBuffer1[i]=iCustom(NULL,TimeFrame,"ChandelierStops_v1",1,y);
      ExtMapBuffer2[i]=iCustom(NULL,TimeFrame,"ChandelierStops_v1",0,y);
     }
   return(0);
  }
//+------------------------------------------------------------------+
