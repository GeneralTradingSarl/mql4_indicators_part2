//+------------------------------------------------------------------+
//|                                                  spread swap.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property indicator_separate_window
//----
double    swaplong,swapshort;
int spread;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int init()
  {
   IndicatorShortName("spread/swap monitor ("+Symbol()+")");
//----
  return(0);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
   {
      return(0);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   spread=MarketInfo(Symbol(),13);
   swaplong=NormalizeDouble(MarketInfo(Symbol(),18),2);
   swapshort=NormalizeDouble(MarketInfo(Symbol(),19),2);
//----
   ObjectCreate("spread/swap monitor1", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitor1","Current Spread:", 9, "Tahoma", White);
   ObjectSet("spread/swap monitor", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitor1", OBJPROP_XDISTANCE, 155);
   ObjectSet("spread/swap monitor1", OBJPROP_YDISTANCE, 2);
//----
   ObjectCreate("spread/swap monitor2", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitor2",DoubleToStr(spread ,0),9, "Tahoma", Black);
   ObjectSet("spread/swap monitor2", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitor2", OBJPROP_XDISTANCE, 250);
   ObjectSet("spread/swap monitor2", OBJPROP_YDISTANCE, 2);
//----
   ObjectCreate("spread/swap monitor3", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitor3","Buy Swap:", 9, "Tahoma", Green);
   ObjectSet("spread/swap monitor3", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitor3", OBJPROP_XDISTANCE, 275);
   ObjectSet("spread/swap monitor3", OBJPROP_YDISTANCE, 2);
//----
   ObjectCreate("spread/swap monitor4", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitor4",DoubleToStr( swaplong ,2),9, "Tahoma", Black);
   ObjectSet("spread/swap monitor4", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitor4", OBJPROP_XDISTANCE, 345);
   ObjectSet("spread/swap monitor4", OBJPROP_YDISTANCE, 2);
//----
   ObjectCreate("spread/swap monitor5", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitor5","Sell Swap:", 9, "Tahoma", Red);
   ObjectSet("spread/swap monitor5", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitor5", OBJPROP_XDISTANCE, 380);
   ObjectSet("spread/swap monitor5", OBJPROP_YDISTANCE, 2);
//----
   ObjectCreate("spread/swap monitor6", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitor6",DoubleToStr( swapshort ,2),9, "Tahoma", Black);
   ObjectSet("spread/swap monitor6", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitor6", OBJPROP_XDISTANCE, 445);
   ObjectSet("spread/swap monitor6", OBJPROP_YDISTANCE, 2);
//----
//----
   ObjectCreate("spread/swap monitor7", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitor7","Bid/Ask:", 9, "Tahoma", Black);
   ObjectSet("spread/swap monitor7", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitor7", OBJPROP_XDISTANCE, 505);
   ObjectSet("spread/swap monitor7", OBJPROP_YDISTANCE, 2);
//----
   ObjectCreate("spread/swap monitor8", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitor8",DoubleToStr(Bid ,5),9, "Tahoma", Red);
   ObjectSet("spread/swap monitor8", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitor8", OBJPROP_XDISTANCE, 555);
   ObjectSet("spread/swap monitor8", OBJPROP_YDISTANCE, 3);
//----
   ObjectCreate("spread/swap monitor9", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitor9",DoubleToStr(Ask ,5),9, "Tahoma", Blue);
   ObjectSet("spread/swap monitor9", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitor9", OBJPROP_XDISTANCE, 555);
   ObjectSet("spread/swap monitor9", OBJPROP_YDISTANCE, 15);

   return(0);
  }
//+------------------------------------------------------------------+