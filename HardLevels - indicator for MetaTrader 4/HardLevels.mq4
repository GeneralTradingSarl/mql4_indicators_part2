//+------------------------------------------------------------------+
//|                                                   HardLevels.mq4 |
//+------------------------------------------------------------------+
#property copyright "mqlservice.co.uk"
#property link      "http://mqlservice.co.uk/"
// For detailed description please visit MQL Scripts section at http://mqlservice.co.uk/
#property indicator_chart_window
#define EndBar 2 
//---- input parameters
extern int       TimeFrame=0;
extern int       TolerancePips=3;
extern int       Hits=15;
extern int       StartBar=300;
extern int       LookBack=300;
extern int       AppliedPrice=0;
extern int       AppliedPriceExtra=1;
extern bool      UseFiltering=true;
extern int       FilterStrength=3;
extern color     LineColor=Blue;
extern int       LineWidth=1;
extern string    note0="Applied price 0-CLOSE | 1-OPEN | 2-HIGH | 3-LOW |";
extern string    note1="            | 4-MEDIAN | 5-TYPICAL | 6-WEIGHTED |";
extern string    note2 = "Time Frame 0=current time frame";
extern string    note3 = "1=M1, 5=M5, 15=M15, 30=M30";
extern string    note4 = "60=H1, 240=H4, 1440=D1";
extern string    note5 = "10080=W1, 43200=MN1";
extern bool      Force4DigitBrokers = true;  

//---- Symbol parameters
string _symbol;
double _point;
int    _digits;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   Print("HardLevels Ver.3");
   Print("Copyright © 2009/06/02  MQL Service UK   http://mqlservice.co.uk/");
   _symbol=Symbol();
   _digits = MarketInfo(_symbol, MODE_DIGITS);
   if(_digits == 0) _digits = 4;
   _point = MarketInfo(_symbol, MODE_POINT);
   if(NormalizeDouble(_point, _digits) == 0.0) _point = Point;
   if(Force4DigitBrokers)
      if(_digits==3||_digits>4)
         _point *= 10;
   switch(AppliedPrice){
      case 1 : break; 
      case 2 : break;  
      case 3 : break;  
      case 4 : break;    
      case 5 : break;    
      case 6 : break;     
      default :
         AppliedPrice=PRICE_CLOSE; break; 
   }
   switch(TimeFrame)
   {
      case 1 : break;
      case 5 : break;
      case 15 : break;
      case 30 : break;
      case 60 : break;
      case 240 : break;
      case 1440 : break;
      case 10080 : break;
      case 43200 : break;
      default : TimeFrame=Period(); break;
   }
   if(StartBar<1) StartBar=Bars-1;
   if(StartBar<0) StartBar=1;
   if(FilterStrength<1) FilterStrength=1;
   if(Hits<1) Hits=1;
   if(LookBack<Hits) LookBack=Hits;
   if(!UseFiltering) FilterStrength=0;
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   //----
   string name1="Hard Line "+FilterStrength+" "+TimeFrame;
   string name2;
   for(int i=ObjectsTotal(); i>=0; i--){
      name2=ObjectName(i); 
      if(StringSubstr(name2,0,StringLen(name1))==name1)
         ObjectDelete(name2);
   }      
   //----
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{  
   if(Bars<LookBack) return(0);
   int i, j, count;
   int start=StartBar;
   if(start>Bars-1) start=Bars-1;
   string name;
   double level;
   static datetime t=0;
   if(t<Time[0]) t=Time[0];
   else return(0);   
   for(i=0; i<start+1; i++)
      if(ObjectFind("Hard Line "+FilterStrength+" "+TimeFrame+" "+TimeToStr(Time[i]))>-1)
         ObjectDelete("Hard Line "+FilterStrength+" "+TimeFrame+" "+TimeToStr(Time[i]));
   double HL[];
   if(ArraySize(HL)!=start+1) ArrayResize(HL,start+1);
   ArrayInitialize(HL,0);
   //---- main loop
   for(i=EndBar; i<start; i++){
      count=1; level=CP(i, false);
      for(j=i; j<i+LookBack; j++){
         if(MathAbs(CP(i, false)-CP(j, false))<=TolerancePips*_point){
            count++; level +=CP(j, false); 
         } 
         else
            if(AppliedPriceExtra!=AppliedPrice)
               if(MathAbs(CP(i, false)-CP(j, true))<=TolerancePips*_point){
                  count++; level +=CP(j, true);
               }   
         if(count>=Hits){
            HL[i]=NormalizeDouble(level/count,Digits);  
            break;
         }
      }
   }
   if(UseFiltering){
      double A[];
      int    c[];
      ArrayResize(A,start+1);
      ArrayInitialize(A,0);
      ArrayResize(c,start+1);
      ArrayInitialize(c,0);
      for(i=start-2; i>=EndBar; i--){
         if(HL[i]>0){
            c[i]++; A[i]=HL[i];
            for(j=start-1; j>=0; j--){
               if(i==j) continue;
               if(HL[j]>0)
                  if(NormalizeDouble(MathAbs(HL[i]-HL[j]),Digits)<=_point*FilterStrength*FilterStrength){
                     A[i] +=HL[j];
                     c[i]++;
                  }   
            }  
            A[i] /=c[i];     
         }  
      }  
      for(i=0; i<start; i++){
         if(c[i]==0 || c[i+1]==0) continue;
         if(NormalizeDouble(MathAbs(A[i]-A[i+1]),Digits)>_point*FilterStrength*FilterStrength) continue;
         if(c[i]<c[i+1]){
               c[i]=0;
               A[i]=0;
            }
         else{
            c[i+1]=0; 
            A[i+1]=0;
            i++; continue;  
         }
      }   
      bool done=false;
      while(!done){
         done=true;
         for(i=0; i<start; i++){
            if(NormalizeDouble(A[i],Digits)==0) continue;
            for(j=0; j<start; j++){
               if(i==j) continue;
               if(NormalizeDouble(A[j],Digits)==0) continue;
               if(NormalizeDouble(MathAbs(A[i]-A[j]),Digits)<=_point*FilterStrength*FilterStrength){
                  if(c[i]<c[j]){
                     c[i]=0;
                     A[i]=0; done=false; 
                  }
                  else{
                     c[j]=0; 
                     A[j]=0; done=false; 
                  }              
               }
            }
         }   
      }    
      for(i=0; i<start; i++){
         if(c[i]==0) HL[i]=0;
         else HL[i]=A[i];
      }   
   }   
   for(i=0; i<start; i++)
      if(HL[i]>0){
         DL(HL[i], "Hard Line "+FilterStrength+" "+TimeFrame+" "+TimeToStr(Time[i]), Time[i]);
      }
   //---- done
   return(0);
}

void DL(double level, string name, datetime time)
{
   if(ObjectFind(name)<0){
      ObjectCreate(name, OBJ_HLINE, 0, time, level);
      ObjectSet(name, OBJPROP_COLOR, LineColor);
      ObjectSet(name, OBJPROP_BACK, true);
      ObjectSet(name, OBJPROP_RAY, true);
      ObjectSet(name, OBJPROP_WIDTH, LineWidth);
   }   
   ObjectSet(name, OBJPROP_PRICE1, level);
   return;
}

double CP(int i, bool _s)  
{
   double result=-1;
   if(!_s && TimeFrame==Period())
      switch(AppliedPrice){
         case 1 : result=Open[i]; break; 
         case 2 : result=High[i]; break; 
         case 3 : result=Low[i]; break;  
         case 4 : result=(High[i]+Low[i])/2; break; 
         case 5 : result=(High[i]+Low[i]+Close[i])/3; break;    
         case 6 : result=(High[i]+Low[i]+Close[i]+Close[i])/4; break;    
         default :
            result=Close[i]; break;  
      }
   if(_s && TimeFrame==Period())
      switch(AppliedPriceExtra){
         case 1 : result=Open[i]; break; 
         case 2 : result=High[i]; break; 
         case 3 : result=Low[i]; break;  
         case 4 : result=(High[i]+Low[i])/2; break; 
         case 5 : result=(High[i]+Low[i]+Close[i])/3; break;    
         case 6 : result=(High[i]+Low[i]+Close[i]+Close[i])/4; break;    
         default :
            result=Close[i]; break;  
      }
   if(!_s && TimeFrame!=Period())
      switch(AppliedPrice){
         case 1 : result=iOpen(_symbol,TimeFrame,i); break; 
         case 2 : result=iHigh(_symbol,TimeFrame,i); break; 
         case 3 : result=iLow(_symbol,TimeFrame,i); break;  
         case 4 : result=(iHigh(_symbol,TimeFrame,i)+iLow(_symbol,TimeFrame,i))/2; break; 
         case 5 : result=(iHigh(_symbol,TimeFrame,i)+iLow(_symbol,TimeFrame,i)+iClose(_symbol,TimeFrame,i))/3; break;    
         case 6 : result=(iHigh(_symbol,TimeFrame,i)+iLow(_symbol,TimeFrame,i)+iClose(_symbol,TimeFrame,i)+iClose(_symbol,TimeFrame,i))/4; break;    
         default :
            result=iClose(_symbol,TimeFrame,i); break;  
      }
   if(_s && TimeFrame!=Period())
      switch(AppliedPriceExtra){
         case 1 : result=iOpen(_symbol,TimeFrame,i); break; 
         case 2 : result=iHigh(_symbol,TimeFrame,i); break; 
         case 3 : result=iLow(_symbol,TimeFrame,i); break;  
         case 4 : result=(iHigh(_symbol,TimeFrame,i)+iLow(_symbol,TimeFrame,i))/2; break; 
         case 5 : result=(iHigh(_symbol,TimeFrame,i)+iLow(_symbol,TimeFrame,i)+iClose(_symbol,TimeFrame,i))/3; break;    
         case 6 : result=(iHigh(_symbol,TimeFrame,i)+iLow(_symbol,TimeFrame,i)+iClose(_symbol,TimeFrame,i)+iClose(_symbol,TimeFrame,i))/4; break;    
         default :
            result=iClose(_symbol,TimeFrame,i); break;  
      }
   return(NormalizeDouble(result,Digits));
}
  
//+---- Programmed by Rafal Dubiel @ MQLService.co.uk -----------------+