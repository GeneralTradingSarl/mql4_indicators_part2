//+------------------------------------------------------------------+
//|                                                        crash.mq4 |
//|                                                    Ramin Rostami |
//|                                            saharramin2@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Dr Ramin Rostami"
#property link      "saharramin2@yahoo.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red

double buffer1[];
double buffer2[];
extern int       barsToProcess=1000;
extern string    Comment1="Alert when 2candel size be more than";
extern double    candelsize=200;
#property indicator_level1  200
#property indicator_level2  0
#property indicator_level3  -200
#property indicator_levelcolor DarkSlateGray
#property indicator_levelstyle 2
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2,Lime);
   SetIndexBuffer(0,buffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2,Red);
   SetIndexBuffer(1,buffer2);
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
   int i=0;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+1;

   //if(limit>barsToProcess) limit=barsToProcess;

   while(i<limit)
     {
      double k=(High[i]-Low[i+1])/Point;
      if(k>0) buffer1[i]=k;
      double k2=(Low[i]-High[i+1])/Point;
      if(k2<0) buffer2[i]=k2;
      i++;
     }
   if(k>candelsize)
     {
      Alert("BUY PUSH...",k,Symbol(),GetLastError());
      Sleep(100);
     }
   if(-(k2)>candelsize)
     {
      Alert("SELL PUSH...",k,Symbol(),GetLastError());
      Sleep(100);
     }

   return(0);
  }
//+------------------------------------------------------------------+
