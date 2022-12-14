CREATE DEFINER=`root`@`localhost` PROCEDURE `EmergOverall`(
userIDVal varchar(255),
NodeTypeOne varchar(255),
NodeTypeTwo varchar(255)
)
BEGIN
	
    
	DECLARE MonitoredDevices INT;
	DECLARE OfflineDevices INT;
	DECLARE OperationalDevices INT;
	DECLARE LowBattery INT;
	DECLARE AlertDevicesExitEmerg INT;
	DECLARE AlertDevices INT;
    DECLARE AllAlerts INT;
 
	SET MonitoredDevices = (Select count(*) As MonitoredDevices from node_details as n 
		where n.Status = 'Active' and NodeType In (NodeTypeOne, NodeTypeTwo) and NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal));
	SET OfflineDevices = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In (NodeTypeOne, NodeTypeTwo) 
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		where alarm.IsResolved is null
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		and alarm.Descr = 'Node is Offline');
	SET AlertDevicesExitEmerg = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In (NodeTypeOne, NodeTypeTwo) 
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		where n.Status = 'Active' 
        and alarm.IsResolved is null
        and alarm.Descr not in ('Low Battery', 'Node is Offline')
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal));
        
	SET LowBattery = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In (NodeTypeOne, NodeTypeTwo) 
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		where n.Status = 'Active' 
        and alarm.IsResolved is null
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		and alarm.Descr = 'Low Battery');
        
	SET AllAlerts = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In (NodeTypeOne, NodeTypeTwo) 
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		where n.Status = 'Active' 
        and alarm.IsResolved is null
        and alarm.Descr not in ('Low Battery')
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal));
        
	SET AlertDevices = AlertDevicesExitEmerg;
    SET OperationalDevices = CASE WHEN 
                            (MonitoredDevices > (AllAlerts)) THEN (MonitoredDevices - AllAlerts)
                            ELSE 0
                        END;
	Select MonitoredDevices As MonitoredDevices, OperationalDevices As OperationalDevices, AlertDevices As AlertDevices, OfflineDevices As OfflineDevices, LowBattery As LowBattery; 

END