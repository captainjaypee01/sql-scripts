CREATE DEFINER=`root`@`localhost` PROCEDURE `Calc_Temperature_Hotspot`(
	in NetworkList varchar(255),
	in NodeTypes varchar(255)
)
BEGIN

	SELECT n.BuildingName as Location, n.SectorName as Sector, Max(SensorValue02) maximum, Min(SensorValue02) minimum, AVG(SensorValue02) as average, updated_at, count(reading.NodeID) as total_node FROM node_latest_readings As reading 
	LEFT JOIN node_details As n on n.NodeID = reading.NodeID and n.NetworkID = reading.NetworkID and n.Status = 'Active'
	where n.Status = 'Active' and SensorValue02 is not null
    and FIND_IN_SET (n.NodeType, NodeTypes) and FIND_IN_SET (n.NetworkID, NetworkList) and reading.updated_at > UTC_TIMESTAMP() - interval 1 hour
	group by n.BuildingName,n.SectorName;
    
END