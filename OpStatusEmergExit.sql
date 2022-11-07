CREATE DEFINER=`root`@`localhost` PROCEDURE `OpStatusEmergExit`(
nodeTypeValue varchar(255),
userIDVal varchar(255)
)
BEGIN

DECLARE MonitoredDevices INT;
DECLARE OfflineDevices INT;
DECLARE AlertDevices INT;
DECLARE OperationalDevices INT;
DECLARE AlertDevicesLowBattery INT;
DECLARE AlertDevicesFire INT;

SET MonitoredDevices = (Select count(*) As MonitoredDevices from node_details As n where n.NodeType In (nodeTypeValue)  and n.NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID = userIDVal));
SET OfflineDevices = (Select count(*) As OfflineDevices from node_details As n where NodeType In (nodeTypeValue) and n.NodeOnlineStatus = 0  and n.NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID = userIDVal));
SET AlertDevices = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In (nodeTypeValue)
and n.NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID = userIDVal)
where alarm.IsResolved is null
and n.NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID = userIDVal)
and alarm.NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID = userIDVal));

SET OperationalDevices = MonitoredDevices - (OfflineDevices + AlertDevices);
if(nodeTypeValue = 'EmergLight') then
Select 'Emergency Light' As Devices, MonitoredDevices As Total, OperationalDevices As Operational, AlertDevices As WarningAlert;  
else
Select 'Exit Light' As Devices, MonitoredDevices As Total, OperationalDevices As Operational, AlertDevices As WarningAlert; 
end if;
END