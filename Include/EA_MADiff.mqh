//+------------------------------------------------------------------+
//|                                                    EA_MADiff.mqh |
//|                                             Copyright 2014, eita |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, eita"
#property link      ""
#property strict

#include "EA_stdval.mqh"

//+------------------------------------------------------------------+
//| input parameters                                                 |
//+------------------------------------------------------------------+
input int prm_MADiff_Period = 20;
input string MADiff_Description_about_method = "0:SMA 1:EMA 2:SMMA 3:LWMA";
input int prm_MADiff_MAMethod = 0;
input double prm_MADiff_UP_LowerLimit = 0.01;
input double prm_MADiff_UP_UpperLimit = 0.075;
input double prm_MADiff_Down_LowerLimit = -0.01;
input double prm_MADiff_Down_UpperLimit = -0.075;

//+------------------------------------------------------------------+
//| Get the trend of MAvsMA                                          |
//+------------------------------------------------------------------+
double EA_getMADiffRate( int timeframe, int shift=0 )
{   
   double currentValue = iClose( NULL, timeframe, shift );
   double maValue = iMA( NULL, timeframe, prm_MADiff_Period, 0, prm_MADiff_MAMethod, PRICE_CLOSE, shift );

   double diffRate = 0.0;
   if ( maValue > 0.0 ) {
      diffRate = ((currentValue - maValue) / maValue) * 100.0;
   }
   else {
      diffRate = 0.0;
   }

   return diffRate; 
}

//+------------------------------------------------------------------+
//| Judge trend                                                      |
//+------------------------------------------------------------------+
int EA_judgeTrendOfMADiff( double diffRate )
{
   int result = EA_TREND_STAY;

   if ( (diffRate < prm_MADiff_UP_LowerLimit) && (diffRate > prm_MADiff_Down_LowerLimit) ) {  // lower limit check
      result = EA_TREND_STAY;
   }
   else {
      if ( (diffRate >= prm_MADiff_UP_LowerLimit) && (diffRate <= prm_MADiff_UP_UpperLimit) ) { // up trend check
         result = EA_TREND_UP;         
      }
      else if ( (diffRate <= prm_MADiff_Down_LowerLimit) && (diffRate >= prm_MADiff_Down_UpperLimit) ) {   // down trend check
         result = EA_TREND_DOWN;
      }
      else {   // wait trend check
         result = EA_TREND_STAY;
      }
   }
   
   return result;
}

//+------------------------------------------------------------------+
