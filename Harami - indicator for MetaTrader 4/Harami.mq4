//+------------------------------------------------------------------+
//|                                                       Harami.mq4 |
//|                                 Copyright © 2009, Paul Stringer. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Paul Stringer."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Cyan

//---- input parameters
extern int       MinMasterSize = 40;
extern int       MaxMasterSize = 500;
extern int       MinHaramiSize = 20;
extern int       MaxHaramiSize = 300;
extern double	 MaxRatioHaramiToMaster = 0.75;
extern double	 MinRatioHaramiToMaster = 0.5;
extern int       ArrowOffSet = 35;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,218);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,217);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(1,0.0);
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
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+1;

	int	_ProcessBarIndex = 0;
	int _SubIndex = 0;
	double _Max = 0;
	double _Min = 0;
	double _SL = 0;
	double _TP = 0;
	bool _WeAreInPlay = false;
	int _EncapsBarIndex = 0;
	string _Name;
	
	double _MasterBarSize = 0;
	double _HaramiBarSize = 0;
	
	// Process any bars not processed
	for ( _ProcessBarIndex = 1; _ProcessBarIndex <= limit; _ProcessBarIndex++ ) 
	{
		// Get the bar sizes
		_MasterBarSize = MathAbs ( Open [ _ProcessBarIndex + 1 ] - Close [ _ProcessBarIndex + 1 ] );
		_HaramiBarSize = MathAbs ( Open [ _ProcessBarIndex ] - Close [ _ProcessBarIndex ] );
		
		// Ensure no "zero-divide" errors
		if ( _MasterBarSize > 0) 
		{
			// Ensure the Master & Harami bars satisfy the ranges
			if (
				( _MasterBarSize < ( MaxMasterSize * Point ) ) && 
				( _MasterBarSize > ( MinMasterSize * Point ) ) &&
				( _HaramiBarSize < ( MaxHaramiSize * Point ) ) && 
				( _HaramiBarSize > ( MinHaramiSize * Point ) ) &&
				( ( _HaramiBarSize / _MasterBarSize ) <= MaxRatioHaramiToMaster ) && 
				( ( _HaramiBarSize / _MasterBarSize ) >= MinRatioHaramiToMaster )
				)
			{

				// Is it reversal in favour of a BEAR reversal...
				if ( 
					( Open [ _ProcessBarIndex + 1 ] > Close [ _ProcessBarIndex + 1 ] ) &&
					( Open [ _ProcessBarIndex ] < Close [ _ProcessBarIndex ] ) &&
					( Close [ _ProcessBarIndex + 1 ] < Open [ _ProcessBarIndex ] ) && 
					( Open [ _ProcessBarIndex + 1 ] > Close [ _ProcessBarIndex ] ) 
					)
				{
					// Reversal favouring a bull coming...
					ExtMapBuffer2 [ _ProcessBarIndex - 1 ] = Open [ _ProcessBarIndex -1 ] - ( ArrowOffSet * Point );
				} 

				// Is it reversal in favour of a BULL reversal...
				if ( 
					( Open [ _ProcessBarIndex + 1 ] < Close [ _ProcessBarIndex + 1 ] ) &&
					( Open [ _ProcessBarIndex ] > Close [ _ProcessBarIndex ] ) &&
					( Close [ _ProcessBarIndex + 1 ] > Open [ _ProcessBarIndex ] ) && 
					( Open [ _ProcessBarIndex + 1 ] < Close [ _ProcessBarIndex ] ) 
					)
				{
					// Reversal favouring a bull coming...
					ExtMapBuffer1 [ _ProcessBarIndex -1 ] = High [ _ProcessBarIndex - 1 ] + ( ArrowOffSet * Point );
				}
			}
		}
	}
	
	// Finished...
	return(0);
}
//+------------------------------------------------------------------+