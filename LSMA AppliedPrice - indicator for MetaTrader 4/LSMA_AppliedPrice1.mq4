//+------------------------------------------------------------------+
//|                                            LSMA_AppliedPrice.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2005, FX Sniper "
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 1
#property indicator_color1 Red
//---- buffers
double ExtMapBuffer1[];
int width;
//----
extern int Rperiod=14;
extern int Draw4HowLongg=1500;
extern int LSMA_AppliedPrice=0;
// Applied Price enumerations
// 0=close, 1=open, 2=high, 3=low, 4=median((h+l/2)), 5=typical((h+l+c)/3), 6=weighted((h+l+c+c)/4)
int Draw4HowLong;
int shift;
int i;
int loopbegin;
double sum1;
int length;
double lengthvar;
double tmp ;
double wt;
int c;
double price;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(2);
//---- drawing settings
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if (CheckValidUserInputs()) return(0);
//-----
   Draw4HowLong=Bars-Rperiod - 5;
   length=Rperiod;
   loopbegin=Draw4HowLong - length - 1;
   for(shift=loopbegin; shift>=0; shift--)
     {
      sum1=0;
      for(i=length; i>=1 ;i--)
        {
         lengthvar=length + 1;
         lengthvar/=3;
         tmp=0;
         // Applied Price enumerations
         // 0=close, 1=open, 2=high, 3=low, 4=median((h+l/2)), 5=typical((h+l+c)/3), 6=weighted((h+l+c+c)/4)
         switch(LSMA_AppliedPrice)
           {
            case 0: price=Close[length-i+shift];
               break;
            case 1: price=Open[length-i+shift];
               break;
            case 2: price=High[length-i+shift];
               break;
            case 3: price=Low[length-i+shift];
               break;
            case 4: price=(High[length-i+shift] + Low[length-i+shift])/2.0;
               break;
            case 5: price=(High[length-i+shift] + Low[length-i+shift] + Close[length-i+shift])/3.0;
               break;
            case 6: price=(High[length-i+shift] + Low[length-i+shift] + 2.0*Close[length-i+shift])/4;
               break;
           }
         tmp =(i - lengthvar)*price;
         sum1+=tmp;
        }
      wt=sum1*6/(length*(length+1));
      //========== COLOR CODING ===========================================               
      ExtMapBuffer1[shift]=wt;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| CheckValidUserInputs                                             |
//| Check if User Inputs are valid for ranges allowed                |
//| return true if invalid input, false otherwise                    |
//| Also display an alert for invalid input                          |
//+------------------------------------------------------------------+
bool CheckValidUserInputs()
  {
   if (CheckAppliedPrice(LSMA_AppliedPrice))
     {
      Alert("LSMA_AppliedPrice requires a value from 0 to 6",'\n','\r',"You entered ",LSMA_AppliedPrice);
      return(true);
     }
   return(false);
  }
//+-----------------------------------------------------+
//| Check for valid Applied Price enumerations          |
//|   0=close, 1=open, 2=high, 3=low, 4=median((h+l/2)) |
//|   5=typical((h+l+c)/3), 6=weighted((h+l+c+c)/4)     |
//|  return true if invalid, false if OK                |
//+-----------------------------------------------------+
bool CheckAppliedPrice(int applied_price)
  {
   if (applied_price < 0) return(true);
   if (applied_price > 6) return(true);
   return(false);
  }
//+------------------------------------------------------------------+

