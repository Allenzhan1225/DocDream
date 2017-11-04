//
//  ChangePassVC.m
//  DocDream
//
//  Created by YDWY on 2017/11/1.
//  Copyright © 2017年 Allen. All rights reserved.
//

#import "ChangePassVC.h"
#import <AFNetworking.h>
#import <UIView+Toast.h>
@interface ChangePassVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *oldPass;
@property (weak, nonatomic) IBOutlet UITextField *newpass;
@property (nonatomic,strong) AFHTTPSessionManager * httpMgr;


@end

@implementation ChangePassVC


/**
 修改密码

 @param sender
 */
- (IBAction)submit:(id)sender {
    _httpMgr = [AFHTTPSessionManager manager];
    _httpMgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    if (_oldPass.text && [_oldPass.text isEqualToString:@""]) {
        [self.view makeToast:@"请输入密码" duration:2.0 position:CSToastPositionCenter];
        return ;
    }
    if (_newpass.text && [_newpass.text isEqualToString:@""]) {
        [self.view makeToast:@"请输入您要修改的密码" duration:2.0 position:CSToastPositionCenter];
           return ;
        
        
    }
    
    NSDictionary * params = @{@"uid":[NSNumber numberWithInteger:self.ID],@"oldpwd":_oldPass.text,@"pwd":_newpass.text};
    [_httpMgr POST:@"http://yxtest.xgyuanda.com/Api/index/editPwd" parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dict =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"修改密码：%@",dict);
         [self.view makeToast:dict[@"msg"] duration:2.0 position:CSToastPositionCenter];
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}



#pragma textFiled 代理方法
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
