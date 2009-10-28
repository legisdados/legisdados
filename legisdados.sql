SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO"; -- Normally, you generate the next sequence number for the column by inserting either NULL or 0 into it. NO_AUTO_VALUE_ON_ZERO suppresses this behavior for 0 so that only NULL generates the next sequence number.

--
-- Database: `congressoaberto`;
--

-- We will use InnoDB engine, which allows for foreign keys. (That we might want to use.)
-- --------------------------------------------------------

use legisdados;

DROP TABLE IF EXISTS `br_votes`;
CREATE TABLE  `br_votes` (
    `matricula` int,
    `legis` int,
    `namelegis` varchar(255),
    `party` varchar(255),
    `state` varchar(2),
    `rc` varchar(20),
    `rcvoteid` int,
    PRIMARY KEY  (`matricula`,`rcvoteid`,`legis`)
    ) 
-- ENGINE=InnoDB 
DEFAULT CHARSET=utf8 COMMENT=''
-- PARTITION BY HASH(legis)
-- PARTITIONS 6
;
alter table br_votes add key matricula_index(matricula, legis);
alter table br_votes add key rcvoteid_index(rcvoteid);


DROP TABLE IF EXISTS `br_votes_leaders`;
CREATE TABLE  `br_votes_leaders` (
    `rcvoteid` int,
    `block` varchar(100),
    `party` varchar(10),
    `rc` varchar(10),
    PRIMARY KEY  (`rcvoteid`,`block`,`party`)	
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='
Content=leaders vote table
CreatedBy=
updatedBy=';


DROP TABLE IF EXISTS `br_rollcalls`;
CREATE TABLE  `br_rollcalls` (
    `rcvoteid` int default NULL,
    `session` varchar(9), 
    `rcdate` date,
    `rctime` datetime,
    `rcdescription` varchar(255),
    `legisyear` int,
    `rcyear` int,
    `billyear` int,
    `billno` varchar(255),
    `billtype` varchar(30),
    `legis` int,
    `rcfile` varchar(30),
    PRIMARY KEY  (`rcvoteid`,`legis`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

alter table br_rollcalls add key legis_index(legis);
alter table br_rollcalls add key date_index(rcdate);
alter table br_rollcalls add key rcvoteid_index(rcvoteid);


      
DROP TABLE IF EXISTS `br_billid`;
CREATE TABLE  `br_billid` (
    `billyear` int,
    `billno` int,
    `billtype` varchar(10),
    `billid` int,
    PRIMARY KEY  (`billtype`,`billyear`,`billno`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8
;


DROP TABLE IF EXISTS `br_matriculaid`;
CREATE TABLE  `br_matriculaid` (	
    `matricula` int,
    `legis` int,
    `id` int,
    PRIMARY KEY  (`matricula`,`legis`,`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8
;



DROP TABLE IF EXISTS `br_tramit`;
CREATE TABLE  `br_tramit` (
    `billid` int,
    `id` int,
    `date` date,
    `event` varchar(1000),
    PRIMARY KEY  (`billid`,`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8
;



DROP TABLE IF EXISTS `br_bills`;
CREATE TABLE  `br_bills` (
    -- `session` varchar(9), 
    `billyear` int,
    `billauthor` varchar(100),
    `billauthorid` int,
    `billdate` date,
    `billno` int,
    `billid` int,
    `propno` int,
    `billtype` varchar(10),
    --    `legis` int,
    `aprec` varchar(255),
    `tramit` varchar(255),
    `status` varchar(255),    
    `ementa` varchar(1000),
    `ementashort` varchar(1000),
    `indexa` varchar(1000),
    `lastaction` varchar(1000),
    `lastactiondate` date,
    PRIMARY KEY  (`billtype`,`billyear`,`billno`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8
;
