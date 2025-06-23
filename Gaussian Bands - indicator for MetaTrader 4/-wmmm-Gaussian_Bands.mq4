//+------------------------------------------------------------------+
//|                                                       GBands.mq4 |
//|                                                           zzuegg |
//|                                       when-money-makes-money.com |
//+------------------------------------------------------------------+
#property copyright "zzuegg"
#property link      "when-money-makes-money.com"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_color5 Blue

//---- buffers
double center[];
double up_1[];
double do_1[];
double up_2[];
double do_2[];
double var[];
double var1[];
double var2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
extern int centerPeriod=12;
extern int dev_1_Period=12;
extern double dev_1_Multi=2;
extern int dev_2_Period=12;
extern double dev_2_Multi=4;

double center_alfa,dev_1_alfa,dev_2_alfa;
double     pi = 3.1415926535;

color lc[]={Yellow,Gold,Orange,DarkOrange,OrangeRed,Red,OrangeRed,DarkOrange,Orange,Gold};


double getAlfa(int p){

   double w = 2*pi/p;
	double beta = (1 - MathCos(w))/(MathPow(1.414,2.0/3) - 1);
	double alfa = -beta + MathSqrt(beta*beta + 2*beta);
	return (alfa);
}


int init()
  {
//---- indicators


     ObjectCreate("logo",OBJ_LABEL,0,0,0);
   ObjectSetText("logo","when-money-makes-money.com",20);
   ObjectSet("logo",OBJPROP_XDISTANCE,0);
   ObjectSet("logo",OBJPROP_YDISTANCE,30);

   center_alfa=getAlfa(centerPeriod);
   dev_1_alfa=getAlfa(dev_1_Period);
   dev_2_alfa=getAlfa(dev_2_Period);
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_LINE,STYLE_DOT,1);
   SetIndexBuffer(0,center);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,up_1);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,do_1);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,3);
   SetIndexBuffer(3,up_2);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,3);
   SetIndexBuffer(4,do_2);
   SetIndexBuffer(5,var);
   SetIndexBuffer(6,var1);
   SetIndexBuffer(7,var2);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
     ObjectDelete("logo"); 
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

     static int currc=0;
   ObjectSet("logo",OBJPROP_COLOR,lc[currc]);
   currc++;
   if(currc>=ArraySize(lc))currc=0;


   for(int i=limit;i>=0;i--){
      center[i]=GSMOOTH(Close[i],center,center_alfa,i);
      var[i]=MathAbs(Close[i]-center[i]);
      if(var[i]>0){
      var1[i]=GSMOOTH(var[i],var1,dev_1_alfa,i);
      var2[i]=GSMOOTH(var[i],var2,dev_2_alfa,i);
      }
      Print(var[i]);
      up_1[i]=center[i]+(var1[i]*dev_1_Multi);
      do_1[i]=center[i]-(var1[i]*dev_1_Multi);
      up_2[i]=center[i]+(var2[i]*dev_2_Multi);
      do_2[i]=center[i]-(var2[i]*dev_2_Multi);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+