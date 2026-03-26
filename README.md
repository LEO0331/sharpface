# 男士 AI 護膚分析儀 (SharpFace)

Flutter + Firebase + OpenAI 的男士膚質分析應用。

## Security

- API Key 使用 `--dart-define` 注入，不寫死在程式碼。
- 本專案已在 `.gitignore` 排除 `.env*`、`google-services.json`、`GoogleService-Info.plist` 等敏感檔案。

## Run

```bash
flutter pub get
flutter run --dart-define=OPENAI_API_KEY=your_openai_api_key
```

## Firebase 設定

- 啟用 `Email/Password` 登入。
- 啟用 `Phone` 登入（供訪客 SMS OTP 驗證）。
- 若要測試 OTP，不發送真實簡訊可在 Firebase Console 設定：
  `Authentication -> Sign-in method -> Phone -> Phone numbers for testing`。
