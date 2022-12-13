CREATE DEFINER=`root`@`localhost` PROCEDURE `GetEmergLuminariesAlertBreakdown`(
userIDVal varchar(255),
in NodeTypes varchar(255)
)
BEGIN


	DECLARE LampTestFailed INT;
	DECLARE DrainBatteryTestFailed INT;
	DECLARE LowBrightness INT;
	
	SET LampTestFailed = (Select count(distinct n.NodeID) as LampTestFailed from node_details As n RIGHT JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID
        and FIND_IN_SET (n.NodeType, NodeTypes)
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
		where n.Status = 'Active' 
        and alarm.IsResolved is null
		and alarm.Descr like '%Lamp Test Failed%');

	SET DrainBatteryTestFailed = (Select count(distinct n.NodeID) as DrainBatteryTestFailed from node_details As n RIGHT JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID
        and FIND_IN_SET (n.NodeType, NodeTypes)
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
		where n.Status = 'Active' 
		and alarm.Descr like '%Drain Battery Test Failed%'
        and alarm.IsResolved is null);
        
	SET LowBrightness = (Select count(distinct n.NodeID) As LowBrightness from node_details As n RIGHT JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID
        and FIND_IN_SET (n.NodeType, NodeTypes)
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
		where n.Status = 'Active' 
		and alarm.Descr like '%Low Brightness%'
        and alarm.IsResolved is null);
        
	Select DrainBatteryTestFailed As DrainBatteryTestFailed, LampTestFailed As LampTestFailed, LowBrightness as LowBrightness;
END