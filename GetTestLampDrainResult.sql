CREATE DEFINER=`root`@`localhost` PROCEDURE `GetTestLampDrainResult`(
TestTypeOne varchar(255),
TestTypeTwo varchar(255),
userIDVal varchar(255),
ScheduleVal varchar(255)
)
BEGIN

    SELECT passed, failed, schedule_name, adho.test_finished_at test_finished_at,
        adho.test_started_at test_started_at,  adho.testType As testType, nodeType as teston, building As location
        FROM exem_test_schedule As adho
        where adho.testType COLLATE utf8mb4_general_ci  in (TestTypeOne, TestTypeTwo);


END