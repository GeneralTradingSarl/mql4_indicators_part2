//+------------------------------------------------------------------+
//|                                                          Mix.mq4 |
//|                                                    karceWZROKIEM |
//|                                            http://www.kampno.pl/ |
//+------------------------------------------------------------------+
#property copyright "karceWZROKIEM"
#property link      "http://www.kampno.pl/"

#property indicator_separate_window

#property indicator_buffers 5
#property indicator_color1 Black
#property indicator_color2 Red
#property indicator_color3 Silver
#property indicator_color4 Blue
#property indicator_style4 STYLE_DASH
#property indicator_color5 Blue

#property indicator_maximum 125
#property indicator_minimum -125

//---- input parameters
extern string ________________01="List of MAs, eg form fiobo: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597";
extern string listMA="1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233";
extern string ________________02="MA to check SORT DEGREE";
extern int MAcheck=8;

extern string ________________10="MA sort type";
extern int MAmethod = 1;               // iMA moving average method:	
                                       //          0	Simple moving average,
                                       //          1	Exponential moving average,
                                       //          2	Smoothed moving average,
                                       //          3	Linear weighted moving average.

//---- buffers
double openOrder[];
double closeOrder[];
double Trend[];
double MAsortRel[];
double sortRel[];


int MAs[];
int cntMAs;
double maVal[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexBuffer(0,openOrder);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,159);
   SetIndexBuffer(1,closeOrder);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Trend);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,MAsortRel);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,sortRel);
//---- name for DataWindow and indicator subwindow label
   short_name="madnessMA("+MAcheck+" -> "+listMA+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Open");
   SetIndexLabel(1,"Close");
   SetIndexLabel(2,"TrendDegree");
   SetIndexLabel(3,"MASortDegree");
   SetIndexLabel(4,"SortDegree");
//----
   SetLevelValue(0,80);
   SetLevelValue(1,-80);
   SetLevelStyle(STYLE_SOLID,1,Silver);
//----
   cntMAs = splitINT(MAs, listMA, ",");
   ArrayResize(maVal, cntMAs+1);
   
   return(0);
  }
//+------------------------------------------------------------------+
double Trend(int MA, int i)
{  
   //return (Close[i] - iMA(NULL,0,MA,0,MAmethod,PRICE_OPEN,i));
   return (Close[i] - maVal[MA]);
}
double sortRel(int MA1, int MA2, int i)
{  
   //return (iMA(NULL,0,MA2,0,MAmethod,PRICE_OPEN,i) - iMA(NULL,0,MA1,0,MAmethod,PRICE_OPEN,i));
   return (maVal[MA2] - maVal[MA1]);
}
////////////////////////////////////////////////////////////////////
int start()
{
   int    counted_bars,i,j,k;
   double tmp;
   double TrendSUM = 0, TrendBUFF = 0;
   double sortRelSUM = 0, sortRelBUFF = 0;
   double MAsortRelSUM = 0, MAsortRelBUFF = 0;

   //if(Bars<=MA) return(0);
   
   counted_bars=IndicatorCounted();          // Number of counted bars
   i=Bars-counted_bars-1;                    // Index of the first uncounted
   
   while(i>=0)
   {  
      setMAs(i);
      TrendSUM = 0; TrendBUFF = 0;
      MAsortRelSUM = 0; MAsortRelBUFF = 0;

      for(int ii=0; ii<cntMAs; ii++)
      {
         //tmp = sortRel(MAs[ii], MAcheck, i);
         tmp = sortRel(ii, cntMAs, i);
         if(MAs[ii] > MAcheck) tmp = 1*tmp; else tmp = -1*tmp;
         MAsortRelBUFF += tmp;
         MAsortRelSUM += MathAbs(tmp);

         //tmp = Trend(MAs[ii], i);
         tmp = Trend(ii, i);
         TrendBUFF += tmp;
         TrendSUM += MathAbs(tmp);
         if(ii-1<cntMAs)
         {
            sortRelSUM = 0; sortRelBUFF = 0;
            
            for(int iii=0; iii<cntMAs; iii++)
            if(ii!=iii)
            {
               //tmp = sortRel(MAs[ii], MAs[iii], i);
               tmp = sortRel(ii, iii, i);
               sortRelBUFF += tmp;
               sortRelSUM += MathAbs(tmp);
            }
         }
      }
         //Print("Trend: B "+TrendBUFF+" S "+TrendSUM);
         //   Print("sortRel: B "+sortRelBUFF+" S "+sortRelSUM);
      if(TrendSUM>0)Trend[i] = 100 * TrendBUFF / TrendSUM;
      if(sortRelSUM>0)sortRel[i] = 100 * sortRelBUFF/sortRelSUM;
      if(MAsortRelSUM>0)MAsortRel[i] = 100 * MAsortRelBUFF/MAsortRelSUM;
      
      if( sortRel[i] < Trend[i] && sortRel[i] <= MAsortRel[i] && sortRel[i] < 0)
         openOrder[i] = 110;
      else if( sortRel[i] > Trend[i] && sortRel[i] >= MAsortRel[i]  && sortRel[i] > 0)
         openOrder[i] = -110;
      else openOrder[i] = EMPTY_VALUE;
      
      if( (Trend[i] < Trend[i+1]  && sortRel[i] < Trend[i] ) || openOrder[i] == -110 )
         closeOrder[i] = 110;
      else if( (Trend[i] > Trend[i+1]  && sortRel[i] > Trend[i] ) || openOrder[i] == 110 )
         closeOrder[i] = -110;
      else closeOrder[i] = EMPTY_VALUE;
      
      i--;
   }
   return(0);
}
//+------------------------------------------------------------------+

int splitINT(int& arr[], string str, string sym) 
{
  ArrayResize(arr, 0);
  string item;
  int pos, size;
  
  int len = StringLen(str);
  for (int i=0; i < len;) {
    pos = StringFind(str, sym, i);
    if (pos == -1) pos = len;
    
    item = StringSubstr(str, i, pos-i);
    item = StringTrimLeft(item);
    item = StringTrimRight(item);
    
    size = ArraySize(arr);
    ArrayResize(arr, size+1);
    arr[size] =  StrToInteger(item);
    
    i = pos+1;
  }
  return (ArraySize(arr));
}

void setMAs(int i)
{
   for(int index=0; index<cntMAs; index++)
   maVal[index] = iMA(NULL,0,MAs[index],0,MAmethod,PRICE_CLOSE,i);
   maVal[cntMAs] = iMA(NULL,0,MAcheck,0,MAmethod,PRICE_CLOSE,i);
}