//+------------------------------------------------------------------+
//|                                              EI_MADifference.mq4 |
//|                                             Copyright 2014, eita |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, eita"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

//--- plot difference
#property indicator_label1  "wait"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Yellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  OrangeRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  RoyalBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2

//--- indicator buffers
double         differenceRateWaitBuffer[];
double         differenceRateUpBuffer[];
double         differenceRateDownBuffer[];

string objectName_UpLowerLimit = "obj_madiff_up_lower_limit";
string objectName_UpUpperLimit = "obj_madiff_up_upper_limit";
string objectName_DownLowerLimit = "obj_madiff_down_lower_limit";
string objectName_DownUpperLimit = "obj_madiff_down_upper_limit";
string objectName_Display = "obj_madiff_display";

//--- import function
#include <EA_MADiff.mqh>

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   SetIndexBuffer(0,differenceRateWaitBuffer);
   SetIndexBuffer(1,differenceRateUpBuffer);
   SetIndexBuffer(2,differenceRateDownBuffer);

//---
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   ObjectsDeleteAll(WindowOnDropped());
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   // set object
   createLimitLine();

   // draw chart line
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;

   for( int i=0; i<(limit-1); i++ ) {
   
      double curDiffRate = EA_getMADiffRate( 0, i );
      double preDiffRate = EA_getMADiffRate( 0, (i+1) );
      int trend = EA_judgeTrendOfMADiff( curDiffRate );

      setLineBuffer( trend, curDiffRate, i );
      setLineBuffer( trend, preDiffRate, (i+1) );
   }

   // draw display text
   drawDisplayText();

//--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Event function                                                   |
//+------------------------------------------------------------------+
void OnChartEvent( const int id,
                   const long& lparam,
                   const double& dparama,
                   const string& sparam )
{
   if ( id == 1 ) {
      ObjectSet( objectName_UpLowerLimit, OBJPROP_PRICE1, prm_MADiff_UP_LowerLimit );
      ObjectSet( objectName_UpUpperLimit, OBJPROP_PRICE1, prm_MADiff_UP_UpperLimit );
      ObjectSet( objectName_DownLowerLimit, OBJPROP_PRICE1, prm_MADiff_Down_LowerLimit );
      ObjectSet( objectName_DownUpperLimit, OBJPROP_PRICE1, prm_MADiff_Down_UpperLimit );
   }
}

//+------------------------------------------------------------------+
//| Create line object                                               |
//+------------------------------------------------------------------+
void createLimitLine()
{
   if ( ObjectFind(objectName_UpLowerLimit) < 0 ) {
      ObjectCreate(objectName_UpLowerLimit, OBJ_HLINE, WindowOnDropped(), 0, prm_MADiff_UP_LowerLimit );
      ObjectSet(objectName_UpLowerLimit, OBJPROP_COLOR, LightPink);
   }
   
   if ( ObjectFind(objectName_UpUpperLimit) < 0 ) {   
      ObjectCreate(objectName_UpUpperLimit, OBJ_HLINE, WindowOnDropped(), 0, prm_MADiff_UP_UpperLimit );
      ObjectSet(objectName_UpUpperLimit, OBJPROP_COLOR, OrangeRed);
   }
   
   if ( ObjectFind(objectName_DownLowerLimit) < 0 ) {  
      ObjectCreate(objectName_DownLowerLimit, OBJ_HLINE, WindowOnDropped(), 0,prm_MADiff_Down_LowerLimit  );
      ObjectSet(objectName_DownLowerLimit, OBJPROP_COLOR, LightSkyBlue);
   }

   if ( ObjectFind(objectName_DownUpperLimit) < 0 ) { 
      ObjectCreate(objectName_DownUpperLimit, OBJ_HLINE, WindowOnDropped(), 0, prm_MADiff_Down_UpperLimit );
      ObjectSet(objectName_DownUpperLimit, OBJPROP_COLOR, RoyalBlue);
   }
}

//+------------------------------------------------------------------+
//| Create display object                                               |
//+------------------------------------------------------------------+
void drawDisplayText()
{
   const string strMALabel[] = { "SMA", "EMA", "SMMA", "LWMA" };

   if ( ObjectFind(objectName_Display) < 0 ) {
      ObjectCreate(objectName_Display, OBJ_LABEL, WindowOnDropped(), 0, 0);
   }

   double diffRate = EA_getMADiffRate( 0, 0 );
   string str = DoubleToStr( diffRate, 4 ) + " (" + DoubleToStr(prm_MADiff_Period,0) + strMALabel[prm_MADiff_MAMethod] + ")";
   color textColor = clrWhite;   
   if ( diffRate >= 0.0 ) {
      textColor = LightPink;   
   }
   else {
      textColor = LightSkyBlue;   
   }

   ObjectSetText(objectName_Display, str, 12, NULL, textColor);
   ObjectSet(objectName_Display, OBJPROP_XDISTANCE, 5);
	ObjectSet(objectName_Display, OBJPROP_YDISTANCE, 2);
	ObjectSet(objectName_Display, OBJPROP_CORNER, 1);
}

//+------------------------------------------------------------------+
//| set line buffer                                                  |
//+------------------------------------------------------------------+
void setLineBuffer( int trend, double rate, int shift )
{
   // Overflow check
   if ( (ArraySize(differenceRateWaitBuffer)-1) < shift  ) {
      return;
   }

   // Set value to buffer
   switch ( trend )
   {
      case EA_TREND_UP:
         differenceRateWaitBuffer[shift] = rate;
         differenceRateUpBuffer[shift] = rate;
         differenceRateDownBuffer[shift] = EMPTY_VALUE;
         break;
      case EA_TREND_DOWN:
         differenceRateWaitBuffer[shift] = rate;
         differenceRateUpBuffer[shift] = EMPTY_VALUE;
         differenceRateDownBuffer[shift] = rate;
         break;
      default:
         differenceRateWaitBuffer[shift] = rate;
         differenceRateUpBuffer[shift] = EMPTY_VALUE;
         differenceRateDownBuffer[shift] = EMPTY_VALUE;
         break;
   }
}

//+------------------------------------------------------------------+
