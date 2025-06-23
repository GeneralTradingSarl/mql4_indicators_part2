//+------------------------------------------------------------------+
//|                                                        MonEx.mq4 |
//|                 Copyright 2015,  Roy Philips Jacobs ~ 10/03/2015 |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp ~ By 3rjfx ~ 10/03/2015"
#property link      "http://www.mql5.com"
#property link      "http://www.gol2you.com"
#property description "MonEx indicator is the Weighted Close (HLCC/4) Candle stick bar combined with ZigZag indicator (Arrow)."
#property description "We recommend next chart settings (press F8 or select menu 'Charts'->'Properties...'):"
#property description " - on 'Color' Tab select 'None' for 'Line graph'"
#property description " - on 'Common' Tab disable 'Chart on Foreground' checkbox and select 'Line Chart' radiobutton"
#property version   "2.00"
#property strict
//---
/* Last Update (Update_01 ~ 2015-07-30)
   ~ Add option to display the arrow (True or False the arrow direction)
   ~ Make minor changes to the candle formula.
*/
//--
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 clrRed
#property indicator_color2 clrHoneydew
#property indicator_color3 clrRed
#property indicator_color4 clrHoneydew
#property indicator_color5 clrYellow
#property indicator_color6 clrSnow
//--
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 1
#property indicator_width6 1
//--
input color MonExColor1=clrRed;  // Shadow of bear candlestick
input color MonExColor2=clrHoneydew;  // Shadow of bull candlestick
input color MonExColor3=clrRed;  // Bear candlestick body
input color MonExColor4=clrHoneydew;  // Bull candlestick body
input bool  TurnArrow=False; // Switch ON/OFF (True or False) to display the arrow direction
input color MonExColor5=clrYellow;  // Bear Arrow
input color MonExColor6=clrAqua;  // Bull Arrow
//--- buffers
double MonExLowHighBuffer[];
double MonExHighLowBuffer[];
double MonExOpenBuffer[];
double MonExCloseBuffer[];
double MonExHighLowArrow[];
double MonExLowHighArrow[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MonExLowHighBuffer);
   SetIndexBuffer(1,MonExHighLowBuffer);
   SetIndexBuffer(2,MonExOpenBuffer);
   SetIndexBuffer(3,MonExCloseBuffer);
   SetIndexBuffer(4,MonExHighLowArrow);
   SetIndexBuffer(5,MonExLowHighArrow);
//--- indicator lines
   SetIndexStyle(0,DRAW_HISTOGRAM,0,1,MonExColor1);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,1,MonExColor2);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,3,MonExColor3);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,3,MonExColor4);
   SetIndexStyle(4,DRAW_ARROW,STYLE_SOLID,EMPTY,MonExColor5);
   SetIndexArrow(4,218);
   SetIndexStyle(5,DRAW_ARROW,STYLE_SOLID,EMPTY,MonExColor6);
   SetIndexArrow(5,217);
//---
   SetIndexLabel(0,"Low/High");
   SetIndexLabel(1,"High/Low");
   SetIndexLabel(2,"Open");
   SetIndexLabel(3,"Close");
   SetIndexLabel(4,"DnArrow");
   SetIndexLabel(5,"UpArrow");
//--
   SetIndexDrawBegin(0,10);
   SetIndexDrawBegin(1,10);
   SetIndexDrawBegin(2,10);
   SetIndexDrawBegin(3,10);
   SetIndexDrawBegin(4,10);
   SetIndexDrawBegin(5,10);
//--
   IndicatorShortName("MonEx");
   IndicatorDigits(Digits);
//--
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----  
   GlobalVariablesDeleteAll();
//----
   return;
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
//---
   int i,pss;
   int zhb,zlb,zz;
   double monOpen,monHigh,monLow,monClose;
   if(_Period<=5) zz=2;
   else zz=5;
//---
   if(rates_total<=10)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(MonExLowHighBuffer,false);
   ArraySetAsSeries(MonExHighLowBuffer,false);
   ArraySetAsSeries(MonExOpenBuffer,false);
   ArraySetAsSeries(MonExCloseBuffer,false);
   ArraySetAsSeries(MonExHighLowArrow,true);
   ArraySetAsSeries(MonExLowHighArrow,true);
   ArraySetAsSeries(open,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);
//--- preliminary calculation
   if(prev_calculated>1)
      pss=prev_calculated-1;
   else
     {
      //--- set first candle
      if(open[0]<close[0])
        {
         MonExLowHighBuffer[0]=low[0];
         MonExHighLowBuffer[0]=high[0];
        }
      else
        {
         MonExLowHighBuffer[0]=high[0];
         MonExHighLowBuffer[0]=low[0];
        }
      MonExOpenBuffer[0]=open[0];
      MonExCloseBuffer[0]=close[0];
      //---
      pss=1;
     }
//--- main loop of calculations
   for(i=pss; i<rates_total; i++)
     {
      monOpen=(high[i-1]+low[i-1]+close[i-1]+close[i-1])/4;
      monClose=(high[i]+low[i]+close[i]+close[i])/4;
      monHigh=MathMax(high[i],MathMax(monOpen,monClose));
      monLow=MathMin(low[i],MathMin(monOpen,monClose));
      if(monOpen<monClose)
        {
         MonExLowHighBuffer[i]=monLow;
         MonExHighLowBuffer[i]=monHigh;
        }
      else
        {
         MonExLowHighBuffer[i]=monHigh;
         MonExHighLowBuffer[i]=monLow;
        }
      MonExOpenBuffer[i]=monOpen;
      MonExCloseBuffer[i]=monClose;
      //-
      if(TurnArrow)
        {
         if(high[i]==iCustom(_Symbol,0,"ZigZag",1,i)) {zhb=i;}
         if(low[i]==iCustom(_Symbol,0,"ZigZag",2,i)) {zlb=i;}
         //-
         if(zhb==0) {MonExHighLowArrow[i]=iCustom(_Symbol,0,"ZigZag",1,i)+(zz*Point);}
         if(zlb==0) {MonExLowHighArrow[i]=iCustom(_Symbol,0,"ZigZag",2,i)-(zz*Point);}
        }
      //-
     }
//--
//--- done
   return(rates_total);
//--- return value of prev_calculated for next call   
  }
//+------------------------------------------------------------------+
