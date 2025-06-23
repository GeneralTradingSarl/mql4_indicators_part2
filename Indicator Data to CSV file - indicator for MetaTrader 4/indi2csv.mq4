//+------------------------------------------------------------------+
//|                                                     Indi2csv.mq4 |
//|                                                  Heaton Research |
//|                              http://www.heatonresearch.com/encog |
//|                                simplified by Mustafa Doruk Basar |
//+------------------------------------------------------------------+
#property copyright "Heaton Research"
#property link      "http://www.heatonresearch.com/encog"
#property strict
#property indicator_separate_window

extern string file_name = "Indi2csv.csv";

int fileh =-1;
int lasterror;

//+------------------------------------------------------------------+

int init()
  {
 
   IndicatorShortName("Indicators2CSV");

   fileh = FileOpen(file_name,FILE_CSV|FILE_WRITE,',');
   if(fileh<1)
   {
      lasterror = GetLastError();
      Print("Error updating file: ",lasterror);
      return(false);
   }
   
   // file header - need to be the identifiers of the indicators to be exported   
   FileWrite(fileh,"time","close","open","atr","cci","macd","rsi","stoch","wpr");

   return(0);
   
  }

//+------------------------------------------------------------------+

int deinit()
  {
      if(fileh>0) 
      {
         FileClose(fileh);
      }
   
   return(0);
   
  }
  
//+------------------------------------------------------------------+
  
int start()
  {
   int barcount = IndicatorCounted();
   if (barcount<0) return(-1);
   if (barcount>0) barcount--;
   
   int barind=Bars-barcount-1;
   
      while(barind>1)
      {
         ExportIndiData(barind);
         barind--;
      }
      
   return(0);
   
  }
//+------------------------------------------------------------------+

void ExportIndiData(int barind) 
{
   datetime t = Time[barind];
   string inditime =  
      StringConcatenate(TimeYear(t)+"_"+
                        TimeMonth(t)+"_"+
                        TimeDay(t)+"_"+
                        TimeHour(t)+"_"+
                        TimeMinute(t)+"_"+
                        TimeSeconds(t));
                        
   // add indicators at will (do not forget to update line 31!
   FileWrite(fileh, 
         inditime,
			Close[barind],
			Open[barind],
			iATR(Symbol(),0,14,barind),
			iCCI(Symbol(),0,14,PRICE_CLOSE,barind),
			iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,0,barind),
			iRSI(Symbol(),0,14,PRICE_CLOSE,barind),
			iStochastic(Symbol(),0,5,3,3,MODE_EMA,0,0,barind),
			iWPR(Symbol(),0,14,barind)
			);
			
}

//+------------------------------------------------------------------+ 