//+------------------------------------------------------------------+
//|                                                 i-BandsWidth.mq4 |
//|                                          Copyright © 2008, Talex |
//|                                                 tan@gazinter.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Talex"
#property link      "tan@gazinter.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

extern int    BandsPeriod=20;
extern int    BandsShift=0;
extern double BandsDeviations=2.0;
extern int    Slow=3;

double BWBuffer[],Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
   
   IndicatorBuffers(2);
   IndicatorShortName("i-BandsWidth ("+BandsPeriod+", "+DoubleToStr(BandsDeviations,1)+", "+Slow+")");
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Buffer);
   SetIndexBuffer(1,BWBuffer);

   return;
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {

   return;
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start() {
   int i,j,limit,cbars;
   double sum,oldval,newres,deviation,upband,dwband;
//---------------------------------------------------   
   cbars=IndicatorCounted();
   if(Bars<=BandsPeriod) return;
   if(cbars<0) return;
   if(cbars>0) limit=Bars-cbars-1;
      else limit=Bars-BandsPeriod-1;

   for(i=0;i<=limit;i++) {
      sum=0.0;
      oldval=iMA(NULL,0,BandsPeriod,BandsShift,MODE_SMA,PRICE_CLOSE,i);
      for(j=0;j<BandsPeriod;j++) {
         newres=Close[i+j]-oldval;
         sum+=newres*newres;
      }
      deviation=BandsDeviations*MathSqrt(sum/BandsPeriod);
      upband=oldval+deviation;
      dwband=oldval-deviation;
      if(oldval!=0)
      BWBuffer[i]=(upband-dwband)/oldval;
   }
   for(i=0;i<=limit;i++) {
      Buffer[i]=iMAOnArray(BWBuffer,0,Slow,0,0,i);
   }
   return;
}
//+------------------------------------------------------------------+