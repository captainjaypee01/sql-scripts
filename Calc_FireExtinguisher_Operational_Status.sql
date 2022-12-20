CREATE DEFINER=`root`@`localhost` PROCEDURE `Calc_FireExtinguisher_Operational_Status`(
userIDVal varchar(255)
)
BEGIN
    DECLARE cursor_BuildingName VARCHAR(255);
    DECLARE cursor_VAL VARCHAR(255);
    DECLARE done INT DEFAULT FALSE;
    DECLARE cursor_i CURSOR FOR (Select count(distinct alarm.NodeID) As OfflineDevice, BuildingName from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In ('FireExtinguisher')
		where n.Status = 'Active'
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
        and alarm.Descr = 'Node is Offline'
		group by BuildingName, alarm.NodeID, n.NodeID, alarm.NetworkID, n.NetworkID, n.NodeType, alarm.IsResolved
		having alarm.IsResolved is null );
    
    DECLARE cursor_alert CURSOR FOR (Select count(distinct alarm.NodeID) As AlertDevice, BuildingName from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In ('FireExtinguisher')
		where n.Status = 'Active'
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
        and alarm.Descr not in ('Low Battery', 'Node is Offline')
		and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		group by BuildingName, alarm.NodeID, n.NodeID, alarm.NetworkID, n.NetworkID, n.NodeType, alarm.IsResolved
		having alarm.IsResolved is null );
        
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DELETE FROM `node_operational_status` WHERE NodeType = 'FireExtinguisher';
        INSERT INTO `node_operational_status`
        (`BuildingName`,
        `MonitoredDevice`,
        `Operational`,
        `Alert`,
        `LostConnection`,
        `NodeType`)
        SELECT BuildingName, count(*) As MonitoredDevice, count(*) As Operational, 0,0,'FireExtinguisher' FROM node_details as n
        where n.Status = 'Active'
        and n.NetworkID in (SELECT un.NetworkID FROM users_network un where un.UserID COLLATE utf8mb4_general_ci = userIDVal)
        group by n.BuildingName, n.NodeType having NodeType = 'FireExtinguisher';
            
        OPEN cursor_i;
    read_loop: LOOP
        FETCH cursor_i INTO cursor_VAL, cursor_BuildingName;
        IF done THEN
        LEAVE read_loop;
        END IF;
        
        UPDATE `node_operational_status`
        SET	`LostConnection` = LostConnection + cursor_VAL
        WHERE `BuildingName` COLLATE utf8mb4_general_ci = cursor_BuildingName
        and `NodeType` = 'FireExtinguisher';
        
        
    END LOOP;
    CLOSE cursor_i;

        
    
        SET done = false;
        OPEN cursor_alert;
    read_alert_loop: LOOP
        FETCH cursor_alert INTO cursor_VAL, cursor_BuildingName;
        IF done THEN
        LEAVE read_alert_loop;
        END IF;
        
        UPDATE `node_operational_status`
        SET	`Alert` = Alert + cursor_VAL
        WHERE `BuildingName` COLLATE utf8mb4_general_ci = cursor_BuildingName
        and `NodeType` = 'FireExtinguisher';
        
        UPDATE `node_operational_status`
        SET	`Operational` = CASE WHEN 
                        (MonitoredDevice > (Alert + LostConnection)) THEN (MonitoredDevice - (LostConnection + Alert))
                        ELSE 0
                    END
        WHERE `BuildingName` COLLATE utf8mb4_general_ci = cursor_BuildingName
        and `NodeType` = 'FireExtinguisher';
        
    END LOOP;
    CLOSE cursor_alert;
    
    SELECT BuildingName As Building, Operational, Alert, LostConnection 
    from `node_operational_status` where
    NodeType ='FireExtinguisher';
    
    
END