//+------------------------------------------------------------------+
//|            Imp_MA.mq4                                            |
//|   Author:  paladin80 (www.mql4.com/users/paladin80)              |
//|   E-mail:  forevex@mail.ru                                       |
//+------------------------------------------------------------------+
#property link "forevex@mail.ru"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Lime
//---- indicator parameters
extern int MA_Period=14;
extern int MA_Shift=0;
extern int MA_Method=0;
//---- Prices coefficients for calculation of individual price.
extern int Close_coef=1;
extern int Open_coef=0;
extern int High_coef=0;
extern int Low_coef=0;
//----
bool       error=false;
//---- indicator buffers
double ExtMapBuffer[];
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   int    draw_begin;
   string short_name, price_name;
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexShift(0,MA_Shift);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   if(MA_Period<2) MA_Period=13;
   draw_begin=MA_Period-1;
//---- Check errors
   if (Close_coef<0) Close_coef=0;
   if (Open_coef<0)  Open_coef=0;
   if (High_coef<0)  High_coef=0;
   if (Low_coef<0)   Low_coef=0;
//----
   if (MA_Period<=0)
   {  error=true; Alert("MA_Period must be above zero for indicator Imp_MA");
      return(0); }
//---- indicator short name
   switch(MA_Method)
     {
      case 1 : short_name="Imp_EMA (";  draw_begin=0; break;
      case 2 : short_name="Imp_SMMA ("; break;
      case 3 : short_name="Imp_LWMA ("; break;
      default :
         MA_Method=0;
         short_name="Imp_SMA (";
     }
   price_name=iPriceName(Close_coef, Open_coef, High_coef, Low_coef);
   IndicatorShortName(short_name+price_name+", "+MA_Period+")");
   SetIndexDrawBegin(0,draw_begin);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
//----
   if (error==true) return(0);
//----
   if(Bars<=MA_Period) return(0);
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
//----
   switch(MA_Method)
     {
      case 0 : sma();  break;
      case 1 : ema();  break;
      case 2 : smma(); break;
      case 3 : lwma();
     }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
void sma()
  {
   double sum=0;
   int    i,pos=Bars-ExtCountedBars-1;
//---- initial accumulation
   if(pos<MA_Period) pos=MA_Period;
   for(i=1;i<MA_Period;i++,pos--)   
   sum+=CustomPricefunc(Close_coef,Open_coef,High_coef,Low_coef,pos);
//---- main calculation loop
   while(pos>=0)
     {
      sum+=CustomPricefunc(Close_coef,Open_coef,High_coef,Low_coef,pos);
      ExtMapBuffer[pos]=sum/MA_Period;
	   sum-=CustomPricefunc(Close_coef,Open_coef,High_coef,Low_coef,pos+MA_Period-1);
 	   pos--;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++) ExtMapBuffer[Bars-i]=0;
  }
//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
void ema()
  {
   double pr=2.0/(MA_Period+1);
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
//---- main calculation loop
   while(pos>=0)
     {
      if(pos==Bars-2) 
      ExtMapBuffer[pos+1]=CustomPricefunc(Close_coef,Open_coef,High_coef,Low_coef,pos+1);
      ExtMapBuffer[pos]  =CustomPricefunc(Close_coef,Open_coef,High_coef,Low_coef,pos)*pr+ExtMapBuffer[pos+1]*(1-pr);
 	   pos--;
     }
  }
//+------------------------------------------------------------------+
//| Smoothed Moving Average                                          |
//+------------------------------------------------------------------+
void smma()
  {
   double sum=0;
   int    i,k,pos=Bars-ExtCountedBars+1;
//---- main calculation loop
   pos=Bars-MA_Period;
   if(pos>Bars-ExtCountedBars) pos=Bars-ExtCountedBars;
   while(pos>=0)
     {
      if(pos==Bars-MA_Period)
        {
         //---- initial accumulation
         for(i=0,k=pos;i<MA_Period;i++,k++)
           {
            sum+=CustomPricefunc(Close_coef,Open_coef,High_coef,Low_coef,k);
            //---- zero initial bars
            ExtMapBuffer[k]=0;
           }
        }
      else sum=ExtMapBuffer[pos+1]*(MA_Period-1)+CustomPricefunc(Close_coef,Open_coef,High_coef,Low_coef,pos);
      ExtMapBuffer[pos]=sum/MA_Period;
 	   pos--;
     }
  }
//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
void lwma()
  {
   double sum=0.0,lsum=0.0;
   double price;
   int    i,weight=0,pos=Bars-ExtCountedBars-1;
//---- initial accumulation
   if(pos<MA_Period) pos=MA_Period;
   for(i=1;i<=MA_Period;i++,pos--)
     {
      price=CustomPricefunc(Close_coef,Open_coef,High_coef,Low_coef,pos);
      sum+=price*i;
      lsum+=price;
      weight+=i;
     }
//---- main calculation loop
   pos++;
   i=pos+MA_Period;
   while(pos>=0)
     {
      ExtMapBuffer[pos]=sum/weight;
      if(pos==0) break;
      pos--;
      i--;
      price=CustomPricefunc(Close_coef,Open_coef,High_coef,Low_coef,pos);
      sum=sum-lsum+price*MA_Period;
      lsum-=CustomPricefunc(Close_coef,Open_coef,High_coef,Low_coef,i);
      lsum+=price;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++) ExtMapBuffer[Bars-i]=0;
  }
//+------------------------------------------------------------------+

//--------------------------------------------- CustomPricefunc() - start --------------------------------------------------
//+----------------------------------------------------------------------------+
//| Input parameters:                                                          |
//|   Close_price_coef  - Weight ratio of the Close price.                     |
//|   Open_price_coef   - Weight ratio of the Open price.                      |
//|   High_price_coef   - Weight ratio of the High price.                      |
//|   Low_price_coef    - Weight ratio of the Low price.                       |
//|   Shift             - Index of the value taken from the indicator buffer.  |
//+----------------------------------------------------------------------------+
double CustomPricefunc(int Close_price_coef, int Open_price_coef,
                       int High_price_coef,  int Low_price_coef,
                       int Shift)
{
   double iCl, iOp, iHi, iLo, numerator, result;
   int denominator;
    if (Close_price_coef>0) iCl=Close[Shift]*Close_price_coef; else { iCl=0.0; Close_price_coef=0; }
    if (Open_price_coef>0)  iOp=Open [Shift]*Open_price_coef;  else { iOp=0.0; Open_price_coef=0;  }
    if (High_price_coef>0)  iHi=High [Shift]*High_price_coef;  else { iHi=0.0; High_price_coef=0;  }
    if (Low_price_coef>0)   iLo=Low  [Shift]*Low_price_coef;   else { iLo=0.0; Low_price_coef=0;   }
   numerator=iCl+iOp+iHi+iLo;
   denominator=Close_price_coef+Open_price_coef+High_price_coef+Low_price_coef;
    if (numerator<=0.0 || denominator<=0) result=0;
    else result=numerator/denominator;
   return(result);
}
//--------------------------------------------- CustomPricefunc() - end ----------------------------------------------------

//--------------------------------------------- iPriceName() - start --------------------------------------------------
string iPriceName(int Cl, int Op, int Hi, int Lo)
{
   string result, Cltext, Optext, Hitext, Lotext;
   //----
   if (Cl<0) Cl=0;
   if (Op<0) Op=0;
   if (Hi<0) Hi=0;
   if (Lo<0) Lo=0;
   //----
   if ((Cl+Op+Hi+Lo)==0) return(0);
   //----
   if (Cl==0) Cltext="";
      else if (Cl==1) Cltext="C";
         else if (Cl>1) Cltext=Cl+"C";
   if (Op==0) Optext="";
      else if (Op==1) Optext="O";
         else if (Op>1) Optext=Op+"O";
   if (Hi==0) Hitext="";
      else if (Hi==1) Hitext="H";
         else if (Hi>1) Hitext=Hi+"H";
   if (Lo==0) Lotext="";
      else if (Lo==1) Lotext="L";
         else if (Lo>1) Lotext=Lo+"L";
      result=Cltext+Optext+Hitext+Lotext;
   //----
   if (Cl!=0 && Op==0 && Hi==0 && Lo==0)                       result="Close";
   if (Cl==0 && Op!=0 && Hi==0 && Lo==0)                       result="Open";
   if (Cl==0 && Op==0 && Hi!=0 && Lo==0)                       result="High";
   if (Cl==0 && Op==0 && Hi==0 && Lo!=0)                       result="Low";
   if (Cl==0 && Op==0 && Hi!=0 && Lo!=0 && Hi==Lo)             result="Median";
   if (Cl!=0 && Op==0 && Hi!=0 && Lo!=0 && Hi==Lo && Cl==Hi)   result="Typical";
   if (Cl!=0 && Op==0 && Hi!=0 && Lo!=0 && Hi==Lo && Cl==2*Hi) result="Weighted";
   return(result);
}
//--------------------------------------------- iPriceName() - start --------------------------------------------------

