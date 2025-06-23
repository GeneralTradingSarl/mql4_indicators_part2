//===================================================================================================================================================//
#property copyright   "Copyright 2014-2017, Nikolaos Pantzos"
#property link        "https://www.mql5.com/en/users/pannik"
#property version     "1.2"
#property description "iBrokerInfo"
#property strict
//===================================================================================================================================================//
#property indicator_chart_window
//===================================================================================================================================================//
extern int SizeBackground=160;
extern int PositionUpDn=150;
//===================================================================================================================================================//
string SymbolExtension="";
int MYpoint=1;
int CornerLabel=3;
int PositionSpread=20;
int PositionLotStep=20;
int PositionMinLot=20;
int PositionMaxLot=5;
int PositionStopLevel=20;
int DigitLot=2;
int PositionLeverage=20;
int Leverage;
int PositionOrders=33;
long MaximumAcceptedOrders;
long ChartColor;
double MinLot;
double MaxLot;
double LotStep;
double StopLevel;
color InformationsColor;
string BackgroundName;
string MaxOrdersStr;
//===================================================================================================================================================//
int OnInit()
  {
   BackgroundName="Background-"+WindowExpertName();
//---------------------------------------------------------------------
   ChartColor=ChartGetInteger(0,CHART_COLOR_BACKGROUND,0);
   if(ObjectFind(BackgroundName)==-1) ChartBackground(BackgroundName,(color)ChartColor,0,16,SizeBackground,SizeBackground);
//------------------------------------------------------
   if(ChartColor==16777215)
     {
      InformationsColor=clrDodgerBlue;
     }
   else
     {
      InformationsColor=clrLightBlue;
     }
//------------------------------------------------------
   if(StringLen(Symbol())>6) SymbolExtension=StringSubstr(Symbol(),6,0);
   if(MarketInfo("EURUSD"+SymbolExtension,MODE_DIGITS)==5) MYpoint=10;
//------------------------------------------------------
   EventSetMillisecondTimer(10);
//------------------------------------------------------
   return(INIT_SUCCEEDED);
//------------------------------------------------------
  }
//===================================================================================================================================================//
void OnDeinit(const int reason)
  {
//------------------------------------------------------
   ObjectDelete("gmt1");
   ObjectDelete("gmt2");
   ObjectDelete("bro1");
   ObjectDelete("bro2");
   ObjectDelete("Leverage1");
   ObjectDelete("Leverage2");
   ObjectDelete("MaxLot1");
   ObjectDelete("MaxLot2");
   ObjectDelete("MinLot1");
   ObjectDelete("MinLot2");
   ObjectDelete("LotStep1");
   ObjectDelete("LotStep2");
   ObjectDelete("StopLevel1");
   ObjectDelete("StopLevel2");
   ObjectDelete("MaxOrders1");
   ObjectDelete("MaxOrders2");
   ObjectDelete("Spread Monitor1");
   ObjectDelete("Spread Monitor2");
   ObjectDelete(BackgroundName);
//------------------------------------------------------
   EventKillTimer();
//------------------------------------------------------
  }
//===================================================================================================================================================//
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//------------------------------------------------------
   MaximumAcceptedOrders=AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
   MinLot=MarketInfo(Symbol(),MODE_MINLOT);
   MaxLot=MarketInfo(Symbol(),MODE_MAXLOT);
   LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
   StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)/MYpoint;
   Leverage=AccountLeverage();
//------------------------------------------------------
   if(MaximumAcceptedOrders==0) MaxOrdersStr="Unlim.";
   if(MaximumAcceptedOrders>0) MaxOrdersStr=IntegerToString(MaximumAcceptedOrders);
//------------------------------------------------------
   return(rates_total);
//------------------------------------------------------
  }
//===================================================================================================================================================//
void OnTimer()
  {
//------------------------------------------------------
   if(PositionUpDn<100) PositionUpDn=150;
   int top=PositionUpDn;
//------------------------------------------------------
   string GMTs=TimeToStr(TimeGMT(),TIME_MINUTES);
   string BROKERs=TimeToStr(TimeCurrent(),TIME_MINUTES);
   double Spread=MarketInfo(Symbol(),MODE_SPREAD)/MYpoint;
//------------------------------------------------------
   if(MaxLot>0) PositionMaxLot=38;
   if(MaxLot>9) PositionMaxLot=30;
   if(MaxLot>99) PositionMaxLot=25;
   if(MaxLot>999) PositionMaxLot=18;
   if(MaxLot>9999) PositionMaxLot=10;
   if(MaxLot>99999) PositionMaxLot=2;
   if(MaxLot>999999) PositionMaxLot=-2;
   if(MinLot<0.01) PositionMinLot=10;
   if(StopLevel>=10) PositionStopLevel=12;
   if(Spread>=10) PositionSpread=13;
   if(Leverage>99) PositionLeverage=10;
   if(Leverage>999) PositionLeverage=5;
   if(MaxLot==0.0) PositionMaxLot=38;
   if(MinLot==0.0) PositionMinLot=20;
   if(Leverage==0) PositionLeverage=25;
   if(MaximumAcceptedOrders>0) PositionOrders=33;
   if(MaximumAcceptedOrders==0) PositionOrders=17;
//------------------------------------------------------
   ObjectMakeLabel("gmt1",70,top);
   ObjectMakeLabel("gmt2",23,top);
   ObjectMakeLabel("bro1",70,top-17);
   ObjectMakeLabel("bro2",23,top-17);
   ObjectMakeLabel("MaxOrders1",70,top-34);
   ObjectMakeLabel("MaxOrders2",PositionOrders,top-34);
   ObjectMakeLabel("Leverage1",70,top-51);
   ObjectMakeLabel("Leverage2",PositionLeverage+23,top-51);
   ObjectMakeLabel("MaxLot1",70,top-68);
   ObjectMakeLabel("MaxLot2",PositionMaxLot+10,top-68);
   ObjectMakeLabel("MinLot1",70,top-85);
   ObjectMakeLabel("MinLot2",PositionMinLot+10,top-85);
   ObjectMakeLabel("LotStep1",70,top-102);
   ObjectMakeLabel("LotStep2",PositionLotStep+10,top-102);
   ObjectMakeLabel("StopLevel1",70,top-119);
   ObjectMakeLabel("StopLevel2",PositionStopLevel+10,top-119);
   ObjectMakeLabel("Spread Monitor1",70,top-136);
   ObjectMakeLabel("Spread Monitor2",PositionSpread+10,top-136);
//------------------------------------------------------
   ObjectSetText("gmt1","GMTtime:",10,"Arial",InformationsColor);
   ObjectSetText("gmt2",GMTs,10,"Arial",clrOrangeRed);
   ObjectSetText("bro1","BROKERtime:",10,"Arial",InformationsColor);
   ObjectSetText("bro2",BROKERs,10,"Arial",clrOrangeRed);
   ObjectSetText("MaxOrders1","MaxOrders:",10,"Arial",InformationsColor);
   ObjectSetText("MaxOrders2",MaxOrdersStr,10,"Arial",clrOrange);
   ObjectSetText("Leverage1","Leverage:",10,"Arial",InformationsColor);
   ObjectSetText("Leverage2",DoubleToStr(Leverage,0),10,"Arial",clrOrange);
   ObjectSetText("MaxLot1","MaximumLot:",10,"Arial",InformationsColor);
   ObjectSetText("MaxLot2",DoubleToStr(MaxLot,0),10,"Arial",clrOrange);
   ObjectSetText("MinLot1","MinimumLot:",10,"Arial",InformationsColor);
   ObjectSetText("MinLot2",DoubleToStr(MinLot,2),10,"Arial",clrOrange);
   ObjectSetText("LotStep1","LotStep:",10,"Arial",InformationsColor);
   ObjectSetText("LotStep2",DoubleToStr(LotStep,2),10,"Arial",clrOrange);
   ObjectSetText("StopLevel1","StopLevel:",10,"Arial",InformationsColor);
   ObjectSetText("StopLevel2",DoubleToStr(StopLevel,2),10,"Arial",clrOrange);
   ObjectSetText("Spread Monitor1","SpreadPips:",10,"Arial",InformationsColor);
   ObjectSetText("Spread Monitor2",DoubleToStr(Spread,2),10,"Arial",clrRed);
//------------------------------------------------------
  }
//====================================================================================================================================================//
void ChartBackground(string StringName,color ImageColor,int Xposition,int Yposition,int Xsize,int Ysize)
  {
//---------------------------------------------------------------------
   ObjectCreate(0,StringName,OBJ_RECTANGLE_LABEL,0,0,0,0,0);
   ObjectSetInteger(0,StringName,OBJPROP_CORNER,CornerLabel);
   ObjectSetInteger(0,StringName,OBJPROP_XDISTANCE,165);
   ObjectSetInteger(0,StringName,OBJPROP_YDISTANCE,PositionUpDn+18);
   ObjectSetInteger(0,StringName,OBJPROP_XSIZE,Xsize);
   ObjectSetInteger(0,StringName,OBJPROP_YSIZE,Ysize);
   ObjectSetInteger(0,StringName,OBJPROP_BGCOLOR,ImageColor);
   ObjectSetInteger(0,StringName,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,StringName,OBJPROP_BORDER_COLOR,clrBlack);
   ObjectSetInteger(0,StringName,OBJPROP_BACK,false);
   ObjectSetInteger(0,StringName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,StringName,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,StringName,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,StringName,OBJPROP_ZORDER,0);
//---------------------------------------------------------------------
  }
//===================================================================================================================================================//
int ObjectMakeLabel(string Label,int xoff,int yoff)
  {
//------------------------------------------------------
   ObjectCreate(Label,OBJ_LABEL,0,0,0);
   ObjectSet(Label,OBJPROP_CORNER,CornerLabel);
   ObjectSet(Label,OBJPROP_XDISTANCE,xoff);
   ObjectSet(Label,OBJPROP_YDISTANCE,yoff);
   ObjectSet(Label,OBJPROP_BACK,false);
   ObjectSet(Label,OBJPROP_SELECTABLE,false);
   ObjectSet(Label,OBJPROP_SELECTED,false);
   ObjectSet(Label,OBJPROP_HIDDEN,true);
   ObjectSet(Label,OBJPROP_ZORDER,0);
//------------------------------------------------------
   ObjectsRedraw();
//------------------------------------------------------
   return(0);
//------------------------------------------------------
  }
//===================================================================================================================================================//
