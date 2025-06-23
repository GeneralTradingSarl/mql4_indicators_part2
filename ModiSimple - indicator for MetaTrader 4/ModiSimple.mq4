#property copyright "Max Berilo"
//----
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 LimeGreen
#property indicator_color3 Black
#property indicator_color4 Red
#property indicator_color5 Green
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 0
#property indicator_width4 1
#property indicator_width5 1
//---- input parameters
extern bool ShowBody     = True;
extern bool UseRSI       = True;
extern bool UseRSIaccel  = True;
extern bool UseRSIvalue  = False;
extern bool UseRSIdir    = True;
extern bool UseRSIhist   = True;
extern bool UseRSIisect  = True;
extern bool UseRSIsign   = False;
extern int  RSIperiod    = 14;
extern int  RSIfast      = 12;
extern int  RSIslow      = 26;
extern int  RSIsignal    = 9;
extern int  RSIbuyThreshold  = 40;
extern int  RSIsellThreshold = 60;
extern bool UseMACD      = True;
extern bool UseMACDaccel = True;
extern bool UseMACDvalue = False;
extern bool UseMACDdir   = True;
extern bool UseMACDhist  = False;
extern bool UseMACDisect = False;
extern bool UseMACDsign  = False;
extern int  FastMA       = 12;
extern int  SlowMA       = 26;
extern int  SignalMA     =  9;
//----
extern bool   ShowTrail   = True;
extern string TrlComment  = "SATL-1,FATL-2,EMA(HLC/3)-3,(HLC/3)-4,EMA(C)-5,C-6";
extern int    TrlMethod   = 5;
extern int    TrlPeriod   = 5;
extern double TrlInitMul  = 1.0;
extern double TrlMul      = 2.0;
extern int    TrlAtrPer   = 21;
extern int    TrlTrap     = 0;
extern bool   TrlUseMax   = False;
extern int    TrlMaxTrap  = 45;
//---- buffers
double ExtMap1[];
double ExtMap2[];
double TrlBegin[];
double TrlStopDn[];
double TrlStopUp[];
double RSI[];
double RSImacd[];
double MACD[];
//---- defines
int nFATL = 39;
int nSATL = 65;
//---- static parameters
double Spread;
static int nDrawBegin;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//----
    IndicatorBuffers(8);
    SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 2);
    SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 2);
    SetIndexStyle(2, DRAW_ARROW);
    SetIndexStyle(3, DRAW_LINE);
    SetIndexStyle(4, DRAW_LINE);
    SetIndexArrow(2, 159);
    SetIndexBuffer(0, ExtMap1);
    SetIndexBuffer(1, ExtMap2);
    SetIndexBuffer(2, TrlBegin);
    SetIndexBuffer(3, TrlStopDn);
    SetIndexBuffer(4, TrlStopUp);
    SetIndexBuffer(5, RSI);
    SetIndexBuffer(6, RSImacd);
    SetIndexBuffer(7, MACD);
//----
    nDrawBegin = TrlPeriod + TrlAtrPer;
    if(TrlMethod == 1) {
      nDrawBegin += nSATL;
    }
    SetIndexDrawBegin(2, nDrawBegin);
    SetIndexDrawBegin(3, nDrawBegin);
    SetIndexDrawBegin(4, nDrawBegin);
//---- labels
    string short_name = "Simple";
    SetIndexLabel(0, short_name);
    SetIndexLabel(1, short_name);
    SetIndexLabel(2, "TrlBegin");
    SetIndexLabel(3, "TrlStopDn");
    SetIndexLabel(4, "TrlStopUp");
//----
    return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
double CalcTrailStop(int shift, bool uptrend, bool initial)
  {
    double res, atr, sl = TrlTrap;
    if(!initial) {
      shift++;
    }
    atr = iATR(NULL, 0, TrlAtrPer, shift) / Point;
    if(initial) {
      sl  += TrlInitMul * atr;
    } else {
      sl  += TrlMul * atr;
    }
    if(TrlUseMax && sl > TrlMaxTrap) {
      sl = TrlMaxTrap;
    }
    switch(TrlMethod) {
      case 1:
        res = CalcSATLonMedian(shift);
        break;
      case 2:
        res = CalcFATLonMedian(shift);
        break;
      case 3:
        res = iMA(NULL, 0, TrlPeriod, 0, MODE_EMA, PRICE_TYPICAL, shift);
        break;
      case 4:
        res = (High[shift] + Low[shift] + Close[shift]) / 3.0;
        break;
      case 5:
        res = iMA(NULL, 0, TrlPeriod, 0, MODE_EMA, PRICE_CLOSE, shift);
        break;
      case 6:
      default:
        res = Close[shift];
        break;
    }
    if(uptrend) {
      res -= sl * Point;
    } else {
      res += (sl + Spread) * Point;
    }
    res = NormalizeDouble(res, Digits);
    return(res);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
    int    limit, shift, counted_bars = IndicatorCounted();
    double val1, val2, ma, signal, prevsign, atr;
    bool   buy, sell, bRSIbuy, bRSIsell, bMACDbuy, bMACDsell;
//----
    double StopLoss;
    bool   TrlLong, TrlPrevLong, TrlShort, TrlPrevShort;
//----
    Spread = MarketInfo(Symbol(), MODE_SPREAD);
    if(!ShowTrail) {
      SetIndexDrawBegin(2, Bars);
      SetIndexDrawBegin(3, Bars);
      SetIndexDrawBegin(4, Bars);
    }
//---- last counted bar will be recounted
    if(Bars <= RSIperiod) return(0);
    if(counted_bars > 0) {
      counted_bars--;
    } else {
      ArrayInitialize(TrlBegin,  EMPTY_VALUE);
      ArrayInitialize(TrlStopDn, EMPTY_VALUE);
      ArrayInitialize(TrlStopUp, EMPTY_VALUE);
    }
    limit = Bars - counted_bars - 1;
//----
    for(shift = limit; shift >= 0; shift--) {
      if(UseRSI) {
        RSI[shift] = iRSI(NULL, 0, RSIperiod, PRICE_CLOSE, shift);
      } else {
        RSI[shift] = 0;
      }
      if(UseMACD) {
        MACD[shift] = iMACD(NULL, 0, FastMA, SlowMA, SignalMA, PRICE_CLOSE, MODE_MAIN, shift);
      } else {
        MACD[shift] = 0;
      }
    }
//----
    for(shift = limit; UseRSI && (shift >= 0); shift--) {
      if(shift < Bars - (RSIperiod + RSIslow)) {
        RSImacd[shift] = iMAOnArray(RSI,0,RSIfast,0,MODE_EMA,shift)-iMAOnArray(RSI,0,RSIslow,0,MODE_EMA,shift);
      } else {
        RSImacd[shift] = 0;
      }
    }
//----
    for(shift = limit; shift >= 0; shift--) {
      val1 = EMPTY_VALUE; val2 = EMPTY_VALUE;
      if(UseRSI) {
        bRSIbuy  = False; bRSIsell = False;
        if(shift < Bars - (RSIperiod+RSIslow+2)) {
          if(UseRSIaccel) {
            prevsign = iMAOnArray(RSImacd,0,RSIsignal,0,MODE_EMA,shift+1);
            signal   = iMAOnArray(RSImacd,0,RSIsignal,0,MODE_EMA,shift);
            bRSIbuy  = (RSImacd[shift] - signal) > (RSImacd[shift+1] - prevsign);
            bRSIsell = (RSImacd[shift] - signal) < (RSImacd[shift+1] - prevsign);
          }
          if(UseRSIvalue) {
            buy  = RSI[shift] > RSIbuyThreshold;
            sell = RSI[shift] < RSIsellThreshold;
            if(UseRSIaccel) {
              bRSIbuy  = bRSIbuy  && buy;
              bRSIsell = bRSIsell && sell;
            } else {
              bRSIbuy  = buy;
              bRSIsell = sell;
            }
          }
          if(UseRSIdir) {
            buy  = (RSImacd[shift] > RSImacd[shift+1]);
            sell = (RSImacd[shift] < RSImacd[shift+1]);
            if(UseRSIaccel || UseRSIvalue) {
              bRSIbuy  = bRSIbuy  && buy;
              bRSIsell = bRSIsell && sell;
            } else {
              bRSIbuy  = buy;
              bRSIsell = sell;
            }
          }
          if(UseRSIhist) {
            buy  = RSImacd[shift] > RSImacd[shift+2];
            sell = RSImacd[shift] < RSImacd[shift+2];
            if(UseRSIaccel || UseRSIvalue || UseRSIdir) {
              bRSIbuy  = bRSIbuy  && buy;
              bRSIsell = bRSIsell && sell;
            } else {
              bRSIbuy  = buy;
              bRSIsell = sell;
            }
          }
          if(UseRSIisect) {
            if(!UseRSIaccel) {
              signal = iMAOnArray(RSImacd,0,RSIsignal,0,MODE_EMA,shift);
            }
            buy  = RSImacd[shift] > signal;
            sell = RSImacd[shift] < signal;
            if(UseRSIaccel || UseRSIvalue || UseRSIdir || UseRSIhist) {
              bRSIbuy  = bRSIbuy  && buy;
              bRSIsell = bRSIsell && sell;
            } else {
              bRSIbuy  = buy;
              bRSIsell = sell;
            }
          }
          if(UseRSIsign) {
            bRSIbuy  = bRSIbuy  && (RSImacd[shift] >= 0);
            bRSIsell = bRSIsell && (RSImacd[shift] <= 0);
            if(UseRSIaccel || UseRSIvalue || UseRSIdir || UseRSIhist || UseRSIisect) {
              bRSIbuy  = bRSIbuy  && buy;
              bRSIsell = bRSIsell && sell;
            } else {
              bRSIbuy  = buy;
              bRSIsell = sell;
            }
          }
        }
      }
      if(UseMACD) {
        bMACDbuy  = False; bMACDsell = False;
        if(shift <= Bars - (SlowMA+2)) {
          if(UseMACDaccel) {
            prevsign  = iMAOnArray(MACD,0,SignalMA,0,MODE_EMA,shift+1);
            signal    = iMAOnArray(MACD,0,SignalMA,0,MODE_EMA,shift);
            bMACDbuy  = (MACD[shift] - signal) > (MACD[shift+1] - prevsign);
            bMACDsell = (MACD[shift] - signal) < (MACD[shift+1] - prevsign);
          }
          if(UseMACDvalue) {
            atr = iATR(NULL, 0, 21, shift);
            buy  = MACD[shift] > -atr;
            sell = MACD[shift] <  atr;
            if(UseMACDaccel) {
              bMACDbuy  = bMACDbuy  && buy;
              bMACDsell = bMACDsell && sell;
            } else {
              bMACDbuy  = buy;
              bMACDsell = sell;
            }
          }
          if(UseMACDdir) {
            buy  = (MACD[shift] > MACD[shift+1]);
            sell = (MACD[shift] < MACD[shift+1]);
            if(UseMACDaccel || UseMACDvalue) {
              bMACDbuy  = bMACDbuy  && buy;
              bMACDsell = bMACDsell && sell;
            } else {
              bMACDbuy  = buy;
              bMACDsell = sell;
            }
          }
          if(UseMACDhist) {
            buy  = MACD[shift] > MACD[shift+2];
            sell = MACD[shift] < MACD[shift+2];
            if(UseMACDaccel || UseMACDvalue || UseMACDdir) {
              bMACDbuy  = bMACDbuy  && buy;
              bMACDsell = bMACDsell && sell;
            } else {
              bMACDbuy  = buy;
              bMACDsell = sell;
            }
          }
          if(UseMACDisect) {
            if(!UseMACDaccel) {
              signal = iMAOnArray(MACD,0,SignalMA,0,MODE_EMA,shift);
            }
            buy  = MACD[shift] > signal;
            sell = MACD[shift] < signal;
            if(UseMACDaccel || UseMACDvalue || UseMACDdir || UseMACDhist) {
              bMACDbuy  = bMACDbuy  && buy;
              bMACDsell = bMACDsell && sell;
            } else {
              bMACDbuy  = buy;
              bMACDsell = sell;
            }
          }
          if(UseMACDsign) {
            buy  = MACD[shift] >= 0;
            sell = MACD[shift] <= 0;
            if(UseMACDaccel || UseMACDvalue || UseMACDdir || UseMACDhist || UseMACDsign) {
              bMACDbuy  = bMACDbuy  && buy;
              bMACDsell = bMACDsell && sell;
            } else {
              bMACDbuy  = buy;
              bMACDsell = sell;
            }
          }
        }
      }
//----
      if((!UseRSI || (UseRSI && bRSIbuy)) && (!UseMACD || (UseMACD && bMACDbuy))) {
        if(ShowBody) {
          if(Open[shift] < Close[shift]) {
            val1 = Open[shift];
            val2 = Close[shift];
          } else {
            val2 = Open[shift];
            val1 = Close[shift];
          }
        }
        TrlLong = True;
      } else {
        TrlLong = False;
      }
      if((!UseRSI || (UseRSI && bRSIsell)) && (!UseMACD || (UseMACD && bMACDsell))) {
        if(ShowBody) {
          if(Open[shift] > Close[shift]) {
            val1 = Open[shift];
            val2 = Close[shift];
          } else {
            val2 = Open[shift];
            val1 = Close[shift];
          }
        }
        TrlShort = True;
      } else {
        TrlShort = False;
      }
      ExtMap1[shift] = val1;
      ExtMap2[shift] = val2;
//----
      if(shift < Bars - nDrawBegin) {
        TrlPrevLong  = (TrlStopUp[shift+1] != EMPTY_VALUE) &&
          ((TrlStopUp[shift+1] < Low[shift+1]) || (TrlStopUp[shift+1] == TrlBegin[shift+1]));
        TrlPrevShort = (TrlStopDn[shift+1] != EMPTY_VALUE) &&
          ((TrlStopDn[shift+1] > High[shift+1] + Spread * Point) || (TrlStopDn[shift+1] == TrlBegin[shift+1]));
        if(TrlLong || TrlPrevLong) {
          StopLoss = CalcTrailStop(shift, true, !TrlPrevLong);
          if(TrlPrevLong && StopLoss < TrlStopUp[shift+1]) {
            TrlStopUp[shift] = TrlStopUp[shift+1];
          } else {
            TrlStopUp[shift] = StopLoss;
            if(!TrlPrevLong) {
              TrlBegin[shift] = StopLoss;
            }
          }
        } else {
          TrlStopUp[shift] = EMPTY_VALUE;
        }
        if(TrlShort || TrlPrevShort) {
          StopLoss = CalcTrailStop(shift, false, !TrlPrevShort);
          if(TrlPrevShort && StopLoss > TrlStopDn[shift+1]) {
            TrlStopDn[shift] = TrlStopDn[shift+1];
          } else {
            TrlStopDn[shift] = StopLoss;
            if(!TrlPrevShort) {
              TrlBegin[shift] = StopLoss;
            }
          }
        } else {
          TrlStopDn[shift] = EMPTY_VALUE;
        }
        if((TrlBegin[shift] != EMPTY_VALUE)&&(TrlBegin[shift] != TrlStopUp[shift])&&(TrlBegin[shift] != TrlStopDn[shift])) {
          TrlBegin[shift] = EMPTY_VALUE;
        }
      }
    }
//----
    return(0);
  }
//----
double ATLprice(int i)
  {
    return((High[i] + Low[i]) / 2.0);
  }
//----
double CalcFATLonMedian(int i)
  {
    double res =
      0.4360409450*ATLprice(i+0) +0.3658689069*ATLprice(i+1) +0.2460452079*ATLprice(i+2) +0.1104506886*ATLprice(i+3)
     -0.0054034585*ATLprice(i+4) -0.0760367731*ATLprice(i+5) -0.0933058722*ATLprice(i+6) -0.0670110374*ATLprice(i+7) -0.0190795053*ATLprice(i+8)
     +0.0259609206*ATLprice(i+9) +0.0502044896*ATLprice(i+10)+0.0477818607*ATLprice(i+11)+0.0249252327*ATLprice(i+12)
     -0.0047706151*ATLprice(i+13)-0.0272432537*ATLprice(i+14)-0.0338917071*ATLprice(i+15)-0.0244141482*ATLprice(i+16)-0.0055774838*ATLprice(i+17)
     +0.0128149838*ATLprice(i+18)+0.0226522218*ATLprice(i+19)+0.0208778257*ATLprice(i+20)+0.0100299086*ATLprice(i+21)
     -0.0036771622*ATLprice(i+22)-0.0136744850*ATLprice(i+23)-0.0160483392*ATLprice(i+24)-0.0108597376*ATLprice(i+25)-0.0016060704*ATLprice(i+26)
     +0.0069480557*ATLprice(i+27)+0.0110573605*ATLprice(i+28)+0.0095711419*ATLprice(i+29)+0.0040444064*ATLprice(i+30)
     -0.0023824623*ATLprice(i+31)-0.0067093714*ATLprice(i+32)-0.0072003400*ATLprice(i+33)-0.0047717710*ATLprice(i+34)
     +0.0005541115*ATLprice(i+35)+0.0007860160*ATLprice(i+36)+0.0130129076*ATLprice(i+37)+0.0040364019*ATLprice(i+38);
    return(res);
  }
//----
double CalcSATLonMedian(int i)
  {
    double res = 0.0982862174*ATLprice(i+0)
      +0.0975682269*ATLprice(i+1) +0.0961401078*ATLprice(i+2) +0.0940230544*ATLprice(i+3) +0.0912437090*ATLprice(i+4) +0.0878391006*ATLprice(i+5)
      +0.0838544303*ATLprice(i+6) +0.0793406350*ATLprice(i+7) +0.0743569346*ATLprice(i+8) +0.0689666682*ATLprice(i+9) +0.0632381578*ATLprice(i+10)
      +0.0572428925*ATLprice(i+11)+0.0510534242*ATLprice(i+12)+0.0447468229*ATLprice(i+13)+0.0383959950*ATLprice(i+14)+0.0320735368*ATLprice(i+15)
      +0.0258537721*ATLprice(i+16)+0.0198005183*ATLprice(i+17)+0.0139807863*ATLprice(i+18)+0.0084512448*ATLprice(i+19)+0.0032639979*ATLprice(i+20)
      -0.0015350359*ATLprice(i+21)-0.0059060082*ATLprice(i+22)-0.0098190256*ATLprice(i+23)-0.0132507215*ATLprice(i+24)-0.0161875265*ATLprice(i+25)
      -0.0186164872*ATLprice(i+26)-0.0205446727*ATLprice(i+27)-0.0219739146*ATLprice(i+28)-0.0229204861*ATLprice(i+29)-0.0234080863*ATLprice(i+30)
      -0.0234566315*ATLprice(i+31)-0.0231017777*ATLprice(i+32)-0.0223796900*ATLprice(i+33)-0.0213300463*ATLprice(i+34)-0.0199924534*ATLprice(i+35)
      -0.0184126992*ATLprice(i+36)-0.0166377699*ATLprice(i+37)-0.0147139428*ATLprice(i+38)-0.0126796776*ATLprice(i+39)-0.0105938331*ATLprice(i+40)
      -0.0084736770*ATLprice(i+41)-0.0063841850*ATLprice(i+42)-0.0043466731*ATLprice(i+43)-0.0023956944*ATLprice(i+44)-0.0005535180*ATLprice(i+45)
      +0.0011421469*ATLprice(i+46)+0.0026845693*ATLprice(i+47)+0.0040471369*ATLprice(i+48)+0.0052380201*ATLprice(i+49)+0.0062194591*ATLprice(i+50)
      +0.0070340085*ATLprice(i+51)+0.0076266453*ATLprice(i+52)+0.0080376628*ATLprice(i+53)+0.0083037666*ATLprice(i+54)+0.0083694798*ATLprice(i+55)
      +0.0082901022*ATLprice(i+56)+0.0080741359*ATLprice(i+57)+0.0077543820*ATLprice(i+58)+0.0073260526*ATLprice(i+59)+0.0068163569*ATLprice(i+60)
      +0.0062325477*ATLprice(i+61)+0.0056078229*ATLprice(i+62)+0.0049516078*ATLprice(i+63)+0.0161380976*ATLprice(i+64); 
    return(res);
  }
//+------------------------------------------------------------------+