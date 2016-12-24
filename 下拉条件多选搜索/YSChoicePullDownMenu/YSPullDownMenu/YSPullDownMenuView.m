#import "YSPullDownMenuView.h"
#import "YSMenuButton.h"

static NSString *cellID = @"cellID";

@interface YSPullDownMenuView()<UITableViewDataSource, UITableViewDelegate>{
    
    // 屏幕高度
    CGFloat _screenHeight;
}

// 具体的查询项列表，添加在此视图的superView上面，头部对齐按钮底部
@property (nonatomic, strong) UITableView *tableView;

// 背景视图，添加在此视图的superView上面，头部对齐tableView底部
@property (nonatomic, strong) UIView *backgroundView;

// 查询表头按钮数组
@property (nonatomic, strong) NSMutableArray<YSMenuButton *> *titleBtnArray;

// 查询条件-数据源
@property (nonatomic, strong) NSArray *searchTitleArray;

// 选中的颜色
@property (nonatomic, strong) UIColor *selectedColor;

// 菜单的正常颜色
@property (nonatomic, strong) UIColor *menuColor;

// 是否显示查询条件
@property (nonatomic, assign) BOOL show;

// 点击按钮的索引
@property (nonatomic, assign) NSInteger selectBtnIndex;

// 选中的复合条件
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *selectedIndexPaths;

@end

@implementation YSPullDownMenuView

- (NSMutableArray *)titleBtnArray{
    if(_titleBtnArray == nil){
        _titleBtnArray = [NSMutableArray array];
    }
    return _titleBtnArray;
}

- (instancetype)initWithFrame:(CGRect)frame andSearchTitleArray:(NSArray *)searchTitleArray andSelectedColor:(UIColor *)selectedColor{
    if (self = [super initWithFrame:frame]) {
        
        _searchTitleArray = [NSArray arrayWithArray:searchTitleArray];
        _selectedColor = selectedColor;
        _menuColor = [UIColor colorWithRed:(110 / 255.0) green:(110 / 255.0) blue:(110 / 255.0) alpha:1];
        _screenHeight = [UIScreen mainScreen].bounds.size.height;
        _show = NO;
        _selectedIndexPaths = [NSMutableArray array];
        
        [self setupUI];
    }
    return self;
}

- (void)addSearchButtons{
    CGFloat btnW = self.frame.size.width / _searchTitleArray.count * 1.0;
    
    for (int i = 0; i < _searchTitleArray.count; i++) {
        YSMenuButton *btn = [[YSMenuButton alloc]initWithFrame:CGRectMake(i * btnW, 0, btnW - 1, self.frame.size.height)];
        
        btn.backgroundColor = [UIColor whiteColor];
        
        [btn setTitleColor:_menuColor forState:UIControlStateNormal];
        [btn setTitleColor:_selectedColor forState:UIControlStateSelected];
        
        if ([[_searchTitleArray objectAtIndex:i] count] > 1) {
            [btn setImage:[UIImage imageNamed:@"selectdown"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"selectdown1"] forState:UIControlStateSelected];
        }
        
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [btn addTarget:self action:@selector(searchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [btn setTitle:[[_searchTitleArray objectAtIndex:i] objectAtIndex:0] forState:UIControlStateNormal];
        
        [self addSubview:btn];
        [self.titleBtnArray addObject:btn];
    }
}
- (void)setupTableView{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, 0) style:UITableViewStylePlain];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
    _tableView.rowHeight = 36;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _backgroundView = [[UIView alloc]init];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
    [_backgroundView addGestureRecognizer:tap];
}

- (void)setupUI{
    self.backgroundColor = [UIColor colorWithRed:(230 / 255.0) green:(230 / 255.0) blue:(230 / 255.0) alpha:1];
    [self addSearchButtons];
    [self setupTableView];
}

- (void)searchButtonClicked:(YSMenuButton *)sender{
    [_titleBtnArray enumerateObjectsUsingBlock:^(YSMenuButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.titleLabel setFont:[UIFont fontWithName: @"Helvetica"size:14]];
    }];
    [sender.titleLabel setFont:[UIFont fontWithName: @"Helvetica-Bold"size:16]];
    
    NSInteger selectIndex = [self.titleBtnArray indexOfObject:sender];
    NSArray *array = _searchTitleArray[selectIndex];
    
    if (array.count <= 1) { // 只有一个button按钮，直接执行代理方法
        
        _selectBtnIndex = selectIndex;
        
        if(_show){
            [self dismissTableView];
        }
        
        sender.selected = YES;
        
        [self addToResults:[NSIndexPath indexPathForRow:0 inSection:selectIndex]];
        if([self.delegate respondsToSelector:@selector(pullDownMenuView:didSelectedIndexPaths:)]){
            [self.delegate pullDownMenuView:self didSelectedIndexPaths:[_selectedIndexPaths copy]];
        }
    }
    else{
        if (_show) { // 当前正在显示
            if (_selectBtnIndex == selectIndex) { // 和上一次点击的是相同按钮
                // 隐藏TableView
                [self dismissTableView];
            }
            else{ // 和上一次点击的是不同按钮，切换数据源
                [UIView animateWithDuration:0.25 animations:^{
                    _titleBtnArray[_selectBtnIndex].imageView.layer.transform = CATransform3DIdentity;
                    [_titleBtnArray enumerateObjectsUsingBlock:^(YSMenuButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        obj.imageView.layer.transform = CATransform3DIdentity;
                    }];
                    sender.imageView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
                }];
                _selectBtnIndex = selectIndex;
                [_tableView reloadData];
            }
        }
        else{ // 当前正在隐藏，需要显示
            _selectBtnIndex = selectIndex;
            [self showTableView:sender];
        }
    }
}
- (void)tapClick{
    [self dismissTableView];
}

#pragma mark - 查询条件显示与消失
- (void)showTableView:(YSMenuButton *)sender{
    _tableView.frame = CGRectMake(0, CGRectGetMaxY(self.frame), self.frame.size.width, 0);
    [_tableView reloadData];
    [self.superview addSubview:_tableView];
    
    CGFloat tableViewH = [_tableView numberOfRowsInSection:0] * _tableView.rowHeight;
    
    _backgroundView.frame = CGRectMake(0, CGRectGetMaxY(_tableView.frame) + tableViewH, self.frame.size.width, _screenHeight - CGRectGetMaxY(_tableView.frame));
    [self.superview addSubview:_backgroundView];
    
    [UIView animateWithDuration:0.25 animations:^{
        _tableView.frame = CGRectMake(0, CGRectGetMaxY(self.frame), self.frame.size.width, tableViewH);
        [_titleBtnArray enumerateObjectsUsingBlock:^(YSMenuButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.imageView.layer.transform = CATransform3DIdentity;
        }];
        sender.imageView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
    }];
    
    _show = YES;
}

- (void)dismissTableView{
    [_titleBtnArray enumerateObjectsUsingBlock:^(YSMenuButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.imageView.layer.transform = CATransform3DIdentity;
    }];
    
    _tableView.frame = CGRectMake(0, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
    [_tableView removeFromSuperview];
    [_backgroundView removeFromSuperview];
    _show = NO;
}

#pragma mark - 把选中的indexPath添加到结果集中
- (void)addToResults:(NSIndexPath *)indexPath{
    [_selectedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.section == indexPath.section){
            [_selectedIndexPaths removeObject:obj];
        }
    }];
    [_selectedIndexPaths addObject:indexPath];
}

#pragma mark - UITableViewDataSource/UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = _searchTitleArray[_selectBtnIndex];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *array = _searchTitleArray[_selectBtnIndex];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.text = array[indexPath.row];
    
    [_selectedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.section == _selectBtnIndex && obj.row == indexPath.row){
            cell.textLabel.textColor = _selectedColor;
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YSMenuButton *btn = [self.titleBtnArray objectAtIndex:_selectBtnIndex];
    btn.selected = YES;
    [btn setTitle:[[_searchTitleArray objectAtIndex:_selectBtnIndex] objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    
    [self addToResults:[NSIndexPath indexPathForRow:indexPath.row inSection:_selectBtnIndex]];
    if([self.delegate respondsToSelector:@selector(pullDownMenuView:didSelectedIndexPaths:)]){
        [self.delegate pullDownMenuView:self didSelectedIndexPaths:[_selectedIndexPaths copy]];
    }
    
    
    [self dismissTableView];
}

@end
