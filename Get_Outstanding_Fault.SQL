CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_Outstanding_Fault`(
    in NetworkList varchar(255),
	timezoneOffset varchar(255),
    in NodeTypes varchar(255),
    initial bool,
    in BuildingList varchar(255),
    in ConfigList varchar(255)
)
BEGIN
	IF BuildingList IS NULL AND ConfigList IS NULL THEN
		IF initial
		THEN
			(SELECT * FROM (
					(
						SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
							n.ServiceID, n.NodeType, 
							al.Descr As FaultDesc,
							al.ResolvedDescription As ResolvedDesc,
							DATE_FORMAT(CONVERT_TZ(al.created_at, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
							ifnull(DATE_FORMAT(CONVERT_TZ(al.ResolvedTime, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
						FROM node_alarm_log As al 
						LEFT JOIN node_details As n on n.NodeID = al.NodeID and n.NetworkID = al.NetworkID
						INNER JOIN (SELECT nodeid, max(created_at) as createdDate FROM node_alarm_log GROUP BY nodeid) alarm2
								on al.NodeID = alarm2.nodeid and al.created_at = alarm2.createdDate
						where FIND_IN_SET (n.NodeType, NodeTypes)
						and al.IsResolved is null 
						and al.Descr not in ('Low Battery', 'Node is Offline')
						and n.Status = 'Active'
						and FIND_IN_SET (al.NetworkID, NetworkList)
						
						group by al.NodeID
						order by al.id desc
					)
				UNION
					(
						SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
							n.ServiceID, n.NodeType, 
							al.Descr As FaultDesc,
							al.Descr As ResolvedDesc,
							#al.Descr as LowBattery,
							DATE_FORMAT(CONVERT_TZ(al.created_at, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
							ifnull(DATE_FORMAT(CONVERT_TZ(al.ResolvedTime, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
						FROM node_alarm_log As al 
						LEFT JOIN node_details As n on n.NodeID = al.NodeID and n.NetworkID = al.NetworkID
						where FIND_IN_SET (n.NodeType, NodeTypes)
						and FIND_IN_SET (al.NetworkID, NetworkList)
						and n.Status = 'Active'
						and al.Descr = 'Low Battery'
						and al.IsResolved is null 
						group by al.NodeID
						order by al.id desc
					)
				UNION
					(
						SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
							n.ServiceID, n.NodeType, 
							al.Descr As FaultDesc,
							al.Descr As ResolvedDesc,
							#al.Descr as LowBattery,
							DATE_FORMAT(CONVERT_TZ(al.created_at, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
							ifnull(DATE_FORMAT(CONVERT_TZ(al.ResolvedTime, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
						FROM node_alarm_log As al 
						#INNER JOIN (SELECT nodeid, max(created_at) as createdDate FROM node_alarm_log GROUP BY nodeid) alarm2
						#		on al.NodeID = alarm2.nodeid and al.created_at = alarm2.createdDate
						LEFT JOIN node_details As n on n.NodeID = al.NodeID and n.NetworkID = al.NetworkID
						where FIND_IN_SET (n.NodeType, NodeTypes)
						and FIND_IN_SET (al.NetworkID, NetworkList)
						and n.Status = 'Active'
						and al.Descr = 'Node is Offline'
						and al.IsResolved is null 
						group by al.NodeID
						order by al.id desc
					)
				) 
				as combined
				order by combined.NodeName asc
				limit 50
			);
		ELSE
			(SELECT * FROM (
					(
						SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
							n.ServiceID, n.NodeType, 
							al.Descr As FaultDesc,
							al.ResolvedDescription As ResolvedDesc,
							#null as LowBattery,
							DATE_FORMAT(CONVERT_TZ(al.created_at, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
							ifnull(DATE_FORMAT(CONVERT_TZ(al.ResolvedTime, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
						FROM node_alarm_log As al 
						LEFT JOIN node_details As n on n.NodeID = al.NodeID and n.NetworkID = al.NetworkID
						INNER JOIN (SELECT nodeid, max(created_at) as createdDate FROM node_alarm_log GROUP BY nodeid) alarm2
								on al.NodeID = alarm2.nodeid and al.created_at = alarm2.createdDate
						where FIND_IN_SET (n.NodeType, NodeTypes)
						and al.IsResolved is null 
						and al.Descr not in ('Low Battery', 'Node is Offline')
						and n.Status = 'Active'
						and FIND_IN_SET (al.NetworkID, NetworkList)
						
						group by al.NodeID
						order by al.id desc
					)
				UNION
					(
						SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
							n.ServiceID, n.NodeType, 
							al.Descr As FaultDesc,
							al.Descr As ResolvedDesc,
							#al.Descr as LowBattery,
							DATE_FORMAT(CONVERT_TZ(al.created_at, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
							ifnull(DATE_FORMAT(CONVERT_TZ(al.ResolvedTime, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
						FROM node_alarm_log As al 
						LEFT JOIN node_details As n on n.NodeID = al.NodeID and n.NetworkID = al.NetworkID
						where FIND_IN_SET (n.NodeType, NodeTypes)
						and FIND_IN_SET (al.NetworkID, NetworkList)
						and n.Status = 'Active'
						and al.Descr = 'Low Battery'
						and al.IsResolved is null 
						group by al.NodeID
						order by al.id desc
					)
				UNION
					(
						SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
							n.ServiceID, n.NodeType, 
							al.Descr As FaultDesc,
							al.Descr As ResolvedDesc,
							#al.Descr as LowBattery,
							DATE_FORMAT(CONVERT_TZ(al.created_at, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
							ifnull(DATE_FORMAT(CONVERT_TZ(al.ResolvedTime, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
						FROM node_alarm_log As al 
						#INNER JOIN (SELECT nodeid, max(created_at) as createdDate FROM node_alarm_log GROUP BY nodeid) alarm2
						#		on al.NodeID = alarm2.nodeid and al.created_at = alarm2.createdDate
						LEFT JOIN node_details As n on n.NodeID = al.NodeID and n.NetworkID = al.NetworkID
						where FIND_IN_SET (n.NodeType, NodeTypes)
						and FIND_IN_SET (al.NetworkID, NetworkList)
						and n.Status = 'Active'
						and al.Descr = 'Node is Offline'
						and al.IsResolved is null 
						group by al.NodeID
						order by al.id desc
					)
				) 
				as combined
				order by combined.NodeName asc
			);
		END IF;
	ELSE
		
		IF initial
		THEN
			(SELECT * FROM (
					(
						SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
							n.ServiceID, n.NodeType, 
							al.Descr As FaultDesc,
							al.ResolvedDescription As ResolvedDesc,
							DATE_FORMAT(CONVERT_TZ(al.created_at, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
							ifnull(DATE_FORMAT(CONVERT_TZ(al.ResolvedTime, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
						FROM node_alarm_log As al 
						LEFT JOIN node_details As n on n.NodeID = al.NodeID and n.NetworkID = al.NetworkID
						INNER JOIN (SELECT nodeid, max(created_at) as createdDate FROM node_alarm_log GROUP BY nodeid) alarm2
								on al.NodeID = alarm2.nodeid and al.created_at = alarm2.createdDate
						where FIND_IN_SET (n.NodeType, NodeTypes)
						and FIND_IN_SET (n.BuildingName, BuildingList)
						and FIND_IN_SET (n.Config, ConfigList)
						and al.IsResolved is null 
						and al.Descr not in ('Low Battery', 'Node is Offline')
						and n.Status = 'Active'
						and FIND_IN_SET (al.NetworkID, NetworkList)
						
						group by al.NodeID
						order by al.id desc
					)
				UNION
					(
						SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
							n.ServiceID, n.NodeType, 
							al.Descr As FaultDesc,
							al.Descr As ResolvedDesc,
							#al.Descr as LowBattery,
							DATE_FORMAT(CONVERT_TZ(al.created_at, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
							ifnull(DATE_FORMAT(CONVERT_TZ(al.ResolvedTime, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
						FROM node_alarm_log As al 
						LEFT JOIN node_details As n on n.NodeID = al.NodeID and n.NetworkID = al.NetworkID
						where FIND_IN_SET (n.NodeType, NodeTypes)
						and FIND_IN_SET (al.NetworkID, NetworkList)
						and FIND_IN_SET (n.BuildingName, BuildingList)
						and FIND_IN_SET (n.Config, ConfigList)
						and n.Status = 'Active'
						and al.Descr = 'Low Battery'
						and al.IsResolved is null 
						group by al.NodeID
						order by al.id desc
					)
				UNION
					(
						SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
							n.ServiceID, n.NodeType, 
							al.Descr As FaultDesc,
							al.Descr As ResolvedDesc,
							#al.Descr as LowBattery,
							DATE_FORMAT(CONVERT_TZ(al.created_at, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
							ifnull(DATE_FORMAT(CONVERT_TZ(al.ResolvedTime, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
						FROM node_alarm_log As al 
						#INNER JOIN (SELECT nodeid, max(created_at) as createdDate FROM node_alarm_log GROUP BY nodeid) alarm2
						#		on al.NodeID = alarm2.nodeid and al.created_at = alarm2.createdDate
						LEFT JOIN node_details As n on n.NodeID = al.NodeID and n.NetworkID = al.NetworkID
						where FIND_IN_SET (n.NodeType, NodeTypes)
						and FIND_IN_SET (al.NetworkID, NetworkList)
						and FIND_IN_SET (n.BuildingName, BuildingList)
						and FIND_IN_SET (n.Config, ConfigList)
						and n.Status = 'Active'
						and al.Descr = 'Node is Offline'
						and al.IsResolved is null 
						group by al.NodeID
						order by al.id desc
					)
				) 
				as combined
				order by combined.NodeName asc
				limit 50
			);
		ELSE
			(SELECT * FROM (
					(
						SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
							n.ServiceID, n.NodeType, 
							al.Descr As FaultDesc,
							al.ResolvedDescription As ResolvedDesc,
							#null as LowBattery,
							DATE_FORMAT(CONVERT_TZ(al.created_at, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
							ifnull(DATE_FORMAT(CONVERT_TZ(al.ResolvedTime, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
						FROM node_alarm_log As al 
						LEFT JOIN node_details As n on n.NodeID = al.NodeID and n.NetworkID = al.NetworkID
						INNER JOIN (SELECT nodeid, max(created_at) as createdDate FROM node_alarm_log GROUP BY nodeid) alarm2
								on al.NodeID = alarm2.nodeid and al.created_at = alarm2.createdDate
						where FIND_IN_SET (n.NodeType, NodeTypes)
						and FIND_IN_SET (n.BuildingName, BuildingList)
						and FIND_IN_SET (n.Config, ConfigList)
						and al.IsResolved is null 
						and al.Descr not in ('Low Battery', 'Node is Offline')
						and n.Status = 'Active'
						and FIND_IN_SET (al.NetworkID, NetworkList)
						
						group by al.NodeID
						order by al.id desc
					)
				UNION
					(
						SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
							n.ServiceID, n.NodeType, 
							al.Descr As FaultDesc,
							al.Descr As ResolvedDesc,
							#al.Descr as LowBattery,
							DATE_FORMAT(CONVERT_TZ(al.created_at, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
							ifnull(DATE_FORMAT(CONVERT_TZ(al.ResolvedTime, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
						FROM node_alarm_log As al 
						LEFT JOIN node_details As n on n.NodeID = al.NodeID and n.NetworkID = al.NetworkID
						where FIND_IN_SET (n.NodeType, NodeTypes)
						and FIND_IN_SET (al.NetworkID, NetworkList)
						and FIND_IN_SET (n.BuildingName, BuildingList)
						and FIND_IN_SET (n.Config, ConfigList)
						and n.Status = 'Active'
						and al.Descr = 'Low Battery'
						and al.IsResolved is null 
						group by al.NodeID
						order by al.id desc
					)
				UNION
					(
						SELECT distinct n.NodeName, n.NodeID, n.BuildingName As Building, n.BuildingLevel As Level, n.SectorName As Sector,
							n.ServiceID, n.NodeType, 
							al.Descr As FaultDesc,
							al.Descr As ResolvedDesc,
							#al.Descr as LowBattery,
							DATE_FORMAT(CONVERT_TZ(al.created_at, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s') AS CreatedDate,
							ifnull(DATE_FORMAT(CONVERT_TZ(al.ResolvedTime, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s'),'-') As ResolvedDate
						FROM node_alarm_log As al 
						#INNER JOIN (SELECT nodeid, max(created_at) as createdDate FROM node_alarm_log GROUP BY nodeid) alarm2
						#		on al.NodeID = alarm2.nodeid and al.created_at = alarm2.createdDate
						LEFT JOIN node_details As n on n.NodeID = al.NodeID and n.NetworkID = al.NetworkID
						where FIND_IN_SET (n.NodeType, NodeTypes)
						and FIND_IN_SET (al.NetworkID, NetworkList)
						and FIND_IN_SET (n.BuildingName, BuildingList)
						and FIND_IN_SET (n.Config, ConfigList)
						and n.Status = 'Active'
						and al.Descr = 'Node is Offline'
						and al.IsResolved is null 
						group by al.NodeID
						order by al.id desc
					)
				) 
				as combined
				order by combined.NodeName asc
			);
		END IF;
    END IF;

END