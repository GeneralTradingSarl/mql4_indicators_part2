//+------------------------------------------------------------------+
//|                                                          %BB.mq4 |
//|                                    Copyright ? 2008, Walter Choy |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright ? 2008, Walter Choy"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
#property indicator_level1 0
#property indicator_level2 50
#property indicator_level3 100

extern int    Bands_period = 20;
extern double Bands_deviation = 2;

//---- buffers
double PercentBB[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, PercentBB);
   SetIndexLabel(0, "%BB");
   SetIndexDrawBegin(0, Bands_period);
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
   if(counted_bars==0) limit--;
//----
   double LB, UB;
        
   for(int i = 0; i < limit; i++){
      LB = iBands(NULL, 0, Bands_period, Bands_deviation, 0, PRICE_CLOSE, MODE_LOWER, i);
      UB = iBands(NULL, 0, Bands_period, Bands_deviation, 0, PRICE_CLOSE, MODE_UPPER, i);
      PercentBB[i]=0;
      if (UB!=LB)
      PercentBB[i] = (iClose(NULL, 0, i) - LB)/(UB - LB) * 100;
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+