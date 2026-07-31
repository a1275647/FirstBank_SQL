-- 角色比對規則的單一來源：一個角色屬於某使用者，代表
--   1) 該角色有直接指派給這個使用者（Role_User_Mapping），或
--   2) 該角色的職位對應（Role_Position_Mapping）符合使用者「目前」的分行/部門＋職稱
-- 用 UNION（非 UNION ALL）避免同一個使用者透過兩種方式對到同一個角色時出現重複列。
CREATE VIEW dbo.RoleUserMatch AS
SELECT u.UserId, rum.FK_Role_Id AS RoleId
FROM Users u
INNER JOIN Role_User_Mapping rum ON rum.FK_User_Id = u.UserId

UNION

SELECT u.UserId, rpm.FK_Role_Id AS RoleId
FROM Users u
INNER JOIN Role_Position_Mapping rpm
    ON rpm.TitleCode = u.TitleCode
   AND (
        (rpm.FK_Branch_Code IS NOT NULL AND rpm.FK_Branch_Code = u.BranchCode)
        OR
        (rpm.FK_Branch_Code IS NULL AND rpm.FK_Department_Code = u.DepartmentCode)
   );
GO
