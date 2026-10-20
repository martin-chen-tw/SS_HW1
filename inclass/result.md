# MQSim 模擬結果

本報告整理 W1、W2、W3 三個 workload，各自使用獨立的輸入與結果檔案。保留原 scenario 1、5、9 的結果，僅重新命名，未重新執行模擬。所有 hot region 設定均為 20。

## Workload 對應

| Workload | Read Ratio | Write Ratio | I/O Requests | Address_Distribution | 原 Scenario |
| --- | ---: | ---: | --- | --- | ---: |
| W1 | 100% | 0% | Streaming | STREAMING | 1 |
| W2 | 0% | 100% | Random | RANDOM_UNIFORM | 5 |
| W3 | 50% | 50% | Mixed | RANDOM_HOTCOLD | 9 |

W3 的 Mixed 沿用原 scenario 9 的 hot/cold 地址分布，讀寫比例各為 50%。每份輸入只含一個 scenario，因此結果檔名的 scenario 編號均為 1。

## 主要結果

- W1（串流純讀）：90,524.84 IOPS，平均延遲 176 µs。
- W2（均勻隨機純寫）：8,031.65 IOPS，平均延遲 1,970 µs。
- W3（hot/cold、讀寫各半）：53,680.19 IOPS，平均延遲 297 µs。

## 測試設定

| 項目 | 設定 |
| --- | --- |
| 地址分布 | STREAMING、RANDOM_UNIFORM、RANDOM_HOTCOLD |
| 讀取比例 | W1：100%；W2：0%；W3：50% |
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

上述設定取自 [wl_inclass_1.xml](wl_inclass_1.xml)、[wl_inclass_2.xml](wl_inclass_2.xml)、[wl_inclass_3.xml](wl_inclass_3.xml) 與 [ssdconfig.xml](ssdconfig.xml)。Hot region 參數在 STREAMING 和 RANDOM_UNIFORM 的地址產生分支中不使用；填入 20 不會使這兩種分布變成 hot/cold。

## 三筆效能結果

頻寬以十進位 MB/s（B/s ÷ 1,000,000）表示；延遲單位為 µs。IOPS 越高越好，延遲越低越好。

| Workload | 地址分布 | 讀／寫設定 | IOPS | 頻寬 (MB/s) | 平均裝置延遲 (µs) | 平均端到端延遲 (µs) |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| W1 | STREAMING | 100%／0% | 90,524.84 | 370.790 | 176 | 176 |
| W2 | RANDOM_UNIFORM | 0%／100% | 8,031.65 | 32.898 | 1,970 | 1,970 |
| W3 | RANDOM_HOTCOLD | 50%／50% | 53,680.19 | 219.874 | 297 | 297 |

## 請求數與延遲範圍

| Workload | 總請求數 | 讀請求數 | 寫請求數 | 實際讀取比例 | 最小端到端延遲 (µs) | 最大端到端延遲 (ms) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| W1 | 905,264 | 905,264 | 0 | 100.00% | 161 | 0.197 |
| W2 | 81,216 | 0 | 81,216 | 0.00% | 22 | 182.422 |
| W3 | 537,440 | 269,279 | 268,161 | 50.10% | 21 | 2.363 |

50% 讀取是生成器的機率設定，實際讀取比例因此略有差異。三筆結果的裝置與端到端延遲之平均、最小、最大值均相同（以 XML 輸出精度為準）。最大延遲是單筆觀察值，不代表 p95 或 p99。

## 指標定義與核對

- IOPS、Bandwidth、請求數及延遲均直接讀取各結果 XML 的 `Host/Host.IO_Flow`。MQSim 原始碼的 IOPS 分子使用生成請求數，分母使用結果輸出時的模擬時間。
- 平均延遲採用 `Device_Response_Time` 與 `End_to_End_Request_Delay`；最小與最大延遲採用對應的 Min／Max 欄位。
- 三筆皆通過：總請求數 = 讀 + 寫、總 IOPS = 讀 IOPS + 寫 IOPS（允許輸出小數誤差）、傳輸位元組數 = 請求數 × 4,096、頻寬 = IOPS × 4,096。
- Stop_Time 是停止產生請求的時間設定，結果 IOPS 的計算分母可能包含後續處理時間；不直接用「請求數 ÷ 10」替代 XML 的 IOPS。
- 本報告依原 scenario 1、5、9 對應 W1、W2、W3；結果 XML 本身不保存完整輸入設定。

## 來源

- W1 輸入：[wl_inclass_1.xml](wl_inclass_1.xml)；結果：[wl_inclass_1_scenario_1.xml](wl_inclass_1_scenario_1.xml)。
- W2 輸入：[wl_inclass_2.xml](wl_inclass_2.xml)；結果：[wl_inclass_2_scenario_1.xml](wl_inclass_2_scenario_1.xml)。
- W3 輸入：[wl_inclass_3.xml](wl_inclass_3.xml)；結果：[wl_inclass_3_scenario_1.xml](wl_inclass_3_scenario_1.xml)。
- SSD 設定：[ssdconfig.xml](ssdconfig.xml)。
- 執行入口：[inclass.sh](inclass.sh)。
