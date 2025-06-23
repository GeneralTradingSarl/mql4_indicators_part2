//+------------------------------------------------------------------+
//|                                    Jay_Digital Parabolic Spy.mq4 |
//|                                                        Oje Uadia |
//|                                         moneyinthesack@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Oje Uadia"
#property link      "moneyinthesack@yahoo.com"

#property indicator_separate_window
//---- input parameters
extern double    par_step=0.02;
extern double    par_max=0.2;
extern color     buycolour=Chartreuse;
extern color     sellcolour=Red;
  int     Buy                  = 233;
  int     Sell                 = 234;
  int     Wait                 = 54;
  int myspace;
  string shortname = "Jay_Digital Parabolic Spy v.1";
  string timeframes []={"M15","M30","H1","H4"};
  int times[]={15,30,60,240};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
if (Year()>2009)
{
Alert("this indicator has expired. pls call 08061228696 for renewal");
return(0);
}
IndicatorShortName(shortname);
   
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
   if (Year()>2009)
{
Alert("this indicator has expired. pls call 08061228696 for renewal");
return(0);
}

   int    counted_bars=IndicatorCounted();
   myspace=WindowFind(shortname);
//----------------------------------------------------------------------------------------------------------------------
//---- to do the drawings once only
//----------------------------------------------------------------------------------------------------------------------
static bool alreadydrawn= false;

if (alreadydrawn==false)
{
//------------------------------------------------------------------------------
// create position and pipDiff and swing
//------------------------------------------------------------------------------
ObjectCreate("Position",OBJ_LABEL,myspace,0,0,0,0,0,0);
ObjectSet("Position",OBJPROP_XDISTANCE,10);
ObjectSet("Position",OBJPROP_YDISTANCE,25);
ObjectSetText("Position","Position",12,"Times New Roman",White);
//----------------------------------------------------------------------------------
ObjectCreate("pipDiff",OBJ_LABEL,myspace,0,0,0,0,0,0);
ObjectSet ("pipDiff",OBJPROP_XDISTANCE,10);
ObjectSet("pipDiff",OBJPROP_YDISTANCE,43);
ObjectSetText("pipDiff","pipDiff",12,"Times New Roman",White);
//---------------------------------------------------------------------------------
ObjectCreate("Swing",OBJ_LABEL,myspace,0,0,0,0,0,0);
ObjectSet("Swing",OBJPROP_XDISTANCE,10);
ObjectSet("Swing",OBJPROP_YDISTANCE,61);
ObjectSetText("Swing","SwinG",12,"Times New Roman",White);
//----------------------------------------------------------------------------------------------------
// cycle for timeframes
//---------------------------------------------------------------------------------------------------
for (int x=0;x<4;x++)
{
ObjectCreate("timename"+x,OBJ_LABEL,myspace,0,0,0,0,0,0);
ObjectSet("timename"+x,OBJPROP_XDISTANCE,(x*80)+100);
ObjectSet("timename"+x,OBJPROP_YDISTANCE,14);
ObjectSetText("timename"+x,timeframes[x],7,"Times New Roman",White);


}// end of timefram creating loop

//-------------------------------------------------------------------------------------------------------
// activate the position symbols 
//-------------------------------------------------------------------------------------------------------
for ( x=0;x<4;x++)
{
ObjectCreate("pozsignals"+x,OBJ_LABEL,myspace,0,0,0,0,0,0);
ObjectSet("pozsignals"+x,OBJPROP_XDISTANCE,(x*80)+100);
ObjectSet("pozsignals"+x,OBJPROP_YDISTANCE,30);
ObjectSetText("pozsignals"+x,CharToStr(Wait),10,"Wingdings",Yellow);
}// end of position symbols

//---------------------------------------------------------------------------------------------------
// create the pipdiff symbols
//--------------------------------------------------------------------------------------------------
for ( x=0;x<4;x++)
{
ObjectCreate("diffsignals"+x,OBJ_LABEL,myspace,0,0,0,0,0,0);
ObjectSet("diffsignals"+x,OBJPROP_XDISTANCE,(x*80)+100);
ObjectSet("diffsignals"+x,OBJPROP_YDISTANCE,46);
ObjectSetText("diffsignals"+x,CharToStr(Wait),10,"Wingdings",Yellow);

//------------------------------------------------------------------------------------------------------
// create swing symbols
//-----------------------------------------------------------------------------------------------------
ObjectCreate("swingn"+x,OBJ_LABEL,myspace,0,0,0,0,0,0);
ObjectSet("swingn"+x,OBJPROP_XDISTANCE,(x*80)+100);
ObjectSet("swingn"+x,OBJPROP_YDISTANCE,61);
ObjectSetText("swingn"+x,DoubleToStr(iHigh(Symbol(),times[x],0)-iLow(Symbol(),times[x],0),Digits),10,"Times New Roman",Yellow);

}// end of pipDiff symbols
alreadydrawn=true;
}// end of the once only code

//----------------------------------------------------------------------------------------------------------
// calculate the sar values and assign appropriately
//----------------------------------------------------------------------------------------------------------
for (x=0;x<4;x++)
{
double sar = iSAR(Symbol(),times[x],par_step,par_max,0);
double sweetsar = NormalizeDouble(sar,2);
double price = NormalizeDouble(iClose(Symbol(),times[x],0),2);


if (sar>iClose(Symbol(),times[x],0))
{
ObjectSetText("pozsignals"+x,CharToStr(Sell),10,"Wingdings",sellcolour);
ObjectSetText("diffsignals"+x,DoubleToStr(sar-iClose(Symbol(),times[x],0),Digits),10,"Times New Roman",sellcolour);
//ObjectSetText("diffsignals"+x,"" + sweetsar - price,10,"Times New Roman",sellcolour);
}//end of sar up code
else 
if (sar<iClose(Symbol(),times[x],0))
{
ObjectSetText("pozsignals"+x,CharToStr(Buy),10,"Wingdings",buycolour);
ObjectSetText("diffsignals"+x,DoubleToStr(iClose(Symbol(),times[x],0)-sar,Digits),10,"Times New Roman",buycolour);

}// end of sar down code

ObjectSetText("swingn"+x,DoubleToStr(iHigh(Symbol(),times[x],0)-iLow(Symbol(),times[x],0),Digits),10,"Times New Roman",Yellow);

}// end of sar values
   //Alert("sar= "+ sar, "close" +iClose(Symbol(),times[x],0));
   return(0);
   
  }
//+------------------------------------------------------------------+