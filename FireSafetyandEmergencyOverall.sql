CREATE DEFINER=`root`@`localhost` PROCEDURE `FireSafetyandEmergencyOverall`(
	userIDVal varchar(255),
	NodeTypeValOne varchar(255),
	NodeTypeValTwo varchar(255),
	NodeTypeValThree varchar(255)

)
BEGIN

	DECLARE MonitoredDevices INT;
	DECLARE OfflineDevices INT;
	DECLARE AlertDevicesFire INT;
	DECLARE OperationalDevices INT;
	DECLARE LowBattery INT;
	DECLARE AlertDevicesExitEmerg INT;
	DECLARE AlertDevices INT;
 
	SET MonitoredDevices = (Select count(*) As MonitoredDevices from node_details as n 
		where n.Status = 'Active' and NodeType In (NodeTypeValOne,NodeTypeValTwo,NodeTypeValThree) 
        and NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal));
	SET OfflineDevices = (Select count(distinct alarm.NodeID) As OfflineDevices from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In (NodeTypeValOne,NodeTypeValTwo,NodeTypeValThree) and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		where alarm.IsResolved is null
        and n.Status = 'Active'
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		and alarm.Descr = 'Node is Offline');
	SET AlertDevicesExitEmerg = (Select count(distinct alarm.NodeID) As AlertDevicesExitEmerg from node_details As n 
		JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID 
		and n.NetworkID = alarm.NetworkID and n.NodeType In ('EmergLight','ExitLight') 
        and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal) 
        where n.Status = 'Active' and alarm.IsResolved is null and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal));
	SET AlertDevicesFire =  (Select count(distinct alarm.NodeID) As AlertDevicesFire from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In ('FireExtinguisher')
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		where n.Status = 'Active' 
        and alarm.IsResolved is null
        and alarm.Descr not in ('Low Battery', 'Node is Offline')
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal));
        
	SET LowBattery = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In (NodeTypeValOne,NodeTypeValTwo,NodeTypeValThree) and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		where alarm.IsResolved is null
        and n.Status = 'Active'
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		and alarm.Descr = 'Low Battery');
        
	SET AlertDevices = AlertDevicesFire + AlertDevicesExitEmerg;
	SET OperationalDevices = MonitoredDevices - (OfflineDevices + AlertDevices);
	Select MonitoredDevices As MonitoredDevices, OperationalDevices As OperationalDevices, AlertDevices As AlertDevices, OfflineDevices As OfflineDevices, LowBattery As LowBattery; 

END