//+------------------------------------------------------------------+
//|                                   Money_Manager_Graphic_Tool.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Girard Matthieu"
#property link      "https://www.mql5.com"
#property version   "1.03"
//Add Magic Number
//Add button hide SL
//Correction on using Money_Manager_Graphic_Tool and Money_Manager_EA more than once
#property script_show_inputs
#property indicator_chart_window
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Lot
  {
   StandardLot,     //Standard Lot 1
   MiniLot,         //Mini Lot 0.1
   MicroLot,        //Micro Lot 0.01
  };
extern string  BuyLine="B";               //Key to Create a Buy Line
extern string  SellLine="S";              //Key to Create a Sell Line
extern int     Risk=2;                    //Your Percentage Risk
extern double  DefaultSL=30;              //Default SL in Pips
extern color   ColorBuySell=clrGreen;     //Color of the Buy or Sell line
extern color   ColorSL=clrRed;            //Color of the SL line
extern color   ColorTP=clrDarkOrange;           //Color of the TP line
extern color   ColorTextBox=clrWhite;     //Color of text in the toolbox
extern ENUM_LINE_STYLE  LineStyle=STYLE_SOLID;  //Style of Lines
extern int     Linewidth=2;                     //Choose the width of the line
extern bool    Account=true;                    //Choose Balance [true] or Equity [false]
extern bool    CreateTP=true;                   //Create a Take Profit line
extern bool    CreateSL=true;                   //not anymore money management, but asked by users
extern bool    TransparancyBox=false;          //The dialog box is transparent
extern color   BoxColor=clrBlack;             //Background box color
extern int     MagicNumber=951357;            //Magic Number

datetime       labelposition;             //label position on screen
int            x=50;                      // axe x start
int            y=130;                     // axe y start 
double         price =0;                  //keep the mouse price
int            xmouse;                    //the x coordonate of the mouse
int            ymouse;                    //the y coordonate of the mouse
double         ratioposition=0.50;
ENUM_ACCOUNT_INFO_DOUBLE         accounttype=ACCOUNT_BALANCE;
string         balanceequity;
double         lotsizemaximum;
double         riskmoney;
double         PipValuesonelot;
double         PipValues;
double         point;
int            divide;
int            minus;
string         ratio;
double         sandboxrisk;
double         sandboxlotsize=-1;
string         onoff;
color          onoffcolor;
bool           followprice=false;
string         YesNo;
color          YesNocolor;
double         SLPips;
double         TPPips;
double         SLTPbrokerLimit;
double         MaximumLot;
double         MinimumLotSize;
double         LotStep;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(WindowFirstVisibleBar()>0)
     {
      labelposition=Time[int(WindowFirstVisibleBar()*0.7)];
     }
   if(Digits==1){minus=1;divide=10;}
   if(Digits==2){minus=0;divide=1;}
   if(Digits==3){minus=1;divide=10;}
   if(Digits==4){minus=0;divide=1;}
   if(Digits==5){minus=1;divide=10;}
   SLTPbrokerLimit=MarketInfo(Symbol(),MODE_STOPLEVEL);
   MaximumLot=MarketInfo(Symbol(),MODE_MAXLOT);
   MinimumLotSize=MarketInfo(Symbol(),MODE_MINLOT);
   LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);

   if(Account){accounttype=ACCOUNT_BALANCE;balanceequity="Balance";}else{accounttype=ACCOUNT_EQUITY;balanceequity="Equity";}
   if(!TransparancyBox)
     {
      RectLabelCreate(0,"MMGTbox_RectLabel",0,int(x-10),int(y-10),480,240,clrBlack,BORDER_SUNKEN,CORNER_LEFT_UPPER,clrRed,STYLE_SOLID,1,false,false,false,0);
      ObjectSetString(0,"MMGTbox_RectLabel",OBJPROP_TOOLTIP,"");
      ObjectSetInteger(0,"MMGTbox_RectLabel",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
     }

   RectLabelCreate(0,"MMGTbox_RecMov",0,x,y,10,10,clrBlack,BORDER_FLAT,CORNER_LEFT_UPPER,ColorTextBox,STYLE_SOLID,3,false,true,true,0);
   ObjectSetInteger(0,"MMGTbox_RecMov",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   point=Point;
   if((Digits==3) || (Digits==5) || (Digits==1)){point*=10;}
   PipValuesonelot=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*1);
   sandboxrisk=Risk;
//Line 1
   ObjectCreate("MMGTbox_Line1",OBJ_LABEL,0,0,0);
   ObjectSet("MMGTbox_Line1",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
   ObjectSet("MMGTbox_Line1",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+10);
   ObjectSetInteger(0,"MMGTbox_Line1",OBJPROP_SELECTABLE,false);
   ObjectSetString(0,"MMGTbox_Line1",OBJPROP_TOOLTIP,"Risk % = Risk "+AccountInfoString(ACCOUNT_CURRENCY)+" / Account Size");
   ObjectSetInteger(0,"MMGTbox_Line1",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   riskmoney=double(AccountInfoDouble(accounttype))/100*Risk;
   ObjectSetText("MMGTbox_Line1","Risk         : "+DoubleToStr(Risk,2)+"% = "+DoubleToStr(riskmoney,2)+" "+AccountInfoString(ACCOUNT_CURRENCY)+" / "+balanceequity+" "+DoubleToStr(AccountInfoDouble(accounttype),2)+" "+AccountInfoString(ACCOUNT_CURRENCY),10,"Courier New",ColorTextBox);
//Line 2
   ObjectCreate("MMGTbox_Line2",OBJ_LABEL,0,0,0);
   ObjectSet("MMGTbox_Line2",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
   ObjectSet("MMGTbox_Line2",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+25);
   ObjectSetInteger(0,"MMGTbox_Line2",OBJPROP_SELECTABLE,false);
   ObjectSetString(0,"MMGTbox_Line2",OBJPROP_TOOLTIP,"Ratio");
   ObjectSetInteger(0,"MMGTbox_Line2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ObjectSetText("MMGTbox_Line2","",10,"Courier New",ColorTextBox);
//Line 3
   ObjectCreate("MMGTbox_Line3",OBJ_LABEL,0,0,0);
   ObjectSet("MMGTbox_Line3",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
   ObjectSet("MMGTbox_Line3",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+40);
   ObjectSetInteger(0,"MMGTbox_Line3",OBJPROP_SELECTABLE,false);
   ObjectSetString(0,"MMGTbox_Line3",OBJPROP_TOOLTIP,"SL pips & value");
   ObjectSetInteger(0,"MMGTbox_Line3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ObjectSetText("MMGTbox_Line3","",10,"Courier New",ColorTextBox);
//Line 4
   ObjectCreate("MMGTbox_Line4",OBJ_LABEL,0,0,0);
   ObjectSet("MMGTbox_Line4",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
   ObjectSet("MMGTbox_Line4",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+55);
   ObjectSetInteger(0,"MMGTbox_Line4",OBJPROP_SELECTABLE,false);
   ObjectSetString(0,"MMGTbox_Line4",OBJPROP_TOOLTIP,"TP pips & value");
   ObjectSetInteger(0,"MMGTbox_Line4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ObjectSetText("MMGTbox_Line4","",10,"Courier New",ColorTextBox);
//Line 5
   ObjectCreate("MMGTbox_Line5",OBJ_LABEL,0,0,0);
   ObjectSet("MMGTbox_Line5",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
   ObjectSet("MMGTbox_Line5",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+70);
   ObjectSetInteger(0,"MMGTbox_Line5",OBJPROP_SELECTABLE,false);
   ObjectSetString(0,"MMGTbox_Line5",OBJPROP_TOOLTIP,"Lot Size Max");
   ObjectSetInteger(0,"MMGTbox_Line5",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ObjectSetText("MMGTbox_Line5","",10,"Courier New",ColorTextBox);
//Line 6
   ObjectCreate("MMGTbox_Line6",OBJ_LABEL,0,0,0);
   ObjectSet("MMGTbox_Line6",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
   ObjectSet("MMGTbox_Line6",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+85);
   ObjectSetString(0,"MMGTbox_Line6",OBJPROP_TOOLTIP,"SandBox Section");
   ObjectSetInteger(0,"MMGTbox_Line6",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"MMGTbox_Line6",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ObjectSetText("MMGTbox_Line6","--SandBox-/-OpenOrder---------------------",10,"Courier New",ColorTextBox);
//Line 7
   ObjectCreate("MMGTbox_Line7",OBJ_LABEL,0,0,0);
   ObjectSet("MMGTbox_Line7",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
   ObjectSet("MMGTbox_Line7",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+100);
   ObjectSetString(0,"MMGTbox_Line7",OBJPROP_TOOLTIP,"Change the risk");
   ObjectSetInteger(0,"MMGTbox_Line7",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"MMGTbox_Line7",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ObjectSetText("MMGTbox_Line7","",10,"Courier New",ColorTextBox);
// Risk button + 
   ButtonCreate(0,"MMGTbox_RiskSizeButtonPlus",0,int(ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+80),int(ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+102),10,10,0,"+","Arial",10,clrBlack,C'236,233,216',clrNONE,false,false,false,false,0);
   ObjectSetString(0,"MMGTbox_RiskSizeButtonPlus",OBJPROP_TOOLTIP,"increase the risk");
   ObjectSetInteger(0,"MMGTbox_RiskSizeButtonPlus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
// Risk button - 
   ButtonCreate(0,"MMGTbox_RiskSizeButtonMinus",0,int(ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+90),int(ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+102),10,10,0,"-","Arial",10,clrBlack,C'236,233,216',clrNONE,false,false,false,false,0);
   ObjectSetString(0,"MMGTbox_RiskSizeButtonMinus",OBJPROP_TOOLTIP,"decrease the risk");
   ObjectSetInteger(0,"MMGTbox_RiskSizeButtonMinus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);

//Line 8
   ObjectCreate("MMGTbox_Line8",OBJ_LABEL,0,0,0);
   ObjectSet("MMGTbox_Line8",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
   ObjectSet("MMGTbox_Line8",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+115);
   ObjectSetString(0,"MMGTbox_Line8",OBJPROP_TOOLTIP,"Lot Size you want");
   ObjectSetInteger(0,"MMGTbox_Line8",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"MMGTbox_Line8",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ObjectSetText("MMGTbox_Line8","",10,"Courier New",ColorTextBox);
// LotSize button + 
   ButtonCreate(0,"MMGTbox_LotSizeButtonPlus",0,int(ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+80),int(ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+117),10,10,0,"+","Arial",10,clrBlack,C'236,233,216',clrNONE,false,false,false,false,0);
   ObjectSetString(0,"MMGTbox_LotSizeButtonPlus",OBJPROP_TOOLTIP,"increase lot size");
   ObjectSetInteger(0,"MMGTbox_LotSizeButtonPlus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
// LotSize button - 
   ButtonCreate(0,"MMGTbox_LotSizeButtonMinus",0,int(ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+90),int(ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+117),10,10,0,"-","Arial",10,clrBlack,C'236,233,216',clrNONE,false,false,false,false,0);
   ObjectSetString(0,"MMGTbox_LotSizeButtonMinus",OBJPROP_TOOLTIP,"decrease lot size");
   ObjectSetInteger(0,"MMGTbox_LotSizeButtonMinus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
//Line 9
   ObjectCreate("MMGTbox_Line9",OBJ_LABEL,0,0,0);
   ObjectSet("MMGTbox_Line9",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
   ObjectSet("MMGTbox_Line9",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+130);
   ObjectSetString(0,"MMGTbox_Line9",OBJPROP_TOOLTIP,"SL");
   ObjectSetInteger(0,"MMGTbox_Line9",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"MMGTbox_Line9",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ObjectSetText("MMGTbox_Line9","",10,"Courier New",ColorTextBox);
//Line 10
   ObjectCreate("MMGTbox_Line10",OBJ_LABEL,0,0,0);
   ObjectSet("MMGTbox_Line10",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
   ObjectSet("MMGTbox_Line10",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+145);
   ObjectSetString(0,"MMGTbox_Line10",OBJPROP_TOOLTIP,"TP");
   ObjectSetInteger(0,"MMGTbox_Line10",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"MMGTbox_Line10",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ObjectSetText("MMGTbox_Line10","",10,"Courier New",ColorTextBox);
//Line 11
   ObjectCreate("MMGTbox_Line11",OBJ_LABEL,0,0,0);
   ObjectSet("MMGTbox_Line11",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
   ObjectSet("MMGTbox_Line11",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+160);
   ObjectSetString(0,"MMGTbox_Line11",OBJPROP_TOOLTIP,"Tp line On/Off   and follow the price");
   ObjectSetInteger(0,"MMGTbox_Line11",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"MMGTbox_Line11",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ObjectSetText("MMGTbox_Line11","    Show TP Line       Show SL Line       Follow price",10,"Courier New",ColorTextBox);
// TP button On/Off 
   if(CreateTP){onoff="On";onoffcolor=clrGreen;}else{onoff="Off";onoffcolor=clrRed;}
   ButtonCreate(0,"MMGTbox_TPButton",0,int(ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)),int(ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+160),25,15,0,onoff,"Arial",10,onoffcolor,C'236,233,216',clrNONE,false,false,false,false,0);
   ObjectSetString(0,"MMGTbox_TPButton",OBJPROP_TOOLTIP,"Tp line On/Off");
   ObjectSetInteger(0,"MMGTbox_TPButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);

// Follow button
   if(followprice){YesNo="Yes";YesNocolor=clrGreen;}else{YesNo="No";YesNocolor=clrRed;}
   ButtonCreate(0,"MMGTbox_FollowButton",0,int(ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+300),int(ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+160),25,15,0,YesNo,"Arial",10,YesNocolor,C'236,233,216',clrNONE,false,false,false,false,0);
   ObjectSetString(0,"MMGTbox_FollowButton",OBJPROP_TOOLTIP,"Buy/Sell line follow the actual price");
   ObjectSetInteger(0,"MMGTbox_FollowButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);

// SL button On/Off 
   if(CreateSL){onoff="On";onoffcolor=clrGreen;}else{onoff="Off";onoffcolor=clrRed;}
   ButtonCreate(0,"MMGTbox_SLButton",0,int(ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+150),int(ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+160),25,15,0,onoff,"Arial",10,onoffcolor,C'236,233,216',clrNONE,false,false,false,false,0);
   ObjectSetString(0,"MMGTbox_SLButton",OBJPROP_TOOLTIP,"TL line On/Off");
   ObjectSetInteger(0,"MMGTbox_SLButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);

// Order button Sell / Buy / Buy limit / Buy stop / Sell limit / Sell stop 
   ButtonCreate(0,"MMGTbox_OrderButton",0,int(ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)),int(ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+180),190,20,0,"","Arial",10,clrBlack,C'236,233,216',clrNONE,false,false,false,false,0);
   ObjectSetString(0,"MMGTbox_OrderButton",OBJPROP_TOOLTIP,"Order used Sandbox parameter");
   ObjectSetInteger(0,"MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
// Close/Abort
   ButtonCreate(0,"MMGTbox_Close",0,int(ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+416),int(ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+180),50,20,0,"Close","Arial",10,clrBlack,C'236,233,216',clrNONE,false,false,false,false,0);
   ObjectSetString(0,"MMGTbox_Close",OBJPROP_TOOLTIP,"Close this box and all lines");
   ObjectSetInteger(0,"MMGTbox_Close",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);

   ObjectCreate("MMGTbox_Line12",OBJ_LABEL,0,0,0);
   ObjectSet("MMGTbox_Line12",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
   ObjectSet("MMGTbox_Line12",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+210);
   ObjectSetString(0,"MMGTbox_Line12",OBJPROP_TOOLTIP,"Broker limit");
   ObjectSetInteger(0,"MMGTbox_Line12",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"MMGTbox_Line12",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ObjectSetText("MMGTbox_Line12","Min Lot:"+DoubleToString(MinimumLotSize,2)+" / Max Lot:"+DoubleToString(MaximumLot,2)+" / Step:"+DoubleToString(LotStep,2)+" / SL TP limit:"+DoubleToString((SLTPbrokerLimit/point*Point),1),8,"Courier New",ColorTextBox);

//Line 13
   ObjectCreate("MMGTbox_Line13",OBJ_LABEL,0,0,0);
   ObjectSet("MMGTbox_Line13",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
   ObjectSet("MMGTbox_Line13",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+185);
   ObjectSetString(0,"MMGTbox_Line13",OBJPROP_TOOLTIP,"");
   ObjectSetInteger(0,"MMGTbox_Line13",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"MMGTbox_Line13",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ObjectSetText("MMGTbox_Line13","if you want to open orders, you need Money_Manager_EA.mq4",8,"Courier New",ColorTextBox);

// ratio button 2 
   ButtonCreate(0,"MMGTbox_RatioButton2",0,int(ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+180),int(ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+27),12,12,0,"2","Arial",8,clrBlack,C'236,233,216',clrNONE,false,false,false,false,0);
   ObjectSetString(0,"MMGTbox_RatioButton2",OBJPROP_TOOLTIP,"ratio 1:2");
   ObjectSetInteger(0,"MMGTbox_RatioButton2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
// ratio button 3 
   ButtonCreate(0,"MMGTbox_RatioButton3",0,int(ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+195),int(ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+27),12,12,0,"3","Arial",8,clrBlack,C'236,233,216',clrNONE,false,false,false,false,0);
   ObjectSetString(0,"MMGTbox_RatioButton3",OBJPROP_TOOLTIP,"ratio 1:3");
   ObjectSetInteger(0,"MMGTbox_RatioButton3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
// ratio button 4 
   ButtonCreate(0,"MMGTbox_RatioButton4",0,int(ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+210),int(ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+27),12,12,0,"4","Arial",8,clrBlack,C'236,233,216',clrNONE,false,false,false,false,0);
   ObjectSetString(0,"MMGTbox_RatioButton4",OBJPROP_TOOLTIP,"ratio 1:4");
   ObjectSetInteger(0,"MMGTbox_RatioButton4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);

   if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
     {
      calculatebuy();
     }

   if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
     {
      calculatesell();
     }
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   int i;
   string objectline;
   double PipGap=0;
   string textline="";
//GlobalVariableGet("MMGT_"+Symbol()+"_Action")  MMGT = send //10=send
//GlobalVariableGet("MMGT_"+Symbol()+"_Action")  EA <=send   =>realised //20=realised
   if(GlobalVariableGet("MMGT_"+Symbol()+"_Action")==20)
     {
      GlobalVariableSet("MMGT_"+Symbol()+"_Action",0);//0=close
      ObjectSetInteger(0,"MMGTbox_RectLabel",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_RecMov",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_Line1",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_Line2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_Line3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_Line4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_Line5",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_Line6",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_Line7",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_RiskSizeButtonPlus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_RiskSizeButtonMinus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_Line8",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_LotSizeButtonPlus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_LotSizeButtonMinus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_Line9",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_Line10",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_TPButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_SLButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_Line11",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_FollowButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_Close",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_Line12",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_Line13",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_RatioButton2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_RatioButton3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_RatioButton4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectDelete(0,"MMGT_"+Symbol()+"_TP_Line");
      ObjectDelete(0,"MMGT_"+Symbol()+"_TP_Label");
      ObjectDelete(0,"MMGT_"+Symbol()+"_SL_Line");
      ObjectDelete(0,"MMGT_"+Symbol()+"_SL_Label");
      ObjectDelete(0,"MMGT_"+Symbol()+"_Buy_Line");
      ObjectDelete(0,"MMGT_"+Symbol()+"_Buy_Label");
      ObjectDelete(0,"MMGT_"+Symbol()+"_Sell_Line");
      ObjectDelete(0,"MMGT_"+Symbol()+"_Sell_Label");
      sandboxlotsize=-1;
     }

   for(i=ObjectsTotal() -1; i>=0; i--)
     {
      if(StringFind(ObjectName(i),"MMGT_"+Symbol())>-1)
        {
         if(StringFind(ObjectName(i),"_Label")>-1)
           {
            objectline=ObjectName(i);
            StringReplace(objectline,"_Label","_Line");
            ObjectMove(0,ObjectName(i),0,labelposition,ObjectGet(objectline,OBJPROP_PRICE1));
            if(StringFind(objectline,"Buy_Line")>-1)
              {
               PipGap=(ObjectGet(objectline,OBJPROP_PRICE1)-MarketInfo(Symbol(),MODE_BID));
               ObjectSetString(0,ObjectName(i),OBJPROP_TEXT,"Buy at "+DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price");
               ObjectSetString(0,ObjectName(i),OBJPROP_TOOLTIP,"Buy at "+DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price");
               ObjectSetString(0,objectline,OBJPROP_TOOLTIP,"Buy at "+DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price");
              }
            if(StringFind(objectline,"Sell_Line")>-1)
              {
               PipGap=(ObjectGet(objectline,OBJPROP_PRICE1)-MarketInfo(Symbol(),MODE_ASK));
               ObjectSetString(0,ObjectName(i),OBJPROP_TEXT,"Sell at "+DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price");
               ObjectSetString(0,ObjectName(i),OBJPROP_TOOLTIP,"Sell at "+DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price");
               ObjectSetString(0,objectline,OBJPROP_TOOLTIP,"Sell at "+DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price");
              }
            if(StringFind(objectline,"SL_Line")>-1)
              {
               if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
                 {
                  textline="Buy";
                  PipGap=(ObjectGet("MMGT_"+Symbol()+"_SL_Label",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
                 }
               if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
                 {
                  textline="Sell";
                  PipGap=(ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
                 }
               ObjectSetString(0,"MMGT_"+Symbol()+"_SL_Label",OBJPROP_TEXT,"SL at "+DoubleToString(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from "+textline);
               ObjectSetString(0,ObjectName(i),OBJPROP_TOOLTIP,"SL at "+DoubleToString(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from "+textline);
               ObjectSetString(0,objectline,OBJPROP_TOOLTIP,"SL at "+DoubleToString(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from "+textline);
              }
            if(StringFind(objectline,"TP_Line")>-1)
              {
               if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
                 {
                  textline="Buy";
                  PipGap=(ObjectGet("MMGT_"+Symbol()+"_TP_Label",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
                 }
               if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
                 {
                  textline="Sell";
                  PipGap=(ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
                 }

               ObjectSetString(0,"MMGT_"+Symbol()+"_TP_Label",OBJPROP_TEXT,"TP at "+DoubleToString(ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from "+textline);
               ObjectSetString(0,ObjectName(i),OBJPROP_TOOLTIP,"TP at "+DoubleToString(ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from "+textline);
               ObjectSetString(0,objectline,OBJPROP_TOOLTIP,"TP at "+DoubleToString(ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from "+textline);
              }
           }
        }
     }
   if(followprice)
     {
      if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
        {
         HLineMove(0,"MMGT_"+Symbol()+"_Buy_Line",MarketInfo(Symbol(),MODE_ASK));
         ObjectMove(0,"MMGT_"+Symbol()+"_Buy_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK));
         HLineMove(0,"MMGT_"+Symbol()+"_SL_Line",MarketInfo(Symbol(),MODE_ASK)-SLPips);
         ObjectMove(0,"MMGT_"+Symbol()+"_SL_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK)-SLPips);
         if(CreateTP)
           {
            HLineMove(0,"MMGT_"+Symbol()+"_TP_Line",MarketInfo(Symbol(),MODE_ASK)+TPPips);
            ObjectMove(0,"MMGT_"+Symbol()+"_TP_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK)+TPPips);
           }
        }
      if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
        {
         HLineMove(0,"MMGT_"+Symbol()+"_Sell_Line",MarketInfo(Symbol(),MODE_BID));
         ObjectMove(0,"MMGT_"+Symbol()+"_Sell_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID));
         HLineMove(0,"MMGT_"+Symbol()+"_SL_Line",MarketInfo(Symbol(),MODE_BID)+SLPips);
         ObjectMove(0,"MMGT_"+Symbol()+"_SL_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID)+SLPips);
         if(CreateTP)
           {
            HLineMove(0,"MMGT_"+Symbol()+"_TP_Line",MarketInfo(Symbol(),MODE_BID)-TPPips);
            ObjectMove(0,"MMGT_"+Symbol()+"_TP_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID)-TPPips);
           }
        }
     }
   if(GlobalVariableGet("MMGT_EA")==1 && ObjectFind(0,"MMGT_"+Symbol()+"_SL_Line")>-1)
     {
      if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
        {
         ObjectSetText("MMGTbox_Line13","Check if automated trading is allowed in the terminal settings!",8,"Courier New",ColorTextBox);
         ObjectSetInteger(0,"MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_Line13",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
        }
      else
        {
         ObjectSetInteger(0,"MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         ObjectSetInteger(0,"MMGTbox_Line13",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
        }
     }
   else
     {
      if(ObjectFind(0,"MMGT_"+Symbol()+"_SL_Line")>-1)
        {
         ObjectSetInteger(0,"MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_Line13",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   datetime dt    =0;
   double   value =0;
   int      window=0;
   int      i=1;
   int      k=1;
   double   PipGap;
   double   SLprice;
   double   TPprice;

   if(id==CHARTEVENT_OBJECT_DRAG)
     {
      if(sparam=="MMGTbox_RecMov")
        {
         ObjectSet("MMGTbox_RectLabel",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)-10);
         ObjectSet("MMGTbox_RectLabel",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)-10);
         ObjectSet("MMGTbox_Line1",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
         ObjectSet("MMGTbox_Line1",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+10);
         ObjectSet("MMGTbox_Line2",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
         ObjectSet("MMGTbox_Line2",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+25);
         ObjectSet("MMGTbox_Line3",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
         ObjectSet("MMGTbox_Line3",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+40);
         ObjectSet("MMGTbox_Line4",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
         ObjectSet("MMGTbox_Line4",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+55);
         ObjectSet("MMGTbox_Line5",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
         ObjectSet("MMGTbox_Line5",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+70);
         ObjectSet("MMGTbox_Line6",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
         ObjectSet("MMGTbox_Line6",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+85);
         ObjectSet("MMGTbox_Line7",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
         ObjectSet("MMGTbox_Line7",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+100);
         ObjectSet("MMGTbox_RiskSizeButtonPlus",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+80);
         ObjectSet("MMGTbox_RiskSizeButtonPlus",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+102);
         ObjectSet("MMGTbox_RiskSizeButtonMinus",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+90);
         ObjectSet("MMGTbox_RiskSizeButtonMinus",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+102);
         ObjectSet("MMGTbox_Line8",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
         ObjectSet("MMGTbox_Line8",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+115);
         ObjectSet("MMGTbox_LotSizeButtonPlus",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+80);
         ObjectSet("MMGTbox_LotSizeButtonPlus",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+117);
         ObjectSet("MMGTbox_LotSizeButtonMinus",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+90);
         ObjectSet("MMGTbox_LotSizeButtonMinus",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+117);
         ObjectSet("MMGTbox_Line9",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
         ObjectSet("MMGTbox_Line9",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+130);
         ObjectSet("MMGTbox_Line10",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
         ObjectSet("MMGTbox_Line10",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+145);
         ObjectSet("MMGTbox_TPButton",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
         ObjectSet("MMGTbox_TPButton",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+160);
         ObjectSet("MMGTbox_SLButton",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+150);
         ObjectSet("MMGTbox_SLButton",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+160);
         ObjectSet("MMGTbox_Line11",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
         ObjectSet("MMGTbox_Line11",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+160);
         ObjectSet("MMGTbox_FollowButton",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+300);
         ObjectSet("MMGTbox_FollowButton",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+160);
         ObjectSet("MMGTbox_OrderButton",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
         ObjectSet("MMGTbox_OrderButton",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+180);
         ObjectSet("MMGTbox_Close",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+416);
         ObjectSet("MMGTbox_Close",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+180);
         ObjectSet("MMGTbox_Line12",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
         ObjectSet("MMGTbox_Line12",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+210);
         ObjectSet("MMGTbox_Line13",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE));
         ObjectSet("MMGTbox_Line13",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+185);
         ObjectSet("MMGTbox_RatioButton2",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+180);
         ObjectSet("MMGTbox_RatioButton2",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+27);
         ObjectSet("MMGTbox_RatioButton3",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+195);
         ObjectSet("MMGTbox_RatioButton3",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+27);
         ObjectSet("MMGTbox_RatioButton4",OBJPROP_XDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_XDISTANCE)+210);
         ObjectSet("MMGTbox_RatioButton4",OBJPROP_YDISTANCE,ObjectGet("MMGTbox_RecMov",OBJPROP_YDISTANCE)+27);
        }
      if(StringFind(sparam,"MMGT_"+Symbol()+"_Buy_Line")>-1)
        {
         ObjectMove(0,"MMGT_"+Symbol()+"_Buy_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
         HLineMove(0,"MMGT_"+Symbol()+"_SL_Line",ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-SLPips);
         ObjectMove(0,"MMGT_"+Symbol()+"_SL_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-SLPips);
         if(CreateTP)
           {
            HLineMove(0,"MMGT_"+Symbol()+"_TP_Line",ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+TPPips);
            ObjectMove(0,"MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+TPPips);
           }
         calculatebuy();
        }
      if(StringFind(sparam,"MMGT_"+Symbol()+"_Sell_Line")>-1)
        {
         ObjectMove(0,"MMGT_"+Symbol()+"_Sell_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
         HLineMove(0,"MMGT_"+Symbol()+"_SL_Line",ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)+SLPips);
         ObjectMove(0,"MMGT_"+Symbol()+"_SL_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)+SLPips);
         if(CreateTP)
           {
            HLineMove(0,"MMGT_"+Symbol()+"_TP_Line",ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-TPPips);
            ObjectMove(0,"MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-TPPips);
           }
         calculatesell();
        }
      if(StringFind(sparam,"MMGT_"+Symbol()+"_TP_Line")>-1)
        {
         ObjectMove(0,"MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            calculatebuy();
           }
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            calculatesell();
           }
        }
      if(StringFind(sparam,"MMGT_"+Symbol()+"_SL_Line")>-1)
        {
         ObjectMove(0,"MMGT_"+Symbol()+"_SL_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            calculatebuy();
           }
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            calculatesell();
           }
        }

      if(StringFind(sparam,"MMGT_"+Symbol())>-1)
        {
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            calculatebuy();
           }
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            calculatesell();
           }
        }
     }

   if(id==CHARTEVENT_CHART_CHANGE)
     {
      if(ratioposition==0)
        {
         ratioposition=0.7;
        }
      if(WindowFirstVisibleBar()>0)
        {
         int newbarpos = int(WindowFirstVisibleBar()*ratioposition);
         labelposition = Time[newbarpos];
        }
     }

   if(id==CHARTEVENT_KEYDOWN)
     {
      if(lparam==(StringGetChar(BuyLine,0)))
        {
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            ObjectDelete(0,"MMGT_"+Symbol()+"_TP_Line");
            ObjectDelete(0,"MMGT_"+Symbol()+"_TP_Label");
            ObjectDelete(0,"MMGT_"+Symbol()+"_SL_Line");
            ObjectDelete(0,"MMGT_"+Symbol()+"_SL_Label");
            ObjectDelete(0,"MMGT_"+Symbol()+"_Sell_Line");
            ObjectDelete(0,"MMGT_"+Symbol()+"_Sell_Label");
           }
         //Buy Line
         if(MathMod(price,MarketInfo(Symbol(),MODE_TICKSIZE))>0)
           {
            price=MathRound(price/MarketInfo(Symbol(),MODE_TICKSIZE))*MarketInfo(Symbol(),MODE_TICKSIZE);
           }
         HLineCreate(0,"MMGT_"+Symbol()+"_Buy_Line",0,price,ColorBuySell,LineStyle,Linewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
         ObjectCreate("MMGT_"+Symbol()+"_Buy_Label",OBJ_TEXT,0,labelposition,ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
         ObjectMove(0,"MMGT_"+Symbol()+"_Buy_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
         PipGap=(ObjectGet("MMGT_"+Symbol()+"_Buy_Label",OBJPROP_PRICE1)-MarketInfo(Symbol(),MODE_BID));
         ObjectSetText("MMGT_"+Symbol()+"_Buy_Label",DoubleToString(ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price",10,"Courier New",ColorBuySell);
         //SL Line
         if(Digits==4 || Digits==5)
           {
            SLprice=price -(DefaultSL/10000);
           }
         else if(Digits==2 || Digits==3)
           {
            SLprice=price -(DefaultSL/100);
           }
         else
           {
            SLprice=price -(DefaultSL/1);
           }
         PipGap=(SLprice-ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
         HLineCreate(0,"MMGT_"+Symbol()+"_SL_Line",0,SLprice,ColorSL,LineStyle,Linewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
         ObjectCreate("MMGT_"+Symbol()+"_SL_Label",OBJ_TEXT,0,labelposition,ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
         ObjectMove(0,"MMGT_"+Symbol()+"_SL_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
         ObjectSetText("MMGT_"+Symbol()+"_SL_Label","SL at "+DoubleToString(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from Buy",10,"Courier New",ColorSL);
         //TakeProfit
         //SL Line
         if(Digits==4 || Digits==5)
           {
            TPprice=price+(DefaultSL*2/10000);
           }
         else if(Digits==2 || Digits==3)
           {
            TPprice=price+(DefaultSL*2/100);
           }
         else
           {
            TPprice=price+(DefaultSL*2/1);
           }
         if(CreateTP)
           {
            PipGap=(TPprice-ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
            HLineCreate(0,"MMGT_"+Symbol()+"_TP_Line",0,TPprice,ColorTP,LineStyle,Linewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
            ObjectCreate("MMGT_"+Symbol()+"_TP_Label",OBJ_TEXT,0,labelposition,ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
            ObjectMove(0,"MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
            ObjectSetText("MMGT_"+Symbol()+"_TP_Label","TP at "+DoubleToString(ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from Buy",10,"Courier New",ColorTP);
           }
         if(CreateTP)
           {
            SLPips = MathAbs(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
            TPPips = MathAbs(ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
            ratio="1:"+DoubleToString((TPPips/SLPips),1);
           }
         else
           {
            ratio="no TP";
           }

         calculatebuy();
        }

      if(lparam==(StringGetChar(SellLine,0)))
        {
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            ObjectDelete(0,"MMGT_"+Symbol()+"_TP_Line");
            ObjectDelete(0,"MMGT_"+Symbol()+"_TP_Label");
            ObjectDelete(0,"MMGT_"+Symbol()+"_SL_Line");
            ObjectDelete(0,"MMGT_"+Symbol()+"_SL_Label");
            ObjectDelete(0,"MMGT_"+Symbol()+"_Buy_Line");
            ObjectDelete(0,"MMGT_"+Symbol()+"_Buy_Label");
           }
         //Sell Line
         if(MathMod(price,MarketInfo(Symbol(),MODE_TICKSIZE))>0)
           {
            price=MathRound(price/MarketInfo(Symbol(),MODE_TICKSIZE))*MarketInfo(Symbol(),MODE_TICKSIZE);
           }
         HLineCreate(0,"MMGT_"+Symbol()+"_Sell_Line",0,price,ColorBuySell,LineStyle,Linewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
         ObjectCreate("MMGT_"+Symbol()+"_Sell_Label",OBJ_TEXT,0,labelposition,ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
         ObjectMove(0,"MMGT_"+Symbol()+"_Sell_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
         PipGap=(ObjectGet("MMGT_"+Symbol()+"_Sell_Label",OBJPROP_PRICE1)-MarketInfo(Symbol(),MODE_BID));
         ObjectSetText("MMGT_"+Symbol()+"_Sell_Label",DoubleToString(ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price",10,"Courier New",ColorBuySell);
         //SL Line
         if(Digits==4 || Digits==5)
           {
            SLprice=price+(DefaultSL/10000);
           }
         else  if(Digits==2 || Digits==3)
           {
            SLprice=price+(DefaultSL/100);
           }
         else
           {
            SLprice=price+(DefaultSL/1);
           }
         PipGap=(ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-SLprice);
         HLineCreate(0,"MMGT_"+Symbol()+"_SL_Line",0,SLprice,ColorSL,LineStyle,Linewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
         ObjectCreate("MMGT_"+Symbol()+"_SL_Label",OBJ_TEXT,0,labelposition,ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
         ObjectMove(0,"MMGT_"+Symbol()+"_SL_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
         ObjectSetText("MMGT_"+Symbol()+"_SL_Label","SL at "+DoubleToString(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from Sell",10,"Courier New",ColorSL);
         //TakeProfit
         //SL Line
         if(Digits==4 || Digits==5)
           {
            TPprice=price-(DefaultSL*2/10000);
           }
         else if(Digits==2 || Digits==3)
           {
            TPprice=price-(DefaultSL*2/100);
           }
         else
           {
            TPprice=price -(DefaultSL*2/1);
           }
         if(CreateTP)
           {
            PipGap=(ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-TPprice);
            HLineCreate(0,"MMGT_"+Symbol()+"_TP_Line",0,TPprice,ColorTP,LineStyle,Linewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
            ObjectCreate("MMGT_"+Symbol()+"_TP_Label",OBJ_TEXT,0,labelposition,ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
            ObjectMove(0,"MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
            ObjectSetText("MMGT_"+Symbol()+"_TP_Label","TP at "+DoubleToString(ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from Sell",10,"Courier New",ColorTP);
           }
         if(CreateTP)
           {
            SLPips = MathAbs(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
            TPPips = MathAbs(ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
            ratio="1:"+DoubleToString((TPPips/SLPips),1);
           }
         else
           {
            ratio="no TP";
           }

         calculatesell();
        }
     }
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam=="MMGTbox_RiskSizeButtonPlus")
        {
         ObjectSetInteger(0,"MMGTbox_RiskSizeButtonPlus",OBJPROP_STATE,false);
         sandboxrisk=sandboxrisk+0.1;

         if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            sandboxlotsize=NormalizeDouble((double(AccountInfoDouble(accounttype))/100*sandboxrisk)/((SLPips/point))/PipValuesonelot,2);
            calculatebuy();
           }
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            sandboxlotsize=NormalizeDouble((double(AccountInfoDouble(accounttype))/100*sandboxrisk)/((SLPips/point))/PipValuesonelot,2);
            calculatesell();
           }
        }
      if(sparam=="MMGTbox_RiskSizeButtonMinus")
        {
         ObjectSetInteger(0,"MMGTbox_RiskSizeButtonMinus",OBJPROP_STATE,false);
         sandboxrisk=sandboxrisk-0.1;

         if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            sandboxlotsize=NormalizeDouble((double(AccountInfoDouble(accounttype))/100*sandboxrisk)/((SLPips/point))/PipValuesonelot,2);
            calculatebuy();
           }
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            sandboxlotsize=NormalizeDouble((double(AccountInfoDouble(accounttype))/100*sandboxrisk)/((SLPips/point))/PipValuesonelot,2);
            calculatesell();
           }
        }
      if(sparam=="MMGTbox_LotSizeButtonPlus")
        {
         ObjectSetInteger(0,"MMGTbox_LotSizeButtonPlus",OBJPROP_STATE,false);
         sandboxlotsize=sandboxlotsize+LotStep;
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            if((double(AccountInfoDouble(accounttype))/100*sandboxrisk)<((SLPips*(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*sandboxlotsize))/point))
              {
               for(;!IsStopped();)
                 {
                  sandboxrisk=sandboxrisk+LotStep;
                  if((double(AccountInfoDouble(accounttype))/100*sandboxrisk)>((SLPips*(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*sandboxlotsize))/point)) break;
                 }
              }
            calculatebuy();
           }
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            if((double(AccountInfoDouble(accounttype))/100*sandboxrisk)<((SLPips*(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*sandboxlotsize))/point))
              {
               for(;!IsStopped();)
                 {
                  sandboxrisk=sandboxrisk+LotStep;
                  if((double(AccountInfoDouble(accounttype))/100*sandboxrisk)>((SLPips*(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*sandboxlotsize))/point)) break;
                 }
              }
            calculatesell();
           }
        }
      if(sparam=="MMGTbox_LotSizeButtonMinus")
        {
         ObjectSetInteger(0,"MMGTbox_LotSizeButtonMinus",OBJPROP_STATE,false);
         sandboxlotsize=sandboxlotsize-LotStep;
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            calculatebuy();
           }
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            calculatesell();
           }
        }
      if(sparam=="MMGTbox_RatioButton2")
        {
         ObjectSetInteger(0,"MMGTbox_RatioButton2",OBJPROP_STATE,false);
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            SLPips=MathAbs(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
            HLineMove(0,"MMGT_"+Symbol()+"_TP_Line",ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+(SLPips*2));
            ObjectMove(0,"MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+(SLPips*2));
            calculatebuy();
           }
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            SLPips=MathAbs(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
            HLineMove(0,"MMGT_"+Symbol()+"_TP_Line",ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-(SLPips*2));
            ObjectMove(0,"MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-(SLPips*2));
            calculatesell();
           }
        }
      if(sparam=="MMGTbox_RatioButton3")
        {
         ObjectSetInteger(0,"MMGTbox_RatioButton3",OBJPROP_STATE,false);
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            SLPips=MathAbs(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
            HLineMove(0,"MMGT_"+Symbol()+"_TP_Line",ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+(SLPips*3));
            ObjectMove(0,"MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+(SLPips*3));
            calculatebuy();
           }
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            SLPips=MathAbs(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
            HLineMove(0,"MMGT_"+Symbol()+"_TP_Line",ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-(SLPips*3));
            ObjectMove(0,"MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-(SLPips*3));
            calculatesell();
           }
        }
      if(sparam=="MMGTbox_RatioButton4")
        {
         ObjectSetInteger(0,"MMGTbox_RatioButton4",OBJPROP_STATE,false);
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            SLPips=MathAbs(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
            HLineMove(0,"MMGT_"+Symbol()+"_TP_Line",ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+(SLPips*4));
            ObjectMove(0,"MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+(SLPips*4));
            calculatebuy();
           }
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            SLPips=MathAbs(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
            HLineMove(0,"MMGT_"+Symbol()+"_TP_Line",ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-(SLPips*4));
            ObjectMove(0,"MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-(SLPips*4));
            calculatesell();
           }
        }
      if(sparam=="MMGTbox_Close")
        {
         ObjectSetInteger(0,"MMGTbox_Close",OBJPROP_STATE,false);
         ObjectSetInteger(0,"MMGTbox_RectLabel",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_RecMov",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_Line1",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_Line2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_Line3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_Line4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_Line5",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_Line6",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_Line7",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_RiskSizeButtonPlus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_RiskSizeButtonMinus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_Line8",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_LotSizeButtonPlus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_LotSizeButtonMinus",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_Line9",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_Line10",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_TPButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_SLButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_Line11",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_FollowButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_Close",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_Line12",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_Line13",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_RatioButton2",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_RatioButton3",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectSetInteger(0,"MMGTbox_RatioButton4",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
         ObjectDelete(0,"MMGT_"+Symbol()+"_TP_Line");
         ObjectDelete(0,"MMGT_"+Symbol()+"_TP_Label");
         ObjectDelete(0,"MMGT_"+Symbol()+"_SL_Line");
         ObjectDelete(0,"MMGT_"+Symbol()+"_SL_Label");
         ObjectDelete(0,"MMGT_"+Symbol()+"_Buy_Line");
         ObjectDelete(0,"MMGT_"+Symbol()+"_Buy_Label");
         ObjectDelete(0,"MMGT_"+Symbol()+"_Sell_Line");
         ObjectDelete(0,"MMGT_"+Symbol()+"_Sell_Label");
         sandboxlotsize=-1;
        }
      if(sparam=="MMGTbox_TPButton")
        {
         ObjectSetInteger(0,"MMGTbox_TPButton",OBJPROP_STATE,false);
         if(CreateTP){CreateTP=false;}else{CreateTP=true;}
         if(CreateTP)
           {
            onoff="On";
            onoffcolor=clrGreen;
            if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               SLPips=MathAbs(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
               TPprice=ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+SLPips*2;
               PipGap=(TPprice-ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
              }
            if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
              {
               SLPips=MathAbs(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
               TPprice=ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-SLPips*2;
               PipGap=(TPprice-ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
              }
            //PipGap=(TPprice-ObjectGet("MMGT_"+Symbol()+"_Buy_Label",OBJPROP_PRICE1));
            HLineCreate(0,"MMGT_"+Symbol()+"_TP_Line",0,TPprice,ColorTP,LineStyle,Linewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
            ObjectCreate("MMGT_"+Symbol()+"_TP_Label",OBJ_TEXT,0,labelposition,ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
            ObjectMove(0,"MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
            ObjectSetText("MMGT_"+Symbol()+"_TP_Label","TP at "+DoubleToString(ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from Buy",10,"Courier New",ColorTP);

           }
         else
           {
            onoff="Off";
            onoffcolor=clrRed;
            ObjectDelete(0,"MMGT_"+Symbol()+"_TP_Line");
            ObjectDelete(0,"MMGT_"+Symbol()+"_TP_Label");
           }
         ObjectSetInteger(0,"MMGTbox_TPButton",OBJPROP_STATE,false);
         ObjectSetString(0,"MMGTbox_TPButton",OBJPROP_TEXT,onoff);
         ObjectSetInteger(0,"MMGTbox_TPButton",OBJPROP_COLOR,onoffcolor);
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            calculatebuy();
           }
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            calculatesell();
           }
        }
      if(sparam=="MMGTbox_SLButton")
        {
         ObjectSetInteger(0,"MMGTbox_SLButton",OBJPROP_STATE,false);
         if(CreateSL){CreateSL=false;}else{CreateSL=true;}
         if(CreateSL)
           {
            onoff="On";
            onoffcolor=clrGreen;
            string tempotxt;
            if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               TPprice=ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-(DefaultSL*point);
               PipGap=(TPprice-ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
               tempotxt="Buy";
              }
            if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
              {
               SLprice=ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)+(DefaultSL*point);
               PipGap=(TPprice-ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
               tempotxt="Sell";
              }
            HLineCreate(0,"MMGT_"+Symbol()+"_SL_Line",0,SLprice,ColorSL,LineStyle,Linewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
            ObjectCreate("MMGT_"+Symbol()+"_SL_Label",OBJ_TEXT,0,labelposition,ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
            ObjectMove(0,"MMGT_"+Symbol()+"_SL_Label",0,labelposition,ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
            ObjectSetText("MMGT_"+Symbol()+"_SL_Label","SL at "+DoubleToString(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from "+tempotxt,10,"Courier New",ColorSL);
           }
         else
           {
            onoff="Off";
            onoffcolor=clrRed;
            ObjectDelete(0,"MMGT_"+Symbol()+"_SL_Line");
            ObjectDelete(0,"MMGT_"+Symbol()+"_SL_Label");
           }
         ObjectSetInteger(0,"MMGTbox_SLButton",OBJPROP_STATE,false);
         ObjectSetString(0,"MMGTbox_SLButton",OBJPROP_TEXT,onoff);
         ObjectSetInteger(0,"MMGTbox_SLButton",OBJPROP_COLOR,onoffcolor);
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            calculatebuy();
           }
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            calculatesell();
           }
        }
      if(sparam=="MMGTbox_FollowButton")
        {
         ObjectSetInteger(0,"MMGTbox_FollowButton",OBJPROP_STATE,false);
         if(followprice){followprice=false;}else{followprice=true;}
         if(followprice)
           {
            YesNo="Yes";
            YesNocolor=clrGreen;
            ObjectSetInteger(0,"MMGTbox_FollowButton",OBJPROP_STATE,false);
            ObjectSetString(0,"MMGTbox_FollowButton",OBJPROP_TEXT,YesNo);
            ObjectSetInteger(0,"MMGTbox_FollowButton",OBJPROP_COLOR,YesNocolor);
            if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               HLineMove(0,"MMGT_"+Symbol()+"_Buy_Line",MarketInfo(Symbol(),MODE_ASK));
               ObjectMove(0,"MMGT_"+Symbol()+"_Buy_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK));
               HLineMove(0,"MMGT_"+Symbol()+"_SL_Line",MarketInfo(Symbol(),MODE_ASK)-SLPips);
               ObjectMove(0,"MMGT_"+Symbol()+"_SL_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK)-SLPips);
               if(CreateTP)
                 {
                  HLineMove(0,"MMGT_"+Symbol()+"_TP_Line",MarketInfo(Symbol(),MODE_ASK)+TPPips);
                  ObjectMove(0,"MMGT_"+Symbol()+"_TP_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK)+TPPips);
                 }
              }
            if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
              {
               HLineMove(0,"MMGT_"+Symbol()+"_Sell_Line",MarketInfo(Symbol(),MODE_BID));
               ObjectMove(0,"MMGT_"+Symbol()+"_Sell_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID));
               HLineMove(0,"MMGT_"+Symbol()+"_SL_Line",MarketInfo(Symbol(),MODE_BID)+SLPips);
               ObjectMove(0,"MMGT_"+Symbol()+"_SL_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID)+SLPips);
               if(CreateTP)
                 {
                  HLineMove(0,"MMGT_"+Symbol()+"_TP_Line",MarketInfo(Symbol(),MODE_ASK)-TPPips);
                  ObjectMove(0,"MMGT_"+Symbol()+"_TP_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK)-TPPips);
                 }
              }
           }
         else
           {
            YesNo="No";
            YesNocolor=clrRed;
            ObjectSetInteger(0,"MMGTbox_FollowButton",OBJPROP_STATE,false);
            ObjectSetString(0,"MMGTbox_FollowButton",OBJPROP_TEXT,YesNo);
            ObjectSetInteger(0,"MMGTbox_FollowButton",OBJPROP_COLOR,YesNocolor);
           }
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            calculatebuy();
           }
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            calculatesell();
           }
        }

      if(sparam=="MMGTbox_OrderButton")
        {
         int OrderProperties;
         double priceorder=0;
         ObjectSetInteger(0,"MMGTbox_OrderButton",OBJPROP_STATE,false);
         if(ObjectFind(0,"MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            if(followprice)
              {
               OrderProperties=OP_BUY;
               priceorder=MarketInfo(Symbol(),MODE_ASK);
              }
            else
              {
               priceorder=ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1);
               if(ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)>MarketInfo(Symbol(),MODE_ASK))
                 {
                  OrderProperties=OP_BUYSTOP;
                 }
               else
                 {
                  OrderProperties=OP_BUYLIMIT;
                 }
              }
            GlobalVariableSet("MMGT_"+Symbol()+"_Action",10);//10=send
            GlobalVariableSet("MMGT_"+Symbol()+"_OrderProp",OrderProperties);
            GlobalVariableSet("MMGT_"+Symbol()+"_LotSize",sandboxlotsize);
            GlobalVariableSet("MMGT_"+Symbol()+"_Price",NormalizeDouble(priceorder,Digits));
            GlobalVariableSet("MMGT_"+Symbol()+"_SL",NormalizeDouble(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits));
            GlobalVariableSet("MMGT_"+Symbol()+"_TP",NormalizeDouble(ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits));
            GlobalVariableSet("MMGT_"+Symbol()+"_MAGIC",MagicNumber);
            //ticket=OrderSend(Symbol(),OrderProperties,sandboxlotsize,Ask,3,ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),"Money_Manager_Graphic_Tool",210572,0,clrGreen);
           }

         if(ObjectFind(0,"MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            if(followprice)
              {
               OrderProperties=OP_SELL;
               priceorder=MarketInfo(Symbol(),MODE_BID);
              }
            else
              {
               priceorder=ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1);
               if(ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)>MarketInfo(Symbol(),MODE_BID))
                 {
                  OrderProperties=OP_SELLLIMIT;
                 }
               else
                 {
                  OrderProperties=OP_SELLSTOP;
                 }
              }
            GlobalVariableSet("MMGT_"+Symbol()+"_Action",10);//10=send
            GlobalVariableSet("MMGT_"+Symbol()+"_OrderProp",OrderProperties);
            GlobalVariableSet("MMGT_"+Symbol()+"_LotSize",sandboxlotsize);
            GlobalVariableSet("MMGT_"+Symbol()+"_Price",NormalizeDouble(priceorder,Digits));
            GlobalVariableSet("MMGT_"+Symbol()+"_SL",NormalizeDouble(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits));
            GlobalVariableSet("MMGT_"+Symbol()+"_TP",NormalizeDouble(ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits));
            GlobalVariableSet("MMGT_"+Symbol()+"_MAGIC",MagicNumber);
           }
        }
     }

   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      ChartXYToTimePrice(0,int(lparam),int(dparam),window,dt,price);
      xmouse = int(lparam);
      ymouse = int(dparam);
     }
  }
//+------------------------------------------------------------------+
//| Create rectangle label                                           |
//+------------------------------------------------------------------+
bool RectLabelCreate(const long             chart_ID=0,               // chart's ID
                     const string           name="RectLabel",         // label name
                     const int              sub_window=0,             // subwindow index
                     const int              xx=0,                      // X coordinate
                     const int              yy=0,                      // Y coordinate
                     const int              width=50,                 // width
                     const int              height=18,                // height
                     const color            back_clr=C'236,233,216',  // background color
                     const ENUM_BORDER_TYPE border=BORDER_SUNKEN,     // border type
                     const ENUM_BASE_CORNER cornerr=CORNER_LEFT_UPPER,// chart corner for anchoring
                     const color            clr=clrRed,               // flat border color (Flat)
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // flat border style
                     const int              line_width=1,             // flat border width
                     const bool             back=false,               // in the background
                     const bool             selection=false,          // highlight to move
                     const bool             hidden=true,              // hidden in the object list
                     const long             z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();

   if(ObjectFind(chart_ID,name)<0)
     {
      //--- create a rectangle label
      if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create a rectangle label! Error code = ",GetLastError());
         return(false);
        }
      //--- set label coordinates
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,xx);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,yy);
      //--- set label size
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      //--- set background color
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
      //--- set border type
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,cornerr);
      //--- set flat border color (in Flat mode)
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      //--- set flat border line style
      ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
      //--- set flat border width
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
      //--- display in the foreground (false) or background (true)
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      //--- enable (true) or disable (false) the mode of moving the label by mouse
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      //--- hide (true) or display (false) graphical object name in the object list
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      //--- set the priority for receiving the event of a mouse click in the chart
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      //--- successful execution
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Move rectangle label                                             |
//+------------------------------------------------------------------+
bool RectLabelMove(const long   chart_ID=0,       // chart's ID
                   const string name="RectLabel", // label name
                   const int    xx=0,              // X coordinate
                   const int    yy=0)              // Y coordinate
  {
//--- reset the error value
   ResetLastError();
//--- move the rectangle label
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,xx))
     {
      Print(__FUNCTION__,
            ": failed to move X coordinate of the label! Error code = ",GetLastError());
      return(false);
     }
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,yy))
     {
      Print(__FUNCTION__,
            ": failed to move Y coordinate of the label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the horizontal line                                       |
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,// chart's ID
                 const string          name="HLine_max",// line name
                 const int             sub_window=0,// subwindow index
                 double                hprice=0,// line price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0,         // priority for mouse click
                 const string          tooltip="")
  {
   ObjectDelete(chart_ID,name);
//--- reset the error value
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,hprice))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);

   ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Move horizontal line                                             |
//+------------------------------------------------------------------+
bool HLineMove(const long   chart_ID=0,   // chart's ID
               const string name="HLine", // line name
               double       pricel=0) // line price
  {
//--- if the line price is not set, move it to the current Bid price level
   if(!pricel)
      pricel=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move a horizontal line
   if(!ObjectMove(chart_ID,name,0,0,pricel))
     {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculatebuy()
  {
//string additionalinfo;
   color Pipconditioncolor;
   color SLlimitcolor;
   color TPlimitcolor;

   if(ObjectFind(0,"MMGT_"+Symbol()+"_TP_Line")>-1)
     {
      CreateTP=true;
     }
   else
     {
      CreateTP=false;
     }

   SLPips=MathAbs(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));

   if(CreateTP)
     {
      TPPips=MathAbs(ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
      ratio="1:"+DoubleToString((TPPips/SLPips),1);
     }
   else
     {
      ratio="no TP";
     }
   ObjectSetText("MMGTbox_Line2","Ratio        : "+ratio,10,"Courier New",ColorTextBox);

   lotsizemaximum=NormalizeDouble(riskmoney/((SLPips/point))/PipValuesonelot,2);

   if(sandboxlotsize==-1)
     {
      sandboxlotsize=lotsizemaximum;
     }
   PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*lotsizemaximum);
   if((SLPips/Point)<SLTPbrokerLimit)
     {
      SLlimitcolor=clrRed;
     }
   else
     {
      SLlimitcolor=ColorTextBox;
     }
   if(CreateSL)
     {
      ObjectSetText("MMGTbox_Line3","SL           : ["+DoubleToString(SLPips/point,1)+" pips  "+DoubleToString(SLPips*PipValues/point,2)+" "+AccountInfoString(ACCOUNT_CURRENCY)+"]",10,"Courier New",SLlimitcolor);
     }
   else
     {
      ObjectSetText("MMGTbox_Line3","SL           : no SL",10,"Courier New",SLlimitcolor);
     }
   if((TPPips/Point)<SLTPbrokerLimit)
     {
      TPlimitcolor=clrRed;
     }
   else
     {
      TPlimitcolor=ColorTextBox;
     }
   if(CreateTP)
     {
      ObjectSetText("MMGTbox_Line4","TP           : ["+DoubleToString(TPPips/point,1)+" pips  "+DoubleToString(TPPips*PipValues/point,2)+" "+AccountInfoString(ACCOUNT_CURRENCY)+"]",10,"Courier New",TPlimitcolor);
     }
   else
     {
      ObjectSetText("MMGTbox_Line4","TP           : no TP",10,"Courier New",ColorTextBox);
     }
   if(lotsizemaximum>MaximumLot || lotsizemaximum<MinimumLotSize)
     {
      Pipconditioncolor=clrRed;
     }
   else
     {
      Pipconditioncolor=ColorTextBox;
     }
   ObjectSetText("MMGTbox_Line5","Lot Size Max : "+DoubleToString(lotsizemaximum,2),10,"Courier New",Pipconditioncolor);
   ObjectSetText("MMGTbox_Line7","Risk         : "+DoubleToStr(sandboxrisk,2)+"% = "+DoubleToStr(double(AccountInfoDouble(accounttype))/100*sandboxrisk,2)+" "+AccountInfoString(ACCOUNT_CURRENCY)+" / "+balanceequity+" "+DoubleToStr(AccountInfoDouble(accounttype),2)+" "+AccountInfoString(ACCOUNT_CURRENCY),10,"Courier New",ColorTextBox);
   if(sandboxlotsize>MaximumLot || sandboxlotsize<MinimumLotSize)
     {
      Pipconditioncolor=clrRed;
     }
   else
     {
      Pipconditioncolor=ColorTextBox;
     }
   ObjectSetText("MMGTbox_Line8","Lot Size     : "+DoubleToString(sandboxlotsize,2),10,"Courier New",Pipconditioncolor);
   double sandboxPipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*sandboxlotsize);
   if(CreateSL)
     {
      ObjectSetText("MMGTbox_Line9","SL           : ["+DoubleToString(SLPips/point,1)+" pips  "+DoubleToString(SLPips*sandboxPipValues/point,2)+" "+AccountInfoString(ACCOUNT_CURRENCY)+"]",10,"Courier New",SLlimitcolor);
     }
   else
     {
      ObjectSetText("MMGTbox_Line9","SL           : no SL",10,"Courier New",SLlimitcolor);
     }
   if(CreateTP)
     {
      ObjectSetText("MMGTbox_Line10","TP           : ["+DoubleToString(TPPips/point,1)+" pips  "+DoubleToString(TPPips*sandboxPipValues/point,2)+" "+AccountInfoString(ACCOUNT_CURRENCY)+"]",10,"Courier New",TPlimitcolor);
     }
   else
     {
      ObjectSetText("MMGTbox_Line10","TP           : no TP",10,"Courier New",ColorTextBox);
     }
   if(!TransparancyBox)
     {
      ObjectSetInteger(0,"MMGTbox_RectLabel",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   ObjectSetInteger(0,"MMGTbox_RecMov",OBJPROP_SELECTED,true);
   ObjectSetInteger(0,"MMGTbox_RecMov",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line5",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line6",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line7",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_RiskSizeButtonPlus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_RiskSizeButtonMinus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line8",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_LotSizeButtonPlus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_LotSizeButtonMinus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line9",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line10",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_TPButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_SLButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line11",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_FollowButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   if(GlobalVariableGet("MMGT_EA")==1)
     {
      ObjectSetInteger(0,"MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
      ObjectSetInteger(0,"MMGTbox_Line13",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
     }
   else
     {
      ObjectSetInteger(0,"MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_Line13",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   ObjectSetInteger(0,"MMGTbox_Close",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line12",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_RatioButton2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_RatioButton3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_RatioButton4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);

   string OrderButtonText="";
   if(followprice)
     {
      OrderButtonText="Order Buy "+DoubleToString(sandboxlotsize,2)+" Lot";
     }
   else
     {
      if(ObjectGet("MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)>MarketInfo(Symbol(),MODE_ASK))
        {
         OrderButtonText="Order Buy Stop "+DoubleToString(sandboxlotsize,2)+" Lot";
        }
      else
        {
         OrderButtonText="Order Buy Limit "+DoubleToString(sandboxlotsize,2)+" Lot";
        }
     }
   ObjectSetString(0,"MMGTbox_OrderButton",OBJPROP_TEXT,OrderButtonText);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculatesell()
  {
   color Pipconditioncolor;
   color SLlimitcolor;
   color TPlimitcolor;
   if(ObjectFind(0,"MMGT_"+Symbol()+"_TP_Line")>-1)
     {
      CreateTP=true;
     }
   else
     {
      CreateTP=false;
     }

   SLPips=MathAbs(ObjectGet("MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));

   if(CreateTP)
     {
      TPPips=MathAbs(ObjectGet("MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
      ratio="1:"+DoubleToString((TPPips/SLPips),1);
     }
   else
     {
      ratio="no TP";
     }
   ObjectSetText("MMGTbox_Line2","Ratio        : "+ratio,10,"Courier New",ColorTextBox);

   lotsizemaximum=NormalizeDouble(riskmoney/((SLPips/point))/PipValuesonelot,2);

   if(sandboxlotsize==-1)
     {
      sandboxlotsize=lotsizemaximum;
     }
   PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*lotsizemaximum);
   if((SLPips/Point)<SLTPbrokerLimit)
     {
      SLlimitcolor=clrRed;
     }
   else
     {
      SLlimitcolor=ColorTextBox;
     }
   if(CreateSL)
     {
      ObjectSetText("MMGTbox_Line3","SL           : ["+DoubleToString(SLPips/point,1)+" pips  "+DoubleToString(SLPips*PipValues/point,2)+" "+AccountInfoString(ACCOUNT_CURRENCY)+"]",10,"Courier New",SLlimitcolor);
     }
   else
     {
      ObjectSetText("MMGTbox_Line3","SL           : no SL",10,"Courier New",SLlimitcolor);
     }
   if((TPPips/Point)<SLTPbrokerLimit)
     {
      TPlimitcolor=clrRed;
     }
   else
     {
      TPlimitcolor=ColorTextBox;
     }
   if(CreateTP)
     {
      ObjectSetText("MMGTbox_Line4","TP           : ["+DoubleToString(TPPips/point,1)+" pips  "+DoubleToString(TPPips*PipValues/point,2)+" "+AccountInfoString(ACCOUNT_CURRENCY)+"]",10,"Courier New",TPlimitcolor);
     }
   else
     {
      ObjectSetText("MMGTbox_Line4","TP           : no TP",10,"Courier New",ColorTextBox);
     }
   if(lotsizemaximum>MaximumLot || lotsizemaximum<MinimumLotSize)
     {
      Pipconditioncolor=clrRed;
     }
   else
     {
      Pipconditioncolor=ColorTextBox;
     }
   ObjectSetText("MMGTbox_Line5","Lot Size Max : "+DoubleToString(lotsizemaximum,2),10,"Courier New",Pipconditioncolor);
   ObjectSetText("MMGTbox_Line7","Risk         : "+DoubleToStr(sandboxrisk,2)+"% = "+DoubleToStr(double(AccountInfoDouble(accounttype))/100*sandboxrisk,2)+" "+AccountInfoString(ACCOUNT_CURRENCY)+" / "+balanceequity+" "+DoubleToStr(AccountInfoDouble(accounttype),2)+" "+AccountInfoString(ACCOUNT_CURRENCY),10,"Courier New",ColorTextBox);

   if(sandboxlotsize>MaximumLot || sandboxlotsize<MinimumLotSize)
     {
      Pipconditioncolor=clrRed;
     }
   else
     {
      Pipconditioncolor=ColorTextBox;
     }
   ObjectSetText("MMGTbox_Line8","Lot Size     : "+DoubleToString(sandboxlotsize,2),10,"Courier New",Pipconditioncolor);
   double sandboxPipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*sandboxlotsize);
   if(CreateSL)
     {
      ObjectSetText("MMGTbox_Line9","SL           : ["+DoubleToString(SLPips/point,1)+" pips  "+DoubleToString(SLPips*sandboxPipValues/point,2)+" "+AccountInfoString(ACCOUNT_CURRENCY)+"]",10,"Courier New",TPlimitcolor);
     }
   else
     {
      ObjectSetText("MMGTbox_Line9","SL           : no SL",10,"Courier New",TPlimitcolor);
     }
   if(CreateTP)
     {
      ObjectSetText("MMGTbox_Line10","TP           : ["+DoubleToString(TPPips/point,1)+" pips  "+DoubleToString(TPPips*sandboxPipValues/point,2)+" "+AccountInfoString(ACCOUNT_CURRENCY)+"]",10,"Courier New",ColorTextBox);
     }
   else
     {
      ObjectSetText("MMGTbox_Line10","TP           : no TP",10,"Courier New",ColorTextBox);
     }
   if(!TransparancyBox)
     {
      ObjectSetInteger(0,"MMGTbox_RectLabel",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   ObjectSetInteger(0,"MMGTbox_RecMov",OBJPROP_SELECTED,true);
   ObjectSetInteger(0,"MMGTbox_RecMov",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line5",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line6",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line7",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_RiskSizeButtonPlus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_RiskSizeButtonMinus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line8",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_LotSizeButtonPlus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_LotSizeButtonMinus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line9",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line10",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_TPButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_SLButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line11",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_FollowButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   if(GlobalVariableGet("MMGT_EA")==1)
     {
      ObjectSetInteger(0,"MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
      ObjectSetInteger(0,"MMGTbox_Line13",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
     }
   else
     {
      ObjectSetInteger(0,"MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
      ObjectSetInteger(0,"MMGTbox_Line13",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   ObjectSetInteger(0,"MMGTbox_Close",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_Line12",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_RatioButton2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_RatioButton3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MMGTbox_RatioButton4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);

   string OrderButtonText="";
   if(followprice)
     {
      OrderButtonText="Order Sell "+DoubleToString(sandboxlotsize,2)+" Lot";
     }
   else
     {
      if(ObjectGet("MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)>MarketInfo(Symbol(),MODE_BID))
        {
         OrderButtonText="Order Sell Limit "+DoubleToString(sandboxlotsize,2)+" Lot";
        }
      else
        {
         OrderButtonText="Order Sell Stop "+DoubleToString(sandboxlotsize,2)+" Lot";
        }
     }
   ObjectSetString(0,"MMGTbox_OrderButton",OBJPROP_TEXT,OrderButtonText);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,// chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               xx=0,                      // X coordinate
                  const int               yy=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  cornerr=CORNER_LEFT_UPPER,// chart corner for anchoring
                  const string            text="Button",            // text
                  const string            font="Arial",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=true,              // hidden in the object list
                  const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create the button
   if(ObjectFind(chart_ID,name)<0)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create the button! Error code = ",GetLastError());
         return(false);
        }
      //--- set button coordinates
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,xx);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,yy);
      //--- set button size
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,cornerr);
      //--- set the text
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      //--- set text font
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      //--- set font size
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      //--- set text color
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      //--- set background color
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
      //--- set border color
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
      //--- display in the foreground (false) or background (true)
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      //--- set button state
      ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
      //--- enable (true) or disable (false) the mode of moving the button by mouse
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      //--- hide (true) or display (false) graphical object name in the object list
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      //--- set the priority for receiving the event of a mouse click in the chart
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      //--- successful execution
     }
   return(true);
  }
//+------------------------------------------------------------------+
