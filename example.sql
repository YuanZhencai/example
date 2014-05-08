
SELECT
    org.MATERIAL_DESC,
    pd.DOC_DATE as PUR_DOC_DATE,
    ed.DOC_DATE as ENT_DOC_DATE,
    pd.DOC_TYPE,
    pd.PURCHASE_DOC_NO,
    vd.VENDOR_ACCOUNT,
    vd.VENDOR_NAME,
    pd.STATISTICS_GROUP_ID,
    pdi.LGORT_GI,
    pdi.CHARG_GI,
    pdi.PLANNED_WEIGHT,
    pdi.CAR_NO,
    ed.ENTRANCE_DOC_NO,
    ed.VEHICLE_NO,
    ed.DRIVER_NAME,
    ed.DRIVER_TELEPHONE_NO,
    edi.SUM_WEIGHT_QUANTITY,
    edi.STORAGE_LOC_NO,
    edi.BATCH_NO,
    pdi.SAP_DOC_NO,
    pdi.BILLING_RULE,
    pdi.Id as P_ID,
    edi.ID as E_ID,
    pd.PUR_ID,
    pdi.MERGED_BILLING_IND

    
FROM
    PURCHASE_DOC_ITEM pdi
LEFT JOIN
    PURCHASE_ENTRANCE_DOC ped
ON
    pdi.ID = ped.PUR_ID
LEFT JOIN
(
select edi.*,weight_times
,substr(w_tmp.STORAGE_LOC_NO,1,length(w_tmp.STORAGE_LOC_NO)-1) STORAGE_LOC_NO
,substr(w_tmp.BATCH_NO,1,length(w_tmp.BATCH_NO)-1) BATCH_NO
,substr(w_tmp.STORAGE_BATCH,1,length(w_tmp.STORAGE_BATCH)-1) STORAGE_BATCH
,substr(w_tmp.WEIGHT_BRIDGE_DOC_NO,1,length(w_tmp.WEIGHT_BRIDGE_DOC_NO)-1) WEIGHT_BRIDGE_DOC_NO
,substr(w_tmp.WEIGHT_QUANTITY,1,length(w_tmp.WEIGHT_QUANTITY)-1) WEIGHT_QUANTITY
,SUM_WEIGHT_QUANTITY
from ENTRANCE_DOC_ITEM edi left outer join
(select wbd.ent_item_id ,count(ent_item_id) weight_times
		,varchar(replace(replace(xml2clob(xmlagg(xmlelement(NAME a,STORAGE_LOC_NO ||';'))),'<A>',''),'</A>',''),1000) 
STORAGE_LOC_NO
		,varchar(replace(replace(xml2clob(xmlagg(xmlelement(NAME a,BATCH_NO||';'))),'<A>',''),'</A>',''),1000) BATCH_NO
		,varchar(replace(replace(xml2clob(xmlagg(xmlelement(NAME a,STORAGE_LOC_NO || '_' || 
BATCH_NO||';'))),'<A>',''),'</A>',''),1000) STORAGE_BATCH
		,varchar(replace(replace(xml2clob(xmlagg(xmlelement(NAME a,WEIGHT_BRIDGE_DOC_NO||';'))),'<A>',''),'</A>',''),1000) 
WEIGHT_BRIDGE_DOC_NO
		,varchar(replace(replace(xml2clob(xmlagg(xmlelement(NAME a,varchar_format(FIRST_WEIGHT - SECOND_WEIGHT,'999999999.99') 
||';'))),'<A>',''),'</A>',''),1000) WEIGHT_QUANTITY
		,sum(FIRST_WEIGHT - SECOND_WEIGHT) SUM_WEIGHT_QUANTITY
	from WEIGHT_BRIDGE_DOC wbd
	group by wbd.ent_item_id) as w_tmp
on edi.ID = w_tmp.ent_item_id
)
    as edi
ON
    edi.ID = ped.ENT_ID
AND edi.DEFUNCT_IND=0
LEFT JOIN
    ENTRANCE_DOC ed
ON
    edi.ENT_ID = ed.ID
AND ed.DEFUNCT_IND=0
LEFT JOIN
    ORG_MATERIAL org
ON
    pdi.ORG_ID = org.ID
LEFT JOIN
    PURCHASE_DOC pd
ON
    pdi.PUR_ID = pd.ID
LEFT JOIN
    VENDOR vd
ON
    pd.VEN_ID = vd.ID

where pdi.DEFUNCT_IND=0
AND org.DEFUNCT_IND=0
AND pd.DEFUNCT_IND=0
AND vd.DEFUNCT_IND=0
AND ( pd.DOC_TYPE = 2 OR  pd.DOC_TYPE = 5);





SELECT
    v.MATERIAL_DESC ,
    v.PUR_DOC_DATE ,
    v.ENT_DOC_DATE ,
    v.DOC_TYPE ,
    v.PURCHASE_DOC_NO ,
    v.VENDOR_ACCOUNT ,
    v.VENDOR_NAME ,
    v.STATISTICS_GROUP_ID ,
    v.LGORT_GI ,
    v.CHARG_GI ,
    v.PLANNED_WEIGHT ,
    v.CAR_NO ,
    v.ENTRANCE_DOC_NO ,
    v.VEHICLE_NO ,
    v.DRIVER_NAME ,
    v.DRIVER_TELEPHONE_NO ,
    v.SUM_WEIGHT_QUANTITY ,
    v.STORAGE_LOC_NO ,
    v.BATCH_NO ,
    v.SAP_DOC_NO ,
    v.BILLING_RULE,
    v.P_ID,
    v.E_ID ,
    sr.* ,
    ir.* ,
    rr.* ,
    cr.*
FROM
    VIEW_WEIGHT_MERGE_INF v
LEFT JOIN
    (//dispatch
        SELECT
            FOREIGN_MATERIAL,
            MOISTURE,
            WET_GLUTEN,
            is_wool_grain,
            IMPERFECT_KERNAL,
            PUR_ID
        FROM
            ENTRANCE_INDICATOR_RESULTS eir
        WHERE
            CHECK_NUM = 10 ) AS sr
ON
    v.P_ID = sr.PUR_ID
LEFT JOIN
    (//initial review
        SELECT
            FOREIGN_MATERIAL,
            MOISTURE,
            WET_GLUTEN,
            is_wool_grain,
            IMPERFECT_KERNAL,
            EN_ID
        FROM
            ENTRANCE_INDICATOR_RESULTS eir
        WHERE
            CHECK_NUM = 1 ) AS ir
ON
    v.E_ID = ir.EN_ID
LEFT JOIN
    (//recheck
        SELECT
            FOREIGN_MATERIAL,
            MOISTURE,
            WET_GLUTEN,
            is_wool_grain,
            IMPERFECT_KERNAL,
            EN_ID
        FROM
            ENTRANCE_INDICATOR_RESULTS eir
        WHERE
            CHECK_NUM = 2 ) AS rr
ON
    v.E_ID = rr.EN_ID
LEFT JOIN
    (//composite
        SELECT
            FOREIGN_MATERIAL,
            MOISTURE,
            WET_GLUTEN,
            is_wool_grain,
            IMPERFECT_KERNAL,
            PDI_ID,
            ISMERGE
        FROM
            TEST_INDICATOR_RESULTS tir ) AS cr
ON
    v.P_ID = cr.PDI_ID
AND cr.ISMERGE = v.MERGED_BILLING_IND
WHERE
    1=1
AND v.PURCHASE_DOC_NO = 'SG1000010083';








SELECT
    pd.PUR_ID,//收购点
    m.MATERIAL_DESC,//物料
    wbd.STORAGE_LOC_NO,//库存地
    wbd.BATCH_NO,//批次
    SUM(eir.FOREIGN_MATERIAL)/COUNT(eir.FOREIGN_MATERIAL),//某指标权重
    SUM(wbd.FIRST_WEIGHT - wbd.SECOND_WEIGHT)//收购量
FROM
    WEIGHT_BRIDGE_DOC wbd //地磅单表
JOIN
    ENTRANCE_DOC_ITEM edi //入场单项目表
ON
    edi.ID = wbd.ENT_ITEM_ID
LEFT JOIN
    PURCHASE_ENTRANCE_DOC ped//收购单入场单对应表
ON
    ped.ENT_ID = edi.ID
LEFT JOIN
    PURCHASE_DOC_ITEM pdi//收购单项目表
ON
    ped.PUR_ID = pdi.ID
LEFT JOIN
    PURCHASE_DOC pd //收购单表
ON
    pdi.PUR_ID = pd.ID
LEFT JOIN
    ORG_MATERIAL m //物料表
ON
    pdi.ORG_ID = m.ID 
LEFT JOIN
    ENTRANCE_INDICATOR_RESULTS eir //检验指标结果表
ON
    eir.EN_ID = edi.ID
AND eir.CHECK_NUM = 1 //初检
WHERE
    1=1

//过滤条件

GROUP BY
    pd.PUR_ID,
    m.MATERIAL_DESC,
    wbd.STORAGE_LOC_NO,
    wbd.BATCH_NO

HAVING
//过滤条件
    wbd.STORAGE_LOC_NO = 'TW02';



-------------------------------------
-- view_weight_qc_inf
-- for 物料品质汇总查询(按库位)
-- DATE: 2013-8-23
-- Author: 倪震宇
-------------------------------------
-- 地磅单相关信息

-- 地磅单对应的 入场单 及 对应的 收购点、收购方
-- purchase_location_id 收购点ID
-- pur_entity_id        收购方ID
-- DOC_DATE             地磅单时间
-- wbd_DEFUNCT_IND      地磅单有效状态
-- wbd.DOC_CLOSE        地磅单关闭状态（找开发确认，字段含义）

-- 地磅单对应的 质检信息

drop view view_weight_qc_inf;
create view view_weight_qc_inf as
SELECT pl.purchase_location_name,pe.purchase_entity_name
	,ed.pur_id as purchase_location_id ,ed.pur_entity_id as purchase_entity_id
	,wbd.WEIGHT_BRIDGE_DOC_NO
	,wbd.FIRST_WEIGHT - wbd.SECOND_WEIGHT - coalesce(PACKING_UNIT_WEIGHT,0) as NET_WEIGHT
	,wbd.PACKING_UNIT_WEIGHT
	,wbd.STORAGE_ID
	,wbd.STORAGE_LOC_NO
	,wbd.BATCH_NO
	,wbd.SAP_CODE
	,wbd.DOC_DATE
	,wbd.DOC_CLOSE
	,wbd.DEFUNCT_IND as wbd_DEFUNCT_IND

	,ed.ENTRANCE_DOC_NO
	,m.ID as M_ID,edi.MATERIAL_CODE,edi.MATERIAL_DESC,edi.ORIGIN,edi.QUANTITY
	,eir.*
from WEIGHT_BRIDGE_DOC wbd left join ENTRANCE_DOC_ITEM edi on wbd.ent_item_id = edi.id
	left join ENTRANCE_DOC ed on edi.ENT_ID = ed.ID
	left join ORG_MATERIAL m on edi.MATERIAL_CODE = m.MATERIAL_ID AND m.PUR_ID = ed.PUR_ID
	
	left join PURCHASE_LOC pl on ed.pur_id = pl.id
	left join PURCHASE_ENTITY pe on ed.pur_entity_id = pe.id
	
	left join ENTRANCE_INDICATOR_RESULTS eir on edi.id = eir.en_id and check_num = 1;

------------------
-- 查询语句 示例（代码中 组合的SQL语句）
------------------
select MATERIAL_CODE,STORAGE_LOC_NO,BATCH_NO, count(moisture),sum(moisture*NET_WEIGHT),sum(NET_WEIGHT) , sum
(moisture*NET_WEIGHT)/sum(NET_WEIGHT) as moisture
	from view_weight_qc_inf
	where purchase_location_id = 100 AND DOC_DATE > '2013-08-21' 
				AND MATERIAL_CODE = '6.0210301 其它' 
				and check_num is not null and DOC_CLOSE = 0 and wbd_DEFUNCT_IND = 0
	group by MATERIAL_CODE,STORAGE_LOC_NO,BATCH_NO;



SELECT
    v.PURCHASE_LOCATION_ID,//收购点
    v.M_ID,                //物料id
    v.MATERIAL_DESC,       //物料描述
    v.STORAGE_LOC_NO,      //库存地
    v.BATCH_NO,            //批次
    //某指标权重   过滤掉   null   的字段
    SUM (CASE WHEN v.brown_rice_outside IS NULL THEN 0 ELSE v.brown_rice_outside * v.NET_WEIGHT END)
    / 
    SUM(CASE WHEN v.brown_rice_outside IS NULL THEN NULL ELSE v.NET_WEIGHT END),
    //  收货量
    SUM(v.NET_WEIGHT)
FROM
    VIEW_WEIGHT_QC_INF v
WHERE  //过滤条件
    1=1
-- and v.check_num is not null
AND v.wbd_DEFUNCT_IND = 0
GROUP BY
    v.PURCHASE_LOCATION_ID,
    v.M_ID,
    v.MATERIAL_DESC,
    v.STORAGE_LOC_NO,
    v.BATCH_NO
HAVING  //过滤条件
    1 = 1
AND v.PURCHASE_LOCATION_ID = 100
AND v.M_ID =101;










SELECT v.MATERIAL_DESC, v.STORAGE_LOC_NO, v.BATCH_NO, SUM (CASE WHEN v.MOISTURE IS NULL THEN 0 ELSE v.MOISTURE * v.NET_WEIGHT END)/ SUM(CASE WHEN v.MOISTURE IS NULL THEN NULL ELSE v.NET_WEIGHT END), SUM (CASE WHEN v.FOREIGN_MATERIAL IS NULL THEN 0 ELSE v.FOREIGN_MATERIAL * v.NET_WEIGHT END)/ SUM(CASE WHEN v.FOREIGN_MATERIAL IS NULL THEN NULL ELSE v.NET_WEIGHT END), SUM (CASE WHEN v.IMMATURE_KERNEL IS NULL THEN 0 ELSE v.IMMATURE_KERNEL * v.NET_WEIGHT END)/ SUM(CASE WHEN v.IMMATURE_KERNEL IS NULL THEN NULL ELSE v.NET_WEIGHT END), SUM (CASE WHEN v.HEAT_LOSS IS NULL THEN 0 ELSE v.HEAT_LOSS * v.NET_WEIGHT END)/ SUM(CASE WHEN v.HEAT_LOSS IS NULL THEN NULL ELSE v.NET_WEIGHT END), SUM (CASE WHEN v.CONTAINED_OIL IS NULL THEN 0 ELSE v.CONTAINED_OIL * v.NET_WEIGHT END)/ SUM(CASE WHEN v.CONTAINED_OIL IS NULL THEN NULL ELSE v.NET_WEIGHT END), SUM (CASE WHEN v.BROKEN_RATE IS NULL THEN 0 ELSE v.BROKEN_RATE * v.NET_WEIGHT END)/ SUM(CASE WHEN v.BROKEN_RATE IS NULL THEN NULL ELSE v.NET_WEIGHT END), SUM (CASE WHEN v.MOLD IS NULL THEN 0 ELSE v.MOLD * v.NET_WEIGHT END)/ SUM(CASE WHEN v.MOLD IS NULL THEN NULL ELSE v.NET_WEIGHT END), SUM (CASE WHEN v.milled_rice_rate IS NULL THEN 0 ELSE v.milled_rice_rate * v.NET_WEIGHT END)/ SUM(CASE WHEN v.milled_rice_rate IS NULL THEN NULL ELSE v.NET_WEIGHT END), SUM (CASE WHEN v.mix IS NULL THEN 0 ELSE v.mix * v.NET_WEIGHT END)/ SUM(CASE WHEN v.mix IS NULL THEN NULL ELSE v.NET_WEIGHT END), SUM (CASE WHEN v.yellow_rice IS NULL THEN 0 ELSE v.yellow_rice * v.NET_WEIGHT END)/ SUM(CASE WHEN v.yellow_rice IS NULL THEN NULL ELSE v.NET_WEIGHT END), SUM (CASE WHEN v.pure_rice IS NULL THEN 0 ELSE v.pure_rice * v.NET_WEIGHT END)/ SUM(CASE WHEN v.pure_rice IS NULL THEN NULL ELSE v.NET_WEIGHT END), SUM (CASE WHEN v.cubage IS NULL THEN 0 ELSE v.cubage * v.NET_WEIGHT END)/ SUM(CASE WHEN v.cubage IS NULL THEN NULL ELSE v.NET_WEIGHT END), SUM (CASE WHEN v.brown_rice_outside IS NULL THEN 0 ELSE v.brown_rice_outside * v.NET_WEIGHT END)/ SUM(CASE WHEN v.brown_rice_outside IS NULL THEN NULL ELSE v.NET_WEIGHT END), SUM(v.NET_WEIGHT) FROM VIEW_WEIGHT_QC_INF v WHERE 1=1 AND v.wbd_DEFUNCT_IND = 0 and v.DOC_DATE >= '2013-08-26 11:37:00' and v.DOC_DATE < '2013-08-27 11:37:00' GROUP BY v.PURCHASE_LOCATION_ID, v.M_ID, v.MATERIAL_DESC, v.STORAGE_LOC_NO, v.BATCH_NO HAVING 1 = 1 and v.PURCHASE_LOCATION_ID = 100 and v.M_ID =101 order by v.STORAGE_LOC_NO,v.BATCH_NO



--DB2LOOK -D Y_TIH -E -A -I Yuan -W 19900115 -O DB_DLL.sql






SELECT
    COUNT(1)
FROM
    (
        SELECT DISTINCT
            (wf.id)
        FROM
            WF_INSTANCEMSTR wf
        JOIN
            (
                SELECT
                    s.WF_INSTANCEMSTR_ID ,
                    MAX(s.id) ,
                    MAX(s.COMPLETED_DATETIME)
                FROM
                    WF_STEPMSTR s
                WHERE
                    s.COMPLETED_DATETIME < '2013-09-02 00:00:00'
                    --and s.COMPLETED_DATETIME > '2013-08-02 00:00:00'
                GROUP BY
                    s.WF_INSTANCEMSTR_ID ) AS tmp
        ON
            wf.ID= tmp.WF_INSTANCEMSTR_ID
        WHERE
            wf.DEFUNCT_IND = 'N'
        AND wf.STATUS = 'TIH.TAX.WORKFLOWSTATUS.2'
        ORDER BY
            wf.id DESC );






UPDATE
    NOTIFICATION_SENDER s
SET
    s.STATUS = 'TIH.TAX.MSG.STATUS.2'
WHERE
    s.id IN
    (
        SELECT
            s.ID
        FROM
            NOTIFICATION_SENDER s
        JOIN
            NOTIFICATIONMSTR n
        ON
            s.NOTIFICATIONMSTR_ID = n.ID
        WHERE
            1=1
        AND n.CONTENT LIKE '%请尽快处理此流程%'
        AND n.CREATED_DATETIME > '2013-08-15 00:00:00' );
SELECT
    COUNT(1)
FROM
    NOTIFICATION_SENDER s
JOIN
    NOTIFICATIONMSTR n
ON
    s.NOTIFICATIONMSTR_ID = n.ID
WHERE
    1=1
AND s.STATUS = 'TIH.TAX.MSG.STATUS.2'
AND n.CONTENT LIKE '%请尽快处理此流程%'
AND n.CREATED_DATETIME > '2013-08-15 00:00:00';




SELECT
    COUNT(1)
FROM
    NOTIFICATION_SENDER s
WHERE
    s.STATUS = 'TIH.TAX.MSG.STATUS.2';




select count(1) from
(
SELECT
    MAX(s.id)
FROM
    WF_STEPMSTR s join WF_INSTANCEMSTR w
    on s.WF_INSTANCEMSTR_ID = w.ID
WHERE
    1 =1
    and w.STATUS = 'TIH.TAX.WORKFLOWSTATUS.2'
    and w.DEFUNCT_IND <> 'Y'
GROUP BY
    s.WF_INSTANCEMSTR_ID
    );
    



UPDATE WF_INSTANCEMSTR WF SET WF.STATUS = 'TIH.TAX.WORKFLOWSTATUS.4'  WHERE WF.ID IN

(
SELECT
    W.ID
FROM
    WF_INSTANCEMSTR W
WHERE
    W.STATUS = 'TIH.TAX.WORKFLOWSTATUS.2'
AND W.CREATED_DATETIME <'2013-08-06 00:00:00')








SELECT
    n.CONTENT,
    r.RECEIVED_BY,
    wf.TYPE,
    s.STATUS,
    s.SEND_OPTION
FROM
    NOTIFICATIONMSTR n
JOIN
    NOTIFICATION_SENDER s
ON
    n.ID = s.NOTIFICATIONMSTR_ID
JOIN
    NOTIFICATION_RECEIVER r
ON
    s.ID = r.NOTIFICATION_SENDER
JOIN
    WF_INSTANCEMSTR wf
ON
    n.TYPE_ID = wf.NO
AND n.CREATED_DATETIME > '2013-08-06 12:00:00'
		



SELECT
    n.CONTENT,
    s.STATUS
FROM
    NOTIFICATIONMSTR n
JOIN
    WF_INSTANCEMSTR wf
ON
    n.TYPE_ID = wf.NO
JOIN
    NOTIFICATION_SENDER s
ON
    n.ID = s.NOTIFICATIONMSTR_ID
WHERE
    n.CREATED_DATETIME > '2013-09-16 13:00:00'
AND s.SEND_OPTION = 'TIH.TAX.MSG.TYPE.1'
AND wf.TYPE = 'TIH.TAX.REQUESTFORM.3'




F443B038DC020D4BA3BEE65996F0840E



SELECT
    *
FROM
    WF_STEPMSTR ws
WHERE
    1=1
AND ws.COMPLETED_DATETIME < '2013-09-25 00:00:00'
AND ws.id IN
    (
        SELECT
            MAX(s.id)
        FROM
            WF_STEPMSTR s
        JOIN
            WF_INSTANCEMSTR w
        ON
            s.WF_INSTANCEMSTR_ID = w.ID
        WHERE
            1 =1
        AND w.STATUS = 'TIH.TAX.WORKFLOWSTATUS.2'
        AND w.DEFUNCT_IND <> 'Y'
        --AND w.NO = 'F443B038DC020D4BA3BEE65996F0840E'
        GROUP BY
            s.WF_INSTANCEMSTR_ID )




SELECT
    *
FROM
    WF_INSTANCEMSTR wf
JOIN
    WF_STEPMSTR ws
ON
    wf.id = ws.WF_INSTANCEMSTR_ID
ORDER BY
    wf.ID
FETCH
    FIRST 10 ROWS ONLY








　启动Samba服务器：
　　# service smb start
　　Starting SMB services: [  OK  ]
　　Starting NMB services: [  OK  ]

查看Samba服务的服务状态：
　　# service smb status
　　smbd (pid 3886 3882) is running...
　　nmbd (pid 3887) is running...
停止Samba服务器：
　　# service smb stop
　　Shutting down SMB services: [  OK  ]
　　Shutting down NMB services: [  OK  ]



mount -a
umount -a  



创建服务
mongod --dbpath "D:\development\tools\mongodb-2.4.7\data\db" --logpath "D:\development\tools\mongodb-2.4.7\data\log\MongoDB.log" --install --serviceName "MongoDB"
删除服务
mongod --dbpath "D:\development\tools\mongodb-2.4.7\data\db" --logpath "D:\development\tools\mongodb-2.4.7\data\log\MongoDB.log" --remove --serviceName "MongoDB"

net start MongoDB   (开启服务）
net stop MongoDB   (关闭服务)












SELECT
    *
FROM
    WF_INSTANCEMSTR wf
JOIN
    (
        SELECT
            MAX(s.COMPLETED_DATETIME) AS COMPLETED_DATETIME,
            s.WF_INSTANCEMSTR_ID
        FROM
            WF_STEPMSTR s
        GROUP BY
            s.WF_INSTANCEMSTR_ID ) AS ws
ON
    wf.ID = ws.WF_INSTANCEMSTR_ID
WHERE
    mod(INT(ws.COMPLETED_DATETIME-wf.CREATED_DATETIME),7) = 0;








SELECT
    wf.TYPE,
    wf.NO,
    ws.CHARGED_BY
FROM
    WF_INSTANCEMSTR wf
JOIN
    (
        SELECT
            step.WF_INSTANCEMSTR_ID AS WF_INSTANCEMSTR_ID,
            step.CHARGED_BY         AS CHARGED_BY,
            step.COMPLETED_DATETIME AS COMPLETED_DATETIME
        FROM
            WF_STEPMSTR step
        WHERE
            step.ID IN
            (
                SELECT
                    MAX(s.id)
                FROM
                    WF_STEPMSTR s
                GROUP BY
                    s.WF_INSTANCEMSTR_ID )) AS ws
ON
    wf.ID = ws.WF_INSTANCEMSTR_ID
JOIN
    WF_TIMEOUT_REMIND wtr
ON
    wf.TYPE = wtr.TYPE
AND wtr.DEFUNCT_IND = 'N'
AND wtr.STATUS ='1'
    //AND wtr.JOB_ID =''
WHERE
    wf.STATUS = 'TIH.TAX.WORKFLOWSTATUS.2'
AND wf.DEFUNCT_IND ='N'
AND days('2013-12-5 00:00:00')-days(ws.COMPLETED_DATETIME) BETWEEN wtr.OVERTIME_DAYS AND
    wtr.EFFECTIVE_DAYS
AND mod(days('2013-12-5 00:00:00') - days(wf.CREATED_DATETIME )-wtr.OVERTIME_DAYS,
    wtr.INTERVAL_DAYS) = 0;
    
    








-- 
-- TABLE: WF_TIMEOUT_REMIND 
--

CREATE TABLE WF_TIMEOUT_REMIND(
    ID                     BIGINT         NOT NULL,
    JOB_ID                 VARCHAR(50)    NOT NULL,
    TYPE                   VARCHAR(50)    NOT NULL,
    REMARKS                VARCHAR(50),
    STATUS                 VARCHAR(50)    NOT NULL,
    OVERTIME_DAYS          BIGINT         NOT NULL,
    INTERVAL_DAYS          BIGINT         NOT NULL,
    EFFECTIVE_DAYS         BIGINT         NOT NULL,
    
    CREATED_BY             VARCHAR(50)    NOT NULL,
    UPDATED_BY             VARCHAR(50)    NOT NULL,
    UPDATED_DATETIME       TIMESTAMP      NOT NULL,
    CREATED_DATETIME       TIMESTAMP      NOT NULL,
    DEFUNCT_IND            CHAR(1)        NOT NULL,
    CONSTRAINT PK146 PRIMARY KEY (ID)
)
;








SELECT
    *
FROM
    (
        SELECT
            *
        FROM
            USERMSTR
        WHERE
            id IN
            (
                SELECT
                    MAX(id)
                FROM
                    USERMSTR
                GROUP BY
                    AD_ACCOUNT )) AS u
LEFT JOIN
    (
        SELECT
            *
        FROM
            TAM_USERMSTR tu
        WHERE
            tu.ID IN
            (
                SELECT
                    MAX(id)
                FROM
                    TAM_USERMSTR
                GROUP BY
                    USER_ID ) ) AS tu
ON
    u.ID = tu.USER_ID;




SELECT
    u.DEFUNCT_IND,
    tu.DISABLED,
    
    COALESCE(tu.STATUS,'-1') AS s,
    CASE
        WHEN u.DEFUNCT_IND = tu.DISABLED
        THEN 1
        ELSE 0
    END as ISOVERTIME
FROM
    (
        SELECT
            *
        FROM
            USERMSTR
        WHERE
            id IN
            (
                SELECT
                    MAX(id)
                FROM
                    USERMSTR
                GROUP BY
                    AD_ACCOUNT )) AS u
LEFT JOIN
    TAM_USERMSTR AS tu
ON
    u.ID = tu.USER_ID
    ORDER BY s DESC,ISOVERTIME,tu.DISABLED,u.DEFUNCT_IND DESC














SELECT
    u.id ,
    u.AD_ACCOUNT ,
    u.DEFUNCT_IND ,
    tu.ID ,
    tu.USER_ID ,
    tu.USER_ACCOUNT ,
    tu.DISABLED ,
    tu.SYNC_DATETIME ,
    CASE
        WHEN tu.STATUS IS NULL
        THEN 'TAM-STATUS-3'
        WHEN tu.DISABLED != u.DEFUNCT_IND
        THEN 'TAM-STATUS-1'
        WHEN tu.STATUS = '0'
        THEN 'TAM-STATUS-2'
        ELSE 'TAM-STATUS-0'
    END AS STATUS
FROM
    (
        SELECT
            *
        FROM
            USERMSTR
        WHERE
            id IN
            (
                SELECT
                    MAX(id)
                FROM
                    USERMSTR
                GROUP BY
                    AD_ACCOUNT ) ) AS u
LEFT JOIN
    TAM_USERMSTR tu
ON
    u.AD_ACCOUNT = tu.USER_ACCOUNT
WHERE
    1=1;








SELECT
    u.id ,
    u.AD_ACCOUNT ,
    u.DEFUNCT_IND ,
    tu.ID ,
    tu.USER_ID ,
    tu.USER_ACCOUNT ,
    tu.DISABLED ,
    tu.SYNC_DATETIME ,
    CASE
        WHEN tu.STATUS IS NULL
        THEN 'TAM-STATUS-3'
        WHEN tu.STATUS != '0'
        THEN 'TAM-STATUS-0'
        WHEN u.DEFUNCT_IND = tu.DISABLED
        THEN 'TAM-STATUS-2'
        ELSE 'TAM-STATUS-1'
    END AS STATUS,
    tu.STATUS
FROM
    (
        SELECT
            *
        FROM
            USERMSTR
        WHERE
            id IN
            (
                SELECT
                    MAX(id)
                FROM
                    USERMSTR
                GROUP BY
                    AD_ACCOUNT ) ) AS u
LEFT JOIN
    TAM_USERMSTR tu
ON
    u.AD_ACCOUNT = tu.USER_ACCOUNT
WHERE
    1=1
ORDER BY
    STATUS,
    tu.SYNC_DATETIME DESC;





--超时邮件
-- 1.岗位超时
SELECT
    w.TYPE,
    w.NO,
    ws.CHARGED_BY,
    wc.MAIL_IND,
    wc.SYS_NOTICE_IND,
    ws.COMPLETED_DATETIME + pr.WP_TIMEOUT_DAYS DAY                            AS COMPLETED_DATETIME,
    days('2014-3-3 00:00:00') - days(ws.COMPLETED_DATETIME)-pr.WP_TIMEOUT_DAYS AS OVERTIMEDAYS
FROM
    WF_INSTANCEMSTR w
JOIN
    (
        SELECT
            step.WF_INSTANCEMSTR_ID AS WF_INSTANCEMSTR_ID,
            step.CHARGED_BY         AS CHARGED_BY,
            step.COMPLETED_DATETIME AS COMPLETED_DATETIME
        FROM
            WF_STEPMSTR step
        WHERE
            step.ID IN
            (
                SELECT
                    MAX(s.id)
                FROM
                    WF_STEPMSTR s
                GROUP BY
                    s.WF_INSTANCEMSTR_ID ) ) AS ws
ON
    w.ID = ws.WF_INSTANCEMSTR_ID
JOIN
    WF_INSTANCEMSTR_PROPERTY wp
ON
    w.ID = wp.WF_INSTANCEMSTR_ID
AND wp.NAME = 'TIMEOUT.EMAIL.REQUESTFORM.TYPE'
JOIN
    WF_TIMEOUT_CONFIG wc
ON
    locate(wp.VALUE,wc.WF_REQUESTFORM_TYPE)>0
AND wc.DEFUNCT_IND = 'N'
AND wc.ENABLE_IND = 'Y'
AND wc.POSITION_TIMEOUT_IND = 'Y'
JOIN
    POSITION_TIMEOUT_REMIND pr
ON
    wc.ID = pr.WF_TIMEOUT_CONFIG_ID
WHERE
    w.DEFUNCT_IND = 'N'
AND w.STATUS = 'TIH.TAX.WORKFLOWSTATUS.2'
AND days('2014-3-3 00:00:00')-days(ws.COMPLETED_DATETIME) BETWEEN pr.WP_TIMEOUT_DAYS AND
    wc.EFFECTIVE_DAYS
AND mod (days('2014-3-3 00:00:00') - days(ws.COMPLETED_DATETIME)-pr.WP_TIMEOUT_DAYS,
    pr.WP_INTERVAL_DAYS) =0;
    
--2.岗位提醒
SELECT
    w.TYPE,
    w.NO,
    ws.CHARGED_BY,
    wc.MAIL_IND,
    wc.SYS_NOTICE_IND
FROM
    WF_INSTANCEMSTR w
JOIN
    (
        SELECT
            step.WF_INSTANCEMSTR_ID AS WF_INSTANCEMSTR_ID,
            step.CHARGED_BY         AS CHARGED_BY,
            step.COMPLETED_DATETIME AS COMPLETED_DATETIME
        FROM
            WF_STEPMSTR step
        WHERE
            step.ID IN
            (
                SELECT
                    MAX(s.id)
                FROM
                    WF_STEPMSTR s
                GROUP BY
                    s.WF_INSTANCEMSTR_ID ) ) AS ws
ON
    w.ID = ws.WF_INSTANCEMSTR_ID
JOIN
    WF_INSTANCEMSTR_PROPERTY wp
ON
    w.ID = wp.WF_INSTANCEMSTR_ID
AND wp.NAME = 'TIMEOUT.EMAIL.REQUESTFORM.TYPE'
JOIN
    WF_TIMEOUT_CONFIG wc
ON
    locate(wp.VALUE,wc.WF_REQUESTFORM_TYPE)>0
AND wc.DEFUNCT_IND = 'N'
AND wc.ENABLE_IND = 'Y'
AND wc.POSITION_TIMEOUT_IND = 'Y'
JOIN
    POSITION_TIMEOUT_REMIND pr
ON
    wc.ID = pr.WF_TIMEOUT_CONFIG_ID
WHERE
    w.DEFUNCT_IND = 'N'
AND w.STATUS = 'TIH.TAX.WORKFLOWSTATUS.2'
AND days('2014-2-22 00:00:00')-days(ws.COMPLETED_DATETIME) BETWEEN 0 AND
    wc.EFFECTIVE_DAYS
AND pr.WP_URGE_DAYS <> 0
AND days('2014-2-22 00:00:00')-days(ws.COMPLETED_DATETIME) = pr.WP_URGE_DAYS;

--流程超时
SELECT
    w.TYPE,
    w.NO,
    ws.CHARGED_BY,
    wc.MAIL_IND,
    wc.SYS_NOTICE_IND
FROM
    WF_INSTANCEMSTR w
JOIN
    (
        SELECT
            step.WF_INSTANCEMSTR_ID AS WF_INSTANCEMSTR_ID,
            step.CHARGED_BY         AS CHARGED_BY,
            step.COMPLETED_DATETIME AS COMPLETED_DATETIME
        FROM
            WF_STEPMSTR step
        WHERE
            step.ID IN
            (
                SELECT
                    MAX(s.id)
                FROM
                    WF_STEPMSTR s
                GROUP BY
                    s.WF_INSTANCEMSTR_ID ) ) AS ws
ON
    w.ID = ws.WF_INSTANCEMSTR_ID
JOIN
    WF_INSTANCEMSTR_PROPERTY wp
ON
    w.ID = wp.WF_INSTANCEMSTR_ID
AND wp.NAME = 'TIMEOUT.EMAIL.REQUESTFORM.TYPE'
JOIN
    WF_TIMEOUT_CONFIG wc
ON
    locate(wp.VALUE,wc.WF_REQUESTFORM_TYPE)>0
AND wc.DEFUNCT_IND = 'N'
AND wc.ENABLE_IND = 'Y'
AND wc.WF_TIMEOUT_IND = 'Y'
JOIN
    WF_TIMEOUT_REMIND wr
ON
    w.ID = wr.WF_ID
WHERE
    w.DEFUNCT_IND = 'N'
AND w.STATUS = 'TIH.TAX.WORKFLOWSTATUS.2'
AND days('2014-2-28 00:00:00')-days(wr.WF_COMPLETE_DATE) BETWEEN 0 AND wc.EFFECTIVE_DAYS
AND mod(days('2014-2-28 00:00:00') - days(wr.WF_COMPLETE_DATE),wr.WF_INTERVAL_DAYS) = 0;

--流程提醒
SELECT
    w.TYPE,
    w.NO,
    ws.CHARGED_BY,
    wc.MAIL_IND,
    wc.SYS_NOTICE_IND
FROM
    WF_INSTANCEMSTR w
JOIN
    (
        SELECT
            step.WF_INSTANCEMSTR_ID AS WF_INSTANCEMSTR_ID,
            step.CHARGED_BY         AS CHARGED_BY,
            step.COMPLETED_DATETIME AS COMPLETED_DATETIME
        FROM
            WF_STEPMSTR step
        WHERE
            step.ID IN
            (
                SELECT
                    MAX(s.id)
                FROM
                    WF_STEPMSTR s
                GROUP BY
                    s.WF_INSTANCEMSTR_ID ) ) AS ws
ON
    w.ID = ws.WF_INSTANCEMSTR_ID
JOIN
    WF_INSTANCEMSTR_PROPERTY wp
ON
    w.ID = wp.WF_INSTANCEMSTR_ID
AND wp.NAME = 'TIMEOUT.EMAIL.REQUESTFORM.TYPE'
JOIN
    WF_TIMEOUT_CONFIG wc
ON
    locate(wp.VALUE,wc.WF_REQUESTFORM_TYPE)>0
AND wc.DEFUNCT_IND = 'N'
AND wc.ENABLE_IND = 'Y'
AND wc.WF_TIMEOUT_IND = 'Y'
JOIN
    WF_TIMEOUT_REMIND wr
ON
    w.ID = wr.WF_ID
WHERE
    w.DEFUNCT_IND = 'N'
AND w.STATUS = 'TIH.TAX.WORKFLOWSTATUS.2'
AND days('2014-2-26 00:00:00')-days(wr.WF_URGE_DATE) BETWEEN 0 AND wc.EFFECTIVE_DAYS
AND days('2014-2-26 00:00:00') = days(wr.WF_URGE_DATE);



SELECT
    wr.*
FROM
    WF_INSTANCEMSTR w
JOIN
    WF_INSTANCEMSTR_PROPERTY wp
ON
    w.ID = wp.WF_INSTANCEMSTR_ID
AND wp.NAME = 'TIMEOUT.EMAIL.REQUESTFORM.TYPE'
JOIN
    WF_TIMEOUT_CONFIG wc
ON
    locate(wp.VALUE,wc.WF_REQUESTFORM_TYPE)>0
AND wc.DEFUNCT_IND = 'N'
AND wc.ENABLE_IND = 'Y'
AND wc.WF_TIMEOUT_IND = 'Y'
JOIN
    WF_TIMEOUT_REMIND wr
ON
    w.ID = wr.WF_ID
WHERE
    w.DEFUNCT_IND = 'N'
AND w.STATUS = 'TIH.TAX.WORKFLOWSTATUS.2';


SELECT 4 AS SQ_NO,'应交税务综合表审核' AS NAME,WI.TYPE,WS.CHARGED_BY,WI.STATUS,COUNT(WI.STATUS) AS NUM
FROM WF_STEPMSTR WS,WF_INSTANCEMSTR WI,WF_INSTANCEMSTR_PROPERTY WIP
WHERE WS.WF_INSTANCEMSTR_ID = WI.ID AND WS.NAME = '报表处理岗主管'
AND WI.ID = WIP.WF_INSTANCEMSTR_ID
AND WIP.NAME = 'TIH.WORKFLOW.SENDREPORT.REPORT.TYPE' AND WIP.VALUE = 'TIH.TAX.REQUESTFORM.4.1'
AND WI.STATUS NOT IN ('TIH.TAX.WORKFLOWSTATUS.1')
AND WI.DEFUNCT_IND <>'Y'
AND WS.CHARGED_BY !=''
AND WI.TYPE = 'TIH.TAX.REQUESTFORM.4'
AND WS.DEAL_METHOD = 'TIH.TAX.APPROACH.8'
GROUP BY WI.TYPE, WS.CHARGED_BY,WI.STATUS;




