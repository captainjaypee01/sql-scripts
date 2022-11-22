CREATE DEFINER=`admin`@`%` PROCEDURE `getGWSinkAddress`(
NetworkIDVal varchar(255),
NodeIDVal varchar(255)
)
BEGIN

update gateways
set last_connected = now(), Status = 1
where NetworkID = NetworkIDVal
and SinkID = (
SELECT distinct TargetNodeID FROM node_provisioning
where id in ( SELECT distinct provisioning_id FROM node_provisioning_detail where ProvisionNodeID = NodeIDVal
and NetworkID = NetworkIDVal) LIMIT 1);

END