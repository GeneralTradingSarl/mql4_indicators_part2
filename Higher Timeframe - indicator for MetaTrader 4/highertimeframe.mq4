//+------------------------------------------------------------------+
//|                                                  HigherTimeframe |
//|                                       Copyright 2016, Il Anokhin |
//|                           http://www.mql5.com/en/users/ilanokhin |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Il Anokhin"
#property link "http://www.mql5.com/en/users/ilanokhin"
#property description ""
#property strict
//-------------------------------------------------------------------------
// Indicator settings
//-------------------------------------------------------------------------
#property  indicator_chart_window
#property  indicator_buffers 4
#property  indicator_color1 Red
#property  indicator_color2 LimeGreen
#property  indicator_color3 Red
#property  indicator_color4 LimeGreen
#property  indicator_width1 2
#property  indicator_width2 2
#property  indicator_style3 2
#property  indicator_style4 2
//-------------------------------------------------------------------------
// Inputs
//-------------------------------------------------------------------------
input ENUM_TIMEFRAMES TF=PERIOD_D1;     //Higher Timeframe
//-------------------------------------------------------------------------
// Variables
//-------------------------------------------------------------------------
double o[],c[],lh[],hl[];

int k;
//-------------------------------------------------------------------------
// 1. Initialization
//-------------------------------------------------------------------------
int OnInit(void)
  {

   IndicatorBuffers(4);

   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);

   SetIndexBuffer(0,o);
   SetIndexBuffer(1,c);
   SetIndexBuffer(2,lh);
   SetIndexBuffer(3,hl);

   Comment("Copyright © 2016, Il Anokhin");

   return(INIT_SUCCEEDED);

  }
//-------------------------------------------------------------------------
// 2. Deinitialization
//-------------------------------------------------------------------------
int deinit() {return(0);}
//-------------------------------------------------------------------------
// 3. Main function
//-------------------------------------------------------------------------
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

   int i,lim,cb;

   if(Bars<10) return(0);

   cb=IndicatorCounted();

   lim=Bars-cb;

   if(cb==0) lim=lim-11;

   if(cb>0) lim++;

//--- 3.1. Main loop ------------------------------------------------------

   k=0;

   for(i=0;i<lim;i++)
     {

      o[i]=iOpen(NULL,TF,k);

      c[i]=iClose(NULL,TF,k);

      if(c[i]>o[i]) {hl[i]=iHigh(NULL,TF,k); lh[i]=iLow(NULL,TF,k);}

      if(c[i]<=o[i]) {lh[i]=iHigh(NULL,TF,k); hl[i]=iLow(NULL,TF,k);}

      if(iTime(NULL,0,i)==iTime(NULL,TF,k)) k++;

     }

//--- 3.2. End of main function -------------------------------------------

   return(rates_total);

  }

//-------------------------------------------------------------------------
