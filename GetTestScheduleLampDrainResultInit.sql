CREATE DEFINER=`root`@`localhost` PROCEDURE `GetTestScheduleLampDrainResultInit`(
    in NetworkList varchar(255),
    in TestTypeList varchar(255)
)
BEGIN

    SELECT distinct details.nodeName as nodename, ex.state_label as testresults, details.nodeType as teston, details.BuildingName As location, 
		ex2.state_label as last_testresults, details.BuildingLevel As level, details.SectorName As sector, 
        CONVERT_TZ(adnode.test_finished_at,'+00:00','+8:00') As test_finished_at,
        CONVERT_TZ(adnode.last_test_finished_at,'+00:00','+8:00') As last_test_finished_at,
        CONVERT_TZ(IFNULL(adnode.next_schedule_date, adho.scheduleValue),'+00:00','+08:00') As next_schedule_date, 
        adhoclamp_status, last_adhoclamp_status, adho.repeat, 
        (CASE WHEN adnode.created_at < UTC_TIMESTAMP() - interval 20 minute and adnode.is_schedule_responded = 0 and adnode.schedule_status = 1 THEN 1 ELSE 0 END) as node_not_responded  
    FROM exem_test_schedule As adho 
    JOIN exem_test_result As adnode on adnode.schedule_no = adho.id and adnode.test_type = testType
    JOIN (SELECT nodeID, max(created_at) As max_created_at FROM (select * from exem_test_result where schedule = 1 and FIND_IN_SET (test_type, TestTypeList)) As maxup group by nodeID order by created_at desc) As lastOne
        on adnode.nodeID =  lastOne.nodeID and adnode.created_at = lastOne.max_created_at
    left JOIN ex_em_state ex on ex.state = adnode.adhoclamp_status and ex.test_type = testType
    right JOIN ex_em_state ex2 on ex2.state = adnode.last_adhoclamp_status and ex2.test_type = testType
    JOIN node_details As details on details.NodeID = adnode.nodeID and details.NetworkID = adnode.networkID
    where FIND_IN_SET(adnode.networkID, NetworkList)
    and adnode.schedule = 1 and FIND_IN_SET (adho.testType, TestTypeList)
    and adnode.adhoclamp_status Not In ('6')
    and details.Status = 'Active'
    group by adnode.NodeID
    order by adnode.adhoclamp_status, details.nodeName, adnode.test_finished_at desc;
    
END