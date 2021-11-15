-- Olmis create table statements
-- Created by Craig Appl (cappl@ona.io)
-- Modified by A. Maritim (amaritim@ona.io) and J. Wambere (jwambere@ona.io)
-- Further modified by C. Ahn (chongsun.ahn@villagereach.org)
-- Last Updated 19 May 2020
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