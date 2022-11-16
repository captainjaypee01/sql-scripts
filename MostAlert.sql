CREATE DEFINER=`root`@`localhost` PROCEDURE `MostAlert`(
	userIDVal varchar(255),
	nodeType VARCHAR(255)
)
BEGIN
	Declare MostAlert varchar(255);
    
	SET MostAlert = ifnull(
		(SELECT Descr FROM node_alarm_log as alarm
		LEFT JOIN node_details as n on n.NodeID = alarm.NodeID and n.NetworkID and n.NodeType = nodeType
		where alarm.IsResolved is null 
		and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
		and n.Status = 'Active'
		group by Descr
		order by count(Descr) desc
		limit 1),
    'No Alert');
	
    SELECT MostAlert as MostAlert;
END