//+------------------------------------------------------------------+
//|                               Oscillator of Indicator and MA.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property description "Oscillator of Indicator & MA by pipPod"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 clrLimeGreen
#property indicator_color2 clrFireBrick
#property indicator_color3 clrAqua
#property indicator_color4 clrMagenta
//---
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
//---
enum ENUM_RANGEMODE
  {
   HIGH_LOW,         //High/Low
   CLOSE_CLOSE,      //Close/Close
   HIGH_LOW_CLOSE    //High/Low/Close
  };
//---
enum indicators
  {
   INDICATOR_MACD,         //Moving Average Convergence/Divergence
   INDICATOR_PRI,          //Percent Range Index
   INDICATOR_RSI,          //Relative Strength Index
   INDICATOR_CCI,          //Commodity Channel Index
   INDICATOR_RVI,          //Relative Vigor Index
   INDICATOR_DEMARKER,     //DeMarker Oscillator
  };
//---
input indicators Indicator=INDICATOR_MACD;
input ENUM_TIMEFRAMES TimeFrame=0;
input string _;//---
input bool ShowIndicator=true;
input bool ShowOscillator=true;
//---MACD
input string MACD;
input int FastMACD=12;
input int SlowMACD=26;
input ENUM_APPLIED_PRICE MACDPrice=PRICE_CLOSE;
input ENUM_MA_METHOD MACDMethod=MODE_EMA;
input int MACDSignal=9;
input ENUM_MA_METHOD MACDSignalMethod=MODE_SMA;
//---PRI
input string PRI;
input int PRIPeriod=14;
input ENUM_APPLIED_PRICE PRIPrice=PRICE_CLOSE;
input int Slowing=3;
input ENUM_RANGEMODE RangeMode=HIGH_LOW;
input int PRISignal=9;
input ENUM_MA_METHOD PRISignalMethod=MODE_SMMA;
//---RSI
input string RSI;
input int RSIPeriod=8;
input ENUM_APPLIED_PRICE RSIPrice=PRICE_CLOSE;
input int RSISignal=5;
input ENUM_MA_METHOD RSISignalMethod=MODE_LWMA;
//---CCI
input string CCI;
input int CCIPeriod=14;
input ENUM_APPLIED_PRICE CCIPrice=PRICE_CLOSE;
input int CCISignal=9;
input ENUM_MA_METHOD CCISignalMethod=MODE_SMMA;
//---RVI
input string RVI;
input int RVIPeriod=10;
input int RVISignal=5;
input ENUM_MA_METHOD RVISignalMethod=MODE_EMA;
//---DeMarker
input string DeMarker;
input int DeMarkerPeriod=14;
input int DeMarkerSignal=9;
input ENUM_MA_METHOD DeMarkerSignalMethod=MODE_LWMA;
input string __;//---
input int MAShift=0;
//---
double indicator,
       signal,
       oscillator;
//---
double IndicatorBuffer[];
double SignalBuffer[];
double Oscillator[];
double OscBuffer1[];
double OscBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorBuffers(indicator_buffers);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(0,OscBuffer1);
   SetIndexBuffer(1,OscBuffer2);
   SetIndexBuffer(2,IndicatorBuffer);
   SetIndexBuffer(3,SignalBuffer);
   SetIndexBuffer(4,Oscillator);
   SetIndexShift(3,MAShift);
//---
   string timeFrame = StringSubstr(EnumToString(TimeFrame),7)+" ";
   if(timeFrame=="CURRENT ")
      timeFrame="";
//---set indexlabel 
   string label1,
          label2,
          label3 = "Signal"+timeFrame,
          label4 = "Oscillator";
   switch(Indicator)
     {
      case INDICATOR_MACD:
         label1 = "iMACD "+timeFrame+"("+
                  IntegerToString(FastMACD)+","+
                  IntegerToString(SlowMACD)+","+
                  IntegerToString(MACDSignal)+") "+
                  StringSubstr(EnumToString(MACDSignalMethod),5);
         label2 = "iMACD "+timeFrame;
         IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
         break;
      case INDICATOR_PRI:
         label1 = "iPRI "+timeFrame+"("+
                  IntegerToString(PRIPeriod)+","+
                  IntegerToString(PRISignal)+","+
                  IntegerToString(Slowing)+") "+
                  StringSubstr(EnumToString(PRISignalMethod),5);
         label2 = "iPRI "+timeFrame;
         IndicatorSetInteger(INDICATOR_DIGITS,1);
         break;
      case INDICATOR_RSI:
         label1 = "iRSI "+timeFrame+"("+
                  IntegerToString(RSIPeriod)+","+
                  IntegerToString(RSISignal)+") "+
                  StringSubstr(EnumToString(RSISignalMethod),5);
         label2 = "iRSI "+timeFrame;
         IndicatorSetInteger(INDICATOR_DIGITS,1);
         break;
      case INDICATOR_CCI:
         label1 = "iCCI "+timeFrame+"("+
                  IntegerToString(CCIPeriod)+","+
                  IntegerToString(CCISignal)+") "+
                  StringSubstr(EnumToString(CCISignalMethod),5);
         label2 = "iCCI "+timeFrame;
         IndicatorSetInteger(INDICATOR_DIGITS,1);
         break;
      case INDICATOR_RVI:
         label1 = "iRVI "+timeFrame+"("+
                  IntegerToString(RVIPeriod)+","+
                  IntegerToString(RVISignal)+") "+
                  StringSubstr(EnumToString(RVISignalMethod),5);
         label2 = "iRVI "+timeFrame;
         IndicatorSetInteger(INDICATOR_DIGITS,1);
         break;
      case INDICATOR_DEMARKER:
         label1 = "iDeMarker "+timeFrame+"("+
                  IntegerToString(DeMarkerPeriod)+","+
                  IntegerToString(DeMarkerSignal)+") "+
                  StringSubstr(EnumToString(DeMarkerSignalMethod),5);
         label2 = "iDeMarker "+timeFrame;
         IndicatorSetInteger(INDICATOR_DIGITS,1);
     }
   IndicatorSetString(INDICATOR_SHORTNAME,label1);
   SetIndexLabel(0,label4);
   SetIndexLabel(1,label4);
   SetIndexLabel(2,label2);
   SetIndexLabel(3,label3);
//---
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
//---
   if(rates_total<100)  
      return(0);
   int i,limit,shift;
//---
   limit = rates_total - prev_calculated;
   if(prev_calculated==0)
      limit -= 100;
//---
   for(i=limit;i>=0;i--)
     {
      shift = iBarShift(_Symbol,TimeFrame,time[i]);
      switch(Indicator)
        {
         case INDICATOR_MACD:
            indicator = iMACD(_Symbol,TimeFrame,FastMACD,SlowMACD,MACDPrice,MACDMethod,MACDSignal,MACDSignalMethod,MODE_MAIN,shift);
            signal = iMACD(_Symbol,TimeFrame,FastMACD,SlowMACD,MACDPrice,MACDMethod,MACDSignal,MACDSignalMethod,MODE_SIGNAL,shift);
            break;
         case INDICATOR_PRI:
            indicator = iPRI(_Symbol,TimeFrame,PRIPeriod,PRIPrice,Slowing,RangeMode,PRISignal,PRISignalMethod,MODE_MAIN,shift);
            signal = iPRI(_Symbol,TimeFrame,PRIPeriod,PRIPrice,Slowing,RangeMode,PRISignal,PRISignalMethod,MODE_SIGNAL,shift);
            break;
         case INDICATOR_RSI:
            indicator = iRSI(_Symbol,TimeFrame,RSIPeriod,RSIPrice,RSISignal,RSISignalMethod,MODE_MAIN,shift);
            signal = iRSI(_Symbol,TimeFrame,RSIPeriod,RSIPrice,RSISignal,RSISignalMethod,MODE_SIGNAL,shift);
            break;
         case INDICATOR_CCI:
            indicator = iCCI(_Symbol,TimeFrame,CCIPeriod,CCIPrice,CCISignal,CCISignalMethod,MODE_MAIN,shift);
            signal = iCCI(_Symbol,TimeFrame,CCIPeriod,CCIPrice,CCISignal,CCISignalMethod,MODE_SIGNAL,shift);
            break;
         case INDICATOR_RVI:
            indicator = iRVI(_Symbol,TimeFrame,RVIPeriod,RVISignal,RVISignalMethod,MODE_MAIN,shift);
            signal = iRVI(_Symbol,TimeFrame,RVIPeriod,RVISignal,RVISignalMethod,MODE_SIGNAL,shift);
            break;
         case INDICATOR_DEMARKER:
            indicator = iDeMarker(_Symbol,TimeFrame,DeMarkerPeriod,DeMarkerSignal,DeMarkerSignalMethod,MODE_MAIN,shift);
            signal = iDeMarker(_Symbol,TimeFrame,DeMarkerPeriod,DeMarkerSignal,DeMarkerSignalMethod,MODE_SIGNAL,shift);
        } 
      oscillator = indicator - signal;
      
      if(ShowIndicator)
        {
         IndicatorBuffer[i] = indicator;
         SignalBuffer[i] = signal;
        }
      if(ShowOscillator)
        {
         Oscillator[i] = oscillator;
         if(Oscillator[i]>=Oscillator[i+1])
           { 
            OscBuffer1[i] = Oscillator[i];
            OscBuffer2[i] = EMPTY_VALUE;
           }
         else
           {   
            OscBuffer2[i] = Oscillator[i];
            OscBuffer1[i] = EMPTY_VALUE;
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Moving Average Convergence/Divergence                           |
//+------------------------------------------------------------------+
double iMACD(const string symbol,
             const ENUM_TIMEFRAMES timeframe,
             int fast_period,
             int slow_period,
             const ENUM_APPLIED_PRICE ma_price,
             const ENUM_MA_METHOD ma_method,
             int signal_period,
             const ENUM_MA_METHOD signal_method,
             int mode,
             int idx)
  { 
   double macd;
   if(mode==MODE_SIGNAL)
     {
      static double macdSignal[];
      if(ArraySize(macdSignal)!=signal_period)
         ArrayResize(macdSignal,signal_period);
      for(int i=0;i<signal_period;i++)
         macdSignal[i] = iMACD(symbol,
                               timeframe,
                               fast_period,
                               slow_period,
                               ma_price,
                               ma_method,
                               signal_period,
                               signal_method,
                               MODE_MAIN,
                               idx+i);
      macd = iMAOnArray(macdSignal,signal_period,signal_method,idx);
     }
   else
      macd = iMA(symbol,timeframe,fast_period,0,ma_method,ma_price,idx)-
             iMA(symbol,timeframe,slow_period,0,ma_method,ma_price,idx);
   
   return(macd);
  }
//+------------------------------------------------------------------+
//|  Percent Range Index                                             |
//+------------------------------------------------------------------+
double iPRI(const string symbol,
            const ENUM_TIMEFRAMES timeframe,
            int pri_period,
            const ENUM_APPLIED_PRICE pri_price,
            int slowing,
            const ENUM_RANGEMODE range_mode,
            int signal_period,
            const ENUM_MA_METHOD signal_method,
            int mode,
            int idx)
  {
   double pri;
   if(mode==MODE_SIGNAL)
     {
      static double priSignal[];
      if(ArraySize(priSignal)!=signal_period)
         ArrayResize(priSignal,signal_period);
      for(int i=0;i<signal_period;i++)
         priSignal[i] = iPRI(symbol,
                             timeframe,
                             pri_period,
                             pri_price,
                             slowing,
                             range_mode,
                             idx+i)-50;
      pri = iMAOnArray(priSignal,signal_period,signal_method,idx);
     }
   else
      pri = iPRI(symbol,
                 timeframe,
                 pri_period,
                 pri_price,
                 slowing,
                 range_mode,
                 idx)-50;
//---
   return(pri);
  }
//---
double iPRI(const string symbol,
            const ENUM_TIMEFRAMES timeframe,
            int pri_period,
            const ENUM_APPLIED_PRICE pri_price,
            int slowing,
            const ENUM_RANGEMODE range_mode,
            int idx)
  {
   double pri;
   double price;
   double maxHigh = 0.0;
   double minLow = 0.0;
   double highHigh,
          highClose,
          highLow;
   double lowHigh,
          lowClose,
          lowLow;
   double priRange;

   switch(range_mode)
     {
      case HIGH_LOW:
         maxHigh = iHigh(symbol,timeframe,
                   iHighest(symbol,timeframe,MODE_HIGH,pri_period,idx));
         minLow = iLow(symbol,timeframe,
                  iLowest(symbol,timeframe,MODE_LOW,pri_period,idx));   
         break;
      case CLOSE_CLOSE:
         maxHigh = iClose(symbol,timeframe,
                   iHighest(symbol,timeframe,MODE_CLOSE,pri_period,idx));
         minLow = iClose(symbol,timeframe,
                  iLowest(symbol,timeframe,MODE_CLOSE,pri_period,idx)); 
         break;
      case HIGH_LOW_CLOSE:
         highHigh = iHigh(symbol,timeframe,
                    iHighest(symbol,timeframe,MODE_HIGH,pri_period,idx));
         highLow = iLow(symbol,timeframe,
                   iHighest(symbol,timeframe,MODE_LOW,pri_period,idx));
         highClose = iClose(symbol,timeframe,
                     iHighest(symbol,timeframe,MODE_CLOSE,pri_period,idx));
         lowHigh = iHigh(symbol,timeframe,
                   iLowest(symbol,timeframe,MODE_HIGH,pri_period,idx));
         lowLow = iLow(symbol,timeframe,
                  iLowest(symbol,timeframe,MODE_LOW,pri_period,idx));
         lowClose = iClose(symbol,timeframe,
                    iLowest(symbol,timeframe,MODE_CLOSE,pri_period,idx));
         maxHigh = (highHigh+highLow+highClose)/3;
         minLow = (lowHigh+lowLow+lowClose)/3; 
         break;
     }

   double sum=0.0;
   double priceSlowing;
   for(int i=0;i<slowing;i++)
     {
      switch(pri_price)
        {
         case PRICE_CLOSE:    
            priceSlowing=iClose(symbol,timeframe,idx+i);    
            break;
         case PRICE_HIGH:     
            priceSlowing=iHigh(symbol,timeframe,idx+i);     
            break;
         case PRICE_LOW:      
            priceSlowing=iLow(symbol,timeframe,idx+i);      
            break;
         case PRICE_MEDIAN:   
            priceSlowing=(iHigh(symbol,timeframe,idx+i)+
                          iLow(symbol,timeframe,idx+i))/2;   
            break;
         case PRICE_TYPICAL:  
            priceSlowing=(iHigh(symbol,timeframe,idx+i)+
                          iLow(symbol,timeframe,idx+i)+
                          iClose(symbol,timeframe,idx+i))/3; 
            break;
         case PRICE_WEIGHTED: 
            priceSlowing=(iHigh(symbol,timeframe,idx+i)+
                          iLow(symbol,timeframe,idx+i)+
                          iClose(symbol,timeframe,idx+i)+
                          iClose(symbol,timeframe,idx+i))/4; 
            break;
         default:             
            priceSlowing=iClose(symbol,timeframe,idx+i);
        }
      sum += priceSlowing;
     }
   price = sum/slowing;

   priRange = maxHigh - minLow;
   if(!priRange)
      pri=50;
   else 
      pri=100*(price-minLow)/priRange;
   if(pri>100)  pri = 100;
   if(pri<0)    pri = 0;
//---
   return(pri);
  }      
//+------------------------------------------------------------------+
//|  Relative Strength Index                                         |
//+------------------------------------------------------------------+
double iRSI(const string symbol,
            const ENUM_TIMEFRAMES timeframe,
            int rsi_period,
            const ENUM_APPLIED_PRICE rsi_price,
            int signal_period,
            const ENUM_MA_METHOD signal_method,
            int mode,
            int idx)
  {
   double rsi;
   if(mode==MODE_SIGNAL)
     {
      static double rsiSignal[];
      if(ArraySize(rsiSignal)!=signal_period)
         ArrayResize(rsiSignal,signal_period);
      for(int i=0;i<signal_period;i++)
         rsiSignal[i] = iRSI(symbol,timeframe,rsi_period,rsi_price,idx+i)-50;
      rsi = iMAOnArray(rsiSignal,signal_period,signal_method,idx);
     }
   else
      rsi = iRSI(symbol,timeframe,rsi_period,rsi_price,idx)-50;
//---
   return(rsi);
  }
//+------------------------------------------------------------------+
//|  Commodity Channel Index                                         |
//+------------------------------------------------------------------+
double iCCI(const string symbol,
            const ENUM_TIMEFRAMES timeframe,
            int cci_period,
            const ENUM_APPLIED_PRICE cci_price,
            int signal_period,
            const ENUM_MA_METHOD signal_method,
            int mode,
            int idx)
  {
   double cci;
   if(mode==MODE_SIGNAL)
     {
      static double cciSignal[];
      if(ArraySize(cciSignal)!=signal_period)
         ArrayResize(cciSignal,signal_period);
      for(int i=0;i<signal_period;i++)
         cciSignal[i]=iCCI(symbol,timeframe,cci_period,cci_price,idx+i);
      cci = iMAOnArray(cciSignal,signal_period,signal_method,idx);
     }
   else
      cci = iCCI(symbol,timeframe,cci_period,cci_price,idx);
//---
   return(cci);
  }
//+------------------------------------------------------------------+
//|  Relative Vigor Index                                            |
//+------------------------------------------------------------------+
double iRVI(const string symbol,
            const ENUM_TIMEFRAMES timeframe,
            int rvi_period,
            int signal_period,
            const ENUM_MA_METHOD signal_method,
            int mode,
            int idx)
  {
   double rvi;
   if(mode==MODE_SIGNAL)
     {
      static double rviSignal[];
      if(ArraySize(rviSignal)!=signal_period)
         ArrayResize(rviSignal,signal_period);
      for(int i=0;i<signal_period;i++)
         rviSignal[i] = iRVI(symbol,timeframe,rvi_period,MODE_MAIN,idx+i);
      rvi = iMAOnArray(rviSignal,signal_period,signal_method,idx);
     }
   else
      rvi = iRVI(symbol,timeframe,rvi_period,MODE_MAIN,idx);
//---
   return(rvi);
  }
//+------------------------------------------------------------------+
//|  DeMarker Oscillator                                             |
//+------------------------------------------------------------------+
double iDeMarker(const string symbol,
                 const ENUM_TIMEFRAMES timeframe,
                 int demarker_period,
                 int signal_period,
                 const ENUM_MA_METHOD signal_method,
                 int mode,
                 int idx)
  {
   double demarker;
   if(mode==MODE_SIGNAL)
     {
      static double demarkerSignal[];
      if(ArraySize(demarkerSignal)!=signal_period)
         ArrayResize(demarkerSignal,signal_period);
      for(int i=0;i<signal_period;i++)
         demarkerSignal[i] = iDeMarker(symbol,timeframe,demarker_period,idx+i)-0.5;
      demarker = iMAOnArray(demarkerSignal,signal_period,signal_method,idx);
     }
   else
      demarker = iDeMarker(symbol,timeframe,demarker_period,idx)-0.5;
//---
   return(demarker);
  }
//+------------------------------------------------------------------+
//|  Moving Average on Array                                         |
//+------------------------------------------------------------------+
double iMAOnArray(const double &array[],
                  int period,
                  const ENUM_MA_METHOD ma_method,
                  int idx)
  {
   double ma = 0.0;
   if(ArraySize(array)<period)
      return(0.0);
   switch(ma_method)
     {
      case MODE_SMA:
        { 
         double sum = 0.0;
         for(int i=0;i<period;i++)
            sum += array[i];
         ma = sum / period;
         break;
        }
      case MODE_EMA:
        {
         double k = 2.0 / (period+1);
         double ema = 0.0;
         static double prevEma = 0.0;
         ema = array[0]*k + prevEma*(1-k);
         ma = ema;
         static int prevIdx;
         if(prevIdx!=idx)
           {
            prevIdx = idx;
            prevEma = ema;
           }
         break;
        }
      case MODE_SMMA:
        { 
         double sum = 0.0,
                smma = 0.0;
         static double prevSum = 0.0;
         for(int i=0;i<period;i++)
            sum += array[i];
         smma = prevSum/period;
         ma = (prevSum - smma + array[0])/period;
         static int prevIdx;
         if(prevIdx!=idx)
           {
            prevIdx = idx;
            prevSum = sum;
           }
         break;
        }
      case MODE_LWMA:
        {
         double sum1 = 0.0,
                sum2 = 0.0;
         for(int i=0,j=period;i<period;i++,j--)
           { 
            sum1 += array[i] * j;
            sum2 += j;
           }
         ma = sum1 / sum2;
        }
      }
   return(ma);
  }    
//-------------------------------------------------------------------+
