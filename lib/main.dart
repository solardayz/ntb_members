import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NTB Members',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://manage.ntbc.store/api/mobile/member/login'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && data['token'] != null) {
        // JWT 토큰과 회원 정보 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        await prefs.setString('member_name', data['username']);
        await prefs.setString('member_id', data['memberId'].toString());
        await prefs.setString('email', data['email']);
        await prefs.setString('phone_number', data['phoneNumber']);
        await prefs.setString('address', data['address']);
        await prefs.setString('age', data['age'].toString());
        // 로그인 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('환영합니다, ${data['username']}님!')),
        );

        // 홈스크린으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // 로그인 실패
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? '로그인에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버 연결에 실패했습니다.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        // 홈스크린으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 로고 또는 타이틀
                Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.red,
                ),
                SizedBox(height: 32),
                Text(
                  'NTB Members',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48),
                // 이메일 입력 필드
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: '이메일',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력해주세요';
                    }
                    if (!value.contains('@')) {
                      return '올바른 이메일 형식이 아닙니다';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // 비밀번호 입력 필드
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                // 로그인 버튼
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          '로그인',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
                SizedBox(height: 16),
                // 비밀번호 찾기 링크
                TextButton(
                  onPressed: () {
                    // TODO: 비밀번호 찾기 화면으로 이동
                  },
                  child: Text('비밀번호를 잊으셨나요?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
  bool checkedInToday = false; // 서버에서 받아와야지 이건
  int currentPoint = 120;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final prefs = snapshot.data!;
        final memberName = prefs.getString('member_name') ?? '회원님';

        return SingleChildScrollView(
          child: Column(
            children: [
              buildPointBanner(checkedInToday, currentPoint),
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
                          backgroundImage:
                          NetworkImage('https://i.pravatar.cc/300'),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$memberName님',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'NTB 복싱 멤버십',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      today,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      weekday,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // 메인 컨텐츠
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 오늘의 운동 통계
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 복싱',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                  '예약 수업', '2', Icons.fitness_center),
                              _buildStatItem(
                                  '남은 수업', '8', Icons.fitness_center),
                              _buildStatItem('체크인', '1', Icons.check_circle),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    // 추천 수업
                    Text(
                      '추천 수업',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 200,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildRecommendedClass('복싱 기초', '09:00', '김복서'),
                          _buildRecommendedClass('스파링', '10:30', '이복서'),
                          _buildRecommendedClass('헤비백', '14:00', '박복서'),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    // 공지사항
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '공지사항',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 15),
                          _buildNoticeItem('2024년 3월 복싱 수업 일정 안내'),
                          _buildNoticeItem('신규 회원 복싱 장갑 제공 이벤트'),
                          _buildNoticeItem('복싱장 시설 점검 일정 안내'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.red, size: 30),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedClass(String name, String time, String instructor) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Center(
              child: Icon(Icons.fitness_center, size: 40, color: Colors.red),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  instructor,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeItem(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget buildPointBanner(bool checkedInToday, int currentPoint) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: checkedInToday ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            checkedInToday ? Icons.check_circle : Icons.local_fire_department,
            color: checkedInToday ? Colors.green : Colors.deepOrange,
            size: 32,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  checkedInToday
                      ? '오늘 출석 완료!'
                      : '🔥 오늘 출석하고 10P 받기!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: checkedInToday ? Colors.green[700] : Colors.orange[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  checkedInToday
                      ? '현재 포인트: ${currentPoint}P'
                      : '출석하면 포인트가 적립됩니다!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          if (!checkedInToday)
            ElevatedButton(
              onPressed: () {
                // 출석 처리 API 호출 등
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('출석하기'),
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
  bool _isLoading = false;

  Future<void> _checkIn(String qrCode) async {
    if (!qrCode.contains('manage.ntbc.store')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('올바른 QR 코드가 아닙니다.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final memberId = prefs.getString('member_id');
      final phoneNumber = prefs.getString('phone_number');

      final response = await http.post(
        Uri.parse('https://manage.ntbc.store/api/mobile/attendance/check-in'),
        headers: await getAuthHeaders(),
        body: json.encode({
          'memberId': int.parse(memberId!),
          'phoneNumber': phoneNumber,
        }),
      );

      final data = json.decode(utf8.decode(response.bodyBytes));
      
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('출석체크가 완료되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? '출석체크에 실패했습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버 연결에 실패했습니다.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDetect(BarcodeCapture barcodeCapture) {
    final Barcode barcode = barcodeCapture.barcodes.first;
    final String code = barcode.rawValue ?? '';
    if (code.isNotEmpty && scannedResult != code) {
      setState(() {
        scannedResult = code;
      });
      _checkIn(code);
    }
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
          Container(
            color: Colors.black54,
            child: CustomPaint(
              painter: ScannerOverlayPainter(),
            ),
          ),
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red,
                  width: 4,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              color: Colors.black54,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    scannedResult.isEmpty
                        ? 'QR 코드를 스캔해주세요'
                        : '결과: $scannedResult',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  if (_isLoading)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 스캐너 오버레이를 그리는 CustomPainter 클래스
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // 전체 화면을 어둡게
    canvas.drawRect(Offset.zero & size, paint);

    // 스캔 영역을 투명하게
    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 300,
      height: 300,
    );
    canvas.drawRect(scanArea, Paint()..blendMode = BlendMode.clear);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// 수업(예약) 탭 (예시)
class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final List<Map<String, dynamic>> _classes = [
    {
      'id': 1,
      'name': '기본기',
      'instructor': '김복서',
      'time': '09:00 - 10:00',
      'capacity': 20,
      'currentParticipants': 15,
      'imageUrl': 'https://example.com/boxing_basic.jpg',
      'description': '복싱의 기본 자세와 기술을 배우는 초급자용 수업입니다.',
      'drills': [
        '기본 스탠스 연습',
        '자비 연습',
        '스트레이트 펀치',
        '훅 펀치',
        '어퍼컷',
      ],
      'difficulty': '초급',
      'equipment': ['복싱 장갑', '붕대', '마우스피스'],
    },
    {
      'id': 2,
      'name': '기본 콤보',
      'instructor': '이복서',
      'time': '10:30 - 11:30',
      'capacity': 15,
      'currentParticipants': 12,
      'imageUrl': 'https://example.com/basic_combo.jpg',
      'description': '기본 펀치들의 다양한 콤비네이션을 배우는 초급자용 수업입니다.',
      'drills': [
        '1-2 콤보',
        '1-2-3 콤보',
        '1-2-3-4 콤보',
        '기본 스탭',
        '기본 방어',
      ],
      'difficulty': '초급',
      'equipment': ['복싱 장갑', '붕대', '마우스피스'],
    },
    {
      'id': 3,
      'name': '중급 콤보',
      'instructor': '박복서',
      'time': '14:00 - 15:00',
      'capacity': 12,
      'currentParticipants': 8,
      'imageUrl': 'https://example.com/intermediate_combo.jpg',
      'description': '복잡한 콤비네이션과 전술을 배우는 중급자용 수업입니다.',
      'drills': [
        '고급 콤비네이션',
        '카운터 펀치',
        '클린치',
        '중급 스탭',
        '중급 방어',
      ],
      'difficulty': '중급',
      'equipment': ['복싱 장갑', '붕대', '마우스피스', '헤드기어'],
    },
    {
      'id': 4,
      'name': '상급 콤보',
      'instructor': '최복서',
      'time': '15:30 - 16:30',
      'capacity': 10,
      'currentParticipants': 6,
      'imageUrl': 'https://example.com/advanced_combo.jpg',
      'description': '전문적인 복싱 기술과 전술을 배우는 고급자용 수업입니다.',
      'drills': [
        '전문 콤비네이션',
        '고급 카운터',
        '클린치 전술',
        '고급 스탭',
        '고급 방어',
      ],
      'difficulty': '고급',
      'equipment': ['복싱 장갑', '붕대', '마우스피스', '헤드기어'],
    },
    {
      'id': 5,
      'name': '스파링',
      'instructor': '정복서',
      'time': '17:00 - 18:00',
      'capacity': 8,
      'currentParticipants': 6,
      'imageUrl': 'https://example.com/sparring.jpg',
      'description': '실전 스파링을 통한 전술과 방어 기술을 배우는 중급자용 수업입니다.',
      'drills': [
        '스파링 전술',
        '방어 기술',
        '카운터 펀치',
        '클린치',
        '스파링 매치',
      ],
      'difficulty': '중급',
      'equipment': ['복싱 장갑', '붕대', '마우스피스', '헤드기어', '보호대'],
    },
    {
      'id': 6,
      'name': '헤비백',
      'instructor': '한복서',
      'time': '18:30 - 19:30',
      'capacity': 10,
      'currentParticipants': 7,
      'imageUrl': 'https://example.com/heavybag.jpg',
      'description': '헤비백을 이용한 파워와 스피드 훈련을 하는 고급자용 수업입니다.',
      'drills': [
        '파워 펀치',
        '스피드 훈련',
        '콤비네이션',
        '인터벌 트레이닝',
        '파워 스트라이크',
      ],
      'difficulty': '고급',
      'equipment': ['복싱 장갑', '붕대', '마우스피스', '헤비백'],
    },
    {
      'id': 7,
      'name': '복싱 피트니스',
      'instructor': '김복서',
      'time': '20:00 - 21:00',
      'capacity': 15,
      'currentParticipants': 10,
      'imageUrl': 'https://example.com/boxing_fitness.jpg',
      'description': '복싱을 통한 체력 향상과 다이어트를 위한 수업입니다.',
      'drills': [
        '기본 스탠스',
        '기본 펀치',
        '유산소 운동',
        '근력 운동',
        '스트레칭',
      ],
      'difficulty': '초급',
      'equipment': ['복싱 장갑', '붕대', '마우스피스'],
    },
    {
      'id': 8,
      'name': '여성 전용 복싱',
      'instructor': '이복서',
      'time': '10:00 - 11:00',
      'capacity': 12,
      'currentParticipants': 8,
      'imageUrl': 'https://example.com/women_boxing.jpg',
      'description': '여성만을 위한 맞춤형 복싱 수업입니다.',
      'drills': [
        '기본 스탠스',
        '기본 펀치',
        '자기방어',
        '체력 향상',
        '스트레칭',
      ],
      'difficulty': '초급',
      'equipment': ['복싱 장갑', '붕대', '마우스피스'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('복싱 수업 예약'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _classes.length,
        itemBuilder: (context, index) {
          final classData = _classes[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _showClassDetails(context, classData),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                classData['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '강사: ${classData['instructor']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              classData['time'],
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${classData['currentParticipants']}/${classData['capacity']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(classData['difficulty']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        classData['difficulty'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '초급':
        return Colors.green;
      case '중급':
        return Colors.orange;
      case '고급':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showClassDetails(BuildContext context, Map<String, dynamic> classData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  classData['name'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  classData['description'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  '수업 정보',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                _buildInfoRow(Icons.access_time, '시간', classData['time']),
                _buildInfoRow(Icons.person, '강사', classData['instructor']),
                _buildInfoRow(
                    Icons.people,
                    '수강 인원',
                    '${classData['currentParticipants']}/${classData['capacity']}'),
                _buildInfoRow(Icons.fitness_center, '난이도',
                    classData['difficulty']),
                SizedBox(height: 24),
                Text(
                  '필요 장비',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (classData['equipment'] as List<String>)
                      .map((item) => Chip(
                            label: Text(item),
                            backgroundColor: Colors.red[50],
                            labelStyle: TextStyle(color: Colors.red),
                          ))
                      .toList(),
                ),
                SizedBox(height: 24),
                Text(
                  '주요 드릴',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                ...(classData['drills'] as List<String>).map((drill) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(drill),
                        ],
                      ),
                    )),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showReservationDialog(context, classData);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        '예약하기',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showReservationDialog(
      BuildContext context, Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('예약 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${classData['name']} 수업을 예약하시겠습니까?'),
            SizedBox(height: 16),
            Text('수업 시간: ${classData['time']}'),
            Text('강사: ${classData['instructor']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 예약 처리 로직 추가
            },
            child: Text('예약하기'),
          ),
        ],
      ),
    );
  }
}

/// 프로필 탭
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final prefs = snapshot.data!;
        final memberName = prefs.getString('member_name') ?? '회원님';
        final email = prefs.getString('email') ?? '';
        final phoneNumber = prefs.getString('phone_number') ?? '';
        final address = prefs.getString('address') ?? '';
        final age = prefs.getString('age') ?? '';

        return SingleChildScrollView(
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
                Text(memberName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(email,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                SizedBox(height: 32),
                ListTile(
                  leading: Icon(Icons.payment, color: Colors.redAccent),
                  title: Text('결제 현황'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PaymentHistoryScreen()),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.calendar_today, color: Colors.redAccent),
                  title: Text('출석 현황'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AttendanceHistoryScreen()),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.account_circle, color: Colors.redAccent),
                  title: Text('내 계정'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyAccountScreen()),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.lock, color: Colors.redAccent),
                  title: Text('비밀번호 변경'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.privacy_tip, color: Colors.redAccent),
                  title: Text('개인정보 처리방침'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.redAccent),
                  title: Text('로그 아웃'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () => logout(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MyAccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final prefs = snapshot.data!;
        final memberName = prefs.getString('member_name') ?? '';
        final email = prefs.getString('email') ?? '';
        final phoneNumber = prefs.getString('phone_number') ?? '';
        final address = prefs.getString('address') ?? '';
        final age = prefs.getString('age') ?? '';

        return Scaffold(
          appBar: AppBar(
            title: Text('내 계정'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                ),
                SizedBox(height: 24),
                _buildInfoCard(
                  '기본 정보',
                  [
                    _buildInfoRow(Icons.person, '이름', memberName),
                    _buildInfoRow(Icons.email, '이메일', email),
                    _buildInfoRow(Icons.phone, '전화번호', phoneNumber),
                    _buildInfoRow(Icons.location_on, '주소', address),
                    _buildInfoRow(Icons.cake, '나이', '$age세'),
                  ],
                ),
                SizedBox(height: 16),
                _buildInfoCard(
                  '멤버십 정보',
                  [
                    _buildInfoRow(Icons.fitness_center, '체육관', 'NTB 복싱'),
                    _buildInfoRow(Icons.calendar_today, '가입일', '2024년 3월 1일'),
                    _buildInfoRow(Icons.star, '멤버십 등급', '일반 회원'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final memberId = prefs.getString('member_id');

      final response = await http.post(
        Uri.parse('https://manage.ntbc.store/api/mobile/member/change-password'),
        headers: await getAuthHeaders(),
        body: json.encode({
          'memberId': int.parse(memberId!),
          'currentPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text,
        }),
      );

      final data = json.decode(utf8.decode(response.bodyBytes));
      
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀번호가 변경되었습니다.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? '비밀번호 변경에 실패했습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버 연결에 실패했습니다.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('비밀번호 변경'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: '현재 비밀번호',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '현재 비밀번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: '새 비밀번호',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '새 비밀번호를 입력해주세요';
                  }
                  if (value.length < 8) {
                    return '비밀번호는 8자 이상이어야 합니다';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '새 비밀번호 확인',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '새 비밀번호를 다시 입력해주세요';
                  }
                  if (value != _newPasswordController.text) {
                    return '비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        '비밀번호 변경',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // print('페이지 로딩 시작: $url'); // 디버깅 로그
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            // print('페이지 로딩 완료: $url'); // 디버깅 로그
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // print('웹뷰 에러: ${error.description}');
            // print('에러 코드: ${error.errorCode}');
            // print('에러 타입: ${error.errorType}');
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://ntbc.store/privacy/privacy.html'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('개인정보 처리방침'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    '페이지를 불러오는데 실패했습니다.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '잠시 후 다시 시도해주세요.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _controller.reload();
                    },
                    child: Text('다시 시도'),
                  ),
                ],
              ),
            )
          else
            WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    '페이지를 불러오는 중...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AttendanceHistoryScreen extends StatefulWidget {
  @override
  _AttendanceHistoryScreenState createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  List<Map<String, dynamic>> _attendanceList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
  }

  Future<void> _loadAttendanceHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memberId = prefs.getString('member_id');
      // print('회원 ID: $memberId'); // 디버깅 로그

      final response = await http.get(
        Uri.parse('https://manage.ntbc.store/api/mobile/attendance/member/$memberId'),
        headers: await getAuthHeaders(),
      );

      // print('서버 응답: ${response.body}'); // 디버깅 로그

      final data = json.decode(utf8.decode(response.bodyBytes));
      // print('파싱된 데이터: $data'); // 디버깅 로그

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> attendanceData = data['data'];
        // print('출석 데이터: $attendanceData'); // 디버깅 로그
        
        setState(() {
          _attendanceList = attendanceData.map((item) => Map<String, dynamic>.from(item)).toList();
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? '출석 기록을 불러오는데 실패했습니다.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // print('에러 발생: $e'); // 디버깅 로그
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버 연결에 실패했습니다.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('출석 현황'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _attendanceList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '출석 기록이 없습니다.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _attendanceList.length,
                  itemBuilder: (context, index) {
                    final attendance = _attendanceList[index];
                    // print('출석 항목: $attendance'); // 디버깅 로그
                    final checkInTime = DateTime.parse(attendance['checkInTime']);
                    final formattedDate = DateFormat('yyyy년 MM월 dd일 HH:mm').format(checkInTime);

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red[100],
                          child: Icon(Icons.check_circle, color: Colors.red),
                        ),
                        title: Text(formattedDate),
                        subtitle: Text(attendance['companyName']),
                        trailing: Text(attendance['phoneNumber']),
                      ),
                    );
                  },
                ),
    );
  }
}

class PaymentHistoryScreen extends StatefulWidget {
  @override
  _PaymentHistoryScreenState createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<Map<String, dynamic>> _paymentList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Future<void> _loadPaymentHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memberId = prefs.getString('member_id');
      // print('회원 ID: $memberId');

      final response = await http.get(
        Uri.parse('https://manage.ntbc.store/api/mobile/payment/member/$memberId'),
        headers: await getAuthHeaders(),
      );

      final data = json.decode(utf8.decode(response.bodyBytes));
      
      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> paymentData = data['data'];
        
        setState(() {
          _paymentList = paymentData.map((item) => Map<String, dynamic>.from(item)).toList();
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? '결제 내역을 불러오는데 실패했습니다.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // print('에러 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버 연결에 실패했습니다.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatAmount(double amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
  }

  String _formatPaymentDate(String date) {
    return DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('결제 내역'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _paymentList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '결제 내역이 없습니다.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _paymentList.length,
                  itemBuilder: (context, index) {
                    final payment = _paymentList[index];
                    final isCompleted = payment['paymentCompleted'];

                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.green[50] : Colors.red[50],
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isCompleted ? Colors.green[100] : Colors.red[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCompleted ? Icons.check_circle : Icons.pending,
                                    color: isCompleted ? Colors.green : Colors.red,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatAmount(payment['amount']),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        isCompleted ? '결제완료' : '미결제',
                                        style: TextStyle(
                                          color: isCompleted ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(Icons.calendar_today, '결제일', _formatPaymentDate(payment['paymentDate'])),
                                _buildInfoRow(Icons.timer, '결제 기간', '${payment['numberOfMonths']}개월'),
                                _buildInfoRow(Icons.business, '지점명', payment['companyName']),
                                if (payment['paymentDesc'].isNotEmpty)
                                  _buildInfoRow(Icons.description, '결제 설명', payment['paymentDesc']),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// API 요청에 사용할 헤더를 가져오는 함수
Future<Map<String, String>> getAuthHeaders() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');
  
  return {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer $token',
  };
}

// 로그아웃 함수
Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('jwt_token');
  await prefs.remove('member_name');
  
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}
