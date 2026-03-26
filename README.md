# 👨‍⚕️ 男士 AI 護膚分析儀 (Men's AI Skin Care Analyzer)

這是一款專為男士設計的輕量化 AI 護膚應用程式。透過 Google Gemini / OpenAI 視覺分析技術，即時偵測膚質並提供個人化的保養建議與產品比價。

---

## ✨ 核心功能

*   **AI 臉部掃描**：上傳照片即可分析膚質（油性、乾性、混合性）及主要皮膚問題。
*   **保養指南**：根據分析結果，自動生成早晚基礎保養步驟（清潔、保濕、防曬）。
*   **產品比價表**：即時顯示 10 件熱門護膚產品，包含成分、價格、評價及導購連結。
*   **贊助排名**：首位顯示贊助商產品，幫助用戶快速發現優質選擇。
*   **皮膚日誌**：追蹤歷屆臉部變化，並記錄當時使用的護膚產品（需登入）。
*   **管理員後台**：商務數據監控（用戶數、分析次數、產品點擊率）。

---

## 🛠️ 技術架構

*   **Frontend**: [Flutter](https://flutter.dev) (Stable v3.41+)
*   **Backend**: [Firebase](https://firebase.google.com) (Auth, Firestore, Storage)
*   **AI Engine**: [Google Gemini API](https://aistudio.google.com) / [OpenAI GPT-4o-mini](https://platform.openai.com)
*   **State Management**: [Riverpod](https://riverpod.dev)
