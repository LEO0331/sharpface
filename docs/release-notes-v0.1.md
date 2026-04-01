# SharpFace v0.1 Release Notes

發布日期：2026-04-01

## 亮點功能

- AI 膚質分析流程（GPT Vision）與結構化回傳
- Firebase Email/Password 登入註冊 + 角色管控（user/admin）
- 訪客 OTP 驗證 + 單次掃描限制
- 產品推薦列表（贊助置頂、最愛、導購連結）
- 歷史膚質曲線（7 天 / 30 天 / 全部）
- 廣告池管理（啟用/停用、權重、排程、草稿、回滾）
- 詳情頁轉換強化（Hero、Sticky 購買按鈕、信任標記）
- 新增「降價通知」：登入用戶可設定/取消目標價格提醒

## 數據與追蹤

- 廣告事件改為「純事件上報」：
- 只寫入 `adEvents`（impression / click）
- 不再由客戶端寫 `adStats` 聚合，降低灌水風險
- Admin 儀表板改為從事件資料計算最高 CTR 廣告

## UX / UI

- 柔和漸層風格與資訊卡優化
- 廣告輪播與捲動觸發動畫
- 30 秒保養流程卡（依預算切換）
- 歷史曲線頁新增：
- 分數計算說明
- 分數區間對應建議（1-3 / 4-6 / 7-10）

## 效能與穩定

- 產品圖片快取（cached_network_image）
- favorites/adConfigs 加入 10 分鐘 TTL 快取 + 差異更新
- 首屏預載熱門產品與廣告配置

## 安全更新

- Firestore Rules 強化（adEvents 欄位約束）
- `adStats` 禁止客戶端 create/update/delete
- 新增本機安全檢查腳本：`tool/security_check.sh`

## 測試狀態

- `flutter analyze` 通過
- `flutter test` 全數通過
- 覆蓋率已達並超過 v0.1 目標（>= 75%）

## 已知限制（Spark Plan）

- 無 Cloud Functions 時，廣告 CTR 採 Admin 端事件聚合計算。
- 建議未來升級 Blaze 後改為後端定時聚合，提高精度與查詢效率。

## 升級 / 部署提醒

1. `flutter pub get`
2. `flutter build ...`（依平台）
3. `firebase deploy --only firestore:rules`
4. 確認環境變數：`OPENAI_API_KEY`（不要寫入 repo）

## 回滾建議

- 若 v0.1 上線異常：
1. 回滾前端版本到上一個 tag
2. 使用 ad 配置草稿/歷史版本快速回滾文案
3. 保持 Firestore Rules 在安全版本，不建議回滾到寬鬆規則
