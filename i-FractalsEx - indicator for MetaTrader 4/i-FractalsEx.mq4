
#property copyright "© 2007 RickD"
#property link      "www.e2e-fx.net"

#define major   1
#define minor   0

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Yellow
#property indicator_width1  1
#property indicator_width2  1


extern int FrPeriod = 6;
extern int MaxBars = 500;


double upper_fr[];
double lower_fr[];

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void init() {
  SetIndexBuffer(0, upper_fr);
  SetIndexBuffer(1, lower_fr);
  
  SetIndexEmptyValue(0, 0);
  SetIndexEmptyValue(1, 0);
  
  SetIndexStyle(0, DRAW_ARROW);
  SetIndexArrow(0, 234);

  SetIndexStyle(1, DRAW_ARROW);
  SetIndexArrow(1, 233);  
}

void start() 
{
  int counted = IndicatorCounted();
  if (counted < 0) return (-1);
  if (counted > 0) counted--;
  
  int limit = MathMin(Bars-counted, MaxBars);
  
  //-----
  
  double dy = 0;
  for (int i=1; i <= 20; i++) {
    dy += 0.3*(High[i]-Low[i])/20;
  }
  
  for (i=0+FrPeriod; i <= limit+FrPeriod; i++) 
  {
    upper_fr[i] = 0;
    lower_fr[i] = 0;
  
    if (is_upper_fr(i, FrPeriod)) upper_fr[i] = High[i]+dy;
    if (is_lower_fr(i, FrPeriod)) lower_fr[i] = Low[i]-dy;
  }
}

bool is_upper_fr(int bar, int period) 
{
  for (int i=1; i<=period; i++) 
  {
    if (bar+i >= Bars || bar-i < 0) return (false);

    if (High[bar] < High[bar+i]) return (false);
    if (High[bar] < High[bar-i]) return (false);
  }
  
  return (true);
}

bool is_lower_fr(int bar, int period) 
{
  for (int i=1; i<=period; i++) 
  {
    if (bar+i >= Bars || bar-i < 0) return (false);
    
    if (Low[bar] > Low[bar+i]) return (false);
    if (Low[bar] > Low[bar-i]) return (false);
  }
  
  return (true);
}

);
}

