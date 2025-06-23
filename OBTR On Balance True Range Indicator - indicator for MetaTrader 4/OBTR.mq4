//+------------------------------------------------------------------+
//|                                                         OBTR.mq4 |
//|                     Copyright © 2010, www.Brooky-Indicators.com. |
//|     On Balance True Range   http://www.www.Brooky-Indicators.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, www.Brooky-Indicators.com."
#property link      "http://www.www.Brooky-Indicators.com"
extern string You_Are_Following_Another = "(www.Brooky-Indicators.com) Indicator ";

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 DodgerBlue
#property indicator_color2 Orange
#property indicator_color3 C'93,93,93'
#property indicator_color4 Blue
#property indicator_color5 C'93,93,93'
#property indicator_color6 Lime
#property indicator_color7 Red


#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 3
#property indicator_width6 3
#property indicator_width7 3
//---- input parameters
extern string OBTR_Concept_By = "Tom Bierovic";
extern string Basic_Codebase  = "Metaquotes";
extern string This_Indi_Coder = "www.Brooky-Indicators.com";
extern string Ma_Modes        = "0=sma, 1=ema, 2=smma, 3=lwma";
extern string Price_Modes     = "0=Cl, 1=Op, 2=Hi, 3=Lo";
extern string Price_Modes2    = "4=Med, 5=Typ, 6=Weight";
extern string Div1            = "--------------------------------------------";
extern string Fast_Ma         = "  Smoothing ";
extern int    Fast_MA_Period  = 1;
extern int    Fast_Mode       = 0;
extern int    Fast_Shift      = 0;
extern int    Slow_MA_Period  = 26;
extern int    Slow_Mode       = 0;
extern int    Slow_Shift      = 0;
extern string Div2            = "--------------------------------------------";
extern string Holding         = "  Ma OBTR Distance Settings ";
extern int    Proximity       = 11;
extern int    Distance_Max    = 126;
extern string OBTR_Price      = "Set Price for Calculations";
extern int    OBTR_Price_Mode =0;
//---- buffers
double         OBTRBuffer[];
double         OBTRFast_Buffer[];
double         OBTRSlow_Buffer[];
double         OBTRover_Buffer[];
double         OBTRunder_Buffer[];
double         OBTRflat_Buffer[];
double         OBTRSlowup_Buffer[];
double         OBTRSlowdn_Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string sShortName;
//---- indicator buffer mapping
   IndicatorBuffers(8);
   SetIndexBuffer(0,OBTRover_Buffer);SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,OBTRunder_Buffer);SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,OBTRflat_Buffer);SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,OBTRFast_Buffer);SetIndexStyle(3,DRAW_LINE);SetIndexDrawBegin(3,Fast_Shift);
   SetIndexBuffer(4,OBTRSlow_Buffer);SetIndexStyle(4,DRAW_LINE);SetIndexDrawBegin(4,Slow_Shift); 
   SetIndexBuffer(5,OBTRSlowup_Buffer);SetIndexStyle(5,DRAW_LINE);SetIndexDrawBegin(5,Slow_Shift);
   SetIndexBuffer(6,OBTRSlowdn_Buffer);SetIndexStyle(6,DRAW_LINE);SetIndexDrawBegin(6,Slow_Shift);  
   SetIndexBuffer(7,OBTRBuffer);
   
//---- sets default precision format for indicators visualization
   IndicatorDigits(0);     
//---- name for DataWindow and indicator subwindow label
   sShortName="Brooky_OBTR";
   IndicatorShortName(sShortName);
   SetIndexLabel(0,sShortName);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| On Balance True Range    Concept by Tom Bierovic                                            |
//+------------------------------------------------------------------+
int start()
  {
   int    i,nLimit,nCountedBars;
//---- bars count that does not changed after last indicator launch.
   nCountedBars=IndicatorCounted();
//---- last counted bar will be recounted
   if(nCountedBars>0) nCountedBars--;
   nLimit=Bars-nCountedBars-1;


   for(i=nLimit; i>=0; i--)

       
     {
     double use_point;
     if (Point==0.0001)use_point=0.0001;
     if (Point==0.00001)use_point=0.0001;
     if (Point==0.01)use_point=0.01;
     if (Point==0.001)use_point=0.01;
     
     int multiplier; 
     multiplier = 1 / use_point;

     OBTRFast_Buffer[i]=EMPTY_VALUE;
     OBTRSlow_Buffer[i]=EMPTY_VALUE;
     OBTRover_Buffer[i]=EMPTY_VALUE;
     OBTRunder_Buffer[i]=EMPTY_VALUE;
     OBTRflat_Buffer[i]=EMPTY_VALUE;

     if(i==Bars-1)
        OBTRBuffer[i]=iATR(NULL,0,1,i)*multiplier;
      else
        {
         double dCurrentPrice=GetAppliedPrice(OBTR_Price_Mode, i);
         double dPreviousPrice=GetAppliedPrice(OBTR_Price_Mode, i+1);
         if(dCurrentPrice==dPreviousPrice)
            OBTRBuffer[i]=OBTRBuffer[i+1];
         else
           {
            if(dCurrentPrice<dPreviousPrice)
               OBTRBuffer[i]=OBTRBuffer[i+1]-iATR(NULL,0,1,i)*multiplier;  
            else
               OBTRBuffer[i]=OBTRBuffer[i+1]+iATR(NULL,0,1,i)*multiplier;
           }
        }
     }
     for(i=nLimit; i>=0; i--)
     {
     
      OBTRFast_Buffer[i]=iMAOnArray(OBTRBuffer,0,Fast_MA_Period,Fast_Shift,Fast_Mode,i);
      OBTRSlow_Buffer[i]=iMAOnArray(OBTRBuffer,0,Slow_MA_Period,Slow_Shift,Slow_Mode,i);
     }
     
     for(i=nLimit; i>=0; i--)
     {
     if(OBTRSlow_Buffer[i]>OBTRSlow_Buffer[i+1])OBTRSlowup_Buffer[i]=OBTRSlow_Buffer[i];
     if(OBTRSlow_Buffer[i]<OBTRSlow_Buffer[i+1])OBTRSlowdn_Buffer[i]=OBTRSlow_Buffer[i];
     
     if(OBTRFast_Buffer[i]>OBTRSlow_Buffer[i])OBTRover_Buffer[i]=OBTRBuffer[i];
     if(OBTRFast_Buffer[i]<OBTRSlow_Buffer[i])OBTRunder_Buffer[i]=OBTRBuffer[i];
     
     
     if(OBTRFast_Buffer[i]==OBTRSlow_Buffer[i])OBTRflat_Buffer[i]=OBTRBuffer[i];
     if(MathAbs(OBTRFast_Buffer[i]-OBTRSlow_Buffer[i])<Proximity)
         OBTRflat_Buffer[i]=OBTRBuffer[i];
     if(MathAbs(OBTRFast_Buffer[i]-OBTRSlow_Buffer[i])>Distance_Max)
         OBTRflat_Buffer[i]=OBTRBuffer[i];   
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double GetAppliedPrice(int nAppliedPrice, int nIndex)
    {
      double dPrice;
//----
      switch(nAppliedPrice)
       {
         case 0:  dPrice=Close[nIndex];                                  break;
         case 1:  dPrice=Open[nIndex];                                   break;
         case 2:  dPrice=High[nIndex];                                   break;
         case 3:  dPrice=Low[nIndex];                                    break;
         case 4:  dPrice=(High[nIndex]+Low[nIndex])/2.0;                 break;
         case 5:  dPrice=(High[nIndex]+Low[nIndex]+Close[nIndex])/3.0;   break;
         case 6:  dPrice=(High[nIndex]+Low[nIndex]+2*Close[nIndex])/4.0; break;
         default: dPrice=0.0;
       }
//----
   return(dPrice);
  }
//+------------------------------------------------------------------+