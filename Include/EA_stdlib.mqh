//+------------------------------------------------------------------+
//|                                                    EA_stdlib.mqh |
//|                                             Copyright 2014, eita |
//|                                                         Ver:1.01 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, eita"
#property link      ""
#property strict

//+------------------------------------------------------------------+
//| calculate the index for multi time                               |
//+------------------------------------------------------------------+
int EA_convertIndexForMT(const int timeframe,
                         const int shift,
                         const int calcIndexShift)
{
   int calcIndex = calcIndexShift;
   
   if ( calcIndexShift >=  0 ) {
      datetime timeArray[];
   
      int result = ArrayCopySeries( timeArray, MODE_TIME, Symbol(), timeframe  );
      if (result == ERR_HISTORY_WILL_UPDATED) {
         calcIndex = -1;
      }
      else {
         while(1)
         {
            if (Time[shift]<timeArray[calcIndex]) {
               if ( ArraySize(timeArray) > (calcIndex+1) ) {
                  calcIndex++;
               }
               else {
                  calcIndex = -1;
                  break;
               }
            }
            else {
               break;
            }
         }
      }
    }

   return calcIndex;
}

//+------------------------------------------------------------------+
