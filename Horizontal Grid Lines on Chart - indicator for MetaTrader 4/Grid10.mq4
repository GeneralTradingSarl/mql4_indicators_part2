//+------------------------------------------------------------------+
//|                                                       Grid10.mq4 |
//|                                          Copyright © M00SE  2009 |
//|                                                                  |
//|                        G R I D   1 0                             |
//|                                                                  |
//| This indicator will draw a grid on a chart using grid lines      |
//| separated at a convenient power of ten (popular with humans!)    |
//| eg. an index chart with range 10,200 to 10,800 will use a        |
//| resolution of 100 whereas a currency pair with chart range       |
//| 1.56100 to 1.56900 will use a resolution of 0.00100              |
//|                                                                  |
//| Version 2 - 15 Sep 2010                                          |
//| 1 - The optional ability to include intermediate grid lines      |
//|     every 10%, 20%, 25% or 50% of the major grid lines.          |
//| 2 - The resolution of the grid is now tied to the range of the   | 
//|     chart (rather than the range of the data on the chart).      |
//|     This means that if the chart is resized, the grid will       |
//|     automatically resize with it at the next tick.               |
//| 3 - Correction to odd results caused by use of MathMod API       | 
//|     function. (See code below for full details.)                 |
//|                                                                  |
//| Version 1 - 10 Sep 2009                                          |
//|                                                                  |
//|                                                                  |
//| Instructions                                                     |
//|                                                                  |
//| Choose the symbol you're interested in and display it in a chart |
//| window at the appropriate timeframe. Select <Ctrl>-G to erase    |
//| the default grid.  Load Grid10 Custom Indicator.                 |
//| Optionally, choose intermediate grid lines and their frequency.  |
//| Optionally, choose your colour scheme and line style properties. |
//|                                                                  |
//| That's it!                                                       |
//| Hope you like it, MOOSE.                                         |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Copyright © M00SE  2009"

#property indicator_chart_window

//---- input parameters
extern color  GridColour = Salmon;
extern color  IntermediateColour = Maroon;
extern string NoteLineStyle = "{0}___ {1}_ _ {2}... {3}_._ {4}_.._";
extern int    GridStyle = STYLE_DOT;
extern int    IntermediateStyle = STYLE_DASHDOTDOT;
extern string NoteIntermediateLine = "Percentage = 0 / 10 / 20 / 25 / 50";
extern int    IntermediateLinePercent = 0;

//---- data
int gridCt;
string sGrid = "GridLine";
double gridResSubDiv = 1.0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----

   if(IntermediateLinePercent == 50)
      gridResSubDiv = 2.0;   
   else if(IntermediateLinePercent == 25)
      gridResSubDiv = 4.0;   
   else if(IntermediateLinePercent == 20)
      gridResSubDiv = 5.0;   
   else if(IntermediateLinePercent == 10)
      gridResSubDiv = 10.0;
   else
   {
      IntermediateLinePercent = 0;
      gridResSubDiv = 1.0;
   }      
   
   if(GridStyle < 0 || GridStyle > 4)
      GridStyle = STYLE_DOT;
   
   if(IntermediateStyle < 0 || IntermediateStyle > 4)
      IntermediateStyle = STYLE_DASHDOTDOT;
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   string sGridLine;

   for(int gridNo=0; gridNo < gridCt; gridNo++)
   {
      sGridLine = sGrid + gridNo;
      ObjectDelete(sGridLine);
   }
   
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
   double log10e = 0.43429448190325182765112891891661;
   //log10x = log10e * logex
   
   double chartHi, chartLo;
   string sGridLine;
   double gridRes = 0.0100;
   double gridPos, startPos;
   double range;
   static double prevRange;
   
   chartHi = WindowPriceMax(0);
   chartLo = WindowPriceMin(0);
   range = chartHi - chartLo;

   // need only draw the grid if the high - low range has changed
   // or the number of bars displayed has changed (ie. the chart has been resized)
   if(prevRange != range)
   {
      deinit();
      prevRange = range;
   
      // select a grid resolution based on the range of the chart
      double log10Range = log10e * MathLog(range);
      log10Range = MathFloor(log10Range);
      gridRes = MathPow(10.0, log10Range);
          
      // draw the grid lines to encompass the full range of the chart
      startPos = chartLo - gridRes;
      gridPos = startPos - MathModCorrect(startPos, gridRes);
      gridCt = 0;
      
      
      double modulus;
      while(gridPos < chartHi + gridRes)
      {
         modulus = MathModCorrect(gridPos, gridRes);

         sGridLine = sGrid + gridCt;
         ObjectCreate(sGridLine, OBJ_HLINE, 0, 0, gridPos);
         if(MathAbs(modulus) < 0.0000001)
         {
            //Grid line
            ObjectSet(sGridLine, OBJPROP_COLOR, GridColour);
            ObjectSet(sGridLine, OBJPROP_STYLE, GridStyle);
         }
         else
         {
            //Intermediate line
            ObjectSet(sGridLine, OBJPROP_COLOR, IntermediateColour);
            ObjectSet(sGridLine, OBJPROP_STYLE, IntermediateStyle);
         }

         gridPos += (gridRes / gridResSubDiv);
         gridCt++;
      }   
   
      //---- force objects drawing
      ObjectsRedraw();

   }
   
   return(0);
}


//+------------------------------------------------------------------+
//| MathModCorrect                                                   |
//|                                                                  |
//| There are known problems with the MathMod API call identified    |
//| in this article:     http://articles.mql4.com/866                |
//| There is a further problem with the solution presented by that   |
//| article in that it is inaccurate when both a and b parameters    |
//| are small numbers (ie. less than 1.0)                            |
//| Consider a=0.7 and b=0.1                                         |
//| The integer result of a/b is 7. Fine.                            |
//| However, suppose that the nearest floating point representation  |
//| of 0.7 is actually 0.6999999999999999.                           |
//| Now the integer result of a/b is in fact 6. Quite different!     |
//| This version of MathModCorrect gets around the problem by keeping|
//| the result of a/b in a double and normalizing the result         |
//| to two decimal places. Thus a number such as 0.6999999999999999  |
//| would be rounded to 0.70 rather than 0.69 which is a much        |
//| better representation of the true value, before being truncated  |
//| (MathFloor) to yield the modulus.                                |
//|                                                                  |
//+------------------------------------------------------------------+
double MathModCorrect(double a, double b)
{ 
   double tmpRes = a / b;
   double tmpNorm = NormalizeDouble(tmpRes, 2);
   double tmpFlr = MathFloor(tmpNorm);
   double result = (a - (tmpFlr * b));
   return(result);
}

