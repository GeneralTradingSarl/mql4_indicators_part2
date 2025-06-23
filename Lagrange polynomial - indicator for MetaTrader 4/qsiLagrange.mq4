//+------------------------------------------------------------------+
//|                                         		      siLagrange.mq4 |
//|                                 Copyright © 2007 Сергеев Алексей |
//|                                              profy.mql@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007-2011, Сергеев Алексей "
#property link      "mailto: profy.mql@gmail.com"
//----
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 SkyBlue
#property indicator_color2 Crimson
#property indicator_color3 Crimson
//----
extern int Pow=3;//Степень полинома Лагранжа. Желательно 3..8
extern int Depth=12;//минимальное расстояние между опорными точками
extern int Mode=MODE_HIGH;//MODE_HIGH, MODE_LOW, MODE_CLOSE
extern int TimeFrame=0;
extern int Shift=10;//На сколько баров продлеваем в будущее
//----
double Lx[];//Полином Лагранжа
double Lx0[];//Полином Лагранжа в будущее на shift баров
double Pnt[];//Индикатор опорных точек построения

int X[];//Номера баров по которым строится полином
double Y[];//Значения цены в точках (O, H, L или C)
double C[];//Коэффициенты полинома
//-----------------------------------------------------------	Lagrange
int init()
{	
//---- indicator line
	SetIndexBuffer(0,Lx); SetIndexStyle(0,DRAW_LINE);
	SetIndexBuffer(1,Lx0); SetIndexStyle(1,DRAW_LINE); SetIndexShift(1, Shift); 
	SetIndexBuffer(2,Pnt); SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2, 159);

	ArrayResize(X, Pow); ArrayResize(Y, Pow); ArrayResize(C, Pow);

	return(0);
}
//-----------------------------------------------------------	Lagrange
int start()
{
	if (Pow<=1) Pow = 2;//проверка корректности
	if (Pow>=21) Pow = 20;//проверка корректности

	//0. Определяем таблицу значений X и Y для построения полинома 
	FindPoint();
	//
	Lagrange();
	//----
	return(0);
}
//-----------------------------------------------------------	FindPoint
void FindPoint()
{
	int pos, pos2, pos_prev = -1;
	if (Depth<=0) Depth=2;
	int i=Depth;
	int n=0;//счетчик точек (до Pow)
	while((i<Bars-Depth) && (n<Pow))
	{
		if (Mode==MODE_HIGH)
		{
			pos = iHighest(NULL,0,MODE_HIGH,2*Depth+1,i-Depth);	pos2 = iHighest(NULL,0,MODE_HIGH,2*Depth+1,pos-Depth); 
			if ((pos==pos2)&&(pos!=pos_prev))
			{
				X[n] = pos; Y[n]=High[pos]; n++; 
				pos_prev = pos; 
			}
		}
		if (Mode==MODE_LOW)
		{
			pos = iLowest(NULL,0,MODE_LOW,2*Depth+1,i-Depth);	pos2 = iLowest(NULL,0,MODE_LOW,2*Depth+1,pos-Depth); 
			if ((pos==pos2)&&(pos!=pos_prev))
			{
				X[n] = pos; Y[n]=Low[pos]; n++; 
				pos_prev = pos; 
			}
		}
		i++;
	}
}
//-----------------------------------------------------------	Lagrange
void Lagrange()
{
	int i, j, b;
	//1. Найдем коэффициенты полинома
	for (i = 0; i<Pow; i++)
	{
		C[i] = 1.0;
		for (j = 0; j<Pow; j++)
			 if (j != i)  C[i] = C[i]*(X[i]-X[j]);
		C[i] = Y[i]/C[i];
	}
	// 2. Теперь проходя по всем барам до масимального бара, указанного в расчете полинома 
	//расчитываем сам полином (индикатор Lx)
	int bars = X[ArrayMaximum(X)];
	double sx;
	for (b = 0; b<=bars; b++)
	{
		Lx[b] = 0.0; Pnt[b] = 0;
		for (i = 0; i<Pow; i++)
		{
			sx = 1;
			for (j = 0; j<Pow; j++)
				if (j != i)	sx = sx*(b-X[j]);
			Lx[b] = Lx[b]+C[i]*sx;
		}
	}
	//3. Заполнили массив опорных точек
	for (i = 0; i<Pow; i++) Pnt[X[i]] = Y[i];

	//4. И строем индикатор Lx0 в будущее на Shift
	ArrayInitialize(Lx0, EMPTY_VALUE);
	for (b = -Shift; b<=0; b++)
	{
		Lx0[b+Shift] = 0.0;
		for (i = 0; i<Pow; i++)
		{
			sx = 1;
			for (j = 0; j<Pow; j++)
				if (j != i)	sx = sx*(b-X[j]);
			Lx0[b+Shift] = Lx0[b+Shift]+C[i]*sx;
		}
	}
}