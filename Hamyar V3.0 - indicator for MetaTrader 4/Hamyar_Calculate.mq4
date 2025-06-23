//+------------------------------------------------------------------+
//|                                             Hamyar Calculate.mq4 |
//|                               Copyright © 2010,Farshad Saremifar |
//|                                               www.4xline.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010,Farshad Saremifar"
#property link      "www.4xline.com"

#property indicator_chart_window
#property indicator_buffers 6
extern string    Copyright="Copyright © 2010,Farshad Saremifar,www.4xline.com";
extern string    Help="This is just used to calculate Internal Variables";
extern int ATR_Period=25;
 int MasterTF=60;
double Pivot[];
double pip5[],pip15[],pip30[],pip60[],pip240[];
double PDayHigh, PDayLow;
datetime PivotDayStartTime;
int NumberOfDays=2;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorDigits(Digits);
   SetIndexBuffer( 0, Pivot);
   SetIndexBuffer( 1, pip5);
   SetIndexBuffer( 2, pip15);
   SetIndexBuffer(3, pip30);
   SetIndexBuffer( 4, pip60);
   SetIndexBuffer(5, pip240);
   SetIndexLabel( 0, "Pivot" );
   SetIndexLabel( 1, "Period_M5" );
   SetIndexLabel( 2, "Period_M15" );
   SetIndexLabel( 3, "Period_M30" );
   SetIndexLabel( 4, "Period_H1" );
   SetIndexLabel( 5, "Period_H4" );
   PivotDayStartTime = 0; 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
 
   int     j =((NumberOfDays*1440)/Period())+((1440)/Period());
   double Range;
   int Count;
   while(j >=0)
   {    
   
     if( Check(Time[j]) )
        {
         Count = iBarShift( Symbol(), 0, PivotDayStartTime ) - j;           
         PDayHigh = High[ iHighest( Symbol(), 0, MODE_HIGH, Count, j+1 ) ]; 
         PDayLow = Low[ iLowest( Symbol(), 0, MODE_LOW, Count, j+1 ) ]; 
         pip5[j]=iATR(Symbol(),PERIOD_M5,ATR_Period,iBarShift(NULL,PERIOD_M5,PivotDayStartTime,false));
         pip15[j]=iATR(Symbol(),PERIOD_M15,ATR_Period,iBarShift(NULL,PERIOD_M15,PivotDayStartTime,false));    
         pip30[j]=iATR(Symbol(),PERIOD_M30,ATR_Period,iBarShift(NULL,PERIOD_M30,PivotDayStartTime,false));
         pip60[j]=iATR(Symbol(),PERIOD_H1,ATR_Period,iBarShift(NULL,PERIOD_H1,PivotDayStartTime,false));
         pip240[j]=iATR(Symbol(),PERIOD_H4,ATR_Period,iBarShift(NULL,PERIOD_H4,PivotDayStartTime,false));
         Pivot[j] = ( PDayHigh + PDayLow + Close[j+1]*2) /4;
         PivotDayStartTime = Time[j];    
        }
         else     
        {
       
                 pip15[j]=pip15[j+1];
                 pip5[j]=pip5[j+1];
                 pip30[j]=pip30[j+1];
                 pip60[j]=pip60[j+1];
                 pip240[j]=pip240[j+1];
                 Pivot[j] = Pivot[j+1];
        }  
      j--; 
      }
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
bool Check(datetime t)
{   
    int TM=TimeMinute(t), TH=TimeHour(t) ;
    bool draw=false;
   
      if(MasterTF==5)
          {  
            if( TM==0 || TM==5 ||TM==10 ||TM==15 ||TM==20||TM==25 ||TM==30 
            ||TM==35 ||TM==40 ||TM==45||TM==50||TM==55) 
            draw=true;
          }  
      if(MasterTF==15)
          {
          if( TM==0 || TM==15 ||TM==30 ||TM==45) 
            draw=true;
          }      
      if(MasterTF==30)
          {
          if( TM==0 || TM==30) 
            draw=true;
          }      
      if(MasterTF==60)
          {
           if( TM==0) 
            draw=true;
          }      
      if(MasterTF==240)
          {
            if(TM==0 && (TH==0 ||TH==4||TH==8||TH==12||TH==16||TH==20||TH==24) ) 
            draw=true;
          }      
      if(MasterTF==1440)
          {
            if(TH==0 && TM==0) 
            draw=true;
          }       
      if(MasterTF==10080)
          {
            if(TH==0 && TM==0 && TimeDayOfWeek(t)==1 ) 
            draw=true;
          } 
      if(MasterTF==43200)
          {
            if(TH==0 && TM==0 && TimeDay(t)==1 ) 
            draw=true;
          }      
          
 return(draw);         
}  

