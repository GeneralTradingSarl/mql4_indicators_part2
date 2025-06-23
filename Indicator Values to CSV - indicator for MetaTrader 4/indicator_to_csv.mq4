//+------------------------------------------------------------------+
//|                                             Indicator_to_CSV.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Inovance"
#property link      "https://www.inovancetech.com/"
#property description "Save indicator values and OHLC data to a csv file."
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

   //Indicator periods
input int CCIPeriod = 14;
input int RSIPeriod = 14;

   //Filename
input string   FileName = "CCIRSIdata.csv";


   //Indicator Buffers
double CCIBuffer[];
double RSIBuffer[];


//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int OnInit()
  {
      //Indicator buffers mapping
   SetIndexBuffer(0,CCIBuffer);
   SetIndexBuffer(1,RSIBuffer);
   
      //Indicator styling
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
      //Define variables
      int limit,i;
      int counted_bars = IndicatorCounted();
      
      //Make sure on most recent bar
      if(counted_bars>0) counted_bars--;
   
      //Set limit
      limit = Bars - counted_bars - 1;
      
      
      //Main loop
      for(i = limit - 1; i>=0; i--) 
         { 
         
            //Indicators
            CCIBuffer[i] = iCCI(NULL,0,CCIPeriod,PRICE_OPEN,i);
            RSIBuffer[i] = iRSI(NULL,0,RSIPeriod,PRICE_OPEN,i); 
          
            //Create and Open file
            int handle=FileOpen(FileName,FILE_CSV|FILE_READ|FILE_WRITE,",");
            
            //Name column headers
            FileWrite(handle,"Open Timestamp","Open","High","Low","Close","Volume","CCI(14)","RSI(14)");
            
            //Go to end of file
            FileSeek(handle,0,SEEK_END);
            
            //Record Indicator values
            FileWrite(handle,Time[i],Open[i],High[i],Low[i],Close[i],Volume[i],CCIBuffer[i],RSIBuffer[i]);
            
            //Close file
            FileClose(handle);    
            
         }
         
      return(0);
  }