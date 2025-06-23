//+------------------------------------------------------------------+
//|                                                GG-TimeFramer.mq4 |
//|                                         Copyright © 2009, GGekko |
//|                                         http://www.fx-ggekko.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, GGekko"
#property link      "http://www.fx-ggekko.com"

#property indicator_separate_window
#property indicator_buffers 2

extern string   __Copyright__          = "www.fx-ggekko.com";
extern bool     Show_Daily_HighLow     = true;
extern bool     Show_H4_HighLow        = false;
extern bool     Show_H1_HighLow        = false;
extern bool     Show_M30_HighLow       = false;
extern bool     Show_M15_HighLow       = false;
extern bool     Show_M5_HighLow        = false;
extern color    UpColor                = YellowGreen;
extern color    DojiColor              = Silver;
extern color    DownColor              = Tomato;
extern color    TextColor              = DarkSlateGray;
extern color    PriceLineColor         = DarkGreen;
extern color    HighLowColor           = SlateGray;
extern color    SeparatorColor         = Orange;
extern int      CandleWidth            = 10;


double M1_O,M1_H,M1_L;
double M5_O,M5_H,M5_L;
double M15_O,M15_H,M15_L;
double M30_O,M30_H,M30_L;
double H1_O,H1_H,H1_L;
double H4_O,H4_H,H4_L;
double D1_O,D1_H,D1_L;

color Color_M1,Color_M5,Color_M15,Color_M30,Color_H1,Color_H4,Color_D1;


//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(2);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_NONE);
   
   
   IndicatorShortName("GG-TimeFramer (www.fx-ggekko.com)"); 
      
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----

   ObjectDelete("D1TF");
   ObjectDelete("H4TF");
   ObjectDelete("H1TF");
   ObjectDelete("M30TF");
   ObjectDelete("M15TF");
   ObjectDelete("M5TF");
   ObjectDelete("M1TF");
   ObjectDelete("D1");
   ObjectDelete("H4");
   ObjectDelete("H1");
   ObjectDelete("M30");
   ObjectDelete("M15");
   ObjectDelete("M5");
   ObjectDelete("M1");
   ObjectDelete("PriceLine");
   ObjectDelete("D1HighLine");
   ObjectDelete("D1LowLine");
   ObjectDelete("H4HighLine");
   ObjectDelete("H4LowLine");
   ObjectDelete("H1HighLine");
   ObjectDelete("H1LowLine");
   ObjectDelete("M30HighLine");
   ObjectDelete("M30LowLine");
   ObjectDelete("M15HighLine");
   ObjectDelete("M15LowLine");
   ObjectDelete("M5HighLine");
   ObjectDelete("M5LowLine");
   ObjectDelete("SeparatorLineD1");
   ObjectDelete("SeparatorLineH4");
   ObjectDelete("SeparatorLineH1");
   ObjectDelete("SeparatorLineM30");
   ObjectDelete("SeparatorLineM15");
   ObjectDelete("SeparatorLineM5");
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
   M1_O=iOpen(NULL,1,0);
   M1_H=iHigh(NULL,1,0);
   M1_L=iLow(NULL,1,0);
   M5_O=iOpen(NULL,5,0);
   M5_H=iHigh(NULL,5,0);
   M5_L=iLow(NULL,5,0);
   M15_O=iOpen(NULL,15,0);
   M15_H=iHigh(NULL,15,0);
   M15_L=iLow(NULL,15,0);
   M30_O=iOpen(NULL,30,0);
   M30_H=iHigh(NULL,30,0);
   M30_L=iLow(NULL,30,0);
   H1_O=iOpen(NULL,60,0);
   H1_H=iHigh(NULL,60,0);
   H1_L=iLow(NULL,60,0);
   H4_O=iOpen(NULL,240,0);
   H4_H=iHigh(NULL,240,0);
   H4_L=iLow(NULL,240,0);
   D1_O=iOpen(NULL,1440,0);
   D1_H=iHigh(NULL,1440,0);
   D1_L=iLow(NULL,1440,0);
   
   
   ExtMapBuffer1[WindowFirstVisibleBar()]=D1_H+5*Point;
   ExtMapBuffer2[WindowFirstVisibleBar()]=D1_L-5*Point;
         
     
   ObjectDelete("D1TF");
   ObjectCreate("D1TF",OBJ_TEXT,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[7*CandleWidth-1],Bid);
   ObjectSetText("D1TF","   Daily",8,"Tahoma",TextColor);
   ObjectDelete("H4TF");
   ObjectCreate("H4TF",OBJ_TEXT,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[6*CandleWidth-1],Bid);
   ObjectSetText("H4TF"," H4",8,"Tahoma",TextColor);
   ObjectDelete("H1TF");
   ObjectCreate("H1TF",OBJ_TEXT,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[5*CandleWidth-1],Bid);
   ObjectSetText("H1TF"," H1",8,"Tahoma",TextColor);
   ObjectDelete("M30TF");
   ObjectCreate("M30TF",OBJ_TEXT,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[4*CandleWidth-1],Bid);
   ObjectSetText("M30TF","   M30",8,"Tahoma",TextColor);
   ObjectDelete("M15TF");
   ObjectCreate("M15TF",OBJ_TEXT,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[3*CandleWidth-1],Bid);
   ObjectSetText("M15TF","   M15",8,"Tahoma",TextColor);
   ObjectDelete("M5TF");
   ObjectCreate("M5TF",OBJ_TEXT,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[2*CandleWidth-1],Bid);
   ObjectSetText("M5TF"," M5",8,"Tahoma",TextColor);
   ObjectDelete("M1TF");
   ObjectCreate("M1TF",OBJ_TEXT,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[1*CandleWidth-1],Bid);
   ObjectSetText("M1TF"," M1",8,"Tahoma",TextColor);
   
   
   if(M1_O>Bid) Color_M1=DownColor;
   else if(M1_O<Bid) Color_M1=UpColor;
   else Color_M1=DojiColor;
   if(M5_O>Bid) Color_M5=DownColor;
   else if(M5_O<Bid) Color_M5=UpColor;
   else Color_M5=DojiColor;
   if(M15_O>Bid) Color_M15=DownColor;
   else if(M15_O<Bid) Color_M15=UpColor;
   else Color_M15=DojiColor;
   if(M30_O>Bid) Color_M30=DownColor;
   else if(M30_O<Bid) Color_M30=UpColor;
   else Color_M30=DojiColor;
   if(H1_O>Bid) Color_H1=DownColor;
   else if(H1_O<Bid) Color_H1=UpColor;
   else Color_H1=DojiColor;
   if(H4_O>Bid) Color_H4=DownColor;
   else if(H4_O<Bid) Color_H4=UpColor;
   else Color_H4=DojiColor;
   if(D1_O>Bid) Color_D1=DownColor;
   else if(D1_O<Bid) Color_D1=UpColor;
   else Color_D1=DojiColor;

   
   ObjectDelete("D1");
   ObjectCreate("D1",OBJ_RECTANGLE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[7*CandleWidth],D1_L,Time[6*CandleWidth],D1_H);
   ObjectSet("D1",OBJPROP_COLOR,Color_D1);
   ObjectDelete("H4");
   ObjectCreate("H4",OBJ_RECTANGLE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[6*CandleWidth],H4_L,Time[5*CandleWidth],H4_H);
   ObjectSet("H4",OBJPROP_COLOR,Color_H4);
   ObjectDelete("H1");
   ObjectCreate("H1",OBJ_RECTANGLE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[5*CandleWidth],H1_L,Time[4*CandleWidth],H1_H);
   ObjectSet("H1",OBJPROP_COLOR,Color_H1);
   ObjectDelete("M30");
   ObjectCreate("M30",OBJ_RECTANGLE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[4*CandleWidth],M30_L,Time[3*CandleWidth],M30_H);
   ObjectSet("M30",OBJPROP_COLOR,Color_M30);
   ObjectDelete("M15");
   ObjectCreate("M15",OBJ_RECTANGLE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[3*CandleWidth],M15_L,Time[2*CandleWidth],M15_H);
   ObjectSet("M15",OBJPROP_COLOR,Color_M15);
   ObjectDelete("M5");
   ObjectCreate("M5",OBJ_RECTANGLE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[2*CandleWidth],M5_L,Time[1*CandleWidth],M5_H);
   ObjectSet("M5",OBJPROP_COLOR,Color_M5);
   ObjectDelete("M1");
   ObjectCreate("M1",OBJ_RECTANGLE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[1*CandleWidth],M1_L,Time[0*CandleWidth],M1_H);
   ObjectSet("M1",OBJPROP_COLOR,Color_M1);
   
 
     
   ObjectDelete("PriceLine");
   ObjectCreate("PriceLine",OBJ_HLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[WindowFirstVisibleBar()],Bid);
   ObjectSet("PriceLine",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet("PriceLine",OBJPROP_COLOR,PriceLineColor);
  
   
   
   ObjectDelete("D1HighLine");
   ObjectDelete("D1LowLine");
   if(Show_Daily_HighLow)
   {
   ObjectCreate("D1HighLine",OBJ_HLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[WindowFirstVisibleBar()],D1_H);
   ObjectSet("D1HighLine",OBJPROP_STYLE,STYLE_DOT);
   ObjectSet("D1HighLine",OBJPROP_COLOR,HighLowColor);
   
   ObjectCreate("D1LowLine",OBJ_HLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[WindowFirstVisibleBar()],D1_L);
   ObjectSet("D1LowLine",OBJPROP_STYLE,STYLE_DOT);
   ObjectSet("D1LowLine",OBJPROP_COLOR,HighLowColor);
   }
   
   ObjectDelete("H4HighLine");
   ObjectDelete("H4LowLine");
   if(Show_H4_HighLow)
   {
   ObjectCreate("H4HighLine",OBJ_HLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[WindowFirstVisibleBar()],H4_H);
   ObjectSet("H4HighLine",OBJPROP_STYLE,STYLE_DOT);
   ObjectSet("H4HighLine",OBJPROP_COLOR,HighLowColor);
   
   ObjectCreate("H4LowLine",OBJ_HLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[WindowFirstVisibleBar()],H4_L);
   ObjectSet("H4LowLine",OBJPROP_STYLE,STYLE_DOT);
   ObjectSet("H4LowLine",OBJPROP_COLOR,HighLowColor);
   }
   
   ObjectDelete("H1HighLine");
   ObjectDelete("H1LowLine");
   if(Show_H1_HighLow)
   {
   ObjectCreate("H1HighLine",OBJ_HLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[WindowFirstVisibleBar()],H1_H);
   ObjectSet("H1HighLine",OBJPROP_STYLE,STYLE_DOT);
   ObjectSet("H1HighLine",OBJPROP_COLOR,HighLowColor);
   
   ObjectCreate("H1LowLine",OBJ_HLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[WindowFirstVisibleBar()],H1_L);
   ObjectSet("H1LowLine",OBJPROP_STYLE,STYLE_DOT);
   ObjectSet("H1LowLine",OBJPROP_COLOR,HighLowColor);
   }
   
   ObjectDelete("M30HighLine");
   ObjectDelete("M30LowLine");
   if(Show_M30_HighLow)
   {
   ObjectCreate("M30HighLine",OBJ_HLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[WindowFirstVisibleBar()],M30_H);
   ObjectSet("M30HighLine",OBJPROP_STYLE,STYLE_DOT);
   ObjectSet("M30HighLine",OBJPROP_COLOR,HighLowColor);
   
   ObjectCreate("M30LowLine",OBJ_HLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[WindowFirstVisibleBar()],M30_L);
   ObjectSet("M30LowLine",OBJPROP_STYLE,STYLE_DOT);
   ObjectSet("M30LowLine",OBJPROP_COLOR,HighLowColor);
   }
   
   ObjectDelete("M15HighLine");
   ObjectDelete("M15LowLine");
   if(Show_M15_HighLow)
   {
   ObjectCreate("M15HighLine",OBJ_HLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[WindowFirstVisibleBar()],M15_H);
   ObjectSet("M15HighLine",OBJPROP_STYLE,STYLE_DOT);
   ObjectSet("M15HighLine",OBJPROP_COLOR,HighLowColor);
   
   ObjectCreate("M15LowLine",OBJ_HLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[WindowFirstVisibleBar()],M15_L);
   ObjectSet("M15LowLine",OBJPROP_STYLE,STYLE_DOT);
   ObjectSet("M15LowLine",OBJPROP_COLOR,HighLowColor);
   }
   
   ObjectDelete("M5HighLine");
   ObjectDelete("M5LowLine");
   if(Show_M5_HighLow)
   {
   ObjectCreate("M5HighLine",OBJ_HLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[WindowFirstVisibleBar()],M5_H);
   ObjectSet("M5HighLine",OBJPROP_STYLE,STYLE_DOT);
   ObjectSet("M5HighLine",OBJPROP_COLOR,HighLowColor);
   
   ObjectCreate("M5LowLine",OBJ_HLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[WindowFirstVisibleBar()],M5_L);
   ObjectSet("M5LowLine",OBJPROP_STYLE,STYLE_DOT);
   ObjectSet("M5LowLine",OBJPROP_COLOR,HighLowColor);
   }
   
      
   
   ObjectDelete("SeparatorLineD1");
   ObjectCreate("SeparatorLineD1",OBJ_VLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[1*CandleWidth],0);
   ObjectSet("SeparatorLineD1",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet("SeparatorLineD1",OBJPROP_COLOR,SeparatorColor);
   ObjectDelete("SeparatorLineH4");
   ObjectCreate("SeparatorLineH4",OBJ_VLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[2*CandleWidth],0);
   ObjectSet("SeparatorLineH4",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet("SeparatorLineH4",OBJPROP_COLOR,SeparatorColor);
   ObjectDelete("SeparatorLineH1");
   ObjectCreate("SeparatorLineH1",OBJ_VLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[3*CandleWidth],0);
   ObjectSet("SeparatorLineH1",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet("SeparatorLineH1",OBJPROP_COLOR,SeparatorColor);
   ObjectDelete("SeparatorLineM30");
   ObjectCreate("SeparatorLineM30",OBJ_VLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[4*CandleWidth],0);
   ObjectSet("SeparatorLineM30",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet("SeparatorLineM30",OBJPROP_COLOR,SeparatorColor);
   ObjectDelete("SeparatorLineM15");
   ObjectCreate("SeparatorLineM15",OBJ_VLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[5*CandleWidth],0);
   ObjectSet("SeparatorLineM15",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet("SeparatorLineM15",OBJPROP_COLOR,SeparatorColor);
   ObjectDelete("SeparatorLineM5");
   ObjectCreate("SeparatorLineM5",OBJ_VLINE,WindowFind("GG-TimeFramer (www.fx-ggekko.com)"),Time[6*CandleWidth],0);
   ObjectSet("SeparatorLineM5",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet("SeparatorLineM5",OBJPROP_COLOR,SeparatorColor);
     
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+