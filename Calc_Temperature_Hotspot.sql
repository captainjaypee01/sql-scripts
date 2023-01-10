CREATE DEFINER=`root`@`localhost` PROCEDURE `Calc_Temperature_Hotspot`(
	in NetworkList varchar(255),
	in NodeTypes varchar(255)
)
BEGIN

    
DECLARE cursor_BuildingName VARCHAR(255);
DECLARE cursor_Sector VARCHAR(255);
DECLARE cursor_Val VARCHAR(255);
DECLARE cursor_ValTwo VARCHAR(255);
DECLARE done INT DEFAULT FALSE;

DECLARE cursor_maximum CURSOR FOR SELECT n.BuildingName, n.SectorName, Max(SensorValue02) Maximum, Min(SensorValue02) Minimum FROM node_latest_readings As reading 
LEFT JOIN node_details As n on n.NodeID = reading.NodeID and n.NetworkID = reading.NetworkID and n.Status = 'Active'
where FIND_IN_SET (n.NodeType, NodeTypes) and FIND_IN_SET (n.NetworkID, NetworkList) and updated_at > UTC_TIMESTAMP() - interval 1 hour
group by n.BuildingName,n.SectorName; 

DECLARE cursor_current CURSOR FOR SELECT n.BuildingName, n.SectorName, Max(SensorValue02) Maximum FROM node_latest_readings As reading 
JOIN node_details As n on n.NodeID = reading.NodeID and n.NetworkID = reading.NetworkID and n.Status = 'Active'
where FIND_IN_SET (n.NodeType, NodeTypes) and FIND_IN_SET (n.NetworkID, NetworkList) and updated_at > UTC_TIMESTAMP() - interval 1 hour
group by n.BuildingName,n.SectorName; 

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
FROM node_details as nd 
LEFT JOIN node_latest_readings as nlr on nlr.NetworkID = nd.NetworkID and nlr.NodeID = nd.NodeID
WHERE nd.Status = 'Active' group by nd.BuildingName, nd.SectorName, nd.NodeType, nd.NetworkID 
having FIND_IN_SET (NodeType, NodeTypes) and FIND_IN_SET (NetworkID, NetworkList);
    	
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