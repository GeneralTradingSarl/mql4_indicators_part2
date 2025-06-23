//+------------------------------------------------------------------+
//|                                                  BoDi.mq4        |
//|                                         Author:  paladin80       |
//|                                         E-mail:  forevex@mail.ru |
//+------------------------------------------------------------------+
#property copyright "paladin80"
#property link      "forevex@mail.ru"
//---- indicator settings
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  Black
#property indicator_color2  Red
#property indicator_color3  Green
//----
extern int    BoDiPeriod=20;
extern int    BoDiShift=0;
extern int    BoDiMA_mode=0;
extern int    Applied_price=0;
/*
BoDiMA_mode:
   0 - Simple moving average,   1 - Exponential moving average,
   2 - Smoothed moving average, 3 - Linear weighted moving average.
Applied_price:
   0 - Close price,  1 - Open price,   2 - High price,
   3 - Low price,    4 - Median price, 5 - Typical price,  6 - Weighted close price.
*/
bool   error=false;
string BoDiMA_modetext,
       Applied_pricetext;
//---- buffers
double ExtBuffer[];
double MovingBuffer[];
double UpperBuffer[];
double LowerBuffer[];
double DifferBuffer[];
double RedBuffer[];
double GreenBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 4 additional buffers are used for counting.
   IndicatorBuffers(7);
//---- indicators
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexStyle(6,DRAW_NONE);
//----
   SetIndexDrawBegin(1,BoDiPeriod);
   SetIndexDrawBegin(2,BoDiPeriod);
   IndicatorDigits(1);
//----
   SetIndexBuffer(0,ExtBuffer);
   SetIndexBuffer(1,GreenBuffer);
   SetIndexBuffer(2,RedBuffer);
   SetIndexBuffer(3,MovingBuffer);
   SetIndexBuffer(4,UpperBuffer);
   SetIndexBuffer(5,LowerBuffer);
   SetIndexBuffer(6,DifferBuffer);
//----
   if (BoDiMA_mode<0 || BoDiMA_mode>3)
   {  error=true; Alert("Please select correct BoDiMA_mode (0-3) for indicator BoDi");
      return(0); }
   if (Applied_price<0 || Applied_price>6)
   {  error=true; Alert("Please select correct Applied_price (0-6) for indicator BoDi");
      return(0); }
//----
   switch (BoDiMA_mode)
   {  case MODE_SMA:  BoDiMA_modetext="SMA";  break;
      case MODE_EMA:  BoDiMA_modetext="EMA";  break;
      case MODE_SMMA: BoDiMA_modetext="SMMA"; break;
      case MODE_LWMA: BoDiMA_modetext="LWMA"; break;
   }
   switch (Applied_price)
   {  case PRICE_CLOSE:    Applied_pricetext="Close";      break;
      case PRICE_OPEN:     Applied_pricetext="Open";       break;
      case PRICE_HIGH:     Applied_pricetext="High";       break;
      case PRICE_LOW:      Applied_pricetext="Low";        break;
      case PRICE_MEDIAN:   Applied_pricetext="Median";     break;
      case PRICE_TYPICAL:  Applied_pricetext="Typical";    break;
      case PRICE_WEIGHTED: Applied_pricetext="Weighted";   break;
   }
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("BoDi("+BoDiMA_modetext+","+Applied_pricetext+","+BoDiPeriod+"/"+BoDiShift+")");
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
   SetIndexLabel(4,NULL);
   SetIndexLabel(5,NULL);
   SetIndexLabel(6,NULL);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
   if (error==true) return(0);
//----
   int    i,k;//,counted_bars=IndicatorCounted();
   double deviation;
   double sum,oldval,newres;
   double prev,current;
//----
   if(Bars<=BoDiPeriod) return(0);

   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+BoDiPeriod;
   
   for(i=0; i<limit; i++)
      MovingBuffer[i]=iMA(NULL,0,BoDiPeriod,BoDiShift,BoDiMA_mode,Applied_price,i);
//----
   i=limit;
   while(i>=0)
     {
      sum=0.0;
      k=i+BoDiPeriod-1;
      oldval=MovingBuffer[i];
      while(k>=i)
        {
         //----
         switch (Applied_price)
         {
         case PRICE_CLOSE:    newres=Close[k+BoDiShift]-oldval; break;
         case PRICE_OPEN:     newres=Open [k+BoDiShift]-oldval; break;
         case PRICE_HIGH:     newres=High [k+BoDiShift]-oldval; break;
         case PRICE_LOW:      newres=Low  [k+BoDiShift]-oldval; break;
         case PRICE_MEDIAN:   newres=(High[k+BoDiShift]+Low[k+BoDiShift])/2.0-oldval; break;
         case PRICE_TYPICAL:  newres=(High[k+BoDiShift]+Low[k+BoDiShift]+Close[k+BoDiShift])/3.0-oldval; break;
         case PRICE_WEIGHTED: newres=(High[k+BoDiShift]+Low[k+BoDiShift]+2*Close[k+BoDiShift])/4.0-oldval; break;
         }
         //----
         sum+=newres*newres;
         k--;
        }
      deviation=MathSqrt(sum/BoDiPeriod);
      UpperBuffer[i]=oldval+deviation;
      LowerBuffer[i]=oldval-deviation;
      DifferBuffer[i]=(UpperBuffer[i]-LowerBuffer[i])*1000;
      i--;
     }
//---- dispatch values between 2 buffers
   bool up=true;
   for(i=limit-1; i>=0; i--)
     {
      current=DifferBuffer[i];
      prev=DifferBuffer[i+1];
      if(current>prev) up=true;
      if(current<prev) up=false;
      if(!up)
        {   GreenBuffer[i]=current;
            RedBuffer[i]=0.0;
        }
      else
        {   RedBuffer[i]=current;
            GreenBuffer[i]=0.0;
        }
        ExtBuffer[i]=current;
     }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+