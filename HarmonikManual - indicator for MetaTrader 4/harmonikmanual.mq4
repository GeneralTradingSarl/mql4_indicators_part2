//+------------------------------------------------------------------+
//|                                               HarmonikManual.mq4 |
//|                                                            Kabul |
//|                                               panji_xx@yahoo.com |
//+------------------------------------------------------------------+
//#property copyright "Kabul"
//#property link      "panji_xx@yahoo.com"
//#property version   "1.00"
//#property strict
//#property indicator_chart_window
//+------------------------------------------------------------------+
//|                                              Harmonic Ratios.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "all traders"
#property link      "www.forexfactory.com"

#define	OBJNAME_LABEL	"Harmonic Rasio"

#property indicator_chart_window

extern bool Active = True;
extern int Harmonic_Pattern_No= 0;
input string InpFileName="harmontrad.csv";    // file name
//input string InpDirectoryName="Data";   // directory name
input int    InpEncodingType=FILE_ANSI; 
string hasil;
        datetime D_tm,C_tm,B_tm,A_tm,X_tm;
        double   D_pr,C_pr,B_pr,A_pr,X_pr;
double  awal,akhir,res1,res2,resak;


int init() {
	createIndicatorLabel(OBJNAME_LABEL);
        D_tm=Time[0]; C_tm=Time[0];B_tm=Time[0];A_tm=Time[0];X_tm=Time[0];
        D_pr=0.0; C_pr=0.0; B_pr=0.0; A_pr=0.0; X_pr=0.0;	
        awal=0.0;akhir=0.0;
        resak=3.0;res1=0.0;res2=0.0;
	return(0);
}

int deinit() {
	ObjectDelete(OBJNAME_LABEL);
	return(0);
}

//+------------------------------------------------------------------+
//|start function                                                    |
//+------------------------------------------------------------------+
int start()
  {

  // Pencarian otomatis
 if (ObjectFind("ON")<0) 
     { 
       if (ObjectGet("D",1)>ObjectGet("C",1)) {resak=3.0;}
       if (ObjectGet("D",1)<ObjectGet("C",1)) {resak=0.0;}
       res1=0.0;res2=0.0;awal=0.0;
     }
 else {
       int hit=StringToInteger(ObjectGetString(0,"ON",OBJPROP_TEXT));
       ObjectDelete("Posisi");
       double harga_D,harga_C;
       datetime waktu_D;
       harga_D = ObjectGet("D",1);
       harga_C = ObjectGet("C",1);
       waktu_D = ObjectGet("D",0);

         string nama1;
         nama1=ObjectGetString(0,"ketemu",OBJPROP_TEXT);
         if ((StringSubstr(nama1,0,5)!="tidak") && (awal==0.0))
         {
           awal=ObjectGet("D",1);
           if ((harga_D>harga_C) && (waktu_D>iTime(NULL,0,0)))
            {
              ObjectSet("D",1,harga_D+0.0005);
              Sleep(500);
            }
            
           if ((harga_D<harga_C) && (waktu_D>iTime(NULL,0,0)))
            {
              ObjectSet("D",1,harga_D-0.0005);
              Sleep(400);
            }                    
         }
         if ((StringSubstr(nama1,0,5)=="tidak") && (awal>0.0))
         {
             akhir=ObjectGet("D",1);
             SetText("Posisi","Awal = "+DoubleToString(awal,4)+" Akhir = "+DoubleToString(akhir,4),25,75,clrRed,18);
             ObjectDelete("SL"+IntegerToString(hit));
             ObjectCreate("SL"+IntegerToString(hit),OBJ_RECTANGLE,0,waktu_D,awal,waktu_D+(4*Period()*60),akhir);
             ObjectSet("SL"+IntegerToString(hit),OBJPROP_COLOR,clrRed);
             ObjectDelete("Hor"+IntegerToString(hit));
             ObjectCreate("Hor"+IntegerToString(hit),OBJ_HLINE,0,0,awal);
             ObjectSet("Hor"+IntegerToString(hit),OBJPROP_COLOR,clrWhite);
             ObjectDelete("Hor1"+IntegerToString(hit));                          
             ObjectCreate("Hor1"+IntegerToString(hit),OBJ_HLINE,0,0,akhir);
             ObjectSet("Hor1"+IntegerToString(hit),OBJPROP_COLOR,clrWhite); 
             awal=0;            
             hit --;
             ObjectSetText("ON",IntegerToString(hit));
             if (hit==0)
             ObjectDelete("ON");             
         }
        
        if ((harga_D>harga_C) && (waktu_D>iTime(NULL,0,0)))
         {
           ObjectSet("D",1,harga_D+0.0001);
           Sleep(500);
         }
         
        if ((harga_D<harga_C) && (waktu_D>iTime(NULL,0,0)))
         {
           ObjectSet("D",1,harga_D-0.0001);
           Sleep(400);
         }         

      }  
  
  // end pencarian otomatis     


  //coba
  double   top=WindowPriceMax();
  double   bottom=WindowPriceMin();
  datetime left=Time[WindowFirstVisibleBar()];
  int      right_bound=WindowFirstVisibleBar()-WindowBarsPerChart();
  if(right_bound<0) right_bound=0;
  datetime right=Time[right_bound]+Period()*60;
//----

  // end coba
  
  // Bikin XABCDE, dan trend linenya
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
     
     if(ObjectFind("E")>=0) {X_tm=Time[0];return(0);}  
     else
      {
        
        
        X_tm=Time[0];
        
        for (int jjj=0;jjj<1200;jjj++)
         {
           if ((iTime(NULL,0,jjj)==ObjectGet("D",0)) && (ObjectGet("D",1)>=iLow(NULL,0,jjj)))
             {
               D_tm=iTime(NULL,0,jjj);
               D_pr=iHigh(NULL,0,jjj);
             }
             
           if ((iTime(NULL,0,jjj)==ObjectGet("D",0)) && (ObjectGet("D",1)<=iHigh(NULL,0,jjj)))
             {
               D_tm=iTime(NULL,0,jjj);
               D_pr=iLow(NULL,0,jjj);
             }
           if (ObjectGet("D",0)>Time[0])
             {
               D_tm=ObjectGet("D",0);
               D_pr=ObjectGet("D",1);              
             } 
             
           if ((iTime(NULL,0,jjj)==ObjectGet("C",0)) && (ObjectGet("C",1)<=iHigh(NULL,0,jjj)))
             {
               C_tm=iTime(NULL,0,jjj);
               C_pr=iLow(NULL,0,jjj);
             }
             
           if ((iTime(NULL,0,jjj)==ObjectGet("C",0)) && (ObjectGet("C",1)>=iLow(NULL,0,jjj)))
             {
               C_tm=iTime(NULL,0,jjj);
               C_pr=iHigh(NULL,0,jjj);
             }             
             
           if ((iTime(NULL,0,jjj)==ObjectGet("B",0)) && (ObjectGet("B",1)<=iHigh(NULL,0,jjj)))
             {
               B_tm=iTime(NULL,0,jjj);
               B_pr=iLow(NULL,0,jjj);
             }
             
           if ((iTime(NULL,0,jjj)==ObjectGet("B",0)) && (ObjectGet("B",1)>=iLow(NULL,0,jjj)))
             {
               B_tm=iTime(NULL,0,jjj);
               B_pr=iHigh(NULL,0,jjj);
             }             

           if ((iTime(NULL,0,jjj)==ObjectGet("A",0)) && (ObjectGet("A",1)<=iHigh(NULL,0,jjj)))
             {
               A_tm=iTime(NULL,0,jjj);
               A_pr=iLow(NULL,0,jjj);
             }
             
           if ((iTime(NULL,0,jjj)==ObjectGet("A",0)) && (ObjectGet("A",1)>=iLow(NULL,0,jjj)))
             {
               A_tm=iTime(NULL,0,jjj);
               A_pr=iHigh(NULL,0,jjj);
             }             
           
           if ((iTime(NULL,0,jjj)==ObjectGet("X",0)) && (ObjectGet("X",1)<=iHigh(NULL,0,jjj)))
             {
               X_tm=iTime(NULL,0,jjj);
               X_pr=iLow(NULL,0,jjj);
             }
             
           if ((iTime(NULL,0,jjj)==ObjectGet("X",0)) && (ObjectGet("X",1)>=iLow(NULL,0,jjj)))
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
  // End bikin XABCDE
  
  //Check if indicator is active
  if (Active==false)
  {
  ObjectSetText(OBJNAME_LABEL,"Harmonic Rasio: Off ",9,"Arial",White);
  return(0);
  }
  else
  ObjectSetText(OBJNAME_LABEL,"Harmonic Rasio: On ",9,"Arial",White);
  
  //Check if input is valid
  if (Harmonic_Pattern_No<0)
  {
  ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios- Error: Invalid Harmonic Pattern No.!",9,"Arial",White);
  return(0);
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
   return(0);
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
   return(0);
   }
   else if(ObjectGet(sAB,OBJPROP_PRICE2)!=ObjectGet(sBC,OBJPROP_PRICE1) || ObjectGet(sAB,OBJPROP_TIME2)!=ObjectGet(sBC,OBJPROP_TIME1))
   {
   ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios- Error: AB is not properly connected to BC!",9,"Arial",White);
   return(0);
   }
   else if(ObjectGet(sBC,OBJPROP_PRICE2)!=ObjectGet(sCD,OBJPROP_PRICE1) || ObjectGet(sBC,OBJPROP_TIME2)!=ObjectGet(sCD,OBJPROP_TIME1))
   {
   ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios- Error: BC is not properly connected to CD!",9,"Arial",White);
   return(0);
   }
   else if(ObjectGet(sXA,OBJPROP_TIME2)<ObjectGet(sXA,OBJPROP_TIME1))
   {
   ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios- Error: Vertex A must be to the right of X",9,"Arial",White);
   return(0);
   }
   else if(ObjectGet(sAB,OBJPROP_TIME2)<ObjectGet(sAB,OBJPROP_TIME1))
   {
   ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios- Error: Vertex B must be to the right of A",9,"Arial",White);
   return(0);
   }
   else if(ObjectGet(sBC,OBJPROP_TIME2)<ObjectGet(sBC,OBJPROP_TIME1))
   {
   ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios- Error: Vertex C must be to the right of B",9,"Arial",White);
   return(0);
   }
   else if(ObjectGet(sCD,OBJPROP_TIME2)<ObjectGet(sCD,OBJPROP_TIME1))
   {
   ObjectSetText(OBJNAME_LABEL,"Harmonic Ratios- Error: Vertex D must be to the right of C",9,"Arial",White);
   return(0);
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
   ObjectSet(StringConcatenate("DX_",Harmonic_Pattern_No), OBJPROP_COLOR, clrWhite);
   sDX = StringConcatenate("DX_",Harmonic_Pattern_No);
   }
   if (bAC==false)
   {
   ObjectCreate(StringConcatenate("AC_",Harmonic_Pattern_No), OBJ_TREND, 0, ObjectGet(sAB,OBJPROP_TIME1), ObjectGet(sAB,OBJPROP_PRICE1), ObjectGet(sBC,OBJPROP_TIME2), ObjectGet(sBC,OBJPROP_PRICE2));
   ObjectSet(StringConcatenate("AC_",Harmonic_Pattern_No), OBJPROP_STYLE, STYLE_DASH);
   ObjectSet(StringConcatenate("AC_",Harmonic_Pattern_No), OBJPROP_RAY, FALSE);
   ObjectSet(StringConcatenate("AC_",Harmonic_Pattern_No), OBJPROP_COLOR, clrWhite);
   sAC = StringConcatenate("AC_",Harmonic_Pattern_No);
   }
   if (bBD==false)
   {
   ObjectCreate(StringConcatenate("BD_",Harmonic_Pattern_No), OBJ_TREND, 0, ObjectGet(sBC,OBJPROP_TIME1), ObjectGet(sBC,OBJPROP_PRICE1), ObjectGet(sCD,OBJPROP_TIME2), ObjectGet(sCD,OBJPROP_PRICE2));
   ObjectSet(StringConcatenate("BD_",Harmonic_Pattern_No), OBJPROP_STYLE, STYLE_DASH);
   ObjectSet(StringConcatenate("BD_",Harmonic_Pattern_No), OBJPROP_RAY, FALSE);
   ObjectSet(StringConcatenate("BD_",Harmonic_Pattern_No), OBJPROP_COLOR, clrWhite);
   sBD = StringConcatenate("BD_",Harmonic_Pattern_No);
   }
   if (bXB==false)
   {
   ObjectCreate(StringConcatenate("XB_",Harmonic_Pattern_No), OBJ_TREND, 0, ObjectGet(sXA,OBJPROP_TIME1), ObjectGet(sXA,OBJPROP_PRICE1), ObjectGet(sAB,OBJPROP_TIME2), ObjectGet(sAB,OBJPROP_PRICE2));
   ObjectSet(StringConcatenate("XB_",Harmonic_Pattern_No), OBJPROP_STYLE, STYLE_DASH);
   ObjectSet(StringConcatenate("XB_",Harmonic_Pattern_No), OBJPROP_RAY, FALSE);
   ObjectSet(StringConcatenate("XB_",Harmonic_Pattern_No), OBJPROP_COLOR, clrWhite);
   sXB = StringConcatenate("XB_",Harmonic_Pattern_No);
   }
   
   //Calculate and label fibo ratios
   
   double rABXA,rBCAB,rCDBC,rCDXA;
   //double lXA,lAB,lBC,lCD,lXB,lAC,lXD,lBD;
   
   rABXA = lAB/lXA;
   rBCAB = lBC/lAB;
   rCDBC = lCD/lBC;
   rCDXA = (lAB+lBD)/lXA;

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
   //Hitung
   bool ketemu; ketemu=false;
   for (int jkk=1;jkk<84;jkk++)  
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
                    
          if ((rABXA>=StringToDouble(minXB_)) && (rABXA<=StringToDouble(maxXB_)) &&
             (rBCAB>=StringToDouble(minAC_)) && (rBCAB<=StringToDouble(maxAC_)) &&
             (rCDBC>=StringToDouble(minBD_)) && (rCDBC<=StringToDouble(maxBD_)) &&
             (rCDXA>=StringToDouble(minXD_)) && (rCDXA<=StringToDouble(maxXD_)))
           {
             ObjectDelete("nama");
             SetText("nama",nama,25,10,clrRed,24);
          
             ketemu=true;
             if ((ObjectGet("D",1)>ObjectGet("C",1))&&(awal>0))
             {
               hasmakD1=(makBD*lBC)+ObjectGet("C_0",OBJPROP_PRICE1);
               hasmakD2=(makXD*lXA)+ObjectGet("A_0",OBJPROP_PRICE1);
               if (hasmakD1>=hasmakD2) {hasmakD=hasmakD2;}
               else {hasmakD=hasmakD1;}
               if (ObjectGet("D",1)<hasmakD)
                   {ObjectSet("D",1,hasmakD);}
              }     

             if ((ObjectGet("D",1)<ObjectGet("C",1))&&(awal>0))
             {
               hasmakD1=ObjectGet("C_0",OBJPROP_PRICE1)-(makBD*lBC);
               hasmakD2=ObjectGet("A_0",OBJPROP_PRICE1)-(makXD*lXA);
               if (hasmakD1>=hasmakD2) {hasmakD=hasmakD1;}
               else {hasmakD=hasmakD2;}
               if (ObjectGet("D",1)>hasmakD)
                   {ObjectSet("D",1,hasmakD);}
              }     
              
              
             break;
           }  
           
           
          if ((rABXA>=StringToDouble(minXB_)) && (rABXA<=StringToDouble(maxXB_)) &&
             (rBCAB>=StringToDouble(minAC_)) && (rBCAB<=StringToDouble(maxAC_)))
             {
                 if (ObjectGet("D",1)>ObjectGet("C",1))          
                 {
                  hasmikD1=(mikBD*lBC)+ObjectGet("C_0",OBJPROP_PRICE1);
                  hasmikD2=(mikXD*lXA)-lAB+ObjectGet("B_0",OBJPROP_PRICE1);
                  hasmakD1=(makBD*lBC)+ObjectGet("C_0",OBJPROP_PRICE1);
                  hasmakD2=(makXD*lXA)-lAB+ObjectGet("B_0",OBJPROP_PRICE1);                  
                  if ((hasmikD1>=hasmikD2)&&(hasmikD1<=hasmakD2)) {res1=hasmikD1;}
                  if ((hasmikD2>=hasmikD1)&&(hasmikD2<=hasmakD1)) {res2=hasmikD2;}
                  if ((res1>0.0)&&(resak>res1)&&(res1>ObjectGet("D",1))) {resak=res1;}
                  if ((res2>0.0)&&(resak>res2)&&(res2>ObjectGet("D",1))) {resak=res2;}
                 }
                 
                 if (ObjectGet("D",1)<ObjectGet("C",1))          
                 {
                  hasmikD1=ObjectGet("C_0",OBJPROP_PRICE1)-(mikBD*lBC);
                  hasmikD2=ObjectGet("B_0",OBJPROP_PRICE1)-(mikXD*lXA-lAB);
                  hasmakD1=ObjectGet("C_0",OBJPROP_PRICE1)-(makBD*lBC);
                  hasmakD2=ObjectGet("B_0",OBJPROP_PRICE1)-(makXD*lXA-lAB);                  
                  if ((hasmikD1>=hasmakD2)&&(hasmikD1<=hasmikD2)) {res1=hasmikD1;}
                  if ((hasmikD2>=hasmakD1)&&(hasmikD2<=hasmikD1)) {res2=hasmikD2;}
                  if ((res1>0.0)&&(resak<res1)&&(res1<ObjectGet("D",1))) {resak=res1;}
                  if ((res2>0.0)&&(resak<res2)&&(res2<ObjectGet("D",1))) {resak=res2;}
                 }                       
             }
    } 
    if (ketemu==true) 
     {
             ObjectDelete("ketemu");
             SetText("ketemu","ada",250,25,clrRed,12);    
     }
    else
     {
             if ((ObjectFind("ON")>=0)&&(awal==0.0) )
              {
               if ((ObjectGet("D",1)<ObjectGet("C",1))&&(ObjectGet("D",1)>resak))
                {ObjectSet("D",1,resak);}              
                
               if ((ObjectGet("D",1)>ObjectGet("C",1))&&(ObjectGet("D",1)<resak))
               {ObjectSet("D",1,resak);}                              
              }
              
             double ab_cd;
             ab_cd=lCD/lAB;
             ObjectDelete("nama"); 
             SetText("nama",DoubleToString(ab_cd,3)+" AB=CD",25,10,clrRed,24);
             ObjectDelete("ketemu");
             SetText("ketemu","tidak ada",250,25,clrRed,12);    
     }  
     double XABCD[4],fibretr; ArrayFill(XABCD,0,4,0.0);
     int max,min;
                XABCD[0]=X_pr;XABCD[1]=A_pr;XABCD[2]=B_pr;XABCD[3]=C_pr;
                max=ArrayMaximum(XABCD);
                min=ArrayMinimum(XABCD);
                fibretr=(D_pr-XABCD[min])/(XABCD[max]-XABCD[min]);
                        
     ObjectDelete("Fib");
     SetText("Fib","Fibo Retrace = "+DoubleToString(fibretr,3),25,50,clrRed,18);
     
     ObjectDelete("Day");
     SetText("Day","Daily Range = "+DoubleToString((iHigh(NULL,1440,0)-iLow(NULL,1440,0))*10000,2),25,100,clrRed,18);     
     

     
   return(0);
  }
//+------------------------------------------------------------------+

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
  
string bacadata(int posisi)
{
//--- specify the value of the variable for generating random numbers
   _RandomSeed=GetTickCount();
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
      FileClose(file_handle);
      
      

     }
   else
      PrintFormat("Failed to open %s file, Error code = %d",InpFileName,GetLastError());
   return(hasil);
}

void SetText(string name,string text,int x,int y,color colour,int fontsize=12)
  {
   if(ObjectCreate(0,name,OBJ_LABEL,0,0,0))
     {
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
     }
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }