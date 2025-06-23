//+------------------------------------------------------------------+
//|                                                        Trend.mq4 |
//|                                                     Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"

#property indicator_separate_window
#property indicator_minimum -25
#property indicator_maximum 25
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_level7 -15
#property indicator_level8 15

//---- input parameters
extern int       Rasrad=16;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_HISTOGRAM);

   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);

   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
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
   int rasr,i,a,k;
   double price;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+MathMax(1,Rasrad);

   rasr=Rasrad;
   i=limit;
   while(i>=0)
     {
      rasr=Rasrad;
      price=High[i];
      if(price>High[i+1])
        {
         k=1;
         while(price>High[i+k])
           {
            k=k+1;
            if(k>rasr){break;}
           }
         ExtMapBuffer1[i]=k-1;
        }
      else{ExtMapBuffer1[i]=0;}

      rasr=Rasrad;
      price=Low[i];

      if(price<Low[i+1])
        {
         k=1;
         while(price<Low[i+k])
           {
            k=k+1;
            if(k>rasr){break;}
           }
         a=k-1;
         ExtMapBuffer2[i]=-a;
        }
      else{ExtMapBuffer2[i]=0;}

      i--;
     }

//----
   return(0);
  }
//+------------------------------------------------------------------+
