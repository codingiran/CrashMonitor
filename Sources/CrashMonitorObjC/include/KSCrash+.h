//
//  KSCrash+.h
//  CrashMonitor
//
//  Created by iran.qiu on 2024/11/21.
//

#import <Foundation/Foundation.h>
#import "KSCrashReport.h"
#import "KSCrashReportStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSCrashReportStore (CrashMonitor)

- (NSArray<KSCrashReportDictionary *> *)allReports;

@end

NS_ASSUME_NONNULL_END
