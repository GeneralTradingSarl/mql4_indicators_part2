//+------------------------------------------------------------------+
//|                                                        IFish.mq4 |
//|                                                          Kalenzo |
//|                                      bartlomiej.gorski@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kalenzo"
#property link      "bartlomiej.gorski@gmail.com"
//----
#property indicator_buffers 1
#property indicator_color1 Red
#property indicator_level1 0.5
#property indicator_level2 -0.5
//----
double value1[];
double value2[];
double ifish[];
double red[];
double green[];
double alertBar;
double prev;
double high=0.5;
double low=-0.5;
extern bool SoundON=true;
//----
#property indicator_separate_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(3);
   SetIndexBuffer(0,ifish);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
   SetIndexBuffer(1,value1);
   SetIndexBuffer(2,value2);
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
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+9;
//---- 
   for(int i=0;i<=limit;i++) value1[i]=0.1*(iRSI(Symbol(),0,5,PRICE_CLOSE,i)-50);
   for(int j=0;j<=limit;j++) value2[j]=iMAOnArray(value1,0,9,0,MODE_LWMA,j);
   for(int f=0;f<=limit;f++) ifish[f]=(MathExp(2*value2[f])-1)/(MathExp(2*value2[f])+1);
//----   
   if(ifish[f]>=high && prev==0) prev=1;
   if(ifish[f]<=low && prev==0) prev=2;
   if(SoundON==true && prev==1 && ifish[f]>=high && Bars>alertBar) {Alert("IFISH Hit 0.5 or above exit Buy on ",Symbol()," Period ",Period());alertBar=Bars;prev=2;}
   if(SoundON==true && prev==2 && ifish[f]<=low && Bars>alertBar) {Alert("IFISH Hit -0.5 or below exit Sell on ",Symbol()," Period ",Period());alertBar=Bars;prev=1;}
//----
   return(0);
  }
//+------------------------------------------------------------------+
