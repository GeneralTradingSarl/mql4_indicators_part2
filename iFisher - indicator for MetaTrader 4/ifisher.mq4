//+------------------------------------------------------------------+
//|                                                      iFisher.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_level1 0.0
#property indicator_color1 clrGreen
#property indicator_color2 clrYellow
#property indicator_color3 clrBlue
#property indicator_color4 clrRed
#property strict
//---- input parameters
extern int Length                = 14;//Period
extern double fsmth              = 0.67;//Smoothing
extern ENUM_APPLIED_PRICE Price  = PRICE_MEDIAN;//Price Type
//---- buffers
double Buffer[];
double BufferUP[];
double BufferDN[];
double Value [];
double Fisher[];  
string OP="";
double VAL=0.0,FS=0.0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
  IndicatorBuffers(6);
 
  SetIndexStyle(0,DRAW_NONE);
  SetIndexStyle(1,DRAW_LINE);
  SetIndexStyle(2,DRAW_LINE);
  SetIndexStyle(3,DRAW_LINE);
 
  SetIndexBuffer(0,Fisher);
  SetIndexBuffer(1,Buffer);
  SetIndexBuffer(2,BufferUP);
  SetIndexBuffer(3,BufferDN);
  SetIndexBuffer(4,Value);
 
  SetIndexLabel (0, "Fish");
 
  SetIndexDrawBegin(0,Length);
  SetIndexDrawBegin(1,Length);
  SetIndexDrawBegin(2,Length);
  SetIndexDrawBegin(3,Length);
  
  return(0);
  }


//+------------------------------------------------------------------+
//| Fisher_org_v1                                                         |
//+------------------------------------------------------------------+
int start()
  {
      IndicatorShortName ("iFisher(" + IntegerToString(Length) + ") "+"   => " + OP +" <=   ");
      
        
      
   int counted_bars=IndicatorCounted(),limit;
   
   if (counted_bars<0) return(-1);
   if (counted_bars>0) counted_bars--;
   limit=Bars-Length-1;
        
      VAL=0.0;FS=0.0;
   for(int shift=limit-1;shift>=0;shift--)
      {   
      //---
      //---         
              double smin=0.0,smax=0.0,price = P(shift);
               smax = price;
               smin = price;
              for (int i = 0; i < Length; i++) {
                  price = P(shift + i);
                  if (price > smax) smax = price;
                  if (price < smin) smin = price;
              }       
         double wpr;        
         if (smax==smin)wpr=0.0; else {wpr=(P(shift)-smin)/(smax-smin);wpr=2.0*wpr-1.0;}
         Value[shift] = fsmth*wpr + (1-fsmth)*Value[shift+1];     // smoothing
         Value[shift]=MathMin(MathMax(Value[shift],-0.999),0.999); //--in range
         if(1.0-Value[shift]!=0.0)Fisher[shift] = MathLog((1.0+Value[shift])/(1.0-Value[shift]))/2.0 + Fisher[shift+1]/2.0;
        
         Buffer[shift] =   //yellow
         BufferUP[shift]=  //blue
         BufferDN[shift]=  //red
         Fisher [shift]; 
        
         if(Fisher [shift]>Fisher [shift+1])    {BufferDN[shift]=EMPTY_VALUE;}//}
         else
         if(Fisher [shift]<Fisher [shift+1])    {BufferUP[shift]=EMPTY_VALUE;}//}
         else                                   {BufferDN[shift]=EMPTY_VALUE;BufferUP[shift]=EMPTY_VALUE;}
         //---
         //---
         //---
         //---
         if(Fisher[1]<Fisher[0] && Fisher[0]>0.0) 
         {
         OP="UP Trend";
         }
         else
           {
         if(Fisher[1]>Fisher[0] && Fisher[0]<0.0)
         {
         OP="DN Trend";
         }
         else OP="NOPE";
           }   
        
        
         }
        return(0);
  }
  double P(int index) {
   {return(iMA(Symbol(),0,1,0,MODE_SMA,Price,index));}  }

//+------------------------------------------------------------------+