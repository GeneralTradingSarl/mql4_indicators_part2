//+------------------------------------------------------------------+
//|                                            Indicador de algo.mq4 |
//|                                                          Gabito. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Gabito."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green
//---- buffers
double Buffer1[];
double Buffer2[];
double cuenta;
double cuenta1;
int Periodo=11;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(0,Buffer1);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(1,Buffer2);
     
   
//----
   return(0);
  }
//----
int start()
  {
   int i,counted_bars=IndicatorCounted();
//----
   if(Bars<=Periodo) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=Periodo;i++) Buffer1[Bars-i]=0.0;
//----
   i=Bars-Periodo-1;
   if(counted_bars>=Periodo) i=Bars-counted_bars-1;
   while(i>=0)
     {
     if(Close[i]>Open[i]) // up
     {
      cuenta=((((High[i]-Low[i]))*10000));
      cuenta1=(((Volume[i]-cuenta)));
      Buffer2[i]=((Volume[i]-(cuenta))/2)+cuenta;
      Buffer1[i]=Volume[i]-Buffer2[i];
     }
     if(Close[i]<Open[i]) // down
     {
      cuenta1=((((High[i]-Low[i]))*10000));
      cuenta=(((Volume[i]-cuenta1)));
      Buffer1[i]=((Volume[i]-(cuenta1))/2)+cuenta1;
      Buffer2[i]=Volume[i]-Buffer1[i];
     }
     if(Close[i]==Open[i]) // equal
     {
      cuenta=((Volume[i]/2));
      Buffer1[i]=cuenta;
      Buffer2[i]=Volume[i]-Buffer1[i];
     }
      i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+