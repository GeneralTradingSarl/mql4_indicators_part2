//+----------------------------------------------------------------+
//|                                      Momentum_Offset_Histo.mq4 |
//+----------------------------------------------------------------+
#property description "Code by Max Michael 2022"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  clrRed
#property indicator_width1  2
#property indicator_color2  clrGreen
#property indicator_width2  2
#property indicator_color5  clrDodgerBlue
#property indicator_width5  1
#property strict

extern int             MomentumPeriod = 20;
static input string   Input_smoothing = "1=unsmoothed";
extern int                  Smoothing = 2;
input ENUM_MA_METHOD       SmoothMode = MODE_SMA;   
input ENUM_APPLIED_PRICE        Price = PRICE_CLOSE;
static input string    Input_HistoAvg = "0=off";
input  int               HistoAverage = 4;
input  int                    MaxBars = 500; 

double    MA1[],MA2[],B1[],B2[],B3[];

int OnInit()
{
   if(MomentumPeriod<=0) MomentumPeriod=20;
   if(Smoothing<=0)      Smoothing=1;
   SetIndexBuffer(0,MA1); SetIndexStyle(0,DRAW_HISTOGRAM); SetIndexLabel(0,"Momentum Down");
   SetIndexBuffer(1,MA2); SetIndexStyle(1,DRAW_HISTOGRAM); SetIndexLabel(1,"Momentum Up"); 
   SetIndexBuffer(2,B1);  SetIndexStyle(2,DRAW_NONE); SetIndexEmptyValue(2,0.0); SetIndexLabel(2,"");
   SetIndexBuffer(3,B2);  SetIndexStyle(3,DRAW_NONE); SetIndexEmptyValue(3,0.0); SetIndexLabel(3,"");
   SetIndexBuffer(4,B3);  SetIndexStyle(4,DRAW_LINE);
	IndicatorShortName("Momentum Offset"+"("+(string)MomentumPeriod+","+(string)Smoothing+")");
   IndicatorDigits(4);
   return(INIT_SUCCEEDED);
}

int start() 
{
   int counted = IndicatorCounted();
   if (counted < 0) return(-1);
   int limit = Bars-counted-1;
   if (limit > MaxBars) limit=MathMin(MaxBars,Bars-1);
   
   // Momentum offset
   for (int i=limit; i>=0; i--)
   {
      double price1 = iMA(NULL,0,1,0, MODE_SMA,Price,i);
      double price2 = iMA(NULL,0,1,0, MODE_SMA,Price,i+MomentumPeriod);
      B1[i] = price1*100/price2-100.0;
   }
   // Smoothing
   for (int i=limit; i>=0; i--)
   {
      B2[i]=iMAOnArray(B1,0,Smoothing,0,SmoothMode,i);
      if(HistoAverage>0) 
        B3[i]=iMAOnArray(B2,0,HistoAverage,0,MODE_SMA,i);
   }
   // Histogram
   for (int i=limit; i>=0; i--)
   {
        if(B2[i]<0) MA1[i]=B2[i];
        else        MA2[i]=B2[i];
   }
   return(0);
}
