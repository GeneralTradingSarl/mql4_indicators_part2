//+------------------------------------------------------------------+
//|                                                        GARCH.mq4 |
//|                                              Andres Barale Sarti |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Andres Barale Sarti"
#property link      "http://www.mql5.com"
#property version   "1.20"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                       GARCH.mq4  |
//|                      Copyright © 2014, andresbarale@gmail.com    |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, andresbarale@gmail.com  "
#property link      "http://www.mql5.com"

#property indicator_separate_window
#property indicator_color1 Blue
#property indicator_width1 2
#property indicator_buffers 1
//************************************************************
// Input parameters
//************************************************************
extern int    e_type_data   = PRICE_CLOSE;
extern int    e_reverse_data   = 0;
extern double e_alpha = 0.010; 
extern double e_beta = 0.080;
//************************************************************
// Constant
//************************************************************
string INDICATOR_NAME="GARCH";
string FILENAME      ="___GARCH.mq4";
double LOG_2;
//************************************************************
// Private vars
//************************************************************
double ExtOutputBuffer[];
double ExtInputBuffer[];
int g_period_minus_1;
//+-----------------------------------------------------------------------+
//| FUNCTION : init                                                       |                                                                                                                                                                                                                                                      
//| Initialization function                                               |                                   
//| Check the user input parameters and convert them in appropriate types.|                                                                                                    
//+-----------------------------------------------------------------------+
int init() {
   if(e_type_data < PRICE_CLOSE || e_type_data > PRICE_WEIGHTED ) {
      Alert( "[ 20-ERROR  " + FILENAME + " ] input parameter \"e_type_data\" unknown (" + e_type_data + ")" );
      return( -1 );
   }
   IndicatorBuffers( 1 );
   SetIndexBuffer( 0, ExtOutputBuffer );
   SetIndexStyle( 0, DRAW_LINE, STYLE_SOLID, 2 );
//----
   return( 0 );
 }
//+------------------------------------------------------------------+
//| FUNCTION : deinit                                                |
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
   return(0);
  }
//+------------------------------------------------------------------+
//| FUNCTION : start                                                 |
//| This callback is fired by metatrader for each tick               |
//+------------------------------------------------------------------+
int start(){
   int counted_bars = IndicatorCounted();
   
   _computeLastNbBars();
//----
   return(0);
  }
//+================================================================================================================+
//+=== FUNCTION : _computeLastNbBars                                                                            ===+
//+===                                                                                                          ===+
//+===                                                                                                          ===+
//+=== This callback is fired by metatrader for each tick                                                       ===+
//+===                                                                                                          ===+
//+===                                                                                                          ===+
//+================================================================================================================+
//+------------------------------------------------------------------+
//| FUNCTION : _computeLastNbBars                                    |
//| This callback is fired by metatrader for each tick               |
//| In : - lastBars : these "n" last bars must be repainted          | 
//+------------------------------------------------------------------+
double tmpArray[];

void _computeLastNbBars( ) {
  int pos;
   switch( e_type_data ){
      case PRICE_CLOSE    : ArrayCopy(tmpArray,Close,0,0,WHOLE_ARRAY); _GARCH( tmpArray); break;
      case PRICE_OPEN     : ArrayCopy(tmpArray,Open,0,0,WHOLE_ARRAY);  _GARCH( tmpArray); break;
      case PRICE_HIGH     : ArrayCopy(tmpArray,High,0,0,WHOLE_ARRAY);  _GARCH( tmpArray); break;
      case PRICE_LOW      : ArrayCopy(tmpArray,Low,0,0,WHOLE_ARRAY);   _GARCH( tmpArray); break;      
      default :
         Alert( "[ 20-ERROR  " + FILENAME + " ] the imput parameter e_type_data <" + e_type_data + "> is unknown" );
     }
    
  }
//+------------------------------------------------------------------+
//| FUNCTION : _GARCH                                                |
//| Compute GARCH ARMA indicator                                     |
//| In :                                                             |                      
//|    - inputData : data array on which the computation is applied  | 
//+------------------------------------------------------------------+
void _GARCH(double &inputData[] ) {
   int    pos;
   double GarchNum;
   double residual;
   double residualSq;
   double GarchNumVar = 0.000001;
   int posData = ArraySize(inputData)-1;
//----
   for( pos=1; pos<(ArraySize(inputData)); pos++ ) {
      if(e_reverse_data == 0){
         posData = pos;
      }
      residual = inputData[posData] - inputData[posData - 1];
      residualSq = MathPow(residual, 2.0);
      GarchNumVar = e_alpha * residualSq + e_beta * GarchNumVar;
      GarchNum = MathSqrt(GarchNumVar);
      ExtOutputBuffer[posData]=GarchNum;
      posData--;
   } 
}
