//====================================================================================================================================================//
#property copyright   "Copyright 2018, Nikolaos Pantzos"
#property link        "https://www.mql5.com/en/users/pannik"
#property version     "1.0"
#property description "Attach indicator on chart to want show history orders, no matter what time frame."
//#property icon        "\\Images\\iPlotterHistoryOrders-Logo.ico";
#property strict
//====================================================================================================================================================//
enum Corn{Up_Left,Up_Right,Dn_Left,Dn_Right};
//====================================================================================================================================================//
#property indicator_chart_window
//====================================================================================================================================================//
extern bool  DeleteObjects= false;//Delete Objects If Terminated Indicator
extern int   SizeFontsOfInfo = 10;//Size Fonts Of Info On Chart
extern color TextColor=clrLightGray;//Color Of Text On Chart
extern Corn  CornerTextShow=Dn_Right;//Corner To Show Text On Chart
//====================================================================================================================================================//
int LastCurrentOrders=-1;
int LastHistoryOrders=-1;
int DigitsPoints;
int TotalHistoryOrders;
datetime TimeFirstOrder;
datetime TimeLastOrder;
//====================================================================================================================================================//
int OnInit()
  {
//---------------------------------------------------------------------------
   DigitsPoints=1;
   if((MarketInfo(Symbol(),MODE_DIGITS)==5) || (MarketInfo(Symbol(),MODE_DIGITS)==3)) DigitsPoints=10;
//---------------------------------------------------------------------------
   return(INIT_SUCCEEDED);
//---------------------------------------------------------------------------
  }
//====================================================================================================================================================//
void OnDeinit(const int reason)
  {
//---------------------------------------------------------------------------
   int ObjectTotal=ObjectsTotal();
//---------------------------------------------------------------------------
   if(DeleteObjects==true)
     {
      for(int i=ObjectTotal; i>=0; i--)
        {
         if(StringSubstr(ObjectName(i),0,2)=="# ") ObjectDelete(ObjectName(i));
         if(ObjectFind("Text"+IntegerToString(i))>-1) ObjectDelete("Text"+IntegerToString(i));
        }
     }
//---------------------------------------------------------------------------
  }
//====================================================================================================================================================//
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
//---------------------------------------------------------------------------
   int cnt;
   int CurrentOrders=OrdersTotal();
   int HistoryOrders=OrdersHistoryTotal();
   color ColorArrowsOpen=clrNONE;
   color ColorArrowsClose=clrNONE;
   color ColorLines=clrNONE;
   string PL="";
//---------------------------------------------------------------------------
   TotalHistoryOrders=0;
   TimeFirstOrder=0;
   TimeLastOrder=0;
//---------------------------------------------------------------------------
   if((LastCurrentOrders==CurrentOrders)&&(LastHistoryOrders==HistoryOrders)) return(0);
//---------------------------------------------------------------------------
//Plot Orders History 
   for(cnt=0; cnt<=HistoryOrders; cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderSymbol()==Symbol())
           {
            //---
            if(TimeFirstOrder==0) TimeFirstOrder=OrderOpenTime();
            TimeLastOrder=OrderOpenTime();
            TotalHistoryOrders++;
            //---
            if(OrderType()==OP_BUY)
              {
               ColorArrowsOpen=clrBlue;
               ColorArrowsClose=clrAquamarine;
               ColorLines=clrBlue;
               PL=DoubleToStr((OrderClosePrice()-OrderOpenPrice())/Point/DigitsPoints,1)+" pips";
              }
            //---
            if(OrderType()==OP_SELL)
              {
               ColorArrowsOpen=clrRed;
               ColorArrowsClose=clrViolet;
               ColorLines=clrRed;
               PL=DoubleToStr((OrderOpenPrice()-OrderClosePrice())/Point/DigitsPoints,1)+" pips";
              }
            //---
            if((OrderType()==OP_BUY) || (OrderType()==OP_SELL))
              {
               ObjectCreate("# "+IntegerToString(OrderTicket())+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),OBJ_ARROW,0,OrderOpenTime(),OrderOpenPrice());
               ObjectSet("# "+IntegerToString(OrderTicket())+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),6,ColorArrowsOpen);
               ObjectSet("# "+IntegerToString(OrderTicket())+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),14,1);
               //---
               ObjectCreate("# "+IntegerToString(OrderTicket())+" : Close at "+TimeToStr(OrderCloseTime(),TIME_MINUTES),OBJ_ARROW,0,OrderCloseTime(),OrderClosePrice());
               ObjectSet("# "+IntegerToString(OrderTicket())+" : Close at "+TimeToStr(OrderCloseTime(),TIME_MINUTES),6,ColorArrowsClose);
               ObjectSet("# "+IntegerToString(OrderTicket())+" : Close at "+TimeToStr(OrderCloseTime(),TIME_MINUTES),14,3);
               //---
               ObjectCreate("# "+IntegerToString(OrderTicket())+" : "+PL,OBJ_TREND,0,OrderOpenTime(),OrderOpenPrice(),OrderCloseTime(),OrderClosePrice());
               ObjectSet("# "+IntegerToString(OrderTicket())+" : "+PL,6,ColorLines);
               ObjectSet("# "+IntegerToString(OrderTicket())+" : "+PL,7,2);
               ObjectSet("# "+IntegerToString(OrderTicket())+" : "+PL,10,false);
              }
           }
        }
     }
//---------------------------------------------------------------------------
//Plot current orders
   for(cnt=0;cnt<=CurrentOrders;cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol())
           {
            if(OrderType()==OP_BUY) ColorArrowsOpen=clrBlue;
            if(OrderType()==OP_SELL) ColorArrowsOpen=clrRed;
            if((OrderType()==OP_BUY) || (OrderType()==OP_SELL))
              {
               ObjectCreate("# "+IntegerToString(OrderTicket())+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),OBJ_ARROW,0,OrderOpenTime(),OrderOpenPrice());
               ObjectSet("# "+IntegerToString(OrderTicket())+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),6,ColorArrowsOpen);
               ObjectSet("# "+IntegerToString(OrderTicket())+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),14,1);
              }
           }
        }
     }
//---------------------------------------------------------------------------
   LastCurrentOrders=CurrentOrders;
   LastHistoryOrders=HistoryOrders;
//---------------------------------------------------------------------------
   CommentChart();
//-----------------------------------------------------------------------------------
   return(rates_total);
//---------------------------------------------------------------------------
  }
//====================================================================================================================================================//
void DisplayText(string StringName,string Image,int FontSize,string TypeImage,color FontColor,int Xposition,int Yposition)
  {
//---------------------------------------------------------------------
   ObjectCreate(StringName,OBJ_LABEL,0,0,0);
   ObjectSet(StringName,OBJPROP_CORNER,CornerTextShow);
   ObjectSet(StringName,OBJPROP_BACK,FALSE);
   ObjectSet(StringName,OBJPROP_XDISTANCE,Xposition);
   ObjectSet(StringName,OBJPROP_YDISTANCE,Yposition);
   ObjectSet(StringName,OBJPROP_SELECTABLE,FALSE);
   ObjectSet(StringName,OBJPROP_SELECTED,FALSE);
   ObjectSet(StringName,OBJPROP_HIDDEN,TRUE);
   ObjectSetText(StringName,Image,FontSize,TypeImage,FontColor);
//---------------------------------------------------------------------
  }
//====================================================================================================================================================//
void CommentChart()
  {
//---------------------------------------------------------------------------
   int PosX=20;
   int PosY=20;
   int PositionY1=0;
   int PositionY2=0;
   int PositionY3=0;
   int PositionX1=0;
   int PositionX2=0;
   int PositionX3=0;
//---------------------------------------------------------------------------
   if((CornerTextShow==0)||(CornerTextShow==1)) {PositionY1=0; PositionY2=15; PositionY3=30;}
   if((CornerTextShow==2)||(CornerTextShow==3)) {PositionY1=30; PositionY2=15; PositionY3=0;}
   if((CornerTextShow==1)||(CornerTextShow==3))
     {
      if(TotalHistoryOrders<=9) PositionX1=124;
      if(TotalHistoryOrders>=10) PositionX1=114;
      if(TotalHistoryOrders>=100) PositionX1=104;
      if(TotalHistoryOrders>=1000) PositionX1=94;
     }
//---------------------------------------------------------------------------
//---Text1
   ObjectDelete("Text1");
   if(ObjectFind("Text1")==-1) DisplayText("Text1"," Sum History Orders: "+IntegerToString(TotalHistoryOrders),SizeFontsOfInfo,"Arial Black",TextColor,PosX+PositionX1,PosY+PositionY1);
//---Text2
   ObjectDelete("Text2");
   if(ObjectFind("Text2")==-1) DisplayText("Text2"," First History Order: "+TimeToStr(TimeFirstOrder,TIME_DATE)+" @ "+TimeToStr(TimeFirstOrder,TIME_MINUTES),SizeFontsOfInfo,"Arial Black",TextColor,PosX+PositionX2,PosY+PositionY2);
//---Text3
   ObjectDelete("Text3");
   if(ObjectFind("Text3")==-1) DisplayText("Text3"," Last History Order: "+TimeToStr(TimeLastOrder,TIME_DATE)+" @ "+TimeToStr(TimeLastOrder,TIME_MINUTES),SizeFontsOfInfo,"Arial Black",TextColor,PosX+PositionX3,PosY+PositionY3);
//---------------------------------------------------------------------------
  }
//====================================================================================================================================================//
