# 男士 AI 護膚分析儀 (SharpFace)

Flutter + Firebase + OpenAI 的男士膚質分析 App。

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

