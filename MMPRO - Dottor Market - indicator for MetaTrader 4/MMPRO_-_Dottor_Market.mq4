//+------------------------------------------------------------------+
//|                                        MMPRO - Dottor Market.mq4 |
//|                                                         D.Market |
//|                                          www.tradersitaliani.com |
//+------------------------------------------------------------------+
#property copyright "D.Market"
#property link      "www.tradersitaliani.com"

#property indicator_chart_window

extern int Stop_Loss = 50;
extern double Risk_for_Trade = 1.5;
extern int caratteri = 8;
extern string Nota = "Settaggio_Grafico";
extern color colore = DarkBlue;
extern color colore2 = Red;
extern int angolo = 1;
extern int Altezza = 10;
extern int Scostamento = 0;
extern string Nota_Angolo = "1= AltoDX   2= BassoSX";
extern string Nota_Angolo2 = "3= BassoDX   4= AltoSX";
extern string Non_Lo_Visualizzo = "Usate Altezza e Scostamento!";
double size = 0;
double Risk_for_trade = 0;
double Loss = 0;
double P_L = 0;
int intero  = 0;
int decimale = 0;
int centesimale =0;
string symbol;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   symbol = Symbol();
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("MMPRO1");
   ObjectDelete("Stop1");
   ObjectDelete("Risk1");
   ObjectDelete("Loss1");
   ObjectDelete("P_L1");
   ObjectDelete("Horizzontal Line6");
   ObjectDelete("Horizzontal Line5");
   ObjectDelete("Title");
   ObjectDelete("Link");
   ObjectDelete("HL");
   ObjectDelete("HL2");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  
   // Titolo
   ObjectCreate("Title", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Title","MMPRO - Dottor Market", caratteri+2, "Verdana", colore);
   ObjectSet("Title", OBJPROP_CORNER, angolo);
   ObjectSet("Title", OBJPROP_XDISTANCE, (3+Scostamento));
   ObjectSet("Title", OBJPROP_YDISTANCE, (41+Altezza));
     
   //Line Up
   ObjectCreate("Horizzontal Line5", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Horizzontal Line5","------------------------", caratteri, "Verdana", colore2);
   ObjectSet("Horizzontal Line5", OBJPROP_CORNER, angolo);
   ObjectSet("Horizzontal Line5", OBJPROP_XDISTANCE, (3+Scostamento));
   ObjectSet("Horizzontal Line5", OBJPROP_YDISTANCE, (50+Altezza));
   
   // SIZE
   size = (((AccountEquity()/100)*Risk_for_Trade)/Stop_Loss)/NormalizeDouble(MarketInfo(symbol,MODE_TICKVALUE),2);
   size = NormalizeDouble(size,2);
   intero = MathFloor(size);
   decimale = (size-intero)*100;
   ObjectCreate("MMPRO1", OBJ_LABEL, 0, 0, 0);
   if(size>=0) ObjectSetText("MMPRO1","SIZE: "+ intero+"."+intero+decimale+" lotti", caratteri+2, "Verdana", colore2);
   if(size>=1) ObjectSetText("MMPRO1","SIZE: "+ intero+"."+intero+decimale/10+" lotti", caratteri+2, "Verdana", colore2);
   if(size>0.09)ObjectSetText("MMPRO1","SIZE: "+ intero+"."+decimale+" lotti", caratteri+2, "Verdana", colore2);
   if(decimale <=9)ObjectSetText("MMPRO1","SIZE: "+ intero+"."+"0"+decimale+" lotti", caratteri+2, "Verdana", colore2);
   ObjectSet("MMPRO1", OBJPROP_CORNER, angolo);
   ObjectSet("MMPRO1", OBJPROP_XDISTANCE, (3+Scostamento));
   ObjectSet("MMPRO1", OBJPROP_YDISTANCE, (56+Altezza));
   
   //Line Down
   ObjectCreate("Horizzontal Line6", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Horizzontal Line6","------------------------", caratteri, "Verdana", colore2);
   ObjectSet("Horizzontal Line6", OBJPROP_CORNER, angolo);
   ObjectSet("Horizzontal Line6", OBJPROP_XDISTANCE, (3+Scostamento));
   ObjectSet("Horizzontal Line6", OBJPROP_YDISTANCE, (66+Altezza));
   
   // SL
   Stop_Loss = Stop_Loss;
   ObjectCreate("Stop1", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Stop1","SL: "+ Stop_Loss + " pips", caratteri, "Verdana", colore);
   ObjectSet("Stop1", OBJPROP_CORNER, angolo);
   ObjectSet("Stop1", OBJPROP_XDISTANCE, (3+Scostamento));
   ObjectSet("Stop1", OBJPROP_YDISTANCE, (73+Altezza));
   
   // RISK
   Risk_for_Trade = NormalizeDouble(Risk_for_Trade,2);
   intero = MathFloor (Risk_for_Trade);
   decimale = (Risk_for_Trade - intero)*100;
   ObjectCreate("Risk1", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Risk1","RISK: "+ intero +"."+decimale+ " %", caratteri, "Verdana", colore);
   ObjectSet("Risk1", OBJPROP_CORNER, angolo);
   ObjectSet("Risk1", OBJPROP_XDISTANCE, (3+Scostamento));
   ObjectSet("Risk1", OBJPROP_YDISTANCE, (83+Altezza));
   
   //LOSS
   Loss = NormalizeDouble(size,2)*NormalizeDouble(MarketInfo(symbol,MODE_TICKVALUE),2)* Stop_Loss;
   intero = MathFloor (Loss);
   decimale = (Loss - intero)*100;
   ObjectCreate("Loss1", OBJ_LABEL, 0, 0, 0);
   if (decimale >9) ObjectSetText("Loss1","LOSS: "+intero+"."+decimale+" €uro", caratteri, "Verdana", colore);
   if (decimale <=9) ObjectSetText("Loss1","LOSS: "+intero+"."+"0"+decimale+" €uro", caratteri, "Verdana", colore);
   ObjectSet("Loss1", OBJPROP_CORNER, angolo);
   ObjectSet("Loss1", OBJPROP_XDISTANCE, (3+Scostamento));
   ObjectSet("Loss1", OBJPROP_YDISTANCE, (92+Altezza));
   
   //Profit/Loss per PIP
   P_L= NormalizeDouble(size,2)*NormalizeDouble(MarketInfo(symbol,MODE_TICKVALUE),2);
   intero = MathFloor (P_L);
   decimale = (P_L - intero)*100;
   ObjectCreate("P_L1", OBJ_LABEL, 0, 0, 0);
   if (size <= 0.01) ObjectSetText("P_L1","P&L: €"+intero+"."+intero+decimale+" pip", caratteri, "Verdana", colore);
   if (size > 0.01) ObjectSetText("P_L1","P&L: €"+intero+"."+decimale+" pip", caratteri, "Verdana", colore);
   if (decimale <=9)ObjectSetText("P_L1","P&L: €"+intero+"."+"0"+decimale+" pip", caratteri, "Verdana", colore);
   ObjectSet("P_L1", OBJPROP_CORNER, angolo);
   ObjectSet("P_L1", OBJPROP_XDISTANCE, (3+Scostamento));
   ObjectSet("P_L1", OBJPROP_YDISTANCE, (101+Altezza));
   
   // Link
   ObjectCreate("Link", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Link","www.tradersitaliani.com", caratteri+2, "Verdana", colore);
   ObjectSet("Link", OBJPROP_CORNER, angolo);
   ObjectSet("Link", OBJPROP_XDISTANCE, (3+Scostamento));
   ObjectSet("Link", OBJPROP_YDISTANCE, (115+Altezza));
   
   // Horizzontal end
   ObjectCreate("HL", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("HL","--------------------------------", caratteri, "Verdana", colore);
   ObjectSet("HL", OBJPROP_CORNER, angolo);
   ObjectSet("HL", OBJPROP_XDISTANCE, (3+Scostamento));
   ObjectSet("HL", OBJPROP_YDISTANCE, (110+Altezza));
   
   // Horizzontal end 2
   ObjectCreate("HL2", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("HL2","--------------------------------", caratteri, "Verdana", colore);
   ObjectSet("HL2", OBJPROP_CORNER, angolo);
   ObjectSet("HL2", OBJPROP_XDISTANCE, (3+Scostamento));
   ObjectSet("HL2", OBJPROP_YDISTANCE, (125+Altezza));
   
   
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+