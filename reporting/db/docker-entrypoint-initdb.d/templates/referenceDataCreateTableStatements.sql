
-- Referencedata create table statements
-- Created by Craig Appl (cappl@ona.io)
-- Last Updated 31 August 2018
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
    id uuid NOT NULL UNIQUE,
    name character varying(255),
    classificationsystem character varying(255),
    classificationid character varying(255),
    parentid uuid
);


ALTER TABLE commodity_types OWNER TO postgres;

--
-- Name: facilities; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE facilities (
    id uuid NOT NULL UNIQUE,
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
    extradata jsonb,
    location public.geometry
);


ALTER TABLE facilities OWNER TO postgres;

--
-- Name: facility_operators; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE facility_operators (
    id uuid NOT NULL UNIQUE,
    code text,
    description text,
    displayorder integer,
    name character varying(255)
);


ALTER TABLE facility_operators OWNER TO postgres;

--
-- Name: ideal_stock_amounts; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE ideal_stock_amounts (
    id uuid NOT NULL UNIQUE,
    facilityid uuid,
    processingperiodid uuid,
    amount integer,
    commoditytypeid uuid
);


ALTER TABLE ideal_stock_amounts OWNER TO postgres;

--
-- Name: lots; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE lots (
    id uuid NOT NULL UNIQUE,
    lotcode character varying(255),
    expirationdate date,
    manufacturedate date,
    tradeitemid uuid,
    active boolean
);


ALTER TABLE lots OWNER TO postgres;

--
-- Name: orderables; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE orderables (
    id uuid NOT NULL UNIQUE,
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
    extradata jsonb
);


ALTER TABLE orderables OWNER TO postgres;

--
-- Name: processing_periods; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE processing_periods (
    id uuid NOT NULL UNIQUE,
    description text,
    enddate date,
    name character varying(255),
    startdate date,
    processingscheduleid uuid
);


ALTER TABLE processing_periods OWNER TO postgres;

--
-- Name: program_orderables; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE program_orderables (
    id uuid NOT NULL UNIQUE,
    active boolean,
    displayorder integer,
    dosesperpatient integer,
    fullsupply boolean,
    priceperpack numeric(19,2),
    orderabledisplaycategoryid uuid,
    orderableid uuid,
    programid uuid
);


ALTER TABLE program_orderables OWNER TO postgres;

--
-- Name: programs; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE programs (
    id uuid NOT NULL UNIQUE,
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
    requisitiongroupid uuid NOT NULL,
    facilityid uuid
);


ALTER TABLE requisition_group_members OWNER TO postgres;

--
-- Name: requisition_group_program_schedules; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE requisition_group_program_schedules (
    id uuid NOT NULL UNIQUE,
    directdelivery boolean,
    dropofffacilityid uuid,
    processingscheduleid uuid,
    programid uuid,
    requisitiongroupid uuid
);


ALTER TABLE requisition_group_program_schedules OWNER TO postgres;

--
-- Name: supported_programs; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE supported_programs (
    active boolean NOT NULL,
    startdate date,
    facilityid uuid,
    programid uuid,
    locallyfulfilled boolean DEFAULT false
);


ALTER TABLE supported_programs OWNER TO postgres;

--
-- Name: trade_item_classifications; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE trade_item_classifications (
    id uuid NOT NULL UNIQUE,
    classificationsystem character varying(255),
    classificationid character varying(255),
    tradeitemid uuid
);


ALTER TABLE trade_item_classifications OWNER TO postgres;

--
-- Name: trade_items; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE trade_items (
    id uuid NOT NULL UNIQUE,
    manufactureroftradeitem character varying(255),
    gtin text
);


ALTER TABLE trade_items OWNER TO postgres;

--
-- Name: rights; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE rights (
    id uuid NOT NULL UNIQUE,
    name character varying(255),
    type character varying(255)
);


ALTER TABLE rights OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE users (
    id uuid NOT NULL UNIQUE,
    username character varying(255),
    firstname character varying(255),
    lastname character varying(255),
    homefacilityid uuid,
    active boolean,
    loginRestricted boolean
);


ALTER TABLE users OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE roles (
    id uuid NOT NULL,
    name character varying(255),
    description character varying(255),
    rightsname character varying(255),
    rightsid uuid,
    rightstype character varying(255),
    count INT
);


ALTER TABLE roles OWNER TO postgres;

--
-- Name: supervisorynodes; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE supervisorynodes (
    id uuid NOT NULL UNIQUE,
    name character varying(255),
    code character varying(255),
    facilityname character varying(255),
    facilityid uuid,
    requisitiongroupname character varying(255),
    requisitiongroupid uuid,
    parentnodename character varying(255),
    parentnodeid uuid
);


ALTER TABLE supervisorynodes OWNER TO postgres;

--
-- Name: requisitiongroups; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE requisitiongroups (
    id uuid NOT NULL UNIQUE,
    name character varying(255),
    code character varying(255),
    facilityid uuid,
    supervisorynodeid uuid,
    supervisorynodename character varying(255),
    supervisorynodecode character varying(255),
    programname character varying(255),
    programid uuid,
    processingscheduleid uuid,
    directdelivery boolean
);


ALTER TABLE requisitiongroups OWNER TO postgres;

--
-- Name: supplylines; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE supplylines (
    id uuid NOT NULL UNIQUE,
    description character varying(255),
    supervisorynodeid uuid,
    programid uuid,
    supplyingfacilityid uuid
);


ALTER TABLE supplylines OWNER TO postgres;
