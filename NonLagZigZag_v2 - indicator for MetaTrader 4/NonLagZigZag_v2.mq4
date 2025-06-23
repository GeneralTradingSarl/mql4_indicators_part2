//+------------------------------------------------------------------+
//|                                              NonLagZigZag_v2.mq4 |
//|                                Copyright © 2006, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
//----
#property indicator_chart_window
#property indicator_buffers 1
//----
#property indicator_color1 Gold
#property indicator_width1 2
//---- input parameters
extern int     Price      =0;  //Apply to Price(0-Close;1-Open;2-High;3-Low;4-Median price;5-Typical price;6-Weighted Close) 
extern int     Length      =100;  //Period of NonLagMA
extern double  PctFilter  =2;  //Dynamic filter in decimals
//----
double ZZBuffer[];
double MABuffer[];
double trend[];
double Del[];
double AvgDel[];
//----
int    ilow, ihigh, nlow, nhigh, prevnhigh,prevnlow, BarsBack;
double alfa[];
datetime lotime,hitime;
int    i, Phase, Len, Cycle=4, Back=0;
double Coeff, beta, t, Sum, Weight, g;
double pi=3.1415926535;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  int init()
  {
   IndicatorBuffers(5);
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,ZZBuffer);
   SetIndexBuffer(1,MABuffer);
   SetIndexBuffer(2,trend);
   SetIndexBuffer(3,Del);
   SetIndexBuffer(4,AvgDel);
   string short_name;
//---- indicator line
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- name for DataWindow and indicator subwindow label
   short_name="NonLagZigZag("+Length+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"NonLagZigZag");
//----
   SetIndexEmptyValue(0,0.0);
   SetIndexDrawBegin(0,Length*Cycle+Length);
//----
   Coeff= 3*pi;
   Phase=Length-1;
   Len=Length*Cycle + Phase;
   ArrayResize(alfa,Len);
   Weight=0;
   for(i=0;i<Len-1;i++)
     {
      if (i<=Phase-1) t=1.0*i/(Phase-1);
      else t=1.0 + (i-Phase+1)*(2.0*Cycle-1.0)/(Cycle*Length-1.0);
      beta=MathCos(pi*t);
      g=1.0/(Coeff*t+1);
      if (t<=0.5)g=1;
      alfa[i]=g * beta;
      Weight+=alfa[i];
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| NonLagZigZag_v2                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    i,shift,limit;
   double price,smin,smax;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1); 
   if(counted_bars > 0)   counted_bars--;
   limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+1+MathMax(Len,Length);

   for(shift=limit;shift>=0;shift--)
     {
      Sum=0;
      for(i=0;i<=Len-1;i++)
        {
         price=iMA(NULL,0,1,0,3,Price,i+shift);
         Sum+=alfa[i]*price;
        }
      if (Weight > 0) MABuffer[shift]=Sum/Weight;
      Del[shift]=MathAbs(MABuffer[shift] - MABuffer[shift+1]);
//----
      double sumdel=0;
      for(i=0;i<=Length-1;i++) sumdel+=Del[shift+i];
      AvgDel[shift]=sumdel/Length;
//----
      double sumpow=0;
      for(i=0;i<=Length-1;i++) sumpow+=MathPow(Del[shift+i]-AvgDel[shift+i],2);
      double StdDev=MathSqrt(sumpow/Length);
      double Filter=PctFilter * StdDev;
      if (Filter < Point) Filter=Point;
      if(MathAbs(MABuffer[shift]-MABuffer[shift+1]) < Filter)MABuffer[shift]=MABuffer[shift+1];
//----
      trend[shift]=trend[shift+1];
      if (MABuffer[shift]-MABuffer[shift+1] > Filter) trend[shift]= 1;
      if (MABuffer[shift+1]-MABuffer[shift] > Filter) trend[shift]=-1;
      if(trend[shift]>0)
        {
         if(trend[shift]!=trend[shift+1])
           {
            ilow=LowestBar(iBarShift(NULL,0,hitime,FALSE)-shift,shift);
            lotime=Time[ilow];
            ZZBuffer[ilow]=Low[ilow];
           }
         else
            if (shift==0)
              {
               int hilen=iBarShift(NULL,0,lotime,FALSE);
               nhigh=HighestBar(hilen,0);
               ZZBuffer[nhigh]=High[nhigh];
               if (nhigh== 0) for(i=hilen-1;i>=1;i--) ZZBuffer[i]=0;
               if (nhigh > 0) for(i=nhigh-1;i>=0;i--) ZZBuffer[i]=0;
              }
        }
      if (trend[shift]<0)
        {
         if(trend[shift]!=trend[shift+1])
           {
            ihigh=HighestBar(iBarShift(NULL,0,lotime,FALSE)-shift,shift);
            hitime=Time[ihigh];
            ZZBuffer[ihigh]=High[ihigh];
           }
         else
            if (shift==0)
              {
               int lolen=iBarShift(NULL,0,hitime,FALSE);
               nlow=LowestBar(lolen,0);
               ZZBuffer[nlow]=Low[nlow];
               if (nlow==0) for(i=lolen-1;i>=1;i--) ZZBuffer[i]=0;
               if (nlow >0) for(i=nlow-1;i>=0;i--) ZZBuffer[i]=0;
              }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LowestBar(int len,int k)
  {
   double min=10000000;
   int lobar;
//----
   for(int i=k+len-1;i>=k;i--)
      if(Low[i] < min) {min=Low[i]; lobar=i;}
   if(len<=0) lobar=k;
   return(lobar);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int HighestBar(int len,int k)
  {
   double max=-10000000;
   int hibar;
   for(int i=k+len-1;i>=k;i--)
      if(High[i] > max) {max=High[i]; hibar=i;}
   if(len<=0) hibar=k;
   return(hibar);
  }
//+------------------------------------------------------------------+