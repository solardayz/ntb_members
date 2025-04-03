# NTB Members - 복싱 멤버십 관리 앱

<div align="center">
  <img src="assets/logo.png" alt="NTB Members Logo" width="200"/>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.19.0-blue.svg)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.3.0-blue.svg)](https://dart.dev)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

## 소개

NTB Members는 복싱장 회원들을 위한 모바일 애플리케이션입니다. QR 코드를 통한 출석체크, 수업 예약, 회원 정보 관리 등 다양한 기능을 제공합니다.

## 주요 기능

### 1. 회원 인증
- 이메일/비밀번호 로그인
- JWT 토큰 기반 인증
- 자동 로그인 유지

### 2. QR 코드 출석체크
- QR 코드 스캔을 통한 빠른 출석체크
- 출석 기록 조회
- 출석 통계 확인

### 3. 수업 예약
- 다양한 복싱 수업 목록 확인
- 실시간 수업 인원 확인
- 수업 상세 정보 조회
- 원클릭 예약

### 4. 프로필 관리
- 회원 정보 조회/수정
- 결제 현황 확인
- 출석 기록 조회
- 개인정보 관리

## 기술 스택

- **프레임워크**: Flutter 3.19.0
- **언어**: Dart 3.3.0
- **상태관리**: Provider
- **네트워크**: http package
- **로컬 저장소**: shared_preferences
- **UI 컴포넌트**: Material Design

## 설치 방법

1. Flutter 개발 환경 설정
```bash
flutter pub get
```

2. 앱 실행
```bash
flutter run
```

## 프로젝트 구조

```
lib/
├── main.dart              # 앱 진입점
├── screens/              # 화면 위젯
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   └── attendance_screen.dart
├── widgets/              # 재사용 가능한 위젯
├── models/              # 데이터 모델
├── services/            # API 서비스
└── utils/              # 유틸리티 함수
```

## API 엔드포인트

- 로그인: `POST /api/mobile/member/login`
- 출석체크: `POST /api/mobile/attendance/check-in`
- 출석 조회: `GET /api/mobile/attendance/member/{memberId}`

## 라이선스

이 프로젝트는 MIT 라이선스 하에 있습니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
