//
//  ViewController.m
//  YSChoicePullDownMenu
//
//  Created by yaoshuai on 2016/12/24.
//  Copyright © 2016年 ys. All rights reserved.
//

#import "ViewController.h"
#import "YSPullDownMenuView.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, YSPullDownMenuViewDelegate>

@property (weak, nonatomic) UITableView *tableView;

@property (nonatomic, strong) YSPullDownMenuView *menu;

@property (strong, nonatomic) NSIndexPath *index;

@property (nonatomic, strong) NSArray *searchTitleArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    [self loadSearchData];
    [self setupUI];
}

- (void)loadSearchData{
    self.searchTitleArray = @[@[@"价格",@"价格从低到高",@"价格从高到底"], @[@"销量",@"销量从低到高",@"销量从高到底"],@[@"好评"]];
}

- (void)setupUI{
    self.menu = [[YSPullDownMenuView alloc] initWithFrame:CGRectMake(0, 30, [UIScreen mainScreen].bounds.size.width, 30) andSearchTitleArray:self.searchTitleArray andSelectedColor:[UIColor colorWithRed:(241 / 255.0) green:(125 / 255.0) blue:(174 / 255.0) alpha:1]];
    
    self.menu.delegate = self;
    [self.view addSubview:self.menu];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, _menu.frame.size.width, [UIScreen mainScreen].bounds.size.width - 60) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [[self.searchTitleArray objectAtIndex:self.index.section] objectAtIndex:self.index.row];
    return cell;
}

- (void)pullDownMenuView:(YSPullDownMenuView *)menu didSelectedIndexPaths:(NSArray<NSIndexPath *> *)indexPathArray{
    
    NSMutableString *strIndex = [NSMutableString string];
    NSMutableString *strText = [NSMutableString string];
    
    [indexPathArray enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [strIndex appendFormat:@"%zd-%zd;",obj.section,obj.row];
        [strText appendFormat:@"%@;",_searchTitleArray[obj.section][obj.row]];
        
    }];
    
    NSLog(@"选中的索引集合：%@",strIndex);
    NSLog(@"选中的文本拼接：%@",strText);
}

@end
