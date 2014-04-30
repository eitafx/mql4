//+------------------------------------------------------------------+
//|                                                    EA_MAvsMA.mqh |
//|                                             Copyright 2014, eita |
//|                                                        Ver:1.01  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, eita"
#property link      ""
#property strict

#include "EA_stdval.mqh"

//+------------------------------------------------------------------+
//| input parameters                                                 |
//+------------------------------------------------------------------+
input int prm_CurrentMAPeriod = 5;
input int prm_BaseMAPeriod = 6;
input string Description_about_method = "0:SMA 1:EMA 2:SMMA 3:LWMA";
input int prm_MAMethod = 0;
input double prm_UP_LowerLimit = 0.001;
input double prm_UP_UpperLimit = 0.01;
input double prm_Down_LowerLimit = -0.001;
input double prm_Down_UpperLimit = -0.01;

//+------------------------------------------------------------------+
//| Get the trend of MAvsMA                                          |
//+------------------------------------------------------------------+
int EA_getTrendOfMAvsMA( int timeframe, int shift=0 )
{
   int trend = EA_TREND_STAY;
   
   double currentMA = iMA( NULL, timeframe, prm_CurrentMAPeriod, 0, prm_MAMethod, PRICE_CLOSE, shift );
   double baceMA    = iMA( NULL, timeframe, prm_BaseMAPeriod,    0, prm_MAMethod, PRICE_CLOSE, shift );
   
   if ( baceMA > 0.0 ) {
      double diffRate = ((currentMA - baceMA) / baceMA) * 100.0;
      trend = judgeTrendOfMAvsMA( diffRate );
   }
   else {
      trend = EA_TREND_STAY;
   }

   return trend; 
}

//+------------------------------------------------------------------+
//| Judge trend                                                      |
//+------------------------------------------------------------------+
int judgeTrendOfMAvsMA( double diffRate )
{
   int result = EA_TREND_STAY;

   if ( (diffRate < prm_UP_LowerLimit) && (diffRate > prm_Down_LowerLimit) ) {  // lower limit check
      result = EA_TREND_STAY;
   }
   else {
      if ( (diffRate >= prm_UP_LowerLimit) && (diffRate <= prm_UP_UpperLimit) ) { // up trend check
         result = EA_TREND_UP;         
      }
      else if ( (diffRate <= prm_Down_LowerLimit) && (diffRate >= prm_Down_UpperLimit) ) {   // down trend check
         result = EA_TREND_DOWN;
      }
      else {   // wait trend check
         result = EA_TREND_STAY;
      }
   }
   
   return result;
}


//+------------------------------------------------------------------+
