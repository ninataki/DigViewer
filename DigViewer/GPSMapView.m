//
//  GPSMapView.m
//  DigViewer
//
//  Created by opiopan on 2014/03/30.
//  Copyright (c) 2014年 opiopan. All rights reserved.
//

#import "GPSMapView.h"
#import "NSColor+JavascriptColorSpace.h"
#import "AppDelegate.h"
#include <math.h>

@implementation GPSMapView{
    NSString*   _apiKey;
    GPSInfo*    _gpsInfo;
    NSColor*    _fovColor;
    NSColor*    _arrowColor;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
    if (aSelector == @selector(onLoad)) return NO;
    if (aSelector == @selector(reflectGpsInfo)) return NO;
    if (aSelector == @selector(onSpecifyKey)) return NO;
    return YES;
}

- (NSString*) apiKey
{
    return _apiKey;
}

- (void) setApiKey:(NSString *)apiKey
{
    _apiKey = [apiKey copy];

    self.UIDelegate = self;
    WebScriptObject* win = [self windowScriptObject];
    [win setValue:self forKey:@"digViewerBridge"];
    
    NSString* htmlString = @
        "<!DOCTYPE html>"
        "<html>"
        "   <head>"
        "       <meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=no\" />"
        "       <style type=\"text/css\">"
        "           html { height: 100%%; font-family: sans-serif; font-size: 9pt }"
        "           body { height: 100%%; margin: 0; padding: 0 }"
        "           .c_wrapper {"
        "               position: absolute; top: 0px; left: 0px; background: #FFFFFF"
        "           }"
        "           .c_content {"
        "               position: relative; top: 50%%; -webkit-transform: translateY(-50%%);"
        "               margin: 10px;"
        "           }"
        "           #map_canvas { height: 100%% }"
        "       </style>"
        "       <script type=\"text/javascript\" src=\"GPSMapView.js\"></script>"
        "   </head>"
        "   <body>"
        "       <div id=\"map_canvas\" class=\"c_wrapper\" style=\"width:100%%; height:100%%; z-index:1\">"
        "           <div id=\"primary_msg\" class=\"c_content\" style=\"text-align:center\"> </div>"
        "       </div>"
        "       <div class=\"c_wrapper\" style=\"width:100%%; height:100%%; z-index:0\">"
        "           <div id=\"secondary_msg\" class=\"c_content\">"
        "               <br><br>"
        "               <div style=\"text-align:center\">"
        "                   <form name=\"control\">"
        "                       <input name=\"key\" type=\"button\" value=\"Specify Key...\" onclick=\"specifyKey()\"/>"
        "                   </form>"
        "               </div>"
        "           </div>"
        "       </div>"
        "   </body>"
        "</html>";
    [[self mainFrame] loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] resourceURL]];
}

- (void)onLoad
{
    NSString* script = nil;
    script = [NSString stringWithFormat:@"msgLoading = \"%@\"", NSLocalizedString(@"MVMSG_LOADING", nil)];
    [[self windowScriptObject] evaluateWebScript:script];
    script = [NSString stringWithFormat:@"msgNoKey = \"%@\"", NSLocalizedString(@"MVMSG_NOKEY", nil)];
    [[self windowScriptObject] evaluateWebScript:script];
    script = [NSString stringWithFormat:@"msgInvalidKey = \"%@\"", NSLocalizedString(@"MVMSG_INVALIDKEY", nil)];
    [[self windowScriptObject] evaluateWebScript:script];
    script = [NSString stringWithFormat:@"msgSpecifyKeyButton = \"%@\"", NSLocalizedString(@"MVMSG_SPECIFYKEYBUTTON", nil)];
    [[self windowScriptObject] evaluateWebScript:script];
    script = [NSString stringWithFormat:@"setKey(\"%@\")", _apiKey];
    [[self windowScriptObject] evaluateWebScript:script];
}

- (GPSInfo*) gpsInfo
{
    return _gpsInfo;
}

- (void) setGpsInfo:(GPSInfo *)gpsInfo
{
    _gpsInfo = gpsInfo;
    WebScriptObject* window = [self windowScriptObject];
    NSString* script = nil;
    if (_gpsInfo){
        double FOVangle = -1;
        double FOVscale = 0;
        if (gpsInfo.focalLengthIn35mm){
            double sensorSize = _gpsInfo.rotation.integerValue < 5 ? 36.0 / 2.0 : 24.0 / 2.0;
            FOVangle = atan(sensorSize / _gpsInfo.focalLengthIn35mm.doubleValue);
            FOVscale = 1.0 / cos(FOVangle);
            FOVangle = FOVangle * (180 / M_PI);
        }
        script = [NSString stringWithFormat:@"setMarker(%@, %@, %@, %f, %f, %@, %@);",
                  _gpsInfo.latitude, _gpsInfo.longitude,
                  _gpsInfo.imageDirection ? _gpsInfo.imageDirection : @"null",
                  FOVangle, FOVscale,
                  _fovColor ? [_fovColor javascriptColor] : @"null",
                  _arrowColor ? [_arrowColor javascriptColor] : @"null"];
    }else{
        script = @"resetMarker();";
    }
    [window evaluateWebScript:script];
}

- (NSColor*) fovColor
{
    return _fovColor;
}

- (void) setFovColor:(NSColor *)fovColor
{
    _fovColor = [fovColor copy];
    self.gpsInfo = _gpsInfo;
}

- (NSColor*) arrowColor
{
    return _arrowColor;
}

- (void) setArrowColor:(NSColor *)arrowColor
{
    _arrowColor = [arrowColor copy];
    self.gpsInfo = _gpsInfo;
}

- (void) reflectGpsInfo
{
    if (_gpsInfo){
        self.gpsInfo = _gpsInfo;
    }
}

- (void)onSpecifyKey
{
    AppDelegate* appDelegate = (AppDelegate*)((NSApplication*)NSApp).delegate;
    [appDelegate showPreferences];
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    WebScriptObject* window = [self windowScriptObject];
    [window evaluateWebScript:@"setHeading();"];
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    NSLog(@"Javascript: %@\n", message);
}

@end
