//+------------------------------------------------------------------+
//|   Multi currency pair Indicator                           DM.mq4 |
//+------------------------------------------------------------------+
#property copyright "H.Odhabi"
#property link      "hodhabi@gmail.com"


#property indicator_separate_window


extern int HistoryShift=0;
extern bool DrawVLine=false;
int EURLong=0;
int USDLong=0;
int GBPLong=0;

int scaleX=30,// horizontal interval at which the squares are created
scaleY=20,// vertical interval
offsetX=35, // horizontal indent of all squares
offsetY=20, // vertical indent
fontSize=20; // font size
extern bool enabletrendline=false;
extern int TrendPeriod= 100;
extern int TrendShift = 3;

string periodString[]={"EUR","USD","JPY","GBP","CHF","AUD","CAD"};
string signalNameString[]={"EUR","GBP","USD"};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName("MCP");

   int windowIndex=WindowFind("MCP");

   if(windowIndex<0)
     {
      // if the subwindow number is -1, there is an error
      Print("Can\'t find window");
      return(0);
     }

   for(int x=0;x<7;x++)
      for(int y=0;y<3;y++)
        {
         ObjectCreate("signal"+x+y,OBJ_LABEL,windowIndex,0,0,0,0);
         ObjectSet("signal"+x+y,OBJPROP_XDISTANCE,x*scaleX+offsetX);
         ObjectSet("signal"+x+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
         ObjectSetText("signal"+x+y,CharToStr(110),fontSize,"Wingdings",Gold);
        }

   for(x=0;x<ArraySize(periodString);x++)
     {
      ObjectCreate("textPeriod"+x,OBJ_LABEL,windowIndex,0,0,0,0);
      ObjectSet("textPeriod"+x,OBJPROP_XDISTANCE,x*scaleX+offsetX);
      ObjectSet("textPeriod"+x,OBJPROP_YDISTANCE,offsetY-10);
      ObjectSetText("textPeriod"+x,periodString[x],8,"Tahoma",Red);
     }

   for(y=0;y<ArraySize(signalNameString);y++)
     {
      ObjectCreate("textSignal"+y,OBJ_LABEL,windowIndex,0,0,0,0);
      ObjectSet("textSignal"+y,OBJPROP_XDISTANCE,offsetX-25);
      ObjectSet("textSignal"+y,OBJPROP_YDISTANCE,y*scaleY+offsetY+8);
      ObjectSetText("textSignal"+y,signalNameString[y],8,"Tahoma",Red);
     }
//---- indicators
//----

   if(DrawVLine==true)
     {
      ObjectDelete("V-Line");
      ObjectCreate("V-Line",OBJ_VLINE,0,Time[HistoryShift],Bid);
      ObjectSet("V-Line",OBJPROP_COLOR,Red);
      ObjectSet("V-Line",OBJPROP_STYLE,1);
      ObjectSet("V-Line",OBJPROP_WIDTH,2);
     }

   DisplaySignal();

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {

   for(int x=0;x<7;x++)
      for(int y=0;y<3;y++)
         ObjectDelete("signal"+x+y);

   for(x=0;x<7;x++)
     {
      ObjectDelete("textPeriod"+x);
      ObjectDelete("textSignal"+y);
     }

   ObjectDelete("TrendLine");

//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

   DisplaySignal();
   DrawTrendLine(TrendPeriod,TrendShift);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplaySignal()
  {
   int Ind_count=IndicatorCounted();
   if(Ind_count < 0) return;
   if(Ind_count>0) Ind_count--;
   int lbars=Bars-Ind_count;
   color  Color[4];

   Color[0]= DeepSkyBlue;              // Object color ..
   Color[1]= LightPink;                // .. for different situations
   Color[2]= Yellow;
   Color[3]= Yellow;
   int SignalMAPower=0;
   int SignalRSIPower=0;
   int SignalICCPower=0;

//EUR      
   ObjectDelete("signal"+0+"0");

   if(iClose("EURUSD",0,HistoryShift)>iOpen("EURUSD",0,HistoryShift))
     {
      ObjectSetText("signal"+1+"0",CharToStr(110),fontSize,"Wingdings",Green);
      EURLong++;
     }
   else if(iClose("EURUSD",0,HistoryShift)<iOpen("EURUSD",0,HistoryShift))
     {
      ObjectSetText("signal"+1+"0",CharToStr(110),fontSize,"Wingdings",Red);
      EURLong--;
     }

   if(iClose("EURJPY",0,HistoryShift)>iOpen("EURJPY",0,HistoryShift))
     {
      ObjectSetText("signal"+2+"0",CharToStr(110),fontSize,"Wingdings",Green);
      EURLong++;
     }
   else if(iClose("EURJPY",0,HistoryShift)<iOpen("EURJPY",0,HistoryShift))
     {
      ObjectSetText("signal"+2+"0",CharToStr(110),fontSize,"Wingdings",Red);
      EURLong--;
     }

   if(iClose("EURGBP",0,HistoryShift)>iOpen("EURGBP",0,HistoryShift))
     {
      ObjectSetText("signal"+3+"0",CharToStr(110),fontSize,"Wingdings",Green);
      EURLong++;
     }
   else if(iClose("EURGBP",0,HistoryShift)<iOpen("EURGBP",0,HistoryShift))
     {
      ObjectSetText("signal"+3+"0",CharToStr(110),fontSize,"Wingdings",Red);
      EURLong--;
     }

   if(iClose("EURCHF",0,HistoryShift)>iOpen("EURCHF",0,HistoryShift))
     {
      ObjectSetText("signal"+4+"0",CharToStr(110),fontSize,"Wingdings",Green);
      EURLong++;
     }
   else if(iClose("EURCHF",0,HistoryShift)<iOpen("EURCHF",0,HistoryShift))
     {
      ObjectSetText("signal"+4+"0",CharToStr(110),fontSize,"Wingdings",Red);
      EURLong--;
     }

   if(iClose("EURAUD",0,HistoryShift)>iOpen("EURAUD",0,HistoryShift))
     {
      ObjectSetText("signal"+5+"0",CharToStr(110),fontSize,"Wingdings",Green);
      EURLong++;
     }
   else if(iClose("EURAUD",0,HistoryShift)<iOpen("EURAUD",0,HistoryShift))
     {
      ObjectSetText("signal"+5+"0",CharToStr(110),fontSize,"Wingdings",Red);
      EURLong--;
     }

   if(iClose("EURCAD",0,HistoryShift)>iOpen("EURCAD",0,HistoryShift))
     {
      ObjectSetText("signal"+6+"0",CharToStr(110),fontSize,"Wingdings",Green);
      EURLong++;
     }
   else if(iClose("EURCAD",0,HistoryShift)<iOpen("EURCAD",0,HistoryShift))
     {
      ObjectSetText("signal"+6+"0",CharToStr(110),fontSize,"Wingdings",Red);
      EURLong--;
     }

//GBP

   if(iClose("EURGBP",0,HistoryShift)<iOpen("EURGBP",0,HistoryShift))
     {
      ObjectSetText("signal"+0+"1",CharToStr(110),fontSize,"Wingdings",Green);
      GBPLong++;
     }
   else if(iClose("EURGBP",0,HistoryShift)>iOpen("EURGBP",0,HistoryShift))
     {
      ObjectSetText("signal"+0+"1",CharToStr(110),fontSize,"Wingdings",Red);
      GBPLong--;
     }

   if(iClose("GBPUSD",0,HistoryShift)>iOpen("GBPUSD",0,HistoryShift))
     {
      ObjectSetText("signal"+1+"1",CharToStr(110),fontSize,"Wingdings",Green);
      GBPLong++;
     }
   else if(iClose("GBPUSD",0,HistoryShift)<iOpen("GBPUSD",0,HistoryShift))
     {
      ObjectSetText("signal"+1+"1",CharToStr(110),fontSize,"Wingdings",Red);
      GBPLong--;
     }

   if(iClose("GBPJPY",0,HistoryShift)>iOpen("GBPJPY",0,HistoryShift))
     {
      ObjectSetText("signal"+2+"1",CharToStr(110),fontSize,"Wingdings",Green);
      GBPLong++;
     }
   else if(iClose("GBPJPY",0,HistoryShift)<iOpen("GBPJPY",0,HistoryShift))
     {
      ObjectSetText("signal"+2+"1",CharToStr(110),fontSize,"Wingdings",Red);
      GBPLong--;
     }

   ObjectDelete("signal"+3+"1");

   if(iClose("GBPCHF",0,HistoryShift)>iOpen("GBPCHF",0,HistoryShift))
     {
      ObjectSetText("signal"+4+"1",CharToStr(110),fontSize,"Wingdings",Green);
      GBPLong++;
     }
   else if(iClose("GBPCHF",0,HistoryShift)<iOpen("GBPCHF",0,HistoryShift))
     {
      ObjectSetText("signal"+4+"1",CharToStr(110),fontSize,"Wingdings",Red);
      GBPLong--;
     }

   if(iClose("GBPAUD",0,HistoryShift)>iOpen("GBPAUD",0,HistoryShift))
     {
      ObjectSetText("signal"+5+"1",CharToStr(110),fontSize,"Wingdings",Green);
      GBPLong++;
     }
   else if(iClose("GBPAUD",0,HistoryShift)<iOpen("GBPAUD",0,HistoryShift))
     {
      ObjectSetText("signal"+5+"1",CharToStr(110),fontSize,"Wingdings",Red);
      GBPLong--;
     }

   if(iClose("GBPCAD",0,HistoryShift)>iOpen("GBPCAD",0,HistoryShift))
     {
      ObjectSetText("signal"+6+"1",CharToStr(110),fontSize,"Wingdings",Green);
      GBPLong++;
     }
   else if(iClose("GBPCAD",0,HistoryShift)<iOpen("GBPCAD",0,HistoryShift))
     {
      ObjectSetText("signal"+6+"1",CharToStr(110),fontSize,"Wingdings",Red);
      GBPLong--;
     }

//USD

   if(iClose("EURUSD",0,HistoryShift)<iOpen("EURUSD",0,HistoryShift))
     {
      ObjectSetText("signal"+0+"2",CharToStr(110),fontSize,"Wingdings",Green);
      USDLong++;
     }
   else if(iClose("EURUSD",0,HistoryShift)>iOpen("EURUSD",0,HistoryShift))
     {
      ObjectSetText("signal"+0+"2",CharToStr(110),fontSize,"Wingdings",Red);
      USDLong--;
     }

   ObjectDelete("signal"+1+"2");

   if(iClose("USDJPY",0,HistoryShift)>iOpen("USDJPY",0,HistoryShift))
     {
      ObjectSetText("signal"+2+"2",CharToStr(110),fontSize,"Wingdings",Green);
      USDLong++;
     }
   else if(iClose("USDJPY",0,HistoryShift)<iOpen("USDJPY",0,HistoryShift))
     {
      ObjectSetText("signal"+2+"2",CharToStr(110),fontSize,"Wingdings",Red);
      USDLong--;
     }

   if(iClose("GBPUSD",0,HistoryShift)<iOpen("GBPUSD",0,HistoryShift))
     {
      ObjectSetText("signal"+3+"2",CharToStr(110),fontSize,"Wingdings",Green);
      USDLong++;
     }
   else if(iClose("GBPUSD",0,HistoryShift)>iOpen("GBPUSD",0,HistoryShift))
     {
      ObjectSetText("signal"+3+"2",CharToStr(110),fontSize,"Wingdings",Red);
      USDLong--;
     }

   if(iClose("USDCHF",0,HistoryShift)>iOpen("USDCHF",0,HistoryShift))
     {
      ObjectSetText("signal"+4+"2",CharToStr(110),fontSize,"Wingdings",Green);
      USDLong++;
     }
   else if(iClose("USDCHF",0,HistoryShift)<iOpen("USDCHF",0,HistoryShift))
     {
      ObjectSetText("signal"+4+"2",CharToStr(110),fontSize,"Wingdings",Red);
      USDLong--;
     }

   if(iClose("AUDUSD",0,HistoryShift)<iOpen("AUDUSD",0,HistoryShift))
     {
      ObjectSetText("signal"+5+"2",CharToStr(110),fontSize,"Wingdings",Green);
      USDLong++;
     }
   else if(iClose("AUDUSD",0,HistoryShift)>iOpen("AUDUSD",0,HistoryShift))
     {
      ObjectSetText("signal"+5+"2",CharToStr(110),fontSize,"Wingdings",Red);
      USDLong--;
     }

   if(iClose("USDCAD",0,HistoryShift)>iOpen("USDCAD",0,HistoryShift))
     {
      ObjectSetText("signal"+6+"2",CharToStr(110),fontSize,"Wingdings",Green);
      USDLong++;
     }
   else if(iClose("USDCAD",0,HistoryShift)<iOpen("USDCAD",0,HistoryShift))
     {
      ObjectSetText("signal"+6+"2",CharToStr(110),fontSize,"Wingdings",Red);
      USDLong--;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTrendLine(int period,int shift)
  {
   if(enabletrendline==true)
     {
      ObjectDelete("TrendLine");
      ObjectCreate("TrendLine",OBJ_TREND,0,Time[period],Close[period],Time[shift],Close[shift],0,0);
      ObjectSet("TrendLine",OBJPROP_COLOR,Red);
      ObjectSet("TrendLine",OBJPROP_WIDTH,3);
     }

  }
//+------------------------------------------------------------------+
