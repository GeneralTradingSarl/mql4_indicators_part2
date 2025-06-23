//+------------------------------------------------------------------+
//|                        Karacatica                                |
//|                        ִלטענטי                                   |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
//----
extern int       iPeriod=70;
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,241);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,242);
   SetIndexBuffer(1,ExtMapBuffer2);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+MathMax(1,iPeriod);

   static int ltr;
   for(int i=limit-1;i>=0;i--)
     {
      if(ExtMapBuffer1[i+1]!=0 && ExtMapBuffer1[i+1]!=EMPTY_VALUE)ltr=1;
      if(ExtMapBuffer2[i+1]!=0 && ExtMapBuffer2[i+1]!=EMPTY_VALUE)ltr=2;
      double pdi=iADX(NULL,0,iPeriod,0,MODE_PLUSDI,i);
      double mdi=iADX(NULL,0,iPeriod,0,MODE_MINUSDI,i);
      ExtMapBuffer1[i]=EMPTY_VALUE;
      ExtMapBuffer2[i]=EMPTY_VALUE;
      if(Close[i]>Close[i+iPeriod] && pdi>mdi && ltr!=1)ExtMapBuffer1[i]=Low[i]-Point*5;
      if(Close[i]<Close[i+iPeriod] && pdi<mdi && ltr!=2)ExtMapBuffer2[i]=High[i]+Point*5;
     }
//-----
   return(0);
  }
//+------------------------------------------------------------------+
