//+------------------------------------------------------------------+
//|                                                          003.mq4 |
//|                                               Yuriy Tokman (YTG) |
//|                                               https://ytg.com.ua |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman (YTG)"
#property link      "https://ytg.com.ua"
#property version   "1.00"
#property strict
#property indicator_separate_window

#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red


input int barsToProcess=1000;

double BU0[];
double BU1[];
string short_name;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   short_name="003";
   IndicatorShortName(short_name);   
   
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,BU0);
   SetIndexLabel(0,"UP");
      
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,BU1);   
   SetIndexLabel(1,"DN");   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   double par;
   int limit=rates_total-prev_calculated;
   if(prev_calculated==0)limit--;
   else  limit++;
   
   if(limit>=rates_total-2)limit = rates_total - 2;
   
   if(barsToProcess>0 && barsToProcess<limit)limit=barsToProcess;
  
   for( int i=limit; i>=0 && !IsStopped(); i--)
    {
     par = (open[i] - close[i+1])/Point;
     if(par>0) BU0[i]=par;    
     else      BU1[i]=par;   
    }   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
