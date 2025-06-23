//+------------------------------------------------------------------+
//|                                           MultiInstrument_YK.mq4 |
//|                               Copyright © 2010, Vladimir Hlystov |
//|                                         http://cmillion.narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Vladimir Hlystov"
#property link      "http://cmillion.narod.ru"
//plots 4 symbols on the current chart
 
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Magenta
extern string symbol_1 = "";      //if "" ,use current
extern string symbol_2 = "EURUSD";//if "" ,use current
extern string symbol_3 = "EURCHF";//if "" ,use current
extern string symbol_4 = "EURGBP";//if "" ,use current
extern int ControlBars = 200;     //number of control bars
extern int N           = 1;       //averaging N candles
extern color PlusColor = indicator_color1;
extern color MinusColor= indicator_color2;
double Buffer_1[];
double Buffer_2[];
double Buffer_3[];
double Buffer_4[];
//+------------------------------------------------------------------+
int init()
  {
   ObjectCreate("symbol_1", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_1", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_1", OBJPROP_XDISTANCE, 10 ); 
   ObjectSet   ("symbol_1", OBJPROP_YDISTANCE, 15);
   ObjectCreate("symbol_2", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_2", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_2", OBJPROP_XDISTANCE, 10 ); 
   ObjectSet   ("symbol_2", OBJPROP_YDISTANCE, 25);
   ObjectCreate("symbol_3", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_3", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_3", OBJPROP_XDISTANCE, 10 ); 
   ObjectSet   ("symbol_3", OBJPROP_YDISTANCE, 35);
   ObjectCreate("symbol_4", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_4", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_4", OBJPROP_XDISTANCE, 10 ); 
   ObjectSet   ("symbol_4", OBJPROP_YDISTANCE, 45);
   ObjectCreate("symbol_5", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_5", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_5", OBJPROP_XDISTANCE, 10 ); 
   ObjectSet   ("symbol_5", OBJPROP_YDISTANCE, 55);
   ObjectCreate("symbol_6", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_6", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_6", OBJPROP_XDISTANCE, 10 ); 
   ObjectSet   ("symbol_6", OBJPROP_YDISTANCE, 65);
   ObjectCreate("symbol_7", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_7", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_7", OBJPROP_XDISTANCE, 10 ); 
   ObjectSet   ("symbol_7", OBJPROP_YDISTANCE, 80);
 
   if (symbol_1=="") symbol_1=Symbol();
   if (symbol_2=="") symbol_2=Symbol();
   if (symbol_3=="") symbol_3=Symbol();
   if (symbol_4=="") symbol_4=Symbol();
 
   ObjectCreate("symbol_1.", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_1.", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_1.", OBJPROP_XDISTANCE, 100 ); 
   ObjectSet   ("symbol_1.", OBJPROP_YDISTANCE, 15);
   ObjectSetText("symbol_1.",symbol_1+"-",8,"Arial",indicator_color1);
   ObjectCreate("symbol_2.", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_2.", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_2.", OBJPROP_XDISTANCE, 100 ); 
   ObjectSet   ("symbol_2.", OBJPROP_YDISTANCE, 25);
   ObjectSetText("symbol_2.",symbol_1+"-",8,"Arial",indicator_color1);
   ObjectCreate("symbol_3.", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_3.", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_3.", OBJPROP_XDISTANCE, 100 ); 
   ObjectSet   ("symbol_3.", OBJPROP_YDISTANCE, 35);
   ObjectSetText("symbol_3.",symbol_1+"-",8,"Arial",indicator_color1);
   ObjectCreate("symbol_4.", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_4.", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_4.", OBJPROP_XDISTANCE, 100 ); 
   ObjectSet   ("symbol_4.", OBJPROP_YDISTANCE, 45);
   ObjectSetText("symbol_4.",symbol_2+"-",8,"Arial",indicator_color2);
   ObjectCreate("symbol_5.", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_5.", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_5.", OBJPROP_XDISTANCE, 100 ); 
   ObjectSet   ("symbol_5.", OBJPROP_YDISTANCE, 55);
   ObjectSetText("symbol_5.",symbol_2+"-",8,"Arial",indicator_color2);
   ObjectCreate("symbol_6.", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_6.", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_6.", OBJPROP_XDISTANCE, 100 ); 
   ObjectSet   ("symbol_6.", OBJPROP_YDISTANCE, 65);
   ObjectSetText("symbol_6.",symbol_3+"-",8,"Arial",indicator_color3);
 
   ObjectCreate("symbol_1..", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_1..", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_1..", OBJPROP_XDISTANCE, 50 ); 
   ObjectSet   ("symbol_1..", OBJPROP_YDISTANCE, 15);
   ObjectSetText("symbol_1..","-"+symbol_2,8,"Arial",indicator_color2);
   ObjectCreate("symbol_2..", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_2..", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_2..", OBJPROP_XDISTANCE, 50 ); 
   ObjectSet   ("symbol_2..", OBJPROP_YDISTANCE, 25);
   ObjectSetText("symbol_2..","-"+symbol_3,8,"Arial",indicator_color3);
   ObjectCreate("symbol_3..", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_3..", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_3..", OBJPROP_XDISTANCE, 50 ); 
   ObjectSet   ("symbol_3..", OBJPROP_YDISTANCE, 35);
   ObjectSetText("symbol_3..","-"+symbol_4,8,"Arial",indicator_color4);
   ObjectCreate("symbol_4..", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_4..", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_4..", OBJPROP_XDISTANCE, 50 ); 
   ObjectSet   ("symbol_4..", OBJPROP_YDISTANCE, 45);
   ObjectSetText("symbol_4..","-"+symbol_3,8,"Arial",indicator_color3);
   ObjectCreate("symbol_5..", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_5..", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_5..", OBJPROP_XDISTANCE, 50 ); 
   ObjectSet   ("symbol_5..", OBJPROP_YDISTANCE, 55);
   ObjectSetText("symbol_5..","-"+symbol_4,8,"Arial",indicator_color4);
   ObjectCreate("symbol_6..", OBJ_LABEL, 0, 0, 0);
   ObjectSet   ("symbol_6..", OBJPROP_CORNER, 1);      
   ObjectSet   ("symbol_6..", OBJPROP_XDISTANCE, 50 ); 
   ObjectSet   ("symbol_6..", OBJPROP_YDISTANCE, 65);
   ObjectSetText("symbol_6..","-"+symbol_4,8,"Arial",indicator_color4);
 
   SetIndexBuffer(0,Buffer_1);
   SetIndexBuffer(1,Buffer_2);
   SetIndexBuffer(2,Buffer_3);
   SetIndexBuffer(3,Buffer_4);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexLabel(0,symbol_1);
   SetIndexLabel(1,symbol_2);
   SetIndexLabel(2,symbol_3);
   SetIndexLabel(3,symbol_4);
   return(0);
  }
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("symbol_1");
   ObjectDelete("symbol_2");
   ObjectDelete("symbol_3");
   ObjectDelete("symbol_4");
   ObjectDelete("symbol_5");
   ObjectDelete("symbol_6");
   ObjectDelete("symbol_7");
   ObjectDelete("symbol_1.");
   ObjectDelete("symbol_2.");
   ObjectDelete("symbol_3.");
   ObjectDelete("symbol_4.");
   ObjectDelete("symbol_5.");
   ObjectDelete("symbol_6.");
   ObjectDelete("symbol_7.");
   ObjectDelete("symbol_1..");
   ObjectDelete("symbol_2..");
   ObjectDelete("symbol_3..");
   ObjectDelete("symbol_4..");
   ObjectDelete("symbol_5..");
   ObjectDelete("symbol_6..");
   ObjectDelete("symbol_7..");
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
   int BarsWind;
   if (ControlBars!=0) BarsWind=ControlBars; else BarsWind=WindowFirstVisibleBar();
   double High_Win = High[iHighest(NULL,0,MODE_HIGH,BarsWind,0)];
   double Low_Win  = Low [iLowest (NULL,0,MODE_LOW, BarsWind,0)];
   double H_2=iHigh(symbol_2,0,iHighest(symbol_2,0,MODE_HIGH,BarsWind,0));
   double L_2=iLow (symbol_2,0,iLowest (symbol_2,0,MODE_LOW, BarsWind,0));
   double H_3=iHigh(symbol_3,0,iHighest(symbol_3,0,MODE_HIGH,BarsWind,0));
   double L_3=iLow (symbol_3,0,iLowest (symbol_3,0,MODE_LOW, BarsWind,0));
   double H_4=iHigh(symbol_4,0,iHighest(symbol_4,0,MODE_HIGH,BarsWind,0));
   double L_4=iLow (symbol_4,0,iLowest (symbol_4,0,MODE_LOW, BarsWind,0));
   color WavesColor=White;
   for(int i=BarsWind; i>=0; i--)
   {
      Buffer_1[i]=  iMA(symbol_1,0,N,0,MODE_SMA,PRICE_WEIGHTED,i);
      Buffer_2[i]= (iMA(symbol_2,0,N,0,MODE_SMA,PRICE_WEIGHTED,i) - L_2)/(H_2 - L_2)*(High_Win-Low_Win)+Low_Win;
      Buffer_3[i]= (iMA(symbol_3,0,N,0,MODE_SMA,PRICE_WEIGHTED,i) - L_3)/(H_3 - L_3)*(High_Win-Low_Win)+Low_Win;
      Buffer_4[i]= (iMA(symbol_4,0,N,0,MODE_SMA,PRICE_WEIGHTED,i) - L_4)/(H_4 - L_4)*(High_Win-Low_Win)+Low_Win;
   }
   int delta_1 = (Buffer_1[0]-Buffer_2[0])/Point;
   int delta_2 = (Buffer_1[0]-Buffer_3[0])/Point;
   int delta_3 = (Buffer_1[0]-Buffer_4[0])/Point;
   int delta_4 = (Buffer_2[0]-Buffer_3[0])/Point;
   int delta_5 = (Buffer_2[0]-Buffer_4[0])/Point;
   int delta_6 = (Buffer_3[0]-Buffer_4[0])/Point;
   if (delta_1>0) WavesColor = PlusColor; else WavesColor = MinusColor;
   ObjectSetText("symbol_1",DoubleToStr(delta_1,0),8,"Arial",WavesColor);
   if (delta_2>0) WavesColor = PlusColor; else WavesColor = MinusColor;
   ObjectSetText("symbol_2",DoubleToStr(delta_2,0),8,"Arial",WavesColor);
   if (delta_3>0) WavesColor = PlusColor; else WavesColor = MinusColor;
   ObjectSetText("symbol_3",DoubleToStr(delta_3,0),8,"Arial",WavesColor);
   if (delta_4>0) WavesColor = PlusColor; else WavesColor = MinusColor;
   ObjectSetText("symbol_4",DoubleToStr(delta_4,0),8,"Arial",WavesColor);
   if (delta_5>0) WavesColor = PlusColor; else WavesColor = MinusColor;
   ObjectSetText("symbol_5",DoubleToStr(delta_5,0),8,"Arial",WavesColor);
   if (delta_6>0) WavesColor = PlusColor; else WavesColor = MinusColor;
   ObjectSetText("symbol_6",DoubleToStr(delta_6,0),8,"Arial",WavesColor);
   int sumdelta=delta_1+delta_2+delta_3+delta_4+delta_5+delta_6;
   if (sumdelta>0) WavesColor = PlusColor; else WavesColor = MinusColor;
   ObjectSetText("symbol_7","Total  = "+sumdelta,8,"Arial",WavesColor);
   return(0);
  }
//+------------------------------------------------------------------+