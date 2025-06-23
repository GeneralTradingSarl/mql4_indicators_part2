//+------------------------------------------------------------------+
//|                                             Indicator Arrows.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Indicator Arrows by pipPod"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Arrows
#property indicator_label1  "BuyArrow"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLimeGreen
#property indicator_width1  1
#property indicator_label2  "SellArrow"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrFireBrick
#property indicator_width2  1
//---
enum indicators
  {
   INDICATOR_MA,           //Moving Average
   INDICATOR_MACD,         //Moving Average Convergence/Divergence
   INDICATOR_OSMA,         //Oscillator of Moving Averages
   INDICATOR_STOCHASTIC,   //Stochastic Oscillator
   INDICATOR_RSI,          //Relative Strength Index
   INDICATOR_CCI,          //Commodity Channel Index
   INDICATOR_RVI,          //Relative Vigor Index
   INDICATOR_ADX,          //Average Directional Movement Index
   INDICATOR_BANDS,        //Bollinger Bands
   INDICATOR_NONE          //No Indicator
  };
//---
input indicators Indicator1=INDICATOR_MACD;
input ENUM_TIMEFRAMES TimeFrame1=0;
input indicators Indicator2=INDICATOR_MA;
input ENUM_TIMEFRAMES TimeFrame2=0;
//---Range
input string Range;
input int RangePeriod=14;
//---Moving Average
input string MovingAverage;
input int MAPeriod=5;
input ENUM_MA_METHOD MAMethod=MODE_EMA;
input ENUM_APPLIED_PRICE MAPrice=PRICE_CLOSE;
//---MACD
input string MACD;
input int FastMACD=12;
input int SlowMACD=26;
input int SignalMACD=9;
input ENUM_APPLIED_PRICE MACDPrice=PRICE_CLOSE;
//---OsMA
input string OsMA;
input int FastOsMA=12;
input int SlowOsMA=26;
input int SignalOsMA=9;
input ENUM_APPLIED_PRICE OsMAPrice=PRICE_CLOSE;
input int OsMASignal=9;
//---Stoch
input string Stochastic;
input int Kperiod=8;
input int Dperiod=3;
input int Slowing=3;
input ENUM_MA_METHOD StochMAMethod=MODE_SMA;
input ENUM_STO_PRICE PriceField=STO_LOWHIGH;
//---RSI
input string RSI;
input int RSIPeriod=8;
input int RSISignal=5;
input ENUM_APPLIED_PRICE RSIPrice=PRICE_CLOSE;
//---CCI
input string CCI;
input int CCIPeriod=14;
input int CCISignal=5;
input ENUM_APPLIED_PRICE CCIPrice=PRICE_CLOSE;
//---RVI
input string RVI;
input int RVIPeriod=10;
//---ADX
input string ADX;
input int ADXPeriod=14;
input ENUM_APPLIED_PRICE ADXPrice=PRICE_CLOSE;
//---Bands
input string Bands;
input int BBPeriod=20;  //Bands Period
input double BBDev=2.0; //Bands Deviation
input ENUM_APPLIED_PRICE BBPrice=PRICE_CLOSE;   //Bands Price
input string _;//---
//---Alerts
input bool  AlertsOn      = true,
            AlertsMessage = true,
            AlertsEmail   = false,
            AlertsSound   = false;
//---
int indicator1,
    indicator2;
//---
double Buy[];
double Sell[];
//---
long chartID = ChartID();
#define LabelBox "LabelBox"
#define Label1 "Label1"
#define Label2 "Label2"
#define Label3 "Label3"
#define Label4 "Label4"
string label1 = "Spread ",
       label2 = "Range";
//---
int doubleToPip;
double pipToDouble;
//---
int rangeHandle,
    indHandle1,
    indHandle2;
//---
MqlTick tick;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME,"Indicator Arrows");
//--- set points & digits
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);   
   if(_Digits==2 || _Digits==3)  
      doubleToPip = 100;
   else                          
      doubleToPip = 10000;
   
   if(_Digits==2 || _Digits==4) 
      pipToDouble = _Point;
   else                       
      pipToDouble = _Point*10;
//---create label rectangle and labels
   string label3,
          label4;
   int xStart=7;
   int yStart=80;
   int yIncrement=14;
   int ySize=40;
   int ySizeInc=15;
   ObjectCreate(chartID,LabelBox,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(chartID,LabelBox,OBJPROP_XDISTANCE,3);
   ObjectSetInteger(chartID,LabelBox,OBJPROP_YDISTANCE,75);
   ObjectSetInteger(chartID,LabelBox,OBJPROP_XSIZE,135);
   ObjectSetInteger(chartID,LabelBox,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(chartID,LabelBox,OBJPROP_BGCOLOR,clrBlack);
   ObjectSetInteger(chartID,LabelBox,OBJPROP_BORDER_TYPE,BORDER_FLAT);

   ObjectCreate(chartID,Label1,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chartID,Label1,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(chartID,Label1,OBJPROP_YDISTANCE,yStart);
   ObjectSetString(chartID,Label1,OBJPROP_FONT,"Arial Bold");
   ObjectSetInteger(chartID,Label1,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(chartID,Label1,OBJPROP_COLOR,clrFireBrick);
   
   ObjectCreate(chartID,Label2,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chartID,Label2,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(chartID,Label2,OBJPROP_YDISTANCE,yStart+=yIncrement);
   ObjectSetString(chartID,Label2,OBJPROP_FONT,"Arial Bold");
   ObjectSetInteger(chartID,Label2,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(chartID,Label2,OBJPROP_COLOR,clrYellow);
//---
   string timeFrame1 = StringSubstr(EnumToString(TimeFrame1),7)+" ";
   string timeFrame2 = StringSubstr(EnumToString(TimeFrame2),7)+" ";
   if(timeFrame1=="CURRENT ")
      timeFrame1 = "";
   if(timeFrame2=="CURRENT ")
      timeFrame2 = "";
//---
   if(Indicator1==INDICATOR_NONE)
      Alert("Indicator1 can't be 'No Indicator'");
   switch(Indicator1)
     {
      case INDICATOR_MA:
         label3 = StringFormat("iMA %s %s (%d)",timeFrame1,
                  StringSubstr(EnumToString(MAMethod),5),MAPeriod);
         break;
      case INDICATOR_MACD:
         label3 = StringFormat("iMACD %s (%d,%d,%d)",timeFrame1,
                  FastMACD,SlowMACD,SignalMACD);
         break;
      case INDICATOR_OSMA:
         label3 = StringFormat("iOsMA %s (%d,%d,%d)",timeFrame1,
                  FastOsMA,SlowOsMA,SignalOsMA);
         break;
      case INDICATOR_STOCHASTIC:
         label3 = StringFormat("iStoch %s (%d,%d,%d) %s",timeFrame1,
                  Kperiod,Dperiod,Slowing,
                  StringSubstr(EnumToString(StochMAMethod),5));
         break;
      case INDICATOR_RSI:
         label3 = StringFormat("iRSI %s (%d,%d)",timeFrame1,
                  RSIPeriod,RSISignal);
         break;
      case INDICATOR_CCI:
         label3 = StringFormat("iCCI %s (%d,%d)",timeFrame1,
                  CCIPeriod,CCISignal);
         break;
      case INDICATOR_RVI:
         label3 = StringFormat("iRVI %s (%d)",timeFrame1,
                  RVIPeriod);
         break;
      case INDICATOR_ADX:
         label3 = StringFormat("iADX %s (%d)",timeFrame1,
                  ADXPeriod);
         break;
      case INDICATOR_BANDS:
         label3 = StringFormat("iBands %s (%d,%2.1f)",timeFrame1,
                  BBPeriod,BBDev);
     }
   ObjectSetInteger(chartID,LabelBox,OBJPROP_YSIZE,ySize+=ySizeInc);
   ObjectCreate(chartID,Label3, OBJ_LABEL,0,0,0);
   ObjectSetInteger(chartID,Label3,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(chartID,Label3,OBJPROP_YDISTANCE,yStart+=yIncrement);
   ObjectSetString(chartID,Label3,OBJPROP_TEXT,label3);
   ObjectSetString(chartID,Label3,OBJPROP_FONT,"Arial Bold");
   ObjectSetInteger(chartID,Label3,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(chartID,Label3,OBJPROP_COLOR,clrLimeGreen);
//---
   if(Indicator2!=INDICATOR_NONE)
     {
      switch(Indicator2)
        {
         case INDICATOR_MA:
            label4 = StringFormat("iMA %s %s (%d)",timeFrame2,
                     StringSubstr(EnumToString(MAMethod),5),MAPeriod);
            break;
         case INDICATOR_MACD:
            label4 = StringFormat("iMACD %s (%d,%d,%d)",timeFrame2,
                     FastMACD,SlowMACD,SignalMACD);
            break;
         case INDICATOR_OSMA:
            label4 = StringFormat("iOsMA %s (%d,%d,%d)",timeFrame2,
                     FastOsMA,SlowOsMA,SignalOsMA);
            break;
         case INDICATOR_STOCHASTIC:
            label4 = StringFormat("iStoch %s (%d,%d,%d) %s",timeFrame2,
                     Kperiod,Dperiod,Slowing,
                     StringSubstr(EnumToString(StochMAMethod),5));
            break;
         case INDICATOR_RSI:
            label4 = StringFormat("iRSI %s (%d,%d)",timeFrame2,
                     RSIPeriod,RSISignal);
            break;
         case INDICATOR_CCI:
            label4 = StringFormat("iCCI %s (%d)",timeFrame2,
                     CCIPeriod);
            break;
         case INDICATOR_RVI:
            label4 = StringFormat("iRVI %s (%d)",timeFrame2,
                     RVIPeriod);
            break;
         case INDICATOR_ADX:
            label4 = StringFormat("iADX %s (%d)",timeFrame2,
                     ADXPeriod);
            break;
         case INDICATOR_BANDS:
            label4 = StringFormat("iBands %s (%d,%2.1f)",timeFrame2,
                     BBPeriod,BBDev);
        }      
      ObjectSetInteger(chartID,LabelBox,OBJPROP_YSIZE,ySize+=ySizeInc);
      ObjectCreate(chartID,Label4,OBJ_LABEL,0,0,0);
      ObjectSetInteger(chartID,Label4,OBJPROP_XDISTANCE,xStart);
      ObjectSetInteger(chartID,Label4,OBJPROP_YDISTANCE,yStart+=yIncrement);
      ObjectSetString(chartID,Label4,OBJPROP_TEXT,label4);
      ObjectSetString(chartID,Label4,OBJPROP_FONT,"Arial Bold");
      ObjectSetInteger(chartID,Label4,OBJPROP_FONTSIZE,10);
      ObjectSetInteger(chartID,Label4,OBJPROP_COLOR,clrLimeGreen);
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,Buy,INDICATOR_DATA);
   ArraySetAsSeries(Buy,true);
   PlotIndexSetString(0,PLOT_LABEL,"BuyArrow");   
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   SetIndexArrow(0,233);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   SetIndexBuffer(1,Sell,INDICATOR_DATA);
   ArraySetAsSeries(Sell,true);
   PlotIndexSetString(1,PLOT_LABEL,"SellArrow");   
   PlotIndexSetInteger(1,PLOT_ARROW,234);
   SetIndexArrow(1,234);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//---
   return(INIT_SUCCEEDED);
  }
//---
#define OP_NONE -1
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
   if(rates_total<100)  
      return(0);
//---
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//---
   if(SymbolInfoTick(_Symbol,tick))
      ObjectSetString(chartID,Label1,OBJPROP_TEXT,label1 + 
                      DoubleToString((tick.ask-tick.bid)*doubleToPip,1));
   static datetime prevTime;
   if(prev_calculated>0 && time[0]!=prevTime)
     {
      prevTime = time[0];
      ObjectSetString(chartID,Label2,OBJPROP_TEXT,label2 + 
                      StringFormat("(%d) %4.1f",RangePeriod,Range(0)*doubleToPip));
     }
   int i,limit,shift1,shift2;
//---
   limit = rates_total - prev_calculated;
   if(prev_calculated==0)
     { 
      limit = (int)ChartGetInteger(chartID,CHART_VISIBLE_BARS)+100;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-limit);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,rates_total-limit);
     }
//---
   for(i=limit;i>=0 && !IsStopped();i--)
     {
      shift1 = iBarShift(_Symbol,TimeFrame1,time[i]);
      switch(Indicator1)
        {
         case INDICATOR_MA:
            indicator1 = iMA(TimeFrame1,shift1);
            break;
         case INDICATOR_MACD:
            indicator1 = iMACD(TimeFrame1,shift1);
            break;
         case INDICATOR_OSMA:
            indicator1 = iOsMA(TimeFrame1,shift1);
            break;
         case INDICATOR_STOCHASTIC:
            indicator1 = iStochastic(TimeFrame1,shift1);
            break;
         case INDICATOR_RSI:
            indicator1 = iRSI(TimeFrame1,shift1);
            break;
         case INDICATOR_CCI:
            indicator1 = iCCI(TimeFrame1,shift1);
            break;
         case INDICATOR_RVI:
            indicator1 = iRVI(TimeFrame1,shift1);
            break;
         case INDICATOR_ADX:
            indicator1 = iADX(TimeFrame1,shift1);
            break;
         case INDICATOR_BANDS:
            indicator1 = iBands(TimeFrame1,shift1);
        }

      if(Indicator2!=INDICATOR_NONE)
        {
         shift2 = iBarShift(_Symbol,TimeFrame2,time[i]);
         switch(Indicator2)
           {
            case INDICATOR_MA:
               indicator2 = iMA(TimeFrame2,shift2);
               break;
            case INDICATOR_MACD:
               indicator2 = iMACD(TimeFrame2,shift2);
               break;
            case INDICATOR_OSMA:
               indicator2 = iOsMA(TimeFrame2,shift2);
               break;
            case INDICATOR_STOCHASTIC:
               indicator2 = iStochastic(TimeFrame2,shift2);
               break;
            case INDICATOR_RSI:
               indicator2 = iRSI(TimeFrame2,shift2);
               break;
            case INDICATOR_CCI:
               indicator2 = iCCI(TimeFrame2,shift2);
               break;
            case INDICATOR_RVI:
               indicator2 = iRVI(TimeFrame2,shift2);
               break;
            case INDICATOR_ADX:
               indicator2 = iADX(TimeFrame2,shift2);
               break;
            case INDICATOR_BANDS:
               indicator2 = iBands(TimeFrame2,shift2);
           }
        }
      if(Indicator2==INDICATOR_NONE)
        {
         if(indicator1==OP_BUY)
           {
            Buy[i] = low[i] - Range(i);
            if(AlertsOn && prev_calculated>0) 
               AlertsHandle(time[0],OP_BUY);
            Sell[i] = 0;
           }
         else if(indicator1==OP_SELL)   
           {
            Sell[i] = high[i] + Range(i);
            if(AlertsOn && prev_calculated>0) 
               AlertsHandle(time[0],OP_SELL);
            Buy[i] = 0;
           }
         else
           {
            Buy[i] = 0;
            Sell[i]= 0;
           } 
        }
      else
        {
         if(indicator1==OP_BUY && indicator2==OP_BUY)
           {
            Buy[i] = low[i] - Range(i);
            if(AlertsOn && prev_calculated>0) 
               AlertsHandle(time[0],OP_BUY);
            Sell[i] = 0;
           }
         else if(indicator1==OP_SELL && indicator2==OP_SELL)   
           {
            Sell[i] = high[i] + Range(i);
            if(AlertsOn && prev_calculated>0) 
               AlertsHandle(time[0],OP_SELL);
            Buy[i] = 0;
           }
         else
           {
            Buy[i] = 0;
            Sell[i]= 0;
           } 
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---check & delete labels
   if(ObjectFind(0,LabelBox)!=-1)
      ObjectDelete(0,LabelBox);
   if(ObjectFind(0,Label1)!=-1)
      ObjectDelete(0,Label1);
   if(ObjectFind(0,Label2)!=-1)
      ObjectDelete(0,Label2);
   if(ObjectFind(0,Label3)!=-1)
      ObjectDelete(0,Label3);
   if(ObjectFind(0,Label4)!=-1)
      ObjectDelete(0,Label4);
   return;
  }
//+------------------------------------------------------------------+
//|  Average Range                                                   |
//+------------------------------------------------------------------+
double Range(int idx)
  {
   double avgRange = iATR(_Symbol,0,RangePeriod,idx+1);
   return(avgRange);
  }
//+------------------------------------------------------------------+
//|  Moving Average                                                  |
//+------------------------------------------------------------------+
int iMA(const ENUM_TIMEFRAMES timeframe,
        const int idx)
  { 
   int signal=OP_NONE;
   double currMA = iMA(_Symbol,timeframe,MAPeriod,0,MAMethod,MAPrice,idx);
   double prevMA = iMA(_Symbol,timeframe,MAPeriod,0,MAMethod,MAPrice,idx+1);
   
   if(currMA>prevMA+1*pipToDouble)
      signal=OP_BUY;
   if(currMA<prevMA-1*pipToDouble)
      signal=OP_SELL;
//---
   return(signal);
  }
//+------------------------------------------------------------------+
//|  Moving Average Convergence/Divergence                           |
//+------------------------------------------------------------------+
int iMACD(const ENUM_TIMEFRAMES timeframe,
          const int idx)
  { 
   int signal=OP_NONE;
   double currMACD = iMACD(_Symbol,timeframe,FastMACD,SlowMACD,SignalMACD,MACDPrice,MODE_MAIN,idx);
   double currSign = iMACD(_Symbol,timeframe,FastMACD,SlowMACD,SignalMACD,MACDPrice,MODE_SIGNAL,idx);
   double prevMACD = iMACD(_Symbol,timeframe,FastMACD,SlowMACD,SignalMACD,MACDPrice,MODE_MAIN,idx+1);
   double prevSign = iMACD(_Symbol,timeframe,FastMACD,SlowMACD,SignalMACD,MACDPrice,MODE_SIGNAL,idx+1);
//---
   if(currMACD>currSign && prevMACD<prevSign)
      signal=OP_BUY;
   if(currMACD<currSign && prevMACD>prevSign)
      signal=OP_SELL;
//---
   return(signal);
  }
//+------------------------------------------------------------------+
//|  Oscillator of Moving Averages                                   |
//+------------------------------------------------------------------+
int iOsMA(const ENUM_TIMEFRAMES timeframe,
          const int idx)
  { 
   int signal=OP_NONE;
   double currOsMA = iOsMA(_Symbol,timeframe,FastOsMA,SlowOsMA,SignalOsMA,OsMAPrice,OsMASignal,MODE_MAIN,idx);
   double currSign = iOsMA(_Symbol,timeframe,FastOsMA,SlowOsMA,SignalOsMA,OsMAPrice,OsMASignal,MODE_SIGNAL,idx);
   double prevOsMA = iOsMA(_Symbol,timeframe,FastOsMA,SlowOsMA,SignalOsMA,OsMAPrice,OsMASignal,MODE_MAIN,idx+1);
   double prevSign = iOsMA(_Symbol,timeframe,FastOsMA,SlowOsMA,SignalOsMA,OsMAPrice,OsMASignal,MODE_SIGNAL,idx+1);

   if(currOsMA>currSign && prevOsMA<prevSign)
      signal=OP_BUY;
   if(currOsMA<currSign && prevOsMA>prevSign)
      signal=OP_SELL;
//---
   return(signal);
  }
//---
double iOsMA(const string symbol,
             const ENUM_TIMEFRAMES timeframe,
             int fast_ema_period,
             int slow_ema_period,
             int signal_period,
             const ENUM_APPLIED_PRICE price,
             int signal,
             int mode,
             int idx)
  {
   double osma;
   if(mode==MODE_SIGNAL)
     {
      double sum=0.0;
      static double osmaSignal[];
      if(ArraySize(osmaSignal)!=signal)
         ArrayResize(osmaSignal,signal);
      for(int i=0;i<signal;i++)
        {
         osmaSignal[i]=iOsMA(symbol,
                             timeframe,
                             fast_ema_period,
                             slow_ema_period,
                             signal_period,
                             price,
                             idx+i);
         sum+=osmaSignal[i];
        }
      osma=sum/signal;
     }
   else
      osma=iOsMA(symbol,
                 timeframe,
                 fast_ema_period,
                 slow_ema_period,
                 signal_period,
                 price,
                 idx);
   return(osma);
  }
//+------------------------------------------------------------------+
//|  Stochastic Oscillator                                           |
//+------------------------------------------------------------------+
int iStochastic(const ENUM_TIMEFRAMES timeframe,
                const int idx)
  { 
   int signal=OP_NONE;
   double currStoc = iStochastic(_Symbol,timeframe,Kperiod,Dperiod,Slowing,MODE_SMA,PriceField,MODE_MAIN,idx);
   double currSign = iStochastic(_Symbol,timeframe,Kperiod,Dperiod,Slowing,MODE_SMA,PriceField,MODE_SIGNAL,idx);
   double prevStoc = iStochastic(_Symbol,timeframe,Kperiod,Dperiod,Slowing,MODE_SMA,PriceField,MODE_MAIN,idx+1);
   double prevSign = iStochastic(_Symbol,timeframe,Kperiod,Dperiod,Slowing,MODE_SMA,PriceField,MODE_SIGNAL,idx+1);
   
   if(currStoc>currSign && prevStoc<prevSign)
      signal=OP_BUY;
   if(currStoc<currSign && prevStoc>prevSign)
      signal=OP_SELL;
//---
   return(signal);
  }            
//+------------------------------------------------------------------+
//|  Relative Strength Index                                         |
//+------------------------------------------------------------------+
int iRSI(const ENUM_TIMEFRAMES timeframe,
         const int idx)
  { 
   int signal=OP_NONE;
   double currRsi = iRSI(_Symbol,timeframe,RSIPeriod,RSISignal,RSIPrice,MODE_MAIN,idx);
   double currSign= iRSI(_Symbol,timeframe,RSIPeriod,RSISignal,RSIPrice,MODE_SIGNAL,idx);
   double prevRsi = iRSI(_Symbol,timeframe,RSIPeriod,RSISignal,RSIPrice,MODE_MAIN,idx+1);
   double prevSign= iRSI(_Symbol,timeframe,RSIPeriod,RSISignal,RSIPrice,MODE_SIGNAL,idx+1);
//---
   if(currRsi>currSign && prevRsi<prevSign)
      signal=OP_BUY;
   if(currRsi<currSign && prevRsi>prevSign)
      signal=OP_SELL;
 
   return(signal);
  }            
//---
double iRSI(const string symbol,
            const ENUM_TIMEFRAMES timeframe,
            const int period,
            const int signal,
            const ENUM_APPLIED_PRICE price,
            const int mode=MODE_MAIN,
            const int idx=0)
  {
   double rsi;
   if(mode==MODE_SIGNAL)
     {
      double sum=0.0;
      static double rsiSignal[];
      if(ArraySize(rsiSignal)!=signal)
         ArrayResize(rsiSignal,signal);
      for(int i=0;i<signal;i++)
        {
         rsiSignal[i]=iRSI(symbol,timeframe,period,price,idx+i);
         sum+=rsiSignal[i];
        }
      rsi=sum/signal;
     }
   else
      rsi=iRSI(symbol,timeframe,period,price,idx);
//---
   return(rsi);
  }
//+------------------------------------------------------------------+
//|  Commodity Channel Index                                         |
//+------------------------------------------------------------------+
int iCCI(const ENUM_TIMEFRAMES timeframe,
         const int idx)
  { 
   int signal=OP_NONE;
   double currCci = iCCI(_Symbol,timeframe,CCIPeriod,CCISignal,CCIPrice,MODE_MAIN,idx);
   //double currSign = iCCI(_Symbol,timeframe,CCIPeriod,CCISignal,CCIPrice,MODE_SIGNAL,idx);
   double prevCci = iCCI(_Symbol,timeframe,CCIPeriod,CCISignal,CCIPrice,MODE_MAIN,idx+1);
   //double prevSign = iCCI(_Symbol,timeframe,CCIPeriod,CCISignal,CCIPrice,MODE_SIGNAL,idx+1);
   double level[3] = {-100,0,100};
//---
   for(int i=0;i<3;i++)
     {
      if(currCci>level[i] && prevCci<=level[i])
        {
         signal=OP_BUY;
         break;
        } 
      if(currCci<level[i] && prevCci>=level[i])
        {
         signal=OP_SELL;
         break;
        } 
     } 
//---
   return(signal);
  }            
//---
double iCCI(const string symbol,
            const ENUM_TIMEFRAMES timeframe,
            const int period,
            const int signal,
            const ENUM_APPLIED_PRICE price,
            const int mode=MODE_MAIN,
            const int idx=0)
  {
   double cci;
   if(mode==MODE_SIGNAL)
     {
      double sum=0.0;
      static double cciSignal[];
      if(ArraySize(cciSignal)!=signal)
         ArrayResize(cciSignal,signal);
      for(int i=0;i<signal;i++)
        {
         cciSignal[i]=iCCI(symbol,timeframe,period,price,idx+i);
         sum+=cciSignal[i];
        }
      cci=sum/signal;
     }
   else
      cci=iCCI(symbol,timeframe,period,price,idx);
//---
   return(cci);
  }
//+------------------------------------------------------------------+
//|  Relative Vigor Index                                            |
//+------------------------------------------------------------------+
int iRVI(const ENUM_TIMEFRAMES timeframe,
         const int idx)
  { 
   int signal=OP_NONE;
   double currRvi = iRVI(_Symbol,timeframe,RVIPeriod,MODE_MAIN,idx);
   double currSign= iRVI(_Symbol,timeframe,RVIPeriod,MODE_SIGNAL,idx);
   double prevRvi = iRVI(_Symbol,timeframe,RVIPeriod,MODE_MAIN,idx+1);
   double prevSign= iRVI(_Symbol,timeframe,RVIPeriod,MODE_SIGNAL,idx+1);
//---
   if(currRvi>currSign && prevRvi<prevSign)
      signal=OP_BUY;
   if(currRvi<currSign && prevRvi>prevSign)
      signal=OP_SELL;
//---
   return(signal);
  }            
//+------------------------------------------------------------------+
//|  Average Directional Movement Index                              |
//+------------------------------------------------------------------+
int iADX(const ENUM_TIMEFRAMES timeframe,
         const int idx)
  { 
   int signal=OP_NONE;
   bool adx = iADX(_Symbol,timeframe,ADXPeriod,ADXPrice,MODE_MAIN,idx)<25;
   double currPDi = iADX(_Symbol,timeframe,ADXPeriod,ADXPrice,MODE_PLUSDI,idx);
   double currMDi = iADX(_Symbol,timeframe,ADXPeriod,ADXPrice,MODE_MINUSDI,idx);
   double prevPDi = iADX(_Symbol,timeframe,ADXPeriod,ADXPrice,MODE_PLUSDI,idx+1);
   double prevMDi = iADX(_Symbol,timeframe,ADXPeriod,ADXPrice,MODE_MINUSDI,idx+1);
   
   if(adx && currPDi>currMDi && prevPDi<prevMDi)
      signal=OP_BUY;
   if(adx && currPDi<currMDi && prevPDi>prevMDi)
      signal=OP_SELL;
//---
   return(signal);
  }            
//+------------------------------------------------------------------+
//|  Bollinger Bands                                                 |
//+------------------------------------------------------------------+
int iBands(const ENUM_TIMEFRAMES timeframe,
           const int idx)
  { 
   int signal=OP_NONE;
   double high = iHigh(_Symbol,timeframe,idx);
   double low = iLow(_Symbol,timeframe,idx);
   double close = iClose(_Symbol,timeframe,idx);
   double upperBand = iBands(_Symbol,timeframe,BBPeriod,BBDev,0,BBPrice,MODE_UPPER,idx);
   double midleBand = iBands(_Symbol,timeframe,BBPeriod,BBDev,0,BBPrice,MODE_MAIN,idx);
   double lowerBand = iBands(_Symbol,timeframe,BBPeriod,BBDev,0,BBPrice,MODE_LOWER,idx);
   
   if((low<lowerBand && close>lowerBand) ||
      (low<midleBand && close>midleBand))
      signal=OP_BUY;
   if((high>upperBand && close<upperBand) ||
      (high>midleBand && close<midleBand))
      signal=OP_SELL;
//---
   return(signal);
  }               
//+------------------------------------------------------------------+
//|  Alerts Handle                                                   |
//+------------------------------------------------------------------+
void AlertsHandle(const datetime &time,
                  const ENUM_ORDER_TYPE alert_type)
  {
   static datetime timePrev;
   static ENUM_ORDER_TYPE typePrev;
   string alertMessage;
   double price = 0.0;
   
   if(timePrev!=time || typePrev!=alert_type)
     {
      timePrev = time;
      typePrev = alert_type;
      alertMessage = StringFormat("%s @ %s %s @ %s",_Symbol,TimeToString(TimeLocal(),TIME_MINUTES),
                                  StringSubstr(EnumToString(alert_type),11),DoubleToString(Bid,_Digits));
      if(AlertsMessage) 
         Alert(alertMessage);
      if(AlertsEmail) 
         SendMail(_Symbol+" Arrow Alert",alertMessage);
      if(AlertsSound) 
         PlaySound("alert2.wav");
     }
  }
//+------------------------------------------------------------------+
