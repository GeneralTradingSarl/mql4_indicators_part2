//+------------------------------------------------------------------+
//|                                              GaussianRainbow.mq4 |
//|                                       when-money-makes-money.com |
//|                                       when-money-makes-money.com |
//+------------------------------------------------------------------+
#property copyright "when-money-makes-money.com"
#property link      "when-money-makes-money.com"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 PowderBlue
#property indicator_color2 LightSkyBlue
#property indicator_color3 DeepSkyBlue
#property indicator_color4 Blue
#property indicator_color5 SlateBlue
#property indicator_color6 IndianRed
#property indicator_color7 Salmon
#property indicator_color8 Red
//---- buffers
double rb1[];
double rb2[];
double rb3[];
double rb4[];
double rb5[];
double rb6[];
double rb7[];
double rb8[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
extern int RainbowPeriod=10;
extern int GaussianOrder=3;
double     pi = 3.1415926535, w, alfa, beta;
color lc[]={Yellow,Gold,Orange,DarkOrange,OrangeRed,Red,OrangeRed,DarkOrange,Orange,Gold};
int init()
  {
  
   ObjectCreate("logo",OBJ_LABEL,0,0,0);
   ObjectSetText("logo","when-money-makes-money.com",20);
   ObjectSet("logo",OBJPROP_XDISTANCE,0);
   ObjectSet("logo",OBJPROP_YDISTANCE,30);
  
  
  
   w = 2*pi/RainbowPeriod;
	beta = (1 - MathCos(w))/(MathPow(1.414,2.0/GaussianOrder) - 1);
	alfa = -beta + MathSqrt(beta*beta + 2*beta);
	
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,rb1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,rb2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,rb3);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,rb4);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,rb5);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,rb6);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,rb7);
   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7,rb8);
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
int start()
  {
   static int currc=0;
   ObjectSet("logo",OBJPROP_COLOR,lc[currc]);
   currc++;
   if(currc>=ArraySize(lc))currc=0;
  
   int    counted_bars=IndicatorCounted();
//----
   
   int limit=Bars-counted_bars-1;
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   if(counted_bars==0) limit-=1+4;
   for(int i=limit;i>=0;i--){
   switch(GaussianOrder){
      case 1:{
         rb1[i] = alfa*Close[i] + (1-alfa)*rb1[i+1]; 
         break;     
      }
      case 2:{
         rb1[i] = MathPow(alfa,2)*Close[i] + 2*(1-alfa)*rb1[i+1] -   MathPow(1-alfa,2)*rb1[i+2];
         break;
      }
      case 3:{
		    rb1[i] = MathPow(alfa,3)*Close[i] + 3*(1-alfa)*rb1[i+1] - 3*MathPow(1-alfa,2)*rb1[i+2] + MathPow(1-alfa,3)*rb1[i+3];
         break;
      }
      case 4:{
		    rb1[i] = MathPow(alfa,4)*Close[i] + 4*(1-alfa)*rb1[i+1] - 6*MathPow(1-alfa,2)*rb1[i+2] + 4*MathPow(1-alfa,3)*rb1[i+3] - MathPow(1-alfa,4)*rb1[i+4];
         break;
      }            
   }
    
   }

   for(i=limit;i>=0;i--){
   switch(GaussianOrder){
      case 1:{
         rb2[i] = alfa*rb1[i] + (1-alfa)*rb2[i+1]; 
         break;     
      }
      case 2:{
         rb2[i] = MathPow(alfa,2)*rb1[i] + 2*(1-alfa)*rb2[i+1] -   MathPow(1-alfa,2)*rb2[i+2];
         break;
      }
      case 3:{
		    rb2[i] = MathPow(alfa,3)*rb1[i] + 3*(1-alfa)*rb2[i+1] - 3*MathPow(1-alfa,2)*rb2[i+2] + MathPow(1-alfa,3)*rb2[i+3];
         break;
      }
      case 4:{
		    rb2[i] = MathPow(alfa,4)*rb1[i] + 4*(1-alfa)*rb2[i+1] - 6*MathPow(1-alfa,2)*rb2[i+2] + 4*MathPow(1-alfa,3)*rb2[i+3] - MathPow(1-alfa,4)*rb2[i+4];
         break;
      }            
   }
    
   }

 for(i=limit;i>=0;i--){
   switch(GaussianOrder){
      case 1:{
         rb3[i] = alfa*rb2[i] + (1-alfa)*rb3[i+1]; 
         break;     
      }
      case 2:{
         rb3[i] = MathPow(alfa,2)*rb2[i] + 2*(1-alfa)*rb3[i+1] -   MathPow(1-alfa,2)*rb3[i+2];
         break;
      }
      case 3:{
		    rb3[i] = MathPow(alfa,3)*rb2[i] + 3*(1-alfa)*rb3[i+1] - 3*MathPow(1-alfa,2)*rb3[i+2] + MathPow(1-alfa,3)*rb3[i+3];
         break;
      }
      case 4:{
		    rb3[i] = MathPow(alfa,4)*rb2[i] + 4*(1-alfa)*rb3[i+1] - 6*MathPow(1-alfa,2)*rb3[i+2] + 4*MathPow(1-alfa,3)*rb3[i+3] - MathPow(1-alfa,4)*rb3[i+4];
         break;
      }            
   }
    
   }

 for(i=limit;i>=0;i--){
   switch(GaussianOrder){
      case 1:{
         rb4[i] = alfa*rb3[i] + (1-alfa)*rb4[i+1]; 
         break;     
      }
      case 2:{
         rb4[i] = MathPow(alfa,2)*rb3[i] + 2*(1-alfa)*rb4[i+1] -   MathPow(1-alfa,2)*rb4[i+2];
         break;
      }
      case 3:{
		    rb4[i] = MathPow(alfa,3)*rb3[i] + 3*(1-alfa)*rb4[i+1] - 3*MathPow(1-alfa,2)*rb4[i+2] + MathPow(1-alfa,3)*rb4[i+3];
         break;
      }
      case 4:{
		    rb4[i] = MathPow(alfa,4)*rb3[i] + 4*(1-alfa)*rb4[i+1] - 6*MathPow(1-alfa,2)*rb4[i+2] + 4*MathPow(1-alfa,3)*rb4[i+3] - MathPow(1-alfa,4)*rb4[i+4];
         break;
      }            
   }
    
   }

for(i=limit;i>=0;i--){
   switch(GaussianOrder){
      case 1:{
         rb5[i] = alfa*rb4[i] + (1-alfa)*rb5[i+1]; 
         break;     
      }
      case 2:{
         rb5[i] = MathPow(alfa,2)*rb4[i] + 2*(1-alfa)*rb5[i+1] -   MathPow(1-alfa,2)*rb5[i+2];
         break;
      }
      case 3:{
		    rb5[i] = MathPow(alfa,3)*rb4[i] + 3*(1-alfa)*rb5[i+1] - 3*MathPow(1-alfa,2)*rb5[i+2] + MathPow(1-alfa,3)*rb5[i+3];
         break;
      }
      case 4:{
		    rb5[i] = MathPow(alfa,4)*rb4[i] + 4*(1-alfa)*rb5[i+1] - 6*MathPow(1-alfa,2)*rb5[i+2] + 4*MathPow(1-alfa,3)*rb5[i+3] - MathPow(1-alfa,4)*rb5[i+4];
         break;
      }            
   }
    
   }


for(i=limit;i>=0;i--){
   switch(GaussianOrder){
      case 1:{
         rb6[i] = alfa*rb5[i] + (1-alfa)*rb6[i+1]; 
         break;     
      }
      case 2:{
         rb6[i] = MathPow(alfa,2)*rb5[i] + 2*(1-alfa)*rb6[i+1] -   MathPow(1-alfa,2)*rb6[i+2];
         break;
      }
      case 3:{
		    rb6[i] = MathPow(alfa,3)*rb5[i] + 3*(1-alfa)*rb6[i+1] - 3*MathPow(1-alfa,2)*rb6[i+2] + MathPow(1-alfa,3)*rb6[i+3];
         break;
      }
      case 4:{
		    rb6[i] = MathPow(alfa,4)*rb5[i] + 4*(1-alfa)*rb6[i+1] - 6*MathPow(1-alfa,2)*rb6[i+2] + 4*MathPow(1-alfa,3)*rb6[i+3] - MathPow(1-alfa,4)*rb6[i+4];
         break;
      }            
   }
    
   }


for(i=limit;i>=0;i--){
   switch(GaussianOrder){
      case 1:{
         rb7[i] = alfa*rb6[i] + (1-alfa)*rb7[i+1]; 
         break;     
      }
      case 2:{
         rb7[i] = MathPow(alfa,2)*rb6[i] + 2*(1-alfa)*rb7[i+1] -   MathPow(1-alfa,2)*rb7[i+2];
         break;
      }
      case 3:{
		    rb7[i] = MathPow(alfa,3)*rb6[i] + 3*(1-alfa)*rb7[i+1] - 3*MathPow(1-alfa,2)*rb7[i+2] + MathPow(1-alfa,3)*rb7[i+3];
         break;
      }
      case 4:{
		    rb7[i] = MathPow(alfa,4)*rb6[i] + 4*(1-alfa)*rb7[i+1] - 6*MathPow(1-alfa,2)*rb7[i+2] + 4*MathPow(1-alfa,3)*rb7[i+3] - MathPow(1-alfa,4)*rb7[i+4];
         break;
      }            
   }
 }  
   for(i=limit;i>=0;i--){
   switch(GaussianOrder){
      case 1:{
         rb8[i] = alfa*rb7[i] + (1-alfa)*rb8[i+1]; 
         break;     
      }
      case 2:{
         rb8[i] = MathPow(alfa,2)*rb7[i] + 2*(1-alfa)*rb8[i+1] -   MathPow(1-alfa,2)*rb8[i+2];
         break;
      }
      case 3:{
		    rb8[i] = MathPow(alfa,3)*rb7[i] + 3*(1-alfa)*rb8[i+1] - 3*MathPow(1-alfa,2)*rb8[i+2] + MathPow(1-alfa,3)*rb8[i+3];
         break;
      }
      case 4:{
		    rb8[i] = MathPow(alfa,4)*rb7[i] + 4*(1-alfa)*rb8[i+1] - 6*MathPow(1-alfa,2)*rb8[i+2] + 4*MathPow(1-alfa,3)*rb8[i+3] - MathPow(1-alfa,4)*rb8[i+4];
         break;
      }            
   }
    
   }
   


//----
   return(0);
  }
//+------------------------------------------------------------------+