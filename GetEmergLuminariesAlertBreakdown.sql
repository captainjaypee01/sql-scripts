CREATE DEFINER=`root`@`localhost` PROCEDURE `GetEmergLuminariesAlertBreakdown`(
userIDVal varchar(255),
NodeTypeOne varchar(255),
NodeTypeTwo varchar(255)
)
BEGIN

	DECLARE LampFailure INT;
	DECLARE DrainBatteryTestFailed INT;
	
	SET LampFailure = (Select count(*) As DrainBatteryTestFailed from node_details As n RIGHT JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID
        and n.NodeType In (NodeTypeOne, NodeTypeTwo) 
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
		where n.Status = 'Active' 
        and alarm.IsResolved is null
		and alarm.Descr like '%LampFailure%');

	SET DrainBatteryTestFailed = (Select count(*) As DrainBatteryTestFailed from node_details As n RIGHT JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID
        and n.NodeType In (NodeTypeOne, NodeTypeTwo) 
		and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
		where n.Status = 'Active' 
        and alarm.IsResolved is null
		and alarm.Descr like '%DrainBatteryTestFailed%');
        
	Select DrainBatteryTestFailed As DrainBatteryTestFailed, LampFailure As LampFailure;
END