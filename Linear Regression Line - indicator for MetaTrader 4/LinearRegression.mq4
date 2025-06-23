//////////////////////////////////////////////////////////////////////
//
//                                                LinearRegression.mq4
//                                       Copyright © 2008 Antonuk Oleg 
//
//////////////////////////////////////////////////////////////////////
#property copyright "Copyright © 2008 Antonuk Oleg"
#property link      "antonukoleg@gmail.com"
#property indicator_chart_window

#property indicator_buffers 1
#property indicator_width1 1
#property indicator_color1 Gold

extern int barsToCount=50;

double buffer0[];

//////////////////////////////////////////////////////////////////////
int init()
{
   IndicatorShortName("linearRegression");
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,buffer0);
   SetIndexEmptyValue(0,0.0);
   return(0);
}

//////////////////////////////////////////////////////////////////////
int deinit()
{  
   return(0);
}

//////////////////////////////////////////////////////////////////////
int start()
{
   // calculate price values
   double a,b,c,
          sumy=0.0,
          sumx=0.0,
          sumxy=0.0,
          sumx2=0.0;
   
   for(int i=0; i<barsToCount; i++)
   {
      sumy+=Close[i];
      sumxy+=Close[i]*i;
      sumx+=i;
      sumx2+=i*i;
   }
   
   c=sumx2*barsToCount-sumx*sumx;
   
   if(c==0.0)
   {
      Alert("LinearRegression error: can\'t resolve equation");
      return;
   }
      
   b=(sumxy*barsToCount-sumx*sumy)/c;
   a=(sumy-sumx*b)/barsToCount;
   
   // drawing Linear regression trendline in indicator buffer
   for(int x=0;x<barsToCount;x++)
      buffer0[x]=a+b*x;
   
   // clear last bar
   buffer0[x]=0.0;

   return(0);
}

