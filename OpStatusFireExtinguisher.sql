CREATE DEFINER=`root`@`localhost` PROCEDURE `OpStatusFireExtinguisher`(
userIDVal varchar(255)
)
BEGIN

	DECLARE MonitoredDevices INT;
	DECLARE OfflineDevices INT;
	DECLARE AlertDevices INT;
	DECLARE OperationalDevices INT;
	DECLARE AlertDevicesLowBattery INT;
	DECLARE AlertDevicesFire INT;
 
	SET MonitoredDevices = (Select count(*) As MonitoredDevices from node_details as n
		where n.Status = 'Active' and NodeType In ('FireExtinguisher') 
        and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci  = userIDVal));
        
	SET OfflineDevices = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
	on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In ('FireExtinguisher') and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci  = userIDVal) 
	where alarm.IsResolved is null and alarm.Descr = 'Node is Offline' and n.Status = 'Active');
        
	SET AlertDevicesLowBattery = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
	on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In ('FireExtinguisher') and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci  = userIDVal) 
	where alarm.IsResolved is null and alarm.Descr = 'Low Battery' and n.Status = 'Active');
    
	SET AlertDevicesFire = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In ('FireExtinguisher')
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		where n.Status = 'Active' 
        and alarm.IsResolved is null
        and alarm.Descr not in ('Low Battery', 'Node is Offline')
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal));

        
	SET AlertDevices = AlertDevicesFire;
	SET OperationalDevices = MonitoredDevices - (OfflineDevices + AlertDevices);
	Select 'Fire Extinguisher' As Devices, MonitoredDevices As Total, OperationalDevices As Operational, AlertDevices As WarningAlert, OfflineDevices as OfflineDevice, AlertDevicesLowBattery as LowBattery;  


END