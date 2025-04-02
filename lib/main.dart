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
                      backgroundImage:
                      NetworkImage('https://i.pravatar.cc/300'),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '홍길동님',
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
          // 카메라 피드 전체 화면
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // 스캔 영역 외 부분을 어둡게 처리
          Container(
            color: Colors.black54,
            child: CustomPaint(
              painter: ScannerOverlayPainter(),
            ),
          ),
          // 중앙에 네모 상자 오버레이 (스캔 영역)
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
          // 하단 스캔 결과 안내 텍스트
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              color: Colors.black54,
              child: Text(
                scannedResult.isEmpty
                    ? 'QR 코드를 스캔해주세요'
                    : '결과: $scannedResult',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
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
      'name': '복싱 기초',
      'instructor': '김복서',
      'time': '09:00 - 10:00',
      'capacity': 20,
      'currentParticipants': 15,
      'price': '30,000원',
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
      'name': '스파링',
      'instructor': '이복서',
      'time': '10:30 - 11:30',
      'capacity': 15,
      'currentParticipants': 12,
      'price': '35,000원',
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
      'equipment': ['복싱 장갑', '붕대', '마우스피스', '헤드기어'],
    },
    {
      'id': 3,
      'name': '헤비백',
      'instructor': '박복서',
      'time': '14:00 - 15:00',
      'capacity': 10,
      'currentParticipants': 8,
      'price': '40,000원',
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
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            classData['price'],
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
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
                      padding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                        _getDifficultyColor(classData['difficulty']),
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

  void _showClassDetails(
      BuildContext context, Map<String, dynamic> classData) {
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
                _buildInfoRow(
                    Icons.person, '강사', classData['instructor']),
                _buildInfoRow(
                    Icons.people,
                    '수강 인원',
                    '${classData['currentParticipants']}/${classData['capacity']}'),
                _buildInfoRow(Icons.attach_money, '가격', classData['price']),
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
            Text('가격: ${classData['price']}'),
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
