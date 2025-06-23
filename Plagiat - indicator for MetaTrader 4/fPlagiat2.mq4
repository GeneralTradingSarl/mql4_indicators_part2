//+----------------------------------------------------------------------------+ 
//| HMA.mq4                                                                    |
//| Copyright © 2006 WizardSerg <wizardserg@mail.ru>, ForexMagazine #104       |
//| wizardserg@mail.ru                                                         |
//| Revised by IgorAD,igorad2003@yahoo.co.uk                                   |   
//| Personalized by iGoR AKA FXiGoR for the Trend Slope Trading method (T_S_T) |
//| Link:                                                                      |
//| contact: thefuturemaster@hotmail.com                                       |                               
//+----------------------------------------------------------------------------+
#property copyright "И maloma руку приложил :)"
//#property copyright "MT4 release WizardSerg <wizardserg@mail.ru>,ForexMagazine #104" 
//#property link      "wizardserg@mail.ru" 
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red
//---- input parameters 
extern int       period=5;//15; 
int       method=2;//3;                         // MODE_SMA 
int       price=5;//0;                          // PRICE_CLOSE 
int       y=0;
//---- buffers 
double Uptrend[];
double Dntrend[];
double ExtMapBuffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(3);
   SetIndexBuffer(0, Uptrend);
   //ArraySetAsSeries(Uptrend, true); 
   SetIndexBuffer(1, Dntrend);
   //ArraySetAsSeries(Dntrend, true); 
   SetIndexBuffer(2, ExtMapBuffer);
   ArraySetAsSeries(ExtMapBuffer, true);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
   IndicatorShortName("Signal Line("+period+")");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+ 
//|                                                                  | 
//+------------------------------------------------------------------+ 
double WMA(int x, int p)
  {
   return(iMA(NULL, PERIOD_D1, p, 0, method, price, x));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if (Period()>1440) return(0);
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)
      return(-1);
   int x=0;
   int p=MathSqrt(period);
   int e=iBars(Symbol(),PERIOD_D1) - counted_bars + period + 1;
//----   
   double vect[], trend[];
//----
   if(e > iBars(Symbol(),PERIOD_D1))
      e=iBars(Symbol(),PERIOD_D1);
//----      
   ArrayResize(vect, e);
   ArraySetAsSeries(vect, true);
   ArrayResize(trend, e);
   ArraySetAsSeries(trend, true);
//----   
   if (Period()==1) for(x=0; x < e; x++) for(y=x*1440;y<=x*1440+1439;y++) vect[y]=2*WMA(x, period/2) - WMA(x, period);
   if (Period()==5) for(x=0; x < e; x++) for(y=x*288;y<=x*288+287;y++) vect[y]=2*WMA(x, period/2) - WMA(x, period);
   if (Period()==15) for(x=0; x < e; x++) for(y=x*96;y<=x*96+95;y++) vect[y]=2*WMA(x, period/2) - WMA(x, period);
   if (Period()==30) for(x=0; x < e; x++) for(y=x*48;y<=x*48+47;y++) vect[y]=2*WMA(x, period/2) - WMA(x, period);
   if (Period()==60) for(x=0; x < e; x++) for(y=x*24;y<=x*24+23;y++) vect[y]=2*WMA(x, period/2) - WMA(x, period);
   if (Period()==240) for(x=0; x < e; x++) for(y=x*6;y<=x*6+5;y++) vect[y]=2*WMA(x, period/2) - WMA(x, period);
   if (Period()==1440) for(x=0; x < e; x++) for(y=x;y<=x;y++) vect[y]=2*WMA(x, period/2) - WMA(x, period);
//----   
   for(x=0; x < e-period; x++)
      ExtMapBuffer[x]=iMAOnArray(vect, 0, p, 0, method, x);
   for(x=e-period; x>=0; x--)
     {
      trend[x]=trend[x+1];
      if (ExtMapBuffer[x]> ExtMapBuffer[x+1]) trend[x] =1;
      if (ExtMapBuffer[x]< ExtMapBuffer[x+1]) trend[x] =-1;
      if (trend[x]>0)
        { Uptrend[x]=ExtMapBuffer[x];
         if (trend[x+1]<0) Uptrend[x+1]=ExtMapBuffer[x+1];
         Dntrend[x]=EMPTY_VALUE;
        }
      else
         if (trend[x]<0)
           {
            Dntrend[x]=ExtMapBuffer[x];
            if (trend[x+1]>0) Dntrend[x+1]=ExtMapBuffer[x+1];
            Uptrend[x]=EMPTY_VALUE;
           }
      //Print( " trend=",trend[x]);
     }
   return(0);
  }
//+------------------------------------------------------------------+ 