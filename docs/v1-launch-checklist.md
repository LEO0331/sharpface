# SharpFace v1 上線檢查表

> 適用：Flutter + Firebase（Spark）  
> 說明：可直接勾選，建議依照 `P0 -> P1` 順序完成。

## P0 - 必做（上線門檻）

- [ ] **API 金鑰安全**
- [ ] `OPENAI_API_KEY` 不出現在任何 commit、README、前端明文設定檔。
- [ ] 執行 `bash tool/security_check.sh` 並確認沒有高風險項目。

- [ ] **Firebase Rules 安全**
- [ ] 部署最新 `firestore.rules`：`firebase deploy --only firestore:rules`
- [ ] 驗證：一般使用者不可讀取 admin 專屬資料（`adminStats`, `adStats`）。

- [ ] **Auth 與角色**
- [ ] Email/Password 註冊後自動寫入 `users.role = "user"`。
- [ ] `admin` 僅能由後台手動設定。

- [ ] **訪客防濫用**
- [ ] 訪客需經 OTP 驗證才能分析。
- [ ] 訪客單次掃描限制可正常生效。

- [ ] **核心流程可用**
- [ ] 分析成功流程（含推薦/廣告切換）正常。
- [ ] 分析失敗會走 fallback，不顯示敏感錯誤細節。
- [ ] 購買按鈕可正確跳轉 affiliate URL。

- [ ] **資料與追蹤**
- [ ] ad impression/click 有寫入 `adEvents`，`adStats` 會更新 CTR。
- [ ] favorites 跨裝置同步正常，並有 10 分鐘 TTL 快取。

- [ ] **品質門檻**
- [ ] `flutter analyze` 無錯誤。
- [ ] `flutter test` 全綠。
- [ ] `flutter test --coverage` 約 >= 75%。

## P1 - 建議（上線後 1-2 週）

- [ ] **可視性/SEO**
- [ ] `web/index.html` 已有 title/description/OG/Twitter meta。
- [ ] 完成商店素材（icon、截圖、關鍵字、描述中英版）。

- [ ] **轉換與留存**
- [ ] 詳情頁 Sticky Buy CTA + 信任標記已上線。
- [ ] 首頁保養流程卡可依膚況/預算快速生成。

- [ ] **後台運營**
- [ ] 廣告池可設定啟用、權重、排程（startAt/endAt）。
- [ ] 有版本草稿/回滾流程，避免誤發佈。

## 發佈日操作清單

- [ ] 先打 tag：`v1.0.0`
- [ ] 建立 release notes（新功能、已知限制、回滾方式）
- [ ] 發佈後 2 小時內監控：
- [ ] Auth 成功率
- [ ] 分析成功率
- [ ] ad click-through rate
- [ ] crash / error log
