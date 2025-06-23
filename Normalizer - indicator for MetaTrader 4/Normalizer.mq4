//+------------------------------------------------------------------+
//|                                                   Normalizer.mq4 |
//|                                          Copyright © 2008, al_su |
//|                                                  al_su31@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, al_su"
#property link      "al_su31@mail.ru"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_maximum 1
#property indicator_minimum -1
#property indicator_level1 0.25
#property indicator_level2 0.5
#property indicator_level3 0.75
#property indicator_level4 -0.25
#property indicator_level5 -0.5
#property indicator_level6 -0.75
#property indicator_color1 DodgerBlue
//---- input parameters
#define PERIODS_CHARACTERISTIC 3

extern string  Indicator;
extern int     mode=0;
extern int     param1=8;//Ну или 9, не важно...
extern int     param2=9;
//extern int param3;Скока надо параметров, стока и задаем
//---- buffers 
double Normalizer[];
double characteristic_period;
double sigma;
//-------------------------------------------------------------------------------
double Indyuk(int shift)
  {
//   return (iCustom(0,0,Indicator,param1,param2,/*param3, и т.д.:)*/mode,shift));
// the retuned value must vary from - to +.
   return(50-iRSI(Symbol(),0,14,PRICE_CLOSE,shift));
  }
//+------------------------------------------------------------------+
//| MathTanh                                                         |
//+------------------------------------------------------------------+
double MathTanh(double x)
  {
   double exp;
   if(x>0) {exp=MathExp(-2*x);return((1-exp)/(1+exp));}
   else {exp=MathExp(2*x);return((exp-1)/(1+exp));}
  }
//+------------------------------------------------------------------+
//| ArrayAverage                                                     |
//+------------------------------------------------------------------+
double ArrayAverage(double &a[])
  {
   int i;
   double s;
   if(ArraySize(a)<1) return (0);
   s=0;
   for(i=0;i<ArraySize(a);i++) s+=a[i];
   return (s/ArraySize(a));
  }

int calc_flag=false;
//+------------------------------------------------------------------+
//| CalculateCharacteristicPeriod                                    |
//+------------------------------------------------------------------+
void CalculateCharacteristicPeriod()
  {
   if(calc_flag==true) return;
  
   int i;
   int count,count_zeros;
   count=0;
   count_zeros=0;
   double periods[];
   for(i=Bars-2;i>=0;i--)
     {
      if(Indyuk(i)*Indyuk(i+1)<0)//переход через 0
        {
         count++;
         ArrayResize(periods,count);
         periods[ArraySize(periods)-1]=0;
        }
      if(ArraySize(periods)>0) periods[ArraySize(periods)-1]++;
     }
   characteristic_period=2*PERIODS_CHARACTERISTIC*ArrayAverage(periods);
   SetIndexDrawBegin(0,characteristic_period);
   Print("characteristic_period=",characteristic_period);
   calc_flag=true;
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorShortName("Normalized "+Indicator);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Normalizer);
   calc_flag=false;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   if(calc_flag==false) CalculateCharacteristicPeriod();
   if (characteristic_period==0) return(-1);
//---
   int   i,j;
   double S;
//---
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+characteristic_period;
//---  
   for(i=limit;i>=0;i--)
     {
      S=0;
      for(j=0;j<characteristic_period;j++) S+=MathPow(Indyuk(i+j),2);
      S/=characteristic_period;
      S=MathSqrt(S);
      if(S!=0) Normalizer[i]=Indyuk(i)/S;
      Normalizer[i]=MathTanh(Normalizer[i]);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
