//
//  RWLegacyNSColor.m
//  RWLegacySupport
//
//  Copyright © 2022 Realmac Software Ltd. All rights reserved.
//

#import "RWLegacyNSColor.h"

#include <stdio.h>

@implementation NSColor (HTMLColor)

+ (NSColor *)colorWithHexColorTagString:(NSString *)string colorTagMap:(NSDictionary *)colorTagMap
{
	return [self colorWithColorTagString:string colorTagMap:colorTagMap selector:@selector(colorWithHTMLColorString:)];
}

+ (NSColor *)colorWithRGBAColorTagString:(NSString *)string colorTagMap:(NSDictionary *)colorTagMap
{
	return [self colorWithColorTagString:string colorTagMap:colorTagMap selector:@selector(colorWithRGBAColorString:)];
}

+ (NSColor *)colorWithString:(NSString *)string usingSelector:(SEL)selector
{
	return [self performSelector:selector withObject:string];
}

+ (NSColor*)colorWithColorTagString:(NSString*)string colorTagMap:(NSDictionary*)colorTagMap selector:(SEL)selector
{
	const char* cString = [string UTF8String];
	
	
	char colourTagName[1024];
	
	{
		char endingPercent[2];
		const int numberOfScannedFields = sscanf(cString, "%%%1023[^% *+-]%[%]", colourTagName, endingPercent);
		if(numberOfScannedFields == 2) return [self colorWithString:[colorTagMap objectForKey:[NSString stringWithFormat:@"%%%s%%", colourTagName]] usingSelector:selector];
	}
	
	{
		char arithmeticOperator[2];
		char rhsColorString[1024];	// No buffer overflow possible since we restrict the maximum scanned field width with %1023s
		const int numberOfScannedFields = sscanf(cString, "%%%1023[^% *+-] %1[+*-] %1023[^%]%%", colourTagName, arithmeticOperator, rhsColorString);
		
		if(numberOfScannedFields == 1)
		{
			return [self colorWithString:[colorTagMap objectForKey:[NSString stringWithFormat:@"%%%s%%", colourTagName]] usingSelector:selector];
		}
		else if(numberOfScannedFields == 3)
		{
			NSColor* lhsColor = [self colorWithString:[colorTagMap objectForKey:[NSString stringWithFormat:@"%%%s%%", colourTagName]] usingSelector:selector];
			
			const CGFloat lhsRed = [lhsColor redComponent];
			const CGFloat lhsGreen = [lhsColor greenComponent];
			const CGFloat lhsBlue = [lhsColor blueComponent];
			
			// Accept either a colour or a floating-point value: try to parse the
			// operand as a colour first, and if that fails, scan the operand as
			// a floating-point value.
			
			CGFloat rhsRed = 0.0f;
			CGFloat rhsGreen = 0.0f;
			CGFloat rhsBlue = 0.0f;
			
			NSColor* rhsColor = [self colorWithString:[NSString stringWithUTF8String:rhsColorString] usingSelector:selector];
			if(rhsColor != nil)
			{
				rhsRed = [rhsColor redComponent];
				rhsGreen = [rhsColor greenComponent];
				rhsBlue = [rhsColor blueComponent];
			}
			else
			{
				{
					float rhsOverallColorAdjustment = 0.0f;
					
					const int rhsColorFieldsScanned = sscanf(rhsColorString, "%f", &rhsOverallColorAdjustment);
					
					if(rhsColorFieldsScanned == 1)
					{
						rhsRed = rhsOverallColorAdjustment;
						rhsGreen = rhsOverallColorAdjustment;
						rhsBlue = rhsOverallColorAdjustment;
					}
				}
				
				{
					char colourSpecifier[3][2];
					float colourAdjustment[3];
					
					const int rhsColorFieldsScanned = sscanf(rhsColorString, "%1[rgbRGB](%f) %1[rgbRGB](%f) %1[rgbRGB](%f)",
															 colourSpecifier[0], &colourAdjustment[0],
															 colourSpecifier[1], &colourAdjustment[1],
															 colourSpecifier[2], &colourAdjustment[2]);
					
					switch(rhsColorFieldsScanned)
					{
						case 2:
						case 4:
						case 6:
						{
							const NSInteger numberOfColourAdjustments = rhsColorFieldsScanned/2;
							
							NSInteger i = 0;
							for(i = 0; i < numberOfColourAdjustments; i++)
							{
								const char c = colourSpecifier[i][0];
								const CGFloat f = colourAdjustment[i];
								
								if(c == 'r' || c == 'R') rhsRed = f;
								else if(c == 'g' || c == 'G') rhsGreen = f;
								else if(c == 'b' || c == 'B') rhsBlue = f;
							}
							
							break;
						}
						default:
							break;
					}
				}
			}
			
			CGFloat red = 0.0f;
			CGFloat green = 0.0f;
			CGFloat blue = 0.0f;
			
			switch(arithmeticOperator[0])
			{
				case '-':	red = lhsRed-rhsRed;	green = lhsGreen-rhsGreen;	blue = lhsBlue-rhsBlue;	break;
				case '+':	red = lhsRed+rhsRed;	green = lhsGreen+rhsGreen;	blue = lhsBlue+rhsBlue;	break;
				case '*':	red = lhsRed*rhsRed;	green = lhsGreen*rhsGreen;	blue = lhsBlue*rhsBlue;	break;
				default:	break;
			}
			
			// Clamp the RGB values within [0.0f, 1.0f]
			if(red < 0.0f) red = 0.0f;
			else if(red > 1.0f) red = 1.0f;
			
			if(green < 0.0f) green = 0.0f;
			else if(green > 1.0f) green = 1.0f;
			
			if(blue < 0.0f) blue = 0.0f;
			else if(blue > 1.0f) blue = 1.0f;
			
			return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0f];
		}
		else
		{
			return nil;
		}
	}
}

+ (NSColor*)colorWithColorTagString:(NSString*)string colorTagMap:(NSDictionary*)colorTagMap
{
	NSString *value = colorTagMap[string];
	if (value){
		if ([value hasPrefix:@"#"]){
			return [self colorWithHexColorTagString:string colorTagMap:colorTagMap];
		} else if ([value hasPrefix:@"rgb"]){
			return [self colorWithRGBAColorTagString:string colorTagMap:colorTagMap];
		}
		return nil;
	} else {
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((?:[a-zA-Z][a-zA-Z0-9_]*))" options:0 error:nil];
		NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
		if (matches.count > 0){
			NSTextCheckingResult *match = [matches firstObject];
			NSString *key = [string substringWithRange:match.range];
			value = colorTagMap[[NSString stringWithFormat:@"%%%@%%", key]];
			if ([value hasPrefix:@"#"]){
				return [self colorWithHexColorTagString:string colorTagMap:colorTagMap];
			} else if ([value hasPrefix:@"rgb"]){
				return [self colorWithRGBAColorTagString:string colorTagMap:colorTagMap];
			}
			return nil;
		}
		return nil;
	}
	
	
	return nil;
}

+ (NSColor*)colorWithHTMLColorString:(NSString*)string
{
	const char* cString = [string UTF8String];
	
	int red = 0;
	int green = 0;
	int blue = 0;
	
	const int numberOfScannedFields = sscanf(cString, "#%2X%2X%2X", &red, &green, &blue);
	
	const CGFloat normalisedRed = (CGFloat)red/255.0f;
	const CGFloat normalisedGreen = (CGFloat)green/255.0f;
	const CGFloat normalisedBlue = (CGFloat)blue/255.0f;
	
	if(numberOfScannedFields == 3)
	{
		return [NSColor colorWithCalibratedRed:normalisedRed green:normalisedGreen blue:normalisedBlue alpha:1.0f];
	}
	else
	{
		return nil;
	}
}

- (NSString*)htmlColorString
{
	NSColor* color = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	
	return [NSString stringWithFormat:@"#%0.2lX%0.2lX%0.2lX",
		(long)([color redComponent]*255),
		(long)([color greenComponent]*255),
		(long)([color blueComponent]*255)];
}

+ (NSColor *)colorWithRGBAColorString:(NSString *)string
{
	NSString *regularExpression = @"/(rgba?)|(\\d+(\\.\\d+)?%?)|(\\.\\d+)/g";
	
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpression options:NSRegularExpressionCaseInsensitive error:nil];
	NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
	
	if ([matches count] < 3){
		return nil;
	}
	
	NSString *redString = [string substringWithRange:[matches[0] range]];
	NSString *greenString = [string substringWithRange:[matches[1] range]];
	NSString *blueString = [string substringWithRange:[matches[2] range]];
	
	const CGFloat normalisedRed = (CGFloat)[redString floatValue]/255.0f;
	const CGFloat normalisedGreen = (CGFloat)[greenString floatValue]/255.0f;
	const CGFloat normalisedBlue = (CGFloat)[blueString floatValue]/255.0f;
	
	if ([matches count] == 4){ // RGBA
		
		NSString *alphaString = [string substringWithRange:[matches[3] range]];
		const CGFloat alpha = [alphaString floatValue];
		
		NSColor *color = [NSColor colorWithCalibratedRed:normalisedRed green:normalisedGreen blue:normalisedBlue alpha:alpha];
		return color;
		
	} else if ([matches count] == 3){ // RGB
		NSColor *color = [NSColor colorWithCalibratedRed:normalisedRed green:normalisedGreen blue:normalisedBlue alpha:1.0f];
		return color;
	} else {
		return nil;
	}
}

- (NSString *)rgbaColorString
{
	NSColor* color = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	return [NSString stringWithFormat:@"rgba(%0.f,%0.f,%0.f,%0.2f)",
			([color redComponent]*255),
			([color greenComponent]*255),
			([color blueComponent]*255),
			[color alphaComponent]];
}

@end
