//+------------------------------------------------------------------+
//| MBKAsctrend3times.mq4                                            |
//+------------------------------------------------------------------+
#property copyright "MBKAsctrend3times matt kennel"
#property link      "http://www.metatrader.org"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
// Modified by MBK:  now have three different timescales (bar lengths)
// to combine for final WPR indicator, with further long-term trend indicator.
// try on H1 chart with these parameters. 
extern int RISK=3;
//extern int CountBars=2000;
extern int NumberofAlerts=0;
extern int WPRLength1=9,WPRLength2=33,WPRLength3=77;
extern int LToffset=-5;
extern double w1=1.0,w2=3.0,w3=1.0; // relative weights
int counter=0;
//---- buffers
double val1[];
double val2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(0,val1);
   SetIndexBuffer(1,val2);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| SilverTrend_Signal                                               |
//+------------------------------------------------------------------+
int start()
  {
//if (CountBars>=Bars) CountBars=Bars;
//SetIndexDrawBegin(0,Bars-CountBars+SSP);
//SetIndexDrawBegin(1,Bars-CountBars+SSP);
   int i1,i2,K;
   double Range,AvgRange,smin,smax,SsMax,SsMin,price;
   double wprvalue;
   static bool uptrend,old;
   bool flag1,flag2;
   int i,shift;
//if(Bars<=SSP+1) return(0);
//---- initial zero
//if(counted_bars<SSP+1)
// {
//      for(i=1;i<=SSP;i++) val2[CountBars-i]=0.0;
//  }
////----
   K=33-RISK;
// wprlength = 3+RISK*2; 
   uptrend=false;
   old=false;
   double sumweights=w1+w2+w3;
   w1/=sumweights;
   w2/=sumweights;
   w3/=sumweights;
   int SSP=10;

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+SSP+1;

   for(shift=limit; shift>=0; shift--)
     {
      Range=0;
      AvgRange=0;
      for(i1=shift; i1<=shift+SSP; i1++)
        {
         AvgRange=AvgRange+MathAbs(High[i1]-Low[i1]);
        }
      Range=AvgRange/(SSP+1);
      double wprval1=(100-MathAbs(iWPR(Symbol(),Period(),WPRLength1,shift)));
      double wprval2=(100-MathAbs(iWPR(Symbol(),Period(),WPRLength2,shift)));
      double wprval3=(100-MathAbs(iWPR(Symbol(),Period(),WPRLength3,shift)));
      wprvalue=w1*wprval1+w2*wprval2+w3*wprval3;
      //  MathPow(wprval1*wprval2*wprval3,1.0/3.0); 
      double wprlong=wprval3;
      if((wprvalue<33-RISK) && (wprlong<50-LToffset))
        {
         uptrend=false;
        }
      if((wprvalue>67+RISK) && (wprlong>=50+LToffset))
        {
         uptrend=true;
        }
      if(uptrend!=old && uptrend==true)
        {
         val1[shift]=Low[shift]-Range*0.8; // lower range
         counter=0;
         if(shift==0 && counter<=NumberofAlerts)
           {
            // Alert("MBKAsctrend ",Period()," ",Symbol()," BUY");
            counter=counter+1;
           }
        }
      if(uptrend!=old && uptrend==false)
        {
         counter=0;
         val2[shift]=High[shift]+Range*0.8;
         if(shift==0 && counter<=NumberofAlerts)
           {
            // Alert("Silver Trend ",Period()," ",Symbol()," SELL");
            counter=counter+1;
           }
        }
      Comment(shift);
      old=uptrend;
     }
   return(0);
  }
//+------------------------------------------------------------------+
