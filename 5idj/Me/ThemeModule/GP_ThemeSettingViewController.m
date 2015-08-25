//
//  GP_ThemeSettingViewController.m
//  5idj_ios
//
//  Created by Xuzhanya on 14-7-31.
//  Copyright (c) 2014年 uwtong. All rights reserved.
//

//----------------------------------------------------------

#import "GP_ThemeSettingViewController.h"

//----------------------------------------------------------

@interface _GP_themeCollectionViewCell  : UICollectionViewCell

- (void)updateWithTheme:(GP_Theme *)theme;

@end

//----------------------------------------------------------

@implementation _GP_themeCollectionViewCell
{
    CALayer     * _selectIndicateLayer;
    UIImageView * _themeImageView;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor   = [defaultViewBackgrounpColor colorWithAlphaComponent:0.5f];
        self.layer.borderWidth = PiexlToPoint(1);
        self.layer.borderColor = defaultLineColor.CGColor;
        
        _themeImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _themeImageView.contentMode   = UIViewContentModeScaleAspectFill;
        _themeImageView.clipsToBounds = YES;
        _themeImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                           UIViewAutoresizingFlexibleWidth;
        
        [self.contentView addSubview:_themeImageView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_selectIndicateLayer) {
        _selectIndicateLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
}

- (void)setSelected:(BOOL)selected
{
    if (self.selected != selected) {
        
        if (self.selected) {
            _selectIndicateLayer.hidden = YES;
        }
        
        if (selected) {
            
            if (!_selectIndicateLayer) {
                
                UIImage * selectIndicateImage = ImageWithName(@"theme_select");
                
                _selectIndicateLayer = [[CALayer alloc] init];
                _selectIndicateLayer.actions = @{@"bounds":[NSNull null],@"position":[NSNull null],@"hidden":[NSNull null]};
                _selectIndicateLayer.contents = (id)selectIndicateImage.CGImage;
                _selectIndicateLayer.bounds = CGRectMake(0.f, 0.f, selectIndicateImage.size.width, selectIndicateImage.size.height);
                _selectIndicateLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
                
                [self.contentView.layer addSublayer:_selectIndicateLayer];
            }
            
            _selectIndicateLayer.hidden = NO;
        }
    }
    
    [super setSelected:selected];
    
}

- (void)updateWithTheme:(GP_Theme *)theme
{
    _themeImageView.image = theme.thumbnailName ? ImageWithName(theme.thumbnailName) : nil;
}

@end

//----------------------------------------------------------

@implementation GP_ThemeSettingViewController

- (UICollectionViewLayout *)collectionViewLayout
{
    CGSize _screenSize = screenSize();
    CGFloat space      = floorf(_screenSize.width * .1f / 4.f);
    
    UICollectionViewFlowLayout * flowLayout = (UICollectionViewFlowLayout *)[super collectionViewLayout];
    
    flowLayout.itemSize = CGSizeMake(floorf(_screenSize.width * .3f), floorf(_screenSize.height * .3f));
    flowLayout.sectionInset = UIEdgeInsetsMake(space, space, space, space);
    flowLayout.minimumLineSpacing = space;
    flowLayout.minimumInteritemSpacing = space;
    
    return flowLayout;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myNavigationItem.title = @"主题设置";
    

    [self.view addSubview:self.collectionView];
    
    //注册单元
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[_GP_themeCollectionViewCell class]
            forCellWithReuseIdentifier:defaultReuseDef];

    //定位到选择的主题
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:[[GP_ThemeManager shareThemeManager] currentThemeIndex] inSection:0]
                                      animated:NO
                                scrollPosition:UICollectionViewScrollPositionCenteredVertically];

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[GP_ThemeManager shareThemeManager] themesCount];;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    _GP_themeCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:defaultReuseDef forIndexPath:indexPath];
    
    [cell updateWithTheme:[[GP_ThemeManager shareThemeManager] themeAtIndex:indexPath.item]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item != [[GP_ThemeManager shareThemeManager] currentThemeIndex]) {
    
        [collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:[[GP_ThemeManager shareThemeManager] currentThemeIndex] inSection:0] animated:YES];
        
        [self showProgressIndicatorView:@"设置主题中,请稍后..."];
        
        //设置主题
        [[GP_ThemeManager shareThemeManager] setCurrentThemeIndex:indexPath.row];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.item != [[GP_ThemeManager shareThemeManager] currentThemeIndex];
}

- (void)didChangeThemeImage
{
    [super didChangeThemeImage];
    
    [self hideProgressIndicatorView];
    
    showSuccessMessage(self.view, @"主题设置成功", nil);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self popSubViewControllerAnimated:YES];
    });
}


@end
