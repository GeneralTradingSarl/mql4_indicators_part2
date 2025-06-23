//+------------------------------------------------------------------+
//|                                                 Grucha Index.mq4 |
//|                                                   gaa1@poczta.fm |
//|                                                   www.crn.ugu.pl |
//+------------------------------------------------------------------+
#property copyright "Grzegorz Antosiewicz"
#property link      "gaa1@poczta.fm www.crn.ugu.pl"

#property indicator_chart_window
#property indicator_buffers 3

#property indicator_color1 Red
#property indicator_color2 Orange
#property indicator_color3 Orange

extern double period=15;
extern double class_partitation_method=1;
extern bool medium_class=false;

double ExtMapBuffer1[];
double top[];
double bottom[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(3);
//---- indicators
   SetIndexStyle(0,DRAW_LINE);

   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,"MA");

   SetIndexStyle(1,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(1,top);
   SetIndexLabel(1,"TOP");

   SetIndexStyle(2,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(2,bottom);
   SetIndexLabel(2,"BOTTOM");


   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
/*   Comment("\nIf you need MQL CODER quote to AUTOR - polish student of computer since with big experience in mql"+" \n"+
           "\n                                     mail to:\n\n>>>>>>>>>>>>   gaa1@poczta.fm    <<<<<<<<<<< "
           +"\n\nFOR MORE FX TOOLS visit:\n \n>>>>>>>>>>>>  www.crn.ugu.pl <<<<<<<<<<<<<"
           +"\n\nLOW PRICE and HIGH QUAILTY"
           );
*/
   
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+period;
   
   int pos=limit;
      
   int nClass=NormalizeDouble(MathSqrt(period)*class_partitation_method,0);
   int nPeriods=period;

   double nPeriod[],stdDEV[];
   ArrayResize(nPeriod,nPeriods);
   ArrayResize(stdDEV,nPeriods);

   double hBoard[],lBoard[];
   ArrayResize(hBoard,nClass);
   ArrayResize(lBoard,nClass);

   double sClass[];
   double Mo[];
   int lClass[];

   ArrayResize(sClass,nClass);
   ArrayResize(Mo,nClass);
   ArrayResize(lClass,nClass);

   while(pos>=0)
     {
      //licze ile bedzie klas// wyrzucielm to z petli
      ////////////////////////////////////////////////  stad
      //zbieram cene z 30 slupkow
      for(int i_period=nPeriods-1; i_period>=0; i_period--)
        {
         nPeriod[i_period]=iClose(NULL,0,i_period+pos);
         //stdDEV[i_period+pos]=nPeriod[i_period] 
        }

      //ustalam granice klas    

      double max= nPeriod[ArrayMaximum(nPeriod,WHOLE_ARRAY,0)];
      double min= nPeriod[ArrayMinimum(nPeriod,WHOLE_ARRAY,0)];

      double step=(max-min)/nClass;

      //Print(max,"  ",min);  
      //granice klas
/*
   double hBoard[], lBoard[];
   
   ArrayResize(hBoard,nClass);   
   ArrayResize(lBoard,nClass);  
   */

      double hB= max;
      double lB= min;

      int nStep=0;

      while(nStep<nClass)
        {

         if(nStep!=0)
           {
            hB=hB-step;
           }

         lB=hB;

         hBoard[nStep]=hB+( (Point/10)*5 );
         lBoard[nStep]=lB-(step)-( (Point/10)*5 );


         //Print(nStep,"  ",hBoard[nStep],"   ",lBoard[nStep]);
         if(lBoard[nStep]<min)
           {break;}

         nStep++;
        }

      // dziele naklasy i oblcizam dane

      //obliczanie n klasy i mediany

      double s_tmp=0;
      int l_tmp=0;


      for(int ic=0; ic<nClass; ic++)
        {
         s_tmp=0;
         l_tmp=0;

         for(int icc=0; icc<nPeriods; icc++)
           {
            if(nPeriod[icc]<hBoard[ic] && nPeriod[icc]>lBoard[ic])
              {
               s_tmp+=nPeriod[icc];
               l_tmp++;
              }
            sClass[ic]=s_tmp;
            lClass[ic]=l_tmp;

            if(l_tmp%2==0)
              {
               Mo[ic]=nPeriod[l_tmp/2];
              }
            else
              {
               Mo[ic]=((((nPeriod[l_tmp/2])+0.5)+((nPeriod[l_tmp/2])-0.5))/2);
              }

           }

         //Print(lClass[ic],"   ",sClass[ic],"  ",ic);
        }

      // rangi i wynik mnozenia

      //lClass[3]=34;
      int s_ir=0;

      if(ArrayRange(lClass,0)%2==0 && medium_class)
        {
         s_ir=ArrayRange(lClass,0)/2;
        }
      else
        {
         s_ir=ArrayMaximum(lClass);
        }


      int tmp=0;

      for(int ir=0; ir<nClass; ir++)
        {
         sClass[ir]=(((ir-s_ir)%nClass))*lClass[ir];
         tmp+=sClass[ir];
         //Print(sClass[ir]); 
        }

      double result=(Mo[s_ir]+((tmp*(step/*/nClass*/))/nPeriods));

      ////////licze odchylenie

      double std=0,std_tmp1=0;
      for(int iii_period=nPeriods-1; iii_period>=0; iii_period--)
        {
         std_tmp1=iClose(NULL,0,iii_period+pos)-result;
         //std_tmp1 = iii_period - 14.5;
         std_tmp1*=std_tmp1;
         std+=std_tmp1;
        }

      std/=(nPeriods-1);
      std = MathSqrt(std);

      //  double MA=iMA(0,0,nPeriods,0,0,0,pos);

      double MA=result;

      ExtMapBuffer1[pos]=MA;
      top[pos]=MA+(MA*std);
      bottom[pos]=MA-(MA*std);

      pos--;
     }
   return(0);
  }
//+------------------------------------------------------------------+
