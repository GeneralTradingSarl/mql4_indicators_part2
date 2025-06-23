//+------------------------------------------------------------------+
//|                                                        inout.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, free84"
#property link      "free84@laposte.net"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrBlue
#property indicator_color2 clrRed
//----
extern bool Show_Alert=true;
extern bool Display_Out=true;
extern bool Display_In=true;
//---- buffers
double val1[];
double val2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_HISTOGRAM,0,1);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,1);
   SetIndexBuffer(0,val1);
   SetIndexBuffer(1,val2);
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
   int    counted_bars=IndicatorCounted();
//----
   double Range,AvgRange;
   int counter,setalert;
   static datetime prevtime=0;
   int shift;
   int shift1;
   int shift2;
   string pattern,period;
   int setPattern=0;
   int alert=0;
   double O,O1,C,C1,L,L1,H,H1;
   if(prevtime==Time[0])
     {
      return(0);
     }
   prevtime=Time[0];
   switch(Period())
     {
      case 1:
         period="M1";
         break;
      case 5:
         period="M5";
         break;
      case 15:
         period="M15";
         break;
      case 30:
         period="M30";
         break;
      case 60:
         period="H1";
         break;
      case 240:
         period="H4";
         break;
      case 1440:
         period="D1";
         break;
      case 10080:
         period="W1";
         break;
      case 43200:
         period="MN";
         break;
     }
   for(shift=0; shift<Bars-9; shift++)
     {
      setalert=0;
      counter=shift;
      Range=0;
      AvgRange=0;
      for(counter=shift;counter<=shift+9;counter++)
        {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
        }
      Range=AvgRange/9;
      shift1=shift;
      shift2=shift + 1;
      //----
      O=Open[shift1];
      O1=Open[shift2];
      H=High[shift1];
      H1=High[shift2];
      L=Low[shift1];
      L1=Low[shift2];
      C=Close[shift1];
      C1=Close[shift2];
      // Check for Out pattern
      if((H>H1) && (L<L1))
        {
         if(Display_Out==true)
           {
            val1[shift]=Low[shift]; val2[shift]=High[shift];
           }
         if(setalert==0 && Show_Alert==true)
           {
            pattern="Out";
            setalert=1;
           }
        }
      // Check for In pattern
      if((H<H1) && (L>L1))
        {
         if(Display_In==true)
           {
              {
               val1[shift]=High[shift]; val2[shift]=Low[shift];
              }
            if(setalert==0 && Show_Alert==true)
              {
               pattern="In";
               setalert=1;
              }
           }
        }
     } // End of for loop
//----
   return(0);
  }
//+------------------------------------------------------------------+
               }
                 if (setalert==0 && Show_Alert==true) 
                 {
                  pattern="In";
                  setalert=1;
                 }
              }
           }
        } // End of for loop
   //----
      return(0);
     }
//+------------------------------------------------------------------+