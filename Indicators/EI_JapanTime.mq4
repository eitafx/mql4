//+------------------------------------------------------------------+
//|                                                 EI_JapanTime.mq4 |
//|                                             Copyright 2014, eita |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, eita"
#property link      ""
#property version   "1.01"
#property strict
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 1

input bool prmAutoDiffTime = True;
input int  prmManualDiffTime = 8;
input bool prmDateDisplay = True;
input bool prmClockDisplay = True;
input int prmClockSize = 18;
input color prmClockColor = clrWhite;
input int prmTokyoStart = 9;
input int prmTokyoEnd = 15;
input color prmTokyoColor = 0x400000;
input int prmLondonStart = 16;
input int prmLondonEnd = 24;
input color prmLondonColor = 0x004000;
input int prmNewYorkStart = 22;
input int prmNewYorkEnd = 7;
input color prmNewYorkColor = 0x000040;

input string Attention1 = "The following is  advanced settings.";
input int prmDispPeriod_M1 = 600;
input int prmDispTiming_M1 = 0;
input int prmDispPeriod_M5 = 1800;
input int prmDispTiming_M5 = 0;
input int prmDispPeriod_M15 = 3600;
input int prmDispTiming_M15 = 0;
input int prmDispPeriod_M30 = 10800;
input int prmDispTiming_M30 = 0;
input int prmDispPeriod_H1 = 21600;
input int prmDispTiming_H1 = 0;
input double prmTimePosition = 1.0;
input double prmDatePosition = 0.7;


#define PERIOD_H24   (86400)

string obj_clockDisplay = "obj_clockdisplay";
string obj_time = "obj_time_";
string obj_day = "obj_day_";
string obj_zone = "obj_zone";
string obj_zone_tyo = "obj_zone_tyo_";
string obj_zone_lon = "obj_zone_lon_";
string obj_zone_ny = "obj_zone_ny_";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
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
   datetime curShitTime;
   datetime preShiftTime;

   if ( prmAutoDiffTime == True ) {
      diffTime = (TimeLocal()-TimeCurrent()) / 3600;
      diffTime *= 3600;
      curShitTime = Time[shift]+diffTime;
   }
   else {
      diffTime = prmManualDiffTime * 3600;
      curShitTime = Time[shift] + diffTime;
   }

   if ( (ArraySize(Time)-1) > shift ) {
      preShiftTime = Time[shift+1] + diffTime;
   }
   else {
      preShiftTime = 0;
   }
   
   drawTime( shift, curShitTime, preShiftTime );
   drawZone( shift, curShitTime, preShiftTime );
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
               const datetime curShiftTime,
               const datetime preShiftTime )
{
   switch (Period())
   {
      case PERIOD_M1:
         drawTime_M1( shift, curShiftTime );
         break;
      case PERIOD_M5:
         drawTime_M5( shift, curShiftTime );
         break;
      case PERIOD_M15:
         drawTime_M15( shift, curShiftTime );
         break;
      case PERIOD_M30:
         drawTime_M30( shift, curShiftTime );
         break;
      case PERIOD_H1:
         drawTime_H1( shift, curShiftTime );
         break;
      case PERIOD_H4:
         drawTime_H4( shift, curShiftTime );
         break;
      case PERIOD_D1:
         drawTime_D1( shift, curShiftTime, preShiftTime );
         break;
      case PERIOD_W1:
         drawTime_W1( shift, curShiftTime );
         break;
      case PERIOD_MN1:
         drawTime_MN1( shift, curShiftTime );
         break;
      default:
         break;
   }
}

//+------------------------------------------------------------------+
//| display the clock at M1                                          |
//+------------------------------------------------------------------+
void drawTime_M1( const int shift,
                  const datetime time )
{
   if ( (time%prmDispPeriod_M1) == prmDispTiming_M1 ) {
      string strTime = StringConcatenate( getTextOfHour( time ), ":", getTextOfMinute( time ) );
      createTimeObject( shift, strTime );
   }
   
   if ( (time%PERIOD_H24) == prmDispTiming_M1 ) {
      string strDate = StringConcatenate( getTextOfMonth( time ), "/", getTextOfDay( time ), " (", getTextOfWeek(time), ")" );
      createDayObject( shift, strDate );
   }
}

//+------------------------------------------------------------------+
//| display the clock at M5                                          |
//+------------------------------------------------------------------+
void drawTime_M5( const int shift,
                  const datetime time )
{
   if ( (time%prmDispPeriod_M5) == prmDispTiming_M5 ) {
      string strTime = StringConcatenate( getTextOfHour( time ), ":", getTextOfMinute( time ) );
      createTimeObject( shift, strTime );
   }
   
   if ( (time%PERIOD_H24) == prmDispTiming_M5 ) {
      string strDate = StringConcatenate( getTextOfMonth( time ), "/", getTextOfDay( time ), " (", getTextOfWeek(time), ")" );
      createDayObject( shift, strDate );
   }
}

//+------------------------------------------------------------------+
//| display the clock at M15                                          |
//+------------------------------------------------------------------+
void drawTime_M15( const int shift,
                   const datetime time )
{
   if ( (time%prmDispPeriod_M15) == prmDispTiming_M15 ) {
      string strTime = StringConcatenate( getTextOfHour( time ) );
      createTimeObject( shift, strTime );
   }
   
   if ( (time%PERIOD_H24) == prmDispTiming_M15 ) {
      string strDate = StringConcatenate( getTextOfMonth( time ), "/", getTextOfDay( time ), " (", getTextOfWeek(time), ")" );
      createDayObject( shift, strDate );
   }
}

//+------------------------------------------------------------------+
//| display the clock at M30                                          |
//+------------------------------------------------------------------+
void drawTime_M30( const int shift,
                   const datetime time )
{
   if ( (time%prmDispPeriod_M30) == prmDispTiming_M30 ) {
      string strTime = StringConcatenate( getTextOfHour( time ) );
      createTimeObject( shift, strTime );
   }
   
   if ( (time%PERIOD_H24) == prmDispTiming_M30 ) {
      string strDate = StringConcatenate( getTextOfMonth( time ), "/", getTextOfDay( time ), " (", getTextOfWeek(time), ")" );
      createDayObject( shift, strDate );
   }
}

//+------------------------------------------------------------------+
//| display the clock at H1                                          |
//+------------------------------------------------------------------+
void drawTime_H1( const int shift,
                  const datetime time )
{
   if ( (time%prmDispPeriod_H1) == prmDispTiming_H1 ) {
      string strTime = StringConcatenate( getTextOfHour( time ) );
      createTimeObject( shift, strTime );
   }
   
   if ( (time%PERIOD_H24) == prmDispTiming_H1 ) {
      string strDate = StringConcatenate( getTextOfMonth( time ), "/", getTextOfDay( time ), " (", getTextOfWeek(time), ")" );
      createDayObject( shift, strDate );
   }
}

//+------------------------------------------------------------------+
//| display the clock at H4                                          |
//+------------------------------------------------------------------+
void drawTime_H4( const int shift,
                  const datetime time )
{
   int curHour = TimeHour( time );
   int diffHour = curHour%4;
   if ( curHour%12 == diffHour ) {
      string strHour = getTextOfHour( time );
      createTimeObject( shift, strHour );
   }

   if ( curHour%24 == diffHour ) {
      string strDate = StringConcatenate( getTextOfMonth( time ), "/", getTextOfDay( time ) );
      createDayObject( shift, strDate );
   }
}

//+------------------------------------------------------------------+
//| display the clock at D1                                          |
//+------------------------------------------------------------------+
void drawTime_D1( const int shift,
                  const datetime time,
                  const datetime preShiftTime )
{
   int week = TimeDayOfWeek(time);
   if ( week == 1 ) {
      string strDate = StringConcatenate( getTextOfMonth( time ), "/", getTextOfDay( time ) );
      createTimeObject( shift, strDate );
   }

   int curMonth = TimeMonth(time);
   int preMonth = TimeMonth(preShiftTime);
   if ( preMonth > curMonth ) {
      string strYear = getTextOfYear( time );
      createDayObject( shift, strYear );
   }
}

//+------------------------------------------------------------------+
//| display the clock at W1                                          |
//+------------------------------------------------------------------+
void drawTime_W1( const int shift,
                  const datetime time )
{
   int curMonth = TimeMonth(time);
   int preMonth = TimeMonth(time-(PERIOD_H24*7));
   if ( (preMonth==12 && curMonth==1) ||
        (preMonth==(curMonth-1) && curMonth%3==0) ) {
      string strDate = getTextOfMonth( time );
      createTimeObject( shift, strDate );
   }

   if ( preMonth==12 && curMonth==1 ) {
      string strYear = getTextOfYear( time );
      createDayObject( shift, strYear );
   }
}

//+------------------------------------------------------------------+
//| display the clock at MN1                                         |
//+------------------------------------------------------------------+
void drawTime_MN1( const int shift,
                   const datetime time )
{
   int curMonth = TimeMonth(time);
   int preMonth = TimeMonth(time-(PERIOD_H24*7));
   if ( (preMonth==12 && curMonth==1) ||
        (preMonth==5 && curMonth==6) ) {
      string strDate = getTextOfMonth( time );
      createTimeObject( shift, strDate );
   }

   if ( preMonth==12 && curMonth==1 ) {
      string strYear = getTextOfYear( time );
      createDayObject( shift, strYear );
   }
}

//+------------------------------------------------------------------+
//| get the text of week                                             |
//+------------------------------------------------------------------+
string getTextOfWeek( const datetime time )
{
   const string weekArray[] = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
   int week = TimeDayOfWeek(time);
   
   return weekArray[week];
}

//+------------------------------------------------------------------+
//| get the text of year                                             |
//+------------------------------------------------------------------+
string getTextOfYear( const datetime time )
{
   int year = TimeYear(time);
   string strYear = DoubleToStr( year, 0 );
   
   return strYear;
}

//+------------------------------------------------------------------+
//| get the text of month                                            |
//+------------------------------------------------------------------+
string getTextOfMonth( const datetime time )
{
   int month = TimeMonth(time);
   string strMonth = DoubleToStr( month, 0 );
   
   return strMonth;
}

//+------------------------------------------------------------------+
//| get the text of day                                              |
//+------------------------------------------------------------------+
string getTextOfDay( const datetime time )
{
   int day = TimeDay(time);
   string strDay = DoubleToStr( day, 0 );
   
   return strDay;
}

//+------------------------------------------------------------------+
//| get the text of hour                                              |
//+------------------------------------------------------------------+
string getTextOfHour( const datetime time )
{
   int hour = TimeHour(time);
   string strHour = DoubleToStr( hour, 0 );
   
   return strHour;
}

//+------------------------------------------------------------------+
//| get the text of minute                                           |
//+------------------------------------------------------------------+
string getTextOfMinute( const datetime time )
{
   int minute = TimeMinute(time);
   string strMinute = DoubleToStr( minute, 0 );
   
   if ( minute <= 9 ) {
      strMinute = "0" + strMinute;
   }

   return strMinute;
}

//+------------------------------------------------------------------+
//| create a label object for time display                           |
//+------------------------------------------------------------------+
void createTimeObject ( const int no,
                        const string strText )
{
   string strNo = DoubleToStr(no,0);
   string strObjectName = StringConcatenate( obj_time, strNo );

   if ( ObjectFind(strObjectName) < 0 ) {
      ObjectCreate(strObjectName, OBJ_TEXT, WindowOnDropped(), 0, 0);
      ObjectSetText(strObjectName, strText, 10, NULL, White);
   }
   
   ObjectMove(strObjectName, 0, Time[no], prmTimePosition);
}

//+------------------------------------------------------------------+
//| delate a label object for time display                           |
//+------------------------------------------------------------------+
void delateTimeObject ( const int no )
{
   string strNo = DoubleToStr(no);
   string strObjectName = StringConcatenate( obj_time, strNo );

   ObjectDelete( strObjectName );
}

//+------------------------------------------------------------------+
//| create a label object for day display                            |
//+------------------------------------------------------------------+
void createDayObject ( const int no,
                        const string strText )
{
   if ( prmDateDisplay == True ) {   
      string strNo = DoubleToStr(no,0);
      string strObjectName = StringConcatenate( obj_day, strNo );
   
      if ( ObjectFind(strObjectName) < 0 ) {
         ObjectCreate(strObjectName, OBJ_TEXT, WindowOnDropped(), 0, 0);
         ObjectSetText(strObjectName, strText, 10, NULL, White);
      }
      
      ObjectMove( strObjectName, 0, Time[no], prmDatePosition );
   }
   else {
      delateDayObject( no );
   }
}

//+------------------------------------------------------------------+
//| delate a label object for day display                           |
//+------------------------------------------------------------------+
void delateDayObject ( const int no )
{
   string strNo = DoubleToStr(no);
   string strObjectName = StringConcatenate( obj_day, strNo );

   ObjectDelete( strObjectName );
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

/*
//+------------------------------------------------------------------+
//| class for controlling the datetime                               |
//+------------------------------------------------------------------+
class CDateTime
{
private:
  datetime  m_dateTime;

public:
  CDateTime( datetime time );
  int GetYear();
  int GetMonth();
  int GetDay();
  int GetHour();
  int GetMin();
  int GetSec();
};

CDateTime::CDateTime(datetime time)
{
    m_dateTime = time;
}
int CDateTime::GetYear()
{
    return TimeYear[m_dateTime];
}
int CDateTime::GetMonth()
{
    return TimeMonth[m_dateTime];
}
int CDateTime::GetDay()
{
    return TimeDay[m_dateTime];
}
int CDateTime::GetHour()
{
    return TimeHour[m_dateTime];
}
int CDateTime::GetMin()
{
    return TimeMinute[m_dateTime];
}
int CDateTime::GetSec()
{
    return TimeSeconds[m_dateTime];
}
*/
//+------------------------------------------------------------------+
