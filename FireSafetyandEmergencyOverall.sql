CREATE DEFINER=`root`@`localhost` PROCEDURE `FireSafetyandEmergencyOverall`(
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
 
SET MonitoredDevices = (Select count(*) As MonitoredDevices from node_details where NodeType In ('FireExtinguisher','EmergLight','ExitLight') and NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID COLLATE utf8mb4_general_ci = userIDVal));
SET OfflineDevices = (Select count(*) As OfflineDevices from node_details where NodeType In ('FireExtinguisher','EmergLight','ExitLight') and NodeOnlineStatus = 0 and NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID COLLATE utf8mb4_general_ci = userIDVal));
SET AlertDevicesExitEmerg = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In ('EmergLight','ExitLight') and n.NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID COLLATE utf8mb4_general_ci = userIDVal) where alarm.IsResolved is null and n.NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
and alarm.NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID COLLATE utf8mb4_general_ci = userIDVal));
SET AlertDevicesFire = (Select count(*) As AlertDevices from node_fx_logic where Leak1 = 1 or Leak2 = 1 or ForeignObj = 1 or Missing = 1 and NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID COLLATE utf8mb4_general_ci = userIDVal));
SET LowBattery = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n JOIN node_alarm_log As alarm 
on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In ('FireExtinguisher','EmergLight','ExitLight') and n.NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
where alarm.IsResolved is null
and n.NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
and alarm.NetworkID in (SELECT NetworkID FROM smartnew.users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
and alarm.Descr = 'Low Battery');
SET AlertDevices = AlertDevicesFire + AlertDevicesExitEmerg + LowBattery;
SET OperationalDevices = MonitoredDevices - (OfflineDevices + AlertDevices);
Select MonitoredDevices As MonitoredDevices, OperationalDevices As OperationalDevices, AlertDevices As AlertDevices, OfflineDevices As OfflineDevices, LowBattery As LowBattery; 

END