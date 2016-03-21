//
// Created by Josh Butts on 3/17/16.
// Copyright (c) 2016 joshbutts. All rights reserved.
//

#import "IMEnvironmentSetup.h"


@implementation IMEnvironmentSetup

+ (void)setupBashProfile {

    NSString *envScript = [NSString stringWithFormat:@"export PATH=$PATH:%@\n", [[NSBundle mainBundle] resourcePath]];
    envScript = [envScript stringByAppendingString:@"export DOCKER_HOST=tcp://127.0.0.1:2375"];

    NSString *envScriptFilename = [NSString stringWithFormat:@"%@/intermodal-env.sh", [[NSBundle mainBundle] resourcePath]];
    [envScript writeToFile:envScriptFilename atomically:YES encoding:NSUTF8StringEncoding error:nil];

    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *bashProfilePath = [NSString stringWithFormat:@"%@/.bash_profile", NSHomeDirectory()];

    NSString *envBashImport = [NSString stringWithFormat:@". %@\n", envScriptFilename];

    NSArray *bashProfileLines;

    if (![fm fileExistsAtPath:bashProfilePath]) {
        bashProfileLines = @[];
    } else {
        NSString *existingBashProfileContent = [NSString stringWithContentsOfFile:bashProfilePath encoding:NSUTF8StringEncoding error:nil];
        bashProfileLines = [existingBashProfileContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    }

    NSMutableArray *newBashProfileLines = [NSMutableArray new];
    for (NSString *line in bashProfileLines) {
        if (![line containsString:@"intermodal-env.sh"]) {
            [newBashProfileLines addObject:line];
        }
    }
    [newBashProfileLines addObject:envBashImport];
    NSString *newBashProfileContent = [newBashProfileLines componentsJoinedByString:@"\n"];
    [newBashProfileContent writeToFile:bashProfilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end