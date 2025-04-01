import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NTB Boxing',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    HomeContent(),
    QRCodeScannerPage(), // 체크인 탭: QR 스캔 기능
    ReservationScreen(), // 수업(예약) 탭 (예시)
    ProfileScreen(),     // 프로필 탭
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NTB Boxing'),
        centerTitle: true,
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: '체크인',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: '수업',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

/// 홈 탭 내용 (환영 메시지, 날짜 등)
class HomeContent extends StatelessWidget {
  final String today = DateFormat('yyyy년 MM월 dd일').format(DateTime.now());
  final String weekday = DateFormat('EEEE', 'ko_KR').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 상단 프로필 섹션
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[700]!, Colors.red[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('홍길동님',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text('NTB 복싱 멤버십',
                            style: TextStyle(
                                fontSize: 16, color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(today,
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                Text(weekday,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
          // 추가 홈 콘텐츠 (예시)
          Padding(
            padding: EdgeInsets.all(20),
            child: Text('홈 화면 콘텐츠',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

/// QR 코드 스캔 페이지 (체크인 탭)
class QRCodeScannerPage extends StatefulWidget {
  @override
  _QRCodeScannerPageState createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  String scannedResult = '';

  // mobile_scanner 6.x에서는 onDetect 콜백이 BarcodeCapture를 인자로 받습니다.
  void _onDetect(BarcodeCapture barcodeCapture) {
    // 스캔된 바코드 리스트에서 첫 번째 항목 사용
    final Barcode barcode = barcodeCapture.barcodes.first;
    final String code = barcode.rawValue ?? '';
    if (code.isNotEmpty && scannedResult != code) {
      setState(() {
        scannedResult = code;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('QR 코드 스캔 성공'),
          content: Text('스캔 결과: $code'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('체크인'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(20),
              color: Colors.black54,
              child: Text(
                scannedResult.isEmpty
                    ? 'QR 코드를 스캔해주세요'
                    : '결과: $scannedResult',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 수업(예약) 탭 (예시)
class ReservationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('수업 예약'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('수업 예약 화면', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

/// 프로필 탭
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
              ),
              SizedBox(height: 16),
              Text('홍길동',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 32),
              ListTile(
                leading: Icon(Icons.payment, color: Colors.redAccent),
                title: Text('결제현황'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.redAccent),
                title: Text('출석 현황'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.redAccent),
                title: Text('내 계정'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.privacy_tip, color: Colors.redAccent),
                title: Text('개인정보 정책'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.redAccent),
                title: Text('로그 아웃'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
