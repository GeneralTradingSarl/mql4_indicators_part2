//+------------------------------------------------------------------+
//|                                                      Raznost2.mq4 |
//|                                                       TokmanYuriy |
//|  13 сент€бр€ 2008 года                      yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"

#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   ObjectCreate("signal",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("signal2",OBJ_LABEL,0,0,0,0,0);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete ("signal");
   ObjectDelete ("signal2");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
    string name ;
    double a = ((iOpen(NULL,0,0))-(iClose(NULL,0,1)))/Point;
    string par = DoubleToStr(a,0);
    
    if     (a>0)  
    {
     name = "  up = ";
     ObjectSetText("signal",name,12,"Arial Black",Red);
     ObjectSetText("signal2",par,12,"Arial Black",Red);
    }
    else if(a<0)  
    {
     name = "down = ";
     ObjectSetText("signal",name,12,"Arial Black",Lime);
     ObjectSetText("signal2",par,12,"Arial Black",Lime);
    }
    else if(a==0) 
    {
     name = "flet = ";
     ObjectSetText("signal",name,12,"Arial Black",Blue);
     ObjectSetText("signal2",par,12,"Arial Black",Blue);
    }
    
   ObjectSet("signal",OBJPROP_XDISTANCE,3);
   ObjectSet("signal2",OBJPROP_XDISTANCE,69);
 
   ObjectSet("signal",OBJPROP_YDISTANCE,12);
   ObjectSet("signal2",OBJPROP_YDISTANCE,12);
                  
//----
   return(0);
  }
//+------------------------------------------------------------------+