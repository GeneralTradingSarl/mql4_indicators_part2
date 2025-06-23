//+-------------------------------------------------------------------------+
//|                                                         Giotee-Norm.mq4 |
//|                                                 Copyright 2016, Gioteen |
//|                                   https://www.mql5.com/en/users/gioteen |
//+-------------------------------------------------------------------------+
#property copyright "Copyright 2016, Farhad Kia"
#property link      "https://www.mql5.com/en/users/gioteen"
#property version   "2.00"
#property strict


#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- indicator buffers
#property indicator_label2  "Label2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_DASH
#property indicator_width2  1
double         Label1Buffer[];
double         Label2Buffer[];
extern string sym="";
extern int ExtPeriod=100;
extern ENUM_MA_METHOD ExtMAMethod=0;
extern ENUM_APPLIED_PRICE ExtAppliedPrice=0;
extern int ExtShift=0;
input bool DrawMA=true;
extern int maPeriod=50;
extern ENUM_MA_METHOD maMethod=1;

int    nCountedBars,i;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,Label1Buffer);
      SetIndexBuffer(1,Label2Buffer);
      if(DrawMA==false)
         SetIndexStyle(1,DRAW_NONE);
         SetIndexDrawBegin(0,ExtPeriod+1);
     SetIndexDrawBegin(1,ExtPeriod+maPeriod+2);
     SetIndexEmptyValue(0,0);
     SetIndexEmptyValue(1,0);
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
//---
if(Bars<=ExtPeriod) return(0);

   nCountedBars=IndicatorCounted();

   i=Bars-ExtPeriod-1;
   if(nCountedBars>ExtPeriod) 
      i=Bars-nCountedBars;  
   while(i>=0)
     {
    
     
      double st=std2(i);
      if(st==0)
         st=0.00001;
      Label1Buffer[i]=(GetAppliedPrice(ExtAppliedPrice,i)-iMA(sym,0,ExtPeriod,0,ExtMAMethod,ExtAppliedPrice,i))/st;

            Label2Buffer[i]=iMAOnArray(Label1Buffer,0,maPeriod,0,maMethod,i);         


      
      i--;
      }

   return(rates_total);
  }
//+------------------------------------------------------------------+



double std2(int k)
{
      double dAPrice=0;
      double dAmount=0.0;
      double dMovingAverage=iMA(sym,0,ExtPeriod,0,ExtMAMethod,ExtAppliedPrice,k);
      for(int j=0; j<ExtPeriod; j++)
        {
         dAPrice=GetAppliedPrice(ExtAppliedPrice,k+j);
         dAmount+=(dAPrice-dMovingAverage)*(dAPrice-dMovingAverage);
        }
      return(MathSqrt(dAmount/ExtPeriod));
}

double GetAppliedPrice(int nAppliedPrice, int nIndex)
  {
   double dPrice;
//----
   switch(nAppliedPrice)
     {
      case 0:  dPrice=iClose(sym,0,nIndex);                                  break;
      case 1:  dPrice=iOpen(sym,0,nIndex);                                   break;
      case 2:  dPrice=iHigh(sym,0,nIndex);                                   break;
      case 3:  dPrice=iLow(sym,0,nIndex);                                    break;
      case 4:  dPrice=(iHigh(sym,0,nIndex)+iLow(sym,0,nIndex))/2.0;                 break;
      case 5:  dPrice=(iHigh(sym,0,nIndex)+iLow(sym,0,nIndex)+iClose(sym,0,nIndex))/3.0;   break;
      case 6:  dPrice=(iHigh(sym,0,nIndex)+iLow(sym,0,nIndex)+2*iClose(sym,0,nIndex))/4.0; break;
      default: dPrice=0.0;
     }
     return(dPrice);
 }
 