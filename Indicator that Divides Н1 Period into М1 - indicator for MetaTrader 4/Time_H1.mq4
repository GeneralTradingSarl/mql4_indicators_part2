//+------------------------------------------------------------------+
//|                                                      Time_H1.mq4 |
//|                                                     Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"

#property indicator_chart_window
extern int       barsToProcess=24;
extern color     colir = Gray;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   int i;
  
  
  
   for (i=0;i<Bars;i++)
    {
    ObjectDelete("Line "+DoubleToStr(i,0));
    }   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted(),
//----
   limit,
   i=0; 
   if(counted_bars>0)
      counted_bars--;
   
   limit=Bars-counted_bars;
   
   if(limit>barsToProcess)
      limit=barsToProcess;

   while (i<limit)
   {           
      datetime t = iTime(NULL,PERIOD_H1,i);
      if (t>0)
       {
        ObjectCreate("Line "+DoubleToStr(i,0),OBJ_VLINE,0,t,0);
        ObjectSet("Line "+DoubleToStr(i,0),OBJPROP_STYLE,STYLE_DASHDOTDOT);
        ObjectSet("Line "+DoubleToStr(i,0),OBJPROP_COLOR,colir);
        ObjectSet("Line "+DoubleToStr(i,0),OBJPROP_TIMEFRAMES,OBJ_PERIOD_M1);
       }            
     i++;  
   }  
//----
   return(0);
  }
//+------------------------------------------------------------------+