//+------------------------------------------------------------------+
//|                                 BW Market Facilitation Index.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 5
#property indicator_color1  Black
#property indicator_color2  Lime
#property indicator_color3  SaddleBrown
#property indicator_color4  Blue
#property indicator_color5  Pink
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
//---- indicator buffers
double ExtMFIBuffer[];
double ExtMFIUpVUpBuffer[];
double ExtMFIDownVDownBuffer[];
double ExtMFIUpVDownBuffer[];
double ExtMFIDownVUpBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMFIBuffer);       
   SetIndexBuffer(1,ExtMFIUpVUpBuffer);
   SetIndexBuffer(2,ExtMFIDownVDownBuffer);
   SetIndexBuffer(3,ExtMFIUpVDownBuffer);
   SetIndexBuffer(4,ExtMFIDownVUpBuffer);
//---- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexStyle(4,DRAW_HISTOGRAM);   
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("BW MFI");
   SetIndexLabel(0,"BW MFI");      
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
   SetIndexLabel(4,NULL);
//---- sets drawing line empty value
   SetIndexEmptyValue(0, 0.0);
   SetIndexEmptyValue(1, 0.0);
   SetIndexEmptyValue(2, 0.0);       
   SetIndexEmptyValue(3, 0.0);
   SetIndexEmptyValue(4, 0.0);      
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| BW Market Facilitation Index                                     |
//+------------------------------------------------------------------+
int start()
  {
   int  i,nLimit,nCountedBars;
   bool bMfiUp=true,bVolUp=true;
//---- bars count that does not changed after last indicator launch.
   nCountedBars=IndicatorCounted();
//---- last counted bar will be recounted
   if(nCountedBars>0) nCountedBars--;
   nLimit=Bars-nCountedBars;
//---- Market Facilitation Index calculation
   for(i=0; i<nLimit; i++)
     {
      if(CompareDouble(Volume[i],0.0))
        {
         Print(Volume[i]);
         if(i==Bars-1) ExtMFIBuffer[i]=0.0;
         else ExtMFIBuffer[i]=ExtMFIBuffer[i+1];
        }
      else ExtMFIBuffer[i]=(High[i]-Low[i])/(Volume[i]*Point);
     }
//---- upanddown flags setting
   if(nCountedBars>1)
     {
      //---- analyze previous bar before recounted bar
      i=nLimit+1;
      if(ExtMFIUpVUpBuffer[i]!=0.0)
        {
         bMfiUp=true;
         bVolUp=true;
        }
      if(ExtMFIDownVDownBuffer[i]!=0.0)
        {
         bMfiUp=false;
         bVolUp=false;
        }
      if(ExtMFIUpVDownBuffer[i]!=0.0)
        {
         bMfiUp=true;
         bVolUp=false;
        }
      if(ExtMFIDownVUpBuffer[i]!=0.0)
        {
         bMfiUp=false;
         bVolUp=true;
        }
     }
//---- dispatch values between 4 buffers
   for(i=nLimit-1; i>=0; i--)
     {
      if(i<Bars-1)
        {
         if(ExtMFIBuffer[i]>ExtMFIBuffer[i+1]) bMfiUp=true;
         if(ExtMFIBuffer[i]<ExtMFIBuffer[i+1]) bMfiUp=false;
         if(Volume[i]>Volume[i+1])             bVolUp=true;
         if(Volume[i]<Volume[i+1])             bVolUp=false;
        }
     if(bMfiUp && bVolUp)
       {
        ExtMFIUpVUpBuffer[i]=ExtMFIBuffer[i];
        ExtMFIDownVDownBuffer[i]=0.0;
        ExtMFIUpVDownBuffer[i]=0.0;
        ExtMFIDownVUpBuffer[i]=0.0;
        continue;
       }
     if(!bMfiUp && !bVolUp)
       {
        ExtMFIUpVUpBuffer[i]=0.0;
        ExtMFIDownVDownBuffer[i]=ExtMFIBuffer[i];
        ExtMFIUpVDownBuffer[i]=0.0;
        ExtMFIDownVUpBuffer[i]=0.0;
        continue;         
       }
     if(bMfiUp && !bVolUp)
       {
        ExtMFIUpVUpBuffer[i]=0.0;
        ExtMFIDownVDownBuffer[i]=0.0;
        ExtMFIUpVDownBuffer[i]=ExtMFIBuffer[i];
        ExtMFIDownVUpBuffer[i]=0.0;
        continue;         
       }
     if(!bMfiUp && bVolUp)
       {
        ExtMFIUpVUpBuffer[i]=0.0;
        ExtMFIDownVDownBuffer[i]=0.0;
        ExtMFIUpVDownBuffer[i]=0.0;
        ExtMFIDownVUpBuffer[i]=ExtMFIBuffer[i];
        continue;         
       }        
    }                     
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CompareDouble(double dNumber1, double dNumber2)
  {
   bool bCompare=NormalizeDouble(dNumber1-dNumber2,8) == 0;
   return(bCompare);
  }
//+------------------------------------------------------------------+