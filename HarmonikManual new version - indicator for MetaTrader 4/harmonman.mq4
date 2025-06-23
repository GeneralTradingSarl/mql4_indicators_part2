//+------------------------------------------------------------------+
//|                                                    HarmonMan.mq4 |
//|                                            Copyright 2015, Kabul |
//|                                               panji_xx@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Kabul"
#property link      "panji_xx@yahoo.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

input string InpFileName="harmontrad.csv";    // file name
input int    InpEncodingType=FILE_ANSI; 
input int    DatabaseRecord=84; 
input int    AUTO_Period=240; 
input color  TriangleColor=clrLime;
input color  Hor_Up_Clr=clrRed;
input color  Hor_Dn_Clr=clrYellow;
input color  Rect_Up_Clr=clrMagenta;
input color  Rect_Dn_Clr=clrAqua;
#define	OBJNAME_LABEL	"Harmonic Ratios :)"

string hasil;
datetime D_tm,C_tm,B_tm,A_tm,X_tm;
double   D_pr,C_pr,B_pr,A_pr,X_pr;
double   LlXA,LlAB,LlBC,LlCD,LlXB,LlAC,LlXD,LlBD;
double   awal,akhir,res1,res2,resak;
double   cari1[],cari2[],cari3[],cari4[],jump[],jump1[];
double   up[5],dn[5],posup[5],posdn[5];
bool     found=false;
int kstrok,kdown,grsbts,grsbts1,grsbts2,grsbts3,wrgval;

bool Active = True;
int Harmonic_Pattern_No= 0;
color triangle,triangle1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   EventSetTimer(1);
   ObjectDelete(0,"SEARCH");
   ObjectDelete(0,"Tulis");
   SetPanel("SEARCH",0,875,20,74,30,clrRed,clrBlack,1);
   SetText("Tulis","SEARCH",879,25,clrWhite,12,"Georgia");  
   triangle=TriangleColor;
   triangle1=TriangleColor;
   kstrok=0;kdown=0;grsbts=0;grsbts1=0;grsbts2=0;grsbts3=0;wrgval=0;

   ArrayResize(cari1,DatabaseRecord);
   ArrayResize(cari2,DatabaseRecord);
   ArrayResize(cari3,DatabaseRecord);
   ArrayResize(cari4,DatabaseRecord);
   
   ObjectDelete(0,"JUMP");
   ObjectDelete(0,"Tulis1");
   SetPanel("JUMP",0,875,50,74,30,clrAqua,clrBlack,1);
   SetText("Tulis1","NEXT",890,55,clrBlack,12,"Georgia");     
   ObjectSet("Tulis",OBJPROP_SELECTABLE,false);    
   ObjectSet("SEARCH",OBJPROP_SELECTABLE,false);    
   ObjectSet("Tulis1",OBJPROP_SELECTABLE,false);    
   ObjectSet("JUMP",OBJPROP_SELECTABLE,false);       
   
   ObjectDelete(0,"ON");
   ObjectDelete(0,"STATUS");
   SetPanel("ON",0,875,80,74,30,clrLime,clrBlack,1);
   SetText("STATUS","ON",898,85,clrRed,12,"Georgia");        
   ObjectSet("ON",OBJPROP_SELECTABLE,false);    
   ObjectSet("STATUS",OBJPROP_SELECTABLE,false);          
   
   ObjectDelete(0,"COLOR");
   ObjectDelete(0,"txtCOLOR");
   SetPanel("COLOR",0,875,110,74,30,clrLime,clrBlack,1);
   SetText("txtCOLOR","COLOUR",878,115,clrRed,12,"Georgia");        
   ObjectSet("COLOR",OBJPROP_SELECTABLE,false);    
   ObjectSet("txtCOLOR",OBJPROP_SELECTABLE,false);             
   
   ObjectDelete(0,"XABC");
   ObjectDelete(0,"txtXABC");
   SetPanel("XABC",0,875,140,74,30,clrLime,clrBlack,1);
   SetText("txtXABC","XABC",890,145,clrRed,12,"Georgia");        
   ObjectSet("XABC",OBJPROP_SELECTABLE,false);    
   ObjectSet("txtXABC",OBJPROP_SELECTABLE,false);                
   
   ObjectDelete(0,"RESET");
   ObjectDelete(0,"txtRESET");
   SetPanel("RESET",0,875,170,74,30,clrLime,clrBlack,1);
   SetText("txtRESET","RESET",885,175,clrRed,12,"Georgia");        
   ObjectSet("RESET",OBJPROP_SELECTABLE,false);    
   ObjectSet("txtRESET",OBJPROP_SELECTABLE,false);                   
   
   ObjectDelete(0,"AUTO");
   ObjectDelete(0,"txtAUTO");
   SetPanel("AUTO",0,875,200,74,30,clrLime,clrBlack,1);
   SetText("txtAUTO","AUTO",890,205,clrRed,12,"Georgia");        
   ObjectSet("AUTO",OBJPROP_SELECTABLE,false);    
   ObjectSet("txtAUTO",OBJPROP_SELECTABLE,false);                      
   
   awal=0.0;
   createIndicatorLabel(OBJNAME_LABEL);
   if (UninitializeReason()==3)
    {
      XABC();
    }
//---
   return(INIT_SUCCEEDED);
  }
  
  
int deinit() 
    {
      if (UninitializeReason()==1)
      {
        reset(); 
      }  
   	return(0);
    }  

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

   
//--- return value of prev_calculated for next call
   return(rates_total);
  }


void OnChartEvent(const int id,         // Event identifier  
                  const long& lparam,   // Event parameter of long type
                  const double& dparam, // Event parameter of double type
                  const string& sparam) // Event parameter of string type
                  
{
   if (id==CHARTEVENT_OBJECT_CLICK)
     {
        if (sparam=="SEARCH")
        {
          ObjectDelete(0,"FOUND");
          ObjectSet("SEARCH",OBJPROP_BGCOLOR,clrLime);  
          ObjectSet("D",0,Time[0]+(4*Period()*60));  
          ObjectSetInteger(0,"Tulis",OBJPROP_COLOR,clrRed);
          found=false;
        }  
        if (sparam=="JUMP")
        {         

         if((ObjectGet("C",1)>ObjectGet("B",1))&&(ObjectFind(0,"SLD100")>=0))
           {

              if(grsbts==0)
               {
                 grsbts++;
                   for (int mii=0;mii<100;mii++)
                    {
                      grsbts++;
                      if (ObjectFind(0,"SPLI"+IntegerToString(mii))<0) 
                       {
                         ArrayResize(jump,grsbts+1);
                         ArrayInitialize(jump,0);
                         jump[0]=ObjectGet("SLD100",1);
                         jump[1]=ObjectGet("SLD100",3);                         
                         for (int miii=0;miii<grsbts-1;miii++)
                          {
                            jump[miii+2]=ObjectGet("SPLI"+IntegerToString(miii),3);
                          }
                         break;
                       }
                    }                            
                    ArraySort(jump,WHOLE_ARRAY,0,MODE_DESCEND);
                    ObjectSet("D",1,jump[0]);
               }
               else
               {
                 grsbts1++;
                 if (grsbts1==grsbts) {grsbts1=0;}
                 ObjectSet("D",1,jump[grsbts1]);
               }
           }
           
          if((ObjectGet("C",1)<ObjectGet("B",1))&&(ObjectFind(0,"SL100")>=0))
           {

              if(grsbts2==0)
               {
                 grsbts2++;
                   for (int mii=0;mii<100;mii++)
                    {
                      grsbts2++;
                      
                      if (ObjectFind(0,"SPLIUP"+IntegerToString(mii))<0) 
                       {
                         ArrayResize(jump1,grsbts2+1);
                         ArrayInitialize(jump1,0);
                         jump1[0]=ObjectGet("SL100",1);
                         jump1[1]=ObjectGet("SL100",3);                         
                         for (int miii=0;miii<grsbts2-1;miii++)
                          {
                            jump1[miii+2]=ObjectGet("SPLIUP"+IntegerToString(miii),1);
                          }                       
                         break;
                       }
                    }                            
                    ArraySort(jump1,WHOLE_ARRAY,0,MODE_DESCEND);
                    ObjectSet("D",1,jump1[1]);grsbts3++;
               }
               else
               {
                 grsbts3++;
                 if (grsbts3==grsbts2) {grsbts3=0;}
                 ObjectSet("D",1,jump1[grsbts3]);
               }
           }
           
                      
        }
        
        
        if (sparam=="ON")
         {
           int xcolor,ycolor;
           xcolor=ObjectGetInteger(0,"ON",OBJPROP_XDISTANCE,0);
           ycolor=ObjectGetInteger(0,"ON",OBJPROP_YDISTANCE,0);            
            if (ObjectGet("ON",OBJPROP_BGCOLOR)==clrLime)
             {
               ObjectSet("ON",OBJPROP_BGCOLOR,clrRed); 
               ObjectDelete(0,"STATUS");
               SetText("STATUS","OFF",xcolor+20,ycolor+5,clrWhite,12,"Georgia");        
             }
             else
             {
               if (ObjectGet("ON",OBJPROP_BGCOLOR)==clrRed)
                {
                  ObjectSet("ON",OBJPROP_BGCOLOR,clrLime);  
                  ObjectDelete(0,"STATUS");
                  SetText("STATUS","ON",xcolor+23,ycolor+5,clrRed,12,"Georgia");        
                }             
             }  
             ObjectSet("ON",OBJPROP_SELECTABLE,false);    
             ObjectSet("STATUS",OBJPROP_SELECTABLE,false);                       
         }
        
        if (sparam=="XABC")
         {
            XABC();         
         }
         
        if (sparam=="RESET")
         {
           reset();         
           OnInit();
         }

        if (sparam=="AUTO")
         {
           int tf=AUTO_Period;
           if (ObjectFind(0,"PERIOD")<0)
            {
              ObjectCreate(0,"PERIOD",OBJ_TEXT,0,Time[0],Low[0]-0.001);
              ObjectSetString(0,"PERIOD",OBJPROP_TEXT,IntegerToString(AUTO_Period));
              ObjectSetInteger(0,"PERIOD",OBJPROP_COLOR,clrRed);
              ObjectSetInteger(0,"PERIOD",OBJPROP_FONTSIZE,18);
            }
           else
            {
              tf=StringToInteger(ObjectGetString(0,"PERIOD",OBJPROP_TEXT,0));
            } 
            
           titik(tf);         
           if (posup[0]<posdn[0])
            {
              ObjectSet("C",0,iTime(NULL,tf,posup[0]));
              ObjectSet("C",1,up[0]+0.0015);               
              
              ObjectSet("B",0,iTime(NULL,tf,posdn[0]));
              ObjectSet("B",1,dn[0]-0.0001);                             
              
              ObjectSet("A",0,iTime(NULL,tf,posup[1]));
              ObjectSet("A",1,up[1]+0.0015);               
              
              ObjectSet("X",0,iTime(NULL,tf,posdn[1]));
              ObjectSet("X",1,dn[1]-0.0001);        
              
              ObjectSet("D",0,Time[0]+(4*Period()*60));                                                                
              
            }
            else
            {
              ObjectSet("C",0,iTime(NULL,tf,posdn[0]));
              ObjectSet("C",1,dn[0]-0.0001);               
              
              ObjectSet("B",0,iTime(NULL,tf,posup[0]));
              ObjectSet("B",1,up[0]+0.0015);                             
              
              ObjectSet("A",0,iTime(NULL,tf,posdn[1]));
              ObjectSet("A",1,dn[1]-0.0001);               
              
              ObjectSet("X",0,iTime(NULL,tf,posup[1]));
              ObjectSet("X",1,up[1]+0.0015);        
              
              ObjectSet("D",0,Time[0]+(4*Period()*60));                                                                
              
            }
          XABC();              
          ObjectDelete(0,"FOUND");
          ObjectSet("SEARCH",OBJPROP_BGCOLOR,clrLime);  
          ObjectSetInteger(0,"Tulis",OBJPROP_COLOR,clrRed);
          found=false;            
         }
         
        if (sparam=="COLOR")
         {
           int xcolor,ycolor;
           xcolor=ObjectGetInteger(0,"COLOR",OBJPROP_XDISTANCE,0);
           ycolor=ObjectGetInteger(0,"COLOR",OBJPROP_YDISTANCE,0);
           if (ObjectGet("REC1",OBJPROP_COLOR)==clrNONE)
            {
               triangle1=triangle; 
               ObjectDelete(0,"txtCOLOR");
               SetText("txtCOLOR","COLOUR",xcolor+3,ycolor+5,clrRed,12,"Georgia");                       
            }
            else
            {
               triangle1=clrNONE;
               ObjectDelete(0,"txtCOLOR");
               SetText("txtCOLOR","NONE",xcolor+13,ycolor+5,clrBlack,12,"Georgia");                                      
            }
               ObjectSet("txtCOLOR",OBJPROP_SELECTABLE,false);                       
         }                  
                  
     }

   if (id==CHARTEVENT_KEYDOWN)
     {
        kstrok=lparam;kdown=StringToInteger(sparam);
     }     
     
   if ((id==CHARTEVENT_CLICK)&&(kstrok==77)&&(kdown==16434))
     {
        {
          ObjectSetInteger(0,"SEARCH",OBJPROP_XDISTANCE,lparam);
          ObjectSetInteger(0,"SEARCH",OBJPROP_YDISTANCE,dparam);
          ObjectSetInteger(0,"Tulis",OBJPROP_XDISTANCE,lparam+4);
          ObjectSetInteger(0,"Tulis",OBJPROP_YDISTANCE,dparam+5);          

          ObjectSetInteger(0,"JUMP",OBJPROP_XDISTANCE,lparam);
          ObjectSetInteger(0,"JUMP",OBJPROP_YDISTANCE,dparam+30);
          ObjectSetInteger(0,"Tulis1",OBJPROP_XDISTANCE,lparam+15);
          ObjectSetInteger(0,"Tulis1",OBJPROP_YDISTANCE,dparam+35);          

          ObjectSetInteger(0,"ON",OBJPROP_XDISTANCE,lparam);
          ObjectSetInteger(0,"ON",OBJPROP_YDISTANCE,dparam+60);
          ObjectSetInteger(0,"STATUS",OBJPROP_XDISTANCE,lparam+23);
          ObjectSetInteger(0,"STATUS",OBJPROP_YDISTANCE,dparam+65);          

          ObjectSetInteger(0,"COLOR",OBJPROP_XDISTANCE,lparam);
          ObjectSetInteger(0,"COLOR",OBJPROP_YDISTANCE,dparam+90);
          if (ObjectGet("txtCOLOR",OBJPROP_COLOR)==clrBlack)
          {
            ObjectSetInteger(0,"txtCOLOR",OBJPROP_XDISTANCE,lparam+13);
            ObjectSetInteger(0,"txtCOLOR",OBJPROP_YDISTANCE,dparam+95);          
          }
          else
          {
            ObjectSetInteger(0,"txtCOLOR",OBJPROP_XDISTANCE,lparam+3);
            ObjectSetInteger(0,"txtCOLOR",OBJPROP_YDISTANCE,dparam+95);                    
          } 
          ObjectSetInteger(0,"XABC",OBJPROP_XDISTANCE,lparam);
          ObjectSetInteger(0,"XABC",OBJPROP_YDISTANCE,dparam+120);
          ObjectSetInteger(0,"txtXABC",OBJPROP_XDISTANCE,lparam+15);
          ObjectSetInteger(0,"txtXABC",OBJPROP_YDISTANCE,dparam+125);          

          ObjectSetInteger(0,"RESET",OBJPROP_XDISTANCE,lparam);
          ObjectSetInteger(0,"RESET",OBJPROP_YDISTANCE,dparam+150);
          ObjectSetInteger(0,"txtRESET",OBJPROP_XDISTANCE,lparam+10);
          ObjectSetInteger(0,"txtRESET",OBJPROP_YDISTANCE,dparam+155);          

          ObjectSetInteger(0,"AUTO",OBJPROP_XDISTANCE,lparam);
          ObjectSetInteger(0,"AUTO",OBJPROP_YDISTANCE,dparam+180);
          ObjectSetInteger(0,"txtAUTO",OBJPROP_XDISTANCE,lparam+15);
          ObjectSetInteger(0,"txtAUTO",OBJPROP_YDISTANCE,dparam+185);          
          kstrok=0;kdown=0;        
        } 
     }     
     

}


void OnTimer()
 {
    support();
 
    if (ObjectGet("ON",OBJPROP_BGCOLOR)==clrRed) {ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios: Off :(",9,"Arial",White);return;}
 
   
 // Bikin XABCDE, dan trend linenya
 
     double   top=WindowPriceMax();
     if(ObjectFind("X")<0)
     {
      ObjectCreate("X",OBJ_TEXT,0,Time[23],top-0.001);
      ObjectSetText("X","X",18,"TimesNewRoman",White);
     }

    if(ObjectFind("A")<0)
     {
      ObjectCreate("A",OBJ_TEXT,0,Time[18],top-0.001);
      ObjectSetText("A","A",18,"TimesNewRoman",White);
     }
     
    if(ObjectFind("B")<0)
     {
      ObjectCreate("B",OBJ_TEXT,0,Time[13],top-0.001);
      ObjectSetText("B","B",18,"TimesNewRoman",White);
     }     
     
    if(ObjectFind("C")<0)
     {
      ObjectCreate("C",OBJ_TEXT,0,Time[8],top-0.001);
      ObjectSetText("C","C",18,"TimesNewRoman",White);
     }     
     
    if(ObjectFind("D")<0)
     {
      ObjectCreate("D",OBJ_TEXT,0,Time[3],top-0.001);
      ObjectSetText("D","D",18,"TimesNewRoman",White);
     }     
     
     if(ObjectFind("E")>=0) {X_tm=Time[0];return;}  
     else
      {
        
        
        X_tm=Time[0];
        
        for (int jjj=0;jjj<1200;jjj++)
         {
           if ((iTime(NULL,0,jjj+1)<ObjectGet("D",0)) &&(iTime(NULL,0,jjj)>=ObjectGet("D",0)) && (ObjectGet("D",1)>=iLow(NULL,0,jjj)))
             {
               D_tm=iTime(NULL,0,jjj);
               D_pr=iHigh(NULL,0,jjj);
             }
             
           if ((iTime(NULL,0,jjj+1)<ObjectGet("D",0))&&(iTime(NULL,0,jjj)>=ObjectGet("D",0)) && (ObjectGet("D",1)<=iHigh(NULL,0,jjj)))
             {
               D_tm=iTime(NULL,0,jjj);
               D_pr=iLow(NULL,0,jjj);
             }
           if (ObjectGet("D",0)>Time[0])
             {
               D_tm=ObjectGet("D",0); 
               D_pr=ObjectGet("D",1);              
             } 
             
           if ((iTime(NULL,0,jjj+1)<ObjectGet("C",0))&&(iTime(NULL,0,jjj)>=ObjectGet("C",0)) && (ObjectGet("C",1)<=iHigh(NULL,0,jjj)))
             {
               C_tm=iTime(NULL,0,jjj);
               C_pr=iLow(NULL,0,jjj);
             }
             
           if ((iTime(NULL,0,jjj+1)<ObjectGet("C",0))&&(iTime(NULL,0,jjj)>=ObjectGet("C",0)) && (ObjectGet("C",1)>=iLow(NULL,0,jjj)))
             {
               C_tm=iTime(NULL,0,jjj);
               C_pr=iHigh(NULL,0,jjj);
             }             
             
           if ((iTime(NULL,0,jjj+1)<ObjectGet("B",0)) && (iTime(NULL,0,jjj)>=ObjectGet("B",0)) &&(ObjectGet("B",1)<=iHigh(NULL,0,jjj)))
             {
               B_tm=iTime(NULL,0,jjj);
               B_pr=iLow(NULL,0,jjj);
             }
             
           if ((iTime(NULL,0,jjj+1)<ObjectGet("B",0)) && (iTime(NULL,0,jjj)>=ObjectGet("B",0)) &&(ObjectGet("B",1)>=iLow(NULL,0,jjj)))
             {
               B_tm=iTime(NULL,0,jjj);
               B_pr=iHigh(NULL,0,jjj);
             }             

           if ((iTime(NULL,0,jjj+1)<ObjectGet("A",0)) && (iTime(NULL,0,jjj)>=ObjectGet("A",0)) &&(ObjectGet("A",1)<=iHigh(NULL,0,jjj)))
             {
               A_tm=iTime(NULL,0,jjj);
               A_pr=iLow(NULL,0,jjj);
             }
             
           if ((iTime(NULL,0,jjj+1)<ObjectGet("A",0)) && (iTime(NULL,0,jjj)>=ObjectGet("A",0)) &&(ObjectGet("A",1)>=iLow(NULL,0,jjj)))
             {
               A_tm=iTime(NULL,0,jjj);
               A_pr=iHigh(NULL,0,jjj);
             }             
           
           if ((iTime(NULL,0,jjj+1)<ObjectGet("X",0)) && (iTime(NULL,0,jjj)>=ObjectGet("X",0)) && (ObjectGet("X",1)<=iHigh(NULL,0,jjj)))
             {
               X_tm=iTime(NULL,0,jjj);
               X_pr=iLow(NULL,0,jjj);
             }
             
           if ((iTime(NULL,0,jjj+1)<ObjectGet("X",0)) && (iTime(NULL,0,jjj)>=ObjectGet("X",0)) && (ObjectGet("X",1)>=iLow(NULL,0,jjj)))
             {
               X_tm=iTime(NULL,0,jjj);
               X_pr=iHigh(NULL,0,jjj);
             }           
             
            if (X_tm!=Time[0]) 
              {
                break;
              }              
         }     
         
             if(ObjectFind("XA_0")<0)
               {
                 ObjectCreate("XA_0",OBJ_TREND,0,X_tm,X_pr,A_tm,A_pr);
                 ObjectSet("XA_0",OBJPROP_RAY,0);
               }     
               else
               {
                 ObjectSet("XA_0",0,X_tm);
                 ObjectSet("XA_0",1,X_pr);
                 ObjectSet("XA_0",2,A_tm);
                 ObjectSet("XA_0",3,A_pr);
               }
               
             if(ObjectFind("AB_0")<0)
               {
                 ObjectCreate("AB_0",OBJ_TREND,0,A_tm,A_pr,B_tm,B_pr);
                 ObjectSet("AB_0",OBJPROP_RAY,0);
               }
               else
               {
                 ObjectSet("AB_0",0,A_tm);
                 ObjectSet("AB_0",1,A_pr);
                 ObjectSet("AB_0",2,B_tm);
                 ObjectSet("AB_0",3,B_pr);
               }               
                                   
               
             if(ObjectFind("BC_0")<0)
               {
                 ObjectCreate("BC_0",OBJ_TREND,0,B_tm,B_pr,C_tm,C_pr);
                 ObjectSet("BC_0",OBJPROP_RAY,0);
               }                     
               
               else
               {
                 ObjectSet("BC_0",0,B_tm);
                 ObjectSet("BC_0",1,B_pr);
                 ObjectSet("BC_0",2,C_tm);
                 ObjectSet("BC_0",3,C_pr);
               }                             
               
             if(ObjectFind("CD_0")<0)
               {
                 ObjectCreate("CD_0",OBJ_TREND,0,C_tm,C_pr,D_tm,D_pr);
                 ObjectSet("CD_0",OBJPROP_RAY,0);
               }                     
               
               else
               {
                 ObjectSet("CD_0",0,C_tm);
                 ObjectSet("CD_0",1,C_pr);
                 ObjectSet("CD_0",2,D_tm);
                 ObjectSet("CD_0",3,D_pr);
               }                                            
      } // end else
      
   LlXA = MathAbs(X_pr-A_pr); 
   LlAB = MathAbs(A_pr-B_pr); 
   LlBC = MathAbs(B_pr-C_pr); 
   LlCD = MathAbs(C_pr-D_pr); 
   LlXB = MathAbs(X_pr-B_pr); 
   LlAC = MathAbs(A_pr-C_pr); 
   LlXD = MathAbs(X_pr-D_pr); 
   LlBD = MathAbs(B_pr-D_pr); 
 //  End bikin XABCDE   
 
 
 //Harmonik_Ratios

//+------------------------------------------------------------------+
//|                                              Harmonic Ratios.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
//#property copyright "all traders"
//#property link      "www.forexfactory.com"

//#define	OBJNAME_LABEL	"Harmonic Ratios :)"

//#property indicator_chart_window

//extern bool Active = True;
//extern int Harmonic_Pattern_No= 0;

//int init() {
//	createIndicatorLabel(OBJNAME_LABEL);
//	return(0);
//}

//int deinit() {
//	ObjectDelete(OBJNAME_LABEL);
//	return(0);
//}

//+------------------------------------------------------------------+
//|start function                                                    |
//+------------------------------------------------------------------+
//bool Active = True; Active=true;
//int Harmonic_Pattern_No= 0;

//int start()
//  {
  //Check if indicator is active
  if (Active==false)
  {
  ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios: Off :(",9,"Arial",White);
  return;
  }
  else
  ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios: On :)",9,"Arial",White);
  
  //Check if input is valid
  if (Harmonic_Pattern_No<0)
  {
  ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios- Error: Invalid Harmonic Pattern No.!",9,"Arial",White);
  return;
  }  
//----
   //Check if segments exist with Harmonic Pattern No.
   bool bXA=False,bAB=False,bBC=False,bCD=False;
   string sXA,sAB,sBC,sCD,sDX,sAC,sBD,sXB;
   // Iterate over objects on this chart
   for (int i=ObjectsTotal()-1;i>=0;i--)
   {
      string	sObjName 	= ObjectName(i);
      if (sObjName==StringConcatenate("XA_",Harmonic_Pattern_No) && ObjectType(sObjName)==OBJ_TREND)
      {
      bXA=True;
      sXA=sObjName;
      }
      else if (sObjName==StringConcatenate("AB_",Harmonic_Pattern_No) && ObjectType(sObjName)==OBJ_TREND)
      {
      bAB=True;
      sAB=sObjName;
      }
      else if (sObjName==StringConcatenate("BC_",Harmonic_Pattern_No) && ObjectType(sObjName)==OBJ_TREND)
      {
      bBC=True;
      sBC=sObjName;
      }
      else if (sObjName==StringConcatenate("CD_",Harmonic_Pattern_No) && ObjectType(sObjName)==OBJ_TREND)
      {
      bCD=True;
      sCD=sObjName;
      }
      else if (bXA==True && bAB==True && bBC==True && bCD==True)
      break;     
   }   

   if(bXA==False || bAB==False || bBC==False || bCD==False)
   {
   ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios- Error: Pattern with specified No. not found!",9,"Arial",White);
   return;
   }
   //Check if segments are properly connected
      
   double lXA,lAB,lBC,lCD,lXB,lAC,lXD,lBD;
   
   lXA = MathAbs(ObjectGet(sXA,OBJPROP_PRICE2)-ObjectGet(sXA,OBJPROP_PRICE1));
   lAB = MathAbs(ObjectGet(sAB,OBJPROP_PRICE2)-ObjectGet(sAB,OBJPROP_PRICE1));
   lBC = MathAbs(ObjectGet(sBC,OBJPROP_PRICE2)-ObjectGet(sBC,OBJPROP_PRICE1));
   lCD = MathAbs(ObjectGet(sCD,OBJPROP_PRICE2)-ObjectGet(sCD,OBJPROP_PRICE1));
   lXB = MathAbs(ObjectGet(sXA,OBJPROP_PRICE1)-ObjectGet(sAB,OBJPROP_PRICE2));
   lAC = MathAbs(ObjectGet(sXA,OBJPROP_PRICE2)-ObjectGet(sCD,OBJPROP_PRICE1));
   lXD = MathAbs(ObjectGet(sXA,OBJPROP_PRICE1)-ObjectGet(sCD,OBJPROP_PRICE2));
   lBD = MathAbs(ObjectGet(sBC,OBJPROP_PRICE1)-ObjectGet(sCD,OBJPROP_PRICE2));
   
   if(ObjectGet(sXA,OBJPROP_PRICE2)!=ObjectGet(sAB,OBJPROP_PRICE1) || ObjectGet(sXA,OBJPROP_TIME2)!=ObjectGet(sAB,OBJPROP_TIME1))
   {
   ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios- Error: XA is not properly connected to AB!",9,"Arial",White);
   return;
   }
   else if(ObjectGet(sAB,OBJPROP_PRICE2)!=ObjectGet(sBC,OBJPROP_PRICE1) || ObjectGet(sAB,OBJPROP_TIME2)!=ObjectGet(sBC,OBJPROP_TIME1))
   {
   ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios- Error: AB is not properly connected to BC!",9,"Arial",White);
   return;
   }
   else if(ObjectGet(sBC,OBJPROP_PRICE2)!=ObjectGet(sCD,OBJPROP_PRICE1) || ObjectGet(sBC,OBJPROP_TIME2)!=ObjectGet(sCD,OBJPROP_TIME1))
   {
   ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios- Error: BC is not properly connected to CD!",9,"Arial",White);
   return;
   }
   else if(ObjectGet(sXA,OBJPROP_TIME2)<ObjectGet(sXA,OBJPROP_TIME1))
   {
   ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios- Error: Vertex A must be to the right of X",9,"Arial",White);
   return;
   }
   else if(ObjectGet(sAB,OBJPROP_TIME2)<ObjectGet(sAB,OBJPROP_TIME1))
   {
   ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios- Error: Vertex B must be to the right of A",9,"Arial",White);
   return;
   }
   else if(ObjectGet(sBC,OBJPROP_TIME2)<ObjectGet(sBC,OBJPROP_TIME1))
   {
   ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios- Error: Vertex C must be to the right of B",9,"Arial",White);
   return;
   }
   else if(ObjectGet(sCD,OBJPROP_TIME2)<ObjectGet(sCD,OBJPROP_TIME1))
   {
   ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios- Error: Vertex D must be to the right of C",9,"Arial",White);
   return;
   }
   
   //Label the pattern with letter XABCD
   bool bVX=false,bVA=false,bVB=false,bVC=false,bVD=false;
   //Only update label positions if already exist
   for (int j=ObjectsTotal()-1;j>=0;j--)
   {
   if (ObjectName(j)==StringConcatenate("X_",Harmonic_Pattern_No) && ObjectType(ObjectName(j))==OBJ_TEXT)
   {
   ObjectSet(ObjectName(j), OBJPROP_TIME1, ObjectGet(sXA,OBJPROP_TIME1));
   ObjectSet(ObjectName(j), OBJPROP_PRICE1, ObjectGet(sXA,OBJPROP_PRICE1));
   bVX=true;
   }
   else if (ObjectName(j)==StringConcatenate("A_",Harmonic_Pattern_No) && ObjectType(ObjectName(j))==OBJ_TEXT)
   {
   ObjectSet(ObjectName(j), OBJPROP_TIME1, ObjectGet(sAB,OBJPROP_TIME1));
   ObjectSet(ObjectName(j), OBJPROP_PRICE1, ObjectGet(sAB,OBJPROP_PRICE1));
   bVA=true;
   }
   else if (ObjectName(j)==StringConcatenate("B_",Harmonic_Pattern_No) && ObjectType(ObjectName(j))==OBJ_TEXT)
   {
   ObjectSet(ObjectName(j), OBJPROP_TIME1, ObjectGet(sBC,OBJPROP_TIME1));
   ObjectSet(ObjectName(j), OBJPROP_PRICE1, ObjectGet(sBC,OBJPROP_PRICE1));
   bVB=true;
   }
   else if (ObjectName(j)==StringConcatenate("C_",Harmonic_Pattern_No) && ObjectType(ObjectName(j))==OBJ_TEXT)
   {
   ObjectSet(ObjectName(j), OBJPROP_TIME1, ObjectGet(sCD,OBJPROP_TIME1));
   ObjectSet(ObjectName(j), OBJPROP_PRICE1, ObjectGet(sCD,OBJPROP_PRICE1));
   bVC=true;
   }
   else if (ObjectName(j)==StringConcatenate("D_",Harmonic_Pattern_No) && ObjectType(ObjectName(j))==OBJ_TEXT)
   {
   ObjectSet(ObjectName(j), OBJPROP_TIME1, ObjectGet(sCD,OBJPROP_TIME2));
   ObjectSet(ObjectName(j), OBJPROP_PRICE1, ObjectGet(sCD,OBJPROP_PRICE2));
   bVD=true;
   }
   else if(bVX==true && bVA==true && bVB==true && bVC==true && bVD==true)
   break;
   }
   
   //Create vertex labels if not already exist
   if (bVX==false)
   {
   ObjectCreate(StringConcatenate("X_",Harmonic_Pattern_No), OBJ_TEXT, 0, ObjectGet(sXA,OBJPROP_TIME1), ObjectGet(sXA,OBJPROP_PRICE1));
   ObjectSetText(StringConcatenate("X_",Harmonic_Pattern_No), StringConcatenate("X_",Harmonic_Pattern_No), 10, "Times New Roman", White);
   }
   if (bVA==false)
   {
   ObjectCreate(StringConcatenate("A_",Harmonic_Pattern_No), OBJ_TEXT, 0, ObjectGet(sAB,OBJPROP_TIME1), ObjectGet(sAB,OBJPROP_PRICE1));
   ObjectSetText(StringConcatenate("A_",Harmonic_Pattern_No), StringConcatenate("A_",Harmonic_Pattern_No), 10, "Times New Roman", White);
   }
   if (bVB==false)
   {
   ObjectCreate(StringConcatenate("B_",Harmonic_Pattern_No), OBJ_TEXT, 0, ObjectGet(sBC,OBJPROP_TIME1), ObjectGet(sBC,OBJPROP_PRICE1));
   ObjectSetText(StringConcatenate("B_",Harmonic_Pattern_No), StringConcatenate("B_",Harmonic_Pattern_No), 10, "Times New Roman",  White);
   }
   if (bVC==false)
   {
   ObjectCreate(StringConcatenate("C_",Harmonic_Pattern_No), OBJ_TEXT, 0, ObjectGet(sCD,OBJPROP_TIME1), ObjectGet(sCD,OBJPROP_PRICE1));
   ObjectSetText(StringConcatenate("C_",Harmonic_Pattern_No), StringConcatenate("C_",Harmonic_Pattern_No), 10, "Times New Roman",  White);
   }
   if (bVD==false)
   {
   ObjectCreate(StringConcatenate("D_",Harmonic_Pattern_No), OBJ_TEXT, 0, ObjectGet(sCD,OBJPROP_TIME2), ObjectGet(sCD,OBJPROP_PRICE2));
   ObjectSetText(StringConcatenate("D_",Harmonic_Pattern_No), StringConcatenate("D_",Harmonic_Pattern_No), 10, "Times New Roman",  White);
   }
   

   //draw dotted lines DX and AC and BD and XB
   bool bDX=false,bAC=false,bBD=false,bXB=false;
   //Only update dotted lines if already exist
   for (int k=ObjectsTotal()-1;k>=0;k--)
   {
   if (ObjectName(k)==StringConcatenate("DX_",Harmonic_Pattern_No) && ObjectType(ObjectName(k))==OBJ_TREND)
   {
   ObjectSet(ObjectName(k), OBJPROP_TIME1, ObjectGet(sCD,OBJPROP_TIME2));
   ObjectSet(ObjectName(k), OBJPROP_PRICE1, ObjectGet(sCD,OBJPROP_PRICE2));
   ObjectSet(ObjectName(k), OBJPROP_TIME2, ObjectGet(sXA,OBJPROP_TIME1));
   ObjectSet(ObjectName(k), OBJPROP_PRICE2, ObjectGet(sXA,OBJPROP_PRICE1));
   sDX = StringConcatenate("DX_",Harmonic_Pattern_No);
   bDX=true;
   }
   else if (ObjectName(k)==StringConcatenate("AC_",Harmonic_Pattern_No) && ObjectType(ObjectName(k))==OBJ_TREND)
   {
   ObjectSet(ObjectName(k), OBJPROP_TIME1, ObjectGet(sAB,OBJPROP_TIME1));
   ObjectSet(ObjectName(k), OBJPROP_PRICE1, ObjectGet(sAB,OBJPROP_PRICE1));
   ObjectSet(ObjectName(k), OBJPROP_TIME2, ObjectGet(sBC,OBJPROP_TIME2));
   ObjectSet(ObjectName(k), OBJPROP_PRICE2, ObjectGet(sBC,OBJPROP_PRICE2));
   sAC = StringConcatenate("AC_",Harmonic_Pattern_No);
   bAC=true;
   }
   else if (ObjectName(k)==StringConcatenate("BD_",Harmonic_Pattern_No) && ObjectType(ObjectName(k))==OBJ_TREND)
   {
   ObjectSet(ObjectName(k), OBJPROP_TIME1, ObjectGet(sBC,OBJPROP_TIME1));
   ObjectSet(ObjectName(k), OBJPROP_PRICE1, ObjectGet(sBC,OBJPROP_PRICE1));
   ObjectSet(ObjectName(k), OBJPROP_TIME2, ObjectGet(sCD,OBJPROP_TIME2));
   ObjectSet(ObjectName(k), OBJPROP_PRICE2, ObjectGet(sCD,OBJPROP_PRICE2));
   sBD = StringConcatenate("BD_",Harmonic_Pattern_No);
   bBD=true;
   }
   if (ObjectName(k)==StringConcatenate("XB_",Harmonic_Pattern_No) && ObjectType(ObjectName(k))==OBJ_TREND)
   {
   ObjectSet(ObjectName(k), OBJPROP_TIME1, ObjectGet(sXA,OBJPROP_TIME1));
   ObjectSet(ObjectName(k), OBJPROP_PRICE1, ObjectGet(sXA,OBJPROP_PRICE1));
   ObjectSet(ObjectName(k), OBJPROP_TIME2, ObjectGet(sAB,OBJPROP_TIME2));
   ObjectSet(ObjectName(k), OBJPROP_PRICE2, ObjectGet(sAB,OBJPROP_PRICE2));
   sXB = StringConcatenate("XB_",Harmonic_Pattern_No);
   bXB=true;
   }
   else if(bDX==true && bAC==true && bBD==true && bXB==true)
   break;
   }
   
   //Create dotted lines if not already exist
   if (bDX==false)
   {
   ObjectCreate(StringConcatenate("DX_",Harmonic_Pattern_No), OBJ_TREND, 0, ObjectGet(sCD,OBJPROP_TIME2), ObjectGet(sCD,OBJPROP_PRICE2), ObjectGet(sXA,OBJPROP_TIME1), ObjectGet(sXA,OBJPROP_PRICE1));
   ObjectSet(StringConcatenate("DX_",Harmonic_Pattern_No), OBJPROP_STYLE, STYLE_DASH);
   ObjectSet(StringConcatenate("DX_",Harmonic_Pattern_No), OBJPROP_RAY, FALSE);
   ObjectSet(StringConcatenate("DX_",Harmonic_Pattern_No), OBJPROP_COLOR, C'128,128,128');
   sDX = StringConcatenate("DX_",Harmonic_Pattern_No);
   }
   if (bAC==false)
   {
   ObjectCreate(StringConcatenate("AC_",Harmonic_Pattern_No), OBJ_TREND, 0, ObjectGet(sAB,OBJPROP_TIME1), ObjectGet(sAB,OBJPROP_PRICE1), ObjectGet(sBC,OBJPROP_TIME2), ObjectGet(sBC,OBJPROP_PRICE2));
   ObjectSet(StringConcatenate("AC_",Harmonic_Pattern_No), OBJPROP_STYLE, STYLE_DASH);
   ObjectSet(StringConcatenate("AC_",Harmonic_Pattern_No), OBJPROP_RAY, FALSE);
   ObjectSet(StringConcatenate("AC_",Harmonic_Pattern_No), OBJPROP_COLOR, C'128,128,128');
   sAC = StringConcatenate("AC_",Harmonic_Pattern_No);
   }
   if (bBD==false)
   {
   ObjectCreate(StringConcatenate("BD_",Harmonic_Pattern_No), OBJ_TREND, 0, ObjectGet(sBC,OBJPROP_TIME1), ObjectGet(sBC,OBJPROP_PRICE1), ObjectGet(sCD,OBJPROP_TIME2), ObjectGet(sCD,OBJPROP_PRICE2));
   ObjectSet(StringConcatenate("BD_",Harmonic_Pattern_No), OBJPROP_STYLE, STYLE_DASH);
   ObjectSet(StringConcatenate("BD_",Harmonic_Pattern_No), OBJPROP_RAY, FALSE);
   ObjectSet(StringConcatenate("BD_",Harmonic_Pattern_No), OBJPROP_COLOR, C'128,128,128');
   sBD = StringConcatenate("BD_",Harmonic_Pattern_No);
   }
   if (bXB==false)
   {
   ObjectCreate(StringConcatenate("XB_",Harmonic_Pattern_No), OBJ_TREND, 0, ObjectGet(sXA,OBJPROP_TIME1), ObjectGet(sXA,OBJPROP_PRICE1), ObjectGet(sAB,OBJPROP_TIME2), ObjectGet(sAB,OBJPROP_PRICE2));
   ObjectSet(StringConcatenate("XB_",Harmonic_Pattern_No), OBJPROP_STYLE, STYLE_DASH);
   ObjectSet(StringConcatenate("XB_",Harmonic_Pattern_No), OBJPROP_RAY, FALSE);
   ObjectSet(StringConcatenate("XB_",Harmonic_Pattern_No), OBJPROP_COLOR, C'128,128,128');
   sXB = StringConcatenate("XB_",Harmonic_Pattern_No);
   }
   
   //Calculate and label fibo ratios
   
   double rABXA,rBCAB,rCDBC,rCDXA;
   //double lXA,lAB,lBC,lCD,lXB,lAC,lXD,lBD;
   if ((lXA==0)||(lAB==0)||(lBC==0)) {return;}
   
   rABXA = lAB/lXA;
   rBCAB = lBC/lAB;
   rCDBC = lCD/lBC;
   if (((ObjectGet("D_0",1)>=ObjectGet("B_0",1)) && (ObjectGet("D_0",1)>=ObjectGet("A_0",1))) ||
      ((ObjectGet("D_0",1)<=ObjectGet("B_0",1)) && (ObjectGet("D_0",1)<=ObjectGet("A_0",1))))
    {rCDXA = (lAB+lBD)/lXA;} else {rCDXA = (lAB-lBD)/lXA;}

   bool bABXA=false,bBCAB=false,bCDBC=false,bCDXA=false;
   //Only update label positions if already exist
   for (int l=ObjectsTotal()-1;l>=0;l--)
   {
   if (ObjectName(l)==StringConcatenate("rABXA_",Harmonic_Pattern_No) && ObjectType(ObjectName(l))==OBJ_TEXT)
   {
   ObjectSet(ObjectName(l), OBJPROP_TIME1, ((ObjectGet(sXA,OBJPROP_TIME1)+ObjectGet(sAB,OBJPROP_TIME2))/2));
   ObjectSet(ObjectName(l), OBJPROP_PRICE1, ((ObjectGet(sXA,OBJPROP_PRICE1)+ObjectGet(sAB,OBJPROP_PRICE2))/2));
   ObjectSetText(ObjectName(l), DoubleToStr(rABXA,3), 10, "Times New Roman", White);
   bABXA=true;
   }
   else if (ObjectName(l)==StringConcatenate("rBCAB_",Harmonic_Pattern_No) && ObjectType(ObjectName(l))==OBJ_TEXT)
   {
   ObjectSet(ObjectName(l), OBJPROP_TIME1, (ObjectGet(sAC,OBJPROP_TIME1)+ObjectGet(sAC,OBJPROP_TIME2))/2);
   ObjectSet(ObjectName(l), OBJPROP_PRICE1, (ObjectGet(sAC,OBJPROP_PRICE1)+ObjectGet(sAC,OBJPROP_PRICE2))/2);
   ObjectSetText(ObjectName(l), DoubleToStr(rBCAB,3), 10, "Times New Roman", White);
   bBCAB=true;
   }
   else if (ObjectName(l)==StringConcatenate("rCDBC_",Harmonic_Pattern_No) && ObjectType(ObjectName(l))==OBJ_TEXT)
   {
   ObjectSet(ObjectName(l), OBJPROP_TIME1, (ObjectGet(sBD,OBJPROP_TIME1)+ObjectGet(sBD,OBJPROP_TIME2))/2);
   ObjectSet(ObjectName(l), OBJPROP_PRICE1, (ObjectGet(sBD,OBJPROP_PRICE1)+ObjectGet(sBD,OBJPROP_PRICE2))/2);
   ObjectSetText(ObjectName(l), DoubleToStr(rCDBC,3), 10, "Times New Roman", White);
   bCDBC=true;
   }
   else if (ObjectName(l)==StringConcatenate("rCDXA_",Harmonic_Pattern_No) && ObjectType(ObjectName(l))==OBJ_TEXT)
   {
   ObjectSet(ObjectName(l), OBJPROP_TIME1, (ObjectGet(sXA,OBJPROP_TIME1)+ObjectGet(sCD,OBJPROP_TIME2))/2);
   ObjectSet(ObjectName(l), OBJPROP_PRICE1, (ObjectGet(sXA,OBJPROP_PRICE1)+ObjectGet(sCD,OBJPROP_PRICE2))/2);
   ObjectSetText(ObjectName(l), DoubleToStr(rCDXA,3), 10, "Times New Roman", White);
   bCDXA=true;
   }
   else if(bABXA==true && bBCAB==true && bCDBC==true && bCDXA==true)
   break;
   }
   
   //Create ratio labels if not already exist Perhitungan disini
   if (bABXA==false)
   {
   ObjectCreate(StringConcatenate("rABXA_",Harmonic_Pattern_No), OBJ_TEXT, 0, (ObjectGet(sXA,OBJPROP_TIME1)+ObjectGet(sAB,OBJPROP_TIME2))/2, (ObjectGet(sXA,OBJPROP_PRICE1)+ObjectGet(sAB,OBJPROP_PRICE2))/2);
   ObjectSetText(StringConcatenate("rABXA_",Harmonic_Pattern_No), DoubleToStr(rABXA,3), 10, "Times New Roman", White);
   }
   if (bBCAB==false)
   {
   ObjectCreate(StringConcatenate("rBCAB_",Harmonic_Pattern_No), OBJ_TEXT, 0, (ObjectGet(sAC,OBJPROP_TIME1)+ObjectGet(sAC,OBJPROP_TIME2))/2, (ObjectGet(sAC,OBJPROP_PRICE1)+ObjectGet(sAC,OBJPROP_PRICE2))/2);
   ObjectSetText(StringConcatenate("rBCAB_",Harmonic_Pattern_No), DoubleToStr(rBCAB,3), 10, "Times New Roman", White);
   }
   if (bCDBC==false)
   {
   ObjectCreate(StringConcatenate("rCDBC_",Harmonic_Pattern_No), OBJ_TEXT, 0, (ObjectGet(sBD,OBJPROP_TIME1)+ObjectGet(sBD,OBJPROP_TIME2))/2, (ObjectGet(sBD,OBJPROP_PRICE1)+ObjectGet(sBD,OBJPROP_PRICE2))/2);
   ObjectSetText(StringConcatenate("rCDBC_",Harmonic_Pattern_No), DoubleToStr(rCDBC,3), 10, "Times New Roman", White);
   }
   if (bCDXA==false)
   {
   ObjectCreate(StringConcatenate("rCDXA_",Harmonic_Pattern_No), OBJ_TEXT, 0, (ObjectGet(sXA,OBJPROP_TIME1)+ObjectGet(sCD,OBJPROP_TIME2))/2, (ObjectGet(sXA,OBJPROP_PRICE1)+ObjectGet(sCD,OBJPROP_PRICE2))/2);
   ObjectSetText(StringConcatenate("rCDXA_",Harmonic_Pattern_No), DoubleToStr(rCDXA,3), 10, "Times New Roman", White);
   }
//----
//   return(0);
//  }
//+------------------------------------------------------------------+

/*
void createIndicatorLabel(string sObjName) {
	
	string sObjText;
	// Set the text
	if(Active==True)
	sObjText = "Harmonic Ratios: On";
	else
	sObjText = "Harmonic Ratios: Off";
	
	// Create and position the label
	ObjectCreate(sObjName,OBJ_LABEL,0,0,0);
	ObjectSetText(sObjName,sObjText,8,"Arial", White);
	ObjectSet(sObjName,OBJPROP_XDISTANCE,5);
	ObjectSet(sObjName,OBJPROP_YDISTANCE,5);
	ObjectSet(sObjName,OBJPROP_CORNER,1);
	
} 
*/ 
 //End Harmonik_Ratios 
 
    ObjectSet("XA_0",OBJPROP_SELECTABLE,false);    
    ObjectSet("AB_0",OBJPROP_SELECTABLE,false);    
    ObjectSet("BC_0",OBJPROP_SELECTABLE,false);    
    ObjectSet("CD_0",OBJPROP_SELECTABLE,false);    
    
    ObjectSet("X_0",OBJPROP_SELECTABLE,false);    
    ObjectSet("A_0",OBJPROP_SELECTABLE,false);    
    ObjectSet("B_0",OBJPROP_SELECTABLE,false);    
    ObjectSet("C_0",OBJPROP_SELECTABLE,false);        
    ObjectSet("D_0",OBJPROP_SELECTABLE,false);        
    
    ObjectSet("DX_0",OBJPROP_SELECTABLE,false);    
    ObjectSet("AC_0",OBJPROP_SELECTABLE,false);    
    ObjectSet("BD_0",OBJPROP_SELECTABLE,false);    
    ObjectSet("XB_0",OBJPROP_SELECTABLE,false);        
    
    ObjectSet("rABXA_0",OBJPROP_SELECTABLE,false);    
    ObjectSet("rBCAB_0",OBJPROP_SELECTABLE,false);    
    ObjectSet("rCDBC_0",OBJPROP_SELECTABLE,false);    
    ObjectSet("rCDXA_0",OBJPROP_SELECTABLE,false);            
    ObjectSet("SEARCH",OBJPROP_SELECTABLE,false);            
    ObjectSet("REC1",OBJPROP_SELECTABLE,false);            
    ObjectSet("REC2",OBJPROP_SELECTABLE,false);            

    

 //  double rABXA,rBCAB,rCDBC,rCDXA;
   rABXA=0.0;rBCAB=0.0;rCDBC=0.0;rCDXA=0.0;
   
   if (ObjectFind(0,"rABXA_0")>=0)
    {
      rABXA=StringToDouble(ObjectGetString(0,"rABXA_0",OBJPROP_TEXT,0));
    }
    
   if (ObjectFind(0,"rBCAB_0")>=0)
    {
      rBCAB=StringToDouble(ObjectGetString(0,"rBCAB_0",OBJPROP_TEXT,0));
    }    
    
   if (ObjectFind(0,"rCDBC_0")>=0)
    {
      rCDBC=StringToDouble(ObjectGetString(0,"rCDBC_0",OBJPROP_TEXT,0));
    }
    
   if (ObjectFind(0,"rCDXA_0")>=0)
    {
      rCDXA=StringToDouble(ObjectGetString(0,"rCDXA_0",OBJPROP_TEXT,0));
    }        
    
// end ambil harga fibo

// Cek pola
   //Hitung
   
   if (ObjectGet("B",1)>ObjectGet("C",1))
      { 
        ArrayInitialize(cari1,999999999.0);  //ganti isi
        ArrayInitialize(cari2,999999999.0);  //ganti isi
        ArrayInitialize(cari3,999999999.0);  //ganti isi
        ArrayInitialize(cari4,999999999.0);  //ganti isi      
      }
   if (ObjectGet("B",1)<ObjectGet("C",1))
      {
        ArrayInitialize(cari1,0.0);
        ArrayInitialize(cari2,0.0);
        ArrayInitialize(cari3,0.0);
        ArrayInitialize(cari4,0.0);
      }
   bool ketemu; ketemu=false;
   for (int jkk=1;jkk<DatabaseRecord;jkk++)  
   {
     bacadata(jkk);
     
          string sep=",";                // A separator as a character
          ushort u_sep;                  // The code of the separator character
          string result[];               // An array to get strings
             //--- Get the separator code
          u_sep=StringGetCharacter(sep,0);
          //--- Split the string to substrings
          int kjk=StringSplit(hasil,u_sep,result);
      string nama,minXB_,maxXB_,minAC_,maxAC_,minBD_,maxBD_,minXD_,maxXD_;
      double makBD,makXD,hasmakD1,hasmakD,hasmakD2;
      hasmakD=0.0;hasmakD1=0.0;hasmakD2=0.0;
      double mikBD,mikXD,hasmikD1,hasmikD,hasmikD2;
      hasmikD=0.0;hasmikD1=0.0;hasmikD2=0.0;      
          nama=result[0];
          minXB_=result[1];
          maxXB_=result[2];
          minAC_=result[3];
          maxAC_=result[4];
          minBD_=result[5];
          maxBD_=result[6];                    
          minXD_=result[7];
          maxXD_=result[8];   
          makBD=StringToDouble(maxBD_);
          makXD=StringToDouble(maxXD_);
          mikBD=StringToDouble(minBD_);
          mikXD=StringToDouble(minXD_);
          
          if (ObjectGet("SEARCH",OBJPROP_BGCOLOR)==clrLime)
           {

          if ((rABXA>=StringToDouble(minXB_)) && (rABXA<=StringToDouble(maxXB_)) &&
             (rBCAB>=StringToDouble(minAC_)) && (rBCAB<=StringToDouble(maxAC_)))
             {
                 //min D1,min D2,max d1, maxd2,  bool cek
                 if (ObjectGet("B",1)>ObjectGet("C",1))          
                 {
                  hasmikD1=(mikBD*LlBC)+ObjectGet("C_0",OBJPROP_PRICE1);
                  hasmikD2=(mikXD*LlXA)+ObjectGet("A_0",OBJPROP_PRICE1);
                  hasmakD1=(makBD*LlBC)+ObjectGet("C_0",OBJPROP_PRICE1);
                  hasmakD2=(makXD*LlXA)+ObjectGet("A_0",OBJPROP_PRICE1); 
                  if (hasmakD2<hasmikD2) {hasmakD2=hasmikD2;hasmikD2=(makXD*LlXA)+ObjectGet("A_0",OBJPROP_PRICE1); }                 
                  if (hasmakD1<hasmikD1) {hasmakD1=hasmikD1;hasmikD1=(makBD*LlBC)+ObjectGet("C_0",OBJPROP_PRICE1);}
                  if ((hasmikD1>=hasmikD2)&&(hasmikD1<=hasmakD2)) {cari1[jkk]=hasmikD1;}
                  if ((hasmikD2>=hasmikD1)&&(hasmikD2<=hasmakD1)) {cari2[jkk]=hasmikD2;}
                  if ((hasmakD1<=hasmakD2)&&(hasmakD1>=hasmikD2)) {cari3[jkk]=hasmakD1;}
                  if ((hasmakD2<=hasmakD1)&&(hasmakD2>=hasmikD1)) {cari4[jkk]=hasmakD2;}
                 }
                 
                 if (ObjectGet("B",1)<ObjectGet("C",1))          
                 {
                  hasmikD1=ObjectGet("C_0",OBJPROP_PRICE1)-(mikBD*LlBC);
                  hasmikD2=ObjectGet("A_0",OBJPROP_PRICE1)-(mikXD*LlXA);
                  hasmakD1=ObjectGet("C_0",OBJPROP_PRICE1)-(makBD*LlBC);
                  hasmakD2=ObjectGet("A_0",OBJPROP_PRICE1)-(makXD*LlXA);                  
                  if (hasmakD2>hasmikD2) {hasmakD2=hasmikD2;hasmikD2=ObjectGet("A_0",OBJPROP_PRICE1)-(makXD*LlXA);}                  
                  if (hasmakD1>hasmikD1) {hasmakD1=hasmikD1;hasmikD1=ObjectGet("C_0",OBJPROP_PRICE1)-(makBD*LlBC);}
                  if ((hasmikD1>=hasmakD2)&&(hasmikD1<=hasmikD2)) {cari1[jkk]=hasmikD1;}
                  if ((hasmikD2>=hasmakD1)&&(hasmikD2<=hasmikD1)) {cari2[jkk]=hasmikD2;}
                  if ((hasmakD1>=hasmakD2)&&(hasmakD1<=hasmikD2)) {cari3[jkk]=hasmakD1;}
                  if ((hasmakD2>=hasmakD1)&&(hasmakD2<=hasmikD1)) {cari4[jkk]=hasmakD2;}  
                 }                       
             }           
             
           }
                    
          if ((rABXA>=StringToDouble(minXB_)) && (rABXA<=StringToDouble(maxXB_)) &&
             (rBCAB>=StringToDouble(minAC_)) && (rBCAB<=StringToDouble(maxAC_)) &&
             (rCDBC>=StringToDouble(minBD_)) && (rCDBC<=StringToDouble(maxBD_)) &&
             (rCDXA>=StringToDouble(minXD_)) && (rCDXA<=StringToDouble(maxXD_)))
           {
             ObjectDelete("nama");
             SetText("nama",nama,25,10,clrRed,24);
          
             ketemu=true;
           }  
           
        wrgval=jkk;   
        if (StringFind(hasil,"END",0)>0){break;}
             
    } 

    if (ketemu==true) 
     {

             ObjectDelete(0,"REC1");
             ObjectDelete(0,"REC2");
             ObjectCreate(0,"REC1",OBJ_TRIANGLE,0,ObjectGetInteger(0,"X_0",OBJPROP_TIME,0),ObjectGet("X_0",1),ObjectGetInteger(0,"A_0",OBJPROP_TIME,0),ObjectGet("A_0",1),ObjectGet("B_0",0),ObjectGet("B_0",1));
             ObjectCreate(0,"REC2",OBJ_TRIANGLE,0,ObjectGetInteger(0,"B_0",OBJPROP_TIME,0),ObjectGet("B_0",1),ObjectGetInteger(0,"C_0",OBJPROP_TIME,0),ObjectGet("C_0",1),ObjectGet("D_0",0),ObjectGet("D_0",1));
             ObjectSet("REC1",OBJPROP_COLOR,triangle1);
             ObjectSet("REC2",OBJPROP_COLOR,triangle1);
     }
    else
     {
     
             ObjectDelete(0,"REC1");
             ObjectDelete(0,"REC2");
             double ab_cd;
             ab_cd=lCD/lAB;
             ObjectDelete("nama"); 
             SetText("nama",DoubleToString(ab_cd,3)+" AB=CD",25,10,clrRed,24);

     }  
     
     
     double XABCD[4],fibretr; ArrayFill(XABCD,0,4,0.0);fibretr=0;
     int max,min;
                XABCD[0]=X_pr;XABCD[1]=A_pr;XABCD[2]=B_pr;XABCD[3]=C_pr;
                max=ArrayMaximum(XABCD);
                min=ArrayMinimum(XABCD);
                if ((XABCD[max]-XABCD[min])!=0) {fibretr=(D_pr-XABCD[min])/(XABCD[max]-XABCD[min]);}
                        
     ObjectDelete("Fib");
     SetText("Fib","Fibo Retrace = "+DoubleToString(fibretr,3),25,50,clrRed,18);
     
     ObjectDelete("Day");
     SetText("Day","Daily Range = "+DoubleToString((iHigh(NULL,1440,0)-iLow(NULL,1440,0))*10000,2),25,75,clrRed,18);     

     ObjectSet("Fib",OBJPROP_SELECTABLE,false);            
     ObjectSet("Day",OBJPROP_SELECTABLE,false);            
     ObjectSet("nama",OBJPROP_SELECTABLE,false);            
     
// end cek pola    

//----  Cari Otomatis
//turun     
             if ((ObjectGet("SEARCH",OBJPROP_BGCOLOR)==clrLime)&&(ObjectGet("D",0)>Time[0])&&(ObjectGet("B",1)<=ObjectGet("C",1)))
              {
               grsbts=0;grsbts1=0;ArrayInitialize(jump,0);Ob_Del_Dn();
                for (int jkk=1;jkk<wrgval;jkk++)  
                 {
                   if ((cari1[jkk]==0)&&(cari2[jkk]==0)&&(cari3[jkk]==0)&&(cari4[jkk]==0)) continue;
                   if ((cari1[jkk]==0)&&(cari2[jkk]==0)) continue;
                   if ((cari3[jkk]==0)&&(cari4[jkk]==0)) continue;
                   if (cari1[jkk]>=cari2[jkk])
                    {
                     if (cari3[jkk]>=cari4[jkk])
                       {
                         //bikin rect
                         ObjectDelete("SLD"+IntegerToString(jkk));
                         ObjectCreate("SLD"+IntegerToString(jkk),OBJ_RECTANGLE,0,ObjectGetInteger(0,"D",OBJPROP_TIME,0),NormalizeDouble(cari1[jkk],5),ObjectGetInteger(0,"D",OBJPROP_TIME,0)+(4*Period()*60),NormalizeDouble(cari3[jkk],5));                         
                         ObjectSet("SLD"+IntegerToString(jkk),OBJPROP_COLOR,clrAqua);
                         found=true;
                         continue;
                       } 
                      else
                       {
                         //bikin rect
                         ObjectDelete("SLD"+IntegerToString(jkk));
                         ObjectCreate("SLD"+IntegerToString(jkk),OBJ_RECTANGLE,0,ObjectGetInteger(0,"D",OBJPROP_TIME,0),NormalizeDouble(cari1[jkk],5),ObjectGetInteger(0,"D",OBJPROP_TIME,0)+(4*Period()*60),NormalizeDouble(cari4[jkk],5));                                                  
                         ObjectSet("SLD"+IntegerToString(jkk),OBJPROP_COLOR,clrAqua);
                         found=true;
                         continue;
                       } 
                    }
                    if (cari2[jkk]>cari1[jkk])
                     {
                      if (cari3[jkk]>=cari4[jkk])
                       {
                         //bikin rect
                         ObjectDelete("SLD"+IntegerToString(jkk));
                         ObjectCreate("SLD"+IntegerToString(jkk),OBJ_RECTANGLE,0,ObjectGetInteger(0,"D",OBJPROP_TIME,0),NormalizeDouble(cari2[jkk],5),ObjectGetInteger(0,"D",OBJPROP_TIME,0)+(4*Period()*60),NormalizeDouble(cari3[jkk],5));                                                  
                         ObjectSet("SLD"+IntegerToString(jkk),OBJPROP_COLOR,clrAqua);
                         found=true;
                         continue;
                       } 
                      else
                       {
                         //bikin rect
                         ObjectDelete("SLD"+IntegerToString(jkk));
                         ObjectCreate("SLD"+IntegerToString(jkk),OBJ_RECTANGLE,0,ObjectGetInteger(0,"D",OBJPROP_TIME,0),NormalizeDouble(cari2[jkk],5),ObjectGetInteger(0,"D",OBJPROP_TIME,0)+(4*Period()*60),NormalizeDouble(cari4[jkk],5));                                                                           
                         ObjectSet("SLD"+IntegerToString(jkk),OBJPROP_COLOR,clrAqua);
                         found=true;
                         continue;
                       }                      
                     }
                 }
//turun

                         if (!found)
                          {
                             ObjectSet("SEARCH",OBJPROP_BGCOLOR,clrRed); 
                             ObjectSet("Tulis",OBJPROP_COLOR,clrWhite); 
                             ObjectDelete(0,"FOUND");
                             SetText("FOUND","Pattern not found !!!",579,25,clrRed,18,"Georgia");  
                             return;
                          }
                     
                 //reposition rect   
                    int hot;hot=0;

                                  double data[][4],sortirdt1[],sortirdt2[],sortirdt3[];
                                  ArrayResize(data,wrgval);
                                  ArrayResize(sortirdt1,wrgval);
                                  ArrayResize(sortirdt2,wrgval);
                                  ArrayResize(sortirdt3,wrgval);
                                 for (int jkk=0;jkk<wrgval;jkk++)  
                                  {
                                      data[jkk][0]=0.0;                                     
                                      data[jkk][1]=0.0;       
                                      data[jkk][2]=0.0; 
                                      data[jkk][3]=0.0; 
                                      sortirdt1[jkk]=0.0;
                                      sortirdt2[jkk]=999999999.0;         // ganti ini                    
                                      sortirdt3[jkk]=0.0;                             
                                    if (ObjectFind("SLD"+IntegerToString(jkk))>=0)
                                     {
                                       data[hot][0]=NormalizeDouble(ObjectGet("SLD"+IntegerToString(jkk),1),5);
                                       data[hot][1]=NormalizeDouble(ObjectGet("SLD"+IntegerToString(jkk),3),5);
                                       data[hot][2]=jkk;
                                       data[hot][3]=data[hot][0]-data[hot][1];
                                       sortirdt1[hot]=data[hot][0];
                                       sortirdt2[hot]=data[hot][1];
                                       sortirdt3[hot]=data[hot][3];
                                       hot++;
                                     }                                 
                                  }             

                                  ArraySort(sortirdt3,WHOLE_ARRAY,0,MODE_DESCEND);         
                                  string ss;ss="";
                                  awal=sortirdt1[ArrayMaximum(sortirdt1,WHOLE_ARRAY,0)];
                                  akhir=sortirdt2[ArrayMinimum(sortirdt2,WHOLE_ARRAY,0)];
                                  if ((awal==0.0)||(akhir==0.0)||(awal==999999999.0)||(akhir==999999999.0))  //ganti ini
                                   {
                                       ObjectSet("SEARCH",OBJPROP_BGCOLOR,clrRed); 
                                       ObjectSet("Tulis",OBJPROP_COLOR,clrWhite); 
                                       ObjectDelete(0,"FOUND");
                                       SetText("FOUND","Pattern not found !!!",579,25,clrRed,18,"Georgia");  
                                       return;
                                   }
                                  ObjectDelete("SLD100");
                                  ObjectCreate("SLD100",OBJ_RECTANGLE,0,Time[0]+(5*Period()*60),awal,Time[0]+(10*Period()*60),akhir);                                                                           
                                  ObjectSet("SLD100",OBJPROP_COLOR,Rect_Dn_Clr);  
                                  ObjectSet("SLD100",OBJPROP_SELECTABLE,false);
                                  ObjectDelete("HorAw100");
                                  ObjectCreate("HorAw100",OBJ_HLINE,0,0,awal);
                                  ObjectSet("HorAw100",OBJPROP_COLOR,Hor_Dn_Clr);
                                  ObjectSet("HorAw100",OBJPROP_SELECTABLE,false);
                                  ObjectDelete("HorAk100");
                                  ObjectCreate("HorAk100",OBJ_HLINE,0,0,akhir);
                                  ObjectSet("HorAk100",OBJPROP_COLOR,Hor_Dn_Clr);
                                  ObjectSet("HorAk100",OBJPROP_SELECTABLE,false);      


                                   double split[][2];
                                   ArrayResize(split,wrgval);
                                   int count;
                                   count=0;
                                   split[0][0]=awal;
                                   split[0][1]=akhir;
                                  for (int jkk=0;jkk<hot;jkk++)   
                                  {
                                      ObjectDelete(0,"SLD"+DoubleToString(data[jkk][2],0)); 
                                    for (int ii=0;ii<hot;ii++)
                                    {
                                       if(sortirdt3[jkk]==data[ii][3])
                                        {
                                          for (int iii=0;iii<=count;iii++)
                                           {
                                            if ((data[ii][0]==split[iii][0])||(data[ii][1]==split[iii][1]))
                                              {
                                                if ((data[ii][0]==split[iii][0]))
                                                  {split[iii][0]=data[ii][1];}
                                                if ((data[ii][1]==split[iii][1]))
                                                  {split[iii][1]=data[ii][0];}                                                  
                                                if ((((data[ii][1]==split[iii][1]))&&((data[ii][0]==split[iii][0])))||    
                                                   (((data[ii][1]==split[iii][0]))&&((data[ii][0]==split[iii][1]))))
                                                   {
                                                     for (int jkklm=0;jkklm<hot;jkklm++)
                                                      {
                                                        ObjectDelete(0,"SLD"+DoubleToString(data[jkklm][2],0)); 
                                                      }   
                                                     ObjectSet("D",1,akhir);
                                                     ObjectSet("SEARCH",OBJPROP_BGCOLOR,clrRed); 
                                                     ObjectSet("Tulis",OBJPROP_COLOR,clrWhite); 
                                                     return;               
                                                   }                                                  
                                              }
                                             else
                                              {
                                                if ((data[ii][0]<split[iii][0])&&(data[ii][1]>split[iii][1]))
                                                   {
                                                     count++;
                                                     split[count][0]=data[ii][1];
                                                     split[count][1]=split[iii][1];
                                                     split[iii][1]=data[ii][0];break;
                                                   }
                                              } 
                                             } 
                                        }
                                    }
                                    
                                  }
                                  
                                  
                                  for (int ii=0;ii<=count;ii++)
                                   {
                                     ObjectDelete("SPLI"+IntegerToString(ii));
                                     ObjectCreate("SPLI"+IntegerToString(ii),OBJ_RECTANGLE,0,Time[0]+(5*Period()*60),split[ii][0],Time[0]+(10*Period()*60),split[ii][1]);
                                     ObjectSet("SPLI"+IntegerToString(ii),OBJPROP_COLOR,Rect_Dn_Clr);
                                     ObjectSet("SPLI"+IntegerToString(ii),OBJPROP_SELECTABLE,false);                                                                     
                                     ObjectDelete(0,"HorSpliAw"+IntegerToString(ii));
                                     ObjectCreate("HorSpliAw"+IntegerToString(ii),OBJ_HLINE,0,0,split[ii][0]);
                                     ObjectSet("HorSpliAw"+IntegerToString(ii),OBJPROP_COLOR,Hor_Dn_Clr);                                   
                                     ObjectSet("HorSpliAw"+IntegerToString(ii),OBJPROP_SELECTABLE,false);
                                     ObjectDelete(0,"HorSpliAk"+IntegerToString(ii));
                                     ObjectCreate("HorSpliAk"+IntegerToString(ii),OBJ_HLINE,0,0,split[ii][1]);
                                     ObjectSet("HorSpliAk"+IntegerToString(ii),OBJPROP_COLOR,Hor_Dn_Clr);
                                     ObjectSet("HorSpliAk"+IntegerToString(ii),OBJPROP_SELECTABLE,false);                                   
                                   }
                                   
                                     ObjectSet("D",1,akhir); 
                                     ObjectSet("SEARCH",OBJPROP_BGCOLOR,clrRed); 
                                     ObjectSet("Tulis",OBJPROP_COLOR,clrWhite); 
                                     
              }

// naik
              
             if ((ObjectGet("SEARCH",OBJPROP_BGCOLOR)==clrLime)&&(ObjectGet("D",0)>Time[0])&&(ObjectGet("B",1)>ObjectGet("C",1)))
              {
                grsbts2=0;grsbts3=0;ArrayInitialize(jump1,0); Ob_Del_Up(); 
                
                for (int jkk=1;jkk<wrgval;jkk++)  
                 {
                   if ((cari1[jkk]==999999999)&&(cari2[jkk]==999999999)&&(cari3[jkk]==999999999)&&(cari4[jkk]==999999999)) continue;  // ganti ini
                   if ((cari1[jkk]==999999999)&&(cari2[jkk]==999999999)) continue; // ganti ini
                   if ((cari3[jkk]==999999999)&&(cari4[jkk]==999999999)) continue; // ganti ini
                   if (cari1[jkk]<=cari2[jkk])
                    {
                     if (cari3[jkk]<=cari4[jkk])
                       {
                         //bikin rect
                         ObjectDelete("SL"+IntegerToString(jkk));
                         ObjectCreate("SL"+IntegerToString(jkk),OBJ_RECTANGLE,0,ObjectGetInteger(0,"D",OBJPROP_TIME,0),NormalizeDouble(cari1[jkk],5),ObjectGetInteger(0,"D",OBJPROP_TIME,0)+(4*Period()*60),NormalizeDouble(cari3[jkk],5));                         
                         ObjectSet("SL"+IntegerToString(jkk),OBJPROP_COLOR,clrRed);
                         found=true;
                         continue;
                       } 
                      else
                       {
                         //bikin rect
                         ObjectDelete("SL"+IntegerToString(jkk));
                         ObjectCreate("SL"+IntegerToString(jkk),OBJ_RECTANGLE,0,ObjectGetInteger(0,"D",OBJPROP_TIME,0),NormalizeDouble(cari1[jkk],5),ObjectGetInteger(0,"D",OBJPROP_TIME,0)+(4*Period()*60),NormalizeDouble(cari4[jkk],5));                                                  
                         ObjectSet("SL"+IntegerToString(jkk),OBJPROP_COLOR,clrRed);
                         found=true;
                         continue;
                       } 
                    }
                    if (cari2[jkk]<cari1[jkk])
                     {
                      if (cari3[jkk]<=cari4[jkk])
                       {
                         //bikin rect
                         ObjectDelete("SL"+IntegerToString(jkk));
                         ObjectCreate("SL"+IntegerToString(jkk),OBJ_RECTANGLE,0,ObjectGetInteger(0,"D",OBJPROP_TIME,0),NormalizeDouble(cari2[jkk],5),ObjectGetInteger(0,"D",OBJPROP_TIME,0)+(4*Period()*60),NormalizeDouble(cari3[jkk],5));                                                  
                         ObjectSet("SL"+IntegerToString(jkk),OBJPROP_COLOR,clrRed);
                         found=true;
                         continue;
                       } 
                      else
                       {
                         //bikin rect
                         ObjectDelete("SL"+IntegerToString(jkk));
                         ObjectCreate("SL"+IntegerToString(jkk),OBJ_RECTANGLE,0,ObjectGetInteger(0,"D",OBJPROP_TIME,0),NormalizeDouble(cari2[jkk],5),ObjectGetInteger(0,"D",OBJPROP_TIME,0)+(4*Period()*60),NormalizeDouble(cari4[jkk],5));                                                                           
                         ObjectSet("SL"+IntegerToString(jkk),OBJPROP_COLOR,clrRed);
                         found=true;
                         continue;
                       }                      
                     }
                 }
                 
                         if (!found)
                          {
                             ObjectSet("SEARCH",OBJPROP_BGCOLOR,clrRed); 
                             ObjectSet("Tulis",OBJPROP_COLOR,clrWhite); 
                             ObjectDelete(0,"FOUND");
                             SetText("FOUND","Pattern not found !!!",579,25,clrRed,18,"Georgia");  
                             return;
                          }
                                           
                 //reposition rect   
                    int hot;hot=0;

                                  double data[][4],sortirdt1[],sortirdt2[],sortirdt3[];
                                  ArrayResize(data,wrgval);
                                  ArrayResize(sortirdt1,wrgval);
                                  ArrayResize(sortirdt2,wrgval);
                                  ArrayResize(sortirdt3,wrgval);
                                 for (int jkk=0;jkk<wrgval;jkk++)  
                                  {
                                      data[jkk][0]=0.0;                                     
                                      data[jkk][1]=0.0;       
                                      data[jkk][2]=0.0; 
                                      data[jkk][3]=0.0; 
                                      sortirdt1[jkk]=999999999.0;    //ganti ini
                                      sortirdt2[jkk]=0.0;                             
                                      sortirdt3[jkk]=0.0;                             
                                    if (ObjectFind("SL"+IntegerToString(jkk))>=0)
                                     {
                                       data[hot][0]=NormalizeDouble(ObjectGet("SL"+IntegerToString(jkk),1),5);
                                       data[hot][1]=NormalizeDouble(ObjectGet("SL"+IntegerToString(jkk),3),5);
                                       data[hot][2]=jkk;
                                       data[hot][3]=data[hot][1]-data[hot][0];
                                       sortirdt1[hot]=data[hot][0];
                                       sortirdt2[hot]=data[hot][1];
                                       sortirdt3[hot]=data[hot][3];
                                       hot++;
                                     }                                 
                                  }             
                                
                                  ArraySort(sortirdt3,WHOLE_ARRAY,0,MODE_DESCEND);         
                                  string ss;ss="";
                                  awal=sortirdt1[ArrayMinimum(sortirdt1,WHOLE_ARRAY,0)];
                                  akhir=sortirdt2[ArrayMaximum(sortirdt2,WHOLE_ARRAY,0)];
                                  if ((awal==0.0)||(akhir==0.0)||(awal==999999999.0)||(akhir==999999999.0))  // ganti ini
                                   {
                                       ObjectSet("SEARCH",OBJPROP_BGCOLOR,clrRed); 
                                       ObjectSet("Tulis",OBJPROP_COLOR,clrWhite); 
                                       ObjectDelete(0,"FOUND");
                                       SetText("FOUND","Pattern not found !!!",579,25,clrRed,18,"Georgia");  
                                       return;
                                   }                                  
                                  ObjectDelete("SL100");
                                  ObjectCreate("SL100",OBJ_RECTANGLE,0,Time[0]+(5*Period()*60),awal,Time[0]+(10*Period()*60),akhir);                                                                           
                                  ObjectSet("SL100",OBJPROP_COLOR,Rect_Up_Clr); 
                                  ObjectSet("SL100",OBJPROP_SELECTABLE,false); 
                                  ObjectDelete("HorUpAw100");
                                  ObjectCreate("HorUpAw100",OBJ_HLINE,0,0,awal);
                                  ObjectSet("HorUpAw100",OBJPROP_COLOR,Hor_Up_Clr);
                                  ObjectSet("HorUpAw100",OBJPROP_SELECTABLE,false); 
                                  ObjectDelete("HorUpAk100");
                                  ObjectCreate("HorUpAk100",OBJ_HLINE,0,0,akhir);
                                  ObjectSet("HorUpAk100",OBJPROP_COLOR,Hor_Up_Clr); 
                                  ObjectSet("HorUpAk100",OBJPROP_SELECTABLE,false);      


                                   double split[][2];
                                   ArrayResize(split,wrgval);
                                   int count;
                                   count=0;
                                   split[0][0]=awal;
                                   split[0][1]=akhir;
                                  for (int jkk=0;jkk<hot;jkk++)   
                                  {
                                      ObjectDelete(0,"SL"+DoubleToString(data[jkk][2],0)); 
                                    for (int ii=0;ii<hot;ii++)
                                    {
                                       if(sortirdt3[jkk]==data[ii][3])
                                        {
                                          for (int iii=0;iii<=count;iii++)
                                           {
                                            if ((data[ii][0]==split[iii][0])||(data[ii][1]==split[iii][1]))
                                              {
                                                if ((data[ii][0]==split[iii][0]))
                                                  {split[iii][0]=data[ii][1];}
                                                if ((data[ii][1]==split[iii][1]))
                                                  {split[iii][1]=data[ii][0];}  
                                                if ((((data[ii][1]==split[iii][1]))&&((data[ii][0]==split[iii][0])))||    
                                                   (((data[ii][1]==split[iii][0]))&&((data[ii][0]==split[iii][1]))))
                                                   {
                                                     for (int jkklm=0;jkklm<hot;jkklm++)
                                                      {
                                                        ObjectDelete(0,"SL"+DoubleToString(data[jkklm][2],0)); 
                                                      }                                                      
                                                     ObjectSet("D",1,akhir);
                                                     ObjectSet("SEARCH",OBJPROP_BGCOLOR,clrRed); 
                                                     ObjectSet("Tulis",OBJPROP_COLOR,clrWhite); 
                                                     return;               
                                                   }
                                              }
                                             else
                                              {
                                                if ((data[ii][0]>split[iii][0])&&(data[ii][1]<split[iii][1]))
                                                   {
                                                     count++;
                                                     split[count][0]=data[ii][1];
                                                     split[count][1]=split[iii][1];
                                                     split[iii][1]=data[ii][0];break;
                                                   }
                                              } 
                                             } 
                                        }
                                    }
                                    
                                  }
                                  
                                  for (int ii=0;ii<=count;ii++)
                                   {
                                     ObjectDelete("SPLIUP"+IntegerToString(ii));
                                     ObjectCreate("SPLIUP"+IntegerToString(ii),OBJ_RECTANGLE,0,Time[0]+(5*Period()*60),split[ii][0],Time[0]+(10*Period()*60),split[ii][1]);
                                     ObjectSet("SPLIUP"+IntegerToString(ii),OBJPROP_COLOR,Rect_Up_Clr); 
                                     ObjectSet("SPLIUP"+IntegerToString(ii),OBJPROP_SELECTABLE,false);                                                                     
                                     ObjectDelete(0,"HorSpliUpAw"+IntegerToString(ii));
                                     ObjectCreate("HorSpliUpAw"+IntegerToString(ii),OBJ_HLINE,0,0,split[ii][0]);
                                     ObjectSet("HorSpliUpAw"+IntegerToString(ii),OBJPROP_COLOR,Hor_Up_Clr);                                   
                                     ObjectSet("HorSpliUpAw"+IntegerToString(ii),OBJPROP_SELECTABLE,false);
                                     ObjectDelete(0,"HorSpliUpAk"+IntegerToString(ii));
                                     ObjectCreate("HorSpliUpAk"+IntegerToString(ii),OBJ_HLINE,0,0,split[ii][1]);
                                     ObjectSet("HorSpliUpAk"+IntegerToString(ii),OBJPROP_COLOR,Hor_Up_Clr);
                                     ObjectSet("HorSpliUpAk"+IntegerToString(ii),OBJPROP_SELECTABLE,false);                                   
                                   }                 
                                     ObjectSet("D",1,akhir);
                                     ObjectSet("SEARCH",OBJPROP_BGCOLOR,clrRed); 
                                     ObjectSet("Tulis",OBJPROP_COLOR,clrWhite); 
                                     
              }              
  //-----------------------------------------------           
//End Cari Otomatis
    
   return;
 }

//+------------------------------------------------------------------+

string bacadata(int posisi)
{

//--- variables for positions of the strings' start points
   ulong pos[];
   int   size;
//--- reset the error value
   ResetLastError();
//--- open the file
   int file_handle=FileOpen(InpFileName,FILE_READ|FILE_CSV|InpEncodingType);
   if(file_handle!=INVALID_HANDLE)
     {
  //    PrintFormat("%s file is available for reading",InpFileName);
      //--- receive start position for each string in the file
      GetStringPositions(file_handle,pos);
      //--- define the number of strings in the file
      size=ArraySize(pos);
      if(!size)
        {
         //--- stop if the file does not have strings
  //       PrintFormat("%s file is empty!",InpFileName);
         FileClose(file_handle);
         return("");
        }
      //--- make a random selection of a string number
      int ind=posisi;

      //--- shift position to the starting point of the string
      FileSeek(file_handle,pos[ind],SEEK_SET);

      //--- read and print the string with ind number
      hasil=FileReadString(file_handle);
      FileReadString(file_handle);
      if (FileIsEnding(file_handle)) {hasil=hasil+"END";}
      FileClose(file_handle);
      
      

     }
   else
      PrintFormat("Failed to open %s file, Error code = %d",InpFileName,GetLastError());
   return(hasil);
}

void SetText(string name,string text,int x,int y,color colour,int fontsize=12, string font="Arial")
  {
   if(ObjectCreate(0,name,OBJ_LABEL,0,0,0))
     {
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
      ObjectSetString(0,name,OBJPROP_FONT,font);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
     }
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }
  
void SetPanel(string name,int sub_window,int x,int y,int width,int height,color bg_color,color border_clr,int border_width)
  {
   if(ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(0,name,OBJPROP_COLOR,border_clr);
      ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,border_width);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,0);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
     }
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg_color);
  }  
  
void GetStringPositions(const int handle,ulong &arr[])
  {
//--- default array size
   int def_size=127;
//--- allocate memory for the array
   ArrayResize(arr,def_size);
//--- string counter
   int i=0;
//--- if this is not the file's end, then there is at least one string
   if(!FileIsEnding(handle))
     {
      arr[i]=FileTell(handle);
      i++;
     }
   else
      return; // the file is empty, exit
//--- define the shift in bytes depending on encoding
   int shift;
   if(FileGetInteger(handle,FILE_IS_ANSI))
      shift=1;
   else
      shift=2;
//--- go through the strings in the loop
   while(1)
     {
      //--- read the string
      FileReadString(handle);
      //--- check for the file end
      if(!FileIsEnding(handle))
        {
         //--- store the next string's position
         arr[i]=FileTell(handle)+shift;
         i++;
         //--- increase the size of the array if it is overflown
         if(i==def_size)
           {
            def_size+=def_size+1;
            ArrayResize(arr,def_size);
           }
        }
      else
         break; // end of the file, exit
     }
//--- define the actual size of the array
   ArrayResize(arr,i);
  }  
  
void  Ob_Del_Up()

{
   for (int yy=0;yy<100;yy++)
    {
      if (ObjectFind(0,"SPLIUP"+IntegerToString(yy))>=0)
       {
         ObjectDelete(0,"SPLIUP"+IntegerToString(yy));    
       }
       else {return;}
       
      if (ObjectFind(0,"HorSpliUpAw"+IntegerToString(yy))>=0)
       {
         ObjectDelete(0,"HorSpliUpAw"+IntegerToString(yy));    
       }       
       
      if (ObjectFind(0,"HorSpliUpAk"+IntegerToString(yy))>=0)
       {
         ObjectDelete(0,"HorSpliUpAk"+IntegerToString(yy));    
       }              
    }
    return;
}  

void  Ob_Del_Dn()

{
   for (int yy=0;yy<100;yy++)
    {
      if (ObjectFind(0,"SPLI"+IntegerToString(yy))>=0)
       {
         ObjectDelete(0,"SPLI"+IntegerToString(yy));    
       }
       else {return;}
      if (ObjectFind(0,"HorSpliAw"+IntegerToString(yy))>=0)
       {
         ObjectDelete(0,"HorSpliAw"+IntegerToString(yy));    
       }       
       
      if (ObjectFind(0,"HorSpliAk"+IntegerToString(yy))>=0)
       {
         ObjectDelete(0,"HorSpliAk"+IntegerToString(yy));    
       }              
       

    }
    return;

}



void createIndicatorLabel(string sObjName) {
	
	string sObjText;
	// Set the text
	if(Active==True)
	sObjText = "Harmonic Ratios: On";
	else
	sObjText = "Harmonic Ratios: Off";
	
	// Create and position the label
	ObjectCreate(sObjName,OBJ_LABEL,0,0,0);
	ObjectSetText(sObjName,sObjText,8,"Arial", White);
	ObjectSet(sObjName,OBJPROP_XDISTANCE,5);
	ObjectSet(sObjName,OBJPROP_YDISTANCE,5);
	ObjectSet(sObjName,OBJPROP_CORNER,1);
	
}void reset()
{
        ObjectDelete(0,"FOUND");
        ObjectDelete(OBJNAME_LABEL);
        ObjectDelete(0,"JUMP");
        ObjectDelete(0,"Tulis1");
        ObjectDelete(0,"ON");
        ObjectDelete(0,"STATUS");        
	     Ob_Del_Dn();
	     Ob_Del_Up();  
	     ObjectDelete(0,"nama");
	     ObjectDelete(0,"Fib");
	     ObjectDelete(0,"Day");
	     ObjectDelete(0,"Tulis");	   	   	   
	     ObjectDelete(0,"SEARCH");	   	   	   
	     ObjectDelete(0,"ketemu");	   	   	   
	     ObjectDelete(0,"REC1");	   	   	   	   	   	   
	     ObjectDelete(0,"REC2");	   	   	   	   	   	   
	     ObjectDelete(0,"HorAk100");	   	   	   	   	   	   
	     ObjectDelete(0,"HorAw100");	   	   	   	   	   	   
	     ObjectDelete(0,"SLD100");	   	   	   	   	   	   
	     ObjectDelete(0,"SL100");	   	   	   	   	   	   	   
	     ObjectDelete(0,"HorUpAk100");	   	   	   	   	   	   
	     ObjectDelete(0,"HorUpAw100");	   	   	   	   	   	   	   	   	   	   	   
	     ObjectDelete(0,"BD_0");
	     ObjectDelete(0,"CD_0");
	     ObjectDelete(0,"X");
	     ObjectDelete(0,"A");	   	   	   
	     ObjectDelete(0,"B");	   	   	   
	     ObjectDelete(0,"C");	   	   	   
	     ObjectDelete(0,"D");	   	   	   	   	   	   
	     ObjectDelete(0,"DX_0");	   	   	   	   	   	   
	     ObjectDelete(0,"AC_0");	   	   	   	   	   	   
	     ObjectDelete(0,"XB_0");	   	   	   	   	   	   
	     ObjectDelete(0,"A_0");	   	   	   	   	   	   
	     ObjectDelete(0,"B_0");	   	   	   	   	   	   	   
	     ObjectDelete(0,"C_0");	   	   	   	   	   	   
	     ObjectDelete(0,"D_0");	   	   	   	   	   	   	   	   	   	   	   	   
	     ObjectDelete(0,"rCDXA_0");	   	   	   	   	   	   
	     ObjectDelete(0,"rCDBC_0");	   	   	   	   	   	   
	     ObjectDelete(0,"rBCAB_0");	   	   	   	   	   	   
	     ObjectDelete(0,"rABXA_0");	   	   	   	   	   	   
	     ObjectDelete(0,"BC_0");	   	   	   	   	   	   	   
	     ObjectDelete(0,"X_0");	   	   	   	   	   	   
	     ObjectDelete(0,"AB_0");	   	   	   	   	   	   	   	   	   	   	   	   	   
        ObjectDelete(0,"AB_0");	   	   	   	   	   	 
        ObjectDelete(0,"XA_0");	   	   	   	   	   	     	   	   	   	   	   	   	   	   
        ObjectDelete(0,"COLOR");
        ObjectDelete(0,"txtCOLOR");        
        ObjectDelete(0,"XABC");
        ObjectDelete(0,"txtXABC");        
        ObjectDelete(0,"RESET");
        ObjectDelete(0,"txtRESET");        
        ObjectDelete(0,"AUTO");
        ObjectDelete(0,"txtAUTO");                                
        return;
}

void XABC()
{
      if (ObjectGet("C",1)>ObjectGet("B",1))
       {
         int kk=0,jj=0,bb=0,aa=0;datetime ll=Time[0];double mm=0.0;
         aa=iBarShift(NULL,0,ObjectGetInteger(0,"D",OBJPROP_TIME,0),false);
         if (aa<0) {aa=0;}         
         kk=iBarShift(NULL,0,ObjectGetInteger(0,"B",OBJPROP_TIME,0),false);
         jj=iHighest(NULL,0,MODE_HIGH,kk-aa,aa);
         ObjectSet("C",0,iTime(NULL,0,jj));
         ObjectSet("C",1,iHigh(NULL,0,jj)+0.0015); 
         kk=iBarShift(NULL,0,ObjectGetInteger(0,"A",OBJPROP_TIME,0),false);
         bb=iLowest(NULL,0,MODE_LOW,kk-jj,jj);
         ObjectSet("B",0,iTime(NULL,0,bb));
         ObjectSet("B",1,iLow(NULL,0,bb)-0.0001);          
         kk=iBarShift(NULL,0,ObjectGetInteger(0,"X",OBJPROP_TIME,0),false);
         jj=iHighest(NULL,0,MODE_HIGH,kk-bb,bb);
         ObjectSet("A",0,iTime(NULL,0,jj));
         ObjectSet("A",1,iHigh(NULL,0,jj)+0.0015);
         bb=iLowest(NULL,0,MODE_LOW,kk+5-jj,jj);
         ObjectSet("X",0,iTime(NULL,0,bb));
         ObjectSet("X",1,iLow(NULL,0,bb)-0.0001);                                      
       }
       
      if (ObjectGet("C",1)<ObjectGet("B",1))
       {
         int kk=0,jj=0,bb=0,aa=0;datetime ll=Time[0];double mm=0.0;
         aa=iBarShift(NULL,0,ObjectGetInteger(0,"D",OBJPROP_TIME,0),false);
         if (aa<0) {aa=0;}
         kk=iBarShift(NULL,0,ObjectGetInteger(0,"B",OBJPROP_TIME,0),false);
         jj=iLowest(NULL,0,MODE_LOW,kk-aa,aa);
         ObjectSet("C",0,iTime(NULL,0,jj));
         ObjectSet("C",1,iLow(NULL,0,jj)-0.0001); 
         kk=iBarShift(NULL,0,ObjectGetInteger(0,"A",OBJPROP_TIME,0),false);
         bb=iHighest(NULL,0,MODE_HIGH,kk-jj,jj);
         ObjectSet("B",0,iTime(NULL,0,bb));
         ObjectSet("B",1,iHigh(NULL,0,bb)+0.0015);          
         kk=iBarShift(NULL,0,ObjectGetInteger(0,"X",OBJPROP_TIME,0),false);
         jj=iLowest(NULL,0,MODE_LOW,kk-bb,bb);
         ObjectSet("A",0,iTime(NULL,0,jj));
         ObjectSet("A",1,iLow(NULL,0,jj)-0.0001);
         bb=iHighest(NULL,0,MODE_HIGH,kk+5-jj,jj);
         ObjectSet("X",0,iTime(NULL,0,bb));
         ObjectSet("X",1,iHigh(NULL,0,bb)+0.0015);                                      
       }       
       return;
}

void titik(int tfr)
{
  int i,j,pos,hitup,hitdn;
  double val1,val2;
  i=Bars;
  j=0;
  pos=0;hitup=0;hitdn=0;
  val1=0;val2=0;
  while (j<i)
   {
      up[hitup]=0.0;
      dn[hitdn]=0.0;
      
      val1 = iFractals(NULL, tfr, MODE_UPPER,j);
      val2 = iFractals(NULL, tfr, MODE_LOWER,j);
      if ((val1>0) && (pos==0))
       {
         up[hitup]=val1;
         posup[hitup]=j;
         pos=2;
         hitup++;
       }
       
      if ((val2>0) && (pos==0))
       {
         dn[hitdn]=val2;
         posdn[hitdn]=j;
         pos=1;
         hitdn++;
       }      
       
      if ((val1>0) && (pos==1))
       {
         up[hitup]=val1;
         posup[hitup]=j;
         pos=2;
         hitup++;
       }
       
      if ((val2>0) && (pos==2))
       {
         dn[hitdn]=val2;
         posdn[hitdn]=j;
         pos=1;
         hitdn++;
       }              
        if ((hitdn>=3)&&(hitup>=3))
         {
          return;
         }
         j++;
   }

}

void support()
 {
   int i;
   double val1,val2,v1[201],v2[201];
   ArrayInitialize(v1,0.0);
   ArrayInitialize(v2,0.0);
   i=199;
   while(i>=0)
     {
   val1=0;val2=0;
val1 = iFractals(NULL, 0, MODE_UPPER,i);
 if (val1 > 0) 
  {
   v1[i]=High[i];
   ObjectDelete(0,"RES"+IntegerToString(i));
   ObjectCreate(0,"RES"+IntegerToString(i),OBJ_ARROW,0,Time[i],v1[i]);
   ObjectSet("RES"+IntegerToString(i),6,clrRed);
   ObjectSet("RES"+IntegerToString(i),14,119);
   ObjectSet("RES"+IntegerToString(i),203,1);
  } 
    else
     {
      v1[i] = v1[i+1];
      if (v1[i]>0)
       {
         ObjectDelete(0,"RES"+IntegerToString(i));
         ObjectCreate(0,"RES"+IntegerToString(i),OBJ_ARROW,0,Time[i],v1[i]);       
         ObjectSet("RES"+IntegerToString(i),6,clrRed);
         ObjectSet("RES"+IntegerToString(i),14,119);
         ObjectSet("RES"+IntegerToString(i),203,1);
       }
     } 
val2 = iFractals(NULL, 0, MODE_LOWER,i);
 if (val2 > 0) 
  {
   v2[i]=Low[i];
   ObjectDelete(0,"SUP"+IntegerToString(i));
   ObjectCreate(0,"SUP"+IntegerToString(i),OBJ_ARROW,0,Time[i],v2[i]);   
   ObjectSet("SUP"+IntegerToString(i),6,clrYellow);
   ObjectSet("SUP"+IntegerToString(i),14,119);
   ObjectSet("SUP"+IntegerToString(i),203,1);
  } 
      else
      {
      v2[i] = v2[i+1];
      if (v2[i]>0)
       {
         ObjectDelete(0,"SUP"+IntegerToString(i));
         ObjectCreate(0,"SUP"+IntegerToString(i),OBJ_ARROW,0,Time[i],v2[i]);       
         ObjectSet("SUP"+IntegerToString(i),6,clrYellow);
         ObjectSet("SUP"+IntegerToString(i),14,119);
         ObjectSet("SUP"+IntegerToString(i),203,1);
       }
      }
      i--;
     }
     

    return;     
 }