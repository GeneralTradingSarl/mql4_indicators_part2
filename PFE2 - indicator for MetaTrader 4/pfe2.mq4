//+------------------------------------------------------------------+
//|                                                          pfe2.mq4|
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- input parameters
extern int smoothingLen=15;
//extern int buySellLevel = 60;
//---- buffers
double pfe[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcPrice(int bar)
  {
   int k;
   double sum=0;
   for(k=bar;k>=bar-smoothingLen;k--)
      sum+=iClose(NULL,0,k);

//Print(sum/smoothingLen);   
   return(sum/smoothingLen);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   IndicatorBuffers(1);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,3);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   SetIndexBuffer(0,pfe);
//----   
   return(0);
  }
//+------------------------------------------------------------------+
//| pfe                                                              |
//+------------------------------------------------------------------+
int start()
  {
   int CountBars=300,i=0,j=0;
   double calcPrice=0,PFE=0,c2c=0,fraceff=0;
//----
//SetIndexDrawBegin(0,Bars-CountBars+smoothingLen);

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+MathMax(9,smoothingLen);

//---- initial zero
//for(i=Bars-CountBars+smoothingLen;i<=Bars;i++) pfe[i]=0;
   for(i=0;i<=limit;i++) pfe[i]=0;
//----
   for(i=smoothingLen;i<=limit;i++)
     {
      calcPrice=0;
      PFE=0;
      c2c=0;
      fraceff=0;
      //
      PFE=MathSqrt(MathPow(calcPrice(i)-calcPrice(i-9),2)+100);
      //Print("PFE = " + PFE);
      for(j=1;j<=9;j++)
         c2c+=MathSqrt(MathPow(calcPrice(i-j-1)-calcPrice(i-j),2)+1);
      //Print("c2c = " + c2c);
      if(calcPrice(i)-calcPrice(i-9)>0)
         fraceff=MathRound((PFE/c2c)*100);
      else
         fraceff=MathRound(-(PFE/c2c)*100);
      //a = iMomentum(NULL,0,len-1,PRICE_MEDIAN,0);  
      //b = iMomentum(NULL,0,len-1,PRICE_MEDIAN,0); 
      //a = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0); 
      //b = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0); 
      //Print("fraceff = " +fraceff);   
      if(i==limit)
         pfe[i]=fraceff;
      else
         pfe[i]=MathRound((fraceff*0.333)+(pfe[i-1]*(1-0.333)));
     }
   return(0);
  }
//+------------------------------------------------------------------+
