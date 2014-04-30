//+------------------------------------------------------------------+
//|                                                       EA_CCI.mqh |
//|                                             Copyright 2014, eita |
//|                                                        Ver:1.01  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, eita"
#property link      ""
#property strict

#include "EA_stdval.mqh"

input int      prm_EA_CCI_trend_period = 14;

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get the trend of CCI                                             |
//+------------------------------------------------------------------+
int EA_getTrendOfCCI( int timeframe, int shift=0 )
{
   int resTrend = EA_getTrendOfCCIwithDepth( timeframe, shift, 3 );
   
   return resTrend;
}

int EA_getTrendOfCCIwithDepth( int timeframe, int shift, int depth )
{
   int upTrend = EA_TREND_UP;
   int downTrend = EA_TREND_DOWN;
   
   int idx;
   int checkPos = shift;
   for ( idx=0; idx<(depth-1); idx++ ) {

      double curCCI =  iCCI( NULL, timeframe, prm_EA_CCI_trend_period, PRICE_CLOSE, checkPos );
      double preCCI =  iCCI( NULL, timeframe, prm_EA_CCI_trend_period, PRICE_CLOSE, (checkPos+1) );

      if ( (curCCI > preCCI) && (upTrend != EA_TREND_STAY) ) {
         upTrend = EA_TREND_UP;
      }
      else {
         upTrend = EA_TREND_STAY;
      }

      if ( (curCCI < preCCI) && (downTrend != EA_TREND_STAY) ) {
         downTrend = EA_TREND_DOWN;
      }
      else {
         downTrend = EA_TREND_STAY;
      }

      checkPos++;
   }
   
   int resTrend = EA_TREND_STAY;
   if ( upTrend != downTrend ) {
      if ( upTrend == EA_TREND_UP ) {
         resTrend = EA_TREND_UP;
      }
      else if ( downTrend == EA_TREND_DOWN ) {
         resTrend = EA_TREND_DOWN;
      }
      else {
         resTrend = EA_TREND_STAY;
      }
   }
   else {
      resTrend = EA_TREND_STAY;
   }
   
   return (resTrend);
}

//+------------------------------------------------------------------+
