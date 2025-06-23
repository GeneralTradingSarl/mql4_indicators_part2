//+------------------------------------------------------------------+
//|                                 Inverse-Fisher-Transform-RSI.mq4 |
//+------------------------------------------------------------------+
#property description "Developed by John Ehlers, the RSI-based inverse Fisher " 
#property description "Transform is used to help clearly define trigger points."
#property description "The normal RSI indicator is calculated and adjusted so"
#property description "that the values are centered around zero."
#property description "The inverse transform is then applied to these values."
#property description "Metatrader Code by Max Michael 2022"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  DodgerBlue
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_levelcolor DimGray
#property indicator_levelwidth 1
#property indicator_levelstyle 0
#property indicator_level1  80
#property indicator_level2  20
#property strict

extern int             RsiPeriod = 20;
extern ENUM_APPLIED_PRICE  price = PRICE_CLOSE;
extern int          NumberOfBars = 1000;

double         fRSIbuffer[];

int init()
{  
   SetIndexBuffer(0,fRSIbuffer); SetIndexStyle(0,DRAW_LINE); SetIndexLabel(0,"Inverse-Fisher-RSI");
   IndicatorShortName("Inverse-Fisher-RSI("+ IntegerToString(RsiPeriod) +")");
   IndicatorDigits(2);
   return(0);
}

int start()
{   
   int CountedBars=IndicatorCounted();
   if (CountedBars<0) return(-1);
   int i=Bars-CountedBars-1;
   if (i>NumberOfBars) i=MathMin(NumberOfBars,Bars-1);
   
   while(i>=0)
   {
      double rsi=iRSI(_Symbol,0,RsiPeriod,price,i);
      double x=0.1*(rsi-50);
      double y=(MathExp(2*x)-1)/(MathExp(2*x)+1);
      double ynormal=50*(y+1);
      fRSIbuffer[i]=ynormal;
      i--;     
   }
   return(0);
}
