//+------------------------------------------------------------------+ 
//|                                                          HVR.mq4 | 
//|      Copyright © 2005, Albert,(idea and code into MQL2 - podval) | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property indicator_separate_window
//----
#property indicator_minimum 0
#property indicator_maximum 3
#property indicator_buffers 3
//----
#property indicator_color1 Red
#property indicator_color2 Red
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  hv6=0,
   hv100=0,
   len=150,
   prevBars=0,
   mean6=0,
   mean100=0;
//----   
int    shift=0, i=0;
double
   x6[6],
   x100[100];
//---- buffers 
double HVRBuffer[];
double ExtMapBuffer[];
int ExtCountedBars=0;
int Barsi=1000;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int init()
  {
//---- 2 additional buffers are used for counting. 
   IndicatorBuffers(2);
   SetIndexBuffer(0,HVRBuffer);
//---- indicator line 
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
//---- name for DataWindow and indicator subwindow label 
   IndicatorShortName("HVR");
   SetIndexLabel(0,"HVR");
//---- 
//---- 
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if (prevBars==Barsi) return(0);
   prevBars=Barsi;
   for(shift=0; shift<=Barsi-1-len; shift++)
     {
      for(i =0; i<=5; i++)
        {
         x6[i]= MathLog(Close[shift+i]/Close[shift+i+1]);
        }
      for(i=0; i<=99; i++)
        {
         x100[i]=MathLog(Close[shift+i]/Close[shift+i+1]);
        }
      mean6=0;
      for(i =0; i<=5; i++)
        {
         mean6=mean6 + x6[i];
        }
      mean6=mean6/6;
      mean100=0;
      for(i=0; i<=99; i++)
        {
         mean100=mean100 + x100[i];
        }
      mean100=mean100/100;
      hv6=0;
      for(i =0; i<=5; i++)
        {
         hv6=hv6 + (x6[i] - mean6)*(x6[i] - mean6);
        }
      hv6=MathSqrt(hv6/5)*7.211102550927978586238442534941;
      hv100=0;
      for(i=0; i<=99; i++)
         hv100=hv100 + (x100[i] - mean100)*(x100[i] - mean100);
      hv100=MathSqrt(hv100/99)*7.211102550927978586238442534941;
      HVRBuffer[shift]= hv6/hv100;
     }
  }
//+------------------------------------------------------------------+