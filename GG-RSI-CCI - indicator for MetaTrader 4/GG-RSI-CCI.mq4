//+------------------------------------------------------------------+
//|                                                   GG-RSI-CCI.mq4 |
//|                                         Copyright © 2009, GGekko |
//|                                         http://www.fx-ggekko.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, GGekko"
#property link      "http://www.fx-ggekko.com"

//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  YellowGreen
#property  indicator_color2  Gold
#property  indicator_color3  OrangeRed
#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width3  2
#property indicator_minimum  0
#property indicator_maximum  1.5 

//---- indicator parameters
extern string   __Copyright__          = "www.fx-ggekko.com";
extern int      Avg_Period1            = 8;
extern int      Avg_Period2            = 14;
extern int      Ind_Period             = 20;

//---- indicator buffers
double     BufferUp[];
double     BufferFlat[];
double     BufferDown[];

double     ind1[];
double     ind2[];

double     ind3[];
double     ind4[];
double     ind5[];
double     ind6[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   IndicatorBuffers(5);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   
   
//---- indicator buffers mapping
   SetIndexBuffer(0,BufferUp);
   SetIndexBuffer(1,BufferFlat);
   SetIndexBuffer(2,BufferDown);
   SetIndexBuffer(3,ind1);
   SetIndexBuffer(4,ind2);
   
   
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("GG-RSI-CCI ("+Avg_Period1+","+Avg_Period2+","+Ind_Period+") * www.fx-ggekko.com * ");
   
   
//---- initialization done
   return(0);
  }

int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- 

   ArrayResize(ind3,limit);
   ArrayResize(ind4,limit);
   ArrayResize(ind5,limit);
   ArrayResize(ind6,limit);


   for(int i=0; i<limit; i++)
      ind1[i]=iRSI(NULL,0,Ind_Period,PRICE_CLOSE,i);
      
   for(i=0; i<limit; i++)
      ind2[i]=iCCI(NULL,0,Ind_Period,PRICE_CLOSE,i);

      
   for(i=0; i<limit; i++)
      ind3[i]=iMAOnArray(ind1,0,Avg_Period1,0,MODE_SMMA,i);

   for(i=0; i<limit; i++)
      ind4[i]=iMAOnArray(ind1,0,Avg_Period2,0,MODE_SMMA,i);
      
   for(i=0; i<limit; i++)
      ind5[i]=iMAOnArray(ind2,0,Avg_Period1,0,MODE_SMMA,i);

   for(i=0; i<limit; i++)
      ind6[i]=iMAOnArray(ind2,0,Avg_Period2,0,MODE_SMMA,i);
      
   
   for(i=0; i<limit; i++)
   {   
   if(ind3[i]>ind4[i] && ind5[i]>ind6[i])
      {
      BufferUp[i]=1;
      BufferFlat[i]=EMPTY_VALUE;
      BufferDown[i]=EMPTY_VALUE;
      } 
   else if(ind3[i]<ind4[i] && ind5[i]<ind6[i])
      {
      BufferUp[i]=EMPTY_VALUE;
      BufferFlat[i]=EMPTY_VALUE;
      BufferDown[i]=1;
      }
   else
      {
      BufferUp[i]=EMPTY_VALUE;
      BufferFlat[i]=1;
      BufferDown[i]=EMPTY_VALUE;
      }
   }
      
   
//---- done
   return(0);
  }
//+------------------------------------------------------------------+