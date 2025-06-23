//+------------------------------------------------------------------+ 
//|                                                  LW Fractals.mq4 | 
//|                                        Gosha. Copyright © 2005,  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Red
//---- input parameters 
extern int       Equals=3;
extern int       nLeftUp=1;
extern int       nRightUp=1;
extern int       nLeftDown=1;
extern int       nRightDown=1;
//---- buffers 
double FractalsUp[];
double FractalsDown[];
int pos=0, cntup=0, cntdown=0, cnt=0;
int r=0,l=0,e=0;
int fup=0,fdown=0;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int init()
  {
//---- indicators 
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,217);
   SetIndexBuffer(0,FractalsUp);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,218);
   SetIndexBuffer(1,FractalsDown);
   SetIndexEmptyValue(1,0.0);
//----
   cntup=nLeftUp+nRightUp+Equals+1;
   cntdown=nLeftDown+Equals+1;
   if (cntup>=cntdown) cnt=cntup;
   if (cntup<cntdown)  cnt=cntdown;
//---- 
   return(0);
  }
//+------------------------------------------------------------------+ 
//| Custor indicator deinitialization function                       | 
//+------------------------------------------------------------------+ 
int deinit()
  {
//---- TODO: add your code here 
//---- 
   return(0);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int start()
  {
   int i=0, j=0;
   int cbars=IndicatorCounted();
   if  (cbars<0) return(-1);
   if  (cbars>0) cbars--;
   pos=0;
   if (cbars > (Bars-cnt-1)) pos=(Bars-cnt-1);
   else pos=cbars+nRightUp;
//---
   while(pos>=nRightUp)
     {
      FractalsUp[pos]  =NULL;
      FractalsDown[pos]=NULL;
      //o?AEOAE AAA?O 
      r=nRightUp; //i?iaa?yai i?aao? noi?iio o?aeoaea 
      for(i=1;i<=r;i++)
        {
         if (High[pos]<=High[pos-i]) break;
        }
      //anee ni?aaa ana IE oi i aie?ii auou ?aaii r+1 
      if (i==r+1) //FractalsUp[pos]=High[pos]; 
        {
         l=nLeftUp;  //i?iaa?yai eaao? noi?iio o?aeoaea 
         e=Equals;
         for(j=1;j<=l+Equals;j++)
           {
            if (High[pos] < High[pos+j]) break;
            if (High[pos] > High[pos+j]) l--;
            if (High[pos]==High[pos+j])e--;
            if (l==0)
              {
               FractalsUp[pos]=High[pos];
               break;
              }
            if (e<0) break;
           }
        }
      //O?AEOAE AIEC 
      r=nRightDown; //i?iaa?yai i?aao? noi?iio o?aeoaea 
      for(i=1;i<=r;i++)
        {
         if (Low[pos]>=Low[pos-i]) break;
        }
      if (i==r+1) //FractalsUp[pos]=High[pos]; 
        {
         l=nLeftDown;  //i?iaa?yai eaao? noi?iio o?aeoaea 
         e=Equals;
         for(j=1;j<=l+Equals;j++)
           {
            if (Low[pos] > Low[pos+j]) break;
            if (Low[pos] < Low[pos+j]) l--;
            if (Low[pos]==Low[pos+j])e--;
            if (l==0)
              {
               FractalsDown[pos]=Low[pos];
               break;
              }
            if (e<0) break;
           }
        }
      pos--;
     }
//---- 
   return(0);
  }
//+------------------------------------------------------------------+

