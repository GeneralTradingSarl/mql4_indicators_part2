//+------------------------------------------------------------------+
//|                                                   Painter_v1.mq4 |
//|                        Copyright 2004, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//| For Heiken Ashi we recommend next chart settings ( press F8 or   |
//|    select on menu 'Charts'->'Properties...'):                    |
//|  - On 'Color' Tab select 'Black' for 'Line Graph'                |
//|  - On 'Common' Tab disable 'Chart on Foreground' checkbox and    |
//|    select 'Line Chart' radiobutton                               |
//+------------------------------------------------------------------+
#property copyright "Copyright 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Blue
#property indicator_color5 Lime
#property indicator_color6 Lime
#property indicator_color7 Lime
#property indicator_color8 Lime
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 3
#property indicator_width8 3
//----
extern int Hours_START=8;
extern int Hours_FINISH=18;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(3,ExtMapBuffer4);
//----
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexStyle(5,DRAW_HISTOGRAM);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexStyle(6,DRAW_HISTOGRAM);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexStyle(7,DRAW_HISTOGRAM);
   SetIndexBuffer(7,ExtMapBuffer8);
//----
   SetIndexDrawBegin(0,10);
   SetIndexDrawBegin(1,10);
   SetIndexDrawBegin(2,10);
   SetIndexDrawBegin(3,10);
   SetIndexDrawBegin(4,10);
   SetIndexDrawBegin(5,10);
   SetIndexDrawBegin(6,10);
   SetIndexDrawBegin(7,10);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
//----
   return(0);
  }
//THIS IS LEFT UNTOUCHES AS IN THE ORIGINAL INDICATOR  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double haOpen,haHigh,haLow,haClose;
   if(Bars<=10) return(0);

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int pos=Bars-counted_bars;
   if(counted_bars==0) pos-=1+1;

   while(pos>=0)
     {
      haOpen=(ExtMapBuffer3[pos+1]+ExtMapBuffer4[pos+1])/2;
      haClose=(Open[pos]+High[pos]+Low[pos]+Close[pos])/4;
      haHigh=MathMax(High[pos],MathMax(haOpen,haClose));
      haLow=MathMin(Low[pos],MathMin(haOpen,haClose));
      //----
      if(haOpen<haClose)
        {
         ExtMapBuffer1[pos]=haLow;
         ExtMapBuffer2[pos]=haHigh;
        }
      else
        {
         ExtMapBuffer1[pos]=haHigh;
         ExtMapBuffer2[pos]=haLow;
        }
      ExtMapBuffer3[pos]=haOpen;
      ExtMapBuffer4[pos]=haClose;
      //----
      bool withinPeriod=TimeHour(Time[pos])>=Hours_START && TimeHour(Time[pos])<Hours_FINISH;
      if(!withinPeriod)
        {
         ExtMapBuffer5[pos]=haHigh;
         ExtMapBuffer6[pos]=haLow;
         ExtMapBuffer7[pos]=MathMax(haOpen,haClose);
         ExtMapBuffer8[pos]=MathMin(haClose,haOpen);
        }
      pos--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
