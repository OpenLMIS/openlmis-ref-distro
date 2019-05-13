-- Olmis create table statements
-- Created by Craig Appl (cappl@ona.io)
-- Modified by A. Maritim (amaritim@ona.io) and J. Wambere (jwambere@ona.io)
-- Last Updated 24 September 2018
--

--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';

--
-- Name: commodity_types; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE commodity_types (
    id varchar NOT NULL UNIQUE,
    name character varying(255),
    classificationsystem character varying(255),
    classificationid character varying(255),
    parentid varchar
);


ALTER TABLE commodity_types OWNER TO postgres;

--
-- Name: facilities; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE facilities (
    id varchar NOT NULL UNIQUE,
    code character varying(255),
    name character varying(255),
    status boolean,
    enabled boolean,
    type character varying(255),
    operator_code character varying(255),
    operator_name character varying(255),
    operator_id character varying(255),
    district character varying(255),
    region character varying(255),
    country character varying(255),
    golivedate date,
    godowndate date,
    openlmisaccessible boolean,
    comment text,
    description text,
    extradata json,
    location character varying(255)
);


ALTER TABLE facilities OWNER TO postgres;

--
-- Name: ideal_stock_amounts; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE ideal_stock_amounts (
    id varchar NOT NULL UNIQUE,
    facilityid varchar,
    processingperiodid varchar,
    amount integer,
    commoditytypeid varchar
);


ALTER TABLE ideal_stock_amounts OWNER TO postgres;

--
-- Name: lots; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE lots (
    id varchar NOT NULL UNIQUE,
    lotcode character varying(255),
    expirationdate date,
    manufacturedate date,
    tradeitemid varchar,
    active boolean
);


ALTER TABLE lots OWNER TO postgres;

--
-- Name: orderables; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE orderables (
    id varchar NOT NULL,
    code character varying(255),
    fullproductname character varying(255),
    packroundingthreshold bigint,
    netcontent bigint,
    roundtozero boolean,
    description character varying(255),
    programid character varying(255),
    orderabledisplaydategoryid character varying(255),
    orderablecategorydisplayname character varying(255),
    orderablecategorydisplayorder int,
    active boolean,
    fullsupply boolean,
    displayorder int,
    dosesperpatient int,
    priceperpack double precision,
    tradeitemid character varying(255),
    extradata json
);


ALTER TABLE orderables OWNER TO postgres;

--
-- Name: processing_periods; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE processing_periods (
    id varchar NOT NULL UNIQUE,
    description text,
    enddate date,
    name character varying(255),
    startdate date,
    processingscheduleid varchar
);


ALTER TABLE processing_periods OWNER TO postgres;

--
-- Name: program_orderables; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE program_orderables (
    id varchar NOT NULL UNIQUE,
    active boolean,
    displayorder integer,
    dosesperpatient integer,
    fullsupply boolean,
    priceperpack numeric(19,2),
    orderabledisplaycategoryid varchar,
    orderableid varchar,
    programid varchar
);


ALTER TABLE program_orderables OWNER TO postgres;

--
-- Name: programs; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE programs (
    id varchar NOT NULL UNIQUE,
    active boolean,
    code character varying(255),
    description text,
    name text,
    periodsskippable boolean,
    shownonfullsupplytab boolean,
    enabledatephysicalstockcountcompleted boolean,
    skipauthorization boolean DEFAULT false
);


ALTER TABLE programs OWNER TO postgres;

--
-- Name: requisition_group_members; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE requisition_group_members (
    requisitiongroupid varchar NOT NULL,
    facilityid varchar
);


ALTER TABLE requisition_group_members OWNER TO postgres;

--
-- Name: requisition_group_program_schedules; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE requisition_group_program_schedules (
    id varchar NOT NULL UNIQUE,
    directdelivery boolean,
    dropofffacilityid varchar,
    processingscheduleid varchar,
    programid varchar,
    requisitiongroupid varchar
);


ALTER TABLE requisition_group_program_schedules OWNER TO postgres;

--
-- Name: supported_programs; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE supported_programs (
    active boolean,
    startdate date,
    facilityid varchar,
    programid varchar,
    locallyfulfilled boolean DEFAULT false
);


ALTER TABLE supported_programs OWNER TO postgres;

--
-- Name: trade_items; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE trade_items (
    id varchar NOT NULL UNIQUE,
    manufactureroftradeitem character varying(255),
    gtin text
);


ALTER TABLE trade_items OWNER TO postgres;

--
-- Name: rights; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE rights (
    id varchar NOT NULL UNIQUE,
    name character varying(255),
    type character varying(255)
);


ALTER TABLE rights OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE users (
    id varchar NOT NULL UNIQUE,
    username character varying(255),
    firstname character varying(255),
    lastname character varying(255),
    homefacilityid varchar,
    active boolean,
    loginRestricted boolean
);


ALTER TABLE users OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE roles (
    id varchar NOT NULL,
    name character varying(255),
    description character varying(255),
    rightsname character varying(255),
    rightsid varchar,
    rightstype character varying(255),
    count INT
);


ALTER TABLE roles OWNER TO postgres;

--
-- Name: supervisorynodes; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE supervisorynodes (
    id varchar NOT NULL UNIQUE,
    name character varying(255),
    code character varying(255),
    facilityname character varying(255),
    facilityid varchar,
    requisitiongroupname character varying(255),
    requisitiongroupid varchar,
    parentnodename character varying(255),
    parentnodeid varchar
);


ALTER TABLE supervisorynodes OWNER TO postgres;

--
-- Name: requisitiongroups; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE requisitiongroups (
    id character varying(255) NOT NULL UNIQUE,
    name character varying(255),
    code character varying(255),
    facilityid varchar,
    supervisorynodeid varchar,
    supervisorynodename character varying(255),
    supervisorynodecode character varying(255),
    programname character varying(255),
    programid character varying(255),
    processingscheduleid character varying(255),
    directdelivery boolean
);


ALTER TABLE requisitiongroups OWNER TO postgres;

--
-- Name: supplylines; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE supplylines (
    id varchar NOT NULL UNIQUE,
    description character varying(255),
    supervisorynodeid varchar,
    programid varchar,
    supplyingfacilityid varchar
);


ALTER TABLE supplylines OWNER TO postgres;

--
-- Name: requisitions; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE requisitions (
  id VARCHAR UNIQUE,
  created_date timestamp,
  modified_date timestamp,
  emergency_status boolean,
  supplying_facility varchar,
  supervisory_node varchar,
  facility_id varchar,
  facility_code varchar,
  facility_name varchar,
  facilty_active_status boolean,
  district_id varchar,
  district_code varchar,
  district_name varchar,
  region_id varchar,
  region_code varchar,
  region_name varchar,
  country_id varchar,
  country_code varchar,
  country_name varchar,
  facility_type_id varchar,
  facility_type_code varchar,
  facility_type_name varchar,
  facility_operator_id varchar,
  facility_operator_code varchar,
  facility_operator_name varchar,
  program_id varchar,
  program_code varchar,
  program_name varchar,
  program_active_status boolean,
  processing_period_id varchar,
  processing_period_name varchar,
  processing_period_startdate varchar,
  processing_period_enddate date,
  processing_schedule_id varchar,
  processing_schedule_code varchar,
  processing_schedule_name varchar 
);

ALTER TABLE requisitions OWNER TO postgres;

--
-- Name: requisition_line_item; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE requisition_line_item (
  requisition_line_item_id varchar,
  requisition_id varchar,
  orderable_id varchar,
  product_code varchar,
  full_product_name varchar,
  trade_item_id varchar,
  beginning_balance double precision,
  total_consumed_quantity double precision,
  average_consumption double precision,
  adjusted_consumption double precision,
  total_losses_and_adjustments double precision,
  stock_on_hand double precision,
  total_stockout_days double precision,
  max_periods_of_stock double precision,
  calculated_order_quantity double precision,
  requested_quantity double precision,
  approved_quantity double precision,
  packs_to_ship double precision,
  price_per_pack double precision,
  total_cost double precision,
  total_received_quantity double precision
);

ALTER TABLE requisition_line_item OWNER TO postgres;

--
-- Name: requisitions_status_history; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE requisitions_status_history (
  requisition_id varchar,
  status varchar,
  author_id varchar,
  created_date date
);

ALTER TABLE requisitions_status_history OWNER TO postgres;

--
-- Name: requisitions_adjustment_lines; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE requisitions_adjustment_lines (
  requisition_id varchar,
  id varchar,
  reasonId varchar,
  quantity int,
  requisition_line_item_id varchar
);

ALTER TABLE requisitions_adjustment_lines OWNER TO postgres;

--
-- Name: sohlineitems; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE sohlineitems (
    stockCardID varchar,
    facilityID varchar,
    facilityCode varchar,
    facilityName varchar,
    facilityActive boolean,
    facilityEnabled boolean,
    facilityType varchar,
    programID varchar,
    programCode varchar,
    programName varchar,
    orderableID varchar,
    productCode varchar,
    fullProductName varchar,
    netContent int,
    lastUpdate varchar,
    quantity int,
    reasonName varchar,
    reasonType varchar,
    reasonCategory varchar,
    reasonID varchar,
    occurredDate varchar,
    stockOnHand int,
    sohlineitems_id varchar,
    source varchar,
    destination varchar
);

ALTER TABLE sohlineitems OWNER TO postgres;

--
-- Name: facility_access; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE facility_access (
    username varchar,
    facility varchar,
    program varchar
);

ALTER TABLE facility_access OWNER TO postgres;

--
-- Name: stock_adjustment_reasons; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE stock_adjustment_reasons (
  id varchar,
  name varchar,
  additive boolean,
  displayorder int,
  description text,
  programid varchar,
  programname varchar
);

ALTER TABLE stock_adjustment_reasons OWNER TO postgres;

--
-- Name: reporting_dates; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE reporting_dates (
  due_days int,
  late_days int,
  country varchar
);

ALTER TABLE reporting_dates OWNER TO postgres;

-- Insert default values for reporting dates --
INSERT INTO reporting_dates(due_days, late_days, country) 
    VALUES(14, 7, 'Malawi'), (14, 7, 'Mozambique');

---
--- Name: reporting_rate_and_timeliness; Type: TABLE; Schema: referencedata; Owner: postgres
---
CREATE MATERIALIZED VIEW reporting_rate_and_timeliness AS
SELECT f.id, f.name, f.district, f.region, f.country, f.type, f.operator_name, 
f.status as facility_active_status,
authorized_reqs.program_id, authorized_reqs.req_id, authorized_reqs.processing_period_id, 
authorized_reqs.processing_period_enddate, authorized_reqs.facility_id, authorized_reqs.created_date, 
authorized_reqs.modified_date, authorized_reqs.emergency_status, authorized_reqs.program_name, 
authorized_reqs.program_active_status, authorized_reqs.processing_schedule_name, 
authorized_reqs.processing_period_name, authorized_reqs.processing_period_startdate,
sp.programid as supported_program, sp.startdate, sp.active as supported_program_active,
rgm.requisitiongroupid,
rgps.processingscheduleid,
fa.facility, fa.program, fa.username,
CASE
    WHEN authorized_reqs.statuschangedate <= (authorized_reqs.processing_period_enddate::DATE + rd.due_days::INT) 
        AND authorized_reqs.status = 'AUTHORIZED' THEN 'On time'
    WHEN authorized_reqs.statuschangedate > (authorized_reqs.processing_period_enddate::DATE + rd.due_days::INT + rd.late_days::INT) 
        AND authorized_reqs.status = 'AUTHORIZED' THEN 'Unscheduled'
    WHEN authorized_reqs.statuschangedate < (authorized_reqs.processing_period_enddate::DATE + rd.due_days::INT + rd.late_days::INT) 
        AND authorized_reqs.statuschangedate >= (authorized_reqs.processing_period_enddate::DATE + rd.due_days::INT) 
        AND authorized_reqs.status = 'AUTHORIZED' THEN 'Late'
    ELSE 'Did not report' END as reporting_timeliness
FROM facilities f
LEFT JOIN (
    SELECT DISTINCT status_rank.facility_id, status_rank.req_id, status_rank.program_id, status_rank.processing_period_id, status_rank.statuschangedate, status_rank.status, status_rank.rank, status_rank.processing_period_enddate, status_rank.created_date, status_rank.modified_date, status_rank.emergency_status, status_rank.program_name, status_rank.program_active_status, status_rank.processing_schedule_name, status_rank.processing_period_name, status_rank.processing_period_startdate
    FROM (
        SELECT items.facility_id, items.program_id, items.req_id, items.processing_period_id, items.status, items.statuschangedate, items.processing_period_enddate, items.created_date, items.modified_date, items.emergency_status, items.program_name, items.program_active_status, items.processing_schedule_name, items.processing_period_name, items.processing_period_startdate,
        rank() OVER (PARTITION BY items.program_id, items.facility_id, items.processing_period_id ORDER BY items.statuschangedate DESC) AS rank
        FROM (
            SELECT r.facility_id, r.program_id, r.id as req_id, r.processing_period_id, r.processing_period_enddate, r.created_date, r.modified_date, r.emergency_status, r.program_name, r.program_active_status, r.processing_schedule_name, r.processing_period_name, r.processing_period_startdate,
            rh.status, rh.created_date AS statuschangedate
            FROM requisitions r
            LEFT JOIN (
                SELECT rh.created_date, rh.status, rh.requisition_id
                FROM requisitions_status_history rh
                WHERE rh.status = 'AUTHORIZED') rh
            ON rh.requisition_id::VARCHAR = r.id::VARCHAR) items
        ORDER BY items.facility_id, items.processing_period_id, items.statuschangedate DESC) status_rank
    WHERE status_rank.rank = 1) authorized_reqs
ON f.id::VARCHAR = authorized_reqs.facility_id::VARCHAR
LEFT JOIN reporting_dates rd ON f.country = rd.country
LEFT JOIN supported_programs sp ON sp.facilityid = f.id AND sp.programid::VARCHAR = authorized_reqs.program_id::VARCHAR
LEFT JOIN requisition_group_members rgm ON rgm.facilityid = f.id
LEFT JOIN requisition_group_program_schedules rgps ON rgps.requisitionGroupId = rgm.requisitionGroupId
LEFT JOIN facility_access fa ON fa.facility = authorized_reqs.facility_id::VARCHAR AND fa.program = authorized_reqs.program_id
ORDER BY authorized_reqs.processing_period_enddate DESC WITH DATA;


ALTER MATERIALIZED VIEW reporting_rate_and_timeliness OWNER TO postgres;

---
--- Name: adjustments; Type: TABLE; Schema: referencedata; Owner: postgres
---
CREATE MATERIALIZED VIEW adjustments AS
SELECT DISTINCT ON (li.requisition_line_item_id) li.requisition_line_item_id, 
r.id AS requisition_id, r.created_date, r.modified_date, r.emergency_status, 
r.supervisory_node, r.facility_name, r.facility_type_name, r.facility_operator_name, 
r.facilty_active_status, r.district_name, r.region_name, r.country_name, r.program_name, 
r.program_active_status, r.processing_period_name, li.orderable_id, li.product_code, 
li.full_product_name, li.trade_item_id, li.total_losses_and_adjustments,
sh.status, sh.author_id, sh.created_date AS status_history_created_date,
al.id AS adjustment_lines_id, al.quantity,
sar.name AS stock_adjustment_reason,
fa.facility, fa.program, fa.username
FROM requisitions r
LEFT JOIN requisition_line_item li ON r.id::VARCHAR = li.requisition_id
LEFT JOIN requisitions_status_history sh ON r.id::VARCHAR = sh.requisition_id
LEFT JOIN requisitions_adjustment_lines al ON li.requisition_line_item_id::VARCHAR = al.requisition_line_item_id
LEFT JOIN stock_adjustment_reasons sar ON sar.id::VARCHAR = al.reasonid::VARCHAR
LEFT JOIN facility_access fa ON fa.facility = r.facility_id AND fa.program = r.program_id
WHERE sh.status NOT IN ('SKIPPED', 'INITIATED', 'SUBMITTED')
ORDER BY li.requisition_line_item_id, r.modified_date DESC NULLS LAST WITH DATA;

ALTER MATERIALIZED VIEW adjustments OWNER TO postgres;


---
--- Name: stock_status_and_consumption; Type: TABLE; Schema: referencedata; Owner: postgres
---
CREATE MATERIALIZED VIEW stock_status_and_consumption AS
SELECT li.requisition_line_item_id, r.id, 
r.created_date as req_created_date, r.modified_date, r.emergency_status, r.supplying_facility, 
r.supervisory_node, r.facility_id, r.facility_code, r.facility_name, r.facilty_active_status, 
r.district_id, r.district_code, r.district_name, r.region_id, r.region_code, r.region_name, 
r.country_id, r.country_code, r.country_name, r.facility_type_id, r.facility_type_code, 
r.facility_type_name, r.facility_operator_id, r.facility_operator_code, r.facility_operator_name, 
r.program_id, r.program_code, r.program_name, r.program_active_status, r.processing_period_id, 
r.processing_period_name, r.processing_period_startdate, r.processing_period_enddate, 
r.processing_schedule_id, r.processing_schedule_code, r.processing_schedule_name,
li.requisition_id as li_req_id, li.orderable_id, li.product_code, li.full_product_name, 
li.trade_item_id, li.beginning_balance, li.total_consumed_quantity, li.average_consumption, 
li.total_losses_and_adjustments, li.stock_on_hand, li.total_stockout_days, li.max_periods_of_stock, 
li.calculated_order_quantity, li.requested_quantity, li.approved_quantity, li.packs_to_ship, 
li.price_per_pack, li.total_cost, li.total_received_quantity, sh.requisition_id as status_req_id, 
sh.status as req_status, sh.author_id, sh.created_date as status_date, fa.facility, fa.program, fa.username,
li.closing_balance, li.AMC, li.Consumption, li.adjusted_consumption,
li.order_quantity, f.status as facility_status, rd.due_days, rd.late_days,
li.combined_stockout, li.stock_status
FROM requisitions r 
LEFT JOIN requisitions_status_history sh ON r.id::VARCHAR = sh.requisition_id
LEFT JOIN reporting_dates rd ON r.country_name = rd.country
LEFT JOIN facilities f ON r.facility_id::VARCHAR = f.id::VARCHAR
LEFT JOIN facility_access fa ON fa.facility = f.id::VARCHAR AND fa.program = r.program_id
LEFT JOIN (SELECT DISTINCT(requisition_line_item_id), requisition_id,
orderable_id, product_code, full_product_name, 
trade_item_id, beginning_balance, total_consumed_quantity, average_consumption, 
total_losses_and_adjustments, stock_on_hand, total_stockout_days, max_periods_of_stock, 
calculated_order_quantity, requested_quantity, approved_quantity, packs_to_ship, 
price_per_pack, total_cost, total_received_quantity,
SUM(stock_on_hand) as closing_balance,
SUM(average_consumption) as AMC,
SUM(total_consumed_quantity) as Consumption,
SUM(adjusted_consumption) as adjusted_consumption,
SUM(approved_quantity) as order_quantity,
CASE 
    WHEN (SUM(stock_on_hand) = 0 OR SUM(total_stockout_days) > 0 OR SUM(beginning_balance) = 0 OR SUM(max_periods_of_stock) = 0) 
    THEN 1 ELSE 0 END as combined_stockout,
CASE
    WHEN SUM(max_periods_of_stock) > 6 THEN 'Overstocked'
    WHEN SUM(max_periods_of_stock) < 3 AND (SUM(stock_on_hand) = 0 OR SUM(total_stockout_days) > 0 OR SUM(beginning_balance) = 0 OR SUM(max_periods_of_stock) = 0) THEN 'Stocked Out'
    WHEN SUM(max_periods_of_stock) < 3 AND SUM(max_periods_of_stock) > 0 AND NOT(SUM(stock_on_hand) = 0 OR SUM(total_stockout_days) > 0 OR SUM(beginning_balance) = 0 OR SUM(max_periods_of_stock) = 0) THEN 'Understocked'
    WHEN SUM(max_periods_of_stock) = 0 AND NOT(SUM(stock_on_hand) = 0 OR SUM(total_stockout_days) > 0 OR SUM(beginning_balance) = 0 OR SUM(max_periods_of_stock) = 0) THEN 'Unknown'
    ELSE 'Adequately stocked' END as stock_status
FROM requisition_line_item
GROUP BY requisition_line_item_id, requisition_id, orderable_id, product_code, full_product_name, 
trade_item_id, beginning_balance, total_consumed_quantity, average_consumption, 
total_losses_and_adjustments, stock_on_hand, total_stockout_days, max_periods_of_stock, 
calculated_order_quantity, requested_quantity, approved_quantity, packs_to_ship, 
price_per_pack, total_cost, total_received_quantity) li ON r.id::VARCHAR = li.requisition_id WITH DATA;

ALTER MATERIALIZED VIEW stock_status_and_consumption OWNER TO postgres;