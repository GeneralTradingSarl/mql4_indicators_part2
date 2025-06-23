//+------------------------------------------------------------------+
//|                                                                  |
//|                FileName: i_DCG_ModStDev.mq4                      |
//| Author: Copyright © 2005, Fermin Da Costa Gomez                  |
//| Description: This indicator measures                             |
//|                                                                  |
//| Version: 000 20050728 14:52 GMT                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Fermin Da Costa Gomez"
#property link      "http://forex.viahetweb.nl"
//----
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Silver
#property indicator_color2 Red
#property indicator_color3 Lime
#property indicator_color4 SkyBlue
//---- External parameters
extern int _maPeriod=12;
//---- indicator buffers
double _sd[];
double _sdMa[];
double _sdMa2[];
double _sdPower[];
double _sdPowerMa[];
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   int    draw_begin;
   string short_name;
   IndicatorBuffers(5);
//---- indicator buffers mapping
   SetIndexBuffer(0,_sdPower);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,_sdPowerMa);
   SetIndexEmptyValue(1,0.0);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(3,_sd);
   SetIndexEmptyValue(3,0.0);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(4,_sdMa);
   SetIndexEmptyValue(4,0.0);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(2,_sdMa2);
   SetIndexEmptyValue(2,0.0);
   SetIndexStyle(2,DRAW_LINE);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| CalculateIndicators                                                                 |
//+------------------------------------------------------------------+
void calculateIndicators(int i)
  {
   double m10,m11,m20,m21;
   int fastPeriod=_maPeriod*0.382;
   _sd[i]=iStdDev(Symbol(),0,_maPeriod,MODE_LWMA,0,PRICE_CLOSE,i);
   _sdMa[i]=iMAOnArray(_sd,0,_maPeriod,0,MODE_LWMA,i);
   _sdMa2[i]=iMAOnArray(_sd,0,_maPeriod*MathSqrt(_maPeriod),0,MODE_LWMA,i);
   _sdPower[i]=_sdMa[i]-_sdMa2[i];
   _sdPowerMa[i]=iMAOnArray(_sdPower,0,_maPeriod*1.618,0,MODE_LWMA,i);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int i,shift;

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+MathMax(1,_maPeriod);

//---- moving average
   for(i=limit; i>=0; i--)
     {
      //calculateIndicators(i);
      double m10,m11,m20,m21;
      int fastPeriod=_maPeriod*0.382;
      _sd[i]=iStdDev(Symbol(),0,_maPeriod,MODE_LWMA,0,PRICE_CLOSE,i);
      _sdMa[i]=iMAOnArray(_sd,0,_maPeriod,0,MODE_LWMA,i);
      _sdMa2[i]=iMAOnArray(_sd,0,_maPeriod*MathSqrt(_maPeriod),0,MODE_LWMA,i);
      _sdPower[i]=_sdMa[i]-_sdMa2[i];
      _sdPowerMa[i]=iMAOnArray(_sdPower,0,_maPeriod*1.618,0,MODE_LWMA,i);
     }
   return(0);
  }
//+------------------------------------------------------------------+
