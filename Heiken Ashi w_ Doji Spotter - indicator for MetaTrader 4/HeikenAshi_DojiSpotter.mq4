//+------------------------------------------------------------------+
//|                                       HeikenAshi_DojiSpotter.mq4 |
//|                      Copyright c 2004, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                           Modified by: Tim Welch |
//+------------------------------------------------------------------+
//| For Heiken Ashi we recommend next chart settings ( press F8 or   |
//| select on menu 'Charts'->'Properties...'):                       |
//|  - On 'Color' Tab select 'Black' for 'Line Graph'                |
//|  - On 'Common' Tab disable 'Chart on Foreground' checkbox and    |
//|    select 'Line Chart' radiobutton                               |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp. - Modified by Tim Welch"
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 White
#property indicator_color3 Red
#property indicator_color4 White
#property indicator_color5 Yellow
#property indicator_color6 Yellow
#property indicator_color7 Yellow
#property indicator_color8 Yellow
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 3
#property indicator_width6 3
#property indicator_width7 1
#property indicator_width8 1


//----

extern string  noteSpotDojis  = "If this is true, color the Doji differently";
extern bool    spotDojis      = true;
extern string  note1DojiLevel = "If the body of the Heiken-Ashi candle is";
extern string  note2DojiLevel = "<= THIS percent of the candles range"; 
extern double  DojiLevel      = 10;

// Normal Color
extern color color1 = Red;
extern color color2 = White;
extern color color3 = Red;
extern color color4 = White;
// Doji Color
extern color color5 = Yellow;
extern color color6 = Yellow;
extern color color7 = Yellow;
extern color color8 = Yellow;


//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];

//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM, 0, 1, color1);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM, 0, 1, color2);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM, 0, 3, color3);
   SetIndexBuffer(2, ExtMapBuffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM, 0, 3, color4);
   SetIndexBuffer(3, ExtMapBuffer4);
   SetIndexStyle(4,DRAW_HISTOGRAM, 0, 3, color5);
   SetIndexBuffer(4, ExtMapBuffer5);
   SetIndexStyle(5,DRAW_HISTOGRAM, 0, 3, color6);
   SetIndexBuffer(5, ExtMapBuffer6);
   SetIndexStyle(6,DRAW_HISTOGRAM, 0, 1, color7);
   SetIndexBuffer(6, ExtMapBuffer7);
   SetIndexStyle(7,DRAW_HISTOGRAM, 0, 1, color8);
   SetIndexBuffer(7, ExtMapBuffer8);
//----
   SetIndexDrawBegin(0,10);
   SetIndexDrawBegin(1,10);
   SetIndexDrawBegin(2,10);
   SetIndexDrawBegin(3,10);
   SetIndexDrawBegin(4,10);
   SetIndexDrawBegin(5,10);
   SetIndexDrawBegin(6,10);
   SetIndexDrawBegin(7,10);
//   SetIndexDrawBegin(4,10);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexBuffer(7,ExtMapBuffer8);
   
   SetIndexEmptyValue(4,EMPTY_VALUE);
   SetIndexEmptyValue(5,EMPTY_VALUE);
   SetIndexEmptyValue(6,EMPTY_VALUE);
   SetIndexEmptyValue(7,EMPTY_VALUE);
   
   if (DojiLevel < 0) { DojiLevel = 10; }
   
   
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
  
//+------------------------------------------------------------------+
bool NewBar()
{
   static datetime lastbar;
   datetime curbar = Time[0];
   if(lastbar!=curbar)
   {
      lastbar=curbar;
      return (true);
   }
   else
   {
      return(false);
   }
}  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double haOpen, haHigh, haLow, haClose;
   if(Bars<=10) return(0);          
        
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
   int pos=Bars-ExtCountedBars-1;
   if(ExtCountedBars==0) pos-=1+1;
   while(pos>=0)
     {
         if ( ExtMapBuffer5[pos+1] != EMPTY_VALUE && spotDojis ) {
            haOpen=(ExtMapBuffer5[pos+1]+ExtMapBuffer6[pos+1])/2;
         } else {
            haOpen=(ExtMapBuffer3[pos+1]+ExtMapBuffer4[pos+1])/2;
         }
         haClose=(Open[pos]+High[pos]+Low[pos]+Close[pos])/4;
         haHigh=MathMax(High[pos], MathMax(haOpen, haClose));
         haLow=MathMin(Low[pos], MathMin(haOpen, haClose));

         if (MathAbs( (haClose-haOpen)/(haHigh-haLow)) <= (DojiLevel/100) && spotDojis) {
            if (haOpen<haClose) 
            {
               ExtMapBuffer7[pos]=haLow;
               ExtMapBuffer8[pos]=haHigh;
            } 
            else
            {
               ExtMapBuffer7[pos]=haHigh;
               ExtMapBuffer8[pos]=haLow;      
            } 
            ExtMapBuffer5[pos]=haOpen;
            ExtMapBuffer6[pos]=haClose;
         } else {
            if (haOpen<haClose) 
            {
               ExtMapBuffer1[pos]=haLow;
               ExtMapBuffer2[pos]=haHigh;
            } 
            else
            {
               ExtMapBuffer1[pos]=haHigh;
               ExtMapBuffer2[pos]=haLow;     
            } 
            ExtMapBuffer3[pos]=haOpen;
            ExtMapBuffer4[pos]=haClose;
         }
         
 	    pos--;
     }

//----
   return(0);
  }
//+------------------------------------------------------------------+