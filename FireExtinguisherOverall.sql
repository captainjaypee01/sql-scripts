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
        JOIN node_fx_logic fx on fx.NodeID = n.NodeID where n.NodeType In ('FireExtinguisher') and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal));
    SET OfflineDevices = (Select count(*) As OfflineDevices from node_details as n
        JOIN node_fx_logic fx on fx.NodeID = n.NodeID where n.NodeType In ('FireExtinguisher') and n.NodeOnlineStatus = 0 and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal));
    /*
    SET AlertDevicesExitEmerg = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
    on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In ('EmergLight','ExitLight') and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal) where alarm.IsResolved is null and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
    and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal));
    */
    SET AlertDevicesFire = (Select count(*) As AlertDevices from node_fx_logic where Leak1 = 1 or Leak2 = 1 or ForeignObj = 1 or Missing = 1 or Blockage = 1 and NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal));
    SET LowBattery = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
    on n.NodeID = alarm.NodeID 
    JOIN node_fx_logic fx on fx.NodeID = n.NodeID
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