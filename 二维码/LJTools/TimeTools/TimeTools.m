//
//  TimeTools.m
//  testJson
//
//  Created by gorson on 3/10/15.
//  Copyright (c) 2015 gorson. All rights reserved.
//

#import "TimeTools.h"

@implementation TimeTools

+ (NSString *)getCurrentTimestamp
{
    //获取系统当前的时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    // 转为字符型
    return timeString;
}

+ (NSString *)getCurrentStandarTime
{
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    return locationString;
}

+ (NSString*)getCurrentTimesType:(NSString*)type
{
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:type];
    
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    return locationString;
}

+ (NSString *)timestampChangesStandarTime:(NSString *)timestamp
{
    if (IFISNULL(timestamp))
    {
        return @"";
    }
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString* tempStr=[timestamp substringToIndex:10];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[tempStr doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}

+(NSString *)timestampChangeTimeStyle:(double)timestamp{
    if (timestamp < 0)
    {
        return @"";
    }
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    if (timestamp>=3600) {
        [formatter setDateFormat:@"HH:mm:ss"];
    }else{
        [formatter setDateFormat:@"mm:ss"];
    }
    
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}

+(NSString *)timestampChangesStandarTime:(NSString *)timestamp Type:(NSString *)type
{
    if (IFISNULL(timestamp))
    {
        return @"";
    }
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:type];
    NSString* tempStr=timestamp;
    if (timestamp.length>10) {
        tempStr=[timestamp substringToIndex:10];
    }else if(timestamp.length<10){
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    }
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[tempStr doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}

+(NSString *)timeToweek:(NSString *)time{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"EEEE"];
    
    NSString* tempStr=[time substringToIndex:10];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[tempStr doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}



/**  yyyy-MM-dd HH:mm:ss（完整） -> 时间戳 */
+(double)getTimestampFromTime:(NSString*)time dateType:(NSString*)dateType{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:dateType];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    
    //------------将字符串按formatter转成nsdate
    NSDate* date = [formatter dateFromString:time];
    
    double timestamp = [date timeIntervalSince1970];
    return timestamp;
}


/**  获取距离2017年 的所有月份 */
+(NSArray*)getAllMonths{
    NSMutableArray* monthsArray = [NSMutableArray array];
    NSMutableArray* monthsTimestamp = [NSMutableArray array];
    
    //double startTimestamp = [self getTimestampFromTime:@"2017-01-01" dateType:@"yyyy-MM-dd"];
    double currentTimestamp = [[self getCurrentTimestamp] doubleValue];
    
    BOOL isEnd = NO;
    NSInteger year = 2017;
    while (!isEnd) {
        for (NSInteger i = 1; i<13; i++) {
            NSString* monthStr = [NSString stringWithFormat:@"%ld-%ld-01", year, i];
            double monthTimestamp = [self getTimestampFromTime:monthStr dateType:@"yyyy-MM-dd"];
            if (monthTimestamp >= currentTimestamp) {
                isEnd = YES;
                break;
            }else{
                [monthsArray addObject:[@(i) stringValue]];
                [monthsTimestamp addObject:@(monthTimestamp)];
            }
        }
        year ++;
    }
    [monthsTimestamp addObject:@(currentTimestamp)];
    
    //逆向 降序 ->  从当前时间 排到2017/01/01
    [monthsArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return NSOrderedDescending;
    }];
    [monthsTimestamp sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return NSOrderedDescending;
    }];
    
    [monthsArray addObject:monthsTimestamp];
    
    return monthsArray;
}

/**  获取距离2017年 的所有周 */
+(NSArray*)getAllWeeks{
    NSMutableArray* weeksArray = [NSMutableArray array];
    NSMutableArray* weeksTimestamp = [NSMutableArray array];
    long oneWeekSecond = 60*60*24*7;
    long oneDaySecond = 60*60*24;
    double startTimestamp = [self getTimestampFromTime:@"2017-01-01" dateType:@"yyyy-MM-dd"];
    double currentTimestamp = [[self getCurrentTimestamp] doubleValue];
    
    
    NSCalendar* calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    
    //1~7  日 一 二 三 四 五 六
    NSInteger currentWeekNum = [calendar component:NSCalendarUnitWeekday fromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    //currentWeekNum = currentWeekNum == 1 ? 7 : (currentWeekNum-1);
    
    //第一逆推的周日 时间戳
    double firstWeekTimestamp = currentTimestamp - oneDaySecond*(currentWeekNum-1);
    NSString* firstWeekStr = [self timestampChangesStandarTime:[@(firstWeekTimestamp) stringValue] Type:@"yyyy-MM-dd"];
    firstWeekTimestamp = [self getTimestampFromTime:firstWeekStr dateType:@"yyyy-MM-dd"];
    
    //保存第一个时间戳  （当前时间戳）
    [weeksTimestamp addObject:@(currentTimestamp)];
    
    //开始 本周的结束 月/日
    NSString* weekEndStr = [self timestampChangesStandarTime:[@(currentTimestamp) stringValue] Type:@"MM/dd"];
    
    while (1) {
        if (firstWeekTimestamp < startTimestamp) {
            break;
        }else{
            [weeksTimestamp addObject:@(firstWeekTimestamp)];
            
            NSString* weekStartStr = [self timestampChangesStandarTime:[@(firstWeekTimestamp) stringValue] Type:@"MM/dd"];
            [weeksArray addObject:[NSString stringWithFormat:@"%@\n%@", weekStartStr, weekEndStr]];
            
            weekEndStr = [self timestampChangesStandarTime:[@(firstWeekTimestamp - oneDaySecond) stringValue] Type:@"MM/dd"];
        }
        
        firstWeekTimestamp -= oneWeekSecond;
    }
    
    [weeksArray addObject:weeksTimestamp];
    
    return weeksArray;
}

/**  获取距离2017年 的所有日期 1~31 */
+(NSArray*)getAllDays{
    
    NSMutableArray* daysArray = [NSMutableArray array];
    NSMutableArray* daysTimestampArray = [NSMutableArray array];
    
    long oneDaySecond = 60*60*24;
    double startTimestamp = [self getTimestampFromTime:@"2017-01-01" dateType:@"yyyy-MM-dd"];
    double currentTimestamp = [[self getCurrentTimestamp] doubleValue];
    
    NSString* curretnDayStr = [self timestampChangesStandarTime:[@(currentTimestamp) stringValue] Type:@"yyyy-MM-dd"];
    double currentDayTimestamp = [self getTimestampFromTime:curretnDayStr dateType:@"yyyy-MM-dd"];
    curretnDayStr = [self timestampChangesStandarTime:[@(currentDayTimestamp) stringValue] Type:@"MM\ndd"];
    
    //添加 今天00：00 的 月日，及 时间戳
    [daysArray addObject:curretnDayStr];
    [daysTimestampArray addObject:@(currentDayTimestamp)];
    
    while (1) {
        currentDayTimestamp -= oneDaySecond;
        if (currentDayTimestamp < startTimestamp) {
            break;
        }else{
            curretnDayStr = [self timestampChangesStandarTime:[@(currentDayTimestamp) stringValue] Type:@"MM\ndd"];
            [daysArray addObject:curretnDayStr];
            [daysTimestampArray addObject:@(currentDayTimestamp)];
        }
    }
    [daysArray addObject:daysTimestampArray];
    
    return daysArray;
}


@end
