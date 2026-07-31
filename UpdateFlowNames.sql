-- 更新 dbo.Flow 表單類型名稱（繁中/簡中/英/日）
-- 依 FK_Menu_ID 對照 Menu 表中文名稱意義重新定義，並儘量沿用系統既有翻譯用字
-- 執行前請先備份 dbo.Flow，並在測試環境確認結果無誤後再上正式環境

-- PK_Id=10, FK_Menu_ID=24 郵件範本設定
UPDATE dbo.Flow SET Name_TN = N'郵件範本設定', Name_CN = N'邮件范本设定', Name_EN = N'Email Template Settings', Name_JP = N'メールテンプレート設定' WHERE PK_Id = 10;

-- PK_Id=27, FK_Menu_ID=73 國家代碼管理
UPDATE dbo.Flow SET Name_TN = N'國家代碼管理', Name_CN = N'国家代码管理', Name_EN = N'Country Code Management', Name_JP = N'国コード管理' WHERE PK_Id = 27;

-- PK_Id=28, FK_Menu_ID=75 洲、特殊區域管理（原始資料「州」為錯字，應為「洲」，對照 ContinentService/ContinentRecord 確認）
UPDATE dbo.Flow SET Name_TN = N'洲、特殊區域管理', Name_CN = N'洲、特殊区域管理', Name_EN = N'Continent / Special Zone Management', Name_JP = N'大陸・特別区域管理' WHERE PK_Id = 28;

-- PK_Id=29, FK_Menu_ID=69 限額參數設定
UPDATE dbo.Flow SET Name_TN = N'限額參數設定', Name_CN = N'限额参数设定', Name_EN = N'Limit Parameter Settings', Name_JP = N'限度額パラメータ設定' WHERE PK_Id = 29;

-- PK_Id=30, FK_Menu_ID=118 RPA發佈
UPDATE dbo.Flow SET Name_TN = N'RPA發佈', Name_CN = N'RPA发布', Name_EN = N'RPA Publish', Name_JP = N'RPA公開' WHERE PK_Id = 30;

-- PK_Id=37, FK_Menu_ID=117 新聞發佈
UPDATE dbo.Flow SET Name_TN = N'新聞管理', Name_CN = N'新闻管理', Name_EN = N'News Management', Name_JP = N'ニュース管理' WHERE PK_Id = 37;

-- PK_Id=38, FK_Menu_ID=119 公告發佈
UPDATE dbo.Flow SET Name_TN = N'公告管理', Name_CN = N'公告管理', Name_EN = N'Announcement Management', Name_JP = N'お知らせ管理' WHERE PK_Id = 38;

-- PK_Id=39, FK_Menu_ID=71 風險評級設定
UPDATE dbo.Flow SET Name_TN = N'風險評級設定', Name_CN = N'风险评级设定', Name_EN = N'Risk Rating Settings', Name_JP = N'リスク格付設定' WHERE PK_Id = 39;

-- PK_Id=40, FK_Menu_ID=96 分行查詢
UPDATE dbo.Flow SET Name_TN = N'分行查詢', Name_CN = N'分行查询', Name_EN = N'Branch Query', Name_JP = N'支店照会' WHERE PK_Id = 40;

-- PK_Id=41, FK_Menu_ID=74 金融商品交易風險係數設定
UPDATE dbo.Flow SET Name_TN = N'金融商品交易風險係數設定', Name_CN = N'金融商品交易风险系数设定', Name_EN = N'Financial Product Trading Risk Coefficient Setting', Name_JP = N'金融商品取引リスク係数設定' WHERE PK_Id = 41;

-- PK_Id=42, FK_Menu_ID=109 排程管理
UPDATE dbo.Flow SET Name_TN = N'排程管理', Name_CN = N'排程管理', Name_EN = N'Schedule Management', Name_JP = N'スケジュール管理' WHERE PK_Id = 42;

-- PK_Id=43, FK_Menu_ID=100 客戶歸戶設定
UPDATE dbo.Flow SET Name_TN = N'客戶歸戶', Name_CN = N'客户归户', Name_EN = N'Customer Consolidation / Exposure Assignment', Name_JP = N'顧客名寄せ' WHERE PK_Id = 43;

-- PK_Id=44, FK_Menu_ID=123 交易紀錄管理
UPDATE dbo.Flow SET Name_TN = N'交易紀錄', Name_CN = N'交易纪录', Name_EN = N'Transaction Records', Name_JP = N'取引履歴' WHERE PK_Id = 44;

-- PK_Id=45, FK_Menu_ID=52 第一層全行額度管理
UPDATE dbo.Flow SET Name_TN = N'第一層全行額度管理', Name_CN = N'第一层全行额度管理', Name_EN = N'Tier 1 Bank-wide Quota Management', Name_JP = N'第1レイヤー 全行限度額管理' WHERE PK_Id = 45;

-- PK_Id=46, FK_Menu_ID=54 第二層全行額度管理
UPDATE dbo.Flow SET Name_TN = N'第二層全行額度管理', Name_CN = N'第二层全行额度管理', Name_EN = N'Tier 2 Bank-wide Quota Management', Name_JP = N'第2レイヤー 全行限度額管理' WHERE PK_Id = 46;

-- PK_Id=47, FK_Menu_ID=55 第三層全行額度管理
UPDATE dbo.Flow SET Name_TN = N'第三層全行額度管理', Name_CN = N'第三层全行额度管理', Name_EN = N'Tier 3 Bank-wide Quota Management', Name_JP = N'第3レイヤー 全行限度額管理' WHERE PK_Id = 47;

-- PK_Id=48, FK_Menu_ID=98 例外國家管理
UPDATE dbo.Flow SET Name_TN = N'例外國家設定', Name_CN = N'例外国家设定', Name_EN = N'Exception Country Settings', Name_JP = N'例外国設定' WHERE PK_Id = 48;

-- PK_Id=49, FK_Menu_ID=99 近期關注國家管理
UPDATE dbo.Flow SET Name_TN = N'近期關注國家設定', Name_CN = N'近期关注国家设定', Name_EN = N'Recent Focus Country Settings', Name_JP = N'最近の注目国設定' WHERE PK_Id = 49;

-- PK_Id=64, FK_Menu_ID=157 未來展望發布
UPDATE dbo.Flow SET Name_TN = N'未來展望', Name_CN = N'未来展望', Name_EN = N'Future Outlook', Name_JP = N'今後の見通し' WHERE PK_Id = 64;

-- PK_Id=65, FK_Menu_ID=152 分行調借申請單
UPDATE dbo.Flow SET Name_TN = N'分行調借申請單', Name_CN = N'分行调借申请单', Name_EN = N'Branch Credit Line Application', Name_JP = N'支店与信移管申請書' WHERE PK_Id = 65;

-- PK_Id=66, FK_Menu_ID=153 總行調借申請單（CUF，跨額度管理調借）
UPDATE dbo.Flow SET Name_TN = N'總行調借申請單', Name_CN = N'总行调借申请单', Name_EN = N'Cross-Unit Credit Line Transfer Application (CUF)', Name_JP = N'本部信用枠調達申請書' WHERE PK_Id = 66;

-- PK_Id=67, FK_Menu_ID=154 延展追蹤日申請單
UPDATE dbo.Flow SET Name_TN = N'延展追蹤日申請單', Name_CN = N'延展追踪日申请单', Name_EN = N'Tracking Date Extension Application', Name_JP = N'追跡期日延長申請書' WHERE PK_Id = 67;
