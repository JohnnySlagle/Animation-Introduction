//
//  JSViewController.m
//  AnimationIntroduction
//
//  Created by Johnny Slagle on 6/29/12.
//  Copyright (c) Johnny Slagle. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "JSViewController.h"

#define UIColorFromRGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

#define BarButtonNormalTransitionString @"Normal Transitions"
#define BarButtonRandomTransitionString @"Random Transitions"

// Change this if you just want the animation to flip from left to right
#define JSRandomTransitions TRUE   

@interface JSViewController ()

@end

@implementation JSViewController
{
    UIView * frontView;
    UIView * backView;
    UIView * containerView;
    BOOL displayingFront;
    BOOL randomTransition;
}

#pragma mark -
#pragma mark View Lifespan
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ViewController's BG color
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    // Set transition boolean default
    randomTransition = NO;
    
    // Set transition setting bar button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BarButtonNormalTransitionString style:UIBarButtonItemStyleBordered target:self action:@selector(switchTransitionStyle)];
    
    // Note:
    //  I create a containerView because when the the views transition the superview 
    //  of the transitioning views would do the transition.
    
    //  So if I added them directly to the JSViewController's view, then the ViewController
    //  would flip the whole screen, which isn't what we want.  
    
    //  By putting the the two views in a container view, the the flip feels seemless.
    
    /* Container View */    
    containerView = [[UIView alloc] initWithFrame:self.view.frame];
    
    // These autoresizingMasks keep the views centered as the device rotates
    containerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;    
    
    /* Front View */
    frontView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 200.0f)];
    frontView.center = self.view.center;
    
    // The following require the "<QuartzCore/QuartzCore.h>" framework
    frontView.layer.cornerRadius = 10.0f;
    
    frontView.layer.borderColor = [UIColor whiteColor].CGColor;
    frontView.layer.borderWidth = 10.0f;
    
    frontView.layer.shadowOffset = CGSizeMake(0, 5);
    frontView.layer.shadowRadius = 5;
    frontView.layer.shadowOpacity = 0.5;
    
    
    /* Front View Gradient */
    
    // Colors
    UIColor * frontStarColor = UIColorFromRGB(139, 171, 141);
    UIColor * frontEndColor = UIColorFromRGB(87, 107, 88);
    
    // Gradient Layer
    CAGradientLayer *gradientFront = [CAGradientLayer layer];
    gradientFront.frame = frontView.bounds;
    gradientFront.colors = [NSArray arrayWithObjects:(id)[frontStarColor CGColor], (id)[frontEndColor CGColor], nil];
    [frontView.layer insertSublayer:gradientFront atIndex:0];
    
    // Do this so the gradient conforms to the rounded corners
    frontView.layer.masksToBounds = YES;
    
    
    /* Back View */    
    backView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 200.0f)];
    backView.center = self.view.center;
    
    backView.layer.cornerRadius = 10.0f;  
    
    backView.layer.borderColor = [UIColor whiteColor].CGColor;
    backView.layer.borderWidth = 10.0f;
    
    backView.layer.shadowOffset = CGSizeMake(0, 5);
    backView.layer.shadowRadius = 5;
    backView.layer.shadowOpacity = 0.5;
    
    // The back view starts initially hidden to make sure it isn't seen at all.
    // It might work one way and not th eother because it depends on the order 
    // the subviews are added to the containerView.
    backView.alpha = 0.0f;
    
    UIColor * backStartColor = UIColorFromRGB(150, 82, 107);
    UIColor * backEndColor = UIColorFromRGB(87, 47, 62);
    
    /* Back View Gradient */
    CAGradientLayer *gradientBack = [CAGradientLayer layer];
    gradientBack.frame = frontView.bounds;
    gradientBack.colors = [NSArray arrayWithObjects:(id)[backStartColor CGColor], (id)[backEndColor CGColor], nil];
    [backView.layer insertSublayer:gradientBack atIndex:0];
    
    backView.layer.masksToBounds = YES;
    
    // BOOL to know how the flip animation should act
    displayingFront = YES;
    
    // Start the Container View Hidden
    containerView.alpha = 0.0f;
    
    [containerView addSubview:backView];
    [containerView addSubview:frontView];
    
    [self.view addSubview:containerView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Do Start Animation
    [self fadeInView:containerView];
}

#pragma mark -
#pragma mark Button Selector
- (void) switchTransitionStyle
{
    // Switch boolean
    randomTransition = !randomTransition;
    
    // Update Bar Button Title
    self.navigationItem.rightBarButtonItem.title = (randomTransition) ? BarButtonRandomTransitionString : BarButtonNormalTransitionString;
}


#pragma mark - 
#pragma mark Fade and Flip Animation

// This view will fade in and flip the passed in iView.  We are using this as our starting animation.
- (void) fadeInView:(UIView *)iView
{
    // Make sure the view is hidden
    iView.alpha = 0.0f;
    
    /* Inital Transform Matrix */
    
    // Set the Rotation
    CATransform3D initalTransformState = CATransform3DMakeRotation (M_PI_2, 0.0, 1.0, 0.0);
    
    // Set the Scale
    initalTransformState = CATransform3DScale (initalTransformState, 1.0, 0.8, 1.0);
    initalTransformState.m34 = 1.0 / -500;    // This is an added bit to make the rotation look nicer
    
    // Add to the View
    iView.layer.transform = initalTransformState;
    
    /* Final Transform Matrix */
    
    // Set the Rotation
    CATransform3D finalTransformState = CATransform3DMakeRotation (2 * M_PI, 0.0, 1.0, 0.0);
    
    // Set the Scale
    finalTransformState = CATransform3DScale (finalTransformState, 1.0, 1.0, 1.0);
    
    /* Flip Animation */
    // Note:
    //  The simplified description on how animations work is that the OS takes the state a view
    //  was before and automatically figures out how to change it to the final state that you set.
    
    [UIView animateWithDuration:0.75f delay:0.0f options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         // Switch View's Transform (Rotation Effect)
                         iView.layer.transform = finalTransformState;
                         
                         // Show View (Fade Effect)
                         iView.alpha = 1.0f;
                         
                     } completion:^(BOOL finished) {    // Note: Runs when animation finishes
                         
                         // make sure both views have the right alpha set
                         frontView.alpha = 1.0f;
                         backView.alpha = 1.0f;
                         
                         // Setup a tap gesture to fire the flip method
                         UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flipBetweenViews)];
                         [tapGesture setNumberOfTapsRequired:1];
                         
                         [self.view addGestureRecognizer:tapGesture];
                         
                     }];                     
}

#pragma mark - 
#pragma mark Flip Between Views

- (void) flipBetweenViews
{
    // Note: There might be mirror issues when using views with actual content
    
    if(randomTransition)
    {
        /* Random Transition */
        if (!displayingFront)
            [UIView transitionFromView:backView toView:frontView duration:1.0 options:[self randomOption] completion:NULL];
        else
            [UIView transitionFromView:frontView toView:backView duration:1.0 options:[self randomOption] completion:NULL];
    }   
    else
    {    
        /* this only flips left then right */
        if (!displayingFront)
            [UIView transitionFromView:backView toView:frontView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft completion:NULL];
        
        else
            [UIView transitionFromView:frontView toView:backView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight completion:NULL];
    }
    
    displayingFront = !displayingFront;
}

- (UIViewAnimationOptions) randomOption
{
    switch (arc4random()%4) {
        case 0:
            return UIViewAnimationOptionTransitionFlipFromLeft;
            break;
        case 1:
            return UIViewAnimationOptionTransitionFlipFromRight;
            break;
        case 2:
            return UIViewAnimationOptionTransitionFlipFromTop;
            break;
        default:
            return UIViewAnimationOptionTransitionFlipFromBottom;
            break;                        
    }     
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
