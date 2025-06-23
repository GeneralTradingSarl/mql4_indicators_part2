//+------------------------------------------------------------------+
//|                                                        Gator.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"
//********************************************************************
// Attention! Following correlations must abide:
// 1.ExtJawsPeriod>ExtTeethPeriod>ExtLipsPeriod;
// 2.ExtJawsShift>ExtTeethShift>ExtLipsShift;
// 3.ExtJawsPeriod>ExtJawsShift;
// 4.ExtTeethPeriod>ExtTeethShift;
// 5.ExtLipsPeriod>ExtLipsShift.
//********************************************************************
//---- indicator settings
#property  indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Black
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Black
#property indicator_color5 Red
#property indicator_color6 Green
//---- input parameters
extern int ExtJawsPeriod=13;
extern int ExtJawsShift=8;
extern int ExtTeethPeriod=8;
extern int ExtTeethShift=5;
extern int ExtLipsPeriod=5;
extern int ExtLipsShift=3;
extern int ExtMAMethod=2;
extern int ExtAppliedPrice=PRICE_MEDIAN;
//---- indicator buffers
double ExtUpBuffer[];
double ExtUpRedBuffer[];
double ExtUpGreenBuffer[];
double ExtDownBuffer[];
double ExtDownRedBuffer[];
double ExtDownGreenBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtUpBuffer);
   SetIndexBuffer(1,ExtUpRedBuffer);
   SetIndexBuffer(2,ExtUpGreenBuffer);
   SetIndexBuffer(3,ExtDownBuffer);
   SetIndexBuffer(4,ExtDownRedBuffer);
   SetIndexBuffer(5,ExtDownGreenBuffer);
//----
   IndicatorDigits(Digits+1);
//---- sets first bar from what index will be drawn
   SetIndexDrawBegin(1,ExtJawsPeriod+ExtJawsShift-ExtTeethShift);
   SetIndexDrawBegin(2,ExtJawsPeriod+ExtJawsShift-ExtTeethShift);
   SetIndexDrawBegin(4,ExtTeethPeriod+ExtTeethShift-ExtLipsShift);
   SetIndexDrawBegin(5,ExtTeethPeriod+ExtTeethShift-ExtLipsShift);
//---- line shifts when drawing
   SetIndexShift(0,ExtTeethShift);
   SetIndexShift(1,ExtTeethShift);
   SetIndexShift(2,ExtTeethShift);
   SetIndexShift(3,ExtLipsShift);
   SetIndexShift(4,ExtLipsShift);
   SetIndexShift(5,ExtLipsShift);
//---- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexStyle(5,DRAW_HISTOGRAM);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Gator("+ExtJawsPeriod+","+ExtTeethPeriod+","+ExtLipsPeriod+")");
   SetIndexLabel(0,"GatorUp");
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,"GatorDown");
   SetIndexLabel(4,NULL);
   SetIndexLabel(5,NULL);
//---- sets drawing line empty value
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(5,0.0);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Gator Oscillator                                                 |
//+------------------------------------------------------------------+
int start()
  {
   int    i,nLimit;
   double dPrev,dCurrent; 
//---- bars count that does not changed after last indicator launch.
   int    nCountedBars=IndicatorCounted();
//---- last counted bar will be recounted
   if(nCountedBars<=ExtTeethPeriod+ExtTeethShift-ExtLipsShift)
      nLimit=Bars-(ExtTeethPeriod+ExtTeethShift-ExtLipsShift);
   else
      nLimit=Bars-nCountedBars-1;
//---- moving averages absolute difference
   for(i=0; i<nLimit+1; i++)
     {
      dCurrent=iMA(NULL,0,ExtTeethPeriod,ExtTeethShift-ExtLipsShift,ExtMAMethod,ExtAppliedPrice,i)-
               iMA(NULL,0,ExtLipsPeriod,0,ExtMAMethod,ExtAppliedPrice,i);
      if(dCurrent<=0.0) ExtDownBuffer[i]=dCurrent;
      else              ExtDownBuffer[i]=-dCurrent;
     }
//---- dispatch values between 2 lower buffers
   for(i=nLimit-1; i>=0; i--)
     {
      dPrev=ExtDownBuffer[i+1];
      dCurrent=ExtDownBuffer[i];
      if(dCurrent<dPrev) 
        {
         ExtDownRedBuffer[i]=0.0;
         ExtDownGreenBuffer[i]=dCurrent;
        }
      if(dCurrent>dPrev)
        {
         ExtDownRedBuffer[i]=dCurrent;
         ExtDownGreenBuffer[i]=0.0;
        }
      //---- arbitrage
      if(dCurrent==dPrev)
        {
         if(ExtDownRedBuffer[i+1]<0.0) ExtDownRedBuffer[i]=dCurrent;
         else                          ExtDownGreenBuffer[i]=dCurrent;
        }
     }
//---- last counted bar will be recounted
   if(nCountedBars<=ExtJawsPeriod+ExtJawsShift-ExtTeethShift)
      nLimit=Bars-(ExtJawsPeriod+ExtJawsShift-ExtTeethShift);
   else
      nLimit=Bars-nCountedBars-1;
//---- moving averages absolute difference
   for(i=0; i<nLimit+1; i++)
     {
      dCurrent=iMA(NULL,0,ExtJawsPeriod,ExtJawsShift-ExtTeethShift,ExtMAMethod,ExtAppliedPrice,i)-
                   iMA(NULL,0,ExtTeethPeriod,0,ExtMAMethod,ExtAppliedPrice,i);
      if(dCurrent>=0.0) ExtUpBuffer[i]=dCurrent;
      else              ExtUpBuffer[i]=-dCurrent;
     }
//---- dispatch values between 2 upper buffers
   for(i=nLimit-1; i>=0; i--)
     {
      dPrev=ExtUpBuffer[i+1];
      dCurrent=ExtUpBuffer[i];
      if(dCurrent>dPrev) 
        {
         ExtUpRedBuffer[i]=0.0;
         ExtUpGreenBuffer[i]=dCurrent;
        }
      if(dCurrent<dPrev) 
        {
         ExtUpRedBuffer[i]=dCurrent;
         ExtUpGreenBuffer[i]=0.0;
        }
      //---- arbitrage
      if(dCurrent==dPrev)
        {
         if(ExtUpGreenBuffer[i+1]>0.0) ExtUpGreenBuffer[i]=dCurrent;
         else                          ExtUpRedBuffer[i]=dCurrent;
        }
     }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+

