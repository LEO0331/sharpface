# 男士 AI 護膚分析儀 (SharpFace)

Flutter + Firebase + OpenAI 的男士膚質分析 App。

## v1 上線檢查表
- [v1-launch-checklist.md](docs/v1-launch-checklist.md)

## 功能
- AI 膚質分析（GPT Vision，JSON 結構化輸出）
- Email/Password 註冊登入
- 訪客 SMS OTP 驗證（Firebase Phone，測試電話號碼可用）
- 產品推薦與導購（贊助商品置頂、點擊回寫）
- 歷史膚質曲線（7天/30天/全部）
- Admin Dashboard（總用戶、今日分析次數、最高點擊產品）

## 環境需求
- Flutter stable
- Firebase 專案（Auth + Firestore）
- OpenAI API Key

## 本機啟動
```bash
flutter pub get
flutter run --dart-define=OPENAI_API_KEY=your_openai_api_key
```

## 測試與覆蓋率
```bash
flutter test
flutter test --coverage
```

### E2E（integration_test）
```bash
flutter test integration_test/app_e2e_test.dart
```

### E2E（Patrol）
```bash
# 先檢查 Patrol 環境
dart run patrol_cli:main doctor

# Android（請先啟動 emulator 或接實機）
dart run patrol_cli:main test --target patrol_test/smoke_test.dart --device <android_device_id>

# iOS（請先啟動 simulator 或接實機）
dart run patrol_cli:main test --target patrol_test/smoke_test.dart --device <ios_device_id>

# Auth flow 測試
dart run patrol_cli:main test --target patrol_test/auth_flow_test.dart --device <device_id>

# Drawer 權限顯示測試（未登入）
dart run patrol_cli:main test --target patrol_test/access_control_test.dart --device <device_id>
```

## 安全基線檢查（本機）
```bash
bash tool/security_check.sh
```
