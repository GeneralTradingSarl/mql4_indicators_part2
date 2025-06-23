//+------------------------------------------------------------------+
//|                                                      TikTak.mq4 |
//|                                                     Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"

#property indicator_chart_window
int price_prev,s;
extern int pips=1;
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
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
int price=MathRound(Bid/Point),r;
   if (price_prev==price) return;
   r=price-price_prev;
   if(r<=-pips)
   {
    Alert("Вниз ",r,"пунктов"," Цена ",Bid);
   }
   if(r>=pips)
   {
    Alert("Вверх ",r," Цена ",Ask);
   }
   
   price_prev=price;
   
//----
   return(0);
  }
//+------------------------------------------------------------------+