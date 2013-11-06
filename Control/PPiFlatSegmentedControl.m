//
//  PPiFlatSwitch.m
//  PPiFlatSwitch
//
//  Created by Pedro Piñera Buendía on 12/08/13.
//  Copyright (c) 2013 PPinera. All rights reserved.
//

#import "PPiFlatSegmentedControl.h"

@interface PPiFlatSegmentedControl()
@property (nonatomic,strong) NSMutableArray *segments;
@property (nonatomic,strong) NSMutableArray *separators;
@property (nonatomic,strong) NSMutableDictionary *textColors;
@property (nonatomic,strong) NSMutableDictionary *selectedTextColors;
@property (nonatomic,strong) NSMutableDictionary *selectedColors;
@property (nonatomic,copy) selectionBlock selBlock;
@end


@implementation PPiFlatSegmentedControl
@synthesize segments=_segments;
@synthesize textColors=_textColors;
@synthesize selectedTextColors=_selectedTextColors;
@synthesize selectedColor=_selectedColor;
@synthesize color=_color;
@synthesize textColor=_textColor;
@synthesize selectedTextColor=_selectedTextColor;
@synthesize borderColor=_borderColor;
@synthesize currentSelected=_currentSelected;
@synthesize textFont=_textFont;
@synthesize separators=_separators;
@synthesize borderWidth=_borderWidth;
@synthesize cornerRadius=_cornerRadius;
@synthesize selBlock=_selBlock;
@synthesize textAttributes=_textAttributes;
@synthesize selectedTextAttributes=_selectedTextAttributes;

/**
 *  Method for initialize PPiFlatSegmentedControl
 *
 *  @param  frame   CGRect for segmented frame
 *  @param  items   List of NSString items for each segment
 *  @param  block   Block called when the user has selected another segment
 *
 *  @return Instantiation of PPiFlatSegmentedControl
 */
- (id)initWithFrame:(CGRect)frame andItems:(NSArray*)items andSelectionBlock:(selectionBlock)block{
    self = [super initWithFrame:frame];
    if (self) {
        //Selection block
        _selBlock=block;
        
        //Background Color
        self.backgroundColor=[UIColor clearColor];
        
        //Generating segments
        float buttonWith=frame.size.width/items.count;
        int i=0;
        for(NSString *item in items){
            UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
            button.frame=CGRectMake(buttonWith*i, 0, buttonWith, frame.size.height);
            [button setTitle:item forState:UIControlStateNormal];
            [button setTitle:item forState:UIControlStateHighlighted];
            [button.titleLabel setAdjustsFontSizeToFitWidth:YES];
            [button.titleLabel setAdjustsLetterSpacingToFitWidth:YES];
            [button.titleLabel setMinimumScaleFactor:0.5];
            [button setContentEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
            [button addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventTouchUpInside];
            
            //Adding to self view
            [self.segments addObject:button];
            [self addSubview:button];
            
            
            //Adding separator
            if(i!=0){
                UIView *separatorView=[[UIView alloc] initWithFrame:CGRectMake(i*buttonWith, 0, self.borderWidth, frame.size.height)];
                [self addSubview:separatorView];
                [self.separators addObject:separatorView];
            }
            
            i++;
        }
        
        //Applying corners
        self.layer.masksToBounds=YES;
        
        //Default selected 0
        _currentSelected=-1;
    }
    return self;
}
#pragma mark - Lazy instantiations
-(NSMutableArray*)segments{
    if(!_segments)_segments=[[NSMutableArray alloc] init];
    return _segments;
}
-(NSMutableArray*)separators{
    if(!_separators)_separators=[[NSMutableArray alloc] init];
    return _separators;
}
-(NSMutableDictionary*)textColors{
    if(!_textColors)_textColors=[[NSMutableDictionary alloc] init];
    return _textColors;
}
-(NSMutableDictionary*)selectedTextColors{
    if(!_selectedTextColors)_selectedTextColors=[[NSMutableDictionary alloc] init];
    return _selectedTextColors;
}
-(NSMutableDictionary*)selectedColors{
    if(!_selectedColors)_selectedColors=[[NSMutableDictionary alloc] init];
    return _selectedColors;
}
#pragma mark - Actions
-(void)segmentSelected:(id)sender{
    if(sender){
        NSInteger previousIndex = _currentSelected;
        NSUInteger selectedIndex=[self.segments indexOfObject:sender];
        
        [self setEnabled:YES forSegmentAtIndex:selectedIndex];
        
        //Calling block
        if(self.selBlock){
            self.selBlock(selectedIndex, previousIndex);
        }
    }
}
#pragma mark - Getters
/**
 *  Returns if a specified segment is selected
 *
 *  @param  index   Index of segment to check
 *
 *  @return BOOL selected
 */
-(BOOL)isEnabledForSegmentAtIndex:(NSUInteger)index{
    return (index==self.currentSelected);
}

#pragma mark - Setters
-(void)updateSegmentsFormat{
    //Setting border color
    if(self.borderColor){
        self.layer.borderWidth=self.borderWidth;
        self.layer.borderColor=self.borderColor.CGColor;
    }else{
        self.layer.borderWidth=0;
    }
    
    //setting corner radius
    if ( _cornerRadius ) {
        self.layer.cornerRadius = _cornerRadius;
    }
    
    //Updating segments color
    for(UIView *separator in self.separators){
        separator.backgroundColor=self.borderColor;
        separator.frame=CGRectMake(separator.frame.origin.x, separator.frame.origin.y,self.borderWidth , separator.frame.size.height);
    }
    
    //Modifying buttons with current State
    int i = 0;
    for (UIButton *segment in self.segments){
        [segment.titleLabel setFont:self.textFont];
        if([self.segments indexOfObject:segment]==self.currentSelected){
            //Selected-one
            UIColor *customSelectedColor = [self.selectedColors objectForKey:[NSNumber numberWithInt:i]];
            if ( customSelectedColor )
                [segment setBackgroundColor:customSelectedColor];
            else if ( self.selectedColor )
                [segment setBackgroundColor:self.selectedColor];
            
            UIColor *customColor =[self.selectedTextColors objectForKey:[NSNumber numberWithInt:i]];
            if ( customColor ) {
                [segment setTitleColor:customColor forState:UIControlStateNormal];
                [segment setTitleColor:customColor forState:UIControlStateHighlighted];
                
            }
            else if ( self.selectedTextColor ) {
                [segment setTitleColor:self.selectedTextColor forState:UIControlStateNormal];
            }
            
            if(self.selectedTextAttributes)
                [segment.titleLabel setValuesForKeysWithDictionary:self.selectedTextAttributes];
        }else{
            //Non selected
            if(self.color)[segment setBackgroundColor:self.color];
            
            UIColor *customColor =[self.textColors objectForKey:[NSNumber numberWithInt:i]];
            if ( customColor ) {
                [segment setTitleColor:customColor forState:UIControlStateNormal];
                [segment setTitleColor:customColor forState:UIControlStateHighlighted];

            }
            else if ( self.textColors ) {
                [segment setTitleColor:self.textColor forState:UIControlStateNormal];
                [segment setTitleColor:self.textColor forState:UIControlStateHighlighted];
            }

            if(self.textAttributes)
                [segment.titleLabel setValuesForKeysWithDictionary:self.textAttributes];
        }
        segment.titleLabel.textAlignment = NSTextAlignmentCenter;
        i++;
    }
}
-(void)setSelectedColor:(UIColor *)selectedColor{
    _selectedColor=selectedColor;
    [self updateSegmentsFormat];
}
-(void)setColor:(UIColor *)color{
    _color=color;
    [self updateSegmentsFormat];
}
-(void)setTextColor:(UIColor *)textColor{
    _textColor=textColor;
    [self updateSegmentsFormat];
}
-(void)setSelectedTextColor:(UIColor *)selectedTextColor{
    _selectedTextColor=selectedTextColor;
    [self updateSegmentsFormat];
}
-(void)setBorderWidth:(CGFloat)borderWidth{
    _borderWidth=borderWidth;
    [self updateSegmentsFormat];
}
-(void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius=cornerRadius;
    [self updateSegmentsFormat];
}

/**
 *  Using this method name of a specified segmend can be changed
 *
 *  @param  title   Title to be applied to the segment
 *  @param  index   Index of the segment that has to be modified
 */

-(void)setTitle:(id)title forSegmentAtIndex:(NSUInteger)index{
    //Getting the Segment
    if(index<self.segments.count){
        UIButton *segment=self.segments[index];
        if([title isKindOfClass:[NSString class]]){
            [segment setTitle:title forState:UIControlStateNormal];
        }else if ([title isKindOfClass:[NSAttributedString class]]){
            [segment setAttributedTitle:title forState:UIControlStateNormal];
        }
    }
}

- (void)setTextColor:(UIColor *)color forSegmentAtIndex:(NSUInteger)index {
    if ( index < self.segments.count ) {
        [self.textColors setObject:color forKey:[NSNumber numberWithInteger:index]];
        [self updateSegmentsFormat];
    }
}
- (void)removeCustomTextColorForSegmentAtIndex:(NSUInteger)index {
    if ( index < self.segments.count ) {
        [self.textColors removeObjectForKey:[NSNumber numberWithInteger:index]];
        [self updateSegmentsFormat];
    }
}

- (void)setSelectedTextColor:(UIColor *)color forSegmentAtIndex:(NSUInteger)index {
    if ( index < self.segments.count ) {
        [self.selectedTextColors setObject:color forKey:[NSNumber numberWithInteger:index]];
        [self updateSegmentsFormat];
    }
}
- (void)removeCustomSelectedTextColorForSegmentAtIndex:(NSUInteger)index {
    if ( index < self.segments.count ) {
        [self.selectedTextColors removeObjectForKey:[NSNumber numberWithInteger:index]];
        [self updateSegmentsFormat];
    }
}

- (void)setSelectedColor:(UIColor *)color forSegmentAtIndex:(NSUInteger)index {
    if ( index < self.segments.count ) {
        [self.selectedColors setObject:color forKey:[NSNumber numberWithInteger:index]];
        [self updateSegmentsFormat];
    }
}
- (void)removeCustomSelectedColorForSegmentAtIndex:(NSUInteger)index {
    if ( index < self.segments.count ) {
        [self.selectedColors removeObjectForKey:[NSNumber numberWithInteger:index]];
        [self updateSegmentsFormat];
    }
}

-(void)setTextFont:(UIFont *)textFont{
    _textFont=textFont;
    [self updateSegmentsFormat];
}
-(void)setBorderColor:(UIColor *)borderColor{
    //Setting boerder color to all view
    _borderColor=borderColor;
    [self updateSegmentsFormat];
}
/**
 *  Method for select/unselect a segment
 *
 *  @param  enabled BOOL if the given segment has to be enabled/disabled ( currently disable option is not enabled )
 *  @param  segment Segment to be selected/unselected
 */
-(void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment{
    if(enabled){
        self.currentSelected=segment;
        [self updateSegmentsFormat];
    }
}
-(void)setTextAttributes:(NSDictionary *)textAttributes{
    _textAttributes=textAttributes;
    [self updateSegmentsFormat];
}
-(void)setSelectedTextAttributes:(NSDictionary *)selectedTextAttributes{
    _selectedTextAttributes=selectedTextAttributes;
    [self updateSegmentsFormat];
}
@end


/*
 // Create the path (with only the top-left corner rounded)
 UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds byRoundingCorners:UIRectCornerTopLeft| UIRectCornerTopRight                                                         cornerRadii:CGSizeMake(10.0, 10.0)];
 // Create the shape layer and set its path
 CAShapeLayer *maskLayer = [CAShapeLayer layer];
 maskLayer.frame = imageView.bounds;
 maskLayer.path = maskPath.CGPath;
 // Set the newly created shape layer as the mask for the image view's layer
 imageView.layer.mask = maskLayer;*/
