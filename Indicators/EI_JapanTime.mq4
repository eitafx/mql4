//+------------------------------------------------------------------+
//|                                                 EI_JapanTime.mq4 |
//|                                             Copyright 2014, eita |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, eita"
#property link      ""
#property version   "1.02"
#property strict
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 1

input bool prmAutoDiffTime = True;
input int  prmManualDiffTime = 8;
input bool prmDateDisplay = True;
input bool prmClockDisplay = True;
input int prmClockSize = 16;
input color prmClockColor = clrWhite;
input int prmTokyoStart = 9;
input int prmTokyoEnd = 15;
input color prmTokyoColor = 0x400000;
input int prmLondonStart = 16;
input int prmLondonEnd = 0;
input color prmLondonColor = 0x004000;
input int prmNewYorkStart = 22;
input int prmNewYorkEnd = 7;
input color prmNewYorkColor = 0x000040;

input string Attention1 = "The following is advanced settings.";
input int prmDispPeriod_M1_min = 10;
input int prmDispPeriod_M5_min = 30;
input int prmDispPeriod_M15_hour = 1;
input int prmDispPeriod_M30_hour = 3;
input int prmDispPeriod_H1_hour = 6;
input int prmDispPeriod_H4_hour = 12;
input double prmTimePosition = 1.0;
input double prmDatePosition = 0.7;

string obj_clockDisplay = "obj_clockdisplay";
string obj_time = "obj_time_";
string obj_day = "obj_day_";
string obj_zone = "obj_zone";
string obj_zone_tyo = "obj_zone_tyo_";
string obj_zone_lon = "obj_zone_lon_";
string obj_zone_ny = "obj_zone_ny_";

// global variable
datetime ChartTime;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    ChartTime = 0;

    deleteAllZoneObject();
    ObjectsDeleteAll(WindowOnDropped());

    IndicatorShortName(" ");
    IndicatorDigits(0);
    
    EventSetTimer(1);

//---
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
    deleteAllZoneObject();
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
    //check draw timing
    if ( ChartTime == Time[0] ) {
        return(rates_total);
    }
    else {
        ChartTime = Time[0];
    }

    // draw function
    int counted_bars=IndicatorCounted();
    if(counted_bars<0) return(-1);
    if(counted_bars>0) counted_bars--;
    int limit=Bars-counted_bars;

    if ( limit >= Bars ) {    
        for( int i=0; i<limit; i++ ) {
          drawObject(i);
        }
    }
    else {
        drawObject(0);
    }

//--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---
   if ( prmClockDisplay == True ) {
      displayClock();
   }
   else {
      deleteClock();
   }
}

//+------------------------------------------------------------------+
//| draw objects                                                     |
//+------------------------------------------------------------------+
void drawObject(const int shift)
{
    datetime diffTime;
    datetime curShiftTime;
    datetime preShiftTime;
    
    if ( prmAutoDiffTime == True ) {
        diffTime = (TimeLocal()-TimeCurrent()) / 3600;
        diffTime *= 3600;
        curShiftTime = Time[shift]+diffTime;
    }
    else {
        diffTime = prmManualDiffTime * 3600;
        curShiftTime = Time[shift] + diffTime;
    }
    
    if ( (ArraySize(Time)-1) > shift ) {
        preShiftTime = Time[shift+1] + diffTime;
    }
    else {
        preShiftTime = 0;
    }

    MqlDateTime curMqlTime, preMqlTime;
    TimeToStruct(curShiftTime,curMqlTime);
    TimeToStruct(preShiftTime,preMqlTime);
    
    drawTime( shift, curMqlTime, preMqlTime );
    drawZone( shift, curShiftTime, preShiftTime );
}

//+------------------------------------------------------------------+
//| display the Time                                                |
//+------------------------------------------------------------------+
void drawZone( const int shift,
               const datetime curShiftTime,
               const datetime preShiftTime )
{
   switch (Period())
   {
      case PERIOD_M5:
      case PERIOD_M15:
      case PERIOD_M30:
      case PERIOD_H1:
        drawZone( shift, curShiftTime, preShiftTime, obj_zone_tyo, prmTokyoStart, prmTokyoEnd, prmTokyoColor );
        drawZone( shift, curShiftTime, preShiftTime, obj_zone_lon, prmLondonStart, prmLondonEnd, prmLondonColor );
        drawZone( shift, curShiftTime, preShiftTime, obj_zone_ny, prmNewYorkStart, prmNewYorkEnd, prmNewYorkColor );
         break;
      default:
         break;
   }
}

//+------------------------------------------------------------------+
//| display the Time                                                 |
//+------------------------------------------------------------------+
void drawZone( const int shift,
               const datetime curShiftTime,
               const datetime preShiftTime,
               const string zoneName,
               const int zoneStart,
               const int zoneEnd,
               const color zoneColor )
{
    MqlDateTime curMqlTime, preMqlTime;
    TimeToStruct(curShiftTime,curMqlTime);
    TimeToStruct(preShiftTime,preMqlTime);
    
    if (zoneStart != zoneEnd) {
        int calcStartTime = zoneStart;
        int calcEndTime = zoneEnd;;
        int calcCurHour = curMqlTime.hour;
        int calcPreHour = preMqlTime.hour;
        datetime calcDateTime = curShiftTime;
        if ( zoneStart > zoneEnd ) {
            calcEndTime = zoneEnd + 24;
            if (curMqlTime.hour>=0 && curMqlTime.hour<=(zoneEnd)) {
                calcCurHour += 24;
                calcPreHour += 24;
                calcDateTime -= (3600*24);
            }            
        }

// start debug
//Print( "calcCurHour=", calcCurHour, " calcPreHour=", calcPreHour, " calcStartTime=", calcStartTime, " calcEndTime=", calcEndTime, " curMqlTime.hour=", curMqlTime.hour, " preMqlTime.hour=", preMqlTime.hour );        
// end debug
        if ( (calcCurHour >= calcStartTime) &&
             (calcCurHour <= calcEndTime && calcPreHour<(calcEndTime)) ){
             
            bool overFlag = False;
            if (calcCurHour != calcEndTime) {
                overFlag = True;
            }
            createZoneObject( shift, calcDateTime, zoneName, zoneColor, overFlag );
        }
    }
    else {
        // no action
    }
}

//+------------------------------------------------------------------+
//| create a rectangle object for zone                               |
//+------------------------------------------------------------------+
void createZoneObject ( const int shift,
                        const datetime time,
                        const string objName,
                        const color objColor,
                        const bool overFlag )
{
    string strDate = TimeToStr(time, TIME_DATE);
    string strObjectName = StringConcatenate( objName, strDate );
    
    double high = High[ArrayMaximum( High )];
    double low = Low[ArrayMinimum( Low )];
    
    if ( ObjectFind(strObjectName) < 0 ) {
        ObjectCreate(strObjectName, OBJ_RECTANGLE, 0, 0, 0);
        ObjectSet(strObjectName, OBJPROP_COLOR, objColor);
        ObjectMove(strObjectName, 1, Time[shift], high);
        ObjectMove(strObjectName, 0, Time[shift], low);
    }
   
    if ( shift == 0 ) {
        if ( overFlag != True ) {
            ObjectMove(strObjectName, 0, Time[shift], low);
        }
        else {
            ObjectMove(strObjectName, 0, (Time[shift] + PeriodSeconds()), low);
        }
    }
    else {
        ObjectMove(strObjectName, 1, Time[shift], high);
    }
}

//+------------------------------------------------------------------+
//| delete rectangle objects for zone                                |
//+------------------------------------------------------------------+
void deleteAllZoneObject()
{    
    while(1)
    {
        Print ("Delete loop");
        int obj_total = ObjectsTotal();
        string name;
        for(int i=0;i<obj_total;i++) {
            name =ObjectName(i);
            if ( StringFind( name, obj_zone, 0 ) != -1  ) {
                bool res = ObjectDelete( name );
            }
        }

        int cnt = 0;
        obj_total = ObjectsTotal();
        for(int i=0;i<obj_total;i++) {
            name =ObjectName(i);
            if ( StringFind( name, obj_zone, 0 ) == -1  ) {
                cnt++;
            }
        }

        if (obj_total == cnt) {
            break;
        }
    }
}

//+------------------------------------------------------------------+
//| display the Time                                                |
//+------------------------------------------------------------------+
void drawTime( const int shift,
               const MqlDateTime& curMqlTime,
               const MqlDateTime& preMqlTime )
{
   switch (Period())
   {
      case PERIOD_M1:
         drawTime_M1( shift, curMqlTime, preMqlTime );
         break;
      case PERIOD_M5:
         drawTime_M5( shift, curMqlTime, preMqlTime );
         break;
      case PERIOD_M15:
         drawTime_M15( shift, curMqlTime, preMqlTime );
         break;
      case PERIOD_M30:
         drawTime_M30( shift, curMqlTime, preMqlTime );
         break;
      case PERIOD_H1:
         drawTime_H1( shift, curMqlTime, preMqlTime );
         break;
      case PERIOD_H4:
         drawTime_H4( shift, curMqlTime, preMqlTime );
         break;
      case PERIOD_D1:
         drawTime_D1( shift, curMqlTime, preMqlTime );
         break;
      case PERIOD_W1:
         drawTime_W1( shift, curMqlTime, preMqlTime );
         break;
      case PERIOD_MN1:
         drawTime_MN1( shift, curMqlTime, preMqlTime );
         break;
      default:
         break;
   }
}

//+------------------------------------------------------------------+
//| display the clock at M1                                          |
//+------------------------------------------------------------------+
void drawTime_M1( const int shift,
                  const MqlDateTime& curMqlTime,
                  const MqlDateTime& preMqlTime )
{
Print("curMqlTime.min=", curMqlTime.min);

    if ( curMqlTime.hour != preMqlTime.hour ) {
        createTimeObject( shift, getTextOfTime(curMqlTime) );
    }
    else if ( checkPeriod( 60, prmDispPeriod_M1_min, curMqlTime.min, preMqlTime.min) == True ) {
        createTimeObject( shift, DoubleToStr(curMqlTime.min, 0) );
    }

    if ( curMqlTime.day != preMqlTime.day ) {
        string strDate = StringConcatenate( DoubleToStr(curMqlTime.mon, 0), "/", DoubleToStr(curMqlTime.day, 0), " (", getTextOfWeek(curMqlTime.day_of_week), ")" );
        createDayObject( shift, strDate );
    }
}

//+------------------------------------------------------------------+
//| display the clock at M5                                          |
//+------------------------------------------------------------------+
void drawTime_M5( const int shift,
                  const MqlDateTime& curMqlTime,
                  const MqlDateTime& preMqlTime )
{
    if ( curMqlTime.hour != preMqlTime.hour ) {
        createTimeObject( shift, getTextOfTime(curMqlTime) );
    }
    else if ( checkPeriod( 60, prmDispPeriod_M5_min, curMqlTime.min, preMqlTime.min) == True ) {
        createTimeObject( shift, DoubleToStr(curMqlTime.min, 0) );
    }
    
    if ( curMqlTime.day != preMqlTime.day ) {
        string strDate = StringConcatenate( DoubleToStr(curMqlTime.mon, 0), "/", DoubleToStr(curMqlTime.day, 0), " (", getTextOfWeek(curMqlTime.day_of_week), ")" );
        createDayObject( shift, strDate );
    }
}

//+------------------------------------------------------------------+
//| display the clock at M15                                          |
//+------------------------------------------------------------------+
void drawTime_M15( const int shift,
                   const MqlDateTime& curMqlTime,
                   const MqlDateTime& preMqlTime )
{
    if ( curMqlTime.day != preMqlTime.day ) {
        createTimeObject( shift, DoubleToStr(curMqlTime.hour, 0) );
    }
    else if ( checkPeriod( 24, prmDispPeriod_M15_hour, curMqlTime.hour, preMqlTime.hour) == True ) {
        createTimeObject( shift, DoubleToStr(curMqlTime.hour, 0) );
    }

    if ( curMqlTime.day != preMqlTime.day ) {
        string strDate = StringConcatenate( DoubleToStr(curMqlTime.mon, 0), "/", DoubleToStr(curMqlTime.day, 0), " (", getTextOfWeek(curMqlTime.day_of_week), ")" );
        createDayObject( shift, strDate );
    }
}

//+------------------------------------------------------------------+
//| display the clock at M30                                          |
//+------------------------------------------------------------------+
void drawTime_M30( const int shift,
                   const MqlDateTime& curMqlTime,
                   const MqlDateTime& preMqlTime )
{
    if ( curMqlTime.day != preMqlTime.day ) {
        createTimeObject( shift, DoubleToStr(curMqlTime.hour, 0) );
    }
    else if ( checkPeriod( 24, prmDispPeriod_M30_hour, curMqlTime.hour, preMqlTime.hour) == True ) {
        createTimeObject( shift, DoubleToStr(curMqlTime.hour, 0) );
    }

    if ( curMqlTime.day != preMqlTime.day ) {
        string strDate = StringConcatenate( DoubleToStr(curMqlTime.mon, 0), "/", DoubleToStr(curMqlTime.day, 0), " (", getTextOfWeek(curMqlTime.day_of_week), ")" );
        createDayObject( shift, strDate );
    }
}

//+------------------------------------------------------------------+
//| display the clock at H1                                          |
//+------------------------------------------------------------------+
void drawTime_H1( const int shift,
                  const MqlDateTime& curMqlTime,
                  const MqlDateTime& preMqlTime )
{
    if ( curMqlTime.day != preMqlTime.day ) {
        createTimeObject( shift, DoubleToStr(curMqlTime.hour, 0) );
    }
    else if ( checkPeriod( 24, prmDispPeriod_H1_hour, curMqlTime.hour, preMqlTime.hour) == True ) {
        createTimeObject( shift, DoubleToStr(curMqlTime.hour, 0) );
    }

    if ( curMqlTime.day != preMqlTime.day ) {
        string strDate = StringConcatenate( DoubleToStr(curMqlTime.mon, 0), "/", DoubleToStr(curMqlTime.day, 0), " (", getTextOfWeek(curMqlTime.day_of_week), ")" );
        createDayObject( shift, strDate );
    }
}

//+------------------------------------------------------------------+
//| display the clock at H4                                          |
//+------------------------------------------------------------------+
void drawTime_H4( const int shift,
                  const MqlDateTime& curMqlTime,
                  const MqlDateTime& preMqlTime )
{
    if ( curMqlTime.day != preMqlTime.day ) {
        createTimeObject( shift, DoubleToStr(curMqlTime.hour, 0) );
    }
    else if ( checkPeriod( 24, prmDispPeriod_H4_hour, curMqlTime.hour, preMqlTime.hour) == True ) {
        createTimeObject( shift, DoubleToStr(curMqlTime.hour, 0) );
    }

    if ( curMqlTime.day != preMqlTime.day ) {
        string strDate = StringConcatenate( DoubleToStr(curMqlTime.mon, 0), "/", DoubleToStr(curMqlTime.day, 0) );
        createDayObject( shift, strDate );
    }
}

//+------------------------------------------------------------------+
//| display the clock at D1                                          |
//+------------------------------------------------------------------+
void drawTime_D1( const int shift,
                  const MqlDateTime& curMqlTime,
                  const MqlDateTime& preMqlTime )
{
   if ( curMqlTime.day_of_week == 1 ) {
      string strDate = StringConcatenate( DoubleToStr(curMqlTime.mon,0), "/", DoubleToStr(curMqlTime.day,0) );
      createTimeObject( shift, strDate );
   }

   if ( preMqlTime.mon > curMqlTime.mon ) {
      createDayObject( shift, DoubleToStr(curMqlTime.year,0) );
   }
}

//+------------------------------------------------------------------+
//| display the clock at W1                                          |
//+------------------------------------------------------------------+
void drawTime_W1( const int shift,
                  const MqlDateTime& curMqlTime,
                  const MqlDateTime& preMqlTime )
{
   if ( preMqlTime.mon != curMqlTime.mon ) {
      createTimeObject( shift, DoubleToStr(curMqlTime.mon,0) );
   }

   if ( preMqlTime.mon > curMqlTime.mon ) {
      createDayObject( shift, DoubleToStr(curMqlTime.year,0) );
   }
}

//+------------------------------------------------------------------+
//| display the clock at MN1                                         |
//+------------------------------------------------------------------+
void drawTime_MN1( const int shift,
                  const MqlDateTime& curMqlTime,
                  const MqlDateTime& preMqlTime )
{
   if ( (curMqlTime.mon%6 == 1) &&
        (preMqlTime.mon != curMqlTime.mon) ) {
      createTimeObject( shift, DoubleToStr(curMqlTime.mon,0) );
   }

   if ( preMqlTime.mon > curMqlTime.mon ) {
      createDayObject( shift, DoubleToStr(curMqlTime.year,0) );
   }
}

//+------------------------------------------------------------------+
//| check the display period                                         |
//+------------------------------------------------------------------+
bool checkPeriod( const int baseTime,
                  const int dispPeriod,
                  const int curTime,
                  const int preTime )
{
    bool result = False;

    int qty = baseTime / dispPeriod;

    for (int index=0; index<qty; index++ ) {
    
        int dispMin = (dispPeriod * index);
        if ( (preTime < dispMin) && (dispMin <= curTime) ) {
            result = True;
            break;
        }
    }

    return result;
}

//+------------------------------------------------------------------+
//| get the text of week                                             |
//+------------------------------------------------------------------+
string getTextOfWeek( const int week )
{
    const string weekArray[] = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
    
    return weekArray[week];
}

//+------------------------------------------------------------------+
//| get the text of time                                             |
//+------------------------------------------------------------------+
string getTextOfTime( const MqlDateTime& curMqlTime )
{
    string strHour = DoubleToStr( curMqlTime.hour, 0 );
    string strMinute = DoubleToStr( curMqlTime.min, 0 );

    if ( curMqlTime.min <= 9 ) {
        strMinute = "0" + strMinute;
    }

    string strTime = StringConcatenate( strHour, ":", strMinute );
    
    return strTime;
}

//+------------------------------------------------------------------+
//| create a label object for time display                           |
//+------------------------------------------------------------------+
void createTimeObject ( const int shift,
                        const string strText )
{
   string strUniqueCode = DoubleToStr(Time[shift],0);
   string strObjectName = StringConcatenate( obj_time, strUniqueCode );

   if ( ObjectFind(strObjectName) < 0 ) {
      ObjectCreate(strObjectName, OBJ_TEXT, WindowOnDropped(), 0, 0);
      ObjectSetText(strObjectName, strText, 10, NULL, White);
   }
   
   ObjectMove(strObjectName, 0, Time[shift], prmTimePosition);
}

//+------------------------------------------------------------------+
//| create a label object for day display                            |
//+------------------------------------------------------------------+
void createDayObject ( const int shift,
                       const string strText )
{
   if ( prmDateDisplay == True ) {   
      string strUniqueCode = DoubleToStr(Time[shift],0);
      string strObjectName = StringConcatenate( obj_day, strUniqueCode );
   
      if ( ObjectFind(strObjectName) < 0 ) {
         ObjectCreate(strObjectName, OBJ_TEXT, WindowOnDropped(), 0, 0);
         ObjectSetText(strObjectName, strText, 10, NULL, White);
      }
      
      ObjectMove( strObjectName, 0, Time[shift], prmDatePosition );
   }
}

//+------------------------------------------------------------------+
//| display the clock                                                |
//+------------------------------------------------------------------+
void displayClock()
{
    if ( ObjectFind(obj_clockDisplay) < 0 ) {
        ObjectCreate(obj_clockDisplay, OBJ_LABEL, WindowOnDropped(), 0, 0);
    }
    
    datetime time_jpn = TimeLocal();
    string strJpn = "TYO:" + TimeToStr( time_jpn, TIME_MINUTES );
    
    datetime time_lon = time_jpn - (3600*8);
    string strLon = "LON:" + TimeToStr( time_lon, TIME_MINUTES );
    
    datetime time_ny = time_jpn - (3600*13);
    string strNy = "NY:" + TimeToStr( time_ny, TIME_MINUTES );
    
    string strClock = strJpn + " " + strLon + " " + strNy;
    
    ObjectSetText(obj_clockDisplay, strClock, prmClockSize, NULL, prmClockColor);
    ObjectSet(obj_clockDisplay, OBJPROP_XDISTANCE, 5);
    ObjectSet(obj_clockDisplay, OBJPROP_YDISTANCE, 2);
    ObjectSet(obj_clockDisplay, OBJPROP_CORNER, 2);
}
//+------------------------------------------------------------------+
//| delete  the clock                                                |
//+------------------------------------------------------------------+
void deleteClock()
{
   ObjectDelete(obj_clockDisplay);
}

//+------------------------------------------------------------------+
