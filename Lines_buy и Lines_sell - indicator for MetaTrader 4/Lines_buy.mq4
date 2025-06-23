//+------------------------------------------------------------------+
//|                                                        Lines_buy.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                         http://pilot911.narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, pilot@m-lan.ru"
#property link      "pilot@m-lan.ru"
//----
#property indicator_chart_window
//---- input parameters
extern double    StartFrom=1.20;
extern double    Step1=20;
extern double    Step2=40;
extern double    Step3=80;
extern double    Step4=80;
extern double    Step5=80;
extern double    Step6=80;
extern double    Step7=80;
extern double    Step8=80;
extern double    Step9=80;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double   curr=NormalizeDouble(ObjectGet( "b_order0", OBJPROP_PRICE1),Digits);
//----
   ObjectSet( "b_order1", OBJPROP_PRICE1, curr+Step1*Point);
   ObjectSet( "b_order2", OBJPROP_PRICE1, curr+(Step1+Step2)*Point);
   ObjectSet( "b_order3", OBJPROP_PRICE1, curr+(Step1+Step2)*Point);
   ObjectSet( "b_order4", OBJPROP_PRICE1, curr+(Step1+Step2+Step3)*Point);
   ObjectSet( "b_order5", OBJPROP_PRICE1, curr+(Step1+Step2+Step3+Step4)*Point);
   ObjectSet( "b_order6", OBJPROP_PRICE1, curr+(Step1+Step2+Step3+Step4+Step5)*Point);
   ObjectSet( "b_order7", OBJPROP_PRICE1, curr+(Step1+Step2+Step3+Step4+Step5+Step6)*Point);
   ObjectSet( "b_order8", OBJPROP_PRICE1, curr+(Step1+Step2+Step3+Step4+Step5+Step6+Step7)*Point);
   ObjectSet( "b_order9", OBJPROP_PRICE1, curr+(Step1+Step2+Step3+Step4+Step5+Step6+Step7+Step8)*Point);
   ObjectSet( "b_order10", OBJPROP_PRICE1, curr+(Step1+Step2+Step3+Step4+Step5+Step6+Step7+Step8+Step9)*Point);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int init() 
  {
   ObjectCreate( "b_order0", OBJ_HLINE, 0, 0, StartFrom, 0, 0, 0, 0 );
   ObjectSet( "b_order0", OBJPROP_COLOR, MediumBlue );
   ObjectCreate( "b_order1", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "b_order1", OBJPROP_COLOR, MediumBlue );
   ObjectCreate( "b_order2", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "b_order2", OBJPROP_COLOR, MediumBlue );
   ObjectCreate( "b_order3", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "b_order3", OBJPROP_COLOR, MediumBlue );
   ObjectCreate( "b_order4", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "b_order4", OBJPROP_COLOR, MediumBlue );
   ObjectCreate( "b_order5", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "b_order5", OBJPROP_COLOR, MediumBlue );
   ObjectCreate( "b_order6", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "b_order6", OBJPROP_COLOR, MediumBlue );
   ObjectCreate( "b_order7", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "b_order7", OBJPROP_COLOR, MediumBlue );
   ObjectCreate( "b_order8", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "b_order8", OBJPROP_COLOR, MediumBlue );
   ObjectCreate( "b_order9", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "b_order9", OBJPROP_COLOR, MediumBlue );
   ObjectCreate( "b_order10", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "b_order10", OBJPROP_COLOR, MediumBlue );
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete( "b_order0");
   ObjectDelete( "b_order1");
   ObjectDelete( "b_order2");
   ObjectDelete( "b_order3");
   ObjectDelete( "b_order4");
   ObjectDelete( "b_order5");
   ObjectDelete( "b_order6");
   ObjectDelete( "b_order7");
   ObjectDelete( "b_order8");
   ObjectDelete( "b_order9");
   ObjectDelete( "b_order10");
   return(0);
  }
//+------------------------------------------------------------------+