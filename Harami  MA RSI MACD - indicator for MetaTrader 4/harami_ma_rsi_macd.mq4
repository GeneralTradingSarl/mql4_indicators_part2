//+------------------------------------------------------------------+
//|                                           Harami MA RSI MACD.ex4 |
//|                      Copyright © 2016, Forex-Index-Intraday, Ger |
//|                             http://www.forex-index-intraday.com/ |
//+------------------------------------------------------------------+
#property strict
#property copyright "Copyright © 2016, Forex-Index-Intraday, Ger"
#property link      "http://www.forex-index-intraday.com/"
#property version   "16.04"
#property description "simple Harami -MA -RSI -MACD indicator;"
#property description "signal after close;"
#property description "alert;"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_width1 1
#property indicator_color2 Red
#property indicator_width2 1

extern int barsToProcess=5000; //Bars to process
extern string line0______________________________________="---------------------------------------------------------------"; //----------------------------------------------------------------
extern bool Alert_On=false; //Alert On
extern string line1______________________________________="---------------------------------------------------------------"; //----------------------------------------------------------------
extern bool MA_filter=false; //MA filter
extern bool RSI_filter=false; //RSI filter
extern bool MACD_filter=false; // MACD filter
extern bool One_Candle_before=false; //One Candle before
extern string line2______________________________________="---------------------------------------------------------------"; //----------------------------------------------------------------
extern int Trend_MA=12; //Trend MA
input int MA_shift=0; //MA Shift
input ENUM_MA_METHOD MA_Mode=MODE_EMA; //MA Mode
input ENUM_APPLIED_PRICE MA_price=PRICE_HIGH; //MA Price
extern string line3______________________________________="---------------------------------------------------------------"; //----------------------------------------------------------------
extern int RSI_Period=5; //RSI Period
extern int RSI_upper_level=70; //RSI upper level
extern int RSI_lower_level=30; //RSI lower level
extern string line4______________________________________="---------------------------------------------------------------"; //----------------------------------------------------------------
extern int MACD_fast_EMA=12; //MACD fast EMA
extern int MACD_slow_EMA=26; //MACD slow EMA
extern int MACD_SMA=9; //MACD SMA
extern string End_____________________________="________________________________";

double One_Candle_before_a;
double One_Candle_before_b;
double One_Candle_before_c;
double One_Candle_before_d;

double MA_filter_a;
double MA_filter_b;
double MA_filter_c;
double MA_filter_d;

double RSI_filter_a;
double RSI_filter_b;
double RSI_filter_c;
double RSI_filter_d;

double MACD_filter_a;
double MACD_filter_b;
double MACD_filter_c;
double MACD_filter_d;

double movesUp[];
double movesDown[];
string TimeFrameStr;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrameStr()
  {
   switch(Period())
     {
      case 1 : TimeFrameStr="M1"; break;
      case 5 : TimeFrameStr="M5"; break;
      case 15 : TimeFrameStr="M15"; break;
      case 30 : TimeFrameStr="M30"; break;
      case 60 : TimeFrameStr="H1"; break;
      case 240 : TimeFrameStr="H4"; break;
      case 1440 : TimeFrameStr="D1"; break;
      case 10080 : TimeFrameStr="W1"; break;
      case 43200 : TimeFrameStr="MN"; break;
      default : TimeFrameStr=(string)Period();
     }
   return (TimeFrameStr);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int OnInit()
  {
     {
      SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,233);
      SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,234);
     }
   SetIndexBuffer(0,movesUp);
   SetIndexBuffer(1,movesDown);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar()
  {
   static datetime lastbar;
   datetime curbar=Time[0];
   if(lastbar!=curbar)
     {
      lastbar=curbar;
      return (true);
     }
   else
     {
      return(false);
     }
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
   int limit,i;
   double Range;
   int counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);

   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(limit>barsToProcess) limit=barsToProcess;
   for(i=0; i<=limit; i++)
     {
      Range=(iATR(NULL,NULL,40,i+1));

      if(MA_filter==true)
        {
         MA_filter_a=(((iClose(NULL,0,i+1))>=(iMA(NULL,0,Trend_MA,MA_shift,MA_Mode,MA_price,i+1)))
                     || ((iOpen(NULL,0,i+1))>=(iMA(NULL,0,Trend_MA,MA_shift,MA_Mode,MA_price,i+1))));
         MA_filter_b=(((iClose(NULL,0,1))>=(iMA(NULL,0,Trend_MA,MA_shift,MA_Mode,MA_price,1)))
                     || ((iOpen(NULL,0,1))>=(iMA(NULL,0,Trend_MA,MA_shift,MA_Mode,MA_price,1))));
         MA_filter_c=(((iClose(NULL,0,i+1))<=(iMA(NULL,0,Trend_MA,MA_shift,MA_Mode,MA_price,i+1)))
                     || ((iOpen(NULL,0,i+1))<=(iMA(NULL,0,Trend_MA,MA_shift,MA_Mode,MA_price,i+1))));
         MA_filter_d=(((iClose(NULL,0,1))<=(iMA(NULL,0,Trend_MA,MA_shift,MA_Mode,MA_price,1)))
                     || ((iOpen(NULL,0,1))<=(iMA(NULL,0,Trend_MA,MA_shift,MA_Mode,MA_price,1))));
        }

      if(MA_filter==false)
        {
         MA_filter_a=((iLow(NULL, 0, i+1)) > (iLow(NULL, 0, i+2)));
         MA_filter_b=((iLow(NULL, 0, 1)) > (iLow(NULL, 0, 2)));
         MA_filter_c=((iLow(NULL, 0, i+1)) > (iLow(NULL, 0, i+2)));
         MA_filter_d=((iLow(NULL, 0, 1)) > (iLow(NULL, 0, 2)));
        }

      if(RSI_filter==true)
        {
         RSI_filter_a=((iRSI(NULL, 0, RSI_Period, 0, i+1)) < RSI_lower_level);
         RSI_filter_b=((iRSI(NULL, 0, RSI_Period, 0, 1)) < RSI_lower_level);
         RSI_filter_c=((iRSI(NULL, 0, RSI_Period, 0, i+1)) > RSI_upper_level);
         RSI_filter_d=((iRSI(NULL, 0, RSI_Period, 0, 1)) > RSI_upper_level);
        }

      if(RSI_filter==false)
        {
         RSI_filter_a=((iLow(NULL, 0, i+1)) > (iLow(NULL, 0, i+2)));
         RSI_filter_b=((iLow(NULL, 0, 1)) > (iLow(NULL, 0, 2)));
         RSI_filter_c=((iLow(NULL, 0, i+1)) > (iLow(NULL, 0, i+2)));
         RSI_filter_d=((iLow(NULL, 0, 1)) > (iLow(NULL, 0, 2)));
        }

      if(MACD_filter==true)
        {
         MACD_filter_a=((iMACD(NULL,0,MACD_fast_EMA,MACD_slow_EMA,MACD_SMA,0,0,i+1))>
                        (iMACD(NULL,0,MACD_fast_EMA,MACD_slow_EMA,MACD_SMA,0,0,i+2)));
         MACD_filter_b=((iMACD(NULL,0,MACD_fast_EMA,MACD_slow_EMA,MACD_SMA,0,0,1))>
                        (iMACD(NULL,0,MACD_fast_EMA,MACD_slow_EMA,MACD_SMA,0,0,2)));
         MACD_filter_c=((iMACD(NULL,0,MACD_fast_EMA,MACD_slow_EMA,MACD_SMA,0,0,i+1))<
                        (iMACD(NULL,0,MACD_fast_EMA,MACD_slow_EMA,MACD_SMA,0,0,i+2)));
         MACD_filter_d=((iMACD(NULL,0,MACD_fast_EMA,MACD_slow_EMA,MACD_SMA,0,0,1))<
                        (iMACD(NULL,0,MACD_fast_EMA,MACD_slow_EMA,MACD_SMA,0,0,2)));
        }

      if(MACD_filter==false)
        {
         MACD_filter_a=((iLow(NULL, 0, i+1)) > (iLow(NULL, 0, i+2)));
         MACD_filter_b=((iLow(NULL, 0, 1)) > (iLow(NULL, 0, 2)));
         MACD_filter_c=((iLow(NULL, 0, i+1)) > (iLow(NULL, 0, i+2)));
         MACD_filter_d=((iLow(NULL, 0, 1)) > (iLow(NULL, 0, 2)));
        }

      if(One_Candle_before==true)
        {
         One_Candle_before_a=((iClose(NULL, 0, i+3)) < (iOpen(NULL, 0, i+3)));
         One_Candle_before_b=((iClose(NULL, 0, 3)) < (iOpen(NULL, 0, 3)));
         One_Candle_before_c=((iOpen(NULL, 0, i+3)) < (iClose(NULL, 0, i+3)));
         One_Candle_before_d=((iOpen(NULL, 0, 3)) < (iClose(NULL, 0, 3)));
        }

      if(One_Candle_before==false)
        {
         One_Candle_before_a=((iLow(NULL, 0, i+1)) > (iLow(NULL, 0, i+2)));
         One_Candle_before_b=((iLow(NULL, 0, 1)) > (iLow(NULL, 0, 2)));
         One_Candle_before_c=((iLow(NULL, 0, i+1)) > (iLow(NULL, 0, i+2)));
         One_Candle_before_d=((iLow(NULL, 0, 1)) > (iLow(NULL, 0, 2)));
        }

        {
         if(((iLow(NULL,0,i+1))>(iLow(NULL,0,i+2))
            && ((iHigh(NULL,0,i+1))<(iHigh(NULL,0,i+2)))
            && ((iClose(NULL,0,i+2))<(iOpen(NULL,0,i+2)))
            && ((iClose(NULL,0,i+1))>(iOpen(NULL,0,i+1)))
            && MA_filter_a
            && RSI_filter_a
            && MACD_filter_a
            && One_Candle_before_a
            ))
           {
            movesUp[i+1]=Low[i+1]-Range*0.3;
           }
         if(((iLow(NULL,0,1))>(iLow(NULL,0,2))
            && ((iHigh(NULL,0,1))<(iHigh(NULL,0,2)))
            && ((iClose(NULL,0,2))<(iOpen(NULL,0,2)))
            && ((iClose(NULL,0,1))>(iOpen(NULL,0,1)))
            && MA_filter_b
            && RSI_filter_b
            && MACD_filter_b
            && One_Candle_before_b
            ))
           {
            if(NewBar())
              {
               if(Alert_On==true)
                 {
                  Alert(Symbol()+"  "+GetTimeFrameStr()+"  "+"Arrow =>  up, "+" Harami");
                 }
              }
           }

         if(((iLow(NULL,0,i+1))>(iLow(NULL,0,i+2))
            && ((iHigh(NULL,0,i+1))<(iHigh(NULL,0,i+2)))
            && ((iOpen(NULL,0,i+2))<(iClose(NULL,0,i+2)))
            && ((iOpen(NULL,0,i+1))>(iClose(NULL,0,i+1)))
            && MA_filter_c
            && RSI_filter_c
            && MACD_filter_c
            && One_Candle_before_c
            ))
           {
            movesDown[i+1]=High[i+1]+Range*0.3;
           }
         if(((iLow(NULL,0,1))>(iLow(NULL,0,2))
            && ((iHigh(NULL,0,1))<(iHigh(NULL,0,2)))
            && ((iOpen(NULL,0,2))<(iClose(NULL,0,2)))
            && ((iOpen(NULL,0,1))>(iClose(NULL,0,1)))
            && MA_filter_d
            && RSI_filter_d
            && MACD_filter_d
            && One_Candle_before_d
            ))
           {
            if(NewBar())
              {
               if(Alert_On==true)
                 {
                  Alert(Symbol()+"  "+GetTimeFrameStr()+"  "+"Arrow =>  down, "+" Harami");
                 }
              }
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
