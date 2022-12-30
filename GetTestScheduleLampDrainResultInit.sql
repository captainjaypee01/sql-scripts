CREATE DEFINER=`admin`@`%` PROCEDURE `GetTestScheduleLampDrainResultInit`(
TestTypeOne varchar(255),
TestTypeTwo varchar(255),
userIDVal varchar(255),
ScheduleVal varchar(255)
)
BEGIN

    SELECT distinct details.nodeName as nodename, ex.state_label as testresults, details.nodeType as teston, details.BuildingName As location, 
		ex2.state_label as last_testresults, details.BuildingLevel As level, details.SectorName As sector, 
        CONVERT_TZ(adnode.test_finished_at,'+00:00','+8:00') As test_finished_at,
        CONVERT_TZ(adnode.last_test_finished_at,'+00:00','+8:00') As last_test_finished_at,
        CONVERT_TZ(IFNULL(adnode.next_schedule_date, adho.scheduleValue),'+00:00','+08:00') As next_schedule_date, 
        adhoclamp_status, last_adhoclamp_status
    FROM exem_test_schedule As adho 
    JOIN exem_test_result As adnode on adnode.schedule_no = adho.id and adnode.test_type = testType
    JOIN (SELECT nodeName, max(created_at) As max_created_at FROM (select * from exem_test_result where schedule = 1 and test_type COLLATE utf8mb4_general_ci  in (TestTypeOne, TestTypeTwo)) As maxup group by nodeName order by created_at desc) As lastOne
        on adnode.nodeName =  lastOne.nodeName and adnode.created_at = lastOne.max_created_at
    left JOIN ex_em_state ex on ex.state = adnode.adhoclamp_status and ex.test_type = testType
    right JOIN ex_em_state ex2 on ex2.state = adnode.last_adhoclamp_status and ex2.test_type = testType
    JOIN node_details As details on details.NodeID = adnode.nodeID and details.NetworkID = adnode.networkID
    where adnode.schedule = 1 and adho.testType COLLATE utf8mb4_general_ci  in (TestTypeOne, TestTypeTwo)
    and adnode.adhoclamp_status Not In ('5','6')
    group by adnode.NodeID
    order by adnode.adhoclamp_status, details.nodeName, adnode.test_finished_at desc;

END