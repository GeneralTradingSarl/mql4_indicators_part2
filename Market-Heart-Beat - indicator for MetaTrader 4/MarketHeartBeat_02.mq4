/*------------------------------------------------------------------+     
 |                                          MarketHeartBeat_02.mq4  |
 |                                                Copyright © 2010  |
 +------------------------------------------------------------------*/ 
#property  copyright "Copyright © 2010, basisforex@gmail.com"
#property  link      "basisforex@gmail.com"
//+-----------------------------------------------------------------+
#property indicator_chart_window
//------------------------------
double dPrice;
double nTick[60];
double SumTickPl[60];
double SumTickMn[60];
string T[60];
string t;
string m = "   <---";
//+-----------------------------------------------------------------+
int init()
 {
   return(0);
 }
//+-----------------------------------------------------------------+
int start()
 {   
   if(dPrice == 0) dPrice = Bid;
   nTick[Minute()] = nTick[Minute()] + 1;
   if(Bid - dPrice > 0)
    {
      SumTickPl[Minute()] = SumTickPl[Minute()] + ((Bid - dPrice) / Point);
      dPrice = Bid;
    } 
   if(Bid - dPrice < 0)
    {
      SumTickMn[Minute()] = SumTickMn[Minute()] + ((dPrice - Bid) / Point);
      dPrice = Bid;
    }  
   //----- 
   t = ""; 
   for(int i = 0; i < 60; i++)
    {      
      if(i == Minute()) 
       {
         T[i] = "M" + i + "   T= " + DoubleToStr(nTick[i], 0) + "   Pl= " + DoubleToStr(SumTickPl[i], 0) + "   Mi= " + DoubleToStr(SumTickMn[i], 0) + m + "\n";
       }
      else T[i] = "M" + i + "   T= " + DoubleToStr(nTick[i], 0) + "   Pl= " + DoubleToStr(SumTickPl[i], 0) + "   Mi= " + DoubleToStr(SumTickMn[i], 0) + "\n";
      //-----       
      t = t + T[i];
    }  
    
   if(Minute() == 59)
    {
      nTick[0] = 0;
      SumTickPl[0] = 0;
      SumTickMn[0] = 0;
    }
   else
    {
      nTick[Minute() + 1] = 0;
      SumTickPl[Minute() + 1] = 0;
      SumTickMn[Minute() + 1] = 0; 
    }
   Comment(t);          
 }
    