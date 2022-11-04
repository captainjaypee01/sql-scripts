CREATE DEFINER=`root`@`localhost` PROCEDURE `Calc_Emerg_Operational_Status`(
	userIDVal varchar(255),
	NodeTypeOne varchar(255),
	NodeTypeTwo varchar(255)
)
BEGIN


	DECLARE cursor_BuildingName VARCHAR(255);
	DECLARE cursor_VAL VARCHAR(255);
	DECLARE done INT DEFAULT FALSE;

	DECLARE cursor_i CURSOR FOR (SELECT count(*) As OfflineDevice, BuildingName FROM node_details as n
		where n.Status = 'Active'
		group by BuildingName, NodeType, NodeOnlineStatus, NetworkID having NodeType In (NodeTypeOne, NodeTypeTwo) and NodeOnlineStatus = 0
		and NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal));
	  
	DECLARE cursor_alert CURSOR FOR (Select count(distinct alarm.NodeID) As AlertDevice, BuildingName from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In ('EmergLight', 'ExitLight')
		where n.Status = 'Active'
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
		and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
		group by BuildingName, alarm.NodeID, n.NodeID, alarm.NetworkID, n.NetworkID, n.NodeType, alarm.IsResolved
		having alarm.IsResolved is null );

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	DELETE FROM `node_operational_status` WHERE NodeType = 'EmergExitLight';
	INSERT INTO `node_operational_status`
		(`BuildingName`,
		`MonitoredDevice`,
		`Operational`,
		`Alert`,
		`LostConnection`,
		`NodeType`)
		SELECT  tmp.BuildingName, sum(tmp.MonitoredDevice) As MonitoredDevice, sum(tmp.Operational) As Operational, 0,0,'EmergExitLight' from (
			SELECT BuildingName, count(*) As MonitoredDevice, count(*) As Operational FROM node_details as n
			where n.Status = 'Active'
			group by BuildingName,NodeType having NodeType  In ('EmergLight', 'ExitLight') ) As tmp
			group by tmp.BuildingName;
			
	OPEN cursor_i;
		read_loop: LOOP
			FETCH cursor_i INTO cursor_VAL, cursor_BuildingName;
				IF done THEN
				  LEAVE read_loop;
				END IF;

				UPDATE `node_operational_status`
				SET	`LostConnection` = LostConnection + cursor_VAL
				WHERE `BuildingName` COLLATE utf8mb4_general_ci = cursor_BuildingName
				and `NodeType` = 'EmergExitLight';


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
				and `NodeType` = 'EmergExitLight';
				
				UPDATE `node_operational_status`
				SET	`Operational` = MonitoredDevice - (Alert + LostConnection)
				WHERE `BuildingName` COLLATE utf8mb4_general_ci = cursor_BuildingName
				and `NodeType` = 'EmergExitLight';
			
		  END LOOP;
	CLOSE cursor_alert;
  
		SELECT BuildingName As Building, Operational, Alert, LostConnection 
		from `node_operational_status` where
		NodeType ='EmergExitLight';
END