//+------------------------------------------------------------------+
//|                                                    NR4ID-ATR.mq4 |
//|                                                             Rosh |
//|                                    http://forexsystems.ru/phpBB/ |
//+------------------------------------------------------------------+
#property copyright "Rosh"
#property link      "http://forexsystems.ru/phpBB/"
//----
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- input parameters
extern int       PerATR=1;
extern int       PerNR=4;
//---- buffers
double ExtMapBuffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,108);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
   int limit;
   double tempval,minATR,currATR;
   int counted_bars=IndicatorCounted();
//---- 
   if (counted_bars==0) limit=Bars-MathMax(PerNR,PerATR);
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) limit=Bars-counted_bars;
   limit--;
//---- main loop
   for(int i=limit; i>=0; i--)
     {
      tempval=0.0;
      if ((High[i]<High[i+1])&&(Low[i]>Low[i+1]))
        {
         minATR=iATR(NULL,0,PerATR,i);
         for(int cnt=i+1;cnt<i+PerNR;cnt++)
           {
            currATR=iATR(NULL,0,PerATR,cnt);
            if (currATR<minATR) minATR=currATR;
           }
         if (minATR==iATR(NULL,0,PerATR,i))   tempval=(High[i]+Low[i])/2;
        }
      ExtMapBuffer1[i]= tempval;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+