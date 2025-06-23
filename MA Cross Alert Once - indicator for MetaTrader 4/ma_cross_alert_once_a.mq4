//+------------------------------------------------------------------+
//|                                       MA_Cross_Alert_Once_a.mq4  |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, file45."
#property link      "https://www.mql5.com/en/users/file45/publications"
#property version   "1.00"
#property strict
#property description "When two Moving Averages cross the indicator will alert once per cross between crosses(not once per candle) and mark the cross point with down or up arrow."
#property indicator_chart_window

#property indicator_buffers 4
#property indicator_color1 Lime
#property indicator_color2 Red

input bool Cross_Alert = true;  // Alert
input bool Sound_Only = false;  // Sound Only
input bool Cross_PN = false;    // Push Notification
input bool Cross_Email = false; // Email

input int Slow_MA_Period = 7; // Slow Period
input int Slow_MA_Shift = 0;  // Slow Shift
input int Slow_MA_Method = 0; // Slow Method
input int Slow_MA_Price = 0;  // Slow Price

input int Fast_MA_Period = 1; // Fast Period
input int Fast_MA_Shift = 0;  // Fast Shift
input int Fast_MA_Method = 0; // Fast Method
input int Fast_MA_Price = 0;  // Farst Price

input string Key;
input string Method = "0=SMA ; 1=EMA ; 2=SMMA ; 3=LWA ; 4=LSMA";  
input string Price = "0=close ; 1=open ; 2=high ; 3=low";
input string Price_= "4=median(high+low)/2 ; 5=typical(high+low+close)/3";
input string Price__ = "6=weighted(high+low+close+close)/4";

double CrossUp[];
double CrossDown[];

#define ALERT_BAR 1

string MA, TM;
int SMP, SMS, FMP, FMS;

datetime LastAlertTime;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{  
   LastAlertTime = TimeCurrent();
   
   switch(Slow_MA_Method)
   {
     case 0: MA = "SMA";break;
     case 1: MA = "EMA"; break;
     case 2: MA = "SMMA"; break;
     case 3: MA = "LWMA"; 
   }  
   
   switch(Period())
     {
      case 1:     TM = "M1";  break;
      case 2:     TM = "M2";  break;
      case 3:     TM = "M3";  break;
      case 4:     TM = "M4";  break;
      case 5:     TM = "M5";  break;
      case 6:     TM = "M6";  break;
      case 7:     TM = "M7";  break;
      case 8:     TM = "M8";  break;
      case 9:     TM = "M9";  break;
      case 10:    TM = "M10"; break;
      case 11:    TM = "M11"; break;
      case 12:    TM = "M12"; break;
      case 13:    TM = "M13"; break;
      case 14:    TM = "M14"; break;
      case 15:    TM = "M15"; break;
      case 20:    TM = "M20"; break;
      case 25:    TM = "M25"; break;
      case 30:    TM = "M30"; break;
      case 40:    TM = "M40"; break;
      case 45:    TM = "M45"; break;
      case 50:    TM = "M50"; break;
      case 60:    TM = "H1";  break;
      case 120:   TM = "H2";  break;
      case 180:   TM = "H3";  break;
      case 240:   TM = "H4";  break;
      case 300:   TM = "H5";  break;
      case 360:   TM = "H6";  break;
      case 420:   TM = "H7";  break;
      case 480:   TM = "H8";  break;
      case 540:   TM = "H9";  break;
      case 600:   TM = "H10"; break;
      case 660:   TM = "H11"; break;
      case 720:   TM = "H12"; break;
      case 1440:  TM = "D1";  break;
      case 10080: TM = "W1";  break;
      case 43200: TM = "MN";  break;
     }
   
   SMP = Slow_MA_Period;
   SMS = Slow_MA_Shift;
   
   FMP = Fast_MA_Period;
   FMS = Fast_MA_Shift;
   
   SetIndexStyle(0, DRAW_ARROW,0,2);
   SetIndexArrow(0, 225);
   SetIndexBuffer(0, CrossUp);

   SetIndexStyle(1, DRAW_ARROW,0,2);
   SetIndexArrow(1, 226);
   SetIndexBuffer(1, CrossDown);
 
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
  int limit, i;
   double Fast_MA_Bar_0, Slow_MA_Bar_0, Fast_MA_Bar_1, Slow_MA_Bar_1; 
  
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;
   
   for(i = 0; i <= limit; i++) 
   {       
      Fast_MA_Bar_0 = iMA(NULL, 0, Fast_MA_Period, Fast_MA_Shift, Fast_MA_Method, Fast_MA_Price, i+1);
      Fast_MA_Bar_1 = iMA(NULL, 0, Fast_MA_Period, Fast_MA_Shift, Fast_MA_Method, Fast_MA_Price, i+2);

      Slow_MA_Bar_0 = iMA(NULL, 0, Slow_MA_Period, Slow_MA_Shift, Slow_MA_Method, Slow_MA_Price, i+1);
      Slow_MA_Bar_1 = iMA(NULL, 0, Slow_MA_Period, Slow_MA_Shift, Slow_MA_Method, Slow_MA_Price, i+2);
      
      static datetime PrevSignal = 0, PrevTime = 0;
 
	   if(ALERT_BAR > 0 && Time[0] <= PrevTime)
	   { 
	     return(0);
	   }  

	   PrevTime = Time[0];
	   

	   if(PrevSignal <= 0)
	   {     
		  if((Fast_MA_Bar_1 < Slow_MA_Bar_1) && (Fast_MA_Bar_0 > Slow_MA_Bar_0)) // For Examples see: https://book.mql4.com/samples/indicators  if( M_1 < S_1 && M_0 > S_0 )
		  {
		    CrossUp[i=1] = Low[i=1] - iATR(NULL,0,20,i)/2;
			        
			 PrevSignal = 1;
			 
			 if(Sound_Only)
		    {
		      PlaySound("Alert.wav");
		    }              
			 if(Cross_Alert && Sound_Only == false)
			 {
			   Alert("BUY cross: ",Symbol(), " ", TM , " - ",IntegerToString(SMP)," ",MA," ",IntegerToString(SMS),"\n",DoubleToStr(Ask,Digits),"\n",TimeToStr(TimeCurrent(),TIME_SECONDS),"  ",TimeToStr(TimeCurrent(),TIME_DATE),"\n",AccountCompany());
			 }
          if(Cross_Email) 
          {
            SendMail ("Buy cross -" + Symbol() + "-" + TM + "-" + AccountCompany(),
                  "Buy Cross Alert" + "\n" +
                  "--------------------" + "\n" +
                  "Symbol : " + " " + Symbol() + " \n" +
                  "Period : " + " " + TM + " \n" +
                  "Slow MA : " + IntegerToString(SMP)+" "+MA+" "+IntegerToString(SMS)+ " \n" +
                  "Fast MA : " + IntegerToString(FMP)+" "+MA+" "+IntegerToString(FMS)+ " \n" +
                  "Ask Price : " + DoubleToStr(Ask,Digits)+ " \n" +
                  "Time and Date : " + TimeToStr(TimeCurrent(), TIME_SECONDS)+ "  " + TimeToStr(TimeCurrent(), TIME_DATE) + " \n" +        
                  "Broker : " + " " + AccountCompany() + "\n" +
                  "Account # : " + " " + IntegerToString(AccountNumber()));  
          }  
          if(Cross_PN) 
          {
            SendNotification("BUY: " + Symbol() + " " + TM + " <" + IntegerToString(SMP) + " " + MA + " " + IntegerToString(SMS) + "> " + DoubleToStr(Ask,Digits) + " " + "\n"+
                                      TimeToStr(TimeCurrent(),TIME_SECONDS)+"  "+TimeToStr(TimeCurrent(),TIME_DATE)+"  " + AccountCompany()); 
          }                            
	     }
      }
	   
	   if(PrevSignal >= 0)
	   {    
		  if((Fast_MA_Bar_1 > Slow_MA_Bar_1) && (Fast_MA_Bar_0 < Slow_MA_Bar_0)) // For Examples see: https://book.mql4.com/samples/indicators  if( M_1 > S_1 && M_0 < S_0 )
		  {
	       CrossDown[i=1] = High[i=1] + iATR(NULL,0,20,i)/2;
         
		    PrevSignal = -1;
		    
		    if(Sound_Only)
		    {
		      PlaySound("Alert.wav");
		    }         
			 if(Cross_Alert && Sound_Only == false)
			 {
			   Alert("SELL cross: ",Symbol(), " ", TM , " - ",IntegerToString(SMP)," ",MA," ",IntegerToString(SMS),"\n",DoubleToStr(Bid,Digits) + "\n",TimeToStr(TimeCurrent(),TIME_SECONDS),"  ",TimeToStr(TimeCurrent(),TIME_DATE),"\n",AccountCompany());
			 }
          if(Cross_Email) 
          {
             SendMail ("Sell cross -" + Symbol() + "-" + TM + "-"+ "-" + AccountCompany(),
                  "Sell Cross ALert" + "\n" +
                  "--------------------" + "\n" +
                  "Symbol : " + " " + Symbol() + " \n" +
                  "Period : " + " " + TM + " \n" +
                  "Slow MA : " + IntegerToString(SMP)+" "+MA+" "+IntegerToString(SMS)+ "-" + "\n" +
                  "Fast MA : " + IntegerToString(FMP)+" "+MA+" "+IntegerToString(FMS)+ " \n" +
                  "Bid Price : " + DoubleToStr(Bid,Digits)+ "\n" +
                  "Time and Date : " + TimeToStr(TimeCurrent(), TIME_SECONDS)+ "  " + TimeToStr(TimeCurrent(), TIME_DATE) + " \n" +        
                  "Broker : " + " " + AccountCompany() + "\n" +
                  "Account # : " + " " + IntegerToString(AccountNumber())); 
          }
          if(Cross_PN) 
          {
            SendNotification("SELL: " + Symbol() + " " + TM + " <" + IntegerToString(SMP) + " " + MA + " " + IntegerToString(SMS) + "> " + DoubleToStr(Bid,Digits) + " " + "\n" +  
                                       TimeToStr(TimeCurrent(),TIME_SECONDS)+"  "+TimeToStr(TimeCurrent(),TIME_DATE)+"  " + AccountCompany()); 
			 }    
        }
	   }     
   }
  
   return(rates_total);
}

