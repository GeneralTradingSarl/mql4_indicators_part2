//+------------------------------------------------------------------+
//|                                                  ImpulseOsMA.mq4 |
//|                                              Дзенчарский Николай |
//|                                               dzenchar@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Дзенчарский Николай"
#property link      "dzenchar@gmail.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 LimeGreen
#property indicator_color5 DeepSkyBlue
//---- input parameters
extern int       FastEMA=12;
extern int       SlowEMA=26;
extern int       SignalEMA=9;
extern int       MAPeriod=12;
extern int       MAMode=0;
/* Какой метод MA использовать: 0 - SMA, 1 - EMA*/
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexBuffer(4,ExtMapBuffer5);

   IndicatorShortName("ImpulseOsMA ("+FastEMA+","+SlowEMA+","+SignalEMA+","+MAPeriod+","+MAMode+")");
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
   int i;
   int bCount;
   double cur,prev,curMA,prevMA;
//----
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   bCount=Bars-counted_bars;
   if(counted_bars==0) bCount-=2;

   for(i=0; i<bCount; i++)
      ExtMapBuffer1[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
   for(i=0; i<bCount; i++)
      ExtMapBuffer2[i]=iMAOnArray(ExtMapBuffer1,Bars,SignalEMA,0,MODE_EMA,i);
   for(i=0; i<bCount; i++)
     {
      cur=ExtMapBuffer1[i]-ExtMapBuffer2[i];
      prev=ExtMapBuffer1[i+1]-ExtMapBuffer2[i+1];
      if(MAMode==0)
        {
         curMA=iMA(NULL,0,MAPeriod,0,MODE_SMA,PRICE_CLOSE,i);
         prevMA=iMA(NULL,0,MAPeriod,0,MODE_SMA,PRICE_CLOSE,i+1);
        }
      if(MAMode==1)
        {
         curMA=iMA(NULL,0,MAPeriod,0,MODE_EMA,PRICE_CLOSE,i);
         prevMA=iMA(NULL,0,MAPeriod,0,MODE_EMA,PRICE_CLOSE,i+1);
        }
      if(cur>prev && curMA>prevMA)
        {
         ExtMapBuffer3[i]=0;
         ExtMapBuffer4[i]=cur*3;
         ExtMapBuffer5[i]=0;
        }
      else if(cur<prev && curMA<prevMA)
        {
         ExtMapBuffer3[i]=cur*3;
         ExtMapBuffer4[i]=0;
         ExtMapBuffer5[i]=0;
        }
      else if((cur-prev)*(curMA-prevMA)<=0)
        {
         ExtMapBuffer3[i]=0;
         ExtMapBuffer4[i]=0;
         ExtMapBuffer5[i]=cur*3;
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
