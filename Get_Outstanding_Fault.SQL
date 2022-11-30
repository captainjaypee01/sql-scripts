CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_Outstanding_Fault`(
	userIDVal varchar(255),
	timezoneOffset varchar(255),
	NodeTypeValOne varchar(255),
	NodeTypeValTwo varchar(255),
	NodeTypeValThree varchar(255)
)
BEGIN

	SELECT * FROM ((SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
	n.ServiceID, n.NodeType, alarm.Descr As FaultDesc, alarm.ResolvedDescription As ResolvedDesc,
    DATE_FORMAT(CONVERT_TZ(alarm.created_at, '+00:00', timezoneOffset), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
    ifnull(DATE_FORMAT(CONVERT_TZ(alarm.ResolvedTime, '+00:00', timezoneOffset), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
	FROM node_alarm_log As alarm 
    INNER JOIN (SELECT NodeID, NetworkID, max(createdDate) from (SELECT a.NodeID, a.NetworkID, a.Descr, a.created_at as createdDate, a.IsResolved FROM node_alarm_log As a 
	GROUP BY a.NodeID, a.NetworkID, a.Descr, a.IsResolved
	having a.Descr = 'Node is Offline'
	and a.IsResolved is null ) alarm3 ) alarm2	on alarm2.NodeID = alarm.NodeID and alarm2.createdDate = alarm.created_at
    and alarm2.NetworkID = alarm.NetworkID
	JOIN node_details As n on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID
	where n.NodeType In (NodeTypeValOne,NodeTypeValTwo,NodeTypeValThree) and alarm.IsResolved is null 
	and n.Status = 'Active'
	and alarm.NetworkID in (SELECT NetworkID FROM users_network un where un.UserID = userIDVal)
    group by alarm.NodeID ) 
    UNION (SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
	n.ServiceID, n.NodeType, alarm.Descr As FaultDesc, alarm.ResolvedDescription As ResolvedDesc,
    DATE_FORMAT(CONVERT_TZ(alarm.created_at, '+00:00', timezoneOffset), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
    ifnull(DATE_FORMAT(CONVERT_TZ(alarm.ResolvedTime, '+00:00', timezoneOffset), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
	FROM node_alarm_log As alarm 
    INNER JOIN (SELECT NodeID, NetworkID, max(createdDate) from (SELECT a.NodeID, a.NetworkID, a.Descr, a.created_at as createdDate, a.IsResolved FROM node_alarm_log As a 
	GROUP BY a.NodeID, a.NetworkID, a.Descr, a.IsResolved
	having a.Descr = 'Low Battery'
	and a.IsResolved is null ) alarm3 ) alarm2	on alarm2.NodeID = alarm.NodeID and alarm2.createdDate = alarm.created_at
    and alarm2.NetworkID = alarm.NetworkID
	JOIN node_details As n on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID
	where n.NodeType In (NodeTypeValOne,NodeTypeValTwo,NodeTypeValThree) and alarm.IsResolved is null 
	and n.Status = 'Active'
	and alarm.NetworkID in (SELECT NetworkID FROM users_network un where un.UserID = userIDVal)
    group by alarm.NodeID ) 
    UNION (SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
	n.ServiceID, n.NodeType, alarm.Descr As FaultDesc, alarm.ResolvedDescription As ResolvedDesc,
    DATE_FORMAT(CONVERT_TZ(alarm.created_at, '+00:00', timezoneOffset), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
    ifnull(DATE_FORMAT(CONVERT_TZ(alarm.ResolvedTime, '+00:00', timezoneOffset), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
	FROM node_alarm_log As alarm 
    INNER JOIN (SELECT NodeID, NetworkID, max(createdDate) from (SELECT a.NodeID, a.NetworkID, a.Descr, a.created_at as createdDate, a.IsResolved FROM node_alarm_log As a 
	GROUP BY a.NodeID, a.NetworkID, a.Descr, a.IsResolved
	having a.Descr Not In ('Node is Offline', 'Low Battery')
	and a.IsResolved is null ) alarm3 ) alarm2	on alarm2.NodeID = alarm.NodeID and alarm2.createdDate = alarm.created_at
    and alarm2.NetworkID = alarm.NetworkID
	JOIN node_details As n on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID
	where n.NodeType In (NodeTypeValOne,NodeTypeValTwo,NodeTypeValThree) and alarm.IsResolved is null 
	and n.Status = 'Active'
	and alarm.NetworkID in (SELECT NetworkID FROM users_network un where un.UserID = userIDVal)
    group by alarm.NodeID )) As c order by ServiceID;




END