CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_All_Fault`(
NodeTypeValOne varchar(255),
NodeTypeValTwo varchar(255),
NodeTypeValThree varchar(255),
userIDVal varchar(255)
)
BEGIN

SELECT distinct n.NodeName As NodeName, n.NodeID As NodeID, n.BuildingName As Building,
n.BuildingLevel As Level, n.SectorName As Sector,
n.ServiceID As ServiceID, n.NodeType As NodeType, alarm.Descr As FaultDesc, 
alarm.ResolvedDescription As ResolvedDesc, 
alarm.created_at As CreatedDate, 
ifnull(alarm.ResolvedTime, '-') As ResolvedDate
FROM node_details As n 
JOIN node_alarm_log As alarm on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID
and n.NodeType In (NodeTypeValOne,NodeTypeValTwo,NodeTypeValThree) 
and n.NetworkID In (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
where n.NodeType In (NodeTypeValOne,NodeTypeValTwo,NodeTypeValThree)
and alarm.IsResolved is null 
and n.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
and alarm.NetworkID in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci = userIDVal)
LIMIT 500;


END