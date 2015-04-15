//
//  main.m
//  FlashlightTool
//
//  Created by Nate Parrott on 12/25/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[]) {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WebKitDeveloperExtras"]; // enable "Inspect Element" in webviews
    return NSApplicationMain(argc, argv);
}
