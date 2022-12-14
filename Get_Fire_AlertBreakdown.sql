CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_Fire_AlertBreakdown`(
    in NetworkList varchar(255)
)
BEGIN

	DECLARE Leaked INT;
	DECLARE ForeignObject INT;
	DECLARE Missing INT;
	DECLARE Blockage INT;
	
	SET Leaked = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n RIGHT JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID
        and n.NodeType In ('FireExtinguisher')  and n.NetworkID = alarm.NetworkID
		where n.Status = 'Active' 
		and FIND_IN_SET (n.NetworkID, NetworkList)
		and alarm.Descr like '%Leak%'
        and alarm.IsResolved is null
        );
        
	SET ForeignObject = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n RIGHT JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID
        and n.NodeType In ('FireExtinguisher')  and n.NetworkID = alarm.NetworkID
		where n.Status = 'Active' 
		and FIND_IN_SET (n.NetworkID, NetworkList)
		and alarm.Descr like '%Foreign Object%'
        and alarm.IsResolved is null
        );
        
	SET Missing = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n RIGHT JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID
        and n.NodeType In ('FireExtinguisher')  and n.NetworkID = alarm.NetworkID
		where n.Status = 'Active' 
		and FIND_IN_SET (n.NetworkID, NetworkList)
		and alarm.Descr like '%Missing%'
        and alarm.IsResolved is null
        );
        
	SET Blockage = (Select count(distinct alarm.NodeID) As LowBattery from node_details As n RIGHT JOIN node_alarm_log As alarm 
		on n.NodeID = alarm.NodeID
        and n.NodeType In ('FireExtinguisher')  and n.NetworkID = alarm.NetworkID
		where n.Status = 'Active' 
		and FIND_IN_SET (n.NetworkID, NetworkList)
		and alarm.Descr like '%Blocked%'
        and alarm.IsResolved is null
        );
	
    SELECT Leaked as Leaked, ForeignObject as ForeignObject, Missing as Missing, Blockage as Blockage;
END