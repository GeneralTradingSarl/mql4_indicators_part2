//+------------------------------------------------------------------+
//|                                                      hemnina.mq4 |
//|                                                              mog |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "mog"
#property link      ""
//----
#property indicator_chart_window
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
   double p10;
   double p9;
   double p8;
   double p7;
   double p6;
   double p5;
   double p4;
   double p3;
   double p2;
   double p1;
   double p0;
//-----
   p10=iClose(0,0,10);
   p9=iClose(0,0,9);
   p8=iClose(0,0,8);
   p7=iClose(0,0,7);
   p6=iClose(0,0,6);
   p5=iClose(0,0,5);
   p4=iClose(0,0,4);
   p3=iClose(0,0,3);
   p2=iClose(0,0,2);
   p1=iClose(0,0,1);
   p0=iClose(0,0,0);
//----
   Comment("Close[10] = ",p10,
           "\nClose[9] = ",p9,
           "\nClose[8] = ",p8,
           "\nClose[7] = ",p7,
           "\nClose[6] = ",p6,
           "\nClose[5] = ",p5,
           "\nClose[4] = ",p4,
           "\nClose[3] = ",p3,
           "\nClose[2] = ",p2,
           "\nClose[1] = ",p1,
           "\nClose[0] = ",p0);
//----
   return(0);
  }
//+------------------------------------------------------------------+