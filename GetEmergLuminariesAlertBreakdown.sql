CREATE DEFINER=`root`@`localhost` PROCEDURE `GetEmergLuminariesAlertBreakdown`(
userIDVal varchar(255),
in NodeTypes varchar(255)
)
BEGIN

	DECLARE LampTestFailed INT;
	DECLARE DrainBatteryTestFailed INT;
	DECLARE LowBrightness INT;
	
	SET LampTestFailed = (Select count(*) As LampTestFailed from node_details As n RIGHT JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID
        and FIND_IN_SET (n.NodeType, NodeTypes)
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
		where n.Status = 'Active' 
        and alarm.IsResolved is null
		and alarm.Descr like '%LampTestFailed%');

	SET DrainBatteryTestFailed = (Select count(*) As DrainBatteryTestFailed from node_details As n RIGHT JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID
        and FIND_IN_SET (n.NodeType, NodeTypes)
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
		where n.Status = 'Active' 
        and alarm.IsResolved is null
		and alarm.Descr like '%DrainBatteryTestFailed%');
        
	SET LowBrightness = (Select count(*) As LowBrightness from node_details As n RIGHT JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID
        and FIND_IN_SET (n.NodeType, NodeTypes)
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
		where n.Status = 'Active' 
        and alarm.IsResolved is null
		and alarm.Descr like '%Low Brightness%');
        
	Select DrainBatteryTestFailed As DrainBatteryTestFailed, LampTestFailed As LampTestFailed, LowBrightness as LowBrightness;
END