CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_Outstanding_Fault`(
	userIDVal varchar(255),
	timezoneOffset varchar(255),
	NodeTypeValOne varchar(255),
	NodeTypeValTwo varchar(255),
	NodeTypeValThree varchar(255)
)
BEGIN

	SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
	n.ServiceID, n.NodeType, alarm.Descr As FaultDesc, alarm.ResolvedDescription As ResolvedDesc,
    DATE_FORMAT(CONVERT_TZ(alarm.created_at, '+00:00', timezoneOffset), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
    ifnull(DATE_FORMAT(CONVERT_TZ(alarm.ResolvedTime, '+00:00', timezoneOffset), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
	FROM node_alarm_log As alarm 
    INNER JOIN (SELECT nodeid, max(created_at) as createdDate FROM node_alarm_log GROUP BY nodeid) alarm2
		on alarm.NodeID = alarm2.NodeID and alarm.created_at = alarm2.createdDate
	JOIN node_details As n on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID
	where n.NodeType In (NodeTypeValOne,NodeTypeValTwo,NodeTypeValThree) and alarm.IsResolved is null 
	and n.Status = 'Active'
	and alarm.NetworkID in (SELECT NetworkID FROM users_network un where un.UserID = userIDVal)
    group by alarm.NodeID
	order by alarm.created_at desc;


END