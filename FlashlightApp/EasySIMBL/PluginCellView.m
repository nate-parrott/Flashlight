//
//  PluginCellView.m
//  Flashlight
//
//  Created by Nate Parrott on 11/3/14.
//
//

#import "PluginCellView.h"
#import "PluginModel.h"

@implementation PluginCellView

- (void)setObjectValue:(id)objectValue {
    [super setObjectValue:objectValue];
    PluginModel *model = (PluginModel *)objectValue;
    self.switchControl.on = model.installed;
}

@end
