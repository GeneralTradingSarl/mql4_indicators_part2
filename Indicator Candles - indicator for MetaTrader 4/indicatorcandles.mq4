//+------------------------------------------------------------------+
//|                                            Indicator Candles.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Indicator Candles by pipPod"
#property strict
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 4

#property indicator_color4 clrMagenta
#property indicator_width4 2

#property indicator_levelcolor clrLightSlateGray

double indicator_level1 = 20;
double indicator_level2 = 50;
double indicator_level3 = 80;

double indicator_level4 = 30;
double indicator_level5 = 50;
double indicator_level6 = 70;

double indicator_level7 = -100;
double indicator_level8 =    0;
double indicator_level9 =  100;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum indicators
  {
   INDICATOR_PRI,  //Percent Range Index 
   INDICATOR_RSI,  //Relative Strength Index
   INDICATOR_CCI,  //Commodity Channel Index
   INDICATOR_PRICE //Prices
  };

enum ENUM_RANGEMODE
  {
   HIGH_LOW,      //High/Low
   CLOSE_CLOSE,   //Close/Close
   HIGH_LOW_CLOSE //High/Low/Close
  };

input indicators Indicator=INDICATOR_PRI;
//--- indicator parameters
input string _ = "Chart = Chart Symbol";
extern string Symbol_="Chart";

input int PRIPeriod=14; // Percent Range Index Period
input int PRISignal=3; // PRI Signal Period
input ENUM_APPLIED_PRICE PRIPrice=PRICE_CLOSE; // PRI Price
input ENUM_RANGEMODE PRIMode=HIGH_LOW;

input int RSIPeriod=14; // Relative Strength Index Period
input int RSISignal=3; // RSI Signal Period
input ENUM_APPLIED_PRICE RSIPrice=PRICE_CLOSE; // RSI Price

input int CCIPeriod=14; // Commodity Channel Index Period
input int CCISignal=3; // CCI Signal Period
input ENUM_APPLIED_PRICE CCIPrice=PRICE_CLOSE; // CCI Price

input int PriceSignal=14; //Price MA Period

input ENUM_TIMEFRAMES TimeFrame=0;

input int indicator_width1=3; //CandleBody Width
input int indicator_width2=1; //CandleWick Width

input bool SignalLine=true; // Show signal line for indicator
input bool PriceLine=true; // Show horizontal price line
input bool AutoColor=true;
//--- indicator buffers
double    _High[];
double    _Low[];
double    _Close[];
double    _Signal[];

double    _high,
          _low,
          _close,
          _signal;

string    candle_1,
          candle_2,
          body="body",
          wick="wick",
          priceLine="PriceLine";

color     candleColor;
color     color_1;
color     color_2;
int       barsWindow;
long      chartID;
int       window;

//--- right input parameters flag
bool      ExtParameters=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   if(Symbol_=="Chart")
      Symbol_=_Symbol;   
   else
      StringToUpper(Symbol_);
   
   color_1=clrLimeGreen;
   color_2=clrFireBrick;
   
   if(AutoColor)
     {
      string Base = StringSubstr(Symbol_,0,3);  //Base currency name
      string Quote= StringSubstr(Symbol_,3,3);  //Quote currency name
      if(Base=="EUR")   color_1=clrRoyalBlue;
      if(Quote=="EUR")  color_2=clrRoyalBlue;
      if(Base=="GBP")   color_1=clrSilver;
      if(Quote=="GBP")  color_2=clrSilver;
      if(Base=="AUD")   color_1=clrDarkOrange;
      if(Quote=="AUD")  color_2=clrDarkOrange;
      if(Base=="NZD")   color_1=clrDarkViolet;
      if(Quote=="NZD")  color_2=clrDarkViolet;
      if(Base=="CAD")   color_1=clrWhite;
      if(Quote=="CAD")  color_2=clrWhite;
      if(Base=="CHF")   color_1=clrFireBrick;
      if(Quote=="CHF")  color_2=clrFireBrick;
      if(Base=="JPY")   color_1=clrYellow;
      if(Quote=="JPY")  color_2=clrYellow;
      if(Base=="USD")   color_1=clrLimeGreen;
      if(Quote=="USD")  color_2=clrLimeGreen;
      if(Base=="XAU")   color_1=clrGold;
     }  
//--- drawing settings
   SetIndexStyle(0,INDICATOR_DATA,EMPTY,EMPTY,clrNONE);
   SetIndexStyle(1,INDICATOR_DATA,EMPTY,EMPTY,clrNONE);
   SetIndexStyle(2,INDICATOR_DATA,EMPTY,EMPTY,clrNONE);
   SetIndexStyle(3,DRAW_LINE);
//--- indicator buffers mapping
   SetIndexBuffer(0,_High);
   SetIndexBuffer(1,_Low);
   SetIndexBuffer(2,_Close);
   SetIndexBuffer(3,_Signal);

   SetLevelStyle(STYLE_DOT,1,indicator_levelcolor);
   
   string   timeFrame;
   switch(TimeFrame)
     {
      case PERIOD_MN1: timeFrame = " MN1 ";break;
      case PERIOD_W1:  timeFrame = " W1 "; break;
      case PERIOD_D1:  timeFrame = " D1 "; break;
      case PERIOD_H4:  timeFrame = " H4 "; break;
      case PERIOD_H1:  timeFrame = " H1 "; break;
      case PERIOD_M30: timeFrame = " M30 ";break;
      case PERIOD_M15: timeFrame = " M15 ";break;
      case PERIOD_M5:  timeFrame = " M5 "; break;
      case PERIOD_M1:  timeFrame = " M1 "; break;
      default:         timeFrame = " ";
     }
   string shortName,
          label_1,
          label_2,
          label_3,
          label_4;
   switch(Indicator)
     {
      case INDICATOR_PRI:  
         shortName="PRI "+Symbol_+timeFrame+"("+
         IntegerToString(PRIPeriod)+","+
         IntegerToString(PRISignal)+")";
         label_1="PRI High "+timeFrame;
         label_2="PRI Low "+timeFrame;   
         label_3="PRI Close "+timeFrame;   
         label_4="PRI Signal "+timeFrame;   
         SetLevelValue(0,indicator_level1);
         SetLevelValue(1,indicator_level2);
         SetLevelValue(2,indicator_level3);
         IndicatorDigits(0);
         break;
      case INDICATOR_RSI:  
         shortName="RSI "+Symbol_+timeFrame+"("+
         IntegerToString(RSIPeriod)+","+
         IntegerToString(RSISignal)+")";
         label_1="RSI High "+timeFrame;
         label_2="RSI Low "+timeFrame;   
         label_3="RSI Close "+timeFrame;   
         label_4="RSI Signal "+timeFrame;   
         SetLevelValue(0,indicator_level4);
         SetLevelValue(1,indicator_level5);
         SetLevelValue(2,indicator_level6);
         IndicatorDigits(0);
         break;
      case INDICATOR_CCI:  
         shortName="CCI "+Symbol_+timeFrame+"("+
         IntegerToString(CCIPeriod)+","+
         IntegerToString(CCISignal)+")";
         label_1="CCI High "+timeFrame;
         label_2="CCI Low "+timeFrame;   
         label_3="CCI Close "+timeFrame;   
         label_4="CCI Signal "+timeFrame;   
         SetLevelValue(0,indicator_level7);
         SetLevelValue(1,indicator_level8);
         SetLevelValue(2,indicator_level9);
         IndicatorDigits(0);
         break;
      case INDICATOR_PRICE: 
         shortName="Price "+Symbol_+timeFrame+"("+
         IntegerToString(PriceSignal)+")";
         label_1="Price High "+timeFrame;
         label_2="Price Low "+timeFrame;   
         label_3="Price Close "+timeFrame;   
         label_4="Price Signal "+timeFrame;   
         IndicatorDigits(_Digits-1);
     }
//--- name for DataWindow and indicator subwindow label
   IndicatorShortName(shortName);
   window=WindowFind(shortName);
   chartID=ChartID();
   
   SetIndexLabel(0,label_1);
   SetIndexLabel(1,label_2);
   SetIndexLabel(2,label_3);
   SetIndexLabel(3,label_4);
//--- check for input parameters
   if(PRIPeriod<=1  || RSIPeriod<=1  || CCIPeriod<=1)
     {
      Print("Wrong input parameters");
      ExtParameters=false;
      return(INIT_FAILED);
     }
   else
      ExtParameters=true;
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   int i,limit/*,shift*/;
   static int candle;
//---
   barsWindow=WindowBarsPerChart();
   if(rates_total<=barsWindow || !ExtParameters)
      return(0);
//---
   limit=rates_total-prev_calculated;
//--- 
   if(prev_calculated==0)
     {
      limit=barsWindow;
      candle=0;
      double price;
      switch(Indicator)
        {
         case INDICATOR_PRI:
            _High[limit+1]=50;
            _Low[limit+1]=50;
            _Close[limit+1]=50;
            _Signal[limit+1]=50;
            break;
         case INDICATOR_RSI:
            _High[limit+1]=50;
            _Low[limit+1]=50;
            _Close[limit+1]=50;
            _Signal[limit+1]=50;
            break;
         case INDICATOR_CCI:
            _High[limit+1]=0.0;
            _Low[limit+1]=0.0;
            _Close[limit+1]=0.0;
            _Signal[limit+1]=0.0;
            break;
         case INDICATOR_PRICE:
            price=iClose(Symbol_,TimeFrame,limit);
            _High[limit+1]=price;
            _Low[limit+1]=price;
            _Close[limit+1]=price;
            _Signal[limit+1]=price;
        }
     } 

   for(i=limit; i>=0;i--)
     {
      //shift=iBarShift(Symbol_,TimeFrame,time[i]);
      switch(Indicator)
        {
         case INDICATOR_PRI:
            _high =iPRI(Symbol_,TimeFrame,PRIPeriod,PRISignal,PRICE_HIGH,MODE_MAIN,i); 
            _low  =iPRI(Symbol_,TimeFrame,PRIPeriod,PRISignal,PRICE_LOW,MODE_MAIN,i); 
            _close=iPRI(Symbol_,TimeFrame,PRIPeriod,PRISignal,PRIPrice,MODE_MAIN,i);
            if(SignalLine)
               _signal=iPRI(Symbol_,TimeFrame,PRIPeriod,PRISignal,PRIPrice,MODE_SIGNAL,i);
            break;
         case INDICATOR_RSI:
            _high =iRSI(Symbol_,TimeFrame,RSIPeriod,RSISignal,PRICE_HIGH,MODE_MAIN,i); 
            _low  =iRSI(Symbol_,TimeFrame,RSIPeriod,RSISignal,PRICE_LOW,MODE_MAIN,i); 
            _close=iRSI(Symbol_,TimeFrame,RSIPeriod,RSISignal,RSIPrice,MODE_MAIN,i); 
            if(SignalLine)
               _signal=iRSI(Symbol_,TimeFrame,RSIPeriod,RSISignal,RSIPrice,MODE_SIGNAL,i); 
            break;
         case INDICATOR_CCI:
            _high =iCCI(Symbol_,TimeFrame,CCIPeriod,CCISignal,PRICE_HIGH,MODE_MAIN,i); 
            _low  =iCCI(Symbol_,TimeFrame,CCIPeriod,CCISignal,PRICE_LOW,MODE_MAIN,i);
            _close=iCCI(Symbol_,TimeFrame,CCIPeriod,CCISignal,CCIPrice,MODE_MAIN,i); 
            if(SignalLine)
               _signal=iCCI(Symbol_,TimeFrame,CCIPeriod,CCISignal,CCIPrice,MODE_SIGNAL,i); 
            break;
         case INDICATOR_PRICE:
            _high =iHigh(Symbol_,TimeFrame,i); 
            _low  =iLow(Symbol_,TimeFrame,i);
            _close=iClose(Symbol_,TimeFrame,i); 
            if(SignalLine)
               _signal=iMA(Symbol_,TimeFrame,PriceSignal,0,MODE_SMA,PRICE_CLOSE,i); 
        }

      _High[i]=_high;
      _Low[i]=_low;
      _Close[i]=_close;
      
      _High[i]=MathMax(_High[i],_Close[i+1]);
      _Low[i]=MathMin(_Low[i],_Close[i+1]);
      
      if(_Close[i]>=_Close[i+1])
         candleColor=color_1;
      else
         candleColor=color_2;
         
      candle_1=body+string(candle);
      candle_2=wick+string(candle);
      
      ObjectCreate(candle_1,candle_2,time[i],_Close[i+1],_High[i],_Low[i],_Close[i],candleColor);
      
      if(SignalLine)
         _Signal[i]=_signal;

      if(prev_calculated==0 || NewBar(time[0]))
         candle++;
      //--- done
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
#define OBJ_NONE -1
void OnDeinit(const int reason)
  {
//---- check & delete candles
   for(int i=0;i<Bars;i++)
     {
      candle_1=body+string(i);
      candle_2=wick+string(i);
      if(ObjectFind(chartID,candle_1)!=OBJ_NONE)
         ObjectDelete(chartID,candle_1);
      if(ObjectFind(chartID,candle_2)!=OBJ_NONE)
         ObjectDelete(chartID,candle_2);
      if(ObjectFind(chartID,priceLine)!=OBJ_NONE)
         ObjectDelete(chartID,priceLine);
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
const bool NewBar(const datetime& time)
  {
   static datetime time_prev;
   if(time_prev!=time)
     {
      time_prev=time;
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectCreate(const string object_name1,
                  const string object_name2,
                  const datetime &time, 
                  const double &open_price, 
                  const double &high_price, 
                  const double &low_price, 
                  const double &close_price,
                  const color candle_color)
  {
   if(ObjectFind(chartID,object_name1)!=OBJ_NONE)
      ObjectDelete(chartID,object_name1);
   if(!ObjectCreate(chartID,object_name1,OBJ_TREND,window,time,open_price,time,close_price))
      Print(__FUNCTION__,": error ",GetLastError());
   ObjectSetInteger(chartID,object_name1,OBJPROP_WIDTH,indicator_width1);
   ObjectSetInteger(chartID,object_name1,OBJPROP_COLOR,candle_color);
   ObjectSetInteger(chartID,object_name1,OBJPROP_RAY,false);
   ObjectSetInteger(chartID,object_name1,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chartID,object_name1,OBJPROP_SELECTABLE,false);
   if(ObjectFind(chartID,object_name2)!=OBJ_NONE)
      ObjectDelete(chartID,object_name2);
   if(!ObjectCreate(chartID,object_name2,OBJ_TREND,window,time,high_price,time,low_price))
      Print(__FUNCTION__,": error ",GetLastError());
   ObjectSetInteger(chartID,object_name2,OBJPROP_WIDTH,indicator_width2);
   ObjectSetInteger(chartID,object_name2,OBJPROP_COLOR,candle_color);
   ObjectSetInteger(chartID,object_name2,OBJPROP_RAY,false);
   ObjectSetInteger(chartID,object_name2,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chartID,object_name2,OBJPROP_SELECTABLE,false);
   if(ObjectFind(chartID,priceLine)!=OBJ_NONE)
      ObjectDelete(chartID,priceLine);
   if(PriceLine)
     {
      if(!ObjectCreate(chartID,priceLine,OBJ_HLINE,window,0,close_price))
         Print(__FUNCTION__,": error ",GetLastError());
      ObjectSetInteger(chartID,priceLine,OBJPROP_WIDTH,1);
      ObjectSetInteger(chartID,priceLine,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(chartID,priceLine,OBJPROP_COLOR,clrLightSlateGray);
      ObjectSetInteger(chartID,priceLine,OBJPROP_HIDDEN,true);
      ObjectSetInteger(chartID,priceLine,OBJPROP_SELECTABLE,false);
     }
   return;
  } 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
const double iPRI(const string symbol,
                  const ENUM_TIMEFRAMES timeframe,
                  const int period,
                  const int signal,
                  const ENUM_APPLIED_PRICE price,
                  const int mode=MODE_MAIN,
                  const int idx=0)
  {
   int i;
   double pri;
   double sum=0.0;
   if(mode==MODE_SIGNAL)
     {
      static double priSignal[1];
      if(ArraySize(priSignal)!=period)
         ArrayResize(priSignal,signal);
      for(i=0;i<signal;i++)
        {
         priSignal[i]=iPRI(symbol,timeframe,period,price,idx+i);
         sum+=priSignal[i];
        }
      pri=sum/signal;
     }
   else
      pri=iPRI(symbol,timeframe,period,price,idx);
   return(pri);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
const double iPRI(const string symbol,
                  const ENUM_TIMEFRAMES timeframe,
                  const int period,
                  const ENUM_APPLIED_PRICE price,
                  const int idx)
  {
   double pri;
   double Price;
   double MaxHigh=0.0,MinLow=0.0;
   double HighHigh,HighClose,HighLow;
   double LowHigh,LowClose,LowLow;
   double PRIRange;

   switch(PRIMode)
     {
      case HIGH_LOW:
         MaxHigh=iHigh(symbol,timeframe,
                 iHighest(symbol,timeframe,MODE_HIGH,period,idx));
         MinLow=iLow(symbol,timeframe,
                iLowest(symbol,timeframe,MODE_LOW,period,idx));   
         break;
      case CLOSE_CLOSE:
         MaxHigh=iClose(symbol,timeframe,
                 iHighest(symbol,timeframe,MODE_CLOSE,period,idx));
         MinLow=iClose(symbol,timeframe,
                iLowest(symbol,timeframe,MODE_CLOSE,period,idx)); 
         break;
      case HIGH_LOW_CLOSE:
         HighHigh=iHigh(symbol,timeframe,
                  iHighest(symbol,timeframe,MODE_HIGH,period,idx));
         HighLow=iLow(symbol,timeframe,
                 iHighest(symbol,timeframe,MODE_LOW,period,idx));
         HighClose=iClose(symbol,timeframe,
                   iHighest(symbol,timeframe,MODE_CLOSE,period,idx));
         LowHigh=iHigh(symbol,timeframe,
                 iLowest(symbol,timeframe,MODE_HIGH,period,idx));
         LowLow=iLow(symbol,timeframe,
                iLowest(symbol,timeframe,MODE_LOW,period,idx));
         LowClose=iClose(symbol,timeframe,
                  iLowest(symbol,timeframe,MODE_CLOSE,period,idx));
         MaxHigh=(HighHigh+HighLow+HighClose)/3;
         MinLow=(LowHigh+LowLow+LowClose)/3; 
         break;
     }

   switch(price)
     {
      case PRICE_CLOSE:    
         Price =  iClose(symbol,timeframe,idx);    break;
      case PRICE_HIGH:     
         Price =  iHigh(symbol,timeframe,idx);     break;
      case PRICE_LOW:      
         Price =  iLow(symbol,timeframe,idx);      break;
      case PRICE_MEDIAN:   
         Price = (iHigh(symbol,timeframe,idx)+
                  iLow(symbol,timeframe,idx))/2;   break;
      case PRICE_TYPICAL:  
         Price = (iHigh(symbol,timeframe,idx)+
                  iLow(symbol,timeframe,idx)+
                  iClose(symbol,timeframe,idx))/3; break;
      case PRICE_WEIGHTED: 
         Price = (iHigh(symbol,timeframe,idx)+
                  iLow(symbol,timeframe,idx)+
                  iClose(symbol,timeframe,idx)+
                  iClose(symbol,timeframe,idx))/4; break;
      default:             
         Price =  iClose(symbol,timeframe,idx);
     }

   PRIRange=MaxHigh-MinLow;
   if(!PRIRange)
      pri=50;
   else 
      pri=100*(Price-MinLow)/PRIRange;
   return(pri);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
const double iRSI(const string symbol,
                  const ENUM_TIMEFRAMES timeframe,
                  const int period,
                  const int signal,
                  const ENUM_APPLIED_PRICE price,
                  const int mode=MODE_MAIN,
                  const int idx=0)
  {
   int i;
   double rsi;
   double sum=0.0;
   if(mode==MODE_SIGNAL)
     {
      static double rsiSignal[1];
      if(ArraySize(rsiSignal)!=period)
         ArrayResize(rsiSignal,signal);
      for(i=0;i<signal;i++)
        {
         rsiSignal[i]=iRSI(symbol,timeframe,period,price,idx+i);
         sum+=rsiSignal[i];
        }
      rsi=sum/signal;
     }
   else
      rsi=iRSI(symbol,timeframe,period,price,idx);
   return(rsi);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
const double iCCI(const string symbol,
                  const ENUM_TIMEFRAMES timeframe,
                  const int period,
                  const int signal,
                  const ENUM_APPLIED_PRICE price,
                  const int mode=MODE_MAIN,
                  const int idx=0)
  {
   int i;
   double cci;
   double sum=0.0;
   if(mode==MODE_SIGNAL)
     {
      static double cciSignal[1];
      if(ArraySize(cciSignal)!=period)
         ArrayResize(cciSignal,signal);
      for(i=0;i<signal;i++)
        {
         cciSignal[i]=iCCI(symbol,timeframe,period,price,idx+i);
         sum+=cciSignal[i];
        }
      cci=sum/signal;
     }
   else
      cci=iCCI(symbol,timeframe,period,price,idx);
   return(cci);
  }
//+------------------------------------------------------------------+
