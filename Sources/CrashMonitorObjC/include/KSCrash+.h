//
//  KSCrash+.h
//  CrashMonitor
//
//  Created by CodingIran on 2024/11/21.
//

#import <Foundation/Foundation.h>
#import "KSCrashReport.h"
#import "KSCrashReportStore.h"
#import "KSCrashReportFilterAppleFmt.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSCrashReportStore (CrashMonitorPublicAPI)

- (NSArray<KSCrashReportDictionary *> *)allReports;

@end

@interface KSCrashReportFilterAppleFmt (CrashMonitorPublicAPI)

- (NSDictionary *)recrashReport:(NSDictionary *)report;

- (NSDictionary *)systemReport:(NSDictionary *)report;

- (NSDictionary *)infoReport:(NSDictionary *)report;

- (NSDictionary *)processReport:(NSDictionary *)report;

- (NSDictionary *)crashReport:(NSDictionary *)report;

- (NSArray *)binaryImagesReport:(NSDictionary *)report;

@end

NS_ASSUME_NONNULL_END
