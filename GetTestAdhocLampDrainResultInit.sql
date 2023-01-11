CREATE DEFINER=`root`@`localhost` PROCEDURE `GetTestAdhocLampDrainResultInit`(
    in NetworkList varchar(255),
    in TestTypeList varchar(255)
)
BEGIN

	SELECT 
		details.nodeName as nodename, ex.state_label as testresults, details.nodeType as teston, 
        details.BuildingName As location, details.BuildingLevel As level, details.SectorName As sector, 
		CONVERT_TZ(adnode.test_finished_at,'+00:00','+8:00') As test_finished_at, adnode.updated_at,
		(CASE WHEN adnode.created_at < UTC_TIMESTAMP() - interval 20 minute and adnode.is_schedule_responded = 0 THEN 1 ELSE 0 END) as node_not_responded  
	FROM exem_test_schedule As adho 
	JOIN exem_test_result As adnode on adnode.schedule_no = adho.id and adnode.test_type = testType
	JOIN ex_em_state ex on ex.state = adnode.adhoclamp_status and ex.test_type = testType
	JOIN node_details As details on details.NodeID = adnode.nodeID and details.NetworkID = adnode.networkID
	where adho.schedule = 0 and FIND_IN_SET (adho.testType, TestTypeList)
	and FIND_IN_SET(adnode.networkID, NetworkList)
	and adho.id = (select distinct id from exem_test_schedule where schedule = 0 order by id desc limit 1)
	order by details.nodeName, adnode.test_finished_at desc;

END