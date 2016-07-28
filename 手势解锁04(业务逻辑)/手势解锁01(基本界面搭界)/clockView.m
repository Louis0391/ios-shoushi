//
//  clockView.m
//  手势解锁01(基本界面搭界)
//
//  Created by hqc on 15/11/15.
//  Copyright © 2015年 hqc. All rights reserved.
//

#import "clockView.h"

@interface clockView()
/** 保存选中状态的按钮 */
@property(nonatomic, strong) NSMutableArray *selectedArrM;
/** 保存当前手指所在点 */
@property(nonatomic, assign) CGPoint curP;
@end

@implementation clockView

-(NSMutableArray *)selectedArrM{
    if (_selectedArrM == nil) {
        //创建并初始化数组
        _selectedArrM = [NSMutableArray array];
    }
    return _selectedArrM;
}
//封装时要考虑使用者通过不同方法创建对象(构造方法,类方法,xib或者storyboard)

//通过xib或storybord文件创建对象时会调用该方法
-(void)awakeFromNib{
    //初始化
    [self setUp];
    
}

//使用alloc和init方法创建对象时会调用该方法
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //初始化
        [self setUp];
    }
    return self;
}

- (void)setUp{
    //添加按钮
    for (int i = 0;  i < 9; i++) {
        //创建按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        //给创建的每一个按钮绑定一个标示符
        btn.tag = i;
        //将按钮用户交互设置为no,将事件交给view去处理
        btn.userInteractionEnabled = NO;
        [btn setImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
        [self addSubview:btn];
    }
    
}


//获取当前手指的点
-(CGPoint)getCurrentPoint:(NSSet *)touches{
    
    UITouch *touch = [touches anyObject];
    CGPoint curP = [touch locationInView:self];
    return curP;
}

//判断手指的触摸点是否在按钮上
-(UIButton *)btnRectContanistPoint:(CGPoint)point{
    //遍历view上的所有的按钮
    for (UIButton *btn in self.subviews) {
        //如果触摸点在按钮上,则返回该按钮,只要点在按钮的frame范围内,按钮就被点中
        if (CGRectContainsPoint(btn.frame, point)) {
            return btn;
        }
    }
    return nil;
}
//当手指点中按钮就让按钮处于选中状态
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint curP = [self getCurrentPoint:touches];
    
    UIButton *btn = [self btnRectContanistPoint:curP];
    if (btn && btn.selected == NO) {
        btn.selected = YES;
         [self.selectedArrM addObject:btn];
    }
}
//当手指移动时,如果按钮被点击中,移动时还要绘制线条
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint curP = [self getCurrentPoint:touches];
    self.curP = curP;
    UIButton *btn = [self btnRectContanistPoint:curP];
    if (btn && btn.selected == NO) {
        btn.selected = YES;
        [self.selectedArrM addObject:btn];
        //每次移动到一个按钮重绘(连接两个按钮之间的线)
        //[self setNeedsDisplay];
    }
    //每次移动都要重绘线条(没有移动到按钮也要连线,连接起始按钮与当前手指之间的线)
    [self setNeedsDisplay];

}

//当手指离开按钮时,让按钮取消选中状态
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSMutableString *strM = [NSMutableString string];
    for (UIButton *btn in self.selectedArrM) {
        //取消按钮选中
        btn.selected = NO;
        //将每个被选中的按钮对应的数字拼接到字符串中
        [strM appendFormat:@"%ld",btn.tag];
    }
    NSLog(@"%@",strM);//答应保存在数组中的所有数字,在清空之前打印
    
    //当选中的按钮被取消了,要及时清空数组,优化内存
    //清空选中按钮的数组(同时就取消了所有的连线)
    [self.selectedArrM removeAllObjects];
    //取消选中之后也要重绘
    [self setNeedsDisplay];

}
//布局按钮控件
-(void)layoutSubviews{
    [super layoutSubviews];
    //self.backgroundColor = [UIColor redColor];
    //总列数
    int cloumn = 3;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat btnWH = 74;
    CGFloat margin = (self.bounds.size.width - (btnWH * cloumn)) / (cloumn + 1);
    
    //当前所在列
    int curCloumn = 0;
    //当前所在的行
    int curRow = 0;
    
    for ( int i = 0;  i < self.subviews.count; i++) {
        //当前所在列
        curCloumn = i % cloumn;
        //当前所在的行
        curRow = i / cloumn;
        
        x = margin + (btnWH + margin) * curCloumn;
        y = (btnWH + margin) * curRow;
        //出取每一个按钮
        UIButton *btn = self.subviews[i];
        btn.frame = CGRectMake(x, y, btnWH, btnWH);
    }
}

//画线
-(void)drawRect:(CGRect)rect{
    //当数组中有值时,才绘线
    if (self.selectedArrM.count) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        //取出所有选中的按钮
        for(int i = 0 ; i < self.selectedArrM.count; i++){
            UIButton *btn = self.selectedArrM[i];
            //如果发现按钮是第一个, 让按钮成为路径的起点.
            if (i == 0) {//选中的第一个按钮
                [path moveToPoint:btn.center];
            }else{//选中的其他按钮
                [path addLineToPoint:btn.center];
            }
        }
        //添加一根线到当前手指的点. (连接选中的第一个按钮和当前手指所在点(不一定在按钮上)之间的连线)
        [path addLineToPoint:self.curP];
        
        //设置连接样式
        [path setLineJoinStyle:kCGLineJoinRound];
        
        //设置线宽度
        [path setLineWidth:10];
        //设置颜色
        [[UIColor redColor] set];
        [path stroke];
        
        
    }
}

@end
