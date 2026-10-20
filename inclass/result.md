# MQSim 模擬結果

本報告整理目前九份 `wl_inclass_scenario_*.xml` 結果，依 `wl_inclass.xml` 的 scenario 順序對應測資。所有 hot region 設定均為 20。

## 主要結果

- 最高 IOPS 為串流純讀（scenario 1）：90,524.84，平均延遲 176 µs。
- 均勻隨機混合讀寫（scenario 6）效能最低：4,987.89 IOPS，平均延遲 3,103 µs，最大延遲 1,586.880 ms。
- 同讀寫比例下，hot/cold 的 IOPS 均高於均勻隨機；混合讀寫時，hot/cold 也高於串流。這是本次模擬的觀察，單次結果不足以判定差異的統計穩定性。

## 測試設定

| 項目 | 設定 |
| --- | --- |
| 地址分布 | STREAMING、RANDOM_UNIFORM、RANDOM_HOTCOLD |
| 讀取比例 | 每種分布各測 100%、0%、50% |
| Hot region | 全部 20%；RANDOM_HOTCOLD 約 80% 流量存取 20% 地址空間 |
| 請求大小 | FIXED，8 sectors = 4 KiB |
| 地址對齊 | 開啟，16 sectors = 8 KiB |
| 產生模式／佇列深度 | QUEUE_DEPTH／16 |
| 工作集／初始占用率 | 50%／75% |
| 停止時間 | 10,000,000,000 ns = 10 秒模擬時間 |
| 總請求數限制 | 0（使用停止時間） |
| Seed | workload 798；SSD 321 |
| SSD | NVMe、PAGE_LEVEL mapping、ADVANCED cache、RGA GC |
| SSD cache／CMT | 256 MiB／2 MiB |
| Preconditioning | 啟用 |

上述設定取自 [wl_inclass.xml](wl_inclass.xml) 與 [ssdconfig.xml](ssdconfig.xml)。Hot region 參數在 STREAMING 和 RANDOM_UNIFORM 的地址產生分支中不使用；填入 20 不會使這兩種分布變成 hot/cold。

## 九筆效能結果

頻寬以十進位 MB/s（B/s ÷ 1,000,000）表示；延遲單位為 µs。IOPS 越高越好，延遲越低越好。

| Scenario | 地址分布 | 讀／寫設定 | IOPS | 頻寬 (MB/s) | 平均裝置延遲 (µs) | 平均端到端延遲 (µs) |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| 1 | STREAMING | 100%／0% | 90,524.84 | 370.790 | 176 | 176 |
| 2 | STREAMING | 0%／100% | 48,755.13 | 199.701 | 328 | 328 |
| 3 | STREAMING | 50%／50% | 49,874.00 | 204.284 | 320 | 320 |
| 4 | RANDOM_UNIFORM | 100%／0% | 11,961.40 | 48.994 | 1,317 | 1,317 |
| 5 | RANDOM_UNIFORM | 0%／100% | 8,031.65 | 32.898 | 1,970 | 1,970 |
| 6 | RANDOM_UNIFORM | 50%／50% | 4,987.89 | 20.430 | 3,103 | 3,103 |
| 7 | RANDOM_HOTCOLD | 100%／0% | 75,880.79 | 310.808 | 210 | 210 |
| 8 | RANDOM_HOTCOLD | 0%／100% | 37,280.13 | 152.699 | 428 | 428 |
| 9 | RANDOM_HOTCOLD | 50%／50% | 53,680.19 | 219.874 | 297 | 297 |

## 請求數與延遲範圍

| Scenario | 總請求數 | 讀請求數 | 寫請求數 | 實際讀取比例 | 最小端到端延遲 (µs) | 最大端到端延遲 (ms) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 905,264 | 905,264 | 0 | 100.00% | 161 | 0.197 |
| 2 | 487,678 | 0 | 487,678 | 0.00% | 22 | 0.329 |
| 3 | 498,818 | 250,031 | 248,787 | 50.12% | 21 | 1.684 |
| 4 | 126,061 | 126,061 | 0 | 100.00% | 88 | 644.535 |
| 5 | 81,216 | 0 | 81,216 | 0.00% | 22 | 182.422 |
| 6 | 53,696 | 26,737 | 26,959 | 49.79% | 21 | 1,586.880 |
| 7 | 758,828 | 758,828 | 0 | 100.00% | 88 | 1.066 |
| 8 | 373,724 | 0 | 373,724 | 0.00% | 22 | 0.695 |
| 9 | 537,440 | 269,279 | 268,161 | 50.10% | 21 | 2.363 |

50% 讀取是生成器的機率設定，實際讀取比例因此略有差異。九筆結果的裝置與端到端延遲之平均、最小、最大值均相同（以 XML 輸出精度為準）。最大延遲是單筆觀察值，不代表 p95 或 p99。

## 同讀寫比例比較

| 讀／寫設定 | Hot/cold ÷ 均勻隨機 IOPS | Hot/cold 相對串流 IOPS 變化 |
| --- | ---: | ---: |
| 100%／0% | 6.34 倍 | -16.18% |
| 0%／100% | 4.64 倍 | -23.54% |
| 50%／50% | 10.76 倍 | +7.63% |

均勻隨機的三種測試均出現較低 IOPS 與較高平均延遲；scenario 6 的最大延遲尤其明顯。Hot/cold 的存取集中性可能有助於快取與映射局部性，但此處僅以 Host 指標比較，尚未使用 cache hit、CMT miss 或 GC 統計驗證原因。

## 指標定義與核對

- IOPS、Bandwidth、請求數及延遲均直接讀取各結果 XML 的 `Host/Host.IO_Flow`。MQSim 原始碼的 IOPS 分子使用生成請求數，分母使用結果輸出時的模擬時間。
- 平均延遲採用 `Device_Response_Time` 與 `End_to_End_Request_Delay`；最小與最大延遲採用對應的 Min／Max 欄位。
- 九筆皆通過：總請求數 = 讀 + 寫、總 IOPS = 讀 IOPS + 寫 IOPS（允許輸出小數誤差）、傳輸位元組數 = 請求數 × 4,096、頻寬 = IOPS × 4,096。
- Stop_Time 是停止產生請求的時間設定，結果 IOPS 的計算分母可能包含後續處理時間；不直接用「請求數 ÷ 10」替代 XML 的 IOPS。
- 本報告使用目前輸入設定對應 scenario 編號；結果 XML 本身不保存完整輸入設定。檔案修改時間是來源辨識資訊，不是模擬耗時。

## 來源

- 輸入：[wl_inclass.xml](wl_inclass.xml)、[ssdconfig.xml](ssdconfig.xml)。
- 執行入口：[inclass.sh](inclass.sh)。

- Scenario 1：[wl_inclass_scenario_1.xml](wl_inclass_scenario_1.xml)（檔案修改時間 2026-10-07 17:21:40，本機時間）。
- Scenario 2：[wl_inclass_scenario_2.xml](wl_inclass_scenario_2.xml)（檔案修改時間 2026-10-07 17:22:02，本機時間）。
- Scenario 3：[wl_inclass_scenario_3.xml](wl_inclass_scenario_3.xml)（檔案修改時間 2026-10-07 17:22:23，本機時間）。
- Scenario 4：[wl_inclass_scenario_4.xml](wl_inclass_scenario_4.xml)（檔案修改時間 2026-10-07 17:25:53，本機時間）。
- Scenario 5：[wl_inclass_scenario_5.xml](wl_inclass_scenario_5.xml)（檔案修改時間 2026-10-07 17:29:29，本機時間）。
- Scenario 6：[wl_inclass_scenario_6.xml](wl_inclass_scenario_6.xml)（檔案修改時間 2026-10-07 17:33:06，本機時間）。
- Scenario 7：[wl_inclass_scenario_7.xml](wl_inclass_scenario_7.xml)（檔案修改時間 2026-10-07 17:36:19，本機時間）。
- Scenario 8：[wl_inclass_scenario_8.xml](wl_inclass_scenario_8.xml)（檔案修改時間 2026-10-07 17:39:32，本機時間）。
- Scenario 9：[wl_inclass_scenario_9.xml](wl_inclass_scenario_9.xml)（檔案修改時間 2026-10-07 17:42:45，本機時間）。
