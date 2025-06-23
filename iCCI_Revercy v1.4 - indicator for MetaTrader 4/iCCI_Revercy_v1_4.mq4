//+------------------------------------------------------------------+
//|                                                 iCCI_Revercy.mq4 |
//|                                                        EvgeTrofi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © Evgeniy Trofimov, 2009"
#property link      "http://vkontakte.ru/id5374887/"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Red
extern int  CCIPeriod = 14;
extern double FindCCI = 100.0;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() 
  {
   IndicatorBuffers(2);
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexDrawBegin(0,CCIPeriod);
   SetIndexLabel(0,"CloseUP");
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexDrawBegin(1,CCIPeriod);
   SetIndexLabel(1,"CloseDN");
   IndicatorShortName("CCI_Revercy("+CCIPeriod+", "+FindCCI+")");
   return(0);
  }//init()
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() 
  {
   int BeginBar;
//---- новые бары не появились и поэтому ничего рисовать не нужно 
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   BeginBar=Bars-counted_bars;
   if(counted_bars==0) BeginBar-=1+CCIPeriod;

//---- основные переменные
   double Price,CCILast,CCI;
   for(int t=BeginBar; t>=0; t--) 
     {
      ExtMapBuffer1[t]=PriceCCI(FindCCI, t, 0);
      ExtMapBuffer2[t]=PriceCCI(FindCCI, t, 1);
/*
      CCILast=iCCI(NULL,0,CCIPeriod,PRICE_TYPICAL,t+2);
      CCI=iCCI(NULL,0,CCIPeriod,PRICE_TYPICAL,t+1);
      if((CCILast>0 && CCI<0) || 
         (CCILast<0 && CCI>0))  {
         ExtMapBuffer1[t+2]=EMPTY_VALUE;
      }
      */
     }//Next t
   return(0);
  } //start()
//+------------------------------------------------------------------+
double PriceCCI(double LevelCCI,int CurrentCandle=0,int index=0) 
  {
//Вычисляем текущий CCI
   double MovBuffer;
   double Price,SummPrice,Abs,SummAbs;
   double K=0.015;
   int j;
   for(int i=CCIPeriod-1; i>=0; i--) 
     {
      j=i+CurrentCandle;
      Price=(High[j]+Low[j]+Close[j])/3;
      MovBuffer=iMA(NULL,0,CCIPeriod,0,MODE_SMA,PRICE_TYPICAL,CurrentCandle);
      Abs=MathAbs(Price-MovBuffer);
      if(i>0) 
        {
         SummPrice+=Price;
         SummAbs+=Abs;
        }
     }//Next i
   double CCI=(Price-MovBuffer)/((SummAbs+Abs)*K/CCIPeriod);
   Comment("CCI("+CCIPeriod+") = "+DoubleToStr(CCI,4)+"\nFindCCI = "+DoubleToStr(LevelCCI,1));
//В зависимости от знака CCI для расчёта необходимой цены используется соответствующая формула
   double H = High[CurrentCandle];
   double L =  Low[CurrentCandle];
   i = CCIPeriod;
   if(index==0) 
     {
      CCI=LevelCCI;
      Price=-(H*i-L*i*i-H*i*i+L*i-CCI*H*K-CCI*L*K+3*SummPrice*i-
              CCI*3*K*SummPrice+CCI*H*K*i+CCI*L*K*i+CCI*3*K*SummAbs*i)/
              (i-i*i-CCI*K+CCI*K*i);
        } else {
      CCI=-LevelCCI;
      Price=-(H*i-L*i*i-H*i*i+L*i+CCI*H*K+CCI*L*K+3*SummPrice*i+
              CCI*3*K*SummPrice-CCI*H*K*i-CCI*L*K*i+CCI*3*K*SummAbs*i)/
              (i-i*i+CCI*K-CCI*K*i);
     }
   return(Price);
  }//PriceCCI()
//+------------------------------------------------------------------+
