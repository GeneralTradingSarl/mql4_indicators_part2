//+------------------------------------------------------------------+
//|                                                Gap_Finder_01.mq4 |
//|                                  Copyright 2015, Khalil Abokwaik |
//|                            https://www.forexfactory.com/abokwaik |
//|                            https://www.mql5.com/en/users/abokwaik|
//+------------------------------------------------------------------+
//| This indicator plots Bullish Gaps and Bearish gaps.              |
//| It also plots or hides closed gaps.                              |
//| Trader can select the minimum gap size in points. Gaps less than |
//| minumum size are ignored.                                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Khalil Abokwaik"
#property link      "https://www.forexfactory.com.abokwaik"
#property description "Gap Finder Indicator"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot Bullish Gaps
#property indicator_label1  "GAP UP"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Bearish Gaps
#property indicator_label2  "GAP DOWN"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Closed Bullish Gaps
#property indicator_label3  "UP Closed"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Closed Bearish Gaps
#property indicator_label4  "DOWN Closed"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input int      min_gap_size=1;//Min gap size in points
input bool     check_closed_gaps=true;//Check for closed gaps
input int      history_bars=1000;//Max history bars for closed gaps
input bool     hide_closed_gaps=true;//Hide closed gaps
input bool     show_alert=true;//Show Alerts
//--- indicator buffers
double         up_openBuffer[];
double         dn_openBuffer[];
double         up_closedBuffer[];
double         dn_closedBuffer[];
datetime       bar_time=0;//to control signals on current bar
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- input validations
   if(min_gap_size<1)
     {
      Alert("Invalid Gap Size, must be > 0");
      return(INIT_PARAMETERS_INCORRECT);
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,up_openBuffer);
   SetIndexBuffer(1,dn_openBuffer);
   SetIndexBuffer(2,up_closedBuffer);
   SetIndexBuffer(3,dn_closedBuffer);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   SetIndexArrow(0,236);
   SetIndexArrow(1,238);
   SetIndexArrow(2,120);
   SetIndexArrow(3,120);

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
   int limit=rates_total-prev_calculated;
//-- check for new gaps --------------------------------------------------------
   limit=MathMax(limit,2);
   for(int i=limit-2; i>=0; i--)
     {
      if(i==0)
        {
         if(Time[0]==bar_time) continue;
         else bar_time=Time[0];
        }
      if(up_openBuffer[i]!=EMPTY_VALUE || dn_openBuffer[i]!=EMPTY_VALUE) continue;
      if(Open[i]>Close[i+1]+min_gap_size*Point) //bullish gap
        {
         up_openBuffer[i]=Open[i];
         if(show_alert && i==0) Alert("Bullish Gap "+DoubleToStr(MathAbs((Open[i]-Close[i+1])/Point),0)+" on "+Symbol()+","+periodName(_Period)+" @ "+DoubleToStr(Open[i],Digits));
        }
      if(Open[i]<Close[i+1]-min_gap_size*Point) //bearish gap
        {
         dn_openBuffer[i]=Open[i];
         if(show_alert && i==0) Alert("Bearish Gap "+DoubleToStr(MathAbs((Open[i]-Close[i+1])/Point),0)+" on "+Symbol()+","+periodName(_Period)+" @ "+DoubleToStr(Open[i],Digits));
        }
     }
//-- check for closed gaps ----------------------------------------
   if(check_closed_gaps)
     {
      for(int i=history_bars-1; i>=0; i--)
        {
         if(up_closedBuffer[i]!=EMPTY_VALUE || dn_closedBuffer[i]!=EMPTY_VALUE) continue;
         if(up_openBuffer[i]==EMPTY_VALUE && dn_openBuffer[i]==EMPTY_VALUE) continue;
         if(up_openBuffer[i]!=EMPTY_VALUE)
           {
            if((i>0 && Low[iLowest(Symbol(),0,MODE_LOW,i+1,0)]<=Close[i+1]) || (i==0 && Low[0]<=Close[1]))//bullish gap closed
              {
               if(hide_closed_gaps) up_openBuffer[i]=EMPTY_VALUE;
               else
                 {
                  up_openBuffer[i]=EMPTY_VALUE;
                  up_closedBuffer[i]=Open[i];
                 }
               if(show_alert && i==0) Alert("Bullish Gap Closed "+" on "+Symbol()+","+periodName(_Period)+" @ "+DoubleToStr(Close[i],Digits));
              }

           }
         if(dn_openBuffer[i]!=EMPTY_VALUE)
           {
            if((i>0 && High[iHighest(Symbol(),0,MODE_HIGH,i+1,0)]>=Close[i+1]) || (i==0 && High[0]>=Close[1]))//bearish gap closed
              {
               if(hide_closed_gaps) dn_openBuffer[i]=EMPTY_VALUE;
               else
                 {
                  dn_openBuffer[i]=EMPTY_VALUE;
                  dn_closedBuffer[i]=Open[i];
                 }
               if(show_alert && i==0) Alert("Bearish Gap Closed "+" on "+Symbol()+","+periodName(_Period)+" @ "+DoubleToStr(Close[i],Digits));
              }

           }

        }
     }
   return(rates_total);
  }
//+---------------------------------------------------------------------------+
//| a function to return period name as a string to be used in alert messages |
//+---------------------------------------------------------------------------+

string periodName(int period)
  {
   switch(period)
     {
      case 1: return("M1");
      case 5: return("M5");
      case 15: return("M15");
      case 30: return("M30");
      case 60: return("H1");
      case 240: return("H4");
      case 1440: return("D1");
      case 10080: return("W1");
      case 43200: return("MN1");
      default: return("");
     }
  }
//+------------------------------------------------------------------+
