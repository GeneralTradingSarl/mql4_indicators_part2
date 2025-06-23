//+------------------------------------------------------------------+
//|                                              Livelli_SR Now .mq4 |
//|                                              L'angolo del Trader |
//|                                                      PaoloNieddu |
//+------------------------------------------------------------------+

#property copyright "L'angolo del Trader"
#property link      "PaoloNieddu"
#property version   "1.00"

//---- Buffer properties
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Tomato
#property indicator_width1 1
#property indicator_width2 1

//---- Constants
#define ZZBack             1                    
#define ZZDev              5                    

//-------------------------------
// Input parameters
//-------------------------------
extern int  ZigZagFast     = 6;
extern int  ZigZagSlow     = 24;

//-------------------------------
// Buffers
//-------------------------------
double v1[];
double v2[];
double middle[];

//-------------------------------
//Variabili interne
//-------------------------------

// Memorizza i valori dello ZigZag
double zz_slow_high = 0;
double zz_slow_low = 0;
double zz_fast_high = 0;
double zz_fast_low = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   // Buffers
   IndicatorBuffers(2);
   SetIndexArrow(0, 158); SetIndexStyle(0, DRAW_ARROW, STYLE_DOT);            //158,159,108 sono i nuneri aschi per settare lo spessore dei pallini; piccolo,medio,grande 
   SetIndexBuffer(0, v1);                                                      // 167,110 per settare i quadrati piccolo e grande
   SetIndexLabel(0,"Resistenza");
   SetIndexArrow(1, 158); SetIndexStyle(1, DRAW_ARROW, STYLE_DOT);
   SetIndexBuffer(1, v2);
   SetIndexLabel(1,"Supporto");
   
   
   IndicatorShortName("Livelli_SR Now");
   Comment(""+"\n"+
   
   
           "Copyright ©2015 L'Angolo Del Trading"+"\n"
           "____________________________________" +"\n"
           "Ultimo Massimo :     "+ v1[1] +"\n"+
           "......................................."+"\n"+
           "Ultimo Minimo  :     "+v2[1]+"\n"+
           "___________________________________"+"\n"
   );
   
   // 
   return(0); 
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   // Start, limit, etc..
   int start = 1;
   int limit;
   int counted_bars = IndicatorCounted();

   //
   if(counted_bars < 0) 
       return(-1);

   // non controllare le  barre che si  ripetono
   limit = Bars - 1 - counted_bars;
    
   // Scorri dal passato al presente
   for(int i = limit; i >= start; i--)
   {
      // ultimo Frattale
      double val1 = upper_fractal(i);
      double val2 = lower_fractal(i);
      
      // Valori zigzag lenti
      double zz_slow_high_t = iCustom(Symbol(), 0, "ZigZag", ZigZagSlow, ZZDev, ZZBack, 1, i);
      if(zz_slow_high_t != 0) zz_slow_high = zz_slow_high_t;
        
      // Zig Zag low
      double zz_slow_low_t  = iCustom(Symbol(), 0, "ZigZag", ZigZagSlow, ZZDev, ZZBack, 2, i);
      if(zz_slow_low_t != 0) zz_slow_low = zz_slow_low_t;
      
      //Valori zigzag Slow 
      double zz_fast_high_t = iCustom(Symbol(), 0, "ZigZag", ZigZagFast, ZZDev, ZZBack, 1, i);
      if(zz_fast_high_t != 0) zz_fast_high = zz_fast_high_t;
        
      // Zig Zag low
      double zz_fast_low_t  = iCustom(Symbol(), 0, "ZigZag", ZigZagFast, ZZDev, ZZBack, 2, i);
      if(zz_fast_low_t != 0) zz_fast_low = zz_fast_low_t;
      
      // Fracttali alti
      if (val1 > 0 && (val1 == zz_slow_high || val1 == zz_fast_high)) 
      {
         v1[i]   = val1;
         v1[i+1] = val1;
         v1[i+2] = val1;
      } else {
         v1[i] = v1[i+1];
      }
    
      // Fracttali bassi
      if (val2 > 0 && (val2 == zz_slow_low || val2 == zz_fast_low)) 
      {
         v2[i]   = val2;
         v2[i+1] = val2;
         v2[i+2] = val2;
      } else {
         v2[i] = v2[i+1];
      }  
      
      // Salva i medi
      middle[i] = (v1[i] + v2[i]) / 2;
   }
   return(0);
}
  
double upper_fractal(int shift = 1)
{
   double middle = iHigh(Symbol(), 0, shift + 2);
   double v1 = iHigh(Symbol(), 0, shift);
   double v2 = iHigh(Symbol(), 0, shift+1);
   double v3 = iHigh(Symbol(), 0, shift + 3);
   double v4 = iHigh(Symbol(), 0, shift + 4);
   if(middle > v1 && 
      middle > v2 && 
      middle > v3 && 
      middle > v4
      
      )
   {
      return(middle);
   }
   return(0);
}
double lower_fractal(int shift = 1)
{
   double middle = iLow(Symbol(), 0, shift + 2);
   double v1 = iLow(Symbol(), 0, shift);
   double v2 = iLow(Symbol(), 0, shift+1);
   double v3 = iLow(Symbol(), 0, shift + 3);
   double v4 = iLow(Symbol(), 0, shift + 4);
   if(middle < v1 && 
      middle < v2 && 
      middle < v3 && 
      middle < v4)
   {
      return(middle);
   }
   return(0);
}