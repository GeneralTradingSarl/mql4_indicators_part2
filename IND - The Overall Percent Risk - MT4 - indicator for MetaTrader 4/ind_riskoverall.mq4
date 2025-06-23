//+------------------------------------------------------------------+
//|                                              IND_RiskOverall.mq4 |
//|                                        Copyright 2021, FxWeirdos |
//|                                               info@fxweirdos.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2021, FxWeirdos. Mario Gharib. Forex Jarvis. info@fxweirdos.com"
#property link      "https://fxweirdos.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0

double dAmtRisking;
double dAmtRewarding;

color cFontClr = C'255,166,36';                    // FONT COLOR

void vSetLabel(string sName,int sub_window, int xx, int yy, color cFontColor, int iFontSize, string sText) {
   ObjectCreate(0,sName,OBJ_LABEL,sub_window,0,0);
   ObjectSetInteger(0,sName, OBJPROP_YDISTANCE, xx);
   ObjectSetInteger(0,sName, OBJPROP_XDISTANCE, yy);
   ObjectSetInteger(0,sName, OBJPROP_COLOR,cFontColor);
   ObjectSetInteger(0,sName, OBJPROP_WIDTH,FW_BOLD);   
   ObjectSetInteger(0,sName, OBJPROP_FONTSIZE, iFontSize);
   ObjectSetString(0,sName,OBJPROP_TEXT, 0,sText);
   ObjectSetInteger(0,sName,OBJPROP_SELECTABLE,false);
}

void vSetBackground(string sName,int sub_window, int xx, int yy, int width, int height) {

   ObjectCreate(0,sName,OBJ_RECTANGLE_LABEL,sub_window,0,0);
   ObjectSetInteger(0,sName,OBJPROP_XDISTANCE,xx);
   ObjectSetInteger(0,sName,OBJPROP_YDISTANCE,yy);
   ObjectSetInteger(0,sName,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,sName,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,sName,OBJPROP_BGCOLOR,C'19,22,31');
   ObjectSetInteger(0,sName,OBJPROP_SELECTABLE,false);
}

double dp, pipPos, dNbPips, PipValue;

double dValuePips(string sSymbol, double dPrice1, double dSLTP, double dVolume) {

   if (MarketInfo(sSymbol,MODE_DIGITS)==1 || MarketInfo(sSymbol,MODE_DIGITS)==3 || MarketInfo(sSymbol,MODE_DIGITS)==5)
      dp=10;
   else 
      dp=1;   
   
   pipPos = MarketInfo(sSymbol,MODE_POINT)*dp;
	dNbPips = NormalizeDouble(MathAbs((dPrice1-dSLTP)/pipPos),1);
   PipValue = MarketInfo(sSymbol,MODE_TICKVALUE)*pipPos/MarketInfo(sSymbol,MODE_TICKSIZE);
   
   if (StringFind(sSymbol,"XAU")>=0 && StringFind(sSymbol,"USD")>=0 && PipValue==0.1)
      PipValue=PipValue*10;
   else if (StringFind(sSymbol,"XAG")>=0 && StringFind(sSymbol,"USD")>=0 && PipValue==5.0)
      PipValue=PipValue*10;

	return NormalizeDouble(dNbPips*PipValue*dVolume,2);

}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   ChartSetInteger(0,CHART_COLOR_BID,C'19,22,31');
   ChartSetInteger(0,CHART_COLOR_ASK,C'19,22,31');
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,C'19,22,31');   
   ChartSetInteger(0,CHART_COLOR_FOREGROUND,C'19,22,31');
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,C'19,22,31');
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,C'19,22,31');
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,C'19,22,31');
   ChartSetInteger(0,CHART_COLOR_CHART_UP,C'19,22,31');
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,C'19,22,31');
   ChartSetInteger(0,CHART_COLOR_GRID,C'19,22,31');
   ChartSetInteger(0,CHART_SHOW_ONE_CLICK,false);

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
   
     	dAmtRisking=0.0;
     	dAmtRewarding=0.0;
   	
   	for (int j=0 ; j < OrdersTotal() ; j++) {
   	   
			if (OrderSelect(j,SELECT_BY_POS,MODE_TRADES)) {
      
      	   if (OrderGetInteger(ORDER_TYPE)==0 || OrderGetInteger(ORDER_TYPE)==1) {
      	   
      			dAmtRisking =    dAmtRisking +    dValuePips(OrderSymbol(), OrderOpenPrice(), OrderStopLoss(), OrderLots());
      			dAmtRewarding =  dAmtRewarding +  dValuePips(OrderSymbol(), OrderOpenPrice(), OrderTakeProfit(), OrderLots());

      		}
      	}
      }

      vSetLabel("OVERALLRISK",0,25,20,cFontClr,10,"Overall Risk: "+ DoubleToString(dAmtRisking/AccountInfoDouble(ACCOUNT_BALANCE)*100,2)+"%");
      vSetLabel("OVERALLTARGET",0,45,20,cFontClr,10,"Overall Target: "+ DoubleToString(dAmtRewarding/AccountInfoDouble(ACCOUNT_BALANCE)*100,2)+"%");  

   return(rates_total);

}