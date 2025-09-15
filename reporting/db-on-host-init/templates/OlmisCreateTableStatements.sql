-- Olmis create table statements
-- Created by Craig Appl (cappl@ona.io)
-- Modified by A. Maritim (amaritim@ona.io) and J. Wambere (jwambere@ona.io)
-- Further modified by C. Ahn (chongsun.ahn@villagereach.org)
-- Further modified by Lesotho eLMIS team in April 2025
-- Last Updated 19 May 2020
--

--- On error (e.g. Table already exists) continue with the next statement
\set ON_ERROR_STOP off

--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';

--
-- Name: commodity_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_commodity_types (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    classificationsystem character varying(255) NOT NULL,
    classificationid character varying(255) NOT NULL,
    parentid uuid
);


ALTER TABLE public.kafka_commodity_types OWNER TO postgres;

--
-- Name: dispensable_attributes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_dispensable_attributes (
    dispensableid uuid NOT NULL,
    key text NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.kafka_dispensable_attributes OWNER TO postgres;

--
-- Name: dispensables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_dispensables (
    id uuid NOT NULL,
    type text DEFAULT 'default'::text NOT NULL
);


ALTER TABLE public.kafka_dispensables OWNER TO postgres;

--
-- Name: facilities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_facilities (
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
    location geometry
);


ALTER TABLE public.kafka_facilities OWNER TO postgres;

--
-- Name: facility_operators; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_facility_operators (
    id uuid NOT NULL,
    code text NOT NULL,
    description text,
    displayorder integer,
    name text
);


ALTER TABLE public.kafka_facility_operators OWNER TO postgres;

--
-- Name: facility_type_approved_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_facility_type_approved_products (
    id uuid NOT NULL,
    versionnumber bigint NOT NULL,
    orderableid uuid NOT NULL,
    programid uuid NOT NULL,
    facilitytypeid uuid NOT NULL,
    maxperiodsofstock double precision NOT NULL,
    minperiodsofstock double precision,
    emergencyorderpoint double precision,
    active boolean DEFAULT true NOT NULL,
    lastupdated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.kafka_facility_type_approved_products OWNER TO postgres;

--
-- Name: facility_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_facility_types (
    id uuid NOT NULL,
    active boolean,
    code text NOT NULL,
    description text,
    displayorder integer,
    name text
);


ALTER TABLE public.kafka_facility_types OWNER TO postgres;

--
-- Name: geographic_levels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_geographic_levels (
    id uuid NOT NULL,
    code text NOT NULL,
    levelnumber integer NOT NULL,
    name text
);


ALTER TABLE public.kafka_geographic_levels OWNER TO postgres;

--
-- Name: geographic_zones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_geographic_zones (
    id uuid NOT NULL,
    catchmentpopulation integer,
    code text NOT NULL,
    latitude numeric(8,5),
    longitude numeric(8,5),
    name text,
    levelid uuid NOT NULL,
    parentid uuid,
    boundary geometry,
    extradata jsonb
);


ALTER TABLE public.kafka_geographic_zones OWNER TO postgres;

--
-- Name: ideal_stock_amounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_ideal_stock_amounts (
    id uuid NOT NULL,
    facilityid uuid NOT NULL,
    processingperiodid uuid NOT NULL,
    amount integer,
    commoditytypeid uuid NOT NULL
);


ALTER TABLE public.kafka_ideal_stock_amounts OWNER TO postgres;

--
-- Name: lots; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_lots (
    id uuid NOT NULL,
    lotcode text NOT NULL,
    expirationdate date,
    manufacturedate date,
    tradeitemid uuid NOT NULL,
    active boolean NOT NULL
);


ALTER TABLE public.kafka_lots OWNER TO postgres;

--
-- Name: orderable_children; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_orderable_children (
    id uuid NOT NULL,
    parentid uuid NOT NULL,
    parentversionnumber bigint NOT NULL,
    orderableid uuid NOT NULL,
    orderableversionnumber bigint NOT NULL,
    quantity bigint NOT NULL
);


ALTER TABLE public.kafka_orderable_children OWNER TO postgres;

--
-- Name: orderable_display_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_orderable_display_categories (
    id uuid NOT NULL,
    code character varying(255),
    displayname character varying(255),
    displayorder integer NOT NULL
);


ALTER TABLE public.kafka_orderable_display_categories OWNER TO postgres;

--
-- Name: orderable_identifiers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_orderable_identifiers (
    key character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    orderableid uuid NOT NULL,
    orderableversionnumber bigint NOT NULL
);


ALTER TABLE public.kafka_orderable_identifiers OWNER TO postgres;

--
-- Name: orderables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_orderables (
    id uuid NOT NULL,
    fullproductname character varying(255),
    packroundingthreshold bigint NOT NULL,
    netcontent bigint NOT NULL,
    code character varying(255),
    roundtozero boolean NOT NULL,
    description character varying(255),
    extradata jsonb,
    dispensableid uuid NOT NULL,
    versionnumber bigint NOT NULL,
    lastupdated timestamp with time zone DEFAULT now() NOT NULL,
    minimumtemperaturevalue double precision,
    minimumtemperaturecode character varying(30),
    maximumtemperaturevalue double precision,
    maximumtemperaturecode character varying(30),
    inboxcubedimensionvalue double precision,
    inboxcubedimensioncode character varying(30)
);


ALTER TABLE public.kafka_orderables OWNER TO postgres;

--
-- Name: processing_periods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_processing_periods (
    id uuid NOT NULL,
    description text,
    enddate date NOT NULL,
    name text NOT NULL,
    startdate date NOT NULL,
    processingscheduleid uuid NOT NULL,
    extradata jsonb
);


ALTER TABLE public.kafka_processing_periods OWNER TO postgres;

--
-- Name: processing_schedules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_processing_schedules (
    id uuid NOT NULL,
    code text NOT NULL,
    description text,
    modifieddate timestamp with time zone,
    name text NOT NULL
);


ALTER TABLE public.kafka_processing_schedules OWNER TO postgres;

--
-- Name: program_orderables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_program_orderables (
    id uuid NOT NULL,
    active boolean NOT NULL,
    displayorder integer NOT NULL,
    dosesperpatient integer,
    fullsupply boolean NOT NULL,
    priceperpack numeric(19,2),
    orderabledisplaycategoryid uuid NOT NULL,
    orderableid uuid NOT NULL,
    programid uuid NOT NULL,
    orderableversionnumber bigint NOT NULL
);


ALTER TABLE public.kafka_program_orderables OWNER TO postgres;

--
-- Name: programs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_programs (
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


ALTER TABLE public.kafka_programs OWNER TO postgres;

--
-- Name: requisition_group_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_requisition_group_members (
    requisitiongroupid uuid NOT NULL,
    facilityid uuid NOT NULL
);


ALTER TABLE public.kafka_requisition_group_members OWNER TO postgres;

--
-- Name: requisition_group_program_schedules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_requisition_group_program_schedules (
    id uuid NOT NULL,
    directdelivery boolean NOT NULL,
    dropofffacilityid uuid,
    processingscheduleid uuid NOT NULL,
    programid uuid NOT NULL,
    requisitiongroupid uuid NOT NULL
);


ALTER TABLE public.kafka_requisition_group_program_schedules OWNER TO postgres;

--
-- Name: requisition_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_requisition_groups (
    id uuid NOT NULL,
    code text NOT NULL,
    description text,
    name text NOT NULL,
    supervisorynodeid uuid NOT NULL
);


ALTER TABLE public.kafka_requisition_groups OWNER TO postgres;

--
-- Name: right_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_right_assignments (
    id uuid NOT NULL,
    rightname text NOT NULL,
    facilityid uuid,
    programid uuid,
    userid uuid NOT NULL
);


ALTER TABLE public.kafka_right_assignments OWNER TO postgres;

--
-- Name: right_attachments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_right_attachments (
    rightid uuid NOT NULL,
    attachmentid uuid NOT NULL
);


ALTER TABLE public.kafka_right_attachments OWNER TO postgres;

--
-- Name: rights; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_rights (
    id uuid NOT NULL,
    description text,
    name text NOT NULL,
    type text NOT NULL
);


ALTER TABLE public.kafka_rights OWNER TO postgres;

--
-- Name: role_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_role_assignments (
    type character varying(31) NOT NULL,
    id uuid NOT NULL,
    roleid uuid,
    userid uuid,
    warehouseid uuid,
    programid uuid,
    supervisorynodeid uuid
);


ALTER TABLE public.kafka_role_assignments OWNER TO postgres;

--
-- Name: role_rights; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_role_rights (
    roleid uuid NOT NULL,
    rightid uuid NOT NULL
);


ALTER TABLE public.kafka_role_rights OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_roles (
    id uuid NOT NULL,
    description text,
    name text NOT NULL
);


ALTER TABLE public.kafka_roles OWNER TO postgres;

--
-- Name: service_accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_service_accounts (
    id uuid NOT NULL,
    createdby uuid NOT NULL,
    createddate timestamp with time zone NOT NULL
);


ALTER TABLE public.kafka_service_accounts OWNER TO postgres;

--
-- Name: supervisory_nodes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_supervisory_nodes (
    id uuid NOT NULL,
    code text NOT NULL,
    description text,
    name text NOT NULL,
    facilityid uuid,
    parentid uuid,
    extradata jsonb,
    partnerid uuid
);


ALTER TABLE public.kafka_supervisory_nodes OWNER TO postgres;

--
-- Name: supply_lines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_supply_lines (
    id uuid NOT NULL,
    description text,
    programid uuid NOT NULL,
    supervisorynodeid uuid NOT NULL,
    supplyingfacilityid uuid NOT NULL
);


ALTER TABLE public.kafka_supply_lines OWNER TO postgres;

--
-- Name: supply_partner_association_facilities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_supply_partner_association_facilities (
    supplypartnerassociationid uuid NOT NULL,
    facilityid uuid NOT NULL
);


ALTER TABLE public.kafka_supply_partner_association_facilities OWNER TO postgres;

--
-- Name: supply_partner_association_orderables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_supply_partner_association_orderables (
    supplypartnerassociationid uuid NOT NULL,
    orderableid uuid NOT NULL,
    orderableversionnumber bigint NOT NULL
);


ALTER TABLE public.kafka_supply_partner_association_orderables OWNER TO postgres;

--
-- Name: supply_partner_associations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_supply_partner_associations (
    id uuid NOT NULL,
    programid uuid NOT NULL,
    supervisorynodeid uuid NOT NULL,
    supplypartnerid uuid NOT NULL
);


ALTER TABLE public.kafka_supply_partner_associations OWNER TO postgres;

--
-- Name: supply_partners; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_supply_partners (
    id uuid NOT NULL,
    name text NOT NULL,
    code text NOT NULL
);


ALTER TABLE public.kafka_supply_partners OWNER TO postgres;

--
-- Name: supported_programs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_supported_programs (
    active boolean NOT NULL,
    startdate date,
    facilityid uuid NOT NULL,
    programid uuid NOT NULL,
    locallyfulfilled boolean DEFAULT false NOT NULL
);


ALTER TABLE public.kafka_supported_programs OWNER TO postgres;

--
-- Name: system_notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_system_notifications (
    id uuid NOT NULL,
    title character varying(255),
    message text NOT NULL,
    startdate timestamp with time zone,
    createddate timestamp with time zone NOT NULL,
    expirydate timestamp with time zone,
    active boolean DEFAULT true NOT NULL,
    authorid uuid NOT NULL
);


ALTER TABLE public.kafka_system_notifications OWNER TO postgres;

--
-- Name: trade_item_classifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_trade_item_classifications (
    id uuid NOT NULL,
    classificationsystem character varying(255) NOT NULL,
    classificationid character varying(255) NOT NULL,
    tradeitemid uuid NOT NULL
);


ALTER TABLE public.kafka_trade_item_classifications OWNER TO postgres;

--
-- Name: trade_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_trade_items (
    id uuid NOT NULL,
    manufactureroftradeitem character varying(255) NOT NULL,
    gtin text
);


ALTER TABLE public.kafka_trade_items OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_users (
    id uuid NOT NULL,
    active boolean DEFAULT false NOT NULL,
    allownotify boolean DEFAULT true,
    email character varying(255),
    extradata jsonb,
    firstname text NOT NULL,
    lastname text NOT NULL,
    timezone character varying(255),
    username text NOT NULL,
    verified boolean DEFAULT false NOT NULL,
    homefacilityid uuid,
    jobtitle character varying(255),
    phonenumber character varying(255)
);


ALTER TABLE public.kafka_users OWNER TO postgres;

-- Kafka Stock Cards Table
CREATE TABLE public.kafka_stock_cards (
    id uuid NOT NULL,
    facilityid uuid NOT NULL,
    lotid uuid,
    orderableid uuid NOT NULL,
    programid uuid NOT NULL,
    origineventid uuid NOT NULL,
    isshowed boolean DEFAULT true,
    isactive boolean DEFAULT true
);

-- Kafka Stock Card Line Items Table
CREATE TABLE public.kafka_stock_card_line_items (
    id uuid NOT NULL,
    stockcardid uuid NOT NULL,
    quantity integer NOT NULL,
    reasonid uuid,
    occurreddate date NOT NULL,
    processeddate timestamp without time zone NOT NULL,
    destinationfreetext character varying(255),
    documentnumber character varying(255),
    reasonfreetext character varying(255),
    signature character varying(255),
    sourcefreetext character varying(255),
    userid uuid NOT NULL,
    destinationid uuid,
    origineventid uuid NOT NULL,
    sourceid uuid,
    cartonnumber character varying(255),
    invoicenumber character varying(255),
    referencenumber character varying(255),
    unitprice double precision,
    extradata jsonb
);


-- Kafka Stock Card Line Item Reasons Table
CREATE TABLE public.kafka_stock_card_line_item_reasons (
    id uuid NOT NULL,
    name text NOT NULL,
    description text,
    isfreetextallowed boolean NOT NULL,
    reasoncategory text NOT NULL,
    reasontype text NOT NULL
);

-- Ownership
ALTER TABLE public.kafka_stock_cards OWNER TO postgres;
ALTER TABLE public.kafka_stock_card_line_items OWNER TO postgres;
ALTER TABLE public.kafka_stock_card_line_item_reasons OWNER TO postgres;

ALTER TABLE ONLY public.kafka_stock_cards
    ADD CONSTRAINT kafka_stock_cards_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.kafka_stock_card_line_items
    ADD CONSTRAINT kafka_stock_card_line_items_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.kafka_stock_card_line_item_reasons
    ADD CONSTRAINT kafka_stock_card_line_item_reasons_pkey PRIMARY KEY (id);

-- ==========================================
-- Indexes for Kafka Stock Cards Table
-- ==========================================

-- Index to speed up lookups by facility ID
CREATE INDEX kafka_stock_cards_facilityid_idx 
ON public.kafka_stock_cards USING btree (facilityid);

-- Index to optimize queries by orderable ID
CREATE INDEX kafka_stock_cards_orderableid_idx 
ON public.kafka_stock_cards USING btree (orderableid);

-- Index to improve performance for program-based searches
CREATE INDEX kafka_stock_cards_programid_idx 
ON public.kafka_stock_cards USING btree (programid);

-- Index to quickly retrieve records based on lot ID
CREATE INDEX kafka_stock_cards_lotid_idx 
ON public.kafka_stock_cards USING btree (lotid);

-- Index to enhance performance when querying by origin event ID
CREATE INDEX kafka_stock_cards_origineventid_idx 
ON public.kafka_stock_cards USING btree (origineventid);

-- ==========================================
-- Indexes for Kafka Stock Card Line Items Table
-- ==========================================

-- Index to speed up lookups by stock card ID
CREATE INDEX kafka_stock_card_line_items_stockcardid_idx 
ON public.kafka_stock_card_line_items USING btree (stockcardid);

-- Index to improve performance when searching by reason ID
CREATE INDEX kafka_stock_card_line_items_reasonid_idx 
ON public.kafka_stock_card_line_items USING btree (reasonid);

-- Index to optimize user-based searches
CREATE INDEX kafka_stock_card_line_items_userid_idx 
ON public.kafka_stock_card_line_items USING btree (userid);

-- Index to enhance performance for origin event ID searches
CREATE INDEX kafka_stock_card_line_items_origineventid_idx 
ON public.kafka_stock_card_line_items USING btree (origineventid);

-- ==========================================
-- Indexes for Kafka Stock Card Line Item Reasons Table
-- ==========================================

-- Index to speed up lookups by reason name
CREATE INDEX kafka_stock_card_line_item_reasons_name_idx 
ON public.kafka_stock_card_line_item_reasons USING btree (name);


--
-- Name: commodity_types commodity_types_classificationsystem_classificationid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_commodity_types
    ADD CONSTRAINT commodity_types_classificationsystem_classificationid_key UNIQUE (classificationsystem, classificationid);


--
-- Name: commodity_types commodity_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_commodity_types
    ADD CONSTRAINT commodity_types_pkey PRIMARY KEY (id);


--
-- Name: dispensable_attributes dispensable_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_dispensable_attributes
    ADD CONSTRAINT dispensable_attributes_pkey PRIMARY KEY (dispensableid, key);


--
-- Name: dispensables dispensables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_dispensables
    ADD CONSTRAINT dispensables_pkey PRIMARY KEY (id);


--
-- Name: facilities facilities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_facilities
    ADD CONSTRAINT facilities_pkey PRIMARY KEY (id);


--
-- Name: facility_operators facility_operators_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_facility_operators
    ADD CONSTRAINT facility_operators_pkey PRIMARY KEY (id);


--
-- Name: facility_type_approved_products facility_type_approved_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_facility_type_approved_products
    ADD CONSTRAINT facility_type_approved_products_pkey PRIMARY KEY (id, versionnumber);


--
-- Name: facility_types facility_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_facility_types
    ADD CONSTRAINT facility_types_pkey PRIMARY KEY (id);


--
-- Name: geographic_levels geographic_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_geographic_levels
    ADD CONSTRAINT geographic_levels_pkey PRIMARY KEY (id);


--
-- Name: geographic_zones geographic_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_geographic_zones
    ADD CONSTRAINT geographic_zones_pkey PRIMARY KEY (id);


--
-- Name: ideal_stock_amounts ideal_stock_amounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_ideal_stock_amounts
    ADD CONSTRAINT ideal_stock_amounts_pkey PRIMARY KEY (id);


--
-- Name: lots lots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_lots
    ADD CONSTRAINT lots_pkey PRIMARY KEY (id);


--
-- Name: orderable_children orderable_children_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_orderable_children
    ADD CONSTRAINT orderable_children_pkey PRIMARY KEY (id);


--
-- Name: orderable_display_categories orderable_display_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_orderable_display_categories
    ADD CONSTRAINT orderable_display_categories_pkey PRIMARY KEY (id);


--
-- Name: orderables orderables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_orderables
    ADD CONSTRAINT orderables_pkey PRIMARY KEY (id, versionnumber);


--
-- Name: right_assignments permission_strings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_right_assignments
    ADD CONSTRAINT permission_strings_pkey PRIMARY KEY (id);


--
-- Name: processing_periods processing_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_processing_periods
    ADD CONSTRAINT processing_periods_pkey PRIMARY KEY (id);


--
-- Name: processing_schedules processing_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_processing_schedules
    ADD CONSTRAINT processing_schedules_pkey PRIMARY KEY (id);


--
-- Name: program_orderables program_orderables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_program_orderables
    ADD CONSTRAINT program_orderables_pkey PRIMARY KEY (id);


--
-- Name: programs programs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_programs
    ADD CONSTRAINT programs_pkey PRIMARY KEY (id);


--
-- Name: requisition_group_members requisition_group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_requisition_group_members
    ADD CONSTRAINT requisition_group_members_pkey PRIMARY KEY (requisitiongroupid, facilityid);


--
-- Name: requisition_group_program_schedules requisition_group_program_schedule_unique_program_requisitiongr; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_requisition_group_program_schedules
    ADD CONSTRAINT requisition_group_program_schedule_unique_program_requisitiongr UNIQUE (requisitiongroupid, programid) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: requisition_group_program_schedules requisition_group_program_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_requisition_group_program_schedules
    ADD CONSTRAINT requisition_group_program_schedules_pkey PRIMARY KEY (id);


--
-- Name: requisition_groups requisition_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_requisition_groups
    ADD CONSTRAINT requisition_groups_pkey PRIMARY KEY (id);


--
-- Name: right_assignments right_assignment_unq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_right_assignments
    ADD CONSTRAINT right_assignment_unq UNIQUE (rightname, facilityid, programid, userid);


--
-- Name: right_attachments right_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_right_attachments
    ADD CONSTRAINT right_attachments_pkey PRIMARY KEY (rightid, attachmentid);


--
-- Name: rights rights_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_rights
    ADD CONSTRAINT rights_pkey PRIMARY KEY (id);


--
-- Name: role_assignments role_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_role_assignments
    ADD CONSTRAINT role_assignments_pkey PRIMARY KEY (id);


--
-- Name: role_rights role_rights_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_role_rights
    ADD CONSTRAINT role_rights_pkey PRIMARY KEY (roleid, rightid);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: service_accounts service_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_service_accounts
    ADD CONSTRAINT service_accounts_pkey PRIMARY KEY (id);


--
-- Name: supervisory_nodes supervisory_nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_supervisory_nodes
    ADD CONSTRAINT supervisory_nodes_pkey PRIMARY KEY (id);


--
-- Name: supply_lines supply_line_unique_program_supervisory_node; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_supply_lines
    ADD CONSTRAINT supply_line_unique_program_supervisory_node UNIQUE (supervisorynodeid, programid);


--
-- Name: supply_lines supply_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_supply_lines
    ADD CONSTRAINT supply_lines_pkey PRIMARY KEY (id);


--
-- Name: supply_partner_association_facilities supply_partner_association_facilities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_supply_partner_association_facilities
    ADD CONSTRAINT supply_partner_association_facilities_pkey PRIMARY KEY (supplypartnerassociationid, facilityid);


--
-- Name: supply_partner_association_orderables supply_partner_association_orderables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_supply_partner_association_orderables
    ADD CONSTRAINT supply_partner_association_orderables_pkey PRIMARY KEY (supplypartnerassociationid, orderableid, orderableversionnumber);


--
-- Name: supply_partner_associations supply_partner_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_supply_partner_associations
    ADD CONSTRAINT supply_partner_associations_pkey PRIMARY KEY (id);


--
-- Name: supply_partners supply_partners_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_supply_partners
    ADD CONSTRAINT supply_partners_pkey PRIMARY KEY (id);


--
-- Name: supported_programs supported_programs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_supported_programs
    ADD CONSTRAINT supported_programs_pkey PRIMARY KEY (facilityid, programid);


--
-- Name: system_notifications system_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_system_notifications
    ADD CONSTRAINT system_notifications_pkey PRIMARY KEY (id);


--
-- Name: trade_items trade_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_trade_items
    ADD CONSTRAINT trade_items_pkey PRIMARY KEY (id);


--
-- Name: rights uk_4f64k9vkx833wfpw8n25x2602; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_rights
    ADD CONSTRAINT uk_4f64k9vkx833wfpw8n25x2602 UNIQUE (name);


--
-- Name: users uk_6dotkott2kjsp8vw4d0m25fb7; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_users
    ADD CONSTRAINT uk_6dotkott2kjsp8vw4d0m25fb7 UNIQUE (email);


--
-- Name: supervisory_nodes uk_9vforn7hxhuinr8bmu0vkad3v; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_supervisory_nodes
    ADD CONSTRAINT uk_9vforn7hxhuinr8bmu0vkad3v UNIQUE (code);


--
-- Name: geographic_levels uk_by9o3bl6rafeuane589514s2v; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_geographic_levels
    ADD CONSTRAINT uk_by9o3bl6rafeuane589514s2v UNIQUE (code);


--
-- Name: facility_operators uk_g7ooo22v3vokh2qrqbxw7uaps; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_facility_operators
    ADD CONSTRAINT uk_g7ooo22v3vokh2qrqbxw7uaps UNIQUE (code);


--
-- Name: geographic_zones uk_jpns3ahywgm4k52rdfm08m9k0; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_geographic_zones
    ADD CONSTRAINT uk_jpns3ahywgm4k52rdfm08m9k0 UNIQUE (code);


--
-- Name: requisition_groups uk_nrqjt84p9wmrm1qmr7nokj8sg; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_requisition_groups
    ADD CONSTRAINT uk_nrqjt84p9wmrm1qmr7nokj8sg UNIQUE (code);


--
-- Name: trade_items uk_tradeitems_gtin; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_trade_items
    ADD CONSTRAINT uk_tradeitems_gtin UNIQUE (gtin);


--
-- Name: lots unq_lotcode_tradeitemid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_lots
    ADD CONSTRAINT unq_lotcode_tradeitemid UNIQUE (lotcode, tradeitemid);


--
-- Name: orderable_children unq_orderable_parent_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_orderable_children
    ADD CONSTRAINT unq_orderable_parent_id UNIQUE (orderableid, orderableversionnumber, parentid, parentversionnumber);


--
-- Name: orderable_identifiers unq_orderableid_orderableversionid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_orderable_identifiers
    ADD CONSTRAINT unq_orderableid_orderableversionid_key UNIQUE (orderableid, orderableversionnumber, key);


--
-- Name: orderables unq_productcode_versionid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_orderables
    ADD CONSTRAINT unq_productcode_versionid UNIQUE (code, versionnumber);


--
-- Name: programs unq_program_code; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_programs
    ADD CONSTRAINT unq_program_code UNIQUE (code);


--
-- Name: trade_item_classifications unq_trade_item_classifications_system; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_trade_item_classifications
    ADD CONSTRAINT unq_trade_item_classifications_system UNIQUE (tradeitemid, classificationsystem);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: facilities_geographiczoneid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilities_geographiczoneid_idx ON public.kafka_facilities USING btree (geographiczoneid);


--
-- Name: facilities_location_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilities_location_idx ON public.kafka_facilities USING gist (location);


--
-- Name: facilities_operatedbyid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilities_operatedbyid_idx ON public.kafka_facilities USING btree (operatedbyid);


--
-- Name: facilities_typeid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilities_typeid_idx ON public.kafka_facilities USING btree (typeid);


--
-- Name: facility_type_approved_products_facilitytypeid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facility_type_approved_products_facilitytypeid_idx ON public.kafka_facility_type_approved_products USING btree (facilitytypeid);


--
-- Name: facility_type_approved_products_orderableid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facility_type_approved_products_orderableid_idx ON public.kafka_facility_type_approved_products USING btree (orderableid);


--
-- Name: facility_type_approved_products_programid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facility_type_approved_products_programid_idx ON public.kafka_facility_type_approved_products USING btree (programid);


--
-- Name: ideal_stock_amounts_commoditytypeid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ideal_stock_amounts_commoditytypeid_idx ON public.kafka_ideal_stock_amounts USING btree (commoditytypeid);


--
-- Name: ideal_stock_amounts_facilityid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ideal_stock_amounts_facilityid_idx ON public.kafka_ideal_stock_amounts USING btree (facilityid);


--
-- Name: ideal_stock_amounts_processingperiodid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ideal_stock_amounts_processingperiodid_idx ON public.kafka_ideal_stock_amounts USING btree (processingperiodid);


--
-- Name: idx_orderable_children_orderable; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orderable_children_orderable ON public.kafka_orderable_children USING btree (orderableid, orderableversionnumber);


--
-- Name: idx_orderable_children_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orderable_children_parent ON public.kafka_orderable_children USING btree (parentid, parentversionnumber);


--
-- Name: orderables_fullproductname_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX orderables_fullproductname_idx ON public.kafka_orderables USING btree (fullproductname);


--
-- Name: processing_schedule_code_unique_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX processing_schedule_code_unique_idx ON public.kafka_processing_schedules USING btree (lower(code));


--
-- Name: processing_schedule_name_unique_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX processing_schedule_name_unique_idx ON public.kafka_processing_schedules USING btree (lower(name));


--
-- Name: program_orderables_orderabledisplaycategoryid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX program_orderables_orderabledisplaycategoryid_idx ON public.kafka_program_orderables USING btree (orderabledisplaycategoryid);


--
-- Name: program_orderables_orderableid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX program_orderables_orderableid_idx ON public.kafka_program_orderables USING btree (orderableid);


--
-- Name: program_orderables_orderableid_idx1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX program_orderables_orderableid_idx1 ON public.kafka_program_orderables USING btree (orderableid);


--
-- Name: program_orderables_programid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX program_orderables_programid_idx ON public.kafka_program_orderables USING btree (programid);


--
-- Name: right_assignments_programid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX right_assignments_programid_idx ON public.kafka_right_assignments USING btree (programid);


--
-- Name: right_assignments_userid_rightname_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX right_assignments_userid_rightname_idx ON public.kafka_right_assignments USING btree (userid, rightname);


--
-- Name: role_assignments_userid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX role_assignments_userid_idx ON public.kafka_role_assignments USING btree (userid);


--
-- Name: supervisory_nodes_parentid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX supervisory_nodes_parentid_idx ON public.kafka_supervisory_nodes USING btree (parentid);


--
-- Name: supported_programs_facilityid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX supported_programs_facilityid_idx ON public.kafka_supported_programs USING btree (facilityid);


--
-- Name: supported_programs_programid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX supported_programs_programid_idx ON public.kafka_supported_programs USING btree (programid);


--
-- Name: system_notifications_active_authorid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX system_notifications_active_authorid_idx ON public.kafka_system_notifications USING btree (active, authorid);


--
-- Name: unq_case_insensetive_supervisory_node_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unq_case_insensetive_supervisory_node_name ON public.kafka_supervisory_nodes USING btree (lower(name));


--
-- Name: unq_facility_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unq_facility_code ON public.kafka_facilities USING btree (lower(code));


--
-- Name: unq_facility_type_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unq_facility_type_code ON public.kafka_facility_types USING btree (lower(code));


--
-- Name: unq_ftap; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unq_ftap ON public.kafka_facility_type_approved_products USING btree (facilitytypeid, orderableid, programid) WHERE (active IS TRUE);


--
-- Name: unq_programid_orderableid_orderableversionnumber; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unq_programid_orderableid_orderableversionnumber ON public.kafka_program_orderables USING btree (programid, orderableid, orderableversionnumber) WHERE (active = true);


--
-- Name: unq_role_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unq_role_name ON public.kafka_roles USING btree (lower(name));


--
-- Name: unq_supervisory_node_case_insesetive_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unq_supervisory_node_case_insesetive_code ON public.kafka_supervisory_nodes USING btree (lower(code));


--
-- Name: unq_supply_partner_association_programid_supervisorynodeid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unq_supply_partner_association_programid_supervisorynodeid ON public.kafka_supply_partner_associations USING btree (programid, supervisorynodeid, supplypartnerid);


--
-- Name: unq_supply_partner_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unq_supply_partner_code ON public.kafka_supply_partners USING btree (lower(code));


--
-- Name: unq_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unq_username ON public.kafka_users USING btree (lower(username));


--
-- Name: available_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_available_products (
    requisitionid uuid NOT NULL,
    orderableid uuid,
    orderableversionnumber bigint,
    facilitytypeapprovedproductid uuid,
    facilitytypeapprovedproductversionnumber bigint
);


ALTER TABLE public.kafka_available_products OWNER TO postgres;

--
-- Name: available_requisition_column_options; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_available_requisition_column_options (
    id uuid NOT NULL,
    optionlabel character varying(255) NOT NULL,
    optionname character varying(255) NOT NULL,
    columnid uuid NOT NULL
);


ALTER TABLE public.kafka_available_requisition_column_options OWNER TO postgres;

--
-- Name: available_requisition_column_sources; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_available_requisition_column_sources (
    columnid uuid NOT NULL,
    value character varying(255)
);


ALTER TABLE public.kafka_available_requisition_column_sources OWNER TO postgres;

--
-- Name: available_requisition_columns; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_available_requisition_columns (
    id uuid NOT NULL,
    canbechangedbyuser boolean,
    canchangeorder boolean,
    columntype character varying(255) NOT NULL,
    definition text,
    indicator character varying(255),
    isdisplayrequired boolean,
    label character varying(255),
    mandatory boolean,
    name character varying(255),
    supportstag boolean DEFAULT false
);


ALTER TABLE public.kafka_available_requisition_columns OWNER TO postgres;

--
-- Name: columns_maps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_columns_maps (
    requisitiontemplateid uuid NOT NULL,
    requisitioncolumnid uuid NOT NULL,
    definition text,
    displayorder integer NOT NULL,
    indicator character varying(255),
    isdisplayed boolean,
    label character varying(255),
    name character varying(255),
    requisitioncolumnoptionid uuid,
    source integer NOT NULL,
    key character varying(255) NOT NULL,
    tag character varying(255)
);


ALTER TABLE public.kafka_columns_maps OWNER TO postgres;

--
-- Name: configuration_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_configuration_settings (
    key character varying(255) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.kafka_configuration_settings OWNER TO postgres;

--
-- Name: jasper_template_parameter_dependencies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_jasper_template_parameter_dependencies (
    id uuid NOT NULL,
    parameterid uuid NOT NULL,
    dependency text NOT NULL,
    placeholder text NOT NULL
);


ALTER TABLE public.kafka_jasper_template_parameter_dependencies OWNER TO postgres;

--
-- Name: jasper_templates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_jasper_templates (
    id uuid NOT NULL,
    data bytea,
    description text,
    name text NOT NULL,
    type text
);


ALTER TABLE public.kafka_jasper_templates OWNER TO postgres;

--
-- Name: jaspertemplateparameter_options; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_jaspertemplateparameter_options (
    jaspertemplateparameterid uuid NOT NULL,
    options character varying(255)
);


ALTER TABLE public.kafka_jaspertemplateparameter_options OWNER TO postgres;

--
-- Name: previous_adjusted_consumptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_previous_adjusted_consumptions (
    requisitionlineitemid uuid NOT NULL,
    previousadjustedconsumption integer
);


ALTER TABLE public.kafka_previous_adjusted_consumptions OWNER TO postgres;

--
-- Name: requisition_line_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_requisition_line_items (
    id uuid NOT NULL,
    adjustedconsumption integer,
    approvedquantity integer,
    averageconsumption integer,
    beginningbalance integer,
    calculatedorderquantity integer,
    maxperiodsofstock numeric(19,2),
    maximumstockquantity integer,
    nonfullsupply boolean,
    numberofnewpatientsadded integer,
    orderableid uuid,
    packstoship bigint,
    priceperpack numeric(19,2),
    remarks character varying(250),
    requestedquantity integer,
    requestedquantityexplanation character varying(255),
    skipped boolean,
    stockonhand integer,
    total integer,
    totalconsumedquantity integer,
    totalcost numeric(19,2),
    totallossesandadjustments integer,
    totalreceivedquantity integer,
    totalstockoutdays integer,
    requisitionid uuid,
    idealstockamount integer,
    calculatedorderquantityisa integer,
    additionalquantityrequired integer,
    orderableversionnumber bigint,
    facilitytypeapprovedproductid uuid,
    facilitytypeapprovedproductversionnumber bigint
);


ALTER TABLE public.kafka_requisition_line_items OWNER TO postgres;

--
-- Name: requisition_permission_strings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_requisition_permission_strings (
    id uuid NOT NULL,
    requisitionid uuid NOT NULL,
    permissionstring text NOT NULL
);


ALTER TABLE public.kafka_requisition_permission_strings OWNER TO postgres;

--
-- Name: requisition_template_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_requisition_template_assignments (
    id uuid NOT NULL,
    programid uuid NOT NULL,
    facilitytypeid uuid,
    templateid uuid NOT NULL
);


ALTER TABLE public.kafka_requisition_template_assignments OWNER TO postgres;

--
-- Name: requisition_templates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_requisition_templates (
    id uuid NOT NULL,
    createddate timestamp with time zone,
    modifieddate timestamp with time zone,
    numberofperiodstoaverage integer,
    populatestockonhandfromstockcards boolean DEFAULT false NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.kafka_requisition_templates OWNER TO postgres;

--
-- Name: requisitions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_requisitions (
    id uuid NOT NULL,
    createddate timestamp with time zone,
    modifieddate timestamp with time zone,
    draftstatusmessage text,
    emergency boolean NOT NULL,
    facilityid uuid NOT NULL,
    numberofmonthsinperiod integer NOT NULL,
    processingperiodid uuid NOT NULL,
    programid uuid NOT NULL,
    status character varying(255) NOT NULL,
    supervisorynodeid uuid,
    supplyingfacilityid uuid,
    templateid uuid NOT NULL,
    datephysicalstockcountcompleted date,
    version bigint DEFAULT 0,
    reportonly boolean,
    extradata jsonb
);


ALTER TABLE public.kafka_requisitions OWNER TO postgres;

--
-- Name: requisitions_previous_requisitions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_requisitions_previous_requisitions (
    requisitionid uuid NOT NULL,
    previousrequisitionid uuid NOT NULL
);


ALTER TABLE public.kafka_requisitions_previous_requisitions OWNER TO postgres;

--
-- Name: status_changes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_status_changes (
    id uuid NOT NULL,
    createddate timestamp with time zone,
    modifieddate timestamp with time zone,
    authorid uuid,
    status character varying(255) NOT NULL,
    requisitionid uuid NOT NULL,
    supervisorynodeid uuid
);


ALTER TABLE public.kafka_status_changes OWNER TO postgres;

--
-- Name: status_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_status_messages (
    id uuid NOT NULL,
    createddate timestamp with time zone,
    modifieddate timestamp with time zone,
    authorfirstname character varying(255),
    authorid uuid,
    authorlastname character varying(255),
    body text NOT NULL,
    status character varying(255) NOT NULL,
    requisitionid uuid NOT NULL,
    statuschangeid uuid NOT NULL
);


ALTER TABLE public.kafka_status_messages OWNER TO postgres;

--
-- Name: stock_adjustment_reasons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_stock_adjustment_reasons (
    id uuid NOT NULL,
    reasonid uuid NOT NULL,
    description text,
    isfreetextallowed boolean NOT NULL,
    name text NOT NULL,
    reasoncategory text NOT NULL,
    reasontype text NOT NULL,
    requisitionid uuid,
    hidden boolean
);


ALTER TABLE public.kafka_stock_adjustment_reasons OWNER TO postgres;

--
-- Name: stock_adjustments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_stock_adjustments (
    id uuid NOT NULL,
    quantity integer NOT NULL,
    reasonid uuid NOT NULL,
    requisitionlineitemid uuid
);


ALTER TABLE public.kafka_stock_adjustments OWNER TO postgres;

--
-- Name: template_parameters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kafka_template_parameters (
    id uuid NOT NULL,
    datatype text,
    defaultvalue text,
    description text,
    displayname text,
    name text,
    selectexpression text,
    templateid uuid NOT NULL,
    selectproperty text,
    displayproperty text,
    required boolean,
    selectmethod text,
    selectbody text
);


ALTER TABLE public.kafka_template_parameters OWNER TO postgres;

--
-- Name: available_requisition_column_options available_requisition_column_options_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_available_requisition_column_options
    ADD CONSTRAINT available_requisition_column_options_pkey PRIMARY KEY (id);


--
-- Name: available_requisition_columns available_requisition_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_available_requisition_columns
    ADD CONSTRAINT available_requisition_columns_pkey PRIMARY KEY (id);


--
-- Name: columns_maps columns_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_columns_maps
    ADD CONSTRAINT columns_maps_pkey PRIMARY KEY (requisitiontemplateid, key);


--
-- Name: configuration_settings configuration_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_configuration_settings
    ADD CONSTRAINT configuration_settings_pkey PRIMARY KEY (key);


--
-- Name: jasper_templates jasper_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_jasper_templates
    ADD CONSTRAINT jasper_templates_pkey PRIMARY KEY (id);


--
-- Name: requisition_line_items requisition_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_requisition_line_items
    ADD CONSTRAINT requisition_line_items_pkey PRIMARY KEY (id);


--
-- Name: requisition_permission_strings requisition_permission_strings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_requisition_permission_strings
    ADD CONSTRAINT requisition_permission_strings_pkey PRIMARY KEY (id);


--
-- Name: requisition_template_assignments requisition_template_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_requisition_template_assignments
    ADD CONSTRAINT requisition_template_assignments_pkey PRIMARY KEY (id);


--
-- Name: requisition_templates requisition_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_requisition_templates
    ADD CONSTRAINT requisition_templates_pkey PRIMARY KEY (id);


--
-- Name: requisitions requisitions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_requisitions
    ADD CONSTRAINT requisitions_pkey PRIMARY KEY (id);


--
-- Name: status_messages status_change_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_status_messages
    ADD CONSTRAINT status_change_id_unique UNIQUE (statuschangeid) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: status_changes status_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_status_changes
    ADD CONSTRAINT status_changes_pkey PRIMARY KEY (id);


--
-- Name: status_messages status_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_status_messages
    ADD CONSTRAINT status_messages_pkey PRIMARY KEY (id);


--
-- Name: stock_adjustment_reasons stock_adjustment_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_stock_adjustment_reasons
    ADD CONSTRAINT stock_adjustment_reasons_pkey PRIMARY KEY (id);


--
-- Name: stock_adjustments stock_adjustments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_stock_adjustments
    ADD CONSTRAINT stock_adjustments_pkey PRIMARY KEY (id);


--
-- Name: template_parameters template_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_template_parameters
    ADD CONSTRAINT template_parameters_pkey PRIMARY KEY (id);


--
-- Name: jasper_templates uk_5878s5vb2v4y53vun95nrdvgw; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kafka_jasper_templates
    ADD CONSTRAINT uk_5878s5vb2v4y53vun95nrdvgw UNIQUE (name);


--
-- Name: available_non_full_supply_products_requisitionid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX available_non_full_supply_products_requisitionid_idx ON public.kafka_available_products USING btree (requisitionid);


--
-- Name: previous_adjusted_consumptions_requisitionlineitemid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX previous_adjusted_consumptions_requisitionlineitemid_idx ON public.kafka_previous_adjusted_consumptions USING btree (requisitionlineitemid);


--
-- Name: req_line_reason; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX req_line_reason ON public.kafka_stock_adjustments USING btree (reasonid, requisitionlineitemid);


--
-- Name: req_prod_fac_per; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX req_prod_fac_per ON public.kafka_requisitions USING btree (programid, facilityid, processingperiodid) WHERE ((emergency = false) AND (supervisorynodeid IS NULL));


--
-- Name: req_prod_fac_per_node; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX req_prod_fac_per_node ON public.kafka_requisitions USING btree (programid, facilityid, processingperiodid, supervisorynodeid) WHERE ((emergency = false) AND (supervisorynodeid IS NOT NULL));


--
-- Name: req_tmpl_asgmt_prog_fac_type_tmpl_unique_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX req_tmpl_asgmt_prog_fac_type_tmpl_unique_idx ON public.kafka_requisition_template_assignments USING btree (facilitytypeid, programid, templateid) WHERE (facilitytypeid IS NOT NULL);


--
-- Name: req_tmpl_asgmt_prog_fac_type_unique_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX req_tmpl_asgmt_prog_fac_type_unique_idx ON public.kafka_requisition_template_assignments USING btree (facilitytypeid, programid) WHERE (facilitytypeid IS NOT NULL);


--
-- Name: req_tmpl_asgmt_prog_tmpl_unique_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX req_tmpl_asgmt_prog_tmpl_unique_idx ON public.kafka_requisition_template_assignments USING btree (programid, templateid) WHERE (facilitytypeid IS NULL);


--
-- Name: requisition_line_items_requisitionid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX requisition_line_items_requisitionid_idx ON public.kafka_requisition_line_items USING btree (requisitionid);

ALTER TABLE public.kafka_requisition_line_items CLUSTER ON requisition_line_items_requisitionid_idx;


--
-- Name: requisition_permission_strings_requisitionid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX requisition_permission_strings_requisitionid_idx ON public.kafka_requisition_permission_strings USING btree (requisitionid);


--
-- Name: requisition_template_name_unique_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX requisition_template_name_unique_idx ON public.kafka_requisition_templates USING btree (lower((name)::text), archived) WHERE (archived IS FALSE);


--
-- Name: requisitions_previous_requisitions_requisitionid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX requisitions_previous_requisitions_requisitionid_idx ON public.kafka_requisitions_previous_requisitions USING btree (requisitionid);


--
-- Name: status_changes_requisitionid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX status_changes_requisitionid_idx ON public.kafka_status_changes USING btree (requisitionid);


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


CREATE MATERIALIZED VIEW view_facility_access AS
SELECT DISTINCT u.username, facilityid, programid
FROM kafka_right_assignments ra
  LEFT JOIN kafka_users u ON u.id = ra.userid
WHERE facilityid IS NOT NULL AND programid IS NOT NULL
UNION
SELECT DISTINCT 'admin', facilityid, programid
FROM kafka_right_assignments ra
  LEFT JOIN kafka_users u ON u.id = ra.userid
WHERE facilityid IS NOT NULL AND programid IS NOT NULL AND u.username = 'administrator'
;


---
--- Name: reporting_rate_and_timeliness; Type: TABLE; Schema: public; Owner: postgres
---
CREATE MATERIALIZED VIEW reporting_rate_and_timeliness AS
SELECT f.name
  , dgz.name AS district
  , rgz.name AS region
  , cgz.name AS country
  , ft.name AS facility_type_name
  , fo.name AS operator_name
  , f.active AS facility_active_status
  , final_authorized_requisitions.requisition_id AS req_id
  , final_authorized_requisitions.facility_id
  , final_authorized_requisitions.program_id
  , final_authorized_requisitions.program_name
  , final_authorized_requisitions.program_active_status
  , final_authorized_requisitions.processing_period_id
  , final_authorized_requisitions.processing_period_name
  , final_authorized_requisitions.processing_schedule_name
  , final_authorized_requisitions.processing_period_startdate
  , final_authorized_requisitions.processing_period_enddate
  , final_authorized_requisitions.emergency_status
  , final_authorized_requisitions.created_date
  , final_authorized_requisitions.modified_date
  , sp.programid AS supported_program
  , sp.active AS supported_program_active
  , sp.startdate AS supported_program_startdate
  , final_authorized_requisitions.status_change_date
  , fa.facilityid AS facility
  , fa.programid AS program
  , fa.username
  , CASE
    WHEN final_authorized_requisitions.status_change_date::DATE <= (final_authorized_requisitions.processing_period_enddate::DATE + rd.due_days::INT) 
      AND final_authorized_requisitions.status = 'AUTHORIZED' THEN 'On time'
    WHEN final_authorized_requisitions.status_change_date::DATE > (final_authorized_requisitions.processing_period_enddate::DATE + rd.due_days::INT + rd.late_days::INT) 
      AND final_authorized_requisitions.status = 'AUTHORIZED' THEN 'Unscheduled'
    WHEN final_authorized_requisitions.status_change_date::DATE < (final_authorized_requisitions.processing_period_enddate::DATE + rd.due_days::INT + rd.late_days::INT) 
      AND final_authorized_requisitions.status_change_date::DATE >= (final_authorized_requisitions.processing_period_enddate::DATE + rd.due_days::INT) 
      AND final_authorized_requisitions.status = 'AUTHORIZED' THEN 'Late'
    ELSE 'Did not report'
  END AS reporting_timeliness
FROM kafka_facilities f
  LEFT JOIN (SELECT ranked_authorized_requisitions.requisition_id
      , ranked_authorized_requisitions.facility_id
      , ranked_authorized_requisitions.program_id
      , ranked_authorized_requisitions.program_name
      , ranked_authorized_requisitions.program_active_status
      , ranked_authorized_requisitions.processing_period_id
      , ranked_authorized_requisitions.processing_period_name
      , ranked_authorized_requisitions.processing_schedule_name
      , ranked_authorized_requisitions.processing_period_startdate
      , ranked_authorized_requisitions.processing_period_enddate
      , ranked_authorized_requisitions.emergency_status
      , ranked_authorized_requisitions.created_date
      , ranked_authorized_requisitions.modified_date
      , ranked_authorized_requisitions.status
      , ranked_authorized_requisitions.status_change_date
      , ranked_authorized_requisitions.rank
    FROM (SELECT authorized_requisitions.requisition_id
        , authorized_requisitions.facility_id
        , authorized_requisitions.program_id
        , authorized_requisitions.program_name
        , authorized_requisitions.program_active_status
        , authorized_requisitions.processing_period_id
        , authorized_requisitions.processing_period_name
        , authorized_requisitions.processing_schedule_name
        , authorized_requisitions.processing_period_startdate
        , authorized_requisitions.processing_period_enddate
        , authorized_requisitions.emergency_status
        , authorized_requisitions.created_date
        , authorized_requisitions.modified_date
        , authorized_requisitions.status
        , authorized_requisitions.status_change_date
        , rank() OVER (PARTITION BY authorized_requisitions.program_id, authorized_requisitions.facility_id, authorized_requisitions.processing_period_id ORDER BY authorized_requisitions.status_change_date DESC) AS rank
      FROM (SELECT r.id AS requisition_id
          , r.facilityid AS facility_id
          , r.programid AS program_id
          , p.name AS program_name
          , p.active AS program_active_status
          , r.processingperiodid AS processing_period_id
          , pp.name AS processing_period_name
          , ps.name AS processing_schedule_name
          , pp.startdate AS processing_period_startdate
          , pp.enddate AS processing_period_enddate
          , r.emergency AS emergency_status
          , r.createddate AS created_date
          , r.modifieddate AS modified_date
          , authorized_status_changes.status
          , authorized_status_changes.createddate AS status_change_date
        FROM kafka_requisitions r
          LEFT JOIN (SELECT sc.requisitionid, sc.status, sc.createddate
            FROM kafka_status_changes sc
            WHERE sc.status = 'AUTHORIZED') authorized_status_changes ON authorized_status_changes.requisitionid = r.id
          LEFT JOIN kafka_programs p ON p.id = r.programid
          LEFT JOIN kafka_processing_periods pp ON pp.id = r.processingperiodid
          LEFT JOIN kafka_processing_schedules ps ON ps.id = pp.processingscheduleid
        ) authorized_requisitions
      ORDER BY authorized_requisitions.facility_id, authorized_requisitions.processing_period_id, authorized_requisitions.status_change_date DESC) ranked_authorized_requisitions
    WHERE ranked_authorized_requisitions.rank = 1) final_authorized_requisitions ON f.id = final_authorized_requisitions.facility_id
  LEFT JOIN kafka_geographic_zones dgz ON dgz.id = f.geographiczoneid
  LEFT JOIN kafka_geographic_zones rgz ON rgz.id = dgz.parentid
  LEFT JOIN kafka_geographic_zones cgz ON cgz.id = rgz.parentid
  LEFT JOIN kafka_facility_types ft ON ft.id = f.typeid
  LEFT JOIN kafka_facility_operators fo ON fo.id = f.operatedbyid
  LEFT JOIN reporting_dates rd ON rd.country = cgz.name
  LEFT JOIN kafka_supported_programs sp ON sp.facilityid = f.id AND sp.programid = final_authorized_requisitions.program_id
  LEFT JOIN view_facility_access fa ON fa.facilityid = f.id AND fa.programid = final_authorized_requisitions.program_id
ORDER BY final_authorized_requisitions.processing_period_enddate DESC
WITH DATA;


ALTER MATERIALIZED VIEW reporting_rate_and_timeliness OWNER TO postgres;

---
--- Name: adjustments; Type: TABLE; Schema: public; Owner: postgres
---
CREATE MATERIALIZED VIEW adjustments AS
SELECT rli.id AS requisition_line_item_id
  , r.id AS requisition_id
  , r.createddate::DATE AS created_date
  , r.modifieddate::DATE AS modified_date
  , r.emergency AS emergency_status
  , sn.name AS supervisory_node
  , f.name AS facility_name
  , ft.name AS facility_type_name
  , fo.name AS facility_operator_name
  , f.active AS facilty_active_status
  , dgz.name AS district_name
  , rgz.name AS region_name
  , cgz.name AS country_name
  , p.name AS program_name
  , p.active AS program_active_status
  , pp.name AS processing_period_name
  , latest_orderables.id AS orderable_id
  , latest_orderables.code AS product_code
  , latest_orderables.fullproductname AS full_product_name
  , oi.value AS trade_item_id
  , rli.totallossesandadjustments AS total_losses_and_adjustments
  , final_status_changes.status AS status
  , final_status_changes.authorid AS author_id
  , final_status_changes.createddate::DATE AS status_history_created_date
  , sa.id AS adjustment_lines_id
  , sa.quantity AS quantity
  , sar.name AS stock_adjustment_reason
  , fa.facilityid AS facility
  , fa.programid AS program
  , fa.username AS username
FROM kafka_requisitions r
  LEFT JOIN kafka_requisition_line_items rli ON rli.requisitionid = r.id
  LEFT JOIN kafka_supervisory_nodes sn ON sn.id = r.supervisorynodeid
  LEFT JOIN kafka_facilities f ON f.id = r.facilityid
  LEFT JOIN kafka_facility_types ft ON ft.id = f.typeid
  LEFT JOIN kafka_facility_operators fo ON fo.id = f.operatedbyid
  LEFT JOIN kafka_geographic_zones dgz ON dgz.id = f.geographiczoneid
  LEFT JOIN kafka_geographic_zones rgz ON rgz.id = dgz.parentid
  LEFT JOIN kafka_geographic_zones cgz ON cgz.id = rgz.parentid
  LEFT JOIN kafka_programs p ON p.id = r.programid
  LEFT JOIN kafka_processing_periods pp ON pp.id = r.processingperiodid
  LEFT JOIN (SELECT DISTINCT ON (id) id, code, fullproductname, versionnumber FROM kafka_orderables ORDER BY id, versionnumber DESC) latest_orderables ON latest_orderables.id = rli.orderableid AND latest_orderables.versionnumber = rli.orderableversionnumber
  LEFT JOIN kafka_orderable_identifiers oi ON oi.orderableid = latest_orderables.id AND oi.orderableversionnumber = latest_orderables.versionnumber AND oi.key = 'tradeItem'
  LEFT JOIN (SELECT DISTINCT ON (requisitionid) id, requisitionid, status, authorid, createddate FROM kafka_status_changes ORDER BY requisitionid, createddate DESC) final_status_changes ON final_status_changes.requisitionid = r.id
  LEFT JOIN kafka_stock_adjustments sa ON sa.requisitionlineitemid = rli.id
  LEFT JOIN kafka_stock_adjustment_reasons sar ON sar.id = sa.reasonid AND sar.requisitionid = r.id
  LEFT JOIN view_facility_access fa ON fa.facilityid = r.facilityid AND fa.programid = r.programid
WHERE final_status_changes.status NOT IN ('SKIPPED', 'INITIATED', 'SUBMITTED')
ORDER BY rli.id, fa.username, r.modifieddate DESC NULLS LAST
WITH DATA;

ALTER MATERIALIZED VIEW adjustments OWNER TO postgres;


---
--- Name: stock_status_and_consumption; Type: TABLE; Schema: public; Owner: postgres
---
CREATE MATERIALIZED VIEW stock_status_and_consumption AS
SELECT li.requisition_line_item_id
  , r.id
  , r.createddate AS req_created_date
  , r.modifieddate AS modified_date
  , r.emergency AS emergency_status
  , r.supplyingfacilityid AS supplying_facility
  , r.supervisorynodeid AS supervisory_node
  , r.facilityid AS facility_id
  , f.code AS facility_code
  , f.name AS facility_name
  , f.active AS facilty_active_status
  , dgz.id AS district_id
  , dgz.code AS district_code
  , dgz.name AS district_name
  , rgz.id AS region_id
  , rgz.code AS region_code
  , rgz.name AS region_name
  , cgz.id AS country_id
  , cgz.code AS country_code
  , cgz.name AS country_name
  , ft.id AS facility_type_id
  , ft.code AS facility_type_code
  , ft.name AS facility_type_name
  , fo.id AS facility_operator_id
  , fo.code AS facility_operator_code
  , fo.name AS facility_operator_name
  , p.id AS program_id
  , p.code AS program_code
  , p.name AS program_name
  , p.active AS program_active_status
  , pp.id AS processing_period_id
  , pp.name AS processing_period_name
  , pp.startdate AS processing_period_startdate
  , pp.enddate AS processing_period_enddate
  , ps.id AS processing_schedule_id
  , ps.code AS processing_schedule_code
  , ps.name AS processing_schedule_name
  , li.requisition_id AS li_req_id
  , li.orderable_id
  , li.product_code
  , li.full_product_name
  , li.trade_item_id
  , li.beginning_balance
  , li.total_consumed_quantity
  , li.average_consumption
  , li.total_losses_and_adjustments
  , li.stock_on_hand
  , li.total_stockout_days
  , li.max_periods_of_stock
  , li.calculated_order_quantity
  , li.requested_quantity
  , li.approved_quantity
  , li.packs_to_ship
  , li.price_per_pack
  , li.total_cost
  , li.total_received_quantity
  , sc.requisitionid AS status_req_id
  , sc.status AS req_status
  , sc.authorid AS author_id
  , sc.createddate AS status_date
  , fa.facilityid AS facility
  , fa.programid AS program
  , fa.username
  , li.closing_balance
  , li.amc
  , li.consumption
  , li.adjusted_consumption
  , li.order_quantity
  , f.enabled as facility_status
  , rd.due_days
  , rd.late_days
  , li.combined_stockout
  , li.stock_status
FROM kafka_requisitions r 
  LEFT JOIN kafka_status_changes sc ON sc.requisitionid = r.id
  LEFT JOIN kafka_facilities f ON f.id = r.facilityid
  LEFT JOIN kafka_geographic_zones dgz ON dgz.id = f.geographiczoneid
  LEFT JOIN kafka_geographic_zones rgz ON rgz.id = dgz.parentid
  LEFT JOIN kafka_geographic_zones cgz ON cgz.id = rgz.parentid
  LEFT JOIN kafka_facility_types ft ON ft.id = f.typeid
  LEFT JOIN kafka_facility_operators fo ON fo.id = f.operatedbyid
  LEFT JOIN kafka_programs p ON p.id = r.programid
  LEFT JOIN kafka_processing_periods pp ON pp.id = r.processingperiodid
  LEFT JOIN kafka_processing_schedules ps ON ps.id = pp.processingscheduleid
  LEFT JOIN reporting_dates rd ON rd.country = cgz.name
  LEFT JOIN view_facility_access fa ON fa.facilityid = f.id AND fa.programid = r.programid
  LEFT JOIN (SELECT DISTINCT ON (rli.id) rli.id AS requisition_line_item_id
      , requisitionid AS requisition_id
      , rli.orderableid AS orderable_id
      , latest_orderables.code AS product_code
      , latest_orderables.fullproductname AS full_product_name
      , oi.value AS trade_item_id
      , beginningbalance AS beginning_balance
      , totalconsumedquantity AS total_consumed_quantity
      , averageconsumption AS average_consumption
      , totallossesandadjustments AS total_losses_and_adjustments
      , stockonhand AS stock_on_hand
      , totalstockoutdays AS total_stockout_days
      , maxperiodsofstock AS max_periods_of_stock
      , calculatedorderquantity AS calculated_order_quantity
      , requestedquantity AS requested_quantity
      , approvedquantity AS approved_quantity
      , packstoship AS packs_to_ship
      , priceperpack AS price_per_pack
      , totalcost AS total_cost
      , totalreceivedquantity AS total_received_quantity
      , SUM(stockonhand) AS closing_balance
      , SUM(averageconsumption) AS amc
      , SUM(totalconsumedquantity) AS consumption
      , SUM(adjustedconsumption) AS adjusted_consumption
      , SUM(approvedquantity) AS order_quantity
      , CASE 
        WHEN (SUM(stockonhand) = 0 OR SUM(totalstockoutdays) > 0 OR SUM(beginningbalance) = 0 OR SUM(maxperiodsofstock) = 0) THEN 1
        ELSE 0 
      END as combined_stockout
      , CASE
        WHEN SUM(maxperiodsofstock) > 6 THEN 'Overstocked'
        WHEN SUM(maxperiodsofstock) < 3 AND (SUM(stockonhand) = 0 OR SUM(totalstockoutdays) > 0 OR SUM(beginningbalance) = 0 OR SUM(maxperiodsofstock) = 0) THEN 'Stocked Out'
        WHEN SUM(maxperiodsofstock) < 3 AND SUM(maxperiodsofstock) > 0 AND NOT(SUM(stockonhand) = 0 OR SUM(totalstockoutdays) > 0 OR SUM(beginningbalance) = 0 OR SUM(maxperiodsofstock) = 0) THEN 'Understocked'
        WHEN SUM(maxperiodsofstock) = 0 AND NOT(SUM(stockonhand) = 0 OR SUM(totalstockoutdays) > 0 OR SUM(beginningbalance) = 0 OR SUM(maxperiodsofstock) = 0) THEN 'Unknown'
        ELSE 'Adequately stocked'
      END as stock_status
    FROM kafka_requisition_line_items rli
      LEFT JOIN (SELECT DISTINCT ON (id) id, code, fullproductname, versionnumber FROM kafka_orderables ORDER BY id, versionnumber DESC) latest_orderables ON latest_orderables.id = rli.orderableid AND latest_orderables.versionnumber = rli.orderableversionnumber
      LEFT JOIN kafka_orderable_identifiers oi ON oi.orderableid = latest_orderables.id AND oi.orderableversionnumber = latest_orderables.versionnumber AND oi.key = 'tradeItem'
    GROUP BY rli.id
      , requisitionid
      , rli.orderableid
      , latest_orderables.code
      , latest_orderables.fullproductname
      , oi.value
      , beginningbalance
      , totalconsumedquantity
      , averageconsumption
      , totallossesandadjustments
      , stockonhand
      , totalstockoutdays
      , maxperiodsofstock
      , calculatedorderquantity
      , requestedquantity
      , approvedquantity
      , packstoship
      , priceperpack
      , totalcost
      , totalreceivedquantity) li ON li.requisition_id = r.id
WITH DATA;

ALTER MATERIALIZED VIEW stock_status_and_consumption OWNER TO postgres;

CREATE MATERIALIZED VIEW facilities AS
SELECT f.code as code, f.name as name, gz.name as district, ft.name as type, fo.name as operator_name
FROM public.kafka_facilities f
left join public.kafka_geographic_zones gz on gz.id = f.geographiczoneid
left join public.kafka_facility_types ft on ft.id = f.typeid
left join public.kafka_facility_operators fo on fo.id = f.operatedbyid
WITH DATA;

ALTER MATERIALIZED VIEW facilities OWNER TO postgres;


CREATE MATERIALIZED VIEW expired_products AS
SELECT "Facility Name" AS "Facility Name",
       "Facility Type Code" AS "Facility Type Code",
       "Program" AS "Program",
       "Product Code" AS "Product Code",
       "Full Product Name" AS "Full Product Name",
       "Batch Number" AS "Batch Number",
       "Expiration Date" AS "Expiration Date",
       "Unit Price" AS "Unit Price",
       "Total Cost" AS "Total Cost"
FROM
  (SELECT f.name "Facility Name",
          f.code "Facility Code",
          f.description "Facility Description",
          ft.name "Facility Type Name",
          ft.code "Facility Type Code",
          ft.description "Facility Type Description",
          fo.name "Facility Operator",
          fo.description "Facility Operator Description",
          pp.name "Reporting Period",
          pp.startdate "Processing Period Start Date",
          pp.enddate "Processing Period End Date",
          ps.name "Processing Schedule Name",
          pp.description "Processing Period Description",
          p.name "Program",
          o.fullproductname "Full Product Name",
          o.code "Product Code",
          o.description "Product Description",
          o.packroundingthreshold "Pack Rounding Threshold",
          o.netcontent "Net Content",
          o.lastupdated "Last Updated",
          l.lotcode "Batch Number",
          l.expirationdate "Expiration Date",
          po.priceperpack "Unit Price",
          rli.adjustedconsumption "Adjusted Consumption",
          rli.approvedquantity "Approved Quantity",
          rli.averageconsumption "Average Consumtion",
          rli.beginningbalance "beginning Balance",
          rli.calculatedorderquantity "Calculated Order Quantity",
          rli.maxperiodsofstock "Maximum Periods of Stock",
          rli.maximumstockquantity "Minimum Stock Quantity",
          r.createddate "Requisition Creation Date",
          r.modifieddate "Requisition Modification Date",
          r.status "Requisition Status",
          r.version "Requisition Version",
          r.datephysicalstockcountcompleted "Date Physical Stockcount Completed",
          rli.packstoship "Packs To Ship",
          rli.priceperpack "Price Per Pack",
          rli.remarks "Remarks",
          rli.requestedquantity "Requested Quantity",
          rli.requestedquantity "Requested Quantity Explanation",
          rli.stockonhand "Stock On Hand",
          rli.total "Total",
          rli.totalconsumedquantity "Total Consumed Quantity",
          rli.totalcost "Total Cost",
          rli.totallossesandadjustments "Total Losses and Adjustments",
          rli.totalreceivedquantity "Total Received Quantity",
          rli.totalstockoutdays "Total Stockout Days",
          -- rli.numberofpatientsontreatmentnextmonth "Number of Patients on Treatment Next Month",
          -- rli.totalrequirement "Total Requirement",
          rli.idealstockamount "Ideal Stock Amount",
          -- rli.totalquantityneededbyhf "Total Quantity Needed by HF",
          -- rli.quantitytoissue "Quantity to Issue",
          -- rli.convertedquantitytoissue "Converted Quantity to Issue",
          fa.username
   FROM kafka_requisition_line_items rli
   LEFT JOIN kafka_requisitions r ON rli.requisitionid = r.id
   LEFT JOIN kafka_facilities f ON r.facilityid =f.id
   LEFT JOIN kafka_facility_types ft ON f.typeid = ft.id
   LEFT JOIN kafka_programs p ON p.id = r.programid
   LEFT JOIN kafka_orderables o ON o.id = rli.orderableid
   LEFT JOIN kafka_processing_periods pp ON pp.id = r.processingperiodid
   LEFT JOIN kafka_processing_schedules ps ON ps.id = pp.processingscheduleid
   LEFT JOIN kafka_facility_operators fo ON fo.id = f.operatedbyid
   LEFT JOIN kafka_orderable_identifiers oi ON oi.orderableid =o.id
   LEFT JOIN kafka_lots l ON l.tradeitemid = oi.value::uuid
   --LEFT JOIN kafka_stock_event_line_items seli ON seli.orderableid =o.id
   LEFT JOIN kafka_program_orderables po ON po.orderableid =o.id
   LEFT JOIN view_facility_access fa ON fa.facilityid = f.id) AS expired
WITH DATA;

ALTER MATERIALIZED VIEW expired_products OWNER TO postgres;

CREATE MATERIALIZED VIEW stock_card_summaries AS
SELECT 
    f.code AS "Facility Code",
    f.name AS "Facility",
    ft.name AS "Facility Type",
    fo.name AS "Facility Operated By",
    p.name AS "Program",
    o.code AS "Product Code",
    o.fullproductname AS "Product",
    o.netcontent AS "Pack Size",
    lots.lotcode AS "Batch Number",
    lots.expirationdate AS "Expiry Date",
    stock_summary.remaining_stock_on_hand,
    CASE 
        WHEN lots.expirationdate IS NOT NULL AND lots.expirationdate < CURRENT_DATE THEN TRUE
        ELSE FALSE
    END AS is_expired,
    fa.username
FROM kafka_stock_cards stc
INNER JOIN (
    SELECT 
        stcli.stockcardid,
        SUM(
            CASE 
                WHEN COALESCE(stclire.reasontype, 'CREDIT') = 'CREDIT' THEN stcli.quantity
                WHEN stclire.reasontype = 'DEBIT' THEN -stcli.quantity
                ELSE 0
            END
        ) AS remaining_stock_on_hand
    FROM kafka_stock_card_line_items stcli
    LEFT JOIN kafka_stock_card_line_item_reasons stclire 
        ON stclire.id = stcli.reasonid
    GROUP BY stcli.stockcardid
) AS stock_summary
    ON stc.id = stock_summary.stockcardid
LEFT JOIN kafka_lots lots ON lots.id = stc.lotid::uuid
LEFT JOIN kafka_facilities f ON f.id = stc.facilityid::uuid
LEFT JOIN kafka_facility_types ft ON ft.id = f.typeid::uuid
LEFT JOIN kafka_programs p ON p.id = stc.programid::uuid
LEFT JOIN kafka_orderables o ON o.id = stc.orderableid::uuid
LEFT JOIN kafka_facility_operators fo ON fo.id = f.operatedbyid::uuid
LEFT JOIN view_facility_access fa ON fa.facilityid = f.id
WITH DATA;

ALTER MATERIALIZED VIEW stock_card_summaries OWNER TO postgres;

DROP MATERIALIZED VIEW IF EXISTS stock_card_summaries_with_prices;

CREATE MATERIALIZED VIEW stock_card_summaries_with_prices AS
WITH latest_prices AS (
  SELECT DISTINCT ON (orderableid, programid)
    orderableid,
    programid,
    priceperpack::numeric,
    orderableversionnumber
  FROM kafka_program_orderables
  WHERE active IS TRUE
  ORDER BY orderableid, programid, orderableversionnumber DESC
)
SELECT DISTINCT
    f.code AS "Facility Code",
    f.name AS "Facility",
    ft.name AS "Facility Type",
    fo.name AS "Facility Operated By",
    p.name AS "Program",
    o.code AS "Product Code",
    o.fullproductname AS "Product",
    o.netcontent AS "Pack Size",
    lots.lotcode AS "Batch Number",
    lots.expirationdate AS "Expiry Date",
    stock_summary.remaining_stock_on_hand,
    CASE 
        WHEN lots.expirationdate IS NOT NULL AND lots.expirationdate < CURRENT_DATE THEN TRUE
        ELSE FALSE
    END AS is_expired,
    lp.priceperpack AS "Pack Cost (LSL)",
    CASE 
        WHEN o.netcontent > 0 THEN ROUND(stock_summary.remaining_stock_on_hand / o.netcontent * lp.priceperpack, 2)
        ELSE NULL
    END AS "Total Cost (LSL)",
    fa.username
FROM kafka_stock_cards stc
INNER JOIN (
    SELECT 
        stcli.stockcardid,
        SUM(
            CASE 
                WHEN COALESCE(stclire.reasontype, 'CREDIT') = 'CREDIT' THEN stcli.quantity
                WHEN stclire.reasontype = 'DEBIT' THEN -stcli.quantity
                ELSE 0
            END
        ) AS remaining_stock_on_hand
    FROM kafka_stock_card_line_items stcli
    LEFT JOIN kafka_stock_card_line_item_reasons stclire 
        ON stclire.id = stcli.reasonid
    GROUP BY stcli.stockcardid
) AS stock_summary
    ON stc.id = stock_summary.stockcardid
LEFT JOIN kafka_lots lots ON lots.id = stc.lotid::uuid
LEFT JOIN kafka_facilities f ON f.id = stc.facilityid::uuid
LEFT JOIN kafka_facility_types ft ON ft.id = f.typeid::uuid
LEFT JOIN kafka_programs p ON p.id = stc.programid::uuid
LEFT JOIN kafka_orderables o ON o.id = stc.orderableid::uuid
LEFT JOIN kafka_facility_operators fo ON fo.id = f.operatedbyid::uuid
LEFT JOIN view_facility_access fa ON fa.facilityid = f.id
LEFT JOIN latest_prices lp ON 
    lp.orderableid = stc.orderableid::uuid AND 
    lp.programid = stc.programid::uuid
WITH DATA;

ALTER MATERIALIZED VIEW stock_card_summaries_with_prices OWNER TO postgres;

DROP MATERIALIZED VIEW IF EXISTS data_verification;
CREATE MATERIALIZED VIEW data_verification AS

WITH stock_by_card AS (
    -- Step 1: Calculate both stock on hand and receipts per stockcard
    SELECT 
        stc.id AS stockcardid,
        fac.name AS facility_name,
        fac.code AS facility_code,
        LEFT(fac.code, 4) AS facility_prefix,
        facty.name AS facility_type,
        facop.name AS facility_operator,
        ord.fullproductname AS product_name,
        ord.netcontent AS pack_size,
        prog.name AS program,
        odc.displayname AS category,
        geoz.name AS geographic_zone,
        dis.name AS district,
        SUM(
            CASE 
                WHEN COALESCE(stclire.reasontype, 'CREDIT') = 'CREDIT' THEN stcli.quantity
                WHEN stclire.reasontype = 'DEBIT' THEN -stcli.quantity
                ELSE 0
            END
        ) AS stock_on_hand,
        SUM(
            CASE 
                WHEN stclire.name = 'Receipts' AND no_fac.code  = 'NDSO' THEN stcli.quantity 
                ELSE 0
            END
        ) AS sum_of_receipts,
        SUM(
            CASE 
                WHEN stclire.name = 'Transfer Out' THEN stcli.quantity 
                ELSE 0
            END
        ) AS sum_of_transfer_out,
        SUM(
            CASE 
                WHEN stclire.name = 'Expired' THEN stcli.quantity 
                ELSE 0
            END
        ) AS sum_expired,
        SUM(
            CASE 
                WHEN stclire.name = 'Transfer In' THEN stcli.quantity 
                ELSE 0
            END
        ) AS sum_tranfer_in
    FROM kafka_stock_card_line_items stcli
    LEFT JOIN kafka_stock_card_line_item_reasons stclire ON stcli.reasonid = stclire.id
    LEFT JOIN kafka_stock_cards stc ON stcli.stockcardid = stc.id
    LEFT JOIN kafka_facilities fac ON stc.facilityid = fac.id
    LEFT JOIN kafka_facility_types facty ON fac.typeid = facty.id
    LEFT JOIN kafka_facility_operators facop ON fac.operatedbyid = facop.id
    LEFT JOIN kafka_orderables ord ON stc.orderableid = ord.id
    LEFT JOIN kafka_programs prog ON stc.programid = prog.id
    LEFT JOIN kafka_program_orderables prog_o ON ord.id = prog_o.orderableid
    LEFT JOIN kafka_orderable_display_categories odc ON odc.id = prog_o.orderabledisplaycategoryid
    LEFT JOIN kafka_geographic_zones geoz ON geoz.id = fac.geographiczoneid
    LEFT JOIN kafka_nodes no ON CAST(no.id AS uuid) = stcli.sourceid
    LEFT JOIN kafka_facilities no_fac ON no_fac.id = CAST(no.referenceid AS uuid)
    LEFT JOIN kafka_geographic_zones Zone_fac ON zone_fac.id = fac.geographiczoneid
    LEFT JOIN kafka_geographic_zones dis ON zone_fac.parentid = dis.id
    GROUP BY 
        stc.id,
        fac.name, fac.code, facty.name, facop.name,
        ord.fullproductname, ord.netcontent,
        prog.name, odc.displayname, geoz.name,dis.name
),
total_by_group AS (
    -- Step 2: Sum both stock and receipts per (first 4 letters of Facility Code + Product Name)
    SELECT 
        facility_prefix,
        product_name,
        SUM(stock_on_hand) AS total_stock_on_hand,
        SUM(sum_of_receipts) AS total_receipts_per_product,
        SUM(sum_of_transfer_out) AS total_transfer_out,
        SUM(sum_expired) AS total_expired,
        SUM(sum_tranfer_in) AS total_transfer_in
    FROM stock_by_card
    GROUP BY facility_prefix, product_name
)
-- Final result: combine per-stockcard data with group totals
SELECT DISTINCT ON (sbc.facility_name, sbc.product_name)
    sbc.district AS "District",
    sbc.geographic_zone AS "Facility Name",
    sbc.facility_code AS "Facility Code",
    sbc.facility_type AS "Facility Type",
    sbc.facility_operator AS "Facility Operator",
    sbc.product_name AS "Product Name",
    sbc.pack_size AS "Pack Size",
    sbc.program AS "Program",
    -- sbc.category AS "Categories",
    -- tbg.total_stock_on_hand AS "Total Stock on Hand",
    tbg.total_receipts_per_product AS "Receipts",
    tbg.total_transfer_in AS "Transfer In",
    tbg.total_transfer_out AS "Transfer Out",
    tbg.total_expired AS "Expired",
    tbg.total_stock_on_hand AS "Total Stock on Hand"
FROM stock_by_card sbc
JOIN total_by_group tbg
    ON sbc.facility_prefix = tbg.facility_prefix
    AND sbc.product_name = tbg.product_name
WHERE LENGTH(sbc.facility_code) = 5
ORDER BY sbc.facility_name, sbc.product_name, sbc.stock_on_hand DESC

WITH DATA;

ALTER MATERIALIZED VIEW data_verification OWNER TO postgres;

DROP MATERIALIZED VIEW IF EXISTS dqa;
CREATE MATERIALIZED VIEW dqa AS

SELECT 
       fac.name "Facility",
       dis.name "District",
       facty.name "Facility Type",
       facop.name "Ownership",
       prog.name AS "Program",
       ord.fullproductname "Product", 
       lots.lotcode "Batch Number" ,
       stcli.quantity, -- "Quantity",
       NULL AS isphysicalinventory,
       stclir.name AS "Reason", 
       stclir.reasontype,
       stcli.occurreddate
       
FROM kafka_stock_card_line_items stcli
LEFT JOIN kafka_stock_card_line_item_reasons stclir ON stcli.reasonid = stclir.id
LEFT JOIN kafka_stock_cards stc ON stcli.stockcardid = stc.id 
LEFT JOIN kafka_orderables ord ON stc.orderableid = ord.id  
LEFT JOIN kafka_lots lots ON stc.lotid = lots.id
LEFT JOIN kafka_program_orderables po ON ord.id = po.orderableid 
LEFT JOIN kafka_programs prog ON po.programid = prog.id
LEFT JOIN kafka_facilities fac ON stc.facilityid = fac.id
LEFT JOIN kafka_facility_types facty ON fac.typeid = facty.id 
LEFT JOIN kafka_facility_operators facop ON fac.operatedbyid = facop.id
LEFT JOIN kafka_geographic_zones zone_fac ON zone_fac.id = fac.geographiczoneid
LEFT JOIN kafka_geographic_zones dis ON zone_fac.parentid = dis.id  -- dis for district
WHERE facty.id IN ('0fbe2b5c-bd2b-46af-ba7f-63c14add59c7', --Hospital
                      '1096849c-84cd-4a94-8a7a-25d9f6e3911b') -- Health Centre
      AND stclir.name IS NOT NULL

UNION 

SELECT 
       fac.name "Facility",
       dis.name "District",
       facty.name "Facility Type",
       facop.name "Ownership",
       prog.name AS "Program",
       ord.fullproductname "Product", 
       lots.lotcode "Batch Number" ,
      -- stcli.quantity AS "Line Item Qauntity", 
       pili.quantity, --  AS "Quantity",
       stcli.extradata ->> 'physicalInventoryType' AS isphysicalinventory,
       stclir.name AS "Reason", 
       stclir.reasontype,
       stcli.occurreddate
       
FROM kafka_stock_card_line_items stcli
LEFT JOIN kafka_physical_inventory_line_item_adjustments pili ON pili.stockcardlineitemid::uuid = stcli.id
LEFT JOIN kafka_stock_card_line_item_reasons stclir ON pili.reasonid::uuid = stclir.id
LEFT JOIN kafka_stock_cards stc ON stcli.stockcardid = stc.id 
LEFT JOIN kafka_orderables ord ON stc.orderableid = ord.id  
LEFT JOIN kafka_lots lots ON stc.lotid = lots.id
LEFT JOIN kafka_program_orderables po ON ord.id = po.orderableid 
LEFT JOIN kafka_programs prog ON po.programid = prog.id
LEFT JOIN kafka_facilities fac ON stc.facilityid = fac.id
LEFT JOIN kafka_facility_types facty ON fac.typeid = facty.id 
LEFT JOIN kafka_facility_operators facop ON fac.operatedbyid = facop.id
LEFT JOIN kafka_geographic_zones zone_fac ON zone_fac.id = fac.geographiczoneid
LEFT JOIN kafka_geographic_zones dis ON zone_fac.parentid = dis.id  -- dis for district
WHERE facty.id IN ('0fbe2b5c-bd2b-46af-ba7f-63c14add59c7', --Hospital
                      '1096849c-84cd-4a94-8a7a-25d9f6e3911b') -- Health Centre
      AND stcli.extradata ? 'physicalInventoryType'

WITH DATA;

ALTER MATERIALIZED VIEW dqa OWNER TO postgres;



DROP MATERIALIZED VIEW IF EXISTS redistribution;
CREATE MATERIALIZED VIEW redistribution AS

SELECT 
       issufac.name AS "Issuing Facility",
       issudis.name AS "Issuing District",
       issufacty.name AS "Issuing Facility Type",
       issufacop.name AS "Issuing Facility Ownership",
       prog.name AS "Program",
       ord.fullproductname "Product", 
       lots.lotcode "Batch Number" ,
       stcli.quantity "Quantity",
      -- stclir.name AS "Reason", 
       stcli.occurreddate AS "Date Received",
       fac.name "Receiving Facility",
       dis.name "District",
       facty.name "Facility Type",
       facop.name "Ownership"
       
FROM kafka_stock_card_line_items stcli
LEFT JOIN kafka_stock_card_line_item_reasons stclir ON stcli.reasonid = stclir.id
LEFT JOIN kafka_stock_cards stc ON stcli.stockcardid = stc.id 
LEFT JOIN kafka_orderables ord ON stc.orderableid = ord.id  
LEFT JOIN kafka_lots lots ON stc.lotid = lots.id
LEFT JOIN kafka_program_orderables po ON ord.id = po.orderableid 
LEFT JOIN kafka_programs prog ON po.programid = prog.id
LEFT JOIN kafka_facilities fac ON stc.facilityid = fac.id
LEFT JOIN kafka_facility_types facty ON fac.typeid = facty.id 
LEFT JOIN kafka_facility_operators facop ON fac.operatedbyid = facop.id
LEFT JOIN kafka_geographic_zones zone_fac ON zone_fac.id = fac.geographiczoneid
LEFT JOIN kafka_geographic_zones dis ON zone_fac.parentid = dis.id  -- dis for district
LEFT JOIN kafka_nodes no ON stcli.sourceid = CAST(no.id AS uuid)
LEFT JOIN kafka_facilities issufac ON CAST(no.referenceid AS uuid) = issufac.id
LEFT JOIN kafka_geographic_zones zone_issufac ON zone_issufac.id = issufac.geographiczoneid 
LEFT JOIN kafka_geographic_zones issudis ON zone_issufac.parentid = issudis.id
LEFT JOIN kafka_facility_types issufacty ON issufac.typeid = issufacty.id 
LEFT JOIN kafka_facility_operators issufacop ON issufac.operatedbyid = issufacop.id

WHERE stclir.id  = 'e3fc3cf3-da18-44b0-a220-77c985202e06' -- Transfer IN
      AND facty.id IN ('0fbe2b5c-bd2b-46af-ba7f-63c14add59c7', --Hospital
                      '1096849c-84cd-4a94-8a7a-25d9f6e3911b') -- Health Centre
      AND stcli.sourceid IS NOT NULL

WITH DATA;
ALTER MATERIALIZED VIEW redistribution OWNER TO postgres;

DROP MATERIALIZED VIEW IF EXISTS stockouts;
CREATE MATERIALIZED VIEW stockouts AS

WITH lineitems AS (
    SELECT 
        dis.name AS district, 
        fac.name AS facility, 
        facty.name AS facility_type, 
        prog.name AS program, 
        ord.fullproductname AS product, 
        stc.id AS stockcard_id,         -- kept for provenance, not used later
        lots.lotcode AS batch_number,   -- ignored for balances/stockouts
        stcli.occurreddate::date AS occurreddate, 
        CASE
            WHEN COALESCE(stclire.reasontype, 'CREDIT') = 'CREDIT' THEN stcli.quantity 
            WHEN stclire.reasontype = 'DEBIT'  THEN -stcli.quantity 
            ELSE 0 
        END AS movement_qty 
    FROM kafka_stock_card_line_items stcli 
    LEFT JOIN kafka_stock_card_line_item_reasons stclire ON stcli.reasonid = stclire.id 
    LEFT JOIN kafka_stock_cards stc              ON stcli.stockcardid = stc.id 
    LEFT JOIN kafka_orderables ord               ON stc.orderableid = ord.id 
    LEFT JOIN kafka_facilities fac               ON stc.facilityid = fac.id 
    LEFT JOIN kafka_geographic_zones zone_fac    ON zone_fac.id = fac.geographiczoneid 
    LEFT JOIN kafka_geographic_zones dis         ON zone_fac.parentid = dis.id 
    LEFT JOIN kafka_facility_types facty         ON fac.typeid = facty.id 
    LEFT JOIN kafka_program_orderables po        ON po.orderableid = ord.id 
    LEFT JOIN kafka_programs prog                ON po.programid = prog.id 
    LEFT JOIN kafka_lots lots                    ON stc.lotid = lots.id 
),

-- Collapse all lots/stockcards into a single daily movement per facility+product
movements AS (
    SELECT
        district,
        facility,
        facility_type,
        program,
        product,
        occurreddate,
        SUM(movement_qty) AS movement_qty
    FROM lineitems
    GROUP BY
        district, facility, facility_type, program, product, occurreddate
),

balances AS (
    SELECT
        district,
        facility,
        facility_type,
        program,
        product,
        occurreddate,
        SUM(movement_qty) OVER (
            PARTITION BY facility, product
            ORDER BY occurreddate
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_balance
    FROM movements
),

stockouts AS (
    SELECT 
        b.district,
        b.facility,
        b.facility_type,
        b.program,
        b.product,
        b.occurreddate AS date_became_os,
        (
            SELECT MIN(b2.occurreddate)
            FROM balances b2
            WHERE b2.facility = b.facility
              AND b2.product  = b.product
              AND b2.occurreddate > b.occurreddate
              AND b2.running_balance > 0
        ) AS date_received_post_os
    FROM balances b
    -- treat 0 or negative as out-of-stock; change to "= 0" if you only want exactly zero
    WHERE b.running_balance <= 0
)

SELECT 
    district, 
    facility, 
    facility_type, 
    program, 
    product, 
    date_trunc('month', MIN(date_became_os)) AS "OS Month", 
    MIN(date_became_os)                       AS date_became_os,
    MAX(date_received_post_os)                AS date_received_post_os,
    COALESCE(MAX(date_received_post_os), CURRENT_DATE) - MIN(date_became_os) AS os_days,
    CASE  
        WHEN MAX(date_received_post_os) IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS was_service_interruption
FROM stockouts
GROUP BY district, facility, facility_type, program, product
ORDER BY district, facility, product, date_became_os;

WITH DATA;
ALTER MATERIALIZED VIEW stockouts OWNER TO postgres;

DROP MATERIALIZED VIEW IF EXISTS product_loss;
CREATE MATERIALIZED VIEW product_loss AS

SELECT 
       fac.name "Facility",
       dis.name "District",
       facty.name "Facility Type",
       facop.name "Ownership",
       prog.name AS "Program",
       ord.fullproductname "Product", 
       lots.lotcode "Batch Number" ,
       stcli.quantity "Quantity",
       stclir.name AS "Reason", 
       stcli.occurreddate 
FROM kafka_stock_card_line_items stcli
LEFT JOIN kafka_stock_card_line_item_reasons stclir ON stcli.reasonid = stclir.id
LEFT JOIN kafka_stock_cards stc ON stcli.stockcardid = stc.id 
LEFT JOIN kafka_orderables ord ON stc.orderableid = ord.id  
LEFT JOIN kafka_lots lots ON stc.lotid = lots.id
LEFT JOIN kafka_program_orderables po ON ord.id = po.orderableid 
LEFT JOIN kafka_programs prog ON po.programid = prog.id
LEFT JOIN kafka_facilities fac ON stc.facilityid = fac.id
LEFT JOIN kafka_facility_types facty ON fac.typeid = facty.id 
LEFT JOIN kafka_facility_operators facop ON fac.operatedbyid = facop.id
LEFT JOIN kafka_geographic_zones zone_fac ON zone_fac.id = fac.geographiczoneid
LEFT JOIN kafka_geographic_zones dis ON zone_fac.parentid = dis.id  -- dis for district
WHERE stclir.id IN ('97e3140e-8432-4541-8347-d3a0d84954b4',-- Damaged
                   'dca931d1-aaf9-47ba-9609-fb98fb421b4c', -- Expiry
                   '58c07b26-6ca0-4d4f-9a7d-c5a8e126927d', -- Damage
                   '5e420bc6-f0b7-49f3-96a4-227b20058e4a', -- Expire
                   --Reason Unaccounted for
                   --Reason Quality Standards
                   '4e1e8588-0af6-4692-a98d-ee3685304574', -- Unusable
                   'ddb09bf6-441b-4290-8828-c1ad5b208252') -- Degraded

      AND facty.id IN ('0fbe2b5c-bd2b-46af-ba7f-63c14add59c7', --Hospital
                      '1096849c-84cd-4a94-8a7a-25d9f6e3911b') -- Health Centre

WITH DATA;
ALTER MATERIALIZED VIEW product_loss OWNER TO postgres;

DROP MATERIALIZED VIEW IF EXISTS emergency_orders;
CREATE MATERIALIZED VIEW emergency_orders AS

SELECT
dis.name AS "District",
geoz.name AS "Facility Name",
fac.name AS "Service Point",
fac.code AS facility_code,
LEFT(fac.code, 5) AS facility_prefix,
facty.name AS facility_type,
facop.name AS facility_operator,
prog.name AS program,
period.name AS "Reporting Period",
ord.fullproductname,
reqli.requestedquantity as "Quantity Requested",
req.status
from  kafka_requisitions req
LEFT JOIN kafka_facilities fac ON req.facilityid = fac.id
LEFT JOIN kafka_facility_types facty ON fac.typeid = facty.id
LEFT JOIN kafka_facility_operators facop ON fac.operatedbyid = facop.id
LEFT JOIN kafka_programs prog ON req.programid = prog.id
--LEFT JOIN kafka_program_orderables prog_o ON ord.id = prog_o.orderableid
--LEFT JOIN kafka_orderable_display_categories odc ON odc.id = prog_o.orderabledisplaycategoryid
LEFT JOIN kafka_geographic_zones geoz ON geoz.id = fac.geographiczoneid
LEFT JOIN kafka_geographic_zones Zone_fac ON zone_fac.id = fac.geographiczoneid
LEFT JOIN kafka_geographic_zones dis ON zone_fac.parentid = dis.id
LEFT JOIN kafka_processing_periods period ON req.processingperiodid  = period.id
LEFT JOIN kafka_requisition_line_items reqli ON req.id = reqli.requisitionid 
LEFT JOIN kafka_orderables ord ON reqli.orderableid = ord.id
WHERE req.emergency  = 'true' -- Pull Only Emergency kafka_requisitions 
AND req.status in ('APPROVED');--, 'SUBMITTED','RELEASED', 'IN_APPROVAL');

WITH DATA;
ALTER MATERIALIZED VIEW emergency_orders OWNER TO postgres;