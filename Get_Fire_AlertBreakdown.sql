CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_Fire_AlertBreakdown`(
userIDVal varchar(255)
)
BEGIN

	SELECT CAST(SUM(Leak1 = 1 or Leak2 = 1) AS SIGNED ) as Leaked, CAST(sum(ForeignObj) AS SIGNED) AS ForeignObject, CAST(sum(Missing) AS SIGNED) AS Missing, CAST(sum(Blockage) AS SIGNED) As Blockage
	from node_fx_logic WHERE NetworkID in (SELECT un.NetworkID FROM users_network un where un.UserID COLLATE utf8mb4_general_ci = userIDVal);

END