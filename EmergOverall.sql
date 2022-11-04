CREATE DEFINER=`root`@`localhost` PROCEDURE `EmergOverall`(
NodeTypeOne varchar(255),
NodeTypeTwo varchar(255),
userIDVal varchar(255)
)
BEGIN
	
    
DECLARE MonitoredDevices INT;
DECLARE OfflineDevices INT;
DECLARE OperationalDevices INT;
DECLARE LowBattery INT;
DECLARE AlertDevicesExitEmerg INT;
DECLARE AlertDevices INT;
 
SET MonitoredDevices = (Select count(*) As MonitoredDevices from node_details where NodeType In (NodeTypeOne, NodeTypeTwo) and NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal));
SET OfflineDevices = (Select count(*) As OfflineDevices from node_details where NodeType In (NodeTypeOne, NodeTypeTwo) and NodeOnlineStatus = 0 and NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal));
SET AlertDevicesExitEmerg = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In (NodeTypeOne, NodeTypeTwo) 
and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
where alarm.IsResolved is null
and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal));
SET LowBattery = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In (NodeTypeOne, NodeTypeTwo) 
and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
where alarm.IsResolved is null
and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
and alarm.Descr = 'Low Battery');
SET AlertDevices = AlertDevicesExitEmerg + LowBattery;
SET OperationalDevices = MonitoredDevices - (OfflineDevices + AlertDevices);
Select MonitoredDevices As MonitoredDevices, OperationalDevices As OperationalDevices, AlertDevices As AlertDevices, OfflineDevices As OfflineDevices, LowBattery As LowBattery; 

END