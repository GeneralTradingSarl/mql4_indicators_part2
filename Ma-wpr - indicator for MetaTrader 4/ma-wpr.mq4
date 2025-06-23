//+------------------------------------------------------------------+
//|                                                        tsf-2.mq4 |
//|                                Copyright © 2008, MOHAmad.Rahimi. |
//|                                           http://a162.blogfa.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MOHAmad.Rahimi."
#property link      "http://a162.blogfa.com"
//----
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_width1 2
//---- input parameters
extern int       WPR=39;
extern int       Moving=10;
//---- buffers
double ExtMapBuffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
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
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+Moving;
   //----
   while(limit>0)
     {
      double sum=0,ma= 0;
      for(int j=0;j<Moving;j++)
      { sum=sum+ iWPR(NULL,0,WPR,limit+j);}
      ma=sum/Moving;
//----
      ExtMapBuffer1[limit]=ma;
      Comment(ma);
      limit--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+