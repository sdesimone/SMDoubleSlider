//
//  SMDoubleSliderCell.m
//
//SMDoubleSlider Copyright (c) 2003-2008, Snowmint Creative Solutions LLC http://www.snowmintcs.com/
//All rights reserved.
//
//Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//• Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//• Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//• Neither the name of Snowmint Creative Solutions LLC nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <AppKit/AppKit.h>

#import "SMDoubleSliderCell.h"
#import "SMDoubleSlider.h"

@interface SMDoubleSliderCell ()

    @property (nonatomic) BOOL trackingLoKnob;

    - (NSRect)_sm_loKnobRect;

@end

@implementation SMDoubleSliderCell {

    double	_lowValue;
    struct {
        unsigned char	lockedSliders : 1;
        unsigned char	mouseTrackingSwapped : 1;
        unsigned char	removeFocusRingStyle : 1;
    } _sm_flags;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    BOOL tempBool;
    if (self = [super initWithCoder:aDecoder]) {
		if ([aDecoder allowsKeyedCoding])
		{
			_lowValue = [ aDecoder decodeDoubleForKey:@"loValue" ];
			tempBool = [ aDecoder decodeBoolForKey:@"lockedSliders" ];
		}
		else
		{
			[ aDecoder decodeValueOfObjCType:@encode(double) at:&_lowValue ];
			[ aDecoder decodeValueOfObjCType:@encode(BOOL) at:&tempBool ];
		}
 
		_sm_flags.lockedSliders = tempBool;

		// Make sure our value is between min and max.
		if ( [ self minValue ] > _lowValue )
			_lowValue = [ self minValue ];
		if ( [ self maxValue ] < _lowValue )
			_lowValue = [ self maxValue ];

		self.trackingLoKnob = YES;
	}
	
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    BOOL	tempBool;

    [ super encodeWithCoder:aCoder ];

	tempBool = _sm_flags.lockedSliders;

	if ( [ aCoder allowsKeyedCoding ] )
	{
		[ aCoder encodeDouble:_lowValue forKey:@"loValue" ];
		[ aCoder encodeBool:tempBool forKey:@"lockedSliders" ];
	}
	else
	{
		[ aCoder encodeValueOfObjCType:@encode(double) at:&_lowValue ];
		[ aCoder encodeValueOfObjCType:@encode(BOOL) at:&tempBool ];
	}
}

- (id)copyWithZone:(NSZone *)zone {
    
    SMDoubleSliderCell* copy = [ super copyWithZone:zone ];
    [ copy setDoubleLoValue:[self doubleLoValue]];
    [ copy setLockedSliders:[self lockedSliders]];
    return copy;
}

- (void)setMinValue:(double)aDouble {
    
    if ( [ self doubleLoValue ] < aDouble )
        [ self setDoubleLoValue:aDouble ];
    if ( [ self doubleHiValue ] < aDouble )
        [ self setDoubleHiValue:aDouble ];
    [super setMinValue:aDouble];
}

- (void)setMaxValue:(double)aDouble {
    
    if ( [ self doubleLoValue ] > aDouble )
        [ self setDoubleLoValue:aDouble ];
    if ( [ self doubleHiValue ] > aDouble )
        [ self setDoubleHiValue:aDouble ];
    [super setMaxValue:aDouble];
}

- (double)valueToPercent:(double)value {
    
    return (value  - [self minValue])/ ([self maxValue] - [self minValue]);
}
- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped {

    [NSGraphicsContext saveGraphicsState];
    
    NSImage* knobImage = [NSImage imageNamed:@"slider-default7-handle"];
    NSImage* fillImage = [NSImage imageNamed:@"slider-default7-fill"];
    
    NSImage* greyFillImage = [NSImage imageNamed:@"slider-default7-greyFill"];
    NSImage* leftCapImage = [NSImage imageNamed:@"slider-default7-greyLeftCap"];
    NSImage* rightCapImage = [NSImage imageNamed:@"slider-default7-greyRightCap"];
    
    CGRect bounds = aRect;
    CGFloat value = [self valueToPercent:[self doubleHiValue]];
    CGFloat lowValue = [self valueToPercent:[self doubleLoValue]];
    
    NSLog(@"KNOB %f", [knobImage size].width);
    NSLog(@"KNOB %f", [knobImage size].height);
    CGRect leftRect = CGRectMake([knobImage size].width / 2,
                                 (bounds.size.height - [fillImage size].height) / 2 + bounds.origin.y,
                                 lowValue * (bounds.size.width - [knobImage size].width),
                                 [fillImage size].height);

    CGFloat b = leftRect.origin.x + leftRect.size.width;
    CGRect middleRect = CGRectMake(b,
                                 (bounds.size.height - [fillImage size].height) / 2 + bounds.origin.y,
                                 (value - lowValue) * (bounds.size.width - [knobImage size].width),
                                 [fillImage size].height);

    CGFloat o = middleRect.origin.x + middleRect.size.width;
    CGRect rightRect = CGRectMake(o,
                                  (bounds.size.height - [fillImage size].height) / 2  + bounds.origin.y,
                                  (1 - value) * (bounds.size.width - [knobImage size].width),
                                  [fillImage size].height);
    
    if (rightRect.size.width < 0)
        rightRect.size.width = 0;
    
    NSDrawThreePartImage(CGRectIntegral(leftRect), leftCapImage, greyFillImage, nil, !flipped, NSCompositeSourceOver, 1.0, YES);
    [fillImage drawInRect:middleRect];
    NSDrawThreePartImage(CGRectIntegral(rightRect), nil, greyFillImage, rightCapImage, !flipped, NSCompositeSourceOver, 1.0, YES);
//
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawKnob
{
    NSRect loKnobRect = [self _sm_loKnobRect];
    [self drawKnob:loKnobRect];
    
    [super drawKnob];
}

- (void)drawKnob:(NSRect)inRect
{
    [NSGraphicsContext saveGraphicsState];
    
    NSImage* knobImage = [NSImage imageNamed:@"slider-default7-handle"];
    NSSize knobSize = knobImage.size;
    NSLog(@"size: %f", knobSize.width);
    NSRect knobRect = (NSRect){ { inRect.origin.x - (inRect.size.width - knobSize.width) / 2},
        { knobSize.width, inRect.size.height} };
//    [knobImage drawInRect:inRect];
    [knobImage drawInRect:knobRect
             fromRect:NSZeroRect
            operation:NSCompositeSourceOver
             fraction:0.5];

    [NSGraphicsContext restoreGraphicsState];
}

// Mouse tracking doesn't use the accessor methods for the value.
// That means, we need to do some hocus pocus here to make it work right.
- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
    NSLog(@"Tracking Knob %@ (%f)", NSStringFromPoint(startPoint), _lowValue);

    NSRect loKnobRect = [self _sm_loKnobRect];
    if ([self isVertical]) {
        if ([controlView isFlipped])
            [self setTrackingLoKnob:(startPoint.y > loKnobRect.origin.y)];
        else
            [self setTrackingLoKnob:(startPoint.y < loKnobRect.origin.y +
                        loKnobRect.size.height ) ];
    } else {
        NSRect hiKnobRect = [ self knobRectFlipped:[ [ self controlView ] isFlipped ] ];
        [self setTrackingLoKnob:( (startPoint.x - (loKnobRect.origin.x + loKnobRect.size.width) ) < (hiKnobRect.origin.x - startPoint.x) ) ];
    }
    
    // Make sure that the user hasn't jammed both knobs up against the minimum value.
    if ( [ self trackingLoKnob ] && NSEqualRects( loKnobRect,
                [ self knobRectFlipped:[ controlView isFlipped ] ] ) )
        [ self setTrackingLoKnob:( _lowValue > [ self minValue ] ) ];

    // Make sure that the entire lo knob gets erased if it's moved the first time.
    if ([self trackingLoKnob]) {
        [controlView setNeedsDisplayInRect:loKnobRect];
        return YES;
    } else {
        return [super startTrackingAt:startPoint inView:controlView];
    }
}

- (double)locationToDouble:(NSPoint)location {
    
    double delta = [self knobIconDelta];
    return (self.maxValue - self.minValue) * (location.x - delta/2) / ([self controlView].bounds.size.width - delta);
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView {
    
    BOOL result = YES;
    
    double newValue = [self locationToDouble:currentPoint];
    if ([self trackingLoKnob]) {

        [controlView setNeedsDisplayInRect:[self _sm_loKnobRect]];
        if (newValue < self.minValue || newValue >= self.doubleHiValue) {
            if (newValue < self.minValue)
                _lowValue = self.minValue;
            if (newValue >= self.doubleHiValue)
                _lowValue = self.doubleHiValue;
            [controlView setNeedsDisplayInRect:[self _sm_loKnobRect]];
        } else {
            self.doubleLoValue = newValue;
        }
        [controlView setNeedsDisplayInRect:[self _sm_loKnobRect]];
        return YES;

    } else {
        if (newValue < [self doubleLoValue]) {
            self.doubleHiValue = self.doubleLoValue;
            return YES;
        }
        result = [super continueTracking:currentPoint at:currentPoint inView:controlView];
    }

    return result;
}

//- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
//{
//    [ super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag ];
//}

#pragma mark -

//- (BOOL)trackingLoKnob
//{
//    return _sm_flags.isTrackingLoKnob;
//}
//
//- (void)setTrackingLoKnob:(BOOL)inValue
//{
//    if ( _sm_flags.isTrackingLoKnob != inValue )
//    {
//        _sm_flags.isTrackingLoKnob = inValue;
//        [ (NSControl *)[ self controlView ] updateCell:self ];
//    }
//}

- (BOOL)lockedSliders
{
    return _sm_flags.lockedSliders;
}

- (void)setLockedSliders:(BOOL)inLocked
{
    if ( _sm_flags.lockedSliders != inLocked )
    {
        _sm_flags.lockedSliders = inLocked;

        if ( inLocked )
            [ self setDoubleLoValue:[ self doubleHiValue ] ];

        [ (NSControl *)[ self controlView ] updateCell:self ];
    }
}

#pragma mark -

- (int)intValue
{
    if ( [ self trackingLoKnob ] )
        return [ self intLoValue ];
    else
        return [ self intHiValue ];
}

- (double)doubleValue
{
    if ( [ self trackingLoKnob ] )
        return [ self doubleLoValue ];
    else
        return [ self doubleHiValue ];
}

- (void)setIntValue:(int)anInt
{
    if ( [ self trackingLoKnob ] )
        [ self setIntLoValue:anInt ];
    else
        [ self setIntHiValue:anInt ];
}

- (void)setDoubleValue:(double)aFloat
{
    if ( [ self trackingLoKnob ] )
        [ self setDoubleLoValue:aFloat ];
    else
        [ self setDoubleHiValue:aFloat ];
}

#pragma mark -

- (double)doubleHiValue {
    
//    if ( _sm_flags.mouseTrackingSwapped )
//        return _sm_saveValue;
//    else
        return [ super doubleValue ];
}

- (void)setDoubleHiValue:(double)aDouble {
    
    if ( aDouble < [ self doubleLoValue ] )
        aDouble = [ self doubleLoValue ];
    if ( aDouble > [ self maxValue ] )
        aDouble = [ self maxValue ];

//    if ( _sm_flags.mouseTrackingSwapped )
//    {
//        _sm_saveValue = aDouble;
//        [ (NSControl *)[ self controlView ] updateCell:self ];
//    }
//    else
        [ super setDoubleValue:aDouble ];
}

- (int)intHiValue
{
    return (int)[ self doubleHiValue ];
}

- (void)setIntHiValue:(int)anInt
{
    [ self setDoubleHiValue:anInt ];
}

- (float)floatHiValue
{
    return (float)[ self doubleHiValue ];
}

- (void)setFloatHiValue:(float)aFloat
{
    [ self setDoubleHiValue:aFloat ];
}

#pragma mark -

- (double)doubleLoValue {
    return _lowValue;
}

- (void)setDoubleLoValue:(double)aDouble {
    
    if ( aDouble > [ self doubleHiValue ] )
        aDouble = [ self doubleHiValue ];
    if ( aDouble < [ self minValue ] )
        aDouble = [ self minValue ];

    _lowValue = aDouble;
    [ (NSControl *)[ self controlView ] updateCell:self ];
}

- (int)intLoValue {
    return (int)[ self doubleLoValue ];
}

- (void)setIntLoValue:(int)anInt {
    [self setDoubleLoValue:anInt];
}

#pragma mark -

- (CGFloat)knobIconDelta {
    NSImage* knobImage = [NSImage imageNamed:@"slider-default7-handle"];
    return ([knobImage size].width / 2);
}

- (NSRect)_sm_loKnobRect {

    NSRect loKnobRect = [self knobRectFlipped:[[self controlView] isFlipped]];
    loKnobRect.origin.x = _lowValue * ([self controlView].bounds.size.width - loKnobRect.size.width) / (self.maxValue - self.minValue);

    return loKnobRect;
}

@end
