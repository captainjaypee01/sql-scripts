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
 
SET MonitoredDevices = (Select count(*) As MonitoredDevices from node_details where NodeType In ('FireExtinguisher') and NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID = userIDVal));
SET OfflineDevices = (Select count(*) As OfflineDevices from node_details where NodeType In ('FireExtinguisher') and NodeOnlineStatus = 0 and NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID = userIDVal));
SET AlertDevicesLowBattery = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In ('FireExtinguisher') and n.NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID = userIDVal) 
where alarm.IsResolved is null and alarm.Descr = 'Low Battery'
and n.NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID = userIDVal)
and alarm.NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID = userIDVal));
SET AlertDevicesFire = (Select count(*) As AlertDevices from node_fx_logic where Leak1 = 1 or Leak2 = 1 or ForeignObj = 1 or Missing = 1 and NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID = userIDVal));

SET AlertDevices = AlertDevicesFire + AlertDevicesLowBattery;
SET OperationalDevices = MonitoredDevices - (OfflineDevices + AlertDevices);
Select 'Fire Extinguisher' As Devices, MonitoredDevices As Total, OperationalDevices As Operational, AlertDevices As WarningAlert;  


END