//+------------------------------------------------------------------+
//|                                    Non Repainting SuperTrend.mq4 |
//|                     Copyright © 2012, Marketcalls (Rajandran R). |
//|                                        http://www.marketcalls.in |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Marketcalls"
#property link      "http://www.marketcalls.in"

#property indicator_chart_window
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_width3 1
#property indicator_width4 1
#property indicator_buffers 4
double TrendUp[],TrendDown[];
double UpBuffer[];
double DnBuffer[];

int changeOfTrend;
extern int Nbr_Periods=10;
extern double Multiplier=4.0;

//---- input parameters
extern int sidFontSize=30;
extern string sidFontName="Ariel";
extern string NoteRedGreenBlue="Red/Green/Blue each 0..255";
extern int sidRed=30;
extern int sidGreen= 30;
extern int sidBlue = 30;
extern int sidXPos = 30;
extern int sidYPos = 150;

extern bool tagDisplayText=true;
extern string tagText="www.marketcalls.in";
extern int tagFontSize=15;
extern string tagFontName="Ariel";
extern int tagRed=30;
extern int tagGreen= 30;
extern int tagBlue = 30;
extern int tagXPos = 200;
extern int tagYPos = 300;

//---- data
string SID = "Symbol";
int sidRGB = 0;
string TAG = "Tag";
int tagRGB = 0;
string tf;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0,TrendUp);
   SetIndexStyle(0,DRAW_LINE,1,1);
   SetIndexLabel(0,"Trend Up");
   SetIndexBuffer(1,TrendDown);
   SetIndexStyle(1,DRAW_LINE,1,1);
   SetIndexLabel(1,"Trend Down");

   SetIndexStyle(2,DRAW_ARROW,EMPTY);
   SetIndexStyle(3,DRAW_ARROW,EMPTY);

   SetIndexBuffer(2,UpBuffer);
   SetIndexBuffer(3,DnBuffer);

   SetIndexArrow(2,233);
   SetIndexArrow(3,234);

   SetIndexLabel(3,"Up Signal");
   SetIndexLabel(4,"Down Signal");

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete(SID);
   ObjectDelete(TAG);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

   double ClosePrice=Close[0];

//      watermark(TAG, tagText, tagFontSize, tagFontName, tagRGB, tagXPos, tagYPos); 
   string str=StringConcatenate("www.marketcalls.in      LTP : ",ClosePrice);
   watermarkclose(TAG,str,22,tagFontName,tagRGB,80,20);

   int i,flag,flagh,trend[];
   double up[],dn[],medianPrice,atr;

   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;

//Print(limit);

   int size=ArraySize(TrendUp);
   ArrayResize(trend,size);
   ArrayResize(up,size);
   ArrayResize(dn,size);
//----
   for(i=limit; i>=1; i--) 
     {
      TrendUp[i]=EMPTY_VALUE;
      TrendDown[i]=EMPTY_VALUE;
      atr=iATR(NULL,0,Nbr_Periods,i);
      //Print("atr: "+atr[i]);
      medianPrice=(High[i]+Low[i])/2;
      //Print("medianPrice: "+medianPrice[i]);
      up[i]=medianPrice+(Multiplier*atr);
      //Print("up: "+up[i]);
      dn[i]=medianPrice-(Multiplier*atr);
      //Print("dn: "+dn[i]);
      trend[i]=1;

      if(Close[i]>up[i+1]) 
        {
         trend[i]=1;
         if(trend[i+1]==-1) changeOfTrend=1;
         //Print("trend: "+trend[i]);

        }
      else if(Close[i]<dn[i+1]) 
        {
         trend[i]=-1;
         if(trend[i+1]==1) changeOfTrend=1;
         //Print("trend: "+trend[i]);
        }
      else if(trend[i+1]==1) 
        {
         trend[i]=1;
         changeOfTrend=0;
        }
      else if(trend[i+1]==-1) 
        {
         trend[i]=-1;
         changeOfTrend=0;
        }

      if(trend[i]<0 && trend[i+1]>0) 
        {
         flag=1;
         //Print("flag: "+flag);
        }
      else 
        {
         flag=0;
         //Print("flagh: "+flag);
        }

      if(trend[i]>0 && trend[i+1]<0) 
        {
         flagh=1;
         //Print("flagh: "+flagh);
        }
      else 
        {
         flagh=0;
         //Print("flagh: "+flagh);
        }

      if(trend[i]>0 && dn[i]<dn[i+1])
         dn[i]=dn[i+1];

      if(trend[i]<0 && up[i]>up[i+1])
         up[i]=up[i+1];

      if(flag==1)
         up[i]=medianPrice+(Multiplier*atr);

      if(flagh==1)
         dn[i]=medianPrice-(Multiplier*atr);

      //-- Draw the indicator
      if(trend[i]==1) 
        {
         TrendUp[i]=dn[i];
         if(changeOfTrend==1) 
           {
            TrendUp[i+1] = TrendDown[i+1];
            changeOfTrend= 0;
           }
        }
      else if(trend[i]==-1) 
        {
         TrendDown[i]=up[i];
         if(changeOfTrend==1) 
           {
            TrendDown[i+1]= TrendUp[i+1];
            changeOfTrend = 0;
           }

        }
      if(trend[i]==1 && trend[i+1]==-1) 
        {
         UpBuffer[i] = iLow(Symbol(),0,i)-(3*Point);
         DnBuffer[i] = EMPTY_VALUE;

        }
      if(trend[i]==-1 && trend[i+1]==1) 
        {
         UpBuffer[i] = EMPTY_VALUE;
         DnBuffer[i] = iHigh(Symbol(),0,i)+(3*Point);
        }

     }
   WindowRedraw();

//----
   return(0);
  }
//+------------------------------------------------------------------+

void watermarkclose(string obj,string text,int fontSize,string fontName,color colour,int xPos,int yPos)
  {
   ObjectCreate(obj,OBJ_LABEL,0,0,0);
   ObjectSetText(obj,text,fontSize,fontName,Red);
   ObjectSet(obj,OBJPROP_CORNER,0);
   ObjectSet(obj,OBJPROP_XDISTANCE,xPos);
   ObjectSet(obj,OBJPROP_YDISTANCE,yPos);
   ObjectSet(obj,OBJPROP_BACK,true);
  }
//+------------------------------------------------------------------+
