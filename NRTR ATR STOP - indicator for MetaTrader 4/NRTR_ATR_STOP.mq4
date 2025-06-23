//+------------------------------------------------------------------+
//|                                                NRTR_ATR_STOP.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers  2
#property indicator_color1 Blue
#property indicator_color2 Red
//----
extern int ATR = 20;
extern int Coeficient = 2;
//----
double Up[], Dn[];
string MODE;
bool first;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0, Up);
   SetIndexStyle (0, DRAW_LINE, 0, 2);
   SetIndexEmptyValue(0, 0.0);
   SetIndexLabel (0, "Up");
//----
   SetIndexBuffer(1, Dn);
   SetIndexStyle (1, DRAW_LINE, 0, 2);
   SetIndexEmptyValue(1, 0.0);
   SetIndexLabel (1, "Dn");
//----
   first=true;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() 
  { 
   first = true; 
   return(0); 
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i, limit;
   double REZ, md;
   limit = Bars - ATR - 1;
//----
   if(first)
     {
       md = 0;
       for(i = 0; i < limit; i++) 
           md += iATR(NULL, 0, ATR, i);
       REZ = Coeficient*iATR(NULL, 0, ATR, limit);
       if(iATR(NULL, 0, ATR, limit) < md / limit) 
         { 
           Up[limit+1] = Low[limit+1] - REZ; 
           MODE = "UP"; 
         }
       if(iATR(NULL, 0, ATR, limit) > md / limit) 
         { 
           Dn[limit+1] = High[limit+1] + REZ; 
           MODE = "DN"; 
         }
       first = false;
     }
//----
   for(i = limit - 1; i >= 0; i--)
     {
       Dn[i] = 0; 
       Up[i] = 0;
       REZ = Coeficient*iATR(NULL, 0, ATR, i);
       //----
       if(MODE == "DN" &&  Low[i+1] > Dn[i+1]) 
         { 
           Up[i+1] = Low[i+1] - REZ; 
           MODE = "UP"; 
         }
       //----
       if(MODE == "UP" && High[i+1] < Up[i+1]) 
         { 
           Dn[i+1] = High[i+1] + REZ; 
           MODE = "DN"; 
         }
       //----
       if(MODE=="UP")
         {
           if(Low[i+1] > Up[i+1] + REZ) 
             { 
               Up[i] = Low[i+1] - REZ; 
               Dn[i] = 0; 
             }
		         else 
		           { 
		             Up[i] = Up[i+1]; 
		             Dn[i] = 0; 
		           }
		       }
       //----
       if(MODE=="DN")
         {
     	     if(High[i+1] < Dn[i+1] - REZ) 
     	       { 
     	         Dn[i] = High[i+1] + REZ; 
     	         Up[i] = 0; 
     	       }
	          else 
	            { 
	              Dn[i] = Dn[i+1]; 
	              Up[i] = 0; 
	            }
	        }
     }
   return(0);
  }
//+------------------------------------------------------------------+