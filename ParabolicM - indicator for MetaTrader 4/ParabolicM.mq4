//+------------------------------------------------------------------+
//|                                                    Parabolic.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"
//----
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Lime
//---- input parameters
extern double    Step=0.02;
extern double    Maximum=0.2;
//---- buffers
double SarBuffer[];
//----
int    save_lastreverse;
bool   save_dirlong;
double save_start;
double save_last_high;
double save_last_low;
double save_ep;
double save_sar;
double up, down;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexBuffer(0,SarBuffer);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SaveLastReverse(int last,int dir,double start,double low,double high,double ep,double sar)
  {
   save_lastreverse=last;
   save_dirlong=dir;
   save_start=start;
   save_last_low=low;
   save_last_high=high;
   save_ep=ep;
   save_sar=sar;
  }
//+------------------------------------------------------------------+
//| Parabolic Sell And Reverse system                                |
//+------------------------------------------------------------------+
int start()
  {
   static bool first=true;
   bool   dirlong;
   double start,last_high,last_low;
   double ep,sar,price_low,price_high,price;
   int    i,counted_bars=IndicatorCounted();
//----
   if(Bars<3) return(0);
//---- initial settings
   i=Bars-2;
   if(counted_bars==0 || first)
     {
      first=false;
      dirlong=true;
      start=Step;
      last_high=-10000000.0;
      last_low=10000000.0;
      while(i>0)
        {
         save_lastreverse=i;
         if (Close[i]>=Open[i])
           {
            price_low=Open[i];
            price_high=Close[i];
           } else
           {
            price_low=Close[i];
            price_high=Open[i];
           }
         if (Close[i+1]>=Open[i+1])
           {
            down=Open[i+1];
            up=Close[i+1];
           } else
           {
            down=Close[i+1];
            up=Open[i+1];
           }
         if(last_low>price_low)   last_low=price_low;
         if(last_high<price_high) last_high=price_high;
         if(price_high>up && price_low>down) break;
         if(price_high<up && price_low<down) { dirlong=false; break; }
         i--;
        }
      //---- initial zero
      int k=i;
      while(k<Bars)
        {
         SarBuffer[k]=0.0;
         k++;
        }
      //---- check further
      if(dirlong) { SarBuffer[i]=down; ep=price_high; }
      else        { SarBuffer[i]=up; ep=price_low; }
      i--;
     }
   else
     {
      i=save_lastreverse;
      start=save_start;
      dirlong=save_dirlong;
      last_high=save_last_high;
      last_low=save_last_low;
      ep=save_ep;
      sar=save_sar;
     }
//----
   while(i>=0)
     {
      if (Close[i]>=Open[i])
        {
         price_low=Open[i];
         price_high=Close[i];
        } else
        {
         price_low=Close[i];
         price_high=Open[i];
        }
      if (Close[i+1]>=Open[i+1])
        {
         down=Open[i+1];
         up=Close[i+1];
        } else
        {
         down=Close[i+1];
         up=Open[i+1];
        }
      //--- check for reverse
      if(dirlong && price_low<SarBuffer[i+1])
        {
         SaveLastReverse(i,true,start,price_low,last_high,ep,sar);
         start=Step; dirlong=false;
         ep=price_low;  last_low=price_low;
         SarBuffer[i]=last_high;
         i--;
         continue;
        }
      if(!dirlong && price_high>SarBuffer[i+1])
        {
         SaveLastReverse(i,false,start,last_low,price_high,ep,sar);
         start=Step; dirlong=true;
         ep=price_high; last_high=price_high;
         SarBuffer[i]=last_low;
         i--;
         continue;
        }
      //---
      price=SarBuffer[i+1];
      sar=price+start*(ep-price);
      if(dirlong)
        {
         if(ep<price_high && (start+Step)<=Maximum) start+=Step;
         if(price_high<up && i==Bars-2)  sar=SarBuffer[i+1];
         //----
         price=down;
         if(sar>price) sar=price;
         price=down;
         if(sar>price) sar=price;
         if(sar>price_low)
           {
            SaveLastReverse(i,true,start,price_low,last_high,ep,sar);
            start=Step; dirlong=false; ep=price_low;
            last_low=price_low;
            SarBuffer[i]=last_high;
            i--;
            continue;
           }
         if(ep<price_high) { last_high=price_high; ep=price_high; }
        }
      else
        {
         if(ep>price_low && (start+Step)<=Maximum) start+=Step;
         if(price_low<down && i==Bars-2)  sar=SarBuffer[i+1];
         //----
         price=up;
         if(sar<price) sar=price;
         price=up;
         if(sar<price) sar=price;
         if(sar<price_high)
           {
            SaveLastReverse(i,false,start,last_low,price_high,ep,sar);
            start=Step; dirlong=true; ep=price_high;
            last_high=price_high;
            SarBuffer[i]=last_low;
            i--;
            continue;
           }
         if(ep>price_low) { last_low=price_low; ep=price_low; }
        }
      SarBuffer[i]=sar;
      i--;
     }
   //   sar=SarBuffer[0];
   //   price=iSAR(NULL,0,Step,Maximum,0);
   //   if(sar!=price) Print("custom=",sar,"   SAR=",price,"   counted=",counted_bars);
   //   if(sar==price) Print("custom=",sar,"   SAR=",price,"   counted=",counted_bars);
//----
   return(0);
  }
//+------------------------------------------------------------------+