CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_All_Fault`(
	userIDVal varchar(255),
	NodeTypeValOne varchar(255),
	NodeTypeValTwo varchar(255),
	NodeTypeValThree varchar(255)
)
BEGIN

	SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
	n.ServiceID, n.NodeType, alarm.Descr As FaultDesc, alarm.ResolvedDescription As ResolvedDesc,
    DATE_FORMAT(CONVERT_TZ(alarm.created_at, '+00:00', timezoneOffset), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
	alarm.created_at As CreatedDate, ifnull(DATE_FORMAT(CONVERT_TZ(alarm.ResolvedTime, '+00:00', timezoneOffset), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
	FROM node_details As n 
	JOIN node_alarm_log As alarm on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID
	where n.NodeType In (NodeTypeValOne,NodeTypeValTwo,NodeTypeValThree) and alarm.IsResolved is null 
	and n.Status = 'Active'
	and n.NetworkID in (SELECT n.NetworkID FROM users_network un where un.UserID = userIDVal)
	order by alarm.created_at desc
	LIMIT 500;

END