CREATE DEFINER=`root`@`localhost` PROCEDURE `FireExtinguisherOverall`(
userIDVal varchar(255)
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
		where n.Status = 'Active' and n.NodeType In ('FireExtinguisher') and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal));
	SET OfflineDevices = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In ('FireExtinguisher') and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		where alarm.IsResolved is null
        and n.Status = 'Active'
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
		and alarm.Descr = 'Node is Offline');

    SET AlertDevicesFire = (SELECT count(*) As AlertDevices FROM node_fx_logic As fx JOIN node_details As n on n.NodeID = fx.NodeID 
    and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
    where n.NodeType = 'FireExtinguisher' and fx.Leak1 = 1 or fx.Leak2 = 1 or fx.ForeignObj = 1 or fx.Missing = 1 or fx.Blockage = 1
    and n.NetworkID in (SELECT un.NetworkID FROM users_network un where un.UserID COLLATE utf8mb4_general_ci  = userIDVal));
        
    SET LowBattery = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
    on n.NodeID = alarm.NodeID 
    and n.NetworkID = alarm.NetworkID and n.NodeType In ('FireExtinguisher') and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
    where alarm.IsResolved is null
    and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
    and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
    and alarm.Descr = 'Low Battery');
    SET AlertDevices = AlertDevicesFire + LowBattery;
    SET OperationalDevices = CASE WHEN 
                            (MonitoredDevices > (OfflineDevices + AlertDevices)) THEN (MonitoredDevices - (OfflineDevices + AlertDevices))
                            ELSE 0
                        END;
    Select MonitoredDevices As MonitoredDevices, OperationalDevices As OperationalDevices, AlertDevices As AlertDevices, OfflineDevices As OfflineDevices, LowBattery As LowBattery; 

END