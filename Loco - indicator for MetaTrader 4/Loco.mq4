//+------------------------------------------------------------------+ 
//| Loco.mq4                                                         | 
//| Copyright © 2005, MetaQuotes Software Corp.                      | 
//| http://www.metaquotes.net                                        |  
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link "http://www.metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- input parameters 
extern int strata=1;
//---- buffers 
double stratbuffer[];
double prev=0;
double result;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int init()
  {
//---- indicators 
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexBuffer(0,stratbuffer);
//---- 
   return(0);
  }
//+------------------------------------------------------------------+ 
//| Custor indicator deinitialization function                       | 
//+------------------------------------------------------------------+ 
int deinit()
  {
//---- 
//---- 
   return(0);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int pos=Bars-counted_bars;
   if(counted_bars==0) pos-=1+1;

   while(pos>=0)
     {
      if(Open[pos]==prev)result=prev;
      else
        {
         if(Open[pos+1]>prev && Open[pos]>prev)
           {
            result=MathMax(prev,(Open[pos]*0.999));
           }
         else
           {
            if(Open[pos]>prev){result=(Open[pos]*0.999);}
            else { result=(Open[pos]*(1.001));}
           }
        }
      prev=result;
      stratbuffer[pos]=result;
      pos--;
     }
//---- 
   return(0);
  }
//+------------------------------------------------------------------+
