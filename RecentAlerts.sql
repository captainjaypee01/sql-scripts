CREATE DEFINER=`root`@`localhost` PROCEDURE `RecentAlerts`(
userIDVal varchar(255),
nodeType varchar(255)
)
BEGIN

Declare Alert1 varchar(255);
Declare Alert2 varchar(255);
Declare Alert3 varchar(255);


create temporary table tblrecentalert
(
	id int auto_increment Primary key,
	alert varchar(500)
);
insert into tblrecentalert(alert)
Select Descr from node_details As n JOIN node_alarm_log As alarm 
on n.NodeID = alarm.NodeID and n.NetworkID = alarm.NetworkID and n.NodeType In (nodeType) 
where alarm.IsResolved is null and n.NetworkID in (SELECT NetworkID FROM users_network where UserID = userIDVal)
and n.Status = 'Active'
order by updated_at desc LIMIT 3;

SET Alert1 = ifnull((select alert from tblrecentalert where id = 1), 'No Alert');
SET Alert2 = ifnull((select alert from tblrecentalert where id = 2), 'No Alert');
SET Alert3 = ifnull((select alert from tblrecentalert where id = 3), 'No Alert');

Select  Alert1 As Alert1,  Alert2  As Alert2, Alert3  As Alert3;
Drop temporary table tblrecentalert;
END