//+------------------------------------------------------------------+
//|                                          MaksiGen_Range_Move.mq4 |
//|                MaksiGen - MT3 by OlegVS ( olegvs2003@yahoo.com ) |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "MaksiGen - MT3 by OlegVS ( olegvs2003@yahoo.com )"
#property link      ""
//----
#property indicator_chart_window
//---- input parameters
extern int Pfast=5;
extern int Pslow=8;
extern double K_RangeOpen=1.4;
double hi1,lo1,hi2,lo2,Range;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- Object
   ObjectCreate("hi1",OBJ_HLINE,0,0,0,0,0,0,0); ObjectSet("hi1",OBJPROP_COLOR,Silver); ObjectSet("hi1",OBJPROP_STYLE,STYLE_DOT);
   ObjectCreate("lo1",OBJ_HLINE,0,0,0,0,0,0,0); ObjectSet("lo1",OBJPROP_COLOR,Silver); ObjectSet("lo1",OBJPROP_STYLE,STYLE_DOT);
   ObjectCreate("hi2",OBJ_HLINE,0,0,0,0,0,0,0); ObjectSet("hi2",OBJPROP_COLOR,Silver); ObjectSet("hi2",OBJPROP_STYLE,STYLE_DASH);
   ObjectCreate("lo2",OBJ_HLINE,0,0,0,0,0,0,0); ObjectSet("lo2",OBJPROP_COLOR,Silver); ObjectSet("lo2",OBJPROP_STYLE,STYLE_DASH);
   ObjectCreate("Bar#1",    OBJ_VLINE,0,0,0,0,0,0,0); ObjectSet("Bar#1",    OBJPROP_COLOR,OliveDrab);    ObjectSet("Bar#1",    OBJPROP_STYLE,STYLE_DOT);
   ObjectCreate("Bar#Pfast",OBJ_VLINE,0,0,0,0,0,0,0); ObjectSet("Bar#Pfast",OBJPROP_COLOR,LightSkyBlue); ObjectSet("Bar#Pfast",OBJPROP_STYLE,STYLE_DOT);
   ObjectCreate("Bar#Pslow",OBJ_VLINE,0,0,0,0,0,0,0); ObjectSet("Bar#Pslow",OBJPROP_COLOR,Blue);         ObjectSet("Bar#Pslow",OBJPROP_STYLE,STYLE_DOT);
   ObjectCreate("TrendHIGH",OBJ_TREND,0,0,0,0,0,0); ObjectSet("TrendHIGH",OBJPROP_COLOR,Gold); ObjectSet("TrendHIGH",OBJPROP_STYLE,STYLE_SOLID);
   ObjectCreate("Trend_LOW",OBJ_TREND,0,0,0,0,0,0); ObjectSet("Trend_LOW",OBJPROP_COLOR,Gold); ObjectSet("Trend_LOW",OBJPROP_STYLE,STYLE_SOLID);
   ObjectCreate("SELLSTOP",OBJ_HLINE,0,0,0,0,0,0,0); ObjectSet("SELLSTOP",OBJPROP_COLOR,Red);  ObjectSet("SELLSTOP",OBJPROP_STYLE,STYLE_DOT);
   ObjectCreate("BUY_STOP",OBJ_HLINE,0,0,0,0,0,0,0); ObjectSet("BUY_STOP",OBJPROP_COLOR,Blue); ObjectSet("BUY_STOP",OBJPROP_STYLE,STYLE_DOT);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   ObjectDelete("hi1"); ObjectDelete("lo1");
   ObjectDelete("hi2"); ObjectDelete("lo2");
   ObjectDelete("Bar#1"); ObjectDelete("Bar#Pfast"); ObjectDelete("Bar#Pslow");
   ObjectDelete("TrendHIGH"); ObjectDelete("Trend_LOW");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//---- 
   hi1=High[Highest(Symbol(),0,MODE_HIGH,Pfast,1)];
   lo1=Low[Lowest(Symbol(),0,MODE_LOW,Pfast,1)];
   hi2=High[Highest(Symbol(),0,MODE_HIGH,Pslow,1)];
   lo2=Low[Lowest(Symbol(),0,MODE_LOW,Pslow,1)];
//---- horizontal lines
   ObjectMove("hi1",0,Time[Pfast-1],hi1);
   ObjectMove("lo1",0,Time[Pfast-1],lo1);
   ObjectMove("hi2",0,Time[Pslow-1],hi2);
   ObjectMove("lo2",0,Time[Pslow-1],lo2);
//---- vertical lines
   ObjectMove("Bar#1",    0,Time[1],    High[1]);
   ObjectMove("Bar#Pfast",0,Time[Pfast],High[1]);
   ObjectMove("Bar#Pslow",0,Time[Pslow],High[1]);
//---- trend lines
   ObjectSet("TrendHIGH",OBJPROP_TIME1,Time[Pslow]); ObjectSet("TrendHIGH",OBJPROP_PRICE1,hi2);
   ObjectSet("TrendHIGH",OBJPROP_TIME2,Time[Pfast]); ObjectSet("TrendHIGH",OBJPROP_PRICE2,hi1);
   ObjectSet("Trend_LOW",OBJPROP_TIME1,Time[Pslow]); ObjectSet("Trend_LOW",OBJPROP_PRICE1,lo2);
   ObjectSet("Trend_LOW",OBJPROP_TIME2,Time[Pfast]); ObjectSet("Trend_LOW",OBJPROP_PRICE2,lo1);
//----
   if (hi1-lo1==hi2-lo2)
     {
      Range=(hi1-lo1)*K_RangeOpen;
      ObjectMove("SELLSTOP",0,Time[Pfast-1],lo1-Range);
      ObjectMove("BUY_STOP",0,Time[Pfast-1],hi1+Range);
      ObjectSet("TrendHIGH",OBJPROP_TIME1,Time[Pslow-1]); ObjectSet("TrendHIGH",OBJPROP_PRICE1,hi2);
      ObjectSet("TrendHIGH",OBJPROP_TIME2,Time[Pfast-1]); ObjectSet("TrendHIGH",OBJPROP_PRICE2,hi1);
      ObjectSet("Trend_LOW",OBJPROP_TIME1,Time[Pslow]-1); ObjectSet("Trend_LOW",OBJPROP_PRICE1,lo2);
      ObjectSet("Trend_LOW",OBJPROP_TIME2,Time[Pfast]-1); ObjectSet("Trend_LOW",OBJPROP_PRICE2,lo1);
     }
   ObjectsRedraw();
//----
   return(0);
  }
//+------------------------------------------------------------------+

