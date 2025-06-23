//+------------------------------------------------------------------+
//|                                              MoneyManagement.mq4 |
//|                               Copyright 2013, Vladimir Kjahrenov |
//|                                            info@tarkvaratehas.ee |
//|                                                                  |
//| Money Management / Risk Management visualiser                    |
//| This indicator uses 3 horizontal line to calculate lot size for  |
//| next order. You can visually drag lines for better position,     |
//| after draging all values are recalculated.                       |
//| This indicator is independent part but it is                     |
//| a part of an HurtLocker EA.                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Vladimir Kjahrenov"

#property indicator_chart_window 

extern int RiskPerOrder = 2; // risk per order 
string slName =   "sl";
string tpName =   "tp";
string oName =    "order";

extern color slColor =   Red;
extern color tpColor =   SpringGreen;
extern color oColor =    Yellow;

int labelFontSize = 7;

int BrokerDigitsMultiplier = 1;

string comment = "";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

   // check is broker have 5 or 4 digits
   if (MarketInfo(Symbol(), MODE_DIGITS) == 5 || MarketInfo(Symbol(), MODE_DIGITS) == 3){
		BrokerDigitsMultiplier = 10;
   }
   
   string  ObjName = "_panel_1";

	if (ObjectFind(ObjName) == -1) {
		ObjectCreate(ObjName, OBJ_LABEL, 0, 0, 0, 0, 0);
		ObjectSetText  (ObjName,"g",150, "Webdings", LightSteelBlue);
		ObjectSet      (ObjName, OBJPROP_CORNER,0);
		ObjectSet      (ObjName, OBJPROP_XDISTANCE, 0);
		ObjectSet      (ObjName, OBJPROP_YDISTANCE, 10);
		ObjectSet      (ObjName, OBJPROP_BACK, false);
	}
	
	string _symbol = Symbol();
	slName = _symbol + "_" + slName;
	tpName = _symbol + "_" + tpName;
	oName = _symbol + "_" + oName;
	
	// delete current currency global variables
   GlobalVariableDel(oName);
   GlobalVariableDel(slName);
   GlobalVariableDel(tpName);

   return(0);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   Comment("");
      
   // delete lines
   ObjectDelete(slName);
   ObjectDelete(tpName);
   ObjectDelete(oName);
   
   // delete labels
   ObjectDelete(Symbol() + "_lbl_StopLoss");
   ObjectDelete(Symbol() + "_lbl_TakeProfit");
   ObjectDelete(Symbol() + "_lbl_Order");
 
   // delete panel
   ObjectDelete("_panel_1");
  
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
   comment = "";
   
   // draw three lines automatically
   DrawLines();
   
   string lblNameO = "", lblNameTP = "", lblNameSL = "";
   string lblCommentSL = "", lblCommentTP = "", lblCommentO = "";  
   
   double StopLossPrice = 0, TakeProfitPrice = 0, OrderPrice = 0;
   double StopLossPips = 0, TakeProfitPips = 0;
   
   
   
   int seconds = 0;
   
   switch(Period()){
      case 5:
         seconds = 5 * 60;
         break;
      case 15:
         seconds = 15 * 60;
         break;
      case 30:
         seconds = 30 * 60;
         break;
      case 60:
         seconds = 60 * 60;
         break;
      case 240:
         seconds = 240 * 60;
         break;
      case 1440:
         seconds = 1440 * 60;
         break;
   }
   
   
   
   
   // check if no lines added with specified names
   
   //
   // STOPLOSS LINE
   //
   if (ObjectFind(slName) == -1){
      comment = comment + "Add HORISONTAL LINE for StopLoss and name it as 'sl' \n";
   } else {
      StopLossPrice = NormalizeDouble(ObjectGet(slName, OBJPROP_PRICE1), Digits * BrokerDigitsMultiplier);
      GlobalVariableSet(slName, StopLossPrice);
      
      
      // change line style
      ObjectSet(slName, OBJPROP_STYLE, STYLE_DASH);  
      ObjectSet(slName, OBJPROP_COLOR, slColor);
         
      // add label 
      lblCommentSL = StringConcatenate("StopLoss: ", StopLossPrice);
		lblNameSL = Symbol() + "_lbl_StopLoss";
      if (ObjectFind(lblNameSL) == -1){
         ObjectCreate(lblNameSL, OBJ_TEXT, 0, Time[0] + seconds * 20, StopLossPrice);
         ObjectSetText(lblNameSL, lblCommentSL, labelFontSize, "Arial", slColor);
         ObjectSet(lblNameSL, OBJPROP_BACK, true); 
      } else {
         ObjectMove(lblNameSL, 0, Time[0] + seconds * 20, StopLossPrice);
         ObjectSetText(lblNameSL, lblCommentSL, labelFontSize, "Arial", slColor);
      }
   }
      
   //
   // TAKEPROFIT LINE
   //
   if (ObjectFind(tpName) == -1){
      comment = comment + "Add HORISONTAL LINE for TakeProfit and name it as 'tp' \n";
   } else {
      TakeProfitPrice = NormalizeDouble(ObjectGet(tpName, OBJPROP_PRICE1), Digits * BrokerDigitsMultiplier);
      GlobalVariableSet(tpName, TakeProfitPrice);
      
      // change line style
      ObjectSet(tpName, OBJPROP_STYLE, STYLE_DASH);  
      ObjectSet(tpName, OBJPROP_COLOR, tpColor);
         
      // add label 
      lblCommentTP = StringConcatenate("TakeProfit: ", TakeProfitPrice);
		lblNameTP = Symbol() + "_lbl_TakeProfit";
		if (ObjectFind(lblNameTP) == -1){
         ObjectCreate(lblNameTP, OBJ_TEXT, 0, Time[0] + seconds * 20, TakeProfitPrice);
			ObjectSetText(lblNameTP, lblCommentTP, labelFontSize, "Arial", tpColor);
			ObjectSet(lblNameTP, OBJPROP_BACK, true); 
		} else {
         ObjectMove(lblNameTP, 0, Time[0]  + seconds * 20, TakeProfitPrice);
         ObjectSetText(lblNameTP, lblCommentTP, labelFontSize, "Arial", tpColor);
		}
   }
      
      
   //
   // ORDER LINE
   //
   if (ObjectFind(oName) == -1){
      comment = comment + "Add HORISONTAL LINE for Order and name it as 'order' \n";
   } else {
      // change line style
      OrderPrice = NormalizeDouble(ObjectGet(oName, OBJPROP_PRICE1), Digits * BrokerDigitsMultiplier);
      GlobalVariableSet(oName, OrderPrice);
      ObjectSet(oName, OBJPROP_COLOR, oColor);
         
      // add label 
      lblCommentO = StringConcatenate("Order: ", OrderPrice);
		lblNameO = Symbol() + "_lbl_Order";
		if (ObjectFind(lblNameO) == -1){
         ObjectCreate(lblNameO, OBJ_TEXT, 0, Time[0]  + seconds * 20, OrderPrice);
         ObjectSetText(lblNameO, lblCommentO, labelFontSize, "Arial", oColor);
         ObjectSet(lblNameO, OBJPROP_BACK, true); 
		} else {
			ObjectMove(lblNameO, 0, Time[0]  + seconds * 20, OrderPrice);
			ObjectSetText(lblNameO, lblCommentO, labelFontSize, "Arial", oColor);
		}
   }
   
   if (  (StopLossPrice > OrderPrice && TakeProfitPrice > OrderPrice) || 
         (TakeProfitPrice < OrderPrice && StopLossPrice  < OrderPrice)){ 
      Comment ("WRONG LINES POSITION"); 
      return (0);
   }
   
   // check for objects IF all lines are current then start to calculate 
   if (ObjectFind(slName) != -1 && ObjectFind(tpName) != -1 && ObjectFind(oName) != -1) { 

      //
      // FIND STOPLOSS AND TAKEPROFIT FROM LINES OPTIONS
      //
      if (OrderPrice > StopLossPrice && OrderPrice < TakeProfitPrice){
         StopLossPips = ((OrderPrice - StopLossPrice) / Point) / BrokerDigitsMultiplier;
         TakeProfitPips = ((TakeProfitPrice - OrderPrice) / Point) / BrokerDigitsMultiplier;
      }
		
		if (OrderPrice < StopLossPrice && OrderPrice > TakeProfitPrice){
         StopLossPips = ((StopLossPrice - OrderPrice) / Point) / BrokerDigitsMultiplier;
		   TakeProfitPips = ((OrderPrice - TakeProfitPrice) / Point) / BrokerDigitsMultiplier;
      }	   	
     
      // calculate your risk in currency
      double RiskInMoney = NormalizeDouble( (AccountEquity() * RiskPerOrder) / 100, 2);
      // calculate optimal lot size 
      double LotSize = NormalizeDouble(RiskInMoney / StopLossPips / (GetPriceByVolume(1.0) * BrokerDigitsMultiplier), 2);
      
    
    
      comment = comment + "----------------------------------------------------------------\n";
      comment = comment + "RISK MANAGEMENT (LOT SIZE: " + DoubleToStr(LotSize, 2)+ ")\n";
      comment = comment + "----------------------------------------------------------------\n";
      comment = comment + "Your RISK: " + RiskPerOrder + "% (" + DoubleToStr(RiskInMoney, 2) + " " + AccountCurrency() + ")\n";
	   comment = comment + "Current StopLoss: " + DoubleToStr(StopLossPips, 1) + "p. (" + DoubleToStr(StopLossPips * GetPriceByVolume(LotSize) * BrokerDigitsMultiplier, 2) + " " + AccountCurrency() + ")\n";	
	   
	   //
	   // calculate TakePRofit
	   //
	   comment = comment + "Current TakeProfit: " + DoubleToStr(TakeProfitPips, 1)+ "p.(" + DoubleToStr(TakeProfitPips * GetPriceByVolume(LotSize) * BrokerDigitsMultiplier, 2) + " " + AccountCurrency() + ")\n";
     
      //
      // calculate Risk / Reward
      //
      double RiskReward = NormalizeDouble(TakeProfitPips / StopLossPips, 1); 
      
      string slResult = "";
      if (RiskReward <= 0.9){
	     slResult = "BAD";
	   } else if (RiskReward >= 1 && RiskReward <= 1.5){
	     slResult = "poor";
      } else if (RiskReward >= 1.6 && RiskReward <= 2.5 ){
	     slResult = "normal";
      } else if (RiskReward >= 2.6 && RiskReward <= 3.5) {
         slResult = "good";
      }else if (RiskReward >= 3.6) {
         slResult = "excelent";
      }
      if (slResult == "BAD"){
         comment = comment + "Risk/Reward RATIO MUST BE AT LEAST 1/1 ! \n";
      } else {
         comment = comment + "Risk/Reward: 1 / " + DoubleToStr(RiskReward, 1) + " (" + slResult + ")\n";
      }
   
      comment = comment + "----------------------------------------------------------------\n";
      comment = comment + "MONEY MANAGEMENT \n";
      comment = comment + "----------------------------------------------------------------\n";
      comment = comment + "RECOMENDED LOT SIZE: " + DoubleToStr(LotSize, 2) + " ( " + DoubleToStr(GetPriceByVolume(LotSize) * BrokerDigitsMultiplier, 2) + " " + AccountCurrency() + ")\n";
      
      comment = comment + "\n";

      comment = comment + Symbol() + " spread: " + DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD) / BrokerDigitsMultiplier, 1) + "\n";
      // comment = comment + "Lot price (0.01): " + DoubleToStr(GetPriceByVolume(0.01) * BrokerDigitsMultiplier, 4) + "\n";                
      // comment = comment + "Lot price (0.1): " + DoubleToStr(GetPriceByVolume(0.1) * BrokerDigitsMultiplier, 4) + "\n";
      // comment = comment + "Lot price (1.0): " + DoubleToStr(GetPriceByVolume(1.0) * BrokerDigitsMultiplier, 4) + "\n";
      
	   comment = comment + "Leverage: 1:" + AccountLeverage() + "\n";	
	   comment = comment + "Balance: " + DoubleToStr(AccountBalance(), 2) + " (Equity: " + DoubleToStr(AccountEquity(), 2) + ")\n";	
	  
   }
   Comment(comment);
   return(0);
  }
//+------------------------------------------------------------------+

void DrawLines(){

   double openPrice = 0;
   
   if (ObjectFind("s") != -1){
   
      openPrice = NormalizeDouble(ObjectGet("s", OBJPROP_PRICE1), Digits * BrokerDigitsMultiplier);
      
      ObjectCreate(slName, OBJ_HLINE, 0, 0, openPrice - 20 * BrokerDigitsMultiplier * Point);
      ObjectSet(slName, OBJPROP_BACK, true); 
      ObjectCreate(tpName, OBJ_HLINE, 0, 0, openPrice + 40 * BrokerDigitsMultiplier * Point);
      ObjectSet(tpName, OBJPROP_BACK, true);
      ObjectCreate(oName, OBJ_HLINE, 0, 0, openPrice);
      ObjectSet(oName, OBJPROP_BACK, true);
      
      ObjectDelete("s");
      
      // delete current currency global variables
      GlobalVariableDel(oName);
      GlobalVariableDel(slName);
      GlobalVariableDel(tpName);
      
   } else if (ObjectFind("s") == -1 && GlobalVariableCheck(oName) == true){
   
      ObjectCreate(slName, OBJ_HLINE, 0, 0, GlobalVariableGet(slName));
      ObjectSet(slName, OBJPROP_BACK, true); 
      ObjectCreate(tpName, OBJ_HLINE, 0, 0, GlobalVariableGet(tpName));
      ObjectSet(tpName, OBJPROP_BACK, true);
      ObjectCreate(oName, OBJ_HLINE, 0, 0, GlobalVariableGet(oName));
      ObjectSet(oName, OBJPROP_BACK, true);
   
   }
  
}



double GetPriceByVolume(double OrderVolume){
   
   double tickPrice = MarketInfo(Symbol(), MODE_TICKVALUE);
	double price = NormalizeDouble((OrderVolume * tickPrice) / 1.0, 2);
	//debug ("Price of ", OrderVolume + " is " + DoubleToStr(price, 2));

	return (price);
}