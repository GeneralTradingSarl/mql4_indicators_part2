//+------------------------------------------------------------------+
//|                              GSV - Greatest Swing Value MTF.mq4  |
//| MT4 code by Max Michael 2021                                     |
//+------------------------------------------------------------------+
#property description "Larry Williams 'Greatest Swing Value' "
#property description "This price action calculation is from Larry's book"
#property description "Long-Term Secrets to Short-Term Trading"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrBlue
#property indicator_type1  DRAW_LINE 
#property indicator_width1 1
#property indicator_color2 clrRed
#property indicator_type2  DRAW_LINE
#property indicator_width2 1
#property strict

extern int                Length = 4;
extern double         Multiplier = 2.4;
extern ENUM_TIMEFRAMES TimeFrame = PERIOD_D1; // MultiTimeframe (set to Current for normal operation)
extern int               MaxBars = 1000;

int    updatebars;

double Buffer0[];
double Buffer1[];

int init()
{
   SetIndexBuffer(0,Buffer0,INDICATOR_DATA);
   SetIndexBuffer(1,Buffer1,INDICATOR_DATA);
   int TF=TimeFrame;
   if (TF < Period()) TF=Period();
   updatebars=MathMax((TF / Period()),1); // example: 1440/240=6 bars to update on H4 chart
   return(0);
}
int deinit() { Comment(""); return(0); }

int start()
{
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) return(-1);
   if (counted_bars > 0) counted_bars--;
   int limit = Bars-counted_bars-1;
   if (limit > MaxBars)  limit=MathMin(MaxBars,limit);
   if (limit < updatebars) limit=updatebars;
   
   for(int i=0; i<limit; i++)
   {
      int d=iBarShift(NULL,TimeFrame,Time[i]); 

      double GSV_up=0, GSV_dn=0;     
      for (int n=1; n<=Length; n++)
      {          
         double open=iOpen(_Symbol,TimeFrame,d+n);
         double high=iHigh(_Symbol,TimeFrame,d+n);
         double low =iLow( _Symbol,TimeFrame,d+n);
         GSV_up += high-open; //sum buying pressure
         GSV_dn += open-low;  //sum selling pressure
      }      
      GSV_up /= (Length); // average
      GSV_dn /= (Length);      
      Buffer0[i]= NormalizeDouble(iOpen(NULL,TimeFrame,d) + Multiplier * GSV_up,_Digits);
      Buffer1[i]= NormalizeDouble(iOpen(NULL,TimeFrame,d) - Multiplier * GSV_dn,_Digits);                        
   }
   return(0);   
}
