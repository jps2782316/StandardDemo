//
//  NXABlueToothViewController.m
//  NXA-MasterDrivingSkills
//
//  Created by jps on 2017/3/23.
//  Copyright © 2017年 NXA. All rights reserved.
//

#import "NXABlueToothViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>


#define kSeriveUUID @"E7B0EB0D-3AA0-4D8A-8A00-3AF63F43B90A"  //要连接的外设UUID



@interface NXABlueToothViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource>


@property(nonatomic,strong)CBCentralManager *centralManager;    //!<蓝牙管理对象，中心角色
@property(nonatomic,strong)CBPeripheral *peripheral;    //!<当前连接的外部设备
@property(nonatomic,strong)CBCharacteristic *characteristic;    //!<要发送数据的特征

@property (nonatomic, strong) NSMutableArray *peripheralArray;  //!<保存扫描到的外部设备
@property (nonatomic, strong) NSMutableArray *characteristicArray;   //!<保存扫描到的特征
@property(nonatomic,strong)NSMutableArray *connectedPeripheralArray;    //!<连接到得设备

@property(nonatomic,strong)NSMutableArray *servicesArray;    //!<保存扫描到的服务


@property(nonatomic,strong)UITableView *tableView;

@end

@implementation NXABlueToothViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initComponents];
    
    ////初始化管理对象
    [self initCentralManger];
    
    
    
  //  [self signData3];
    
    
    [self authentication];
    
    
    [self tableView];
    
        UIImage *image2 = [UIImage imageNamed:@"1.jpg"];
        [self.navigationController.navigationBar setBackgroundImage:image2 forBarMetrics:UIBarMetricsDefault];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}


- (void)viewDidLayoutSubviews
{
    self.tableView.frame = self.view.frame;
}

//// 2. 横屏时是否隐藏状态栏   默认隐藏
//- (BOOL)prefersStatusBarHidden {
//    return YES; // 显示
//}
//
//
//- (BOOL)shouldAutorotate{
//    //不允许转屏
//    return YES;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    //viewController所支持的全部旋转方向
//    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
//}
//    




- (void)initComponents
{
    self.view.backgroundColor = [UIColor whiteColor];
    //初始化导航栏
    self.navigationItem.title = @"签到签退";
    UIImage *backImage = [UIImage imageNamed:@"back"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:backImage style:UIBarButtonItemStyleDone target:self action:@selector(backAction:)];
}

- (void)backAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - ------------- UITableViewDataSource -------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.peripheralArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    CBPeripheral *peripheral = self.peripheralArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"外设名称:%@",peripheral.name];
    NSUUID *uuid = peripheral.identifier;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"UUID：%@",uuid];
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
//    //cell右边辅助按钮的事件处理
//    DLog(@"正在断开蓝牙连接");
//    
//    //断开与指定外设的连接
//    [self.centralManager cancelPeripheralConnection:self.peripheralArray[indexPath.row]];
    
    
   // [self printAllUUID];
    
    //签退
    NSArray *arr = [self signOut];
    [self.peripheral writeValue:arr[0] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    [self.peripheral writeValue:arr[1] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //连接外部设备
    [self.centralManager connectPeripheral:self.peripheralArray[indexPath.row] options:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"周围的蓝牙设备";
}


//==================================================================

//初始化管理对象
- (void)initCentralManger
{
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    //会自动触发centralManagerDidUpdateState:代理方法
    
    //_cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)];
    //扫描设备时,不扫描到相同设备,这样可以节约电量,提高app性能.如果需求是需要实时获取设备最新信息的,那就需要设置为YES.
}


#pragma mark - ------------- CBCentralManagerDelegate -------------

//监听蓝牙状态,蓝牙状态改变时调用
//不同状态下可以弹出提示框交互
//如果单独封装了这个类,可以设置代理或block或通知向控制器传值
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@">>>蓝牙未知状态");
            break;
        case CBManagerStateResetting:
            NSLog(@">>>蓝牙重启");
            break;
        case CBManagerStateUnsupported:
            NSLog(@">>>不支持蓝牙");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@">>>未授权");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@">>>蓝牙关闭");
            break;
        case CBManagerStatePoweredOn:
        {
            NSLog(@">>>蓝牙打开,开始扫描...");
            //蓝牙打开时,再去扫描设备 提前开扫是扫不到的
            //参数1：扫描指定的外部设置的UUID.如果穿nil表示扫描外部所有的设备。
            CBUUID *uuid = [CBUUID UUIDWithString:@"E7B0EB0D-3AA0-4D8A-8A00-3AF63F43B90A"];
            [_centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];  //@[kSeriveUUID]  @[[CBUUID UUIDWithString:@"FF15"]]
        }
            break;
        default:
            break;
    }
}

//发现外设时调用
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    //RSSI信号强度。值越大，信号强度越强。
    if (![self.peripheralArray containsObject:peripheral]) {
        NSLog(@"发现外设:%@", peripheral);
        
        DLog(@"advertisementData: %@",advertisementData);
        
        //外部设置的名字
        //peripheral.name;
        
        //把扫描到的外设对象添加到数组
        [self.peripheralArray addObject:peripheral];
        
        NSLog(@"信号强度:%@", RSSI);
        
        //如果之前调用扫描外设的方法时,设置了相关参数,只会扫描到指定设备,可以考虑自动连接
        //[_cbManager connectPeripheral:peripheral options:nil];
        
        //刷新显示外设
        [self.tableView reloadData];
    }
}

//外设连接成功时调用
//一个主设备最多能连7个外设，每个外设最多只能给一个主设备连接,连接成功，失败，断开会进入各自的委托
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接成功");
    //记录当前连接的外设。 如果有多个，将连接的设备添加到_connectedPeripheralArray
    self.peripheral = peripheral;
    //设置外设代理
    self.peripheral.delegate = self;
    //4.扫描外部设备的服务
    //参数传空表示扫描当前外设中所有的服务
    [self.peripheral discoverServices:nil];
    
    //读取RSSI  会触发didReadRSSI代理方法
    [self.peripheral readRSSI];
    
}

//外设连接失败时调用
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"连接失败,%@", [error localizedDescription]);
}

//断开连接时调用
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@">>>外设连接断开连接 %@: %@\n", [peripheral name], [error localizedDescription]);
    //移除断开的设备
    //[_connectedPeripheralArray removeObject:peripheral];
    //这里可以进行一些操作,如之前连接时,监听了某个特征的通知,这里可以取消监听
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    NSLog(@"%s,%@",__PRETTY_FUNCTION__,peripheral);
    int rssi = [RSSI intValue];
    CGFloat ci = (rssi - 49) / (10 * 4.);
    NSString *length = [NSString stringWithFormat:@"发现BLT4.0热点:%@,距离:%.1fm",_peripheral,pow(10,ci)];
   // [NXAPublicClass showMessage:length];
    DLog(@"%@",length);
    
}



#pragma mark - ------------- CBPeripheralDelegate -------------

//已经扫描到外设中的服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"%@发现服务时出错: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    //遍历外设所有服务
    for (CBService *service in peripheral.services) {
        
        //把扫描到的所有服务添加到数组
        if (![self.servicesArray containsObject:service]) {
            [self.servicesArray addObject:service];
        }
        
#if 0
        //找到需要的服务，做操作*******
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FF15"]]) {
            
        }
#endif
        //UUIDString == 180A     UUID == Device Information
        NSLog(@"发现服务: UUIDString->%@ - UUID->%@", service.UUID.UUIDString, service.UUID);
        //每个服务又包含一个或多个特征,搜索服务的特征
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

//已经扫描到指定服务的特征
//发现特征时调用,由几个服务,这个方法就会调用几次
//这里我们可以使用readValueForCharacteristic:来读取数据。如果数据是不断更新的，则可以使用setNotifyValue:forCharacteristic:来实现只要有新数据，就获取。
//打印出 characteristic 的权限，可以看到有很多种，这是一个NS_OPTIONS，就是可以同时用于好几个值，常见的有read，write，notify，indicate，知知道这几个基本就够用了，前连个是读写权限，后两个都是通知，两种不同的通知方式。
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"扫描特征出错:%@", [error localizedDescription]);
        return;
    }
    //获取Characteristic的值
    for (CBCharacteristic *c in service.characteristics) {
        NSLog(@"服务server:%@ 的特征:%@, 读写属性:%ld", service.UUID.UUIDString, c, c.properties);
        //添加到数组中
        if (![self.characteristicArray containsObject:c])
        {
            [self.characteristicArray addObject:c];
        }
        
        //1. 向特征里面写数据
//        Byte b[] = {0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA0};
//        NSData *data = [NSData dataWithBytes:&b length:8];
//        Byte byte[1];
//        byte[0] = 0x0B;
//        [peripheral writeValue:[NSData dataWithBytes:byte length:1] forCharacteristic:c type:CBCharacteristicWriteWithResponse];
        
        
//        //1) 获取终端信息(GetDeviInfo)操作
//        Byte b[] = {0xF5, 0x5F, 0x01, 0x00, 0x00, 0x00, 0x1};
//        [peripheral writeValue:[NSData dataWithBytes:b length:7] forCharacteristic:c type:CBCharacteristicWriteWithResponse];
        
        //2) 终端注册(DevLogIn)操作
//        Byte b[] = {0xF5, 0x5F, 0x05, 0x00, 0x00, 0x00, 0x05};
//        [peripheral writeValue:[NSData dataWithBytes:b length:7] forCharacteristic:c type:CBCharacteristicWriteWithResponse];
        
        //3) 终端注销(DevLogOff)操作
//        Byte b[] = {0xF5, 0x5F, 0x07, 0x00, 0x00, 0x00, 0x07};
//        [peripheral writeValue:[NSData dataWithBytes:b length:7] forCharacteristic:c type:CBCharacteristicWriteWithResponse];
        
        
        
        //1. 向指定特征里面写数据
        //FFD1 -> app下传数据给终端的通道UUID
        //FFD2 -> 终端上传数据给app的通道UUID
        if ([c.UUID.UUIDString isEqualToString:@"FFD1"]) {
            NSArray *dataArr = [self signData3];
            //type一定要写对，不然写入不成功（写了没反应，不会进入didWriteValueForCharacteristic方法）
            [peripheral writeValue:dataArr[0] forCharacteristic:c type:CBCharacteristicWriteWithResponse];
            [peripheral writeValue:dataArr[1] forCharacteristic:c type:CBCharacteristicWriteWithResponse];
            [peripheral writeValue:dataArr[2] forCharacteristic:c type:CBCharacteristicWriteWithResponse];
            
            //记录要发送数据的特征
            self.characteristic = c;
        }
        
        
        
        //[peripheral writeValue:[self signData2] forCharacteristic:c type:CBCharacteristicWriteWithResponse];
        
        
        //2. 订阅通知
        //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
        
        //UUID==FFD1    notifying = NO, properties = 0xA
        if ([c.UUID.UUIDString isEqualToString:@"FFD1"]) {
            [peripheral readValueForCharacteristic:c];
            //[peripheral setNotifyValue:YES forCharacteristic:c];
        }
        //UUID==FFD2     notifying = YES, properties = 0x10
        if ([c.UUID.UUIDString isEqualToString:@"FFD2"]) { //
            [peripheral setNotifyValue:YES forCharacteristic:c];
            
        }
        
       
        
        //3. 获取Characteristic的值，读到数据会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
       // [peripheral readValueForCharacteristic:c];
        
        
        //4. 搜索Characteristic的Descriptors(描述符)，读到数据会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
        //Descriptor Descriptor用来描述characteristic变量的属性
        //[peripheral discoverDescriptorsForCharacteristic:c];
        
        
#if 0
        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"FF02"]]) {
            [_peripheral readValueForCharacteristic:c];
            [_peripheral setNotifyValue:YES forCharacteristic:c];
        }
        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"FFA1"]]) {
            [_peripheral readRSSI];
        }
#endif
        
        
    }
    /*
    //第一次调用,打印结果:
    //服务server:6666 的特征:<CBCharacteristic: 0x135e37410, UUID = 8888, properties = 0xDE, value = (null), notifying = NO>, 读写属性:->222
    //如果一个服务包含多种特征,会循环打出其他特征,我的设备正好一个服务只包含一个特征,处理起来方便了许多.
    //第二次调用,打印结果:
    //服务server:7777 的特征:<CBCharacteristic: 0x135e3d260, UUID = 8877, properties = 0x4E, value = (null), notifying = NO>, 读写属性:->78
    //特征也用UUID来区分,注意和service的UUID区别开来
    //和厂家确认,server(uuid=6666)的特征characteristic(uuid=8888)是监控蓝牙设备往APP发数据的,
    //server(uuid=7777)的特征characteristic(uuid=8877)向蓝牙发送指令的.
    //对特征定义宏
    //#define CID8888 @"8888"  //读指令(监控蓝牙设备往APP发数据),6666提供
    //#define CID8877 @"8877"  //APP向蓝牙发指令,7777提供
    //UUID=8888的特征有通知权限,在我的项目中是实时接收蓝牙状态发送过来的数据
     
    if ([service.UUID.UUIDString isEqualToString:SeriveID6666]) {
        for (CBCharacteristic *c in service.characteristics) {
            if ([c.UUID.UUIDString isEqualToString:CID8888]) {
                //设置通知,接收蓝牙实时数据
                [self notifyCharacteristic:peripheral characteristic:c];
            }
        }
    }
    if ([service.UUID.UUIDString isEqualToString:SeriveID7777]) {
        [peripheral readValueForCharacteristic:characteristic];
        //获取数据后,进入代理方法:
        //- peripheral: didUpdateValueForCharacteristic: error:
        //根据蓝牙协议发送指令,写在这里是自动发送,也可以写按钮方法,手动操作
        //我将指令封装了一个类,以下三个方法是其中的三个操作,具体是啥不用管,就知道是三个基本操作,返回数据后,会进入代理方法
        //校准时间
        [CBCommunication cbCorrectTime:peripheral characteristic:characteristic];
        //获取mac地址
        [CBCommunication cbGetMacID:peripheral characteristic:characteristic];
        //获取脱机数据
        [CBCommunication cbReadOfflineData:peripheral characteristic:characteristic];
    }
}
//描述相关的方法,代理实际项目中没有涉及到,只做了解
//搜索Characteristic的Descriptors
for (CBCharacteristic *characteristic in service.characteristics){
    [peripheral discoverDescriptorsForCharacteristic:characteristic];
    //回调方法:
    // - peripheral: didDiscoverDescriptorsForCharacteristic: error:;
    //还有写入读取描述值的方法和代理函数
}
*/
    
}




//特征CBCharacteristic中有一个属性是properties,是CBCharacteristicProperties类型的,我这里叫他权限,有read,write,notify,indicate等,这是一个可位移操作的枚举,如第一次打印出来的properties = 0xDE,转为二进制1101 1110
//有write时才可写,即向蓝牙发送指令CBCharacteristicPropertyWriteWithoutResponse写入有反馈,CBCharacteristicPropertyWrite写入后无反馈.反馈即提示是否写入成功,代理方法实现


//如果只想扫描到特定设备,可以用以下方法,前提是你知道服务的uuid.能够提供uuid为SeriveID6666(定义的宏)和SeriveID7777服务的设备.uuid可以由厂家提供,也可以先扫描所有设备,来获取服务.
//包含一个符合服务的设备即可被搜索到
/*CBUUID *uuid01 = [CBUUID UUIDWithString:SeriveID6666];
CBUUID *uuid02 = [CBUUID UUIDWithString:SeriveID7777];
NSArray *serives = [NSArray arrayWithObjects:uuid01, uuid02, nil];
[_cbManager scanForPeripheralsWithServices:serives options:nil];
*/
//性能优化 当扫描到或连接到指定设备后,取消扫描



//中心读取外设实时数据   特征注册通知后，会回调此方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    DLog(@"中心读取外设实时数据 %@ >>>>>>>>> UUID:%@", characteristic.value, characteristic.UUID);
    
    //[peripheral readValueForCharacteristic:characteristic];
    
    // Notification has started
    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];
        
    } else { // Notification has stopped
        // so disconnect from the peripheral
        DLog(@"通知停止 %@.  Disconnecting", characteristic);
        //DLog(@"%@",[NSString stringWithFormat:@"Notification stopped on %@.  Disconnecting", characteristic]);
        //[self.manager cancelPeripheralConnection:self.peripheral];
    }
}


//发送到外设数据成功的回调
//用于检测中心向外设写数据是否成功
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (error) {
        NSLog(@"APP发送数据失败:%@    特征UUID:%@",error.localizedDescription, characteristic.UUID);
    }else{
        NSLog(@"APP向设备发送数据成功   特征UUID:%@",characteristic.UUID);
    }
    
}

//收到外部设备发来的消息会触发  接收硬件返回的数据  不论是read和notify,获取数据都是从这个方法中读取。
//蓝牙接收到外设发来的数据时调用,数据主要在这里解析
//更新特征的value的时候会调用 （凡是从蓝牙传过来的数据都要经过这个回调，简单的说这个方法就是你拿数据的唯一方法） 你可以判断是否
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    
    //characteristic.value是NSData类型的，具体开发时，会根据开发协议去解析数据
    NSData *data = characteristic.value;
    NSLog(@">>>>>>>>>>>>>>>>");
   // NSLog(@"服务：%@",characteristic);
    NSLog(@"获取外设发来的数据（特征值）:%@    UUID:%@",data, characteristic.UUID);
    //根据协议解析数据
    //因为数据是异步返回的,我并不知道现在返回的数据是是哪种数据,返回的数据中应该会有标志位来识别是哪种数据;
    //如下图,我的设备发来的是8byte数据,收到蓝牙的数据后,打印characteristic.value:
    //获取外设发来的数据:<0af37ab219b0>
    //解析数据,判断首尾数据为a0何b0,即为mac地址,不同设备协议不同
    
    
    
    
    if (data.length == 0) {
        return;
    }
    //转成字节   字节数组，长度为几就有几个字节
    Byte *resultByte = (Byte *)data.bytes;
    
    for(int i=0;i<[data length];i++)
        printf("resultByte[%d] = %#x\n",i,resultByte[i]);  //带0x前缀的打印
    
    /*
    data == <4170706c 6520496e 63>
    resultByte == "Apple Inc"; （0x0000000174225a50 "Apple Inc"）
    resultByte[0] == 'A'
    resultByte[1] == 'p'
    resultByte[4] == 'e'
    resultByte[7] == 'n'
     */
    
   // DLog(@"%#x",'A' & 0xff);  //字符转16进制  'A' = 65
    
    //一位十六进制代表四位二进制.一个字节八个比特,就是八个二进制位 四个二进制数最大表示为15,就是一个16进制数,所以八位可以表示成两个16进制的数!
    //1个字节是8位，二进制8位：xxxxxxxx 范围从,00000000－11111111，表示0到255。一位16进制数（对应二进制是1111）最多只表示到15（对应16进制的F），要表示到255,就还需要第二位。
    //所以1个字节＝2个16进制字符
    
    //16进制变十进制：f表示15。第n位的权值为16的n次方，由右到左从0位起。
    //0xff = 15*16^1 + 15*16^0 = 255
    //16进制变二进制再变十进制：
    //0xff = 1111 1111 = 2^8 - 1 = 255
    
    
//    //获得设备基本信息请求
////    if (byte[0] == 0x02 && byte[1] == 0x01)
////    {
//        unichar c = resultByte[7];
//        NSString *str = [NSString stringWithFormat:@"%c",c];
//        //获取电池的状态
//    if (resultByte[0] == 0x41) {
//        DLog(@"'A' == 0x41 >>>>>>>>");
//    }
//    if (resultByte[0] == 'A') {
//        DLog(@"'A' == 'A' >>>>");
//    }
//        if ([str isEqualToString:@"n"])
//        {
//            NSLog(@"电池正常>>>>");
//        }
//        else if (resultByte[7] == 0x01)
//        {
//            NSLog(@"正在充电");
//        }
//        else if (resultByte[7] == 0x02)
//        {
//            NSLog(@"电池充满");
//        }
//    //}
    
    
#if 0
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF02"]]) {
        
        NSData *originData = characteristic.value;
        if (originData.length == 0) {
            return;
        }
        //转成字节
        Byte *resultByte = (Byte *)originData.bytes;
        
        if (resultByte[1] == 0) {
            switch (resultByte[0]) {
                case 3: // 加解锁
                {
                    if (resultByte[2] == 0) {
                        // [self updateLog:@"撤防成功!!!"];
                    }else if (resultByte[2] == 1) {
                        //  [self updateLog:@"设防成功!!!"];
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }else if (resultByte[1] == 1) {
            [NXAPublicClass showMessage:@"未知错误"];
        }else if (resultByte[1] == 2) {
            [NXAPublicClass showMessage:@"鉴权失败"];
        }
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF04"]]) {
        NSData * data = characteristic.value;
        Byte * resultByte = (Byte *)[data bytes];
        
        for(int i=0;i<[data length];i++)
            printf("testByteFF04[%d] = %d\n",i,resultByte[i]);
        
        if (resultByte[0] == 0) {
            // 未绑定 -》写鉴权码
            [self updateLog:@"当前车辆未绑定，请鉴权"];
            [self authentication];  // 鉴权
            [self writePassword:nil newPw:nil];
        }else if (resultByte[0] == 1) {
            // 已绑定 -》鉴权
            [self updateLog:@"当前车辆已经绑定，请鉴权"];
            [self writePassword:nil newPw:nil];
        }else if (resultByte[0] == 2) {
            // 允许绑定
            [self updateLog:@"当前车辆允许绑定"];
        }
    }
#endif
    
    
}

////搜索到Characteristic的Descriptors
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //打印出Characteristic和他的Descriptors
   // NSLog(@"characteristic uuid:%@",characteristic.UUID);
    for (CBDescriptor *d in characteristic.descriptors) {
        NSLog(@"搜索描述符：Descriptor uuid:%@",d.UUID);
        
        //获取描述符的值   会触发  didUpdateValueForDescriptor 这个代理方法
        [peripheral readValueForDescriptor:d];
    }
}

////获取到Descriptors的值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    NSLog(@"描述符的值：descriptor uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}



//以下为非代理方法

//5. 写数据  把数据写到Characteristic中
-(void)writeCharacteristic:(CBPeripheral *)peripheral
            characteristic:(CBCharacteristic *)characteristic
                     value:(NSData *)value{
    
    //打印出 characteristic 的权限，可以看到有很多种，这是一个NS_OPTIONS，就是可以同时用于好几个值，常见的有read，write，notify，indicate，知知道这几个基本就够用了，前连个是读写权限，后两个都是通知，两种不同的通知方式。
    
     
    
    NSLog(@"%lu", (unsigned long)characteristic.properties);
    
    
    //写数据
    //只有 characteristic.properties 有write的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyWrite){
        /*
         最好一个type参数可以为CBCharacteristicWriteWithResponse或type:CBCharacteristicWriteWithResponse,区别是是否会有反馈
         */
        /*
         参数1：发送到外设的数据
         参数2：特征
         参数3：需要response?
         */
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }else{
        NSLog(@"该字段不可写！");
    }
    
}


//6. 订阅Characteristic的通知
//设置通知
-(void)notifyCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic{
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    
}

//取消通知
-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral
                   characteristic:(CBCharacteristic *)characteristic{
    
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}



//7.   停止扫描并断开连接
-(void)disconnectPeripheral:(CBCentralManager *)centralManager
                 peripheral:(CBPeripheral *)peripheral{
    //停止扫描
    [centralManager stopScan];
    //断开连接
    [centralManager cancelPeripheralConnection:peripheral];
}



//鉴权
- (NSArray *)authentication
{
    //1) 时间戳    DWORD  4字节
    //DWORD 就是 Double Word， 每个word为2个字节的长度，DWORD 双字即为4个字节，每个字节是8位，共32位
    
    //short int (内存中占16位);2个字节.  int(内存中占32位);4个字节.  long int(内存中占64位);8个字节.   long long(内存中占64位);8个字节
    //float ：4个字节.   double：8个字节.   long double：16个字节
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    
    //double型态的数转换成byte数组
    Byte *p = (Byte *)&timeInterval;
   // NSData *data = [NSData dataWithBytes:<#(nullable const void *)#> length:<#(NSUInteger)#>]
    for (int i =0; *(p+i) != '\0'; i++) {
        DLog(@"%#x",*(p+i));
    }
    

    
    //2) 计时终端编号 BYTE[16]    证书口令 BYTE[12]
    NSString *str = @"47730371451856982S1925";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[data bytes];
    for (int i = 0; i < 37; i++) {
        //DLog(@"bytes[%d]%#x",i, bytes[i]);
    }
    
    
    //3) 终端证书  STRING  由计时平台向全国驾培平台申请(字节数<=4096 Bytes)
    
    
    NSArray *arr = @[];
    
    DLog(@"%@",arr);
    
    return arr;
}




//签到
- (NSArray *)signData
{
    /*
    教练一
    教练编号：00100046
    教练统一编号：2435164466931143
    统一培训机构编号：3346322552663682
    教练名称：大邓子
    身份证号：530825198004234500
    执教类别:C1
    准驾车型:C1
    手机号：18653241254
    
    教练二
    教练编号：00100045
    教练统一编号：4835105795891521
    统一培训机构编号：3346322552663682
    教练名称：大李子
    身份证号：45030019760310926X
    执教类别:C1
    准驾车型:C1
    手机号：18752632569
    */
    
    
    //DLog(@"%#x",'A' & 0xff);  //字符转16进制  'A' = 65
    
    NSString *idCardStr = @"530825198004234500";
    NSString *coachIDStr = @"2435164466931143";
    NSString *carTypeStr = @"C1";
    
//    NSData *idCard = [self hexToBytes:@"530825198004234500"];
//    NSData *coachID = [self hexToBytes:@"2435164466931143"];
//    NSData *carType = [self hexToBytes:@"C1"];
    //NSData *data = [self hexToBytes:@"53082519800423450024351644669311432435164466931143"];
    
    Byte idcardByte[18];
    Byte coachIdByte[16];
    Byte carTypeByte[2];
    
    const char *s = [idCardStr UTF8String];
    for (int i = 0; i < idCardStr.length; i++) {
        char c = *(s+i);
        idcardByte[i] = c & 0xff;
    }
    
    const char *s1 = [coachIDStr UTF8String];
    for (int i = 0; *(s1+i)!= '\0'; i++) {
        char c = *(s1+i);
        coachIdByte[i] = c & 0xff;
    }
    
    const char *s2 = [carTypeStr UTF8String];
    for (int i = 0; *(s2+i)!= '\0'; i++) {
        char c = *(s2+i);
        carTypeByte[i] = c & 0xff;
    }
    
    
    Byte firstByte[20] = {0xF5, 0x5F, 0x0B, 0x00, 0x01, 0x0D};
    Byte secondByte[20] = {0xF5, 0x5F, 0x0B, 0x00, 0x02, 0x0D};
    Byte thirdByte[17] = {0xF5, 0x5F, 0x0B, 0x00, 0x00, 0x0A};
    
    for (int i = 0; i < 13; i++) {
        firstByte[i+6] = idcardByte[i];
    }
    //firstByte[19] =
    for (int i = 0; i < 5; i++) {
        secondByte[i+6] = idcardByte[13+i];
    }
    for (int i = 0; i < 13-5; i++) {
        secondByte[i+6+5] = coachIdByte[i];
    }
    //secondByte[19] =
    for (int i = 0; i < 16-(13-5); i++) {
        thirdByte[i+6] = coachIdByte[16-(13-5)+i];
    }
    for (int i = 0; i < 2; i++) {
        thirdByte[8+i] = carTypeByte[i];
    }
    
    NSArray *arr = @[[NSData dataWithBytes:firstByte length:20], [NSData dataWithBytes:secondByte length:20], [NSData dataWithBytes:thirdByte length:17]];
    
    return arr;
    
    
//    //1. 向特征里面写数据
//    Byte b[] = {0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA0};
//    NSData *data = [NSData dataWithBytes:&b length:8];
//    Byte byte[1];
//    byte[0] = 0x0B;
//    [peripheral writeValue:[NSData dataWithBytes:byte length:1] forCharacteristic:c type:CBCharacteristicWriteWithResponse];
}


- (void)signDataTest
{
    NSString *str = @"02435164466931143530825198004234500C1";
    
    //废物方法
    //1. 字符串转成NSData   @"C1" -> <0c01>   (0x0c, 0x01)
    NSData *data = [self hexToBytes:str];
    Byte *byte = (Byte *)data.bytes;   //byte[37]
    for(int i=0;i<37;i++)
        printf("byte[%d] = %#x\n",i,byte[i]);  //带0x前缀的打印
    
    
    
    //真正的方法
    //2. 字符串转NSData   @"C1" -> <4331>    (0x43, 0x31)
//    NSData *data2 = [str dataUsingEncoding:NSUTF8StringEncoding];
//    Byte *byte2 = (Byte *)data2.bytes;
//    for(int i=0;i<[data2 length];i++)
//        printf("byte2[%d] = %#x\n",i,byte2[i]);  //带0x前缀的打印
    
    
}

//ascii码   教练签到
- (NSArray *)signData3
{
    /*
    0~9 -> 48~57
    A~Z -> 65~90
    a~z -> 97~122
     */
    
    //教练一
    NSString *str = @"02435164466931143530825198004234500C1";
    
    //教练二
    NSString *str2 = @"0483510579589152145030019760310926XC1";
    
  //  DLog(@"%@",[self hexStringFromString:str]);
    
    NSData *data = [str2 dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[data bytes];
    for (int i = 0; i < 37; i++) {
        DLog(@"bytes[%d]%#x",i, bytes[i]);
    }
    
//    Byte byte2[37];
//    for(int i=0;i<[data length];i++)
//    {
//        byte2[i] = bytes[i]&0xff;
//    }
//    for (int i = 0; i < 37; i++) {
//        DLog(@"byte2[%d]%#x",i, byte2[i]);
//    }
//    
//    方法一：
//    Byte byte3[37];
//    const char *s = [str UTF8String];
//    for (int i = 0; i < str.length; i++) {
//        char c = *(s+i);
//        byte3[i] = c & 0xff;
//    }
//    for (int i = 0; i < 37; i++) {
//        DLog(@"byte3[%d]%#x",i, byte3[i]);
//    }
    
    //二：
//    const char *s2 = [carTypeStr UTF8String];
//    for (int i = 0; *(s2+i)!= '\0'; i++) {
//        char c = *(s2+i);
//        carTypeByte[i] = c & 0xff;
//    }
    
    
    Byte firstByte[20] = {0xF5, 0x5F, 0x0B, 0x00, 0x01, 0x0D};  //0x0D
    Byte secondByte[20] = {0xF5, 0x5F, 0x0B, 0x00, 0x02, 0x0D};
    Byte thirdByte[18] = {0xF5, 0x5F, 0x0B, 0x00, 0x00, 0x0B};   //0x0B
    
    Byte XOR1 = 0x0B^0x00^0x01^0x0D;  //....
    Byte XOR2 = 0x0B^0x00^0x02^0x0D;
    Byte XOR3 = 0x0B^0x00^0x00^0x0B;
    
    
    
    for (int i = 0; i < 13; i++) {
        firstByte[i+6] = bytes[i];
        XOR1 = XOR1^bytes[i];
        
        secondByte[i+6] = bytes[13+i];
        XOR2 = XOR2^bytes[13+i];
        
        if (i < 11) {
            thirdByte[i+6] = bytes[13*2+i];
            XOR3 = XOR3^bytes[13*2+i];    //.....
        }
    }
    
    firstByte[19] = XOR1;
    secondByte[19] = XOR2;
    thirdByte[17] = XOR3;
    
    
    for(int i=0;i<20;i++)
        printf("firstByte[%d] = %#x\n",i,firstByte[i]);  //带0x前缀的打印
    
    for(int i=0;i<20;i++)
        printf("secondByte[%d] = %#x\n",i,secondByte[i]);  //带0x前缀的打印
    
    for(int i=0;i<18;i++)
        printf("thirdByte[%d] = %#x\n",i,thirdByte[i]);  //带0x前缀的打印
    
    
    NSArray *arr = @[[NSData dataWithBytes:firstByte length:20], [NSData dataWithBytes:secondByte length:20], [NSData dataWithBytes:thirdByte length:18]];
    
    DLog(@"%@",arr);
    
    return arr;
}


//签退  ==================
- (NSArray *)signOut
{
    //教练一
    NSString *str = @"02435164466931143";
    
    //教练二
    NSString *str2 = @"04835105795891521";
    
    NSData *data = [str2 dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[data bytes];
    for (int i = 0; i < [data length]; i++) {
        DLog(@"bytes[%d]=%#x",i,bytes[i]);
    }
    
    Byte firstByte[20] = {0xF5, 0x5F, 0x0D, 0x00, 0x01, 0x0D};  //0x0D
    Byte secondByte[11] = {0xF5, 0x5F, 0x0D, 0x00, 0x00, 0x04};
    
    Byte XOR1 = 0x0D^0x00^0x01^0x0D;
    Byte XOR2 = 0x0D^0x00^0x00^0x04;
    
    
    for (int i = 0; i < 13; i++) {
        firstByte[i+6] = bytes[i];
        XOR1 = XOR1^bytes[i];
        
        if (i < 4) {
            secondByte[i+6] = bytes[13+i];
            XOR2 = XOR2^bytes[13+i];
        }
    }
    
    firstByte[19] = XOR1;
    secondByte[10] = XOR2;
    
    
    
    for(int i=0;i<20;i++)
        printf("firstByte[%d] = %#x\n",i,firstByte[i]);  //带0x前缀的打印
    
    for(int i=0;i<11;i++)
        printf("secondByte[%d] = %#x\n",i,secondByte[i]);  //带0x前缀的打印
    
    
    NSArray *arr = @[[NSData dataWithBytes:firstByte length:20], [NSData dataWithBytes:secondByte length:11]];
    
    DLog(@"%@",arr);
    
    return arr;
}



//学员签到 ========
- (void)studentSignIn
{
    
}




- (void)utility
{
    //NSString 转换成NSData 对象
    NSData* xmlData = [@"testdata" dataUsingEncoding:NSUTF8StringEncoding];
    
    //NSData 转换成NSString对象
    NSData * data;
    NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    
    //NSData 转换成char*
    NSData *data1;
    char *test=[data1 bytes];
    
    NSString *str = @"jfewi324356";
    const char *s = [str UTF8String];
    
    //char* 转换成NSData对象
    Byte* tempData = malloc(sizeof(Byte)*16);
    NSData *content=[NSData dataWithBytes:tempData length:16];
}



- (void)printAllUUID
{
    DLog(@"扫描到的所有服务>>>>>>>>>>>");
    for (CBService *service in self.servicesArray) {
        DLog(@"UUIDString = %@    UUID = %@   data:%@",service.UUID.UUIDString, service.UUID, service.UUID.data);
    }
//    DLog(@"当前连接设备能提供的所有服务");
//    for (CBService *service in self.peripheral.services) {
//        DLog(@"UUIDString = %@    UUID = %@",service.UUID.UUIDString, service.UUID);
//    }
    
    DLog(@"扫描到的所有特征>>>>>>>>>>>");
    for (CBCharacteristic *character in self.characteristicArray) {
        DLog(@"UUIDString = %@   UUID = %@    data:%@",character.UUID.UUIDString, character.UUID, character.UUID.data);
    }
}


//普通字符串转换为十六进制的  @"AA" -> @"4141"
- (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr]; 
    } 
    return hexStr; 
}


#pragma mark - ------------- 数据转换 -------------

//废物方法
//字符串转成NSData   @"C1" -> <0c01>   (0x0c, 0x01)
-(NSData *)hexToBytes:(NSString *)hexString {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx < hexString.length; idx++) {
        NSRange range = NSMakeRange(idx, 1);
        NSString* hexStr = [hexString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    
    return data;
}



#pragma mark - ------------- 懒加载 -------------

- (NSMutableArray *)peripheralArray
{
    if (!_peripheralArray) {
        _peripheralArray = [[NSMutableArray alloc]init];
    }
    return _peripheralArray;
}

- (NSMutableArray *)characteristicArray
{
    if (!_characteristicArray) {
        _characteristicArray = [[NSMutableArray alloc]init];
    }
    return _characteristicArray;
}

- (NSMutableArray *)servicesArray
{
    if (!_servicesArray) {
        _servicesArray = [[NSMutableArray alloc]init];
    }
    return _servicesArray;
}

- (NSMutableArray *)connectedPeripheralArray
{
    if (!_connectedPeripheralArray) {
        _connectedPeripheralArray = [[NSMutableArray alloc]init];
    }
    return _connectedPeripheralArray;
}


- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}




@end
