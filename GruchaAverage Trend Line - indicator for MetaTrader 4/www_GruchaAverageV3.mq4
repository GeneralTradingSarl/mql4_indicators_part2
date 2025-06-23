//+------------------------------------------------------------------+
//|                                                GruchaAverage.mq4 |
//|                                                              crn |
//|                                 gaa1@poczta.fm | www.crn.ugu.pl  |                     |
//+------------------------------------------------------------------+
#property copyright "crn"
#property link      "gaa1@poczta.fm | www.crn.ugu.pl"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue

#property indicator_color2 Red

#property indicator_color3 Lime

#property indicator_color4 Blue

extern double period=50;
extern double class_partitation_method=1;
extern bool medium_class=false;
extern int smoothing=3;

/*
      ("\nIf you need MQL CODER quote to AUTOR - polish student of computer since with big experience in mql"+" \n"+
 "\n                                     mail to:\n\n>>>>>>>>>>>>   gaa1@poczta.fm    <<<<<<<<<<< " 
  +"\n\nFOR MORE FREE FX TOOLS visit:\n \n>>>>>>>>>>>>  www.crn.ugu.pl <<<<<<<<<<<<<"+"\n\nTest GruchaCopierTool which copy orders from one MT4 to another (via internet, LAN, or on the same computer)" 
 +"\n\nLOW PRICE and HIGH QUAILTY. Check my WEBSITE and other TOOLS"
 );
*/

double ExtMapBuffer1[];

double dn[];
double up[];
double NoTrend[];
double tmp_[];

double smooth[1];
double nPeriod[1];
double hBoard[1];
double lBoard[1];
double sClass[1];
double Mo[1];
int lClass[1];

int ret=271;

string CHAR[256];

string d;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(5);
//---- indicators

   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(1,dn);
   SetIndexLabel(1,"MAdn");

   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(2,up);
   SetIndexLabel(2,"MAup");

   SetIndexBuffer(4,ExtMapBuffer1);

   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(3,NoTrend);
   SetIndexLabel(3,"NoTrend");

   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(0,tmp_);
   SetIndexLabel(0,"tmp");

   ArrayResize(smooth,smoothing);

   int nClass=NormalizeDouble(MathSqrt(period)*class_partitation_method,0);
   int nPeriods=period;

   ArrayResize(nPeriod,nPeriods);
   ArrayResize(hBoard,nClass);
   ArrayResize(lBoard,nClass);

   ArrayResize(sClass,nClass);
   ArrayResize(Mo,nClass);
   ArrayResize(lClass,nClass);

   for(int i=0; i<256; i++) CHAR[i]=CharToStr(i);
/*
   d = "\nIf you need MQL CODER mail to AUTOR (gaa1@poczta.fm) - polish student of computer since with big experience in mql"+" "+
 "                                           " 
  +"\n\nFOR MORE FREE FX TOOLS visit:  www.crn.ugu.pl"+"\n\nTest GruchaCopierTool which copy orders from one MT4 to another" ;
*/
   d="\nNeed MQL CODER? mail to AUTOR: gaa1@poczta.fm - polish ICT student; big EXPERIENCE in MQL"+" "+
     "                                           "
     +"\nFOR MORE FREE FX TOOLS visit:  >>>  www.crn.ugu.pl"+"  >>> Include MT4CopierTool!";

   Print(d);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
//int   pos=(Bars+(period+5))-(counted_bars);
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+period;

   int pos=limit;

//Comment(d);
   int nClass=NormalizeDouble(MathSqrt(period)*class_partitation_method,0);
   int nPeriods=period;

   while(pos>=0)
     {
      //licze ile bedzie klas// wyrzucielm to z petli
      ////////////////////////////////////////////////  stad
      //zbieram cene z 30 slupkow

      for(int i_period=nPeriods-1; i_period>=0; i_period--)
        {
         nPeriod[i_period]=iClose(NULL,0,i_period+pos);

         //nPeriod[i_period]=iLow(NULL,0,i_period+pos);
        }

      //ustalam granice klas    
      double max= nPeriod[ArrayMaximum(nPeriod,0,0)];
      double min= nPeriod[ArrayMinimum(nPeriod,0,0)];

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

      double result1=(Mo[s_ir]+((tmp*(step/*/nClass*/))/nPeriods));

      smooth[pos%smoothing]=result1;

      double smooth_tmp=0;
      for(int j=0; j<smoothing; j++)
        {
         smooth_tmp+=smooth[j];
        }
      double result=smooth_tmp/smoothing;

      //ExtMapBuffer1[pos] = result;
/*
            double med = (ExtMapBuffer1[pos] + ExtMapBuffer1[pos+1] 
            + ExtMapBuffer1[pos+2] + ExtMapBuffer1[pos+3] 
            + ExtMapBuffer1[pos+4] + ExtMapBuffer1[pos+5] + ExtMapBuffer1[pos+6] + ExtMapBuffer1[pos+7])
            /8;
            */
      if(result>=iClose(NULL,0,pos) /*&& ExtMapBuffer1[pos] >= iClose(0,0,pos+1) && ExtMapBuffer1[pos] >= iClose(0,0,pos+2) && ExtMapBuffer1[pos] >= iClose(0,0,pos+3)*/)
        {
         // dn[pos]= result;
         // up[pos]= EMPTY_VALUE;
         ExtMapBuffer1[pos]=-1;
        }
      else
        {
         ExtMapBuffer1[pos]=1;
         //up[pos]= result;
         //dn[pos]= EMPTY_VALUE;
        }

      tmp_[pos]=result;

      if(ExtMapBuffer1[pos]==-1 && ExtMapBuffer1[pos+1]==-1)
        {
         dn[pos]= result;
         up[pos]= EMPTY_VALUE;
         NoTrend[pos]=EMPTY_VALUE;

        }
      else if(ExtMapBuffer1[pos]==1 && ExtMapBuffer1[pos+1]==1)
        {
         up[pos]= result;
         dn[pos]= EMPTY_VALUE;
         NoTrend[pos]=EMPTY_VALUE;
        }

      pos--;
     }

   return(0);
  }
//+------------------------------------------------------------------+
