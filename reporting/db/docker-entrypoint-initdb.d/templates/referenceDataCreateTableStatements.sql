
-- Referencedata create table statements
-- Created by Craig Appl (cappl@ona.io)
-- Last Updated 14 August 2018
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
    status boolean,
    code character varying(255),
    comment text,
    description text,
    enabled boolean,
    godowndate date,
    golivedate date,
    name character varying(255),
    openlmisaccessible boolean,
    district character varying(255),
    region character varying(255),
    country character varying(255),
    operator_code character varying(255),
    operator_name character varying(255),
    operator_id uuid,
    type character varying(255),
    extradata jsonb,
    location public.geometry
);


ALTER TABLE facilities OWNER TO postgres;

--
-- Name: facility_type_approved_products; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE facility_type_approved_products (
    id uuid NOT NULL UNIQUE,
    emergencyorderpoint double precision,
    maxperiodsofstock double precision NOT NULL,
    minperiodsofstock double precision,
    facilitytypeid uuid NOT NULL,
    orderableid uuid NOT NULL,
    programid uuid NOT NULL
);


ALTER TABLE facility_type_approved_products OWNER TO postgres;

--
-- Name: ideal_stock_amounts; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE ideal_stock_amounts (
    id uuid NOT NULL UNIQUE,
    facilityid uuid NOT NULL,
    processingperiodid uuid NOT NULL,
    amount integer,
    commoditytypeid uuid NOT NULL
);


ALTER TABLE ideal_stock_amounts OWNER TO postgres;

--
-- Name: lots; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE lots (
    id uuid NOT NULL UNIQUE,
    lotcode text NOT NULL,
    expirationdate date,
    manufacturedate date,
    tradeitemid uuid NOT NULL,
    active boolean NOT NULL
);


ALTER TABLE lots OWNER TO postgres;

--
-- Name: orderables; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE orderables (
    id uuid NOT NULL UNIQUE,
    fullproductname character varying(255),
    packroundingthreshold bigint,
    netcontent bigint,
    code character varying(255),
    roundtozero boolean,
    description character varying(255),
    extradata jsonb,
    dispensableid uuid,
    programid character varying(255),
    orderabledisplaydategoryid character varying(255),
    orderablecategorydisplayname character varying(255),
    orderablecategorydisplayorder character varying(255),
    active boolean,
    fullsupply boolean,
    displayorder int,
    dosesperpatient int,
    priceperpack double precision,
    tradeitemid character varying(255)
);


ALTER TABLE orderables OWNER TO postgres;

--
-- Name: processing_periods; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE processing_periods (
    id uuid NOT NULL UNIQUE,
    description text,
    enddate date NOT NULL,
    name text NOT NULL,
    startdate date NOT NULL,
    durationinmonths int,
    processingscheduleid uuid NOT NULL,
    processingschedulename character varying(255),
    processingschedulecode character varying(255)
);


ALTER TABLE processing_periods OWNER TO postgres;

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
    facilityid uuid NOT NULL
);


ALTER TABLE requisition_group_members OWNER TO postgres;

--
-- Name: requisition_group_program_schedules; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE requisition_group_program_schedules (
    id uuid NOT NULL UNIQUE,
    directdelivery boolean NOT NULL,
    dropofffacilityid uuid,
    processingscheduleid uuid NOT NULL,
    programid uuid NOT NULL,
    requisitiongroupid uuid NOT NULL
);


ALTER TABLE requisition_group_program_schedules OWNER TO postgres;

--
-- Name: requisition_groups; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE requisition_groups (
    id uuid NOT NULL UNIQUE,
    code text NOT NULL,
    description text,
    name text NOT NULL,
    supervisorynodeid uuid NOT NULL
);


ALTER TABLE requisition_groups OWNER TO postgres;

--
-- Name: stock_adjustment_reasons; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE stock_adjustment_reasons (
    id uuid NOT NULL UNIQUE,
    additive boolean,
    description text,
    displayorder integer,
    name text NOT NULL,
    programid uuid NOT NULL
);


ALTER TABLE stock_adjustment_reasons OWNER TO postgres;

--
-- Name: supervisory_nodes; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE supervisory_nodes (
    id uuid NOT NULL UNIQUE,
    code text NOT NULL,
    description text,
    name text NOT NULL,
    facilityid uuid,
    parentid uuid
);


ALTER TABLE supervisory_nodes OWNER TO postgres;

--
-- Name: supply_lines; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE supply_lines (
    id uuid NOT NULL UNIQUE,
    description text,
    programid uuid NOT NULL,
    supervisorynodeid uuid NOT NULL,
    supplyingfacilityid uuid NOT NULL
);


ALTER TABLE supply_lines OWNER TO postgres;

--
-- Name: supported_programs; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE supported_programs (
    active boolean NOT NULL,
    startdate date,
    facilityid uuid NOT NULL,
    programid uuid NOT NULL,
    locallyfulfilled boolean DEFAULT false NOT NULL
);


ALTER TABLE supported_programs OWNER TO postgres;

--
-- Name: trade_item_classifications; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE trade_items (
    id uuid NOT NULL UNIQUE,
    classificationsystem character varying(255),
    classificationid character varying(255),
    manufactureroftradeitem character varying(255)
);


ALTER TABLE trade_items OWNER TO postgres;
