CREATE DEFINER=`root`@`localhost` PROCEDURE `OpStatusEmergExit`(
userIDVal varchar(255),
nodeTypeValue varchar(255)
)
BEGIN

	DECLARE MonitoredDevices INT;
	DECLARE OfflineDevices INT;
	DECLARE AlertDevices INT;
	DECLARE OperationalDevices INT;
	DECLARE LowBattery INT;
	DECLARE AlertDevicesLowBattery INT;
	DECLARE AlertDevicesFire INT;

	SET MonitoredDevices = (Select count(*) As MonitoredDevices from node_details as n 
			where n.Status = 'Active' and NodeType In (nodeTypeValue) 
			and NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal));
            
	SET OfflineDevices = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		where alarm.IsResolved is null
        and n.Status = 'Active'
        and n.NodeType in (nodeTypeValue)
		and alarm.Descr = 'Node is Offline');
	
    SET AlertDevices = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In (nodeTypeValue)
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
		where alarm.IsResolved is null and n.Status = 'Active');
        
	SET LowBattery = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		where alarm.IsResolved is null
        and n.Status = 'Active'
        and n.NodeType in (nodeTypeValue)
		and alarm.Descr = 'Low Battery');
        
	SET OperationalDevices = MonitoredDevices - (OfflineDevices + AlertDevices);
	if(nodeTypeValue = 'EmergLight') then
	Select 'Emergency Light' As Devices, MonitoredDevices As Total, OperationalDevices As Operational, AlertDevices As WarningAlert, OfflineDevices as OfflineDevice, LowBattery as LowBattery;  
	else
	Select 'Exit Light' As Devices, MonitoredDevices As Total, OperationalDevices As Operational, AlertDevices As WarningAlert, OfflineDevices as OfflineDevice, LowBattery as LowBattery; 
	end if;
END