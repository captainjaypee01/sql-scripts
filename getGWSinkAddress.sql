CREATE DEFINER=`admin`@`%` PROCEDURE `getGWSinkAddress`(
NetworkIDVal varchar(255),
NodeIDVal varchar(255)
)
BEGIN

update gateways
set last_connected = now(), Status = 1, updated_at = now()
where NetworkID = NetworkIDVal
and SinkID = NodeIDVal;

END