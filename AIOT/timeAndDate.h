#include "time.h"

//#include "WiFiConnection.h"

const char* ntpServer = "pool.ntp.org";
const long gmtOffset_sec = 0;
const int daylightOffset_sec = 3600;
struct tm timeinfo;

void TimeAndDateSetUp() {
   Serial.println("TimeAndDateSetUp");
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
}

String getTime() {
  String timeStr = "";
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Failed to obtain time");
    return timeStr;
  }
  int hour = timeinfo.tm_hour;
  int minute = timeinfo.tm_min;

  if (hour < 10) {
    timeStr += '0';
  }
  timeStr += String(hour) + ':';
  if (minute < 10) {
    timeStr += '0';
  }
  timeStr += String(minute);
  return timeStr;

}

String getDate() {
  String dateStr = "";
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Failed to obtain time");
    return dateStr;
  }
  int day = timeinfo.tm_mday;
  int month = timeinfo.tm_mon + 1;
  int year = timeinfo.tm_year + 1900;

  if (day < 10) {
    dateStr += '0';
  }
  dateStr += String(day) + '/';
  if (month < 10) {
    dateStr += '0';
  }
  dateStr += String(month) + '/';
  dateStr += String(year % 100);
  return dateStr;
}


















