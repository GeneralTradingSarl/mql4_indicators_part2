/********************************************************************************
 *                                                       MACD Histogram WIS.mq4 *
 *                                           MACD Histogram With Impulse System *
 *                             Copyright © 2009, G.Vladimir.Ivanovich@gmail.com *
 *                                        mailto:G.Vladimir.Ivanovich@gmail.com *
 *******************************************************************************/
#property copyright "Copyright © 2009, G.Vladimir.Ivanovich@gmail.com"
#property link      "mailto:G.Vladimir.Ivanovich@gmail.com"

/*******************************************************************************/
#property  indicator_separate_window
#property  indicator_buffers 5

#property  indicator_color1 LightGray
#property  indicator_width1 2

#property  indicator_color2 Red
#property  indicator_width2 2

#property  indicator_color3 Green
#property  indicator_width3 2

#property  indicator_color4 Maroon
#property  indicator_width4 2

#property  indicator_color5 Orange
#property  indicator_width5 2

/*******************************************************************************/
extern	int FastMA			= 12;/* Период быстрой скользящей средней          */
extern	int SlowMA			= 26;/* Период медленной скользящей средней        */
extern	int SignalMA		= 9; /* Период сигнальной линии                    */
extern	int MAPeriod		= 13;/* Период скользящей средней если Line = 0    */
extern	int MAMethod		= 1; /* Метод усреднения по умолчанию MODE_EMA     */
extern	int MAAppliedPrice	= 0; /* Используемая цена по умолчанию PRICE_CLOSE */
extern	int Line			= 0; /* Инерция 0-MA(MAPeriod); 1-MACD; 2-Signal   */
extern	int DigitsInc		= 2; /* Формат точности Digits + DigitsInc         */

/*******************************************************************************/
double	Histogram[];
double	HistogramWaitClose[];
double	HistogramSell[];
double	HistogramBuy[];
double	MACD[];
double	Signal[];
double	Filter[];

/*******************************************************************************/
int init()
{
	string Mode;
	
	SetIndexBuffer(0, HistogramWaitClose);
	SetIndexStyle(0, DRAW_HISTOGRAM);
	SetIndexEmptyValue(0, 0.0);
	SetIndexLabel(0, "Wait, Close");
	
	SetIndexBuffer(1, HistogramSell);
	SetIndexStyle(1, DRAW_HISTOGRAM);
	SetIndexEmptyValue(1, 0.0);
	SetIndexLabel(1, "Histogram Sell");
	
	SetIndexBuffer(2, HistogramBuy);
	SetIndexStyle(2, DRAW_HISTOGRAM);
	SetIndexEmptyValue(2, 0.0);
	SetIndexLabel(2, "Histogram Buy");
	
	SetIndexBuffer(3, Signal);
	SetIndexStyle(3, DRAW_LINE, STYLE_SOLID);
	SetIndexLabel(3, "Signal");
	
	SetIndexBuffer(4, MACD);
	SetIndexStyle(4, DRAW_LINE, STYLE_SOLID);
	SetIndexLabel(4, "MACD");
	
	if(Line <= 0) Mode = "MA(" + MAPeriod + ")";
	if(Line == 1) Mode = "MACD";
	if(Line >= 2) Mode = "Signal";
	
	IndicatorShortName("MACD Histogram (" + FastMA + "," + SlowMA + "," + SignalMA + ") With Filter " + Mode + "");
	IndicatorDigits(Digits + DigitsInc);
	
	return(0);
}

/*******************************************************************************/
int start()
{
	int i;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=2;
	
	BufferResize(Filter);
	BufferResize(Histogram);
	
	for(i = 0; i <= limit; i++)
		MACD[i] = iMA(NULL, 0, FastMA, 0, MAMethod, MAAppliedPrice, i) - iMA(NULL, 0, SlowMA, 0, MAMethod, MAAppliedPrice, i);
	for(i = 0; i <= limit; i++)
		Signal[i] = iMAOnArray(MACD, iBars(NULL,0), SignalMA, 0, MAMethod, i);
	for(i = 0; i <= limit; i++)
		Histogram[i] = MACD[i] - Signal[i];
	CalcFilter(Line, limit);
	for(i = limit; i >= 0; i--)
	{
		if(Histogram[i] > Histogram[i+1] && Filter[i] > Filter[i+1])
		{
			HistogramWaitClose[i] = 0.0;
			HistogramSell[i] = 0.0;
			HistogramBuy[i] = Histogram[i];
		}
		if(Histogram[i] < Histogram[i+1] && Filter[i] < Filter[i+1])
		{
			HistogramWaitClose[i] = 0.0;
			HistogramSell[i] = Histogram[i];
			HistogramBuy[i] = 0.0;
		}
		if((Histogram[i] >= Histogram[i+1] && Filter[i] <= Filter[i+1]) || (Histogram[i] <= Histogram[i+1] && Filter[i] >= Filter[i+1]))
		{
			HistogramWaitClose[i] = Histogram[i];
			HistogramSell[i] = 0.0;
			HistogramBuy[i] = 0.0;
		}
	}
	
	return(0);
}


/*******************************************************************************/
void BufferResize(double &Array[])
{
	//int counted_bars = ArraySize(Array) - 1;
	//int limit = iBars(NULL, 0) - counted_bars;
	
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit--;
 	
	ArraySetAsSeries(Array, false);
	ArrayResize(Array, iBars(NULL, 0));
	
	for(int i = limit; i >= 0; i--)
		Array[i] = 0.0;
	ArraySetAsSeries(Array, true);
}

/*******************************************************************************/
void CalcFilter(int &a, int &max)
{
	if(a <= 0)
	{
		for(int i = 0; i <= max; i++)
			Filter[i] = iMA(NULL, 0, MAPeriod, 0, MAMethod, MAAppliedPrice, i);
		return;
	}
	if(a == 1)
	{
		ArrayCopy(Filter, MACD);
		return;
	}
	if(a >= 2)
		ArrayCopy(Filter, Signal);
}

/*******************************************************************************/

