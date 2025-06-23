//+------------------------------------------------------------------+
//|                                      		        	 MACDonRSI.mq4 |
//|                                 Copyright © 2008 Сергеев Алексей |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Сергеев Алексей "
//----
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 LimeGreen
#property indicator_color2 Crimson
#property indicator_color3 Blue
#property indicator_level1 70
#property indicator_level2 30
//----
extern int MA=5;
extern int RSIperiod=3;
extern int FastEMA=10;
extern int SlowEMA=20;
extern int SignalSMA=5;
//----
double BufRSI[];
double BufMACD[];
double BufSign[];
double BufMA[];

int init()
{
//---- indicator line
	IndicatorBuffers(4);
	SetIndexBuffer(0,BufRSI); SetIndexStyle(0,DRAW_LINE);
	SetIndexBuffer(1,BufMACD); SetIndexStyle(1,DRAW_HISTOGRAM);
	SetIndexBuffer(2,BufSign); SetIndexStyle(2,DRAW_LINE);
	SetIndexBuffer(3,BufMA); SetIndexStyle(3,DRAW_NONE);
	return(0);
}

int start()
{
	int i;
	for(i=0; i<Bars; i++) BufMA[i]=iMA(NULL,0,MA,0, MODE_EMA, PRICE_CLOSE, i);
	for(i=0; i<Bars; i++) BufRSI[i]=iRSIOnArray(BufMA,Bars,RSIperiod,i);
	for(i=0; i<Bars; i++) BufMACD[i]=8*(iMAOnArray(BufRSI,Bars,FastEMA,0,MODE_EMA,i)-iMAOnArray(BufRSI,Bars,SlowEMA,0,MODE_EMA,i));
	for(i=0; i<Bars; i++) BufSign[i]=iMAOnArray(BufMACD,Bars,SignalSMA,0,MODE_SMA,i);
	//----
	return(0);
}
//+------------------------------------------------------------------+