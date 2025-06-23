//+------------------------------------------------------------------+
//|                                      Cronex Impulse CD Color.mq4 |
//|                                        Copyright © 2007, Cronex. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2008, Cronex"
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  SteelBlue
#property  indicator_color2  DarkOrange
#property  indicator_color3  Green
#property  indicator_color4  Red
//---- indicator parameters
extern int SlowMA=34;
extern int FastMA=14;
extern int SignalMA=9;
//---- indicator buffers

double     MacdDivrBuffer[];
double     SignalBuffer[];
double     CDDivrBuffUP[];
double     CDDivrBuffDN[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
  //---- indicator buffers mapping
   SetIndexBuffer(0,MacdDivrBuffer);
   SetIndexBuffer(1,SignalBuffer);  
   SetIndexBuffer(2,CDDivrBuffUP);
   SetIndexBuffer(3,CDDivrBuffDN);      
//---- drawing settings
 
   SetIndexStyle(0,DRAW_HISTOGRAM);   
   SetIndexStyle(1,DRAW_LINE); 
   SetIndexStyle(2,DRAW_HISTOGRAM);     
   SetIndexStyle(3,DRAW_HISTOGRAM);   
   
   SetIndexEmptyValue(0,0) ;
   SetIndexEmptyValue(1,0) ;
   SetIndexEmptyValue(2,0) ;   
   SetIndexEmptyValue(3,0) ;   
   IndicatorDigits(Digits);

//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Cronex Impulse CD("+SlowMA+","+FastMA+","+SignalMA+")");
   SetIndexLabel(0,"Impulse MACD");
   SetIndexLabel(1,"Signal");
   SetIndexLabel(2,"Impulse CD");  
   SetIndexLabel(3,"Impulse CD");     
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   double HiInd,LoInd,MasterInd,CDDivr;
//---- last counted bar will be recounted
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+1;
   
//---- macd counted in the 1-st buffer
   for(int i=0; i<limit; i++)
    {
     HiInd=iMA(NULL,0,SlowMA,0,MODE_SMMA,PRICE_HIGH,i);
     LoInd=iMA(NULL,0,SlowMA,0,MODE_SMMA,PRICE_LOW,i);
     MasterInd=iMA(NULL,0,FastMA,0,MODE_LWMA,PRICE_WEIGHTED,i);

     if(MasterInd>HiInd)
      MacdDivrBuffer[i]=MasterInd-HiInd;
      
     if(MasterInd<LoInd)
      MacdDivrBuffer[i]=MasterInd-LoInd;  
    }
//---- signal line counted in the 2-nd buffer
   for(i=0; i<limit; i++)
       SignalBuffer[i]=iMAOnArray(MacdDivrBuffer,0,SignalMA,0,MODE_SMA,i);
       
   for(i=0; i<limit; i++)
      {
       if((MacdDivrBuffer[i]-SignalBuffer[i])> (MacdDivrBuffer[i+1]-SignalBuffer[i+1]))CDDivrBuffUP[i]=MacdDivrBuffer[i]-SignalBuffer[i];
       if((MacdDivrBuffer[i]-SignalBuffer[i])< (MacdDivrBuffer[i+1]-SignalBuffer[i+1]))CDDivrBuffDN[i]=MacdDivrBuffer[i]-SignalBuffer[i];
      }

//---- done
   return(0);
  }
//+------------------------------------------------------------------+