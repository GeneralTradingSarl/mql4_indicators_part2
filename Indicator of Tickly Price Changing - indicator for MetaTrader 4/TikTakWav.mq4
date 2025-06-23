//+------------------------------------------------------------------+
//|                                                      TikTakWav.mq4 |
//|                                                     Tokman Yuriy |
//|  13 ñåíòÿáðÿ 2008 ãîäà                     yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"

#property indicator_chart_window
extern bool Play = true;
int price_prev;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   ObjectCreate("sigl",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("sigl2",OBJ_LABEL,0,0,0,0,0);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete ("sigl");
   ObjectDelete ("sigl2");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
    int price=MathRound(Bid/Point),d;
    if (price_prev==price) return;
    d=price-price_prev;
   
    string name ;
    string par = DoubleToStr(d,0);
    
    if     (d>0)  
    {
     name = "ÂÂÅÐÕ = ";
     ObjectSetText("sigl",name,12,"Arial Black",Red);
     ObjectSetText("sigl2",par,12,"Arial Black",Red);
     if ( Play == true)
     {
      if      (d==1){PlaySound("tick.wav");}
      else if (d==2){PlaySound("alert2.wav");}
      else if (d==3){PlaySound("expert.wav");}
      else if (d>3) {PlaySound("news.wav");}
     }
    }
    else if(d<0)  
    {
     name = "ÂÍÈÇ = ";
     ObjectSetText("sigl",name,12,"Arial Black",Lime);
     ObjectSetText("sigl2",par,12,"Arial Black",Lime);
     if ( Play == true)
     {
      if      (d==-1){PlaySound("ok.wav");}
      else if (d==-2){PlaySound("stops.wav");}
      else if (d==-3){PlaySound("timeout.wav");}
      else if (d>-3) {PlaySound("disconnect.wav");}
     }
    }
    
   ObjectSet("sigl",OBJPROP_XDISTANCE,3);
   ObjectSet("sigl2",OBJPROP_XDISTANCE,85);
 
   ObjectSet("sigl",OBJPROP_YDISTANCE,30);
   ObjectSet("sigl2",OBJPROP_YDISTANCE,30);
   
   price_prev=price;
                  
//----
   return(0);
  }
//+------------------------------------------------------------------+