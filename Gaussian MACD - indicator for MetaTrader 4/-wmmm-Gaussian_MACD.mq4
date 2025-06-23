//+------------------------------------------------------------------+
//|                                                        GMACD.mq4 |
//|                                       when-money-makes-money.com |
//|                                       when-money-makes-money.com |
//+------------------------------------------------------------------+
#property copyright "when-money-makes-money.com"
#property link      "when-money-makes-money.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Black
#property indicator_color3 Blue
#property indicator_color4 Red
//---- buffers
double signal[];
double main[];
double diffup[];
double diffdo[];
double ma[];
double maf[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
double     pi = 3.1415926535;

extern int Fast=26;
extern int Slow=12;
extern int Signal=3;
double Fast_alfa,Slow_alfa,Signal_alfa;

double getAlfa(int p){

   double w = 2*pi/p;
	double beta = (1 - MathCos(w))/(MathPow(1.414,2.0/3) - 1);
	double alfa = -beta + MathSqrt(beta*beta + 2*beta);
	return (alfa);
}

int init()
  {

   Fast_alfa=getAlfa(Fast);
   Slow_alfa=getAlfa(Slow);
   Signal_alfa=getAlfa(Signal);
//---- indicators
   IndicatorBuffers(6);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,3);
   SetIndexBuffer(0,signal);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexBuffer(1,main);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexBuffer(2,diffup);
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexBuffer(3,diffdo);

   SetIndexBuffer(4,ma);
   SetIndexBuffer(5,maf);   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
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

double GSMOOTH(double price,double arr[],double alfa,int i){
	    double ret = MathPow(alfa,4)*price + 4*(1-alfa)*arr[i+1] - 6*MathPow(1-alfa,2)*arr[i+2] + 4*MathPow(1-alfa,3)*arr[i+3] - MathPow(1-alfa,4)*arr[i+4];
       return (ret);     

}
int start()
  {
   int    counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+4;
//----
   for(int i=limit;i>=0;i--){
      ma[i]=GSMOOTH(Close[i],ma,Slow_alfa,i);
      maf[i]=GSMOOTH(Close[i],maf,Fast_alfa,i);
      main[i]=ma[i]-maf[i];  
      signal[i]=GSMOOTH(main[i],signal,Signal_alfa,i);
      double tmp=main[i]-signal[i];
      double tmp2=main[i+1]-signal[i+1];
      if(tmp>tmp2){
         diffup[i]=tmp*10;
         diffdo[i]=0;
      }
      if(tmp<tmp2){
         diffup[i]=0;
         diffdo[i]=tmp*10;
      }
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+