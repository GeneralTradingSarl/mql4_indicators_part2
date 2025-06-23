//+------------------------------------------------------------------+
//|                                                Pivots_Hi_Low.mq4 |
//|                      Copyright © 2006, Cartwright Software Corp. |
//|                                        http://www.cartwright.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Cartwright Software Corp."
#property link      "http://www.cartwright.net"
#property indicator_chart_window
//----
extern int BarsBack=8;    // (Set to 0 GMT) IBFX=GMT FXDD=GMT+3 5pm-17:00(PST)
extern bool ShowLines=true;
double yesterday_high, yesterday_low;
//+------------------------------------------------------------------+
//|                                                                  |
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
   ObjectDelete("Yesterdays Low line");
   ObjectDelete("Yesterdays High line");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
   yesterday_high=iHigh(NULL, PERIOD_H1,Highest(NULL, PERIOD_H1, MODE_HIGH, BarsBack, 0));
   yesterday_low=iLow(NULL, PERIOD_H1,Lowest(NULL, PERIOD_H1, MODE_LOW, BarsBack, 0));
//----
     if (ShowLines==true && Period() < PERIOD_D1) 
     {
      ObjectDelete("Yesterdays Low line");
      ObjectCreate("Yesterdays Low line",OBJ_HLINE, 0, Time[0], yesterday_low);
      ObjectSet("Yesterdays Low line", OBJPROP_STYLE, STYLE_DASH);
      ObjectSet("Yesterdays Low line", OBJPROP_COLOR, Green);
      ObjectDelete("Yesterdays High line");
      ObjectCreate("Yesterdays High line",OBJ_HLINE, 0, Time[0], yesterday_high);
      ObjectSet("Yesterdays High line", OBJPROP_STYLE, STYLE_DASH);
      ObjectSet("Yesterdays High line", OBJPROP_COLOR, Red);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+