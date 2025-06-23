//+------------------------------------------------------------------+
//|                                                       pivots.mq4 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//|                                          Author: Yashar Seyyedin |
//|       Web Address: https://www.mql5.com/en/users/yashar.seyyedin |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot ph
#property indicator_label1  "ph"
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot pl
#property indicator_label2  "pl"
#property indicator_type2   DRAW_SECTION
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input int _right=10;
input int _left=10;
//--- indicator buffers
double         phBuffer[];
double         plBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,phBuffer);
   SetIndexBuffer(1,plBuffer);
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
   int BARS=MathMax(Bars-(_right+_left)-IndicatorCounted(),1);
   pivothigh(high, phBuffer, _left, _right, 0, BARS);
   pivotlow(low, plBuffer, _left, _right, 0, BARS);
   return(rates_total);
  }
//+------------------------------------------------------------------+


void pivothigh(const double &high[], double &output[], int left, int right, int start_pos, int count)
{
   for(int index=start_pos;index<start_pos+count;index++)
   {
      bool next_index=false;
      int i=index+right;
      for(int j=i+1;j<i+1+left;j++)
      {
         if(j>Bars-1) break;
         if(high[j]>high[i])
         {
            output[index] = EMPTY_VALUE;
            next_index=true;
            break;
         }
      }
      if(next_index==true) continue;
      for(int j=i-1;j>i-1-right;j--)
      {
         if(j<0) break;
         if(high[j]>high[i])
         {
            output[index] = EMPTY_VALUE;
            next_index=true;
            break;
         }
      }
      if(next_index==true) continue;
      output[index] = high[i];
   }
}

void pivotlow(const double &low[], double &output[] , int left, int right, int start_pos, int count)
{
   for(int index=start_pos;index<start_pos+count;index++)
   {
      bool next_index=false;
      int i=index+right;
      for(int j=i+1;j<i+1+left;j++)
      {
         if(j>Bars-1) break;
         if(low[j]<low[i])
         {
            output[index] = EMPTY_VALUE;
            next_index=true;
            break;
         }
      }
      if(next_index==true) continue;
      for(int j=i-1;j>i-1-right;j--)
      {
         if(j<0) break;
         if(low[j]<low[i])
         {
            output[index] = EMPTY_VALUE;
            next_index=true;
            break;
         }
      }
      if(next_index==true) continue;
      output[index] = low[i];
   }
}