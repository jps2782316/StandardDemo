//
//  AppDelegate.m
//  JPSStandardDemo
//
//  Created by jps on 2017/3/28.
//  Copyright © 2017年 jps. All rights reserved.
//

#import "AppDelegate.h"
#import "TabbarController.h"
#import "JpsViewController.h"
#import "JpsLoginViewController.h"
#import "JpsWelcomeViewController.h"
#import "JpsManagerViewController.h"
#import "JpsLeftViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //self.window.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRootVC:) name:@"login" object:nil];
    
    //bilibili
//    JpsViewController *loginVC = [[JpsViewController alloc]init];
//    self.window.rootViewController = loginVC;
    
    //QQ
//    JpsLoginViewController *loginVC = [[JpsLoginViewController alloc]init];
//    self.window.rootViewController = loginVC;
    
    JpsWelcomeViewController *wecomeVC = [[JpsWelcomeViewController alloc]init];
    self.window.rootViewController = wecomeVC;
    
    
    
    return YES;
}




- (void)changeRootVC:(NSNotification *)noti
{
//    //1. 初始化窗口根控制器
//    TabbarController *tabController = [[TabbarController alloc]init];
//    self.window.rootViewController = tabController;
//    
//    //2. 配置navigationBar样式
//    [[UINavigationBar appearance] setTintColor:[UIColor purpleColor]];
//    
//    //3. 配置tabbar样式
//    [[UITabBar appearance] setTintColor:[UIColor blueColor]];
//    //设置tabbar背景色
//    //[[UITabBar appearance] setBarTintColor:[UIColor lightGrayColor]];
    
    TabbarController *tabBarVC = [[TabbarController alloc]init];
    JpsLeftViewController *leftVC = [[JpsLeftViewController alloc]init];
    
    JpsManagerViewController *managerVC = [[JpsManagerViewController alloc]initWithLeftVC:leftVC rightVC:tabBarVC];
    self.window.rootViewController = managerVC;
    
}





- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
