//+------------------------------------------------------------------+
//| Kijun_Sen Candles Two Colors: Copylight © 2013, File45 (Phylo)       
//| http://codebase.mql4.com/en/author/file45 
//| 
//| Thanks to Mladen for code enhancements: http://www.forex-tsd.com/metatrader-4/20171-please-fix-indicator-ea-82.html  
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "2.00"

#property indicator_chart_window

#property indicator_buffers 4
#property indicator_color1 RoyalBlue//wicks
#property indicator_color2 Red//wicks
#property indicator_color3 RoyalBlue // Candle Bodies
#property indicator_color4 Red // Candle Bodies

extern int Candle_Kijun_Sen = 34;
extern int Candle_Shadow_Width = 1, Candle_Body_Width = 3;

int MA1 = 1;
int MA1_SHIFT = 0;
int MA1_MODE = 0;
int MA1_PRICE = 0;

// ======================== indicator buffers
double Bar1[], Bar2[], Candle1[], Candle2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
   ChartSetInteger(0,CHART_MODE,CHART_LINE);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrNONE);
   
   IndicatorShortName("MA Candles");
   IndicatorBuffers(4);

   SetIndexBuffer(0,Bar1);
   SetIndexBuffer(1,Bar2);
   SetIndexBuffer(2,Candle1);
   SetIndexBuffer(3,Candle2);	

   SetIndexStyle(0,DRAW_HISTOGRAM,0,Candle_Shadow_Width);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,Candle_Shadow_Width);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,Candle_Body_Width);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,Candle_Body_Width);

   SetIndexLabel(0, "R up L, R dn L, B up H, B dn H");
   SetIndexLabel(1, "R up H, R dn H, B up L, B dn L");
   SetIndexLabel(2, "R up O, R dn C, B up C, B dn O");
   SetIndexLabel(3, "R up C, R dn O, B up O, B dn C");
  
   return(0);
}
   double MA_1 (int i = 0){return(iMA(NULL,0,MA1,MA1_SHIFT,MA1_MODE, MA1_PRICE,i));}
   double MA_2 (int i = 0){return(iIchimoku(NULL,0,Candle_Kijun_Sen,Candle_Kijun_Sen,Candle_Kijun_Sen,MODE_KIJUNSEN,i));}

void SetCandleColor(int col, int i)
{
   double high,low,bodyHigh,bodyLow;

   bodyHigh = MathMax(Open[i],Close[i]);
   bodyLow = MathMin(Open[i],Close[i]);
   high	 = High[i];
   low	 = Low[i];

   Bar1[i] = EMPTY_VALUE;	
   Bar2[i] = EMPTY_VALUE;
   Candle1[i] = EMPTY_VALUE;
   Candle2[i] = EMPTY_VALUE;
   
   switch(col)
   {
   case 1: Bar1[i] = high;	Bar2[i] = low; Candle1[i] = bodyHigh;	Candle2[i] = bodyLow; break;
   case 2: Bar2[i] = high;	Bar1[i] = low; Candle2[i] = bodyHigh;	Candle1[i] = bodyLow; break;
   }
}

int start()
{
   for(int i = MathMax(Bars-1-IndicatorCounted(),1); i>=0; i--)
   {
      double	Ma1	= MA_1(i);
      double	Ma2	= MA_2(i);

      if(Ma1 > Ma2)	
      {
         SetCandleColor(1,i);
      }   
      else	
      {
         if(Ma1 < Ma2) SetCandleColor(2,i);
      }
   }

   return(0);
}

int deinit()
{
   return(0);
}