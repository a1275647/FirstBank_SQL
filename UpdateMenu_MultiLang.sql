-- ══════════════════════════════════════════════════════════════════════════
-- [Menu] 多語系名稱更新（Name_CN 簡中 / Name_EN 英文 / Name_JP 日文）
-- 依 PK_Id 更新，Name_TN（繁中）除下方「改名」區塊外維持不變
-- 這些項目不在「複本 國家風險系統左側menu.xlsx」的新選單結構內，
-- 只同步語系名稱，不調整 MenuType / Seq / ParentId
-- ══════════════════════════════════════════════════════════════════════════

UPDATE [Menu] SET Name_CN = N'表单申请',           Name_EN = N'Form Application',                       Name_JP = N'フォーム申請'                 WHERE PK_Id = 5;
UPDATE [Menu] SET Name_CN = N'表单查询',           Name_EN = N'Form Query',                             Name_JP = N'フォーム検索'                 WHERE PK_Id = 8;
UPDATE [Menu] SET Name_CN = N'历史表单查询',       Name_EN = N'Historical Form Query',                  Name_JP = N'履歴フォーム検索'             WHERE PK_Id = 9;
UPDATE [Menu] SET Name_CN = N'快速处理',           Name_EN = N'Quick Processing',                       Name_JP = N'クイック処理'                 WHERE PK_Id = 11;
UPDATE [Menu] SET Name_CN = N'取回代理表单',       Name_EN = N'Retrieve Delegate Form',                 Name_JP = N'代理フォーム取得'             WHERE PK_Id = 12;
UPDATE [Menu] SET Name_CN = N'流程设定',           Name_EN = N'Process Configuration',                  Name_JP = N'プロセス設定'                 WHERE PK_Id = 15;
UPDATE [Menu] SET Name_CN = N'创建流程',           Name_EN = N'Create Process',                         Name_JP = N'プロセス作成'                 WHERE PK_Id = 20;
UPDATE [Menu] SET Name_CN = N'人事',               Name_EN = N'Personnel',                              Name_JP = N'人事'                         WHERE PK_Id = 25;
UPDATE [Menu] SET Name_CN = N'一般',               Name_EN = N'General',                                Name_JP = N'一般'                         WHERE PK_Id = 26;
UPDATE [Menu] SET Name_CN = N'测试',               Name_EN = N'Test',                                   Name_JP = N'テスト'                       WHERE PK_Id = 28;
UPDATE [Menu] SET Name_CN = N'财务中心',           Name_EN = N'Finance Center',                         Name_JP = N'財務センター'                 WHERE PK_Id = 29;
UPDATE [Menu] SET Name_CN = N'Excel模板设定',      Name_EN = N'Excel Template Settings',                Name_JP = N'Excelテンプレート設定'        WHERE PK_Id = 46;
UPDATE [Menu] SET Name_CN = N'传送记录',           Name_EN = N'Transmission Log',                       Name_JP = N'送信記録'                     WHERE PK_Id = 56;
UPDATE [Menu] SET Name_CN = N'额度调借申请',       Name_EN = N'Credit Line Transfer Application',       Name_JP = N'与信枠融通申請'               WHERE PK_Id = 65;
UPDATE [Menu] SET Name_CN = N'新闻/公告查询',      Name_EN = N'News/Announcement Query',                Name_JP = N'ニュース/お知らせ照会'        WHERE PK_Id = 68;
UPDATE [Menu] SET Name_CN = N'信用评等',           Name_EN = N'Credit Rating',                          Name_JP = N'信用格付'                     WHERE PK_Id = 70;
UPDATE [Menu] SET Name_CN = N'国家额度余额账龄表', Name_EN = N'Country Credit Limit Balance Aging Report', Name_JP = N'国別与信枠残高エージング表' WHERE PK_Id = 72;
UPDATE [Menu] SET Name_CN = N'目录设定',           Name_EN = N'Directory Settings',                     Name_JP = N'ディレクトリ設定'             WHERE PK_Id = 76;
UPDATE [Menu] SET Name_CN = N'测试',               Name_EN = N'Test',                                   Name_JP = N'テスト'                       WHERE PK_Id = 77;
UPDATE [Menu] SET Name_CN = N'例外、近期关注国家维护', Name_EN = N'Exception/Watch-list Country Maintenance', Name_JP = N'例外・要注意国メンテナンス' WHERE PK_Id = 97;
UPDATE [Menu] SET Name_CN = N'文件中心',           Name_EN = N'File Center',                            Name_JP = N'ファイルセンター'             WHERE PK_Id = 101;
UPDATE [Menu] SET Name_CN = N'系统主档流程设定',   Name_EN = N'System Master Data Process Settings',    Name_JP = N'システムマスタプロセス設定'   WHERE PK_Id = 108;
UPDATE [Menu] SET Name_CN = N'CDS/汇率查询',       Name_EN = N'CDS/Exchange Rate Query',                Name_JP = N'CDS/為替レート照会'           WHERE PK_Id = 124;
UPDATE [Menu] SET Name_CN = N'例外、近期关注国家查询', Name_EN = N'Exception/Watch-list Country Query',  Name_JP = N'例外・要注意国照会'           WHERE PK_Id = 130;
UPDATE [Menu] SET Name_CN = N'例外国家查询',       Name_EN = N'Exception Country Query',                Name_JP = N'例外国照会'                   WHERE PK_Id = 131;
UPDATE [Menu] SET Name_CN = N'近期关注国家查询',   Name_EN = N'Watch-list Country Query',               Name_JP = N'要注意国照会'                 WHERE PK_Id = 132;
UPDATE [Menu] SET Name_CN = N'延展追踪日申请单',   Name_EN = N'Tracking Date Extension Application',   Name_JP = N'追跡日延長申請書'             WHERE PK_Id = 154;

-- ══════════════════════════════════════════════════════════════════════════
-- 依「複本 國家風險系統左側menu.xlsx」重建選單分類、順序與父子關係
-- MenuType 對應新版 MenuGroup enum：
-- 1=個人工作台 2=國家/內部資料管理 3=外部資料管理 4=額度/餘額資料管理
-- 5=電子簽核流程作業 6=公告專區 7=系統管理 8=報表管理
-- Seq 依 Excel 由上到下重新編號（同層級各自從 1 起算）
-- ParentId：頂層項目與資料夾本身皆為 NULL，只有資料夾底下的子項目才設定
-- ══════════════════════════════════════════════════════════════════════════

-- 個人工作台（MenuType=1）
UPDATE [Menu] SET MenuType = 1, Seq = 1 WHERE PK_Id = 7;   -- 通知
UPDATE [Menu] SET MenuType = 1, Seq = 2 WHERE PK_Id = 10;  -- 待辦事項
UPDATE [Menu] SET Name_TN = N'指派簽核人員', Name_CN = N'指派签核人员', Name_EN = N'Assign Approver', Name_JP = N'承認者割当', MenuType = 1, Seq = 3 WHERE PK_Id = 133;
UPDATE [Menu] SET MenuType = 1, Seq = 4, ParentId = NULL WHERE PK_Id = 121; -- 表單查詢（原掛在 PK8 資料夾下，拉平）
UPDATE [Menu] SET Name_TN = N'電子郵件管理', Name_CN = N'电子邮件管理', Name_EN = N'Email Management', Name_JP = N'電子メール管理', MenuType = 1, Seq = 5 WHERE PK_Id = 50;
UPDATE [Menu] SET Name_TN = N'郵件傳送', Name_CN = N'邮件传送', Name_EN = N'Mail Delivery', Name_JP = N'メール送信', MenuType = 1, Seq = 1 WHERE PK_Id = 37; -- 電子郵件管理(50) 子項目
UPDATE [Menu] SET Name_TN = N'郵件範本設定', Name_CN = N'邮件模板设定', Name_EN = N'Mail Template Settings', Name_JP = N'メールテンプレート設定', MenuType = 1, Seq = 2, ParentId = 50 WHERE PK_Id = 24; -- 併入電子郵件管理(50) 子項目

-- 國家/內部資料管理（MenuType=2）
UPDATE [Menu] SET Name_TN = N'國家代碼管理', Name_CN = N'国家代码管理', Name_EN = N'Country Code Management', Name_JP = N'国コード管理', MenuType = 2, Seq = 1 WHERE PK_Id = 73;
UPDATE [Menu] SET Name_TN = N'洲、特殊區域管理', Name_CN = N'洲、特殊区域管理', Name_EN = N'Continent/Special Region Management', Name_JP = N'大陸・特別地域管理', MenuType = 2, Seq = 2 WHERE PK_Id = 75;
UPDATE [Menu] SET Name_TN = N'例外國家管理', Name_CN = N'例外国家管理', Name_EN = N'Exception Country Management', Name_JP = N'例外国管理', MenuType = 2, Seq = 3, ParentId = NULL WHERE PK_Id = 98; -- 原掛在 PK97 資料夾下，拉平
UPDATE [Menu] SET Name_TN = N'近期關注國家管理', Name_CN = N'近期关注国家管理', Name_EN = N'Watch-list Country Management', Name_JP = N'要注意国管理', MenuType = 2, Seq = 4, ParentId = NULL WHERE PK_Id = 99; -- 原掛在 PK97 資料夾下，拉平
UPDATE [Menu] SET MenuType = 2, Seq = 5 WHERE PK_Id = 69;  -- 限額參數設定
UPDATE [Menu] SET MenuType = 2, Seq = 6 WHERE PK_Id = 74;  -- 金融商品交易風險係數設定
UPDATE [Menu] SET MenuType = 2, Seq = 7, ParentId = NULL WHERE PK_Id = 71; -- 風險評級設定（原掛在 PK70 資料夾下，拉平）
UPDATE [Menu] SET MenuType = 2, Seq = 8 WHERE PK_Id = 96;  -- 分行查詢

-- 外部資料管理（MenuType=3）
UPDATE [Menu] SET MenuType = 3, Seq = 1 WHERE PK_Id = 120; -- 信評查詢
UPDATE [Menu] SET MenuType = 3, Seq = 2 WHERE PK_Id = 122; -- BMI查詢
UPDATE [Menu] SET Name_TN = N'五年期CDS查詢', Name_CN = N'五年期CDS查询', Name_EN = N'5-Year CDS Query', Name_JP = N'5年物CDS照会', MenuType = 3, Seq = 3, ParentId = NULL WHERE PK_Id = 126; -- 原掛在 PK124 資料夾下，拉平
UPDATE [Menu] SET MenuType = 3, Seq = 4, ParentId = NULL WHERE PK_Id = 127; -- 匯率查詢（原掛在 PK124 資料夾下，拉平）

-- 額度/餘額資料管理（MenuType=4）
UPDATE [Menu] SET Name_TN = N'餘額/額度資料查詢', Name_CN = N'余额/额度资料查询', Name_EN = N'Balance/Limit Data Query', Name_JP = N'残高/与信枠データ照会', MenuType = 4, Seq = 1 WHERE PK_Id = 57;
UPDATE [Menu] SET MenuType = 4, Seq = 1 WHERE PK_Id = 58;  -- 全行額度分配查詢，餘額/額度資料查詢(57) 子項目
UPDATE [Menu] SET MenuType = 4, Seq = 2 WHERE PK_Id = 59;  -- 各項產品別查詢，餘額/額度資料查詢(57) 子項目
UPDATE [Menu] SET MenuType = 4, Seq = 3 WHERE PK_Id = 128; -- 行業別查詢，餘額/額度資料查詢(57) 子項目（原 MenuType=1、Seq 與手足重複）
UPDATE [Menu] SET MenuType = 4, Seq = 2 WHERE PK_Id = 51;  -- 額度分配設定
UPDATE [Menu] SET MenuType = 4, Seq = 1 WHERE PK_Id = 52;  -- 第一層全行額度管理，額度分配設定(51) 子項目
UPDATE [Menu] SET MenuType = 4, Seq = 2 WHERE PK_Id = 54;  -- 第二層全行額度管理，額度分配設定(51) 子項目
UPDATE [Menu] SET MenuType = 4, Seq = 3 WHERE PK_Id = 55;  -- 第三層全行額度管理，額度分配設定(51) 子項目
UPDATE [Menu] SET Name_TN = N'交易紀錄管理', Name_CN = N'交易记录管理', Name_EN = N'Transaction Record Management', Name_JP = N'取引記録管理', MenuType = 4, Seq = 3 WHERE PK_Id = 123;
UPDATE [Menu] SET MenuType = 4, Seq = 4 WHERE PK_Id = 100; -- 客戶歸戶設定

-- 電子簽核流程作業（MenuType=5）
UPDATE [Menu] SET MenuType = 5, Seq = 1, ParentId = NULL WHERE PK_Id = 158; -- 調借單查詢（原掛在 PK8 資料夾下，拉平）
UPDATE [Menu] SET MenuType = 5, Seq = 2, ParentId = NULL WHERE PK_Id = 152; -- 分行調借申請單（原掛在 PK5 資料夾下，拉平）
UPDATE [Menu] SET MenuType = 5, Seq = 3, ParentId = NULL WHERE PK_Id = 153; -- 總行調借申請單（原掛在 PK5 資料夾下，拉平）

-- 公告專區（MenuType=6）
UPDATE [Menu] SET MenuType = 6, Seq = 1 WHERE PK_Id = 102; -- 新聞/公告查詢（採用 newsSearch 這筆，PK68/newsQuery 不動）
UPDATE [Menu] SET MenuType = 6, Seq = 2 WHERE PK_Id = 103; -- 新聞/公告發佈
UPDATE [Menu] SET MenuType = 6, Seq = 1 WHERE PK_Id = 117; -- 新聞發佈，新聞/公告發佈(103) 子項目
UPDATE [Menu] SET MenuType = 6, Seq = 2 WHERE PK_Id = 118; -- RPA發佈，新聞/公告發佈(103) 子項目
UPDATE [Menu] SET MenuType = 6, Seq = 3 WHERE PK_Id = 119; -- 公告發佈，新聞/公告發佈(103) 子項目
UPDATE [Menu] SET Name_TN = N'未來展望發佈', MenuType = 6, Seq = 4 WHERE PK_Id = 157; -- 原「未來展望發布」用字不統一，改成「發佈」對齊同層 117/118/119/103

-- 系統管理（MenuType=7）
UPDATE [Menu] SET Name_TN = N'角色權限管理', Name_CN = N'角色权限管理', Name_EN = N'Role/Permission Management', Name_JP = N'役職権限管理', MenuType = 7, Seq = 1 WHERE PK_Id = 39;
UPDATE [Menu] SET Name_CN = N'角色设定', Name_EN = N'Role Settings', Name_JP = N'役職設定', MenuType = 7, Seq = 1 WHERE PK_Id = 19; -- 角色權限管理(39) 子項目；Name_TN 原本已是「角色設定」，只修正跟 TN 對不上的 CN/EN/JP
UPDATE [Menu] SET MenuType = 7, Seq = 2 WHERE PK_Id = 43;  -- 權限設定，角色權限管理(39) 子項目
UPDATE [Menu] SET Name_TN = N'角色用戶查詢', Name_CN = N'角色用户查询', Name_EN = N'Role User Query', Name_JP = N'役職ユーザー照会', MenuType = 7, Seq = 3, ParentId = 39 WHERE PK_Id = 60; -- 對應 Excel「角色用戶查詢」，併入角色權限管理(39) 子項目
UPDATE [Menu] SET MenuType = 7, Seq = 2 WHERE PK_Id = 109; -- 排程管理

-- 報表管理（MenuType=8）
UPDATE [Menu] SET MenuType = 8, Seq = 1 WHERE PK_Id = 159; -- 餘額/額度統計月報
UPDATE [Menu] SET Name_TN = N'風險等級餘額趨勢月報表', Name_CN = N'风险等级余额趋势月报表', Name_EN = N'Risk Level Balance Trend Monthly Report', Name_JP = N'リスクレベル残高推移月報', MenuType = 8, Seq = 2 WHERE PK_Id = 160;

-- ══════════════════════════════════════════════════════════════════════════
-- 停用已隨前端功能一併移除的選單（流程設計器 / 國家例外查詢 / 國家關注查詢）
-- ══════════════════════════════════════════════════════════════════════════

UPDATE [Menu] SET IsActive = 0 WHERE PK_Id IN (20, 131, 132,8,97,5,70);
