//+------------------------------------------------------------------+
//|                                                        Bears.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Teo_Onica"
#property link      "phone:0612480123"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 LawnGreen
#property indicator_color2 Blue
#property indicator_color3 Orange

//---- input parameters
extern int per=1000;
extern double BandsDeviations=0.5;
//extern int signal=5;
//extern int main=3;
//---- buffers
double regr[];
double regrh[];
double regrb[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(3);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
//---- indicator buffers mapping
   SetIndexBuffer(0,regr);
   SetIndexStyle(1,DRAW_LINE);
//---- indicator buffers mapping
   SetIndexBuffer(1,regrh);
//ObjectCreate("Rezist", OBJ_TREND, 0,0,0,0,0);
   SetIndexStyle(2,DRAW_LINE);
//---- indicator buffers mapping
   SetIndexBuffer(2,regrb);

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
//ObjectDelete("Rezist");

//---- 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Bears Power                                                      |
//+------------------------------------------------------------------+
int start()
  {
   if (Bars<per) return(-1);

   double x,y,etapc,xy,etapd,xx,etapf,yy,coefa,coefb,naw,nawb,rac,cor,temp,tempp,sum,deviation;
   int i,a,b,c,k;
//----
//if(Bars<=BearsPeriod) return(0);
//----
// int limit=Bars-counted_bars;
// if(counted_bars>0) limit++;
//for(i=0; i<limit; i++)
// TempBuffer[i]=iMA(NULL,0,BearsPeriod,0,MODE_EMA,PRICE_CLOSE,i);
//----

   i=per;
   a=per;
   b=per;
   c=per;

   x=0;
   y=0;
   xy=0;
   etapc=0;
   etapd=0;
   xx=0;
   etapf=0;
   yy=0;

   i=per;

   while(i>=0)
     {
      x=x+i;
      y=y+Close[i];
      etapc=Close[i]*i;
      xy=xy+etapc;
      etapd=i*i;
      xx=xx+etapd;
      etapf=Close[i]*Close[i];
      yy=yy+etapf;
      i--;
     }

   coefb=((per*xy)-(x*y))/((per*xx)-(x*x));
   coefa=(y-(coefb*x))/per;
//vala=coefa+(coefb*1);
//valb=coefa+(coefb*per);
   naw=((per*xx)-(x*x))*((per*yy)-(y*y));
   nawb=MathAbs(naw);
   rac=MathSqrt(nawb);
   cor=((per*xy)-(x*y))/rac;
   int haut=iHighest(NULL,0,MODE_HIGH,per,1);
   int bas =iLowest(NULL,0,MODE_LOW,per,1);

   while(a>=0)
     {
      regr[a]=coefa+(coefb*a);
      a--;
     }

//ObjectSet("Rezist", OBJPROP_TIME1 ,Time[per]);
//ObjectSet("Rezist", OBJPROP_TIME2 ,Time[1]);
//ObjectSet("Rezist", OBJPROP_TIME3 ,Time[1]);
//ObjectSet("Rezist", OBJPROP_PRICE1,valb);
//ObjectSet("Rezist", OBJPROP_PRICE2,vala);
//ObjectSet("Rezist", OBJPROP_PRICE3,valc);
//ObjectSet("Rezist", OBJPROP_RAY   , True);

// double priceh = ObjectGetValueByShift("Rezist", haut);
//double priceb = ObjectGetValueByShift("Rezist", bas);

//Comment("haut ",hh,"  bas ",bb," correlation ",cor," ym ",ym);
//----
   i=0;

   sum=0.0;
   k=i+per-1;
   temp=regr[i];
   while(k>=i)
     {
      tempp=Close[k]-temp;
      sum+=tempp*tempp;
      k--;
     }

   deviation=BandsDeviations*MathSqrt(sum/per);

   i=per;
   while(i>=0)
     {
      temp=regr[i];
      regrh[i]=temp+deviation;
      regrb[i]=temp-deviation;
      i--;
     }
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
