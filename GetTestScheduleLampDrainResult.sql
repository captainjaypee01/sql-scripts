CREATE DEFINER=`admin`@`%` PROCEDURE `GetTestScheduleLampDrainResult`(
TestTypeOne varchar(255),
TestTypeTwo varchar(255),
userIDVal varchar(255),
ScheduleVal varchar(255)
)
BEGIN

SELECT details.nodeName as nodename, ex.state_label as testresults, details.nodeType as teston, details.BuildingName As location, details.BuildingLevel As level, details.SectorName As sector, 
CONVERT_TZ(adnode.test_finished_at,'+00:00','+8:00') As test_finished_at,
CONVERT_TZ(adho.next_schedule_date,'+00:00','+8:00') As next_schedule_date
FROM smartnew.exem_test_schedule As adho 
JOIN smartnew.exem_test_result As adnode on adnode.schedule_no = adho.id and adnode.test_type = testType
JOIN (SELECT nodeName, max(updated_at) As max_updated_at FROM (select * from smartnew.exem_test_result where schedule = 1) As maxup group by nodeName) As lastOne
on adnode.nodeName =  lastOne.nodeName and adnode.updated_at = lastOne.max_updated_at
JOIN smartnew.ex_em_state ex on ex.state = adnode.adhoclamp_status and ex.test_type = testType
JOIN smartnew.node_details As details on details.NodeID = adnode.nodeID and details.NetworkID = adnode.networkID
where adnode.adhoclamp_status in ('f','8') and
adnode.schedule = 1 and adho.testType COLLATE utf8mb4_general_ci  in (TestTypeOne, TestTypeTwo)
and adnode.NetworkID COLLATE utf8mb4_general_ci in (SELECT NetworkID FROM smartnew.users_network where UserID COLLATE utf8mb4_general_ci  = userIDVal)
order by details.nodeName, adnode.test_finished_at desc;

END