CREATE DEFINER=`admin`@`%` PROCEDURE `GetTestScheduleLampDrainResult`(
TestTypeOne varchar(255),
TestTypeTwo varchar(255),
userIDVal varchar(255),
ScheduleVal varchar(255)
)
BEGIN

    
    SELECT distinct details.nodeName as nodename, ex.state_label as testresults, details.nodeType as teston, details.BuildingName As location, details.BuildingLevel As level, details.SectorName As sector, 
        CONVERT_TZ(adnode.test_finished_at,'+00:00','+8:00') As test_finished_at,
        CONVERT_TZ(adnode.next_schedule_date,'+00:00','+8:00') As next_schedule_date
    FROM exem_test_schedule As adho 
    JOIN exem_test_result As adnode on adnode.schedule_no = adho.id and adnode.test_type = testType
    JOIN (SELECT nodeName, max(created_at) As max_created_at FROM (select * from exem_test_result where schedule = 1 and test_type COLLATE utf8mb4_general_ci  in (TestTypeOne, TestTypeTwo)) As maxup group by nodeName) As lastOne
        on adnode.nodeName =  lastOne.nodeName and adnode.created_at = lastOne.max_created_at
    JOIN ex_em_state ex on ex.state = adnode.adhoclamp_status and ex.test_type = testType
    JOIN node_details As details on details.NodeID = adnode.nodeID and details.NetworkID = adnode.networkID
    where adnode.schedule = 1 and adho.testType COLLATE utf8mb4_general_ci  in (TestTypeOne, TestTypeTwo)
    and adnode.adhoclamp_status Not In ('5','6')
    and adho.schedule_status
    group by adnode.NodeID
    order by details.nodeName, adnode.test_finished_at desc;

END