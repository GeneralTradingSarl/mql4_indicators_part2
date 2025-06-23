//+------------------------------------------------------------------+
//|                                                      MACFibo.mq4 |
//|                                                     Dinesh Yadav |
//|                                              dineshydv@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Dinesh Yadav"
#property link      "dineshydv@gmail.com"
// based on MAC-Fibo system

#property indicator_chart_window

extern string MA_Mode_Types="0=SMA; 1=EMA; 2=SMMA; 3=LWMA;";
extern int Fast_MA=5;
extern int Fast_Mode=1;
//extern int MidMA=8;
extern int Slow_MA=20;
extern int Slow_Mode=0;
extern color Long_Entry_Clr=Blue;
extern color Shrt_Entry_Clr=Red;
extern bool Alerts=true;

int bars_snc_dn_strtd=0,bars_snc_up_strtd=0;
double POINT_A, POINT_B, P_200, P_161_8, P_78_6, P_61_8, P_50, P_32_2;
string TRADE;
datetime LastTradeBarTime;

//double upper[], lower[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init() { return(0); }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit() { ObjectsDeleteAll(); return(0); }
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start() 
{
   int i, counter;
   double MA5_prv1, MA20_prv1, MA5_prv2, MA20_prv2, MA5_now, MA20_now;
   double Range, AvgRange;

   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+9;

   double this_trnd_low=99999, this_trnd_high=0;

   for(i=limit; i>=0; i--)
   {
      counter=i; Range=0; AvgRange=0;
      for (counter=i ;counter<=i+9;counter++)
      { AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]); }
      Range=AvgRange/10;

      MA5_prv1 = iMA(NULL, 0, Fast_MA, 0, Fast_Mode, PRICE_CLOSE, i+1);    // i+1 
      MA5_prv2 = iMA(NULL, 0, Fast_MA, 0, Fast_Mode, PRICE_CLOSE, i+2);  // I+2
      MA5_now = iMA(NULL, 0, Fast_MA, 0, Fast_Mode, PRICE_CLOSE, i);  // i
      MA20_prv1 = iMA(NULL, 0, Slow_MA, 0, Slow_Mode, PRICE_CLOSE, i+1);   // i+1
      MA20_prv2 = iMA(NULL, 0, Slow_MA, 0, Slow_Mode, PRICE_CLOSE, i+2); // i+2
      MA20_now = iMA(NULL, 0, Slow_MA, 0, Slow_Mode, PRICE_CLOSE, i); // i

      // 5EMA cross above 20SMA UP
      if((MA5_prv1 > MA20_prv1) && (MA5_prv2 < MA20_prv2) && (MA5_now > MA20_now)) 
      { 
         TRADE="BUY";
         int low_bar_shft=iLowest(NULL,0,MODE_LOW,bars_snc_dn_strtd,i);
         POINT_A=Close[i+1];
         POINT_B=Low[low_bar_shft];
         DrawObjects("MACFIBO-A "+i+1, i+2, POINT_A, i, POINT_A, Long_Entry_Clr, 3 );
         DrawObjects("MACFIBO-B "+i+1, low_bar_shft+1, POINT_B, low_bar_shft-1, POINT_B, Long_Entry_Clr, 3 );
         DrawObjects("MACFIBO-Line "+i+1, low_bar_shft, POINT_B, i+1, POINT_A, Long_Entry_Clr, 3 );
         if( Alerts && LastTradeBarTime != Time[i] )
            { Alert("MAC-Fibo BUY Alert on "+Symbol()+" at "+POINT_A);  LastTradeBarTime = Time[i]; 
            }

      }
      // 5EMA cross below 20SMA DN
      else if ((MA5_prv1 < MA20_prv1) && (MA5_prv2 > MA20_prv2) && (MA5_now < MA20_now)) 
      { 
         TRADE="SELL";
         int High_bar_shft=iHighest(NULL,0,MODE_HIGH,bars_snc_up_strtd,i);
         POINT_A=Close[i+1];
         POINT_B=High[High_bar_shft];
         DrawObjects("MACFIBO-A "+i+1, i+2, POINT_A, i, POINT_A, Shrt_Entry_Clr, 3 );
         DrawObjects("MACFIBO-B "+i+1, High_bar_shft+1, POINT_B, High_bar_shft-1, POINT_B, Shrt_Entry_Clr, 3 );
         DrawObjects("MACFIBO-Line "+i+1, High_bar_shft, POINT_B, i+1, POINT_A, Shrt_Entry_Clr, 3 );
         if( Alerts && LastTradeBarTime != Time[i] )
            { Alert("MAC-Fibo SELL Alert on "+Symbol()+" at "+POINT_A);  LastTradeBarTime = Time[i]; 
            }
      }
      else { TRADE="NA"; }


      if( MA5_prv1 < MA20_prv1 ) // Trend is DN
      { bars_snc_up_strtd=0; bars_snc_dn_strtd++; }
      else if( MA5_prv1 > MA20_prv1 ) // Trend is UP
      { bars_snc_up_strtd++; bars_snc_dn_strtd=0; }

   }
return(0);
}



void DrawObjects(string ObjName, int shft_bgn, double Price_Bgn, int shft_end, double Price_End, color clr, int wdth) 
{
   ObjectDelete(ObjName);
   ObjectCreate(ObjName, OBJ_TREND, 0, Time[shft_bgn], Price_Bgn, Time[shft_end], Price_End ); 
   ObjectSet(ObjName, OBJPROP_WIDTH, wdth);
   ObjectSet(ObjName,OBJPROP_RAY,false);
   ObjectSet(ObjName,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(ObjName,OBJPROP_COLOR,clr);
}


//+------------------------------------------------------------------+