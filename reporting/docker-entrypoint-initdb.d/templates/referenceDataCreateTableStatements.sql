
-- Referencedata create table statements
-- Created by Craig Appl (cappl@ona.io)
-- Last Updated 29 July 2018
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
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    classificationsystem character varying(255) NOT NULL,
    classificationid character varying(255) NOT NULL,
    parentid uuid
);


ALTER TABLE commodity_types OWNER TO postgres;

--
-- Name: facilities; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE facilities (
    id uuid NOT NULL,
    active boolean NOT NULL,
    code text NOT NULL,
    comment text,
    description text,
    enabled boolean NOT NULL,
    godowndate date,
    golivedate date,
    name text,
    openlmisaccessible boolean,
    geographiczoneid uuid NOT NULL,
    operatedbyid uuid,
    typeid uuid NOT NULL,
    extradata jsonb,
    location public.geometry
);


ALTER TABLE facilities OWNER TO postgres;

--
-- Name: facility_operators; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE facility_operators (
    id uuid NOT NULL,
    code text NOT NULL,
    description text,
    displayorder integer,
    name text
);


ALTER TABLE facility_operators OWNER TO postgres;

--
-- Name: facility_type_approved_products; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE facility_type_approved_products (
    id uuid NOT NULL,
    emergencyorderpoint double precision,
    maxperiodsofstock double precision NOT NULL,
    minperiodsofstock double precision,
    facilitytypeid uuid NOT NULL,
    orderableid uuid NOT NULL,
    programid uuid NOT NULL
);


ALTER TABLE facility_type_approved_products OWNER TO postgres;

--
-- Name: facility_types; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE facility_types (
    id uuid NOT NULL,
    active boolean,
    code text NOT NULL,
    description text,
    displayorder integer,
    name text
);


ALTER TABLE facility_types OWNER TO postgres;

--
-- Name: geographic_levels; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE geographic_levels (
    id uuid NOT NULL,
    code text NOT NULL,
    levelnumber integer NOT NULL,
    name text
);


ALTER TABLE geographic_levels OWNER TO postgres;

--
-- Name: geographic_zones; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE geographic_zones (
    id uuid NOT NULL,
    catchmentpopulation integer,
    code text NOT NULL,
    latitude numeric(8,5),
    longitude numeric(8,5),
    name text,
    levelid uuid NOT NULL,
    parentid uuid,
    boundary public.geometry
);


ALTER TABLE geographic_zones OWNER TO postgres;

--
-- Name: ideal_stock_amounts; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE ideal_stock_amounts (
    id uuid NOT NULL,
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
    id uuid NOT NULL,
    lotcode text NOT NULL,
    expirationdate date,
    manufacturedate date,
    tradeitemid uuid NOT NULL,
    active boolean NOT NULL
);


ALTER TABLE lots OWNER TO postgres;

--
-- Name: orderable_display_categories; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE orderable_display_categories (
    id uuid NOT NULL,
    code character varying(255),
    displayname character varying(255),
    displayorder integer NOT NULL
);


ALTER TABLE orderable_display_categories OWNER TO postgres;

--
-- Name: orderable_identifiers; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE orderable_identifiers (
    key character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    orderableid uuid NOT NULL
);


ALTER TABLE orderable_identifiers OWNER TO postgres;

--
-- Name: orderables; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE orderables (
    id uuid NOT NULL,
    fullproductname character varying(255),
    packroundingthreshold bigint NOT NULL,
    netcontent bigint NOT NULL,
    code character varying(255),
    roundtozero boolean NOT NULL,
    description character varying(255),
    extradata jsonb,
    dispensableid uuid NOT NULL
);


ALTER TABLE orderables OWNER TO postgres;

--
-- Name: processing_periods; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE processing_periods (
    id uuid NOT NULL,
    description text,
    enddate date NOT NULL,
    name text NOT NULL,
    startdate date NOT NULL,
    processingscheduleid uuid NOT NULL
);


ALTER TABLE processing_periods OWNER TO postgres;

--
-- Name: processing_schedules; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE processing_schedules (
    id uuid NOT NULL,
    code text NOT NULL,
    description text,
    modifieddate timestamp with time zone,
    name text NOT NULL
);


ALTER TABLE processing_schedules OWNER TO postgres;

--
-- Name: program_orderables; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE program_orderables (
    id uuid NOT NULL,
    active boolean NOT NULL,
    displayorder integer NOT NULL,
    dosesperpatient integer,
    fullsupply boolean NOT NULL,
    priceperpack numeric(19,2),
    orderabledisplaycategoryid uuid NOT NULL,
    orderableid uuid NOT NULL,
    programid uuid NOT NULL
);


ALTER TABLE program_orderables OWNER TO postgres;

--
-- Name: programs; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE programs (
    id uuid NOT NULL,
    active boolean,
    code character varying(255),
    description text,
    name text,
    periodsskippable boolean NOT NULL,
    shownonfullsupplytab boolean,
    enabledatephysicalstockcountcompleted boolean NOT NULL,
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
    id uuid NOT NULL,
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
    id uuid NOT NULL,
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
    id uuid NOT NULL,
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
    id uuid NOT NULL,
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
    id uuid NOT NULL,
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

CREATE TABLE trade_item_classifications (
    id uuid NOT NULL,
    classificationsystem character varying(255) NOT NULL,
    classificationid character varying(255) NOT NULL,
    tradeitemid uuid NOT NULL
);


ALTER TABLE trade_item_classifications OWNER TO postgres;

--
-- Name: trade_items; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE trade_items (
    id uuid NOT NULL,
    manufactureroftradeitem character varying(255) NOT NULL,
    gtin text
);


ALTER TABLE trade_items OWNER TO postgres;

