-- ============================================================
-- DATABASE: GRAND
-- ============================================================

-- Drop the database if it exists, then create a fresh one
DROP DATABASE IF EXISTS grand;
CREATE DATABASE grand;
USE grand;


-- ============================================================
-- TABLE CREATION
-- ============================================================

-- USERS TABLE
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    User_Name VARCHAR(32) NOT NULL,
    Security_level INT CHECK(Security_level BETWEEN 1 AND 5)
);

-- LOCATIONS TABLE
CREATE TABLE Location (
    LocationID INT PRIMARY KEY AUTO_INCREMENT,
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    Location_Name VARCHAR(64) NOT NULL,
    Threat INT CHECK(Threat BETWEEN 1 AND 5),
    clearance INT CHECK(clearance BETWEEN 1 AND 5)
);

-- CATEGORIES TABLE
CREATE TABLE Categories (
    CatID INT PRIMARY KEY AUTO_INCREMENT,
    Typeof VARCHAR(64) NOT NULL
);

-- ASSETS TABLE
CREATE TABLE Assets (
    AssetID INT PRIMARY KEY AUTO_INCREMENT,
    CatID INT,
    LocationID INT,
    Status_info VARCHAR(32),
    value_cost INT,
    title VARCHAR(64),
    clearance INT CHECK(clearance BETWEEN 1 AND 5),
    FOREIGN KEY(CatID) REFERENCES Categories(CatID),
    FOREIGN KEY(LocationID) REFERENCES Location(LocationID)
);

-- ACCESS LOG TABLE
CREATE TABLE Access_log (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    AssetID INT,
    Action_done VARCHAR(32),
    Status_info CHAR(1) CHECK(Status_info IN ('T','F')),
    FOREIGN KEY(UserID) REFERENCES Users(UserID),
    FOREIGN KEY(AssetID) REFERENCES Assets(AssetID)
);


-- ============================================================
-- INSERT DATA
-- ============================================================

-- Users
INSERT INTO Users (User_Name, Security_level) VALUES
('Bruce Wayne', 5),
('Dick Grayson', 4),
('Alfred Pennyworth', 5),
('Alt Cunninham', 5),
('Arthur Morgan', 3),
('Michael De Santa', 1),
('Guts', 3),
('Casca', 2),
('Adam Smasher', 1);

-- Locations
INSERT INTO Location (latitude, longitude, Location_Name, Threat, clearance) VALUES
(40.7128, -74.0060, 'Arkham Asylum - Medical Pavilion', 5, 5),
(34.0522, -118.2437, 'Los Santos - Diamond Casino Vault', 3, 4),
(36.1699, -115.1398, 'Beecher’s Hope - Blackwater', 2, 2),
(35.6895, 139.6917, 'Arasaka Tower - CEO Floor', 5, 5),
(47.1524, 27.6014, 'Falconia - Inner Circle', 4, 5);

-- Categories
INSERT INTO Categories (Typeof) VALUES
('Heavy Ordinance & Vehicles'),
('Cursed Artifacts'),
('Netrunning Software'),
('Outlaw Gear'),
('Chemical Compounds');

-- Assets
INSERT INTO Assets (CatID, LocationID, Status_info, value_cost, title, clearance) VALUES
(5, 1, 'Highly Volatile', 15000, 'Fear Toxin (Crane Grade)', 5),
(1, 1, 'Damaged', 2500000, 'Arkham Knight Cloudburst', 5),
(1, 2, 'Operational', 3500000, 'Oppressor Mk II', 4),
(4, 3, 'Vintage', 45, 'Schofield Revolver (Dutch)', 2),
(3, 4, 'Contained', 1000000, 'Soulkiller v3.5', 5),
(1, 4, 'Standard', 150000, 'Rayfield Caliburn', 3),
(2, 5, 'Bloodsoaked', 0, 'Dragon Slayer Sword', 5),
(2, 5, 'Active', 0, 'Beherit (Crimson)', 5),
(5, 1, 'Dormant State', 15, 'Titan Toxin (Bane grade)', 5);

-- Access Log
INSERT INTO Access_log (UserID, AssetID, Action_done, Status_info) VALUES
(1, 1, 'Confiscated', 'T'),
(7, 7, 'Retrieved', 'T'),
(4, 5, 'Digital Breach', 'F'),
(5, 4, 'Maintained', 'T'),
(8, 8, 'Activated', 'T'),
(9, 6, 'Deployed', 'T'),
(6, 3, 'Stole', 'T');


-- ============================================================
-- EXAMPLE QUERIES
-- ============================================================

-- 1. INNER JOIN: Users who accessed Chemical Compounds
SELECT 
    u.User_Name,
    a.title AS Asset,
    c.Typeof AS Category,
    al.Action_done
FROM Access_log al
INNER JOIN Users u ON al.UserID = u.UserID
INNER JOIN Assets a ON al.AssetID = a.AssetID
INNER JOIN Categories c ON a.CatID = c.CatID
WHERE c.Typeof = 'Chemical Compounds';

-- 2. LEFT JOIN: All users and the Chemical Compounds they accessed (NULL if none)
SELECT 
    u.User_Name,
    a.title AS Asset,
    c.Typeof AS Category,
    al.Action_done
FROM Users u
LEFT JOIN Access_log al ON u.UserID = al.UserID
LEFT JOIN Assets a ON al.AssetID = a.AssetID
LEFT JOIN Categories c ON a.CatID = c.CatID
WHERE c.Typeof = 'Chemical Compounds';

-- 3. RIGHT JOIN: All Chemical Compounds and who accessed them
SELECT 
    u.User_Name,
    a.title AS Asset,
    c.Typeof AS Category,
    al.Action_done
FROM Users u
RIGHT JOIN Access_log al ON u.UserID = al.UserID
RIGHT JOIN Assets a ON al.AssetID = a.AssetID
RIGHT JOIN Categories c ON a.CatID = c.CatID
WHERE c.Typeof = 'Chemical Compounds';

-- 4. Count of assets accessed by each user
SELECT 
    u.User_Name,
    COUNT(al.AssetID) AS Assets_Accessed
FROM Users u
LEFT JOIN Access_log al ON u.UserID = al.UserID
GROUP BY u.User_Name;

-- 5. Total value of assets at each location
SELECT 
    l.Location_Name,
    SUM(a.value_cost) AS Total_Asset_Value
FROM Location l
LEFT JOIN Assets a ON l.LocationID = a.LocationID
GROUP BY l.Location_Name;

-- 6. Average value of assets in each category
SELECT 
    c.Typeof AS Category,
    AVG(a.value_cost) AS Avg_Asset_Value
FROM Categories c
LEFT JOIN Assets a ON c.CatID = a.CatID
GROUP BY c.Typeof;

-- 7. Count of assets per security clearance level
SELECT 
    a.clearance AS Clearance_Level,
    COUNT(a.AssetID) AS Num_Assets
FROM Assets a
GROUP BY a.clearance;

-- 8. Subquery example: Users who accessed the most expensive asset
SELECT 
    u.User_Name, 
    a.AssetID, 
    a.title, 
    a.value_cost
FROM Users u
JOIN Access_log al ON u.UserID = al.UserID
JOIN Assets a ON al.AssetID = a.AssetID
WHERE a.value_cost = (SELECT MAX(value_cost) FROM Assets);

-- 9. View example: Asset details with location and category
CREATE OR REPLACE VIEW Asset_Details AS
SELECT 
    a.AssetID,
    a.title AS Asset,
    a.value_cost,
    a.Status_info,
    l.Location_Name,
    c.Typeof AS Category
FROM Assets a
JOIN Location l ON a.LocationID = l.LocationID
JOIN Categories c ON a.CatID = c.CatID;

-- To check the view
SELECT * FROM Asset_Details;

-- 10. Transaction example: Transfer an asset from one location to another
START TRANSACTION;

-- Move 'Titan Toxin (Bane grade)' from LocationID 1 to 2
UPDATE Assets
SET LocationID = 2
WHERE title = 'Titan Toxin (Bane grade)';

-- Optional check before committing
SELECT value_cost FROM Assets WHERE title = 'Titan Toxin (Bane grade)';

-- Commit changes
COMMIT;

-- If something goes wrong:
-- ROLLBACK;
