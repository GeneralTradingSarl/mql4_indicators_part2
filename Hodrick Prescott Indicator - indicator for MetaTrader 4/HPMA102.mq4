//+--------------------------------------------------------------------------+
//|                                                                 HPMA.mq4 |
//| Hodrick-Prescott filter MA                                               |
//| based on HP filter implementation by gwpr (http://codebase.mql4.com/5169)|
//+--------------------------------------------------------------------------+
#define IND "HPMA"
#define VER "1_02"
#property copyright "ryaz"
#property link      "outta@here"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Gray
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Olive
#property indicator_color5 Indigo
#property indicator_color6 Indigo
#property indicator_color7 SeaGreen
#property indicator_color8 SeaGreen

//Input parameters
extern int nobs=150; //Number of bars to process for filter evaluation
extern double lambda=1600; //Higher lambda leads to the smoother data
extern int timeframe=0;//The applied timeframe, 0=the same as chart
extern int price=PRICE_CLOSE;//The applied price
extern int delay=0; //Shows the result of delaying (or advancing if negative) the HP filter
extern int trend=10; //how many consecutive filter bars to check to determine trend
extern int future=8; //How many bars in the future to display for the HP filter
extern int bands= 0; //how many bars to include in bands calculation
extern double band1 =2; //deviations for first band
extern double band2 =2; //deviations for second Band
extern int type1=-1; //Type for the first band -1=Filter Band or else Price Band 0=applied price 1=mean 2=exterme High/Low 3=inside High/Low 4=median 5=typical 6=weighted
extern int type2=0; //Type for second band as above
extern bool repaint =FALSE; //To repaint last bar, FALSE for faster execution
extern bool points  =FALSE; //Plot up/downtrend as points instead of line
extern bool alerts  =FALSE; //Enable visual alert
extern string audio="alert.wav"; //Enable audioalert
extern int history=500; //history bars to display on initialisation, 0 means all history
                        //Indicator buffers
double hp0[],hpu0[],hpd0[],hpf0[],fhi0[],flo0[],phi0[],plo0[];
//Global vars
double hp[],hpu[],hpd[],hpf[],fhi[],flo[],phi[],plo[];
double dat[],a[],b[],c[];
datetime time;
string tframe;
bool alerting;
bool showf;
//+----------------------------------------------------------------------------------------+
int init()
  {
   if(timeframe==0) timeframe=Period();
   SetIndexBuffer(0,hp0);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexLabel(0,"hpma");
   SetIndexBuffer(1,hpu0);
   SetIndexLabel(1,"up");
   SetIndexBuffer(2,hpd0);
   SetIndexLabel(2,"down");
   if(points)
     {
      SetIndexStyle(1,DRAW_ARROW);
      SetIndexArrow(1,4);
      SetIndexStyle(2,DRAW_ARROW);
      SetIndexArrow(2,4);
        } else {
      SetIndexStyle(1,DRAW_LINE);
      SetIndexStyle(2,DRAW_LINE);
     }
   SetIndexBuffer(3,hpf0);
   if(trend>0)
     {
      SetIndexStyle(3,DRAW_LINE);
      SetIndexLabel(3,"filter");
      SetIndexShift(3,future);
     }
   else
      SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(4,fhi0);
   SetIndexBuffer(5,flo0);
   SetIndexBuffer(6,phi0);
   SetIndexBuffer(7,plo0);
   if(history==0) history=iBarShift(NULL,0,iTime(NULL,timeframe,iBars(NULL,timeframe)-nobs));
   SetIndexDrawBegin(0,Bars-history);
   SetIndexDrawBegin(1,Bars-history);
   SetIndexDrawBegin(2,Bars-history);
   SetIndexDrawBegin(3,Bars-history+future);
   if(bands>0 && band1!=0)
     {
      SetIndexLabel(4,"Fhi");
      SetIndexLabel(5,"Flo");
      SetIndexStyle(4,DRAW_LINE);
      SetIndexStyle(5,DRAW_LINE);
      if(band1>0)
        {
         SetIndexDrawBegin(4,Bars-history);
         SetIndexDrawBegin(5,Bars-history);
        }
        } else {
      SetIndexStyle(4,DRAW_NONE);
      SetIndexStyle(5,DRAW_NONE);
     }
   if(bands>0 && band2!=0)
     {
      SetIndexLabel(6,"Phi");
      SetIndexLabel(7,"Plo");
      SetIndexStyle(6,DRAW_LINE);
      SetIndexStyle(7,DRAW_LINE);
      if(band2>0)
        {
         SetIndexDrawBegin(6,Bars-history);
         SetIndexDrawBegin(7,Bars-history);
        }
        } else {
      SetIndexStyle(6,DRAW_NONE);
      SetIndexStyle(7,DRAW_NONE);
     }
   ArrayResize(hpf,nobs);
   ArrayResize(dat,nobs);
   ArrayResize(a,nobs);
   ArrayResize(b,nobs);
   ArrayResize(c,nobs);
   time=Time[history-1];
   if(lambda<1) lambda=MathExp(-lambda);
   switch(timeframe)
     {
      case 60:{tframe="H1";break;}
      case 240:{tframe="H4";break;}
      case 1440:{tframe="D1";break;}
      case 10080:{tframe="W1";break;}
      case 43200:{tframe="MN1";break;}
      default:tframe="M"+Period();
     }
   IndicatorShortName(IND+"("+tframe+")");
   tframe=Symbol()+" "+tframe+": ";
   history=MathMax(iBarShift(NULL,timeframe,time),bands);
   ArrayResize(hp,history);
   ArrayResize(hpu,history);
   ArrayResize(hpd,history);
   ArrayResize(fhi,history);
   ArrayResize(flo,history);
   ArrayResize(phi,history);
   ArrayResize(plo,history);
   alerting=alerts || audio!="";
   showf=trend>0;
   if(trend<0) trend=-trend;
   return(0);
  }
//+----------------------------------------------------------------------------------------+
int start()
  {
   double H1,H2,H3,H4,H5,HH1,HH2,HH3,HH4,HH5,HB,HC,Z,V;
   int i,disp,bar,limit;
   if(iBars(NULL,timeframe)<nobs) return(0);
   limit=iBarShift(NULL,timeframe,time);
   time=Time[0];
   if(limit>=history) limit=history-2;
   if(limit<history-1)
      for(bar=history-limit-1; bar>=0; bar--)
        {
         hp[bar+limit] =hp[bar];
         hpu[bar+limit]=hpu[bar];
         hpd[bar+limit]=hpd[bar];
         fhi[bar+limit]=fhi[bar];
         flo[bar+limit]=flo[bar];
         phi[bar+limit]=phi[bar];
         plo[bar+limit]=plo[bar];
        }
   for(bar=history-limit-1; bar>=0; bar--)
     {
      hpu[bar]=EMPTY_VALUE;
      hpd[bar]=EMPTY_VALUE;
      fhi[bar]=EMPTY_VALUE;
      flo[bar]=EMPTY_VALUE;
      phi[bar]=EMPTY_VALUE;
      plo[bar]=EMPTY_VALUE;
      H1=0;H2=0;H3=0;H4=0;H5=0;HH1=0;HH2=0;HH3=0;HH4=0;HH5=0;
      switch(price)
        {
         case PRICE_CLOSE:
           {
            for(i=0;i<nobs;i++) dat[i]=iClose(NULL,timeframe,bar+i);break;
           }
         case PRICE_OPEN:
           {
            for(i=0;i<nobs;i++)dat[i]=iOpen(NULL,timeframe,bar+i);break;
           }
         case PRICE_HIGH:
           {
            for(i=0;i<nobs;i++)dat[i]=iHigh(NULL,timeframe,bar+i);break;
           }
         case PRICE_LOW:
           {
            for(i=0;i<nobs;i++)dat[i]=iLow(NULL,timeframe,bar+i);break;
           }
         case PRICE_MEDIAN:
           {
            for(i=0;i<nobs;i++)dat[i]=(iHigh(NULL,timeframe,bar+i)+iLow(NULL,timeframe,bar+i))/2;break;
           }
         case PRICE_TYPICAL:
           {
            for(i=0;i<nobs;i++)dat[i]=(iHigh(NULL,timeframe,bar+i)+iLow(NULL,timeframe,bar+i)+iClose(NULL,timeframe,bar+i))/3;break;
           }
         case PRICE_WEIGHTED:
           {
            for(i=0;i<nobs;i++)dat[i]=(iHigh(NULL,timeframe,bar+i)+iLow(NULL,timeframe,bar+i)+2*iClose(NULL,timeframe,bar+i))/4;break;
           }
         default:
            for(i=0;i<nobs;i++) dat[i]=(iHigh(NULL,timeframe,bar+i)+iLow(NULL,timeframe,bar+i)+iOpen(NULL,timeframe,bar+i)+iClose(NULL,timeframe,bar+i))/4;
        }
      V=dat[0];
      a[0]=1.0+lambda;
      b[0]=-2.0*lambda;
      c[0]=lambda;
      for(i=1;i<nobs-2;i++)
        {
         a[i]=6.0*lambda+1.0;
         b[i]=-4.0*lambda;
         c[i]=lambda;
        }
      a[1]=5.0*lambda+1;
      a[nobs-1]=1.0+lambda;
      a[nobs-2]=5.0*lambda+1.0;
      b[nobs-2]=-2.0*lambda;
      b[nobs-1]=0.0;
      c[nobs-2]=0.0;
      c[nobs-1]=0.0;

      //Forward
      for(i=0;i<nobs;i++)
        {
         Z=a[i]-H4*H1-HH5*HH2;
         HB=b[i];
         HH1=H1;
         H1=(HB-H4*H2)/Z;
         b[i]=H1;
         HC=c[i];
         HH2=H2;
         H2=HC/Z;
         c[i]=H2;
         a[i]=(dat[i]-HH3*HH5-H3*H4)/Z;
         HH3=H3;
         H3=a[i];
         H4=HB-H5*HH1;
         HH5=H5;
         H5=HC;
        }

      //Backward 
      H2=0;
      H1=a[nobs-1];
      hpf[nobs-1]=H1;
      for(i=nobs-2;i>=0;i--)
        {
         hpf[i]=a[i]-b[i]*H1-c[i]*H2;
         H2=H1;
         H1=hpf[i];
        }
      hp[bar]=hpf[0];
      if((bar+1<ArraySize(hpu)-1) && hpu[bar+1]==EMPTY_VALUE && (hp[bar]<hp[bar+1] || V<hp[bar]))
         hpu[bar]=EMPTY_VALUE;
      else if(trend>0)
        {
         for(i=0; i<trend; i++)
            if(hpf[i]<hpf[i+1]) break;
         if(i<trend)
            hpu[bar]=EMPTY_VALUE;
         else
            hpu[bar]=hpf[0];
           } else {
         if(hp[bar]<hp[bar+1])
            hpu[bar]=EMPTY_VALUE;
         else
            hpu[bar]=hpf[0];
        }
      if((bar+1<ArraySize(hpu)-1) && hpd[bar+1]==EMPTY_VALUE && (hp[bar]>hp[bar+1] || V>hp[bar]))
         hpd[bar]=EMPTY_VALUE;
      else if(trend>0)
        {
         for(i=0; i<trend; i++)
            if(hpf[i]>hpf[i+1]) break;
         if(i<trend)
            hpd[bar]=EMPTY_VALUE;
         else
            hpd[bar]=hpf[0];
           } else {
         if(hp[bar]>hp[bar+1])
            hpd[bar]=EMPTY_VALUE;
         else
            hpd[bar]=hpf[0];
        }
      if(bands>0 && (band1>0 || (band1<0 && bar==0)))
        {
         Z=0;
         for(i=0; i<bands; i++)
           {
            V=hpf[i];
            switch(type1)
              {
               case -1: {V-=hp[bar+i];break;}
               case 0: {V-=dat[i];break;}
               case 1: {V-=(2*(iHigh(NULL,timeframe,bar+i)+iLow(NULL,timeframe,bar+i))+iOpen(NULL,timeframe,bar+i)+iClose(NULL,timeframe,bar+i))/6;break;}
               case 2: {V=MathMax(MathAbs(iHigh(NULL,timeframe,bar+i)-V),MathAbs(iLow(NULL,timeframe,bar+i)-V));break;}
               case 3: {V=MathMin(MathAbs(iHigh(NULL,timeframe,bar+i)-V),MathAbs(iLow(NULL,timeframe,bar+i)-V));break;}
               case 4: {V-=(iHigh(NULL,timeframe,bar+i)+iLow(NULL,timeframe,bar+i))/2;break;}
               case 5: {V-=(iHigh(NULL,timeframe,bar+i)+iLow(NULL,timeframe,bar+i)+iClose(NULL,timeframe,bar+i))/3;break;}
               case 6: {V-=(iHigh(NULL,timeframe,bar+i)+iLow(NULL,timeframe,bar+i)+2*iClose(NULL,timeframe,bar+i))/4;break;}
               default: V-=iClose(NULL,timeframe,bar+i);
              }
            Z+=V*V;
           }
         Z=band1*MathSqrt(Z/bands);
         if(band1>0)
           {
            fhi[bar]=hp[bar]+Z;
            flo[bar]=hp[bar]-Z;
              } else {
            limit=iBarShift(NULL,0,iTime(NULL,timeframe,nobs-1));
            SetIndexDrawBegin(6,limit);
            SetIndexDrawBegin(7,limit);
            for(i=0; i<nobs; i++)
              {
               fhi[i]=hpf[i]-Z;
               flo[i]=hpf[i]+Z;
              }
           }
        }
      if(bands>0 && (band2>0 || (band2<0 && bar==0)))
        {
         Z=0;
         for(i=0; i<bands; i++)
           {
            V=hpf[i];
            switch(type2)
              {
               case -1: {V-=hp[bar+i];break;}
               case 0: {V-=dat[i];break;}
               case 1: {V-=(2*(iHigh(NULL,timeframe,bar+i)+iLow(NULL,timeframe,bar+i))+iOpen(NULL,timeframe,bar+i)+iClose(NULL,timeframe,bar+i))/6;break;}
               case 2: {V=MathMax(MathAbs(iHigh(NULL,timeframe,bar+i)-V),MathAbs(iLow(NULL,timeframe,bar+i)-V));break;}
               case 3: {V=MathMin(MathAbs(iHigh(NULL,timeframe,bar+i)-V),MathAbs(iLow(NULL,timeframe,bar+i)-V));break;}
               case 4: {V-=(iHigh(NULL,timeframe,bar+i)+iLow(NULL,timeframe,bar+i))/2;break;}
               case 5: {V-=(iHigh(NULL,timeframe,bar+i)+iLow(NULL,timeframe,bar+i)+iClose(NULL,timeframe,bar+i))/3;break;}
               case 6: {V-=(iHigh(NULL,timeframe,bar+i)+iLow(NULL,timeframe,bar+i)+2*iClose(NULL,timeframe,bar+i))/4;break;}
               default: V-=iClose(NULL,timeframe,bar+i);
              }
            Z+=V*V;
           }
         Z=band2*MathSqrt(Z/bands);
         if(band2>0)
           {
            phi[bar]=hp[bar]+Z;
            plo[bar]=hp[bar]-Z;
              } else {
            limit=iBarShift(NULL,0,iTime(NULL,timeframe,nobs-1));
            SetIndexDrawBegin(4,limit);
            SetIndexDrawBegin(5,limit);
            for(i=0; i<nobs; i++)
              {
               phi[i]=hpf[i]-Z;
               plo[i]=hpf[i]+Z;
              }
           }
        }
      if(bar<history-1)
        {
         if(bar==0)
            disp=0;
         else if(timeframe<=Period())
                            disp=iBarShift(NULL,0,iTime(NULL,timeframe,bar));
         else
            disp=iBarShift(NULL,0,iTime(NULL,timeframe,bar-1))+1;
         if(delay>=0)
            hp0[disp]=hpf[delay];
         else
            hp0[disp]=newt(hpf,0,-delay);
         if(hpu[bar]!=EMPTY_VALUE)
            hpu0[disp]=hp0[disp];
         else
            hpu0[disp]=EMPTY_VALUE;
         if(hpd[bar]!=EMPTY_VALUE)
            hpd0[disp]=hp0[disp];
         else
            hpd0[disp]=EMPTY_VALUE;
         fhi0[disp]=fhi[bar];
         flo0[disp]=flo[bar];
         phi0[disp]=phi[bar];
         plo0[disp]=plo[bar];
         if(timeframe<=Period())
            limit=iBarShift(NULL,0,iTime(NULL,timeframe,bar+1));
         else
            limit=iBarShift(NULL,0,iTime(NULL,timeframe,bar))+1;
         i=limit-disp;
         if(i<2) continue;
         H1=hp[bar+1];
         HH1=(hp[bar]-H1)/i;
         if(bands>0 && band1>0)
           {
            H2=fhi[bar+1];
            HH2=(fhi[bar]-H2)/i;
            H3=flo[bar+1];
            HH3=(flo[bar]-H3)/i;
           }
         if(bands>0 && band2>0)
           {
            H4=phi[bar+1];
            HH4=(phi[bar]-H4)/i;
            H5=plo[bar+1];
            HH5=(plo[bar]-H5)/i;
           }
         for(i=limit-1; i>disp; i--)
           {
            H1+=HH1;
            hp0[i]=H1;
            if(hpu[bar+1]!=EMPTY_VALUE) hpu0[i]=H1; else hpu0[i]=EMPTY_VALUE;
            if(hpd[bar+1]!=EMPTY_VALUE) hpd0[i]=H1; else hpd0[i]=EMPTY_VALUE;
            if(bands>0 && band1>0)
              {
               H2+=HH2;
               H3+=HH3;
               fhi0[i]=H2;
               flo0[i]=H3;
              }
            if(bands>0 && band2>0)
              {
               H4+=HH4;
               H5+=HH5;
               phi0[i]=H4;
               plo0[i]=H5;
              }
           }
        }
     }
   if(showf>0)
     {
      limit=iBarShift(NULL,0,iTime(NULL,timeframe,nobs-1));
      SetIndexDrawBegin(3,limit);
      if(future>0)
        {
         V=Period();
         V/=timeframe;
         for(bar=0; bar<future; bar++)
            hpf0[bar]=newt(hpf,0,(future-bar)*V);
        }
      for(bar=nobs-1; bar>=0; bar--)
        {
         if(bar==0)
            disp=future;
         else if(timeframe<=Period())
                            disp=iBarShift(NULL,0,iTime(NULL,timeframe,bar))+future;
         else
            disp=iBarShift(NULL,0,iTime(NULL,timeframe,bar-1))+future+1;
         hpf0[disp]=hpf[bar];
         if(bar<nobs-1)
           {
            limit=iBarShift(NULL,0,iTime(NULL,timeframe,bar+1))+future;
            i=limit-disp;
            if(i<2) continue;
            H1=hpf[bar];
            HH1=(H1-hpf[bar+1])/i;
            for(i=limit-1; i>disp; i--)
              {
               H1+=HH1;
               hpf0[i]=H1;
              }
           }
        }
     }
   if(bands>0 && band1<0)
     {
      limit=iBarShift(NULL,0,iTime(NULL,timeframe,nobs-1));
      for(bar=nobs-1; bar>=0; bar--)
        {
         if(bar==0)
            disp=0;
         else if(timeframe<=Period())
                            disp=iBarShift(NULL,0,iTime(NULL,timeframe,bar));
         else
            disp=iBarShift(NULL,0,iTime(NULL,timeframe,bar-1))+1;
         fhi0[disp]=fhi[bar];
         flo0[disp]=flo[bar];
         if(bar<nobs-1)
           {
            if(timeframe<=Period())
               limit=iBarShift(NULL,0,iTime(NULL,timeframe,bar+1));
            else
               limit=iBarShift(NULL,0,iTime(NULL,timeframe,bar))+1;
            i=limit-disp;
            if(i<2) continue;
            H2=fhi[bar+1];
            HH2=(fhi[bar]-H2)/i;
            H3=flo[bar+1];
            HH3=(flo[bar]-H3)/i;
            for(i=limit-1; i>disp; i--)
              {
               H2+=HH2;
               H3+=HH3;
               fhi0[i]=H2;
               flo0[i]=H3;
              }
           }
        }
     }
   if(bands>0 && band2<0)
     {
      limit=iBarShift(NULL,0,iTime(NULL,timeframe,nobs-1));
      for(bar=nobs-1; bar>=0; bar--)
        {
         if(bar==0)
            disp=0;
         else if(timeframe<=Period())
                            disp=iBarShift(NULL,0,iTime(NULL,timeframe,bar));
         else
            disp=iBarShift(NULL,0,iTime(NULL,timeframe,bar-1))+1;
         phi0[disp]=phi[bar];
         plo0[disp]=plo[bar];
         if(bar<nobs-1)
           {
            if(timeframe<=Period())
               limit=iBarShift(NULL,0,iTime(NULL,timeframe,bar+1));
            else
               limit=iBarShift(NULL,0,iTime(NULL,timeframe,bar))+1;
            i=limit-disp;
            if(i<2) continue;
            H4=phi[bar+1];
            HH4=(phi[bar]-H4)/i;
            H5=plo[bar+1];
            HH5=(plo[bar]-H5)/i;
            for(i=limit-1; i>disp; i--)
              {
               H4+=HH4;
               H5+=HH5;
               phi0[i]=H4;
               plo0[i]=H5;
              }
           }
        }
     }
   if(alerting)
     {
      if(hpu[0]!=EMPTY_VALUE && hpu[1]==EMPTY_VALUE)
        {
         MyAlert("Up Trend");
        }
      else
      if(hpu[0]==EMPTY_VALUE && hpu[1]!=EMPTY_VALUE && hpd[0]==EMPTY_VALUE)
        {
         MyAlert("No Trend");
        }
      else
      if(hpd[0]!=EMPTY_VALUE && hpd[1]==EMPTY_VALUE)
        {
         MyAlert("Down Trend");
        }
      else
      if(hpd[0]==EMPTY_VALUE && hpd[1]!=EMPTY_VALUE && hpu[0]==EMPTY_VALUE)
        {
         MyAlert("No Trend");
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyAlert(string alert)
  {
   static string last;
   if(alert==last) return;
   last=alert;
   if(alerts) Alert(IND+tframe+alert);
   if(audio!="") PlaySound(audio);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double newt(double x[],int pos,double n)
  {
   double r=x[pos],k=1;
   int l=MathCeil(n),i;
   if(pos+l>=ArraySize(x)) l=ArraySize(x)-pos-1;
   if(n==0) return(r);
   if(n<0) return(EMPTY_VALUE);
   for(i=1; i<=l; i++)
     {
      k*=n/i;
      r+=k*dlt(x,pos,i);
     }
   return(r);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double dlt(double x[],int pos,int d)
  {
   double r=0;
   int i, k=1, pod=pos+d, l=d>>1;
   if(pos>=ArraySize(x)) return(EMPTY_VALUE);
   if(pos+d>=ArraySize(x)) return(0);
   if(d%2>0)
      for(i=0; i<=l; i++,pos++,pod--)
        {
         r+=k*(x[pos]-x[pod]);
         k*=i-d;
         k/=i+1;
        }
   else
     {
      for(i=0; i<l; i++,pos++,pod--)
        {
         r+=k*(x[pos]+x[pod]);
         k*=i-d;
         k/=i+1;
        }
      r+=k*x[pos];
     }
   return(r);
  }
//+------------------------------------------------------------------+
