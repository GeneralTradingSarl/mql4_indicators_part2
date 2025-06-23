//+------------------------------------------------------------------+
//|                                                   GG-Promise.mq4 |
//|                                      Copyright © 2010, JJ Newark |
//|                                            http:/jjnewark.atw.hu |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, JJ Newark"
#property link      "http:/jjnewark.atw.hu"


//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers      2
#property  indicator_color1       Maroon
#property  indicator_color2       Chocolate
#property  indicator_width1       1
#property  indicator_width2       1
#property  indicator_level1       0.0
#property  indicator_levelcolor   Silver


//---- indicator parameters
extern string   __Copyright__          = "http://jjnewark.atw.hu";


//int shift[]={0,3,5,8,13,21,34,55,89};
//int shift[]={0,2,3,5,8,13,21,34,55};
int shift[]={0,1,2,3,5,8,13,21,34};


extern int      Ma_Period                   = 12;
extern string   Help_for_Signal_Tolerance   = "Min: 1 (the smaller the faster)";
extern int      Signal_Tolerance            = 2;
extern int      Ma_Price                    = PRICE_TYPICAL;
extern int      DiffAvg_Period              = 12;
extern color    DiffColor                   = Maroon;
extern string   Help_for_DiffType           = "0: Value; 1: Percent";
extern int      DiffType                    = 0;


/*
PRICE_CLOSE 0 Close price. 
PRICE_OPEN 1 Open price. 
PRICE_HIGH 2 High price. 
PRICE_LOW 3 Low price. 
PRICE_MEDIAN 4 Median price, (high+low)/2. 
PRICE_TYPICAL 5 Typical price, (high+low+close)/3. 
PRICE_WEIGHTED 6 Weighted close price, (high+low+close+close)/4. 


MODE_SMA 0 Simple moving average, 
MODE_EMA 1 Exponential moving average, 
MODE_SMMA 2 Smoothed moving average, 
MODE_LWMA 3 Linear weighted moving average. 
*/

//---- indicator buffers
double     MainVal[];
double     SignalVal[];
double     DiffValue[];

double val_0,val_1,val_2,val_3,val_4,val_5,val_6,val_7,val_8;
double DiffAvg;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MainVal);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(1,SignalVal);
   SetIndexBuffer(2,DiffValue);
      
   SetIndexLabel(0,"MainVal");
   SetIndexLabel(1,"SignalVal");

   
   
//---- indicator buffers mapping
      
   
//---- 
   IndicatorShortName("JJN-Promise ("+Ma_Period+","+Signal_Tolerance+" - "+Ma_Price+") * http://jjnewark.atw.hu * ");
   
   
//---- initialization done
   return(0);
  }

int deinit()
  {
//----

   ObjectDelete("_DiffValue");
      
//----
   return(0);
  }

int start()
  {
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+Signal_Tolerance;
//---- 

   for(int i=0; i<limit; i++)
   {
   val_0=iMA(NULL,0,Ma_Period,shift[0],MODE_EMA,Ma_Price,i);
   val_1=iMA(NULL,0,Ma_Period,shift[1],MODE_EMA,Ma_Price,i)-val_0;
   val_2=iMA(NULL,0,Ma_Period,shift[2],MODE_EMA,Ma_Price,i)-val_0;
   val_3=iMA(NULL,0,Ma_Period,shift[3],MODE_EMA,Ma_Price,i)-val_0;
   val_4=iMA(NULL,0,Ma_Period,shift[4],MODE_EMA,Ma_Price,i)-val_0;
   val_5=iMA(NULL,0,Ma_Period,shift[5],MODE_EMA,Ma_Price,i)-val_0;
   val_6=iMA(NULL,0,Ma_Period,shift[6],MODE_EMA,Ma_Price,i)-val_0;
   val_7=iMA(NULL,0,Ma_Period,shift[7],MODE_EMA,Ma_Price,i)-val_0;
   val_8=iMA(NULL,0,Ma_Period,shift[8],MODE_EMA,Ma_Price,i)-val_0;
      
   MainVal[i]=0-(val_1+val_2+val_3+val_4+val_5+val_6+val_7+val_8);
   }
   
   
   
   for(i=0; i<limit; i++)
   {
   SignalVal[i]=MainVal[i+Signal_Tolerance];
   }
   
   
   for(i=0; i<limit; i++)
   {
   DiffValue[i]=MathAbs(MainVal[i]-SignalVal[i]);
   }
   
   
   DiffAvg=iMAOnArray(DiffValue,Bars,DiffAvg_Period,0,MODE_EMA,0);
   double Percent=(MathAbs(DiffValue[0])/DiffAvg)*100;

   
   
   DiffValue[0]=MainVal[0]-SignalVal[0];
   ObjectCreate("_DiffValue", OBJ_LABEL, WindowFind("JJN-Promise ("+Ma_Period+","+Signal_Tolerance+" - "+Ma_Price+") * http://jjnewark.atw.hu * "), 0, 0);
   ObjectSet("_DiffValue", OBJPROP_XDISTANCE, 3); 
   ObjectSet("_DiffValue", OBJPROP_YDISTANCE, 15);
   if(DiffType==0)   
   ObjectSetText("_DiffValue",StringConcatenate("Diff: ",DoubleToStr(DiffValue[0],4)," (",DoubleToStr(DiffAvg,4),")"),10,"Tahoma",DiffColor);
   else if(DiffType==1)   
   ObjectSetText("_DiffValue",StringConcatenate("Diff: ",DoubleToStr(DiffValue[0],4)," (",DoubleToStr(Percent,0),"%)"),10,"Tahoma",DiffColor);
   
         
   
//---- done
   return(0);
  }
//+------------------------------------------------------------------+