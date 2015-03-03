//
//  HelloWorldScene.m
//  SPACE INVADERS
//
//  Created by Антон Дитятив on 25.05.14.
//  Copyright Антон Дитятив 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "HelloWorldScene.h"
#import "IntroScene.h"
#import <CoreMotion/CoreMotion.h>
// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

@implementation HelloWorldScene
{
    CCSprite *_sprite;
    CCSprite *_enemy;
    CCSprite *_bullet;
    CCSprite *_newBulet;
    CCActionMoveTo *_actionMoveEnemy;
    CCActionMoveTo *_actionMove;
    CCLabelTTF *_live;
    int _q;
    float _shot;
    NSMutableArray *_enemies;
    NSMutableArray *_bullets;
    NSMutableArray *_enemyBullets;
    CMMotionManager *_motionManager;
    bool _gameFinished;
    bool _GameOver;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (HelloWorldScene *)scene
{
    return [[self alloc] init];

}

// -----------------------------------------------------------------------

- (id)init
{
    
    self = [super init];
    if (!self) return(nil);
    
  
    self.userInteractionEnabled = YES;
    _shot=0;
    _q=3;
    _gameFinished = false;
    _bullets = [NSMutableArray array];
    _enemyBullets = [NSMutableArray array];

    CCSprite *image = [CCSprite spriteWithImageNamed:@"012.png"];
    // position the label on the center of the screen
    image.position =  ccp(self.contentSize.height/2, self.contentSize.width/2);
    [self addChild:image];

    // Add a sprite
    _sprite = [CCSprite spriteWithImageNamed:@"spaceship-hd.png"];
    _sprite.position  = ccp(self.contentSize.width/2,20.f);
    _enemies = [NSMutableArray array];
    for(int i=0;i<=5;++i)
    {
        for(int j=0;j<=1;j++)
        {
            _enemy = [CCSprite spriteWithImageNamed:@"spaceship-hd.png"];
            _enemy.position = ccp(90.f+i*50, 200.f + j*50);
            [self addChild:_enemy];
            [ _enemies addObject:_enemy];
            _enemy.rotation = 180.f;
        }
    }
    [self addChild:_sprite];
    _live = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Live:%d", _q] fontName:@"Chalkduster" fontSize:12.0f];
    _live.position = ccp(20.f, 300.f);
    [self addChild:_live];
    
    _motionManager = [[CMMotionManager alloc] init];
   
    
    // Create a back button
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Menu ]" fontName:@"Verdana-Bold" fontSize:18.0f];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.85f, 0.95f); // Top Right of screen
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];
	return self;
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
     [_motionManager startAccelerometerUpdates];
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
    [_motionManager stopAccelerometerUpdates];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_gameFinished) {
        return;
    }
    _bullet = [CCSprite spriteWithImageNamed:@"bullet.png"];
    _bullet.position = _sprite.position;
    [self addChild:_bullet];
    [_bullets addObject:_bullet];
    _actionMove = [CCActionMoveTo actionWithDuration:1.0f position:ccp(_sprite.position.x,self.contentSize.height)];
    [_bullet runAction:_actionMove];
   }

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------
- (void)update:(CCTime)delta {
    if (_gameFinished) {
        return;
    }
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    CGFloat newXPosition = _sprite.position.x + acceleration.y * 1000 * delta;
    newXPosition = clampf(newXPosition, 0, self.contentSize.width);
    _sprite.position = CGPointMake(newXPosition, _sprite.position.y);
    for(int i = (int)(_bullets.count - 1); i >= 0; --i)
    {
        for(int j = (int)(_enemies.count - 1); j >= 0; --j)
        {
            if(CGRectIntersectsRect([(CCSprite *)[_bullets objectAtIndex:i] boundingBox], [(CCSprite *)[_enemies objectAtIndex:j ] boundingBox]))
            {
                [self removeChild:[_bullets objectAtIndex:i] cleanup:YES];
                [_bullets removeObjectAtIndex:i];
                [self removeChild:[_enemies objectAtIndex:j] cleanup:YES];
                [_enemies removeObjectAtIndex:j];
                break;
            }
        }
    }
    
    if(_enemies.count ==  0)
    {
        if (_gameFinished) {
            return;
        }
        _gameFinished = true;
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"YOU WIN" fontName:@"Chalkduster" fontSize:36.0f];
        label.positionType = CCPositionTypeNormalized;
        label.color = [CCColor redColor];
        label.position = ccp(0.5f, 0.5f); // Middle of screen
        [self addChild:label];
        [self removeChild:_sprite cleanup:YES];
        [_bullet stopAllActions];
    }
    _shot=_shot+delta;
    
    if(_shot > 5)
    {
        int t = arc4random() % _enemies.count;
        CCSprite *NewEnemy = [_enemies objectAtIndex:t];
        CGPoint position = [NewEnemy position];
        _newBulet = [CCSprite spriteWithImageNamed:@"bullet.png"];
        _newBulet.position = position;
        [self addChild:_newBulet z:0];
        [_enemyBullets addObject:_newBulet];
        _shot=0;
    }
    _actionMoveEnemy = [CCActionMoveTo actionWithDuration:3.0f position:ccp(_sprite.position.x,_sprite.position.y)];
    [_newBulet runAction:_actionMoveEnemy];
    for(int i = (int)(_enemyBullets.count-1);i >= 0; --i)
    {
            if(CGRectIntersectsRect([(CCSprite *)[_enemyBullets objectAtIndex:i] boundingBox], _sprite.boundingBox))
            {
                [self removeChild:[_enemyBullets objectAtIndex:i] cleanup:YES];
                [_enemyBullets removeObjectAtIndex:i];
                _q=_q-1;
                [_live setString:[NSString stringWithFormat:@"Live:%d", _q] ];
            }
    }
        if(_q == 0)
        {
            
            if (_gameFinished)
            {
                return;
            }
            _gameFinished = true;
                CCLabelTTF *label = [CCLabelTTF labelWithString:@"YOU LOSE" fontName:@"Chalkduster" fontSize:36.0f];
                label.positionType = CCPositionTypeNormalized;
                label.color = [CCColor redColor];
                label.position = ccp(0.5f, 0.5f); // Middle of screen
            [self removeChild:_sprite cleanup:YES];
                [self addChild:label];
            [self stopAllActions];
        }
    
   }

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

@end
