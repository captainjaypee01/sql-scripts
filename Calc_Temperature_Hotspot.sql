CREATE DEFINER=`root`@`localhost` PROCEDURE `Calc_Temperature_Hotspot`(
userIDVal varchar(255)
)
BEGIN

    
DECLARE cursor_BuildingName VARCHAR(255);
DECLARE cursor_Sector VARCHAR(255);
DECLARE cursor_Val VARCHAR(255);
DECLARE cursor_ValTwo VARCHAR(255);
DECLARE done INT DEFAULT FALSE;
DECLARE cursor_maximum CURSOR FOR SELECT n.BuildingName, n.SectorName, Max(SensorValue02) Maximum, Min(SensorValue02) Minimum FROM node_latest_readings As reading 
JOIN node_details As n on n.NodeID = reading.NodeID and n.NetworkID = reading.NetworkID and n.Status = 'Active'
group by n.BuildingName,n.SectorName, SensorValue02, n.NodeType, reading.updated_at, n.NetworkID having n.NodeType = 'FireExtinguisher'
and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci  = userIDVal);

DECLARE cursor_current CURSOR FOR SELECT n.BuildingName, n.SectorName, Max(SensorValue02) Maximum FROM node_latest_readings As reading 
JOIN node_details As n on n.NodeID = reading.NodeID and n.NetworkID = reading.NetworkID and n.Status = 'Active'
group by n.BuildingName,n.SectorName, SensorValue02, n.NodeType, reading.updated_at, n.NetworkID 
having n.NodeType = 'FireExtinguisher' and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci  = userIDVal);

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

TRUNCATE TABLE `temperature_hotspot`;
INSERT INTO `temperature_hotspot`
	(`Location`,
	`Sector`,
	`minimum`,
	`average`,
	`maximum`,
    `total_node`
    )
SELECT BuildingName As Location, SectorName As Sector, 0,0,0,0
FROM node_details group by BuildingName, SectorName, NodeType, NetworkID having NodeType = 'FireExtinguisher'
and NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci  = userIDVal);
    	
OPEN cursor_maximum;
  read_maximum_loop: LOOP
    FETCH cursor_maximum INTO cursor_BuildingName, cursor_Sector, cursor_Val, cursor_ValTwo;
    IF done THEN
      LEAVE read_maximum_loop;
    END IF;
    
    UPDATE `temperature_hotspot`
	SET	`maximum` = cursor_Val, `minimum` = cursor_ValTwo
	WHERE `Location` COLLATE utf8mb4_general_ci = cursor_BuildingName
    and `Sector` COLLATE utf8mb4_general_ci = cursor_Sector;
   
    
  END LOOP;
  CLOSE cursor_maximum;

	
   
	SET done = false;
    OPEN cursor_current;
  read_current_loop: LOOP
    FETCH cursor_current INTO cursor_BuildingName, cursor_Sector, cursor_Val;
    IF done THEN
      LEAVE read_current_loop;
    END IF;
    
	UPDATE `temperature_hotspot`
	SET	`current_max` = cursor_Val
	WHERE `Location` COLLATE utf8mb4_general_ci = cursor_BuildingName
    and `Sector` COLLATE utf8mb4_general_ci = cursor_Sector;
    
    UPDATE `temperature_hotspot`
	SET	`average` =  (maximum + minimum) / 2
	WHERE `Location` COLLATE utf8mb4_general_ci = cursor_BuildingName
    and `Sector` COLLATE utf8mb4_general_ci = cursor_Sector;
    
  END LOOP;
  CLOSE cursor_current;
   
    
    
END