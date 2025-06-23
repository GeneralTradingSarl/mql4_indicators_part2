//+------------------------------------------------------------------+
//|                                                     LineFrakDown.mq4 |
//|                                                     Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"

#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
    ObjectCreate("Saport", OBJ_TREND, 0,0,0,0,0);//создание трендовой линии
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
  ObjectDelete("Saport");//удаление обекта   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
//----
  double F1=0, F3=0, F13;    // номера фракталов
  int    B1, B3, SR=2;               // номера баров
  
  while(F3==0)                       //поиск фракталов
  {
    F13=iFractals(NULL,0,MODE_LOWER,SR);
    if (F13!=0) 
    {
      if      (F1==0){B1=SR; F1=F13;}
      else if (F3==0){B3=SR; F3=F13;}
    }
    SR++; 
  }
    ObjectSet("Saport", OBJPROP_TIME1 ,iTime(NULL,0,B3));
    ObjectSet("Saport", OBJPROP_TIME2 ,iTime(NULL,0,B1));
    ObjectSet("Saport", OBJPROP_PRICE1,iLow(NULL,0,B3));
    ObjectSet("Saport", OBJPROP_PRICE2,iLow(NULL,0,B1));
    ObjectSet("Saport", OBJPROP_RAY   , True);

  
//----
   return(0);
  }
//+------------------------------------------------------------------+