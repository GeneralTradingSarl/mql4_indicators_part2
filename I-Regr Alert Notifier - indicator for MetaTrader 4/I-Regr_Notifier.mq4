//+------------------------------------------------------------------+
//| Version 3                                     IregrNotifier.mq4  |
//|                                         Copyright © 2011,NN      |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Neudis Neukrug"

double regup, regdown; 
extern int delayBetweenAlerts =240;
extern int degree = 3;
extern double kstd = 2.0;
extern int bars = 250;
extern int shift = 0;
extern color IndicatorColor=White; 
int counter=0;

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
      ObjectDelete("I-regr Notifier");
      ObjectDelete("RegrUp");
      ObjectDelete("RegrDown");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  
  counter++;

  regup = iCustom(NULL,0,"i-Regr",degree,kstd,bars,shift,1,0);
  regdown = iCustom(NULL,0,"i-Regr",degree,kstd,bars,shift,2,0);
  
  if(Ask>regup && counter>delayBetweenAlerts){
  Alert("IREGR BROKE UP: ",Symbol()," M",Period()," Price: ",Ask);
          counter=0;
  }
  
  if(Ask<regdown && counter>delayBetweenAlerts){
  Alert("IREGR BROKE DOWN: ",Symbol()," M",Period()," Price: ",Ask);
         counter=0;
  }
      ObjectCreate("I-regr Notifier", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("I-regr Notifier","I-regr Notifier",8,"Arial Black", IndicatorColor);
      ObjectSet("I-regr Notifier", OBJPROP_CORNER, 3);
      ObjectSet("I-regr Notifier", OBJPROP_XDISTANCE, 4);
      ObjectSet("I-regr Notifier", OBJPROP_YDISTANCE, 13);
      
      
      ObjectCreate("RegrUp", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("RegrUp",DoubleToStr(regup,Digits),8,"Arial Black", IndicatorColor);
      ObjectSet("RegrUp", OBJPROP_CORNER, 3);
      ObjectSet("RegrUp", OBJPROP_XDISTANCE, 4);
      ObjectSet("RegrUp", OBJPROP_YDISTANCE, 47);

      ObjectCreate("RegrDown", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("RegrDown",DoubleToStr(regdown,Digits),8,"Arial Black", IndicatorColor);
      ObjectSet("RegrDown", OBJPROP_CORNER, 3);
      ObjectSet("RegrDown", OBJPROP_XDISTANCE, 4);
      ObjectSet("RegrDown", OBJPROP_YDISTANCE, 34);
   
      return(0);
  }
//+------------------------------------------------------------------+