# NTB Membership App

NTB 멤버십 앱은 피트니스 클럽 회원들을 위한 종합 관리 시스템입니다. 수업 예약, 체크인, 회원 정보 관리 등 다양한 기능을 제공합니다.

## 주요 기능

### 1. 홈 화면
- 회원 프로필 정보 표시
- 오늘의 운동 통계 (예약 수업, 남은 수업, 체크인 현황)
- 추천 수업 목록
- 공지사항

### 2. 체크인 시스템
- QR 코드 스캐너를 통한 빠른 체크인
- 실시간 체크인 상태 확인

### 3. 수업 예약
- 다양한 수업 목록 제공
- 실시간 수강 가능 인원 확인
- 간편한 예약 프로세스

### 4. 프로필 관리
- 회원 정보 관리
- 결제 현황 확인
- 출석 현황 확인
- 계정 설정

## 기술 스택

- Flutter
- Dart
- QR Code Scanner
- Intl Package

## 시작하기

### 필수 조건
- Flutter SDK (최신 버전)
- Dart SDK
- Android Studio / VS Code
- Git

### 설치 방법

1. 저장소 클론
```bash
git clone https://github.com/yourusername/ntb_member.git
```

2. 프로젝트 디렉토리로 이동
```bash
cd ntb_member
```

3. 의존성 패키지 설치
```bash
flutter pub get
```

4. 앱 실행
```bash
flutter run
```

## 프로젝트 구조

```
lib/
├── main.dart              # 앱의 진입점
├── screens/              # 화면 위젯
│   ├── home_screen.dart
│   ├── check_in_screen.dart
│   ├── reservation_screen.dart
│   └── profile_screen.dart
├── widgets/              # 재사용 가능한 위젯
└── models/              # 데이터 모델
```

## 개발 가이드

### 코드 스타일
- Flutter 공식 스타일 가이드를 따릅니다.
- 모든 코드는 `flutter analyze`를 통과해야 합니다.

### 브랜치 전략
- main: 프로덕션 브랜치
- develop: 개발 브랜치
- feature/*: 새로운 기능 개발
- bugfix/*: 버그 수정

## 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

