/*=============================================== H E A D E R ==============================================
                                 Pavol Krizan | paulie.sk@gmail.com 
                                 
EN  = Please if anyone modifying and improves file, send to me on my email thank you !!!                                          
SVK = Prosím ak niekto upravuj alebo vylepšuje tento súbor, predošlite mi to na môj email dakujem !!!
   
/*=========================================== H E A D E R  E N D ===========================================*/
#property copyright "ForF"
#property link      "http://www.forf.eu/"
#property version   "1.01" 

/*==========================================================================================================*/

#property  indicator_separate_window
//+------------------------------------------------------------------+
#property  indicator_level1      50
#property  indicator_level2      35
#property  indicator_level3      65
#property  indicator_levelcolor  Silver
#property  indicator_levelstyle  0
//+------------------------------------------------------------------+
#property  indicator_buffers     3
#property  indicator_color1      Gold
#property  indicator_color2      DeepSkyBlue
#property  indicator_color3      White
//+------------------------------------------------------------------+
#property  indicator_width1      1
#property  indicator_width2      1
#property  indicator_width3      1
//+------------------------------------------------------------------+
extern string Symobol_1="GOLD";
extern string Symobol_2="SILVER";
extern int    period           = 14;

double     MacdBuffer1[];
double     MacdBuffer2[];
double     MacdBuffer3[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE,0,2);

//---- indicator buffers mapping
   SetIndexBuffer(0,MacdBuffer1);
   SetIndexBuffer(1,MacdBuffer2);
   SetIndexBuffer(2,MacdBuffer3);

   IndicatorShortName("RSI_Gold_Silver");
   
   SetIndexLabel(0,"GOLD");
   SetIndexLabel(1,"SILVER"); 
   SetIndexLabel(2,"Typical"); 
   
 
   return(0);
  }
//+------------------------------------------------------------------+
// Signal indicator                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
   int i;
     
//====================================================         
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//====================================================   
   for(i=0; i<limit; i++)
      MacdBuffer1[i]=iRSI(Symobol_1,0,period,PRICE_TYPICAL,i);
   
   for(i=0; i<limit; i++)
      MacdBuffer2[i]=iRSI(Symobol_2,0,period,PRICE_TYPICAL,i); 
              
   for(i=0; i<limit; i++)
      MacdBuffer3[i]=
       ((
       MacdBuffer1[i]+MacdBuffer2[i]
        )/2);
        
//====================================================   
     return(0);
}
//+------------------------------------------------------------------+
