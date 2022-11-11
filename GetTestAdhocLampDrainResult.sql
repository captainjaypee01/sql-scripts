CREATE DEFINER=`admin`@`%` PROCEDURE `GetTestAdhocLampDrainResult`(
TestTypeOne varchar(255),
TestTypeTwo varchar(255),
userIDVal varchar(255),
ScheduleVal varchar(255)
)
BEGIN

    SELECT details.nodeName as nodename, ex.state_label as testresults, details.nodeType as teston, details.BuildingName As location, details.BuildingLevel As level, details.SectorName As sector, 
        CONVERT_TZ(adnode.test_finished_at,'+00:00','+8:00') As test_finished_at, adnode.updated_at
        FROM exem_test_schedule As adho 
        JOIN exem_test_result As adnode on adnode.schedule_no = adho.id and adnode.test_type = testType
        JOIN ex_em_state ex on ex.state = adnode.adhoclamp_status and ex.test_type = testType
        JOIN node_details As details on details.NodeID = adnode.nodeID and details.NetworkID = adnode.networkID
        where adho.schedule = 0 and adho.testType COLLATE utf8mb4_general_ci  in (TestTypeOne, TestTypeTwo)
        and adnode.NetworkID COLLATE utf8mb4_general_ci in (SELECT NetworkID FROM users_network where UserID COLLATE utf8mb4_general_ci  = userIDVal)
        and adho.id = (select distinct id from exem_test_schedule where schedule = 0 order by id desc limit 1)
        order by details.nodeName, adnode.test_finished_at desc;

END