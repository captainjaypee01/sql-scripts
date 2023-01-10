CREATE DEFINER=`root`@`localhost` PROCEDURE `OperationalStatus`(
	in NetworkList varchar(255),
	in NodeTypes varchar(255),
    DeviceType varchar(255)
)
BEGIN
	
	DECLARE MonitoredDevices INT;
	DECLARE OfflineDevices INT;
	DECLARE AlertDevices INT;
	DECLARE OperationalDevices INT;
	DECLARE LowBattery INT;
	DECLARE AlertDevicesLowBattery INT;
	DECLARE AlertDevicesFire INT;
    DECLARE AllAlerts INT;

	SET MonitoredDevices = (
			Select count(*) As MonitoredDevices from node_details as n 
			where n.Status = 'Active' and FIND_IN_SET (n.NodeType, NodeTypes)
			and FIND_IN_SET (n.NetworkID, NetworkList)
            );
            
	SET OfflineDevices = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and FIND_IN_SET (n.NetworkID, NetworkList)
		where alarm.IsResolved is null
        and n.Status = 'Active'
        and  FIND_IN_SET (n.NodeType, NodeTypes)
		and alarm.Descr = 'Node is Offline');
	
    SET AlertDevices = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and FIND_IN_SET (n.NodeType, NodeTypes)
		and FIND_IN_SET (n.NetworkID, NetworkList)
		where alarm.IsResolved is null 
        and alarm.Descr not in ('Low Battery', 'Node is Offline')
        and n.Status = 'Active');
        
	SET LowBattery = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and FIND_IN_SET (n.NetworkID, NetworkList)
		where alarm.IsResolved is null
        and n.Status = 'Active'
        and FIND_IN_SET (n.NodeType, NodeTypes)
		and alarm.Descr = 'Low Battery');
        
	SET AllAlerts= (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and FIND_IN_SET (n.NodeType, NodeTypes)
		and FIND_IN_SET (n.NetworkID, NetworkList)
		where n.Status = 'Active' 
        and alarm.IsResolved is null
        and alarm.Descr not in ('Low Battery')
		and FIND_IN_SET (n.NetworkID, NetworkList) );
        
	SET OperationalDevices = CASE WHEN 
                            (MonitoredDevices > (AllAlerts)) THEN (MonitoredDevices - (AllAlerts))
                            ELSE 0
                        END;
	Set DeviceType = DeviceType;
	Select DeviceType As Devices, MonitoredDevices As Total, OperationalDevices As Operational, AlertDevices As WarningAlert, OfflineDevices as OfflineDevice, LowBattery as LowBattery;  

END