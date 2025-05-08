-- SHADMINスキーマを作成
create user SHADMIN IDENTIFIED BY Welcome12345#;

-- 権限の付与
GRANT SELECT ANY TABLE TO ADMIN;
GRANT DWROLE TO SHADMIN;
GRANT UNLIMITED TABLESPACE TO SHADMIN;

-- DUMMY列を加えたSALES表を作成
CREATE TABLE "SHADMIN"."SALES"
   (    "PROD_ID" NUMBER NOT NULL ENABLE,
        "CUST_ID" NUMBER NOT NULL ENABLE,
        "TIME_ID" DATE NOT NULL ENABLE,
        "CHANNEL_ID" NUMBER NOT NULL ENABLE,
        "PROMO_ID" NUMBER NOT NULL ENABLE,
        "QUANTITY_SOLD" NUMBER(10,2) NOT NULL ENABLE,
        "AMOUNT_SOLD" NUMBER(10,2) NOT NULL ENABLE,
        "DUMMY1" CHAR(100),
        "DUMMY2" CHAR(110)
   );

-- データを追加
insert /*+append */ into SHADMIN.SALES
  nologging
    select PROD_ID,
           CUST_ID,
           TIME_ID+15*365+3,
           CHANNEL_ID,
           PROMO_ID,
           QUANTITY_SOLD,
           AMOUNT_SOLD,
           rpad(to_char(mod(CUST_ID,30)),100,'dummy1'),
           rpad(to_char(mod(CUST_ID,30)),110,'dummy2')
      from SH.SALES;
commit;

-- データを増幅
insert /*+append */ into SHADMIN.SALES nologging select * from SHADMIN.SALES;
commit;
insert /*+append */ into SHADMIN.SALES nologging select * from SHADMIN.SALES;
commit;
insert /*+append */ into SHADMIN.SALES nologging select * from SHADMIN.SALES;
commit;
insert /*+append */ into SHADMIN.SALES nologging select * from SHADMIN.SALES;
commit;
insert /*+append */ into SHADMIN.SALES nologging select * from SHADMIN.SALES;
commit;
insert /*+append */ into SHADMIN.SALES nologging select * from SHADMIN.SALES;
commit;
insert /*+append */ into SHADMIN.SALES nologging select * from SHADMIN.SALES;
commit;
insert /*+append */ into SHADMIN.SALES nologging select * from SHADMIN.SALES;
commit;
insert /*+append */ into SHADMIN.SALES nologging select * from SHADMIN.SALES;
commit;
