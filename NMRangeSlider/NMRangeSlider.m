//
//  RangeSlider.m
//  RangeSlider
//
//  Created by Murray Hughes on 04/08/2012
//  Copyright 2011 Null Monkey Pty Ltd. All rights reserved.
//

#import "NMRangeSlider.h"

@interface NMRangeSlider ()
{
    float _lowerTouchOffset;
    float _upperTouchOffset;
    float _stepValueInternal;
    BOOL _haveAddedSubviews;
}

@property (retain, nonatomic) UIImageView* track;
@property (retain, nonatomic) UIImageView* trackBackground;
@property (retain, nonatomic) UIImageView* lowerHandle;
@property (retain, nonatomic) UIImageView* upperHandle;

@end

@implementation NMRangeSlider

#pragma mark -
#pragma mark - Constructors

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self configureView];
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self configureView];
    }
    
    return self;
}


- (void) configureView
{
    //Setup the default values
    _minimumValue = 0.0;
    _maximumValue = 1.0;
    _minimumRange = 0.0;
    _stepValue = 0.0;
    _stepValueInternal = 0.0;
    
    _continuous = YES;
    
    _lowerValue = 0.0;
    _upperValue = 1.0;
    
    _isVertical = NO;
    _useLabels = NO;
    
    _themeName = @"default";
}

// ------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark - Properties

- (CGPoint) lowerCenter
{
    return _lowerHandle.center;
}

- (CGPoint) upperCenter
{
    return _upperHandle.center;
}

- (void) setLowerValue:(float)lowerValue
{
    float value = lowerValue;
    
    if(_stepValueInternal>0)
    {
        value = roundf(value / _stepValueInternal) * _stepValueInternal;
    }
    
    value = MAX(value, _minimumValue);
    value = MIN(value, _upperValue - _minimumRange);
    
    _lowerValue = value;
    
    [self setNeedsLayout];
}

- (void) setUpperValue:(float)upperValue
{
    float value = upperValue;
    
    if(_stepValueInternal>0)
    {
        value = roundf(value / _stepValueInternal) * _stepValueInternal;
    }
    
    value = MIN(value, _maximumValue);
    value = MAX(value, _lowerValue+_minimumRange);
    
    _upperValue = value;
    
    [self setNeedsLayout];
}


- (void) setLowerValue:(float) lowerValue upperValue:(float) upperValue animated:(BOOL)animated
{
    if((!animated) && (isnan(lowerValue) || lowerValue==_lowerValue) && (isnan(upperValue) || upperValue==_upperValue))
    {
        //nothing to set
        return;
    }
    
    __block void (^setValuesBlock)(void) = ^ {
        
        if(!isnan(lowerValue))
        {
            [self setLowerValue:lowerValue];
        }
        if(!isnan(upperValue))
        {
            [self setUpperValue:upperValue];
        }
        
    };
    
    if(animated)
    {
        [UIView animateWithDuration:0.25  delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             setValuesBlock();
                             [self layoutSubviews];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
    }
    else
    {
        setValuesBlock();
    }
    
}

- (void)setLowerValue:(float)lowerValue animated:(BOOL) animated
{
    [self setLowerValue:lowerValue upperValue:NAN animated:animated];
}

- (void)setUpperValue:(float)upperValue animated:(BOOL) animated
{
    [self setLowerValue:NAN upperValue:upperValue animated:animated];
}

//ON-Demand images. If the images are not set, then the default values are loaded.

- (UIImage *)trackBackgroundImage
{
    if(_trackBackgroundImage==nil)
    {
        NSString *name = @"trackBackground";
        NSString *imageName = [NSString stringWithFormat:@"slider-%@-%@%@%@", _themeName, name, _isVertical ? @"-vertical" : @"", @""];
        UIImage* image = [UIImage imageNamed:imageName];
        if (_isVertical) {
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0)];
        }
        else {
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
        }
        
        _trackBackgroundImage = image;
    }
    
    return _trackBackgroundImage;
}

- (UIImage *)trackImage
{
    if(_trackImage==nil)
    {
        NSString *name = @"track";
        NSString *imageName = [NSString stringWithFormat:@"slider-%@-%@%@%@", _themeName, name, _isVertical ? @"-vertical" : @"", @""];
        UIImage* image = [UIImage imageNamed:imageName];
        if (_isVertical) {
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(7.0, 0.0, 7.0, 0.0)];
        }
        else {
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)];
        }
        _trackImage = image;
    }
    
    return _trackImage;
}

- (UIImage *)lowerHandleImageNormal
{
    if(_lowerHandleImageNormal==nil)
    {
        NSString *name = @"handle-lower";
        NSString *imageName = [NSString stringWithFormat:@"slider-%@-%@%@", _themeName, name, @""];
        UIImage* image = [UIImage imageNamed:imageName];
        _lowerHandleImageNormal = image;
    }
    
    return _lowerHandleImageNormal;
}

- (UIImage *)lowerHandleImageHighlighted
{
    if(_lowerHandleImageHighlighted==nil)
    {
        NSString *name = @"handle-lower";
        NSString *imageName = [NSString stringWithFormat:@"slider-%@-%@%@", _themeName, name, @"-highlighted"];
        UIImage* image = [UIImage imageNamed:imageName];
        //        UIImage* image = [UIImage imageNamed:@"slider-default-handle-highlighted"];
        _lowerHandleImageHighlighted = image;
    }
    
    return _lowerHandleImageHighlighted;
}

- (UIImage *)upperHandleImageNormal
{
    if(_upperHandleImageNormal==nil)
    {
        NSString *name = @"handle-upper";
        NSString *imageName = [NSString stringWithFormat:@"slider-%@-%@%@", _themeName, name, @""];
        UIImage* image = [UIImage imageNamed:imageName];
        //        UIImage* image = [UIImage imageNamed:@"slider-khm-handle-upper"];
        _upperHandleImageNormal = image;
    }
    
    return _upperHandleImageNormal;
}

- (UIImage *)upperHandleImageHighlighted
{
    if(_upperHandleImageHighlighted==nil)
    {
        NSString *name = @"handle-upper";
        NSString *imageName = [NSString stringWithFormat:@"slider-%@-%@%@", _themeName, name, @"-highlighted"];
        UIImage* image = [UIImage imageNamed:imageName];
        //        UIImage* image = [UIImage imageNamed:@"slider-khm-handle-upper-highlighted"];
        _upperHandleImageHighlighted = image;
    }
    
    return _upperHandleImageHighlighted;
}

// ------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Math Math Math

//Returns the lower value based on the X potion
//The return value is automatically adjust to fit inside the valid range
-(float) lowerValueForCenterX:(float)x
{
    float _padding = _lowerHandle.frame.size.width/2.0f;
    float value = _minimumValue + (x-_padding) / (self.frame.size.width-(_padding*2)) * (_maximumValue - _minimumValue);
    
    value = MAX(value, _minimumValue);
    value = MIN(value, _upperValue - _minimumRange);
    
    return value;
}

//Returns the lower value based on the Y potion
//The return value is automatically adjust to fit inside the valid range
-(float) lowerValueForCenterY:(float)y
{
    float _padding = _lowerHandle.frame.size.height/2.0f;
    float value = _minimumValue + (y-_padding) / (self.frame.size.height-(_padding*2)) * (_maximumValue - _minimumValue);
    
    value = MAX(value, _minimumValue);
    value = MIN(value, _upperValue - _minimumRange);
    
    return value;
}

//Returns the upper value based on the X potion
//The return value is automatically adjust to fit inside the valid range
-(float) upperValueForCenterX:(float)x
{
    float _padding = _upperHandle.frame.size.width/2.0;
    
    float value = _minimumValue + (x-_padding) / (self.frame.size.width-(_padding*2)) * (_maximumValue - _minimumValue);
    
    value = MIN(value, _maximumValue);
    value = MAX(value, _lowerValue+_minimumRange);
    
    return value;
}

//Returns the upper value based on the Y potion
//The return value is automatically adjust to fit inside the valid range
-(float) upperValueForCenterY:(float)y
{
    float _padding = _upperHandle.frame.size.height/2.0;
    
    float value = _minimumValue + (y-_padding) / (self.frame.size.height-(_padding*2)) * (_maximumValue - _minimumValue);
    
    value = MIN(value, _maximumValue);
    value = MAX(value, _lowerValue+_minimumRange);
    
    return value;
}

//returns the rect for the track image between the lower and upper values based on the trackimage object
- (CGRect)trackRect
{
    CGRect retValue;
    
    retValue.size = CGSizeMake(_trackImage.size.width, _trackImage.size.height);
    
    if(_trackImage.capInsets.top || _trackImage.capInsets.bottom)
    {
        retValue.size.height=self.bounds.size.height;
    }
    
    if (_isVertical) {
        float yLowerValue = ((self.bounds.size.height - _lowerHandle.frame.size.height) * (_lowerValue - _minimumValue) / (_maximumValue - _minimumValue))+(_lowerHandle.frame.size.height/2.0f);
        float yUpperValue = ((self.bounds.size.height - _upperHandle.frame.size.height) * (_upperValue - _minimumValue) / (_maximumValue - _minimumValue))+(_upperHandle.frame.size.height/2.0f);
        
        retValue.origin = CGPointMake((self.bounds.size.width/2.0f) - (retValue.size.width/2.0f), yLowerValue);
        retValue.size.height = yUpperValue-yLowerValue;
        
        return retValue;
    }
    else {
        float xLowerValue = ((self.bounds.size.width - _lowerHandle.frame.size.width) * (_lowerValue - _minimumValue) / (_maximumValue - _minimumValue))+(_lowerHandle.frame.size.width/2.0f);
        float xUpperValue = ((self.bounds.size.width - _upperHandle.frame.size.width) * (_upperValue - _minimumValue) / (_maximumValue - _minimumValue))+(_upperHandle.frame.size.width/2.0f);
        
        retValue.origin = CGPointMake(xLowerValue, (self.bounds.size.height/2.0f) - (retValue.size.height/2.0f));
        retValue.size.width = xUpperValue-xLowerValue;
        
        return retValue;
    }
}

//returns the rect for the background image
-(CGRect) trackBackgroundRect
{
    CGRect trackBackgroundRect;
    
    if (_isVertical) {
        trackBackgroundRect.size = CGSizeMake(_trackBackgroundImage.size.width, _trackBackgroundImage.size.height-4);
    }
    else {
        trackBackgroundRect.size = CGSizeMake(_trackBackgroundImage.size.width-4, _trackBackgroundImage.size.height);
    }
    
    if(_trackBackgroundImage.capInsets.top || _trackBackgroundImage.capInsets.bottom)
    {
        trackBackgroundRect.size.height=self.bounds.size.height - (_isVertical ? 4 : 0);
    }
    
    if(_trackBackgroundImage.capInsets.left || _trackBackgroundImage.capInsets.right)
    {
        trackBackgroundRect.size.width=self.bounds.size.width - (_isVertical ? 0 : 4);
    }
    
    if (_isVertical) {
        trackBackgroundRect.origin = CGPointMake((self.bounds.size.width/2.0f) - (trackBackgroundRect.size.width/2.0f), 2);
    }
    else {
        trackBackgroundRect.origin = CGPointMake(2, (self.bounds.size.height/2.0f) - (trackBackgroundRect.size.height/2.0f));
    }
    
    return trackBackgroundRect;
}

//returms the rect of the tumb image for a given track rect and value
- (CGRect)thumbRectForValue:(float)value image:(UIImage*) thumbImage
{
    CGRect thumbRect;
    UIEdgeInsets insets = thumbImage.capInsets;
    
    thumbRect.size = CGSizeMake(thumbImage.size.width, thumbImage.size.height);
    
    if (_isVertical) {
        if(insets.left || insets.right)
        {
            thumbRect.size.width=self.bounds.size.width;
        }
    }
    else {
        if(insets.top || insets.bottom)
        {
            thumbRect.size.height=self.bounds.size.height;
        }
    }
    
    if (_isVertical) {
        float yValue = ((self.bounds.size.height-thumbRect.size.height)*((value - _minimumValue) / (_maximumValue - _minimumValue)));
        thumbRect.origin = CGPointMake((self.bounds.size.width/2.0f) - (thumbRect.size.width/2.0f), yValue);
        
        return thumbRect;
    }
    else {
        float xValue = ((self.bounds.size.width-thumbRect.size.width)*((value - _minimumValue) / (_maximumValue - _minimumValue)));
        thumbRect.origin = CGPointMake(xValue, (self.bounds.size.height/2.0f) - (thumbRect.size.height/2.0f));
        
        return thumbRect;
    }
    
}

// ------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark - Layout


- (void) addSubviews
{
    //------------------------------
    // Track Brackground
    self.trackBackground = [[UIImageView alloc] initWithImage:self.trackBackgroundImage];
    self.trackBackground.frame = [self trackBackgroundRect];
    
    //------------------------------
    // Track
    self.track = [[UIImageView alloc] initWithImage:self.trackImage];
    self.track.frame = [self trackRect];
    
    //------------------------------
    // Lower Handle Handle
    self.lowerHandle = [[UIImageView alloc] initWithImage:self.lowerHandleImageNormal highlightedImage:self.lowerHandleImageHighlighted];
    self.lowerHandle.frame = [self thumbRectForValue:_lowerValue image:self.lowerHandleImageNormal];
    
    if (_useLabels) {
        _lowerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.lowerHandle.frame.size.width, self.lowerHandle.frame.size.height)];
        _lowerLabel.userInteractionEnabled = NO;
        _lowerLabel.textColor = [UIColor whiteColor];
        _lowerLabel.font = [UIFont systemFontOfSize:10];
        _lowerLabel.textAlignment = NSTextAlignmentRight;
        _lowerLabel.backgroundColor = [UIColor clearColor];
        _lowerLabel.text = [NSString stringWithFormat:@"%i", (int)_maximumValue - (int)_lowerValue];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(textForLowerLabelOfSlider:)]) {
            _lowerLabel.text = [self.delegate textForLowerLabelOfSlider:self];
        }

        [_lowerHandle addSubview:_lowerLabel];
    }
    
    //------------------------------
    // Upper Handle Handle
    self.upperHandle = [[UIImageView alloc] initWithImage:self.upperHandleImageNormal highlightedImage:self.upperHandleImageHighlighted];
    self.upperHandle.frame = [self thumbRectForValue:_upperValue image:self.upperHandleImageNormal];
    
    if (_useLabels) {
        _upperLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.upperHandle.frame.size.width, self.upperHandle.frame.size.height)];
        _upperLabel.userInteractionEnabled = NO;
        _upperLabel.textColor = [UIColor whiteColor];
        _upperLabel.font = [UIFont systemFontOfSize:10];
        _upperLabel.textAlignment = NSTextAlignmentLeft;
        _upperLabel.backgroundColor = [UIColor clearColor];
        _upperLabel.text = [NSString stringWithFormat:@"%i", (int)_maximumValue - (int)_upperValue];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(textForUpperLabelOfSlider:)]) {
            _upperLabel.text = [self.delegate textForUpperLabelOfSlider:self];
        }
        
        [_upperHandle addSubview:_upperLabel];
    }
    
    [self addSubview:self.trackBackground];
    [self addSubview:self.track];
    [self addSubview:self.lowerHandle];
    [self addSubview:self.upperHandle];
}


-(void)layoutSubviews
{
    if(_haveAddedSubviews==NO)
    {
        _haveAddedSubviews=YES;
        [self addSubviews];
    }
    
    
    self.trackBackground.frame = [self trackBackgroundRect];
    self.track.frame = [self trackRect];
    self.lowerHandle.frame = [self thumbRectForValue:_lowerValue image:self.lowerHandleImageNormal];
    self.upperHandle.frame = [self thumbRectForValue:_upperValue image:self.upperHandleImageNormal];
}


// ------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark - Touch handling

// The handle size can be a little small, so i make it a little bigger
// TODO: Do it the correct way. I think wwdc 2012 had a video on it...
- (CGRect) touchRectForHandle:(UIImageView*) handleImageView
{
    float xPadding = 20;
    float yPadding = 20; //(self.bounds.size.height-touchRect.size.height)/2.0f
    
    CGRect touchRect = handleImageView.frame;
    touchRect.origin.x -= xPadding/2.0;
    touchRect.origin.y -= yPadding/2.0;
    touchRect.size.height += xPadding;
    touchRect.size.width += yPadding;
    return touchRect;
}

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    
    
    //Check both buttons upper and lower thumb handles because
    //they could be on top of each other.
    
    if(CGRectContainsPoint([self touchRectForHandle:_lowerHandle], touchPoint))
    {
        _lowerHandle.highlighted = YES;
        _lowerTouchOffset = _isVertical ? touchPoint.y - _lowerHandle.center.y : touchPoint.x - _lowerHandle.center.x;
    }
    
    if(CGRectContainsPoint([self touchRectForHandle:_upperHandle], touchPoint))
    {
        _upperHandle.highlighted = YES;
        _upperTouchOffset = _isVertical ? touchPoint.y - _upperHandle.center.y : touchPoint.x - _upperHandle.center.x;
    }
    
    _stepValueInternal= _stepValueContinuously ? _stepValue : 0.0f;
    
    return YES;
}


-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(!_lowerHandle.highlighted && !_upperHandle.highlighted ){
        return YES;
    }
    
    CGPoint touchPoint = [touch locationInView:self];
    
    if(_lowerHandle.highlighted)
    {
        //get new lower value based on the touch location.
        //This is automatically contained within a valid range.
        float newValue;
        if (_isVertical) {
            newValue = [self lowerValueForCenterY:(touchPoint.y - _lowerTouchOffset)];
        }
        else {
            newValue = [self lowerValueForCenterX:(touchPoint.x - _lowerTouchOffset)];
        }
        
        //if both upper and lower is selected, then the new value must be LOWER
        //otherwise the touch event is ignored.
        if(!_upperHandle.highlighted || newValue<_lowerValue)
        {
            _upperHandle.highlighted=NO;
            [self bringSubviewToFront:_lowerHandle];
            
            [self setLowerValue:newValue animated:_stepValueContinuously ? YES : NO];
        }
        else
        {
            _lowerHandle.highlighted=NO;
        }
    }
    
    if(_upperHandle.highlighted )
    {
        float newValue;
        if (_isVertical) {
            newValue = [self upperValueForCenterY:(touchPoint.y - _upperTouchOffset)];
        }
        else {
            newValue = [self upperValueForCenterX:(touchPoint.x - _upperTouchOffset)];
        }
        
        //if both upper and lower is selected, then the new value must be HIGHER
        //otherwise the touch event is ignored.
        if(!_lowerHandle.highlighted || newValue>_upperValue)
        {
            _lowerHandle.highlighted=NO;
            [self bringSubviewToFront:_upperHandle];
            [self setUpperValue:newValue animated:_stepValueContinuously ? YES : NO];
        }
        else
        {
            _upperHandle.highlighted=NO;
        }
    }
    
    
    //send the control event
    if(_continuous)
    {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    //redraw
    [self setNeedsLayout];
    
    return YES;
}



-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _lowerHandle.highlighted = NO;
    _upperHandle.highlighted = NO;
    
    if(_stepValue>0)
    {
        _stepValueInternal=_stepValue;
        
        [self setLowerValue:_lowerValue animated:YES];
        [self setUpperValue:_upperValue animated:YES];
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
