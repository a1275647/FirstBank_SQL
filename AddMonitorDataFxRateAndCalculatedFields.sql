-- ══════════════════════════════════════════════════════════════════════════
-- [MONITORDATA] 新增交易/額度匯率與計算後美金金額欄位
-- TRAN_FXRATE／LIMIT_FXRATE：拆分 usp_UpdateMonitorDataFPEXR_RateUSD 換算美金時
--   實際套用的匯率並落地保存（原本只算出 TO_USD_AMT/TO_USD_LIMIT 結果，匯率本身未保留）
-- CAL_TO_USD_AMT／CAL_TO_USD_LIMIT：套用 WEIGHTS/RISKFACTOR 後的計算後美金金額，
--   計算邏輯待補（另由 usp_UpdateMonitorDataCalculatedUsdAmount 落地）
-- MONITORDATA_temp／MONITORDATA_his 同步新增，維持三表欄位一致
-- ══════════════════════════════════════════════════════════════════════════

ALTER TABLE [MONITORDATA] ADD
	[TRAN_FXRATE] DECIMAL(18, 10) NULL,
	[LIMIT_FXRATE] DECIMAL(18, 10) NULL,
	[CAL_TO_USD_AMT] DECIMAL(18, 2) NULL,
	[CAL_TO_USD_LIMIT] DECIMAL(18, 2) NULL;

ALTER TABLE [MONITORDATA_temp] ADD
	[TRAN_FXRATE] DECIMAL(18, 10) NULL,
	[LIMIT_FXRATE] DECIMAL(18, 10) NULL,
	[CAL_TO_USD_AMT] DECIMAL(18, 2) NULL,
	[CAL_TO_USD_LIMIT] DECIMAL(18, 2) NULL;

ALTER TABLE [MONITORDATA_his] ADD
	[TRAN_FXRATE] DECIMAL(18, 10) NULL,
	[LIMIT_FXRATE] DECIMAL(18, 10) NULL,
	[CAL_TO_USD_AMT] DECIMAL(18, 2) NULL,
	[CAL_TO_USD_LIMIT] DECIMAL(18, 2) NULL;
