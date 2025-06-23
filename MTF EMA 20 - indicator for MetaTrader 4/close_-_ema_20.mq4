//+------------------------------------------------------------------+
//|                                                     Close - EMA's|
//|                                  2014 - Joca (nc32007a@gmail.com)|
//+------------------------------------------------------------------+
 
#property indicator_chart_window

extern int EMA_Period=20;
extern int offset=2;
extern int lenght=7;

color UpCandleColor=Lime;
color DownCandleColor=Red;
double width=2;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+


void DeleteObjects() 


{
   ObjectDelete(0,"M1");
   ObjectDelete(0,"M5");
   ObjectDelete(0,"M15");
   ObjectDelete(0,"M30");
   ObjectDelete(0,"H1");
   ObjectDelete(0,"H4");
   ObjectDelete(0,"D1");
   ObjectDelete(0,"W1");
   ObjectDelete(0,"MN1");

}
   

int init()

  {
  DeleteObjects();
  return(0);
  }
  
  
  int deinit() 
  
  {
  DeleteObjects();
  return(0);
  }
  
int start()

  {
  
   DeleteObjects();
   
   double dif=MathAbs(Time[1] - Time[2]);
   datetime dtStart=Time[0]+dif*offset;
   datetime dtEnd=Time[0]+dif*offset*lenght;
    
   
   
   //M1 
   
   string name="M1";
   double M1=iMA(Symbol(), PERIOD_M1, EMA_Period, 0, MODE_EMA, PRICE_CLOSE, 0);
   color clr=DownCandleColor; 
   if (M1 <= Bid) clr=UpCandleColor;
   
   
   ObjectCreate(0,name,OBJ_TREND,0, dtStart, M1,dtEnd, M1);
   ObjectSet(name, OBJPROP_COLOR, clr);
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_RAY, False);
   ObjectSetText(name,"  M1");
   
   
   
    //M5 
   
   name="M5";
   double M5=iMA(Symbol(), PERIOD_M5, EMA_Period, 0, MODE_EMA, PRICE_CLOSE, 0);
   clr=DownCandleColor; 
   if (M5 <= Bid) clr=UpCandleColor;
   
   
   ObjectCreate(0,name,OBJ_TREND,0, dtStart, M5,dtEnd, M5);
   ObjectSet(name, OBJPROP_COLOR, clr);
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_RAY, False);
   ObjectSetText(name,"  M5");
   
   
   
   
   
   //M15 
   
   name="M15";
   double M15=iMA(Symbol(), PERIOD_M15, EMA_Period, 0, MODE_EMA, PRICE_CLOSE, 0);
   clr=DownCandleColor; 
   if (M15 <= Bid) clr=UpCandleColor;
   
   
   ObjectCreate(0,name,OBJ_TREND, 0,dtStart, M15,dtEnd, M15);
   ObjectSet(name, OBJPROP_COLOR, clr);
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_RAY, False);
   ObjectSetText(name,"  M15");
   
   
   //M30 
   
   name="M30";
   double M30=iMA(Symbol(), PERIOD_M30, EMA_Period, 0, MODE_EMA, PRICE_CLOSE, 0);
   clr=DownCandleColor; 
   if (M30 <= Bid) clr=UpCandleColor;
   
   
   ObjectCreate(0,name,OBJ_TREND, 0,dtStart, M30,dtEnd, M30);
   ObjectSet(name, OBJPROP_COLOR, clr);
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_RAY, False);
   ObjectSetText(name,"  M30");
   
   
   
    //H1
   
   name="H1";
   double H1=iMA(Symbol(), PERIOD_H1, EMA_Period, 0, MODE_EMA, PRICE_CLOSE, 0);
   clr=DownCandleColor; 
   if (H1 <= Bid) clr=UpCandleColor;
   
   
   ObjectCreate(0,name,OBJ_TREND, 0,dtStart, H1,dtEnd, H1);
   ObjectSet(name, OBJPROP_COLOR, clr);
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_RAY, False);
   ObjectSetText(name,"  H1");
   
   
    //H4
   
   name="H4";
   double H4=iMA(Symbol(), PERIOD_H4, EMA_Period, 0, MODE_EMA, PRICE_CLOSE, 0);
   clr=DownCandleColor; 
   if (H4 <= Bid) clr=UpCandleColor;
   
   
   ObjectCreate(0,name,OBJ_TREND, 0,dtStart, H4,dtEnd, H4);
   ObjectSet(name, OBJPROP_COLOR, clr);
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_RAY, False);
   ObjectSetText(name,"  H4");
   
   
   //D1
   
   name="D1";
   double D1=iMA(Symbol(), PERIOD_D1, EMA_Period, 0, MODE_EMA, PRICE_CLOSE, 0);
   clr=DownCandleColor; 
   if (D1 <= Bid) clr=UpCandleColor;
   
   
   ObjectCreate(0,name,OBJ_TREND, 0,dtStart, D1,dtEnd, D1);
   ObjectSet(name, OBJPROP_COLOR, clr);
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_RAY, False);
   ObjectSetText(name,"  D1");
   
   
    //W1
   
   name="W1";
   double W1=iMA(Symbol(), PERIOD_W1, EMA_Period, 0, MODE_EMA, PRICE_CLOSE, 0);
   clr=DownCandleColor; 
   if (W1 <= Bid) clr=UpCandleColor;
   
   
   ObjectCreate(0,name,OBJ_TREND, 0,dtStart, W1,dtEnd, W1);
   ObjectSet(name, OBJPROP_COLOR, clr);
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_RAY, False);
   ObjectSetText(name,"  W1");
   
   
    //MN1
   
   name="MN1";
   double MN1=iMA(Symbol(), PERIOD_MN1, EMA_Period, 0, MODE_EMA, PRICE_CLOSE, 0);
   clr=DownCandleColor; 
   if (MN1 <= Bid) clr=UpCandleColor;
   
   
   ObjectCreate(0,name,OBJ_TREND, 0,dtStart, MN1,dtEnd, MN1);
   ObjectSet(name, OBJPROP_COLOR, clr);
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_RAY, False);
   ObjectSetText(name,"  MN1");
   
   
   
   return(0);
  }
//+------------------------------------------------------------------+


     