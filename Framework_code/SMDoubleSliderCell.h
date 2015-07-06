/*!	@header	SMDoubleSliderCell.h
    @discussion
    This is subclass of NSSliderCell that supports two knobs - a low knob and a high knob.  The user
    can set either knob in the range of the slider, as long as the low knob is always lower
    in value than the high knob.

SMDoubleSlider Copyright (c) 2003-2008, Snowmint Creative Solutions LLC http://www.snowmintcs.com/
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

¥ Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
¥ Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
¥ Neither the name of Snowmint Creative Solutions LLC nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <AppKit/AppKit.h>

/*!	@class		SMDoubleSliderCell
    @discussion	This subclass of NSSliderCell has two knobs - a low knob and a high knob.  The user
                can set either knob in the range of the slider, as long as the low knob is always lower
                in value than the high knob.
*/
@interface SMDoubleSliderCell : NSSliderCell

//@property (nonatomic) CGFloat minValue;
//@property (nonatomic) CGFloat maxValue;

/*!	@method		trackingLoKnob
    @discussion	Are we tracking on the low knob or the high knob?  The end user can change this by clicking on
                one knob or the other, or by using the tab key to cycle through the knobs.

    @result	YES if the double slider is tracking on the low knob.
*/

- (BOOL)trackingLoKnob;

/*!	@method		setTrackingLoKnob:
    @discussion	Are we tracking on the low knob or the high knob?  Note that the end user can change this by
                clicking on one knob or the other, or by using the tab key to cycle through the knobs.

    @param	inValue		YES if you want to track on the low knob.
*/
- (void)setTrackingLoKnob:(BOOL)inValue;

/*!	@method		lockedSliders
    @discussion	Determine if the two sliders are locked together.  The low and high knobs will always have
                the same value if this is true.  The end user can not change this setting at run time.

                <b>NOTE: This value is currently saved, but the locking behavior is unimplemented.</b>
    @result	YES if the two knobs are locked together.
*/

- (BOOL)lockedSliders;
/*!	@method		setLockedSliders:
    @discussion	Lock the two sliders together, so it functions just like a normal NSSlider.  The low and high
                knobs will have the same value.  The end user can not change this setting at run time.

                The low knob value gets set to the high knob value immediately.

                <b>NOTE: This value is currently saved, but the locking behavior is unimplemented.</b>
    @param	inLocked	YES if you want to lock the two knobs together.
*/
- (void)setLockedSliders:(BOOL)inLocked;

- (void)setIntHiValue:(int)anInt;
- (void)setDoubleHiValue:(double)aFloat;
- (int)intHiValue;
- (double)doubleHiValue;
- (void)setIntLoValue:(int)anInt;
- (void)setDoubleLoValue:(double)aFloat;
- (int)intLoValue;
- (double)doubleLoValue;

@end
