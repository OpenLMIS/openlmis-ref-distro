--
-- PostgreSQL database dump
--

-- Dumped from database version 12.20 (Debian 12.20-1.pgdg110+1)
-- Dumped by pg_dump version 12.20 (Debian 12.20-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;


--
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: gen_random_uuid(); Type: FUNCTION; Schema: public; Owner: dhis
--

CREATE FUNCTION public.gen_random_uuid() RETURNS uuid
    LANGUAGE sql
    AS $$
        SELECT md5(random()::text || random()::text)::uuid
    $$;


ALTER FUNCTION public.gen_random_uuid() OWNER TO dhis;

--
-- Name: generate_uid(); Type: FUNCTION; Schema: public; Owner: dhis
--

CREATE FUNCTION public.generate_uid() RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
chars  text [] := '{0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z}';
 result text := chars [11 + random() * (array_length(chars, 1) - 11)];
begin
 for i in 1..10 loop
 result := result || chars [1 + random() * (array_length(chars, 1) - 1)];
 end loop;
return result;
end;
$$;


ALTER FUNCTION public.generate_uid() OWNER TO dhis;

--
-- Name: incrementsequentialcounter(text, text, integer); Type: FUNCTION; Schema: public; Owner: dhis
--

CREATE FUNCTION public.incrementsequentialcounter(counter_owner text, counter_key text, size integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
		current_counter integer;
	BEGIN
        INSERT INTO sequentialnumbercounter  (id, owneruid, key, counter)
        VALUES(nextval('hibernate_sequence'), counter_owner, counter_key, (1 + size) )

        ON CONFLICT (owneruid, key)
            DO
                UPDATE SET counter = (sequentialnumbercounter.counter + size)
                WHERE sequentialnumbercounter.owneruid = counter_owner
                AND sequentialnumbercounter.key = counter_key

        RETURNING counter INTO current_counter;

        RETURN current_counter;

	END;
$$;


ALTER FUNCTION public.incrementsequentialcounter(counter_owner text, counter_key text, size integer) OWNER TO dhis;

--
-- Name: jsonb_check_user_access(jsonb, text, text); Type: FUNCTION; Schema: public; Owner: dhis
--

CREATE FUNCTION public.jsonb_check_user_access(jsonb, text, text) RETURNS boolean
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
select  $1->'users'->$2->>'access' like $3
$_$;


ALTER FUNCTION public.jsonb_check_user_access(jsonb, text, text) OWNER TO dhis;

--
-- Name: jsonb_check_user_groups_access(jsonb, text, text); Type: FUNCTION; Schema: public; Owner: dhis
--

CREATE FUNCTION public.jsonb_check_user_groups_access(jsonb, text, text) RETURNS boolean
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT exists(
         SELECT 1
         FROM  jsonb_each($1->'userGroups') je
         WHERE je.key = ANY ($3::text[])
         AND je.value->>'access' LIKE $2
     );
$_$;


ALTER FUNCTION public.jsonb_check_user_groups_access(jsonb, text, text) OWNER TO dhis;

--
-- Name: jsonb_has_user_group_ids(jsonb, text); Type: FUNCTION; Schema: public; Owner: dhis
--

CREATE FUNCTION public.jsonb_has_user_group_ids(jsonb, text) RETURNS boolean
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT   $1->'userGroups' ?| $2::text[];
$_$;


ALTER FUNCTION public.jsonb_has_user_group_ids(jsonb, text) OWNER TO dhis;

--
-- Name: jsonb_has_user_id(jsonb, text); Type: FUNCTION; Schema: public; Owner: dhis
--

CREATE FUNCTION public.jsonb_has_user_id(jsonb, text) RETURNS boolean
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
select  $1->'users' ? $2
$_$;


ALTER FUNCTION public.jsonb_has_user_id(jsonb, text) OWNER TO dhis;

--
-- Name: regexp_search(character varying, character varying); Type: FUNCTION; Schema: public; Owner: dhis
--

CREATE FUNCTION public.regexp_search(character varying, character varying) RETURNS boolean
    LANGUAGE sql
    AS $_$select $1 ~* $2;$_$;


ALTER FUNCTION public.regexp_search(character varying, character varying) OWNER TO dhis;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: aggregatedataexchange; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.aggregatedataexchange (
    aggregatedataexchangeid bigint NOT NULL,
    uid character varying(11),
    code character varying(100),
    created timestamp without time zone,
    userid bigint,
    lastupdated timestamp without time zone,
    lastupdatedby bigint,
    translations jsonb,
    sharing jsonb DEFAULT '{}'::jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    name character varying(230) NOT NULL,
    source jsonb NOT NULL,
    target jsonb NOT NULL
);


ALTER TABLE public.aggregatedataexchange OWNER TO dhis;

--
-- Name: api_token; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.api_token (
    apitokenid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint NOT NULL,
    createdby bigint NOT NULL,
    version integer NOT NULL,
    type character varying(50) NOT NULL,
    expire bigint NOT NULL,
    key character varying(128) NOT NULL,
    attributes jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.api_token OWNER TO dhis;

--
-- Name: attribute; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.attribute (
    attributeid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    shortname character varying(50),
    description text,
    valuetype character varying(50) NOT NULL,
    mandatory boolean NOT NULL,
    isunique boolean,
    dataelementattribute boolean NOT NULL,
    dataelementgroupattribute boolean,
    indicatorattribute boolean NOT NULL,
    indicatorgroupattribute boolean,
    datasetattribute boolean,
    organisationunitattribute boolean NOT NULL,
    organisationunitgroupattribute boolean,
    organisationunitgroupsetattribute boolean,
    userattribute boolean NOT NULL,
    usergroupattribute boolean,
    programattribute boolean,
    programstageattribute boolean,
    trackedentitytypeattribute boolean,
    trackedentityattributeattribute boolean,
    categoryoptionattribute boolean,
    categoryoptiongroupattribute boolean,
    documentattribute boolean,
    optionattribute boolean,
    optionsetattribute boolean,
    constantattribute boolean,
    legendsetattribute boolean,
    programindicatorattribute boolean,
    sqlviewattribute boolean,
    sectionattribute boolean,
    categoryoptioncomboattribute boolean,
    categoryoptiongroupsetattribute boolean,
    dataelementgroupsetattribute boolean,
    validationruleattribute boolean,
    validationrulegroupattribute boolean,
    categoryattribute boolean,
    sortorder integer,
    optionsetid bigint,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    sharing jsonb DEFAULT '{}'::jsonb,
    visualizationattribute boolean DEFAULT false NOT NULL,
    mapattribute boolean DEFAULT false NOT NULL,
    eventreportattribute boolean DEFAULT false NOT NULL,
    eventchartattribute boolean DEFAULT false NOT NULL,
    relationshiptypeattribute boolean DEFAULT false NOT NULL
);


ALTER TABLE public.attribute OWNER TO dhis;

--
-- Name: attributevalue; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.attributevalue (
    attributevalueid bigint NOT NULL,
    created timestamp without time zone,
    lastupdated timestamp without time zone,
    value text,
    attributeid bigint NOT NULL
);


ALTER TABLE public.attributevalue OWNER TO dhis;

--
-- Name: audit; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.audit (
    auditid integer NOT NULL,
    audittype text NOT NULL,
    auditscope text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    createdby text NOT NULL,
    klass text,
    uid text,
    code text,
    attributes jsonb DEFAULT '{}'::jsonb,
    data bytea
);


ALTER TABLE public.audit OWNER TO dhis;

--
-- Name: audit_auditid_seq; Type: SEQUENCE; Schema: public; Owner: dhis
--

CREATE SEQUENCE public.audit_auditid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.audit_auditid_seq OWNER TO dhis;

--
-- Name: audit_auditid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dhis
--

ALTER SEQUENCE public.audit_auditid_seq OWNED BY public.audit.auditid;


--
-- Name: axis; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.axis (
    axisid bigint NOT NULL,
    dimensionalitem character varying(255) NOT NULL,
    axis integer NOT NULL
);


ALTER TABLE public.axis OWNER TO dhis;

--
-- Name: categories_categoryoptions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.categories_categoryoptions (
    categoryid bigint NOT NULL,
    sort_order integer NOT NULL,
    categoryoptionid bigint NOT NULL
);


ALTER TABLE public.categories_categoryoptions OWNER TO dhis;

--
-- Name: categorycombo; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.categorycombo (
    categorycomboid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    datadimensiontype character varying(255) NOT NULL,
    skiptotal boolean NOT NULL,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.categorycombo OWNER TO dhis;

--
-- Name: categorycombos_categories; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.categorycombos_categories (
    categoryid bigint,
    sort_order integer NOT NULL,
    categorycomboid bigint NOT NULL
);


ALTER TABLE public.categorycombos_categories OWNER TO dhis;

--
-- Name: categorycombos_optioncombos; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.categorycombos_optioncombos (
    categoryoptioncomboid bigint NOT NULL,
    categorycomboid bigint NOT NULL
);


ALTER TABLE public.categorycombos_optioncombos OWNER TO dhis;

--
-- Name: categorydimension; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.categorydimension (
    categorydimensionid integer NOT NULL,
    categoryid bigint
);


ALTER TABLE public.categorydimension OWNER TO dhis;

--
-- Name: categorydimension_items; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.categorydimension_items (
    categorydimensionid integer NOT NULL,
    sort_order integer NOT NULL,
    categoryoptionid bigint NOT NULL
);


ALTER TABLE public.categorydimension_items OWNER TO dhis;

--
-- Name: categoryoption_organisationunits; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.categoryoption_organisationunits (
    organisationunitid bigint NOT NULL,
    categoryoptionid bigint NOT NULL
);


ALTER TABLE public.categoryoption_organisationunits OWNER TO dhis;

--
-- Name: categoryoptioncombo; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.categoryoptioncombo (
    categoryoptioncomboid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name text,
    ignoreapproval boolean,
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.categoryoptioncombo OWNER TO dhis;

--
-- Name: categoryoptioncombos_categoryoptions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.categoryoptioncombos_categoryoptions (
    categoryoptioncomboid bigint NOT NULL,
    categoryoptionid bigint NOT NULL
);


ALTER TABLE public.categoryoptioncombos_categoryoptions OWNER TO dhis;

--
-- Name: categoryoptiongroup; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.categoryoptiongroup (
    categoryoptiongroupid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    shortname character varying(50) NOT NULL,
    datadimensiontype character varying(255),
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.categoryoptiongroup OWNER TO dhis;

--
-- Name: categoryoptiongroupmembers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.categoryoptiongroupmembers (
    categoryoptiongroupid bigint NOT NULL,
    categoryoptionid bigint NOT NULL
);


ALTER TABLE public.categoryoptiongroupmembers OWNER TO dhis;

--
-- Name: categoryoptiongroupset; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.categoryoptiongroupset (
    categoryoptiongroupsetid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    datadimension boolean NOT NULL,
    datadimensiontype character varying(255),
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb,
    shortname character varying(50) NOT NULL
);


ALTER TABLE public.categoryoptiongroupset OWNER TO dhis;

--
-- Name: categoryoptiongroupsetdimension; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.categoryoptiongroupsetdimension (
    categoryoptiongroupsetdimensionid integer NOT NULL,
    categoryoptiongroupsetid bigint
);


ALTER TABLE public.categoryoptiongroupsetdimension OWNER TO dhis;

--
-- Name: categoryoptiongroupsetdimension_items; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.categoryoptiongroupsetdimension_items (
    categoryoptiongroupsetdimensionid integer NOT NULL,
    sort_order integer NOT NULL,
    categoryoptiongroupid bigint NOT NULL
);


ALTER TABLE public.categoryoptiongroupsetdimension_items OWNER TO dhis;

--
-- Name: categoryoptiongroupsetmembers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.categoryoptiongroupsetmembers (
    categoryoptiongroupid bigint,
    categoryoptiongroupsetid bigint NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.categoryoptiongroupsetmembers OWNER TO dhis;

--
-- Name: completedatasetregistration; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.completedatasetregistration (
    datasetid bigint NOT NULL,
    periodid bigint NOT NULL,
    sourceid bigint NOT NULL,
    attributeoptioncomboid bigint NOT NULL,
    date timestamp without time zone,
    storedby character varying(255),
    lastupdatedby character varying(255),
    lastupdated timestamp without time zone,
    completed boolean NOT NULL
);


ALTER TABLE public.completedatasetregistration OWNER TO dhis;

--
-- Name: configuration; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.configuration (
    configurationid integer NOT NULL,
    systemid character varying(255),
    feedbackrecipientsid bigint,
    offlineorgunitlevelid bigint,
    infrastructuralindicatorsid bigint,
    infrastructuraldataelementsid bigint,
    infrastructuralperiodtypeid integer,
    selfregistrationrole bigint,
    selfregistrationorgunit bigint,
    facilityorgunitgroupset bigint,
    facilityorgunitlevel bigint,
    systemupdatenotificationrecipientsid bigint
);


ALTER TABLE public.configuration OWNER TO dhis;

--
-- Name: configuration_corswhitelist; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.configuration_corswhitelist (
    configurationid integer NOT NULL,
    corswhitelist character varying(255)
);

ALTER TABLE ONLY public.configuration_corswhitelist REPLICA IDENTITY FULL;


ALTER TABLE public.configuration_corswhitelist OWNER TO dhis;

--
-- Name: constant; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.constant (
    constantid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    shortname character varying(50),
    description text,
    value double precision NOT NULL,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.constant OWNER TO dhis;

--
-- Name: dashboard; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dashboard (
    dashboardid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    userid bigint,
    externalaccess boolean,
    publicaccess character varying(8),
    favorites jsonb,
    translations jsonb,
    sharing jsonb DEFAULT '{}'::jsonb,
    restrictfilters boolean NOT NULL,
    allowedfilters jsonb,
    layout jsonb,
    itemconfig jsonb
);


ALTER TABLE public.dashboard OWNER TO dhis;

--
-- Name: dashboard_items; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dashboard_items (
    dashboardid bigint NOT NULL,
    sort_order integer NOT NULL,
    dashboarditemid bigint NOT NULL
);


ALTER TABLE public.dashboard_items OWNER TO dhis;

--
-- Name: dashboarditem; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dashboarditem (
    dashboarditemid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    eventchartid bigint,
    mapid bigint,
    textcontent text,
    messages boolean,
    appkey character varying(255),
    shape character varying(50),
    x integer,
    y integer,
    height integer,
    width integer,
    eventreport bigint,
    translations jsonb,
    visualizationid bigint,
    eventvisualizationid bigint
);


ALTER TABLE public.dashboarditem OWNER TO dhis;

--
-- Name: dashboarditem_reports; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dashboarditem_reports (
    dashboarditemid bigint NOT NULL,
    sort_order integer NOT NULL,
    reportid bigint NOT NULL
);


ALTER TABLE public.dashboarditem_reports OWNER TO dhis;

--
-- Name: dashboarditem_resources; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dashboarditem_resources (
    dashboarditemid bigint NOT NULL,
    sort_order integer NOT NULL,
    resourceid bigint NOT NULL
);


ALTER TABLE public.dashboarditem_resources OWNER TO dhis;

--
-- Name: dashboarditem_users; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dashboarditem_users (
    dashboarditemid bigint NOT NULL,
    sort_order integer NOT NULL,
    userid bigint NOT NULL
);


ALTER TABLE public.dashboarditem_users OWNER TO dhis;

--
-- Name: dataapproval; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataapproval (
    dataapprovalid bigint NOT NULL,
    dataapprovallevelid bigint NOT NULL,
    workflowid bigint NOT NULL,
    periodid bigint NOT NULL,
    organisationunitid bigint NOT NULL,
    attributeoptioncomboid bigint NOT NULL,
    accepted boolean NOT NULL,
    created timestamp without time zone NOT NULL,
    creator bigint NOT NULL,
    lastupdated timestamp without time zone,
    lastupdatedby bigint
);


ALTER TABLE public.dataapproval OWNER TO dhis;

--
-- Name: dataapprovalaudit; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataapprovalaudit (
    dataapprovalauditid bigint NOT NULL,
    levelid bigint NOT NULL,
    workflowid bigint NOT NULL,
    periodid bigint NOT NULL,
    organisationunitid bigint NOT NULL,
    attributeoptioncomboid bigint NOT NULL,
    action character varying(100) NOT NULL,
    created timestamp without time zone NOT NULL,
    creator bigint NOT NULL
);


ALTER TABLE public.dataapprovalaudit OWNER TO dhis;

--
-- Name: dataapprovallevel; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataapprovallevel (
    dataapprovallevelid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    level integer NOT NULL,
    orgunitlevel integer NOT NULL,
    categoryoptiongroupsetid bigint,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.dataapprovallevel OWNER TO dhis;

--
-- Name: dataapprovalworkflow; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataapprovalworkflow (
    workflowid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    periodtypeid integer NOT NULL,
    categorycomboid bigint,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.dataapprovalworkflow OWNER TO dhis;

--
-- Name: dataapprovalworkflowlevels; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataapprovalworkflowlevels (
    workflowid bigint NOT NULL,
    dataapprovallevelid bigint NOT NULL
);


ALTER TABLE public.dataapprovalworkflowlevels OWNER TO dhis;

--
-- Name: datadimensionitem; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.datadimensionitem (
    datadimensionitemid integer NOT NULL,
    indicatorid bigint,
    dataelementid bigint,
    dataelementoperand_dataelementid bigint,
    dataelementoperand_categoryoptioncomboid bigint,
    datasetid bigint,
    metric character varying(50),
    programindicatorid bigint,
    programdataelement_programid bigint,
    programdataelement_dataelementid bigint,
    programattribute_programid bigint,
    programattribute_attributeid bigint
);


ALTER TABLE public.datadimensionitem OWNER TO dhis;

--
-- Name: dataelement; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataelement (
    dataelementid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    shortname character varying(50) NOT NULL,
    description text,
    formname character varying(230),
    style jsonb,
    valuetype character varying(50) NOT NULL,
    domaintype character varying(255) NOT NULL,
    aggregationtype character varying(50) NOT NULL,
    categorycomboid bigint NOT NULL,
    url character varying(255),
    zeroissignificant boolean NOT NULL,
    optionsetid bigint,
    commentoptionsetid bigint,
    userid bigint,
    publicaccess character varying(8),
    fieldmask character varying(255),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb,
    valuetypeoptions jsonb
);


ALTER TABLE public.dataelement OWNER TO dhis;

--
-- Name: dataelementaggregationlevels; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataelementaggregationlevels (
    dataelementid bigint NOT NULL,
    sort_order integer NOT NULL,
    aggregationlevel integer
);


ALTER TABLE public.dataelementaggregationlevels OWNER TO dhis;

--
-- Name: dataelementcategory; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataelementcategory (
    categoryid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    datadimensiontype character varying(255) NOT NULL,
    datadimension boolean NOT NULL,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb,
    shortname character varying(50) NOT NULL
);


ALTER TABLE public.dataelementcategory OWNER TO dhis;

--
-- Name: dataelementcategoryoption; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataelementcategoryoption (
    categoryoptionid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    shortname character varying(50),
    startdate date,
    enddate date,
    style jsonb,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    formname character varying(230),
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb,
    description text
);


ALTER TABLE public.dataelementcategoryoption OWNER TO dhis;

--
-- Name: dataelementgroup; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataelementgroup (
    dataelementgroupid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    shortname character varying(50),
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    description text,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.dataelementgroup OWNER TO dhis;

--
-- Name: dataelementgroupmembers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataelementgroupmembers (
    dataelementid bigint NOT NULL,
    dataelementgroupid bigint NOT NULL
);


ALTER TABLE public.dataelementgroupmembers OWNER TO dhis;

--
-- Name: dataelementgroupset; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataelementgroupset (
    dataelementgroupsetid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    compulsory boolean,
    datadimension boolean NOT NULL,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb,
    shortname character varying(50) NOT NULL
);


ALTER TABLE public.dataelementgroupset OWNER TO dhis;

--
-- Name: dataelementgroupsetdimension; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataelementgroupsetdimension (
    dataelementgroupsetdimensionid integer NOT NULL,
    dataelementgroupsetid bigint
);


ALTER TABLE public.dataelementgroupsetdimension OWNER TO dhis;

--
-- Name: dataelementgroupsetdimension_items; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataelementgroupsetdimension_items (
    dataelementgroupsetdimensionid integer NOT NULL,
    sort_order integer NOT NULL,
    dataelementgroupid bigint NOT NULL
);


ALTER TABLE public.dataelementgroupsetdimension_items OWNER TO dhis;

--
-- Name: dataelementgroupsetmembers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataelementgroupsetmembers (
    dataelementgroupsetid bigint NOT NULL,
    sort_order integer NOT NULL,
    dataelementgroupid bigint NOT NULL
);


ALTER TABLE public.dataelementgroupsetmembers OWNER TO dhis;

--
-- Name: dataelementlegendsets; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataelementlegendsets (
    dataelementid bigint NOT NULL,
    sort_order integer NOT NULL,
    legendsetid bigint NOT NULL
);


ALTER TABLE public.dataelementlegendsets OWNER TO dhis;

--
-- Name: dataelementoperand; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataelementoperand (
    dataelementoperandid bigint NOT NULL,
    dataelementid bigint,
    categoryoptioncomboid bigint
);


ALTER TABLE public.dataelementoperand OWNER TO dhis;

--
-- Name: dataentryform; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataentryform (
    dataentryformid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(160) NOT NULL,
    style character varying(40),
    htmlcode text,
    format integer,
    translations jsonb
);


ALTER TABLE public.dataentryform OWNER TO dhis;

--
-- Name: datainputperiod; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.datainputperiod (
    datainputperiodid integer NOT NULL,
    periodid bigint NOT NULL,
    openingdate timestamp without time zone,
    closingdate timestamp without time zone,
    datasetid bigint
);


ALTER TABLE public.datainputperiod OWNER TO dhis;

--
-- Name: dataset; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.dataset (
    datasetid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    shortname character varying(50),
    description text,
    formname text,
    style jsonb,
    periodtypeid integer NOT NULL,
    categorycomboid bigint NOT NULL,
    mobile boolean NOT NULL,
    version integer,
    expirydays integer,
    timelydays integer,
    notifycompletinguser boolean,
    workflowid bigint,
    openfutureperiods integer,
    fieldcombinationrequired boolean,
    validcompleteonly boolean,
    novaluerequirescomment boolean,
    skipoffline boolean,
    dataelementdecoration boolean,
    renderastabs boolean,
    renderhorizontally boolean,
    compulsoryfieldscompleteonly boolean,
    userid bigint,
    publicaccess character varying(8),
    dataentryform bigint,
    notificationrecipients bigint,
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    openperiodsaftercoenddate integer DEFAULT 0,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.dataset OWNER TO dhis;

--
-- Name: datasetelement; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.datasetelement (
    datasetelementid integer NOT NULL,
    datasetid bigint,
    dataelementid bigint NOT NULL,
    categorycomboid bigint
);


ALTER TABLE public.datasetelement OWNER TO dhis;

--
-- Name: datasetindicators; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.datasetindicators (
    indicatorid bigint NOT NULL,
    datasetid bigint NOT NULL
);


ALTER TABLE public.datasetindicators OWNER TO dhis;

--
-- Name: datasetlegendsets; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.datasetlegendsets (
    datasetid bigint NOT NULL,
    sort_order integer NOT NULL,
    legendsetid bigint NOT NULL
);


ALTER TABLE public.datasetlegendsets OWNER TO dhis;

--
-- Name: datasetnotification_datasets; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.datasetnotification_datasets (
    datasetnotificationtemplateid bigint NOT NULL,
    datasetid bigint NOT NULL
);


ALTER TABLE public.datasetnotification_datasets OWNER TO dhis;

--
-- Name: datasetnotificationtemplate; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.datasetnotificationtemplate (
    datasetnotificationtemplateid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    subjecttemplate character varying(100),
    messagetemplate text NOT NULL,
    relativescheduleddays integer,
    notifyparentorganisationunitonly boolean,
    notifyusersinhierarchyonly boolean,
    sendstrategy character varying(50),
    usergroupid bigint,
    datasetnotificationtrigger character varying(255),
    notificationrecipienttype character varying(255),
    translations jsonb DEFAULT '[]'::jsonb
);


ALTER TABLE public.datasetnotificationtemplate OWNER TO dhis;

--
-- Name: datasetnotificationtemplate_deliverychannel; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.datasetnotificationtemplate_deliverychannel (
    datasetnotificationtemplateid bigint NOT NULL,
    deliverychannel character varying(255)
);

ALTER TABLE ONLY public.datasetnotificationtemplate_deliverychannel REPLICA IDENTITY FULL;


ALTER TABLE public.datasetnotificationtemplate_deliverychannel OWNER TO dhis;

--
-- Name: datasetoperands; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.datasetoperands (
    datasetid bigint NOT NULL,
    dataelementoperandid bigint NOT NULL
);


ALTER TABLE public.datasetoperands OWNER TO dhis;

--
-- Name: datasetsource; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.datasetsource (
    sourceid bigint NOT NULL,
    datasetid bigint NOT NULL
);


ALTER TABLE public.datasetsource OWNER TO dhis;

--
-- Name: datastatistics; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.datastatistics (
    statisticsid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    mapviews double precision,
    eventreportviews double precision,
    eventchartviews double precision,
    dashboardviews double precision,
    datasetreportviews double precision,
    active_users integer,
    totalviews double precision,
    maps double precision,
    eventreports double precision,
    eventcharts double precision,
    dashboards double precision,
    indicators double precision,
    datavalues double precision,
    users integer,
    visualizationviews double precision,
    visualizations double precision,
    passivedashboardviews double precision,
    eventvisualizationviews double precision,
    eventvisualizations double precision
);


ALTER TABLE public.datastatistics OWNER TO dhis;

--
-- Name: datastatisticsevent; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.datastatisticsevent (
    eventid integer NOT NULL,
    eventtype character varying,
    "timestamp" timestamp without time zone,
    username character varying(255),
    favoriteuid character varying(255)
);


ALTER TABLE public.datastatisticsevent OWNER TO dhis;

--
-- Name: datavalue; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.datavalue (
    dataelementid bigint NOT NULL,
    periodid bigint NOT NULL,
    sourceid bigint NOT NULL,
    categoryoptioncomboid bigint NOT NULL,
    attributeoptioncomboid bigint NOT NULL,
    value character varying(50000),
    storedby character varying(255),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    comment character varying(50000),
    followup boolean,
    deleted boolean NOT NULL
);


ALTER TABLE public.datavalue OWNER TO dhis;

--
-- Name: datavalueaudit; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.datavalueaudit (
    datavalueauditid bigint NOT NULL,
    dataelementid bigint NOT NULL,
    periodid bigint NOT NULL,
    organisationunitid bigint NOT NULL,
    categoryoptioncomboid bigint NOT NULL,
    attributeoptioncomboid bigint NOT NULL,
    value character varying(50000),
    created timestamp without time zone,
    modifiedby character varying(100),
    audittype character varying(100) NOT NULL
);


ALTER TABLE public.datavalueaudit OWNER TO dhis;

--
-- Name: datavalueaudit_sequence; Type: SEQUENCE; Schema: public; Owner: dhis
--

CREATE SEQUENCE public.datavalueaudit_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.datavalueaudit_sequence OWNER TO dhis;

--
-- Name: deletedobject; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.deletedobject (
    deletedobjectid bigint NOT NULL,
    klass character varying(255) NOT NULL,
    uid character varying(255) NOT NULL,
    code character varying(255),
    deleted_at timestamp without time zone NOT NULL,
    deleted_by character varying(255)
);


ALTER TABLE public.deletedobject OWNER TO dhis;

--
-- Name: deletedobject_sequence; Type: SEQUENCE; Schema: public; Owner: dhis
--

CREATE SEQUENCE public.deletedobject_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.deletedobject_sequence OWNER TO dhis;

--
-- Name: document; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.document (
    documentid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    url text NOT NULL,
    fileresource bigint,
    external boolean NOT NULL,
    contenttype character varying(255),
    attachment boolean,
    externalaccess boolean,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.document OWNER TO dhis;

--
-- Name: eventchart; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventchart (
    eventchartid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    relativeperiodsid integer,
    userorganisationunit boolean,
    userorganisationunitchildren boolean,
    userorganisationunitgrandchildren boolean,
    programid bigint NOT NULL,
    programstageid bigint,
    startdate timestamp without time zone,
    enddate timestamp without time zone,
    dataelementvaluedimensionid bigint,
    attributevaluedimensionid bigint,
    aggregationtype character varying(40),
    completedonly boolean,
    timefield character varying(255),
    title character varying(255),
    subtitle character varying(255),
    hidetitle boolean,
    hidesubtitle boolean,
    type character varying(40) NOT NULL,
    showdata boolean,
    hideemptyrowitems character varying(40),
    hidenadata boolean,
    programstatus character varying(40),
    eventstatus character varying(40),
    percentstackedvalues boolean,
    cumulativevalues boolean,
    rangeaxismaxvalue double precision,
    rangeaxisminvalue double precision,
    rangeaxissteps integer,
    rangeaxisdecimals integer,
    outputtype character varying(30),
    collapsedatadimensions boolean,
    domainaxislabel character varying(255),
    rangeaxislabel character varying(255),
    hidelegend boolean,
    nospacebetweencolumns boolean,
    regressiontype character varying(40) NOT NULL,
    targetlinevalue double precision,
    targetlinelabel character varying(255),
    baselinevalue double precision,
    baselinelabel character varying(255),
    sortorder integer,
    externalaccess boolean,
    userid bigint,
    publicaccess character varying(8),
    favorites jsonb,
    subscribers jsonb,
    translations jsonb,
    orgunitfield character varying(255),
    userorgunittype character varying(20),
    sharing jsonb DEFAULT '{}'::jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.eventchart OWNER TO dhis;

--
-- Name: eventchart_attributedimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventchart_attributedimensions (
    eventchartid bigint NOT NULL,
    sort_order integer NOT NULL,
    trackedentityattributedimensionid integer NOT NULL
);


ALTER TABLE public.eventchart_attributedimensions OWNER TO dhis;

--
-- Name: eventchart_categorydimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventchart_categorydimensions (
    eventchartid bigint NOT NULL,
    sort_order integer NOT NULL,
    categorydimensionid integer NOT NULL
);


ALTER TABLE public.eventchart_categorydimensions OWNER TO dhis;

--
-- Name: eventchart_categoryoptiongroupsetdimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventchart_categoryoptiongroupsetdimensions (
    eventchartid bigint NOT NULL,
    sort_order integer NOT NULL,
    categoryoptiongroupsetdimensionid integer NOT NULL
);


ALTER TABLE public.eventchart_categoryoptiongroupsetdimensions OWNER TO dhis;

--
-- Name: eventchart_columns; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventchart_columns (
    eventchartid bigint NOT NULL,
    sort_order integer NOT NULL,
    dimension character varying(255)
);


ALTER TABLE public.eventchart_columns OWNER TO dhis;

--
-- Name: eventchart_dataelementdimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventchart_dataelementdimensions (
    eventchartid bigint NOT NULL,
    sort_order integer NOT NULL,
    trackedentitydataelementdimensionid integer NOT NULL
);


ALTER TABLE public.eventchart_dataelementdimensions OWNER TO dhis;

--
-- Name: eventchart_filters; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventchart_filters (
    eventchartid bigint NOT NULL,
    sort_order integer NOT NULL,
    dimension character varying(255)
);


ALTER TABLE public.eventchart_filters OWNER TO dhis;

--
-- Name: eventchart_itemorgunitgroups; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventchart_itemorgunitgroups (
    eventchartid bigint NOT NULL,
    sort_order integer NOT NULL,
    orgunitgroupid bigint NOT NULL
);


ALTER TABLE public.eventchart_itemorgunitgroups OWNER TO dhis;

--
-- Name: eventchart_organisationunits; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventchart_organisationunits (
    eventchartid bigint NOT NULL,
    sort_order integer NOT NULL,
    organisationunitid bigint NOT NULL
);


ALTER TABLE public.eventchart_organisationunits OWNER TO dhis;

--
-- Name: eventchart_orgunitgroupsetdimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventchart_orgunitgroupsetdimensions (
    eventchartid bigint NOT NULL,
    sort_order integer NOT NULL,
    orgunitgroupsetdimensionid integer NOT NULL
);


ALTER TABLE public.eventchart_orgunitgroupsetdimensions OWNER TO dhis;

--
-- Name: eventchart_orgunitlevels; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventchart_orgunitlevels (
    eventchartid bigint NOT NULL,
    sort_order integer NOT NULL,
    orgunitlevel integer
);


ALTER TABLE public.eventchart_orgunitlevels OWNER TO dhis;

--
-- Name: eventchart_periods; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventchart_periods (
    eventchartid bigint NOT NULL,
    sort_order integer NOT NULL,
    periodid bigint NOT NULL
);


ALTER TABLE public.eventchart_periods OWNER TO dhis;

--
-- Name: eventchart_programindicatordimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventchart_programindicatordimensions (
    eventchartid bigint NOT NULL,
    sort_order integer NOT NULL,
    trackedentityprogramindicatordimensionid integer NOT NULL
);


ALTER TABLE public.eventchart_programindicatordimensions OWNER TO dhis;

--
-- Name: eventchart_rows; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventchart_rows (
    eventchartid bigint NOT NULL,
    sort_order integer NOT NULL,
    dimension character varying(255)
);


ALTER TABLE public.eventchart_rows OWNER TO dhis;

--
-- Name: eventreport; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventreport (
    eventreportid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    relativeperiodsid integer,
    userorganisationunit boolean,
    userorganisationunitchildren boolean,
    userorganisationunitgrandchildren boolean,
    programid bigint NOT NULL,
    programstageid bigint,
    startdate timestamp without time zone,
    enddate timestamp without time zone,
    dataelementvaluedimensionid bigint,
    attributevaluedimensionid bigint,
    aggregationtype character varying(40),
    completedonly boolean,
    timefield character varying(255),
    title character varying(255),
    subtitle character varying(255),
    hidetitle boolean,
    hidesubtitle boolean,
    datatype character varying(40),
    rowtotals boolean,
    coltotals boolean,
    rowsubtotals boolean,
    colsubtotals boolean,
    hideemptyrows boolean,
    hidenadata boolean,
    showhierarchy boolean,
    outputtype character varying(30),
    collapsedatadimensions boolean,
    showdimensionlabels boolean,
    digitgroupseparator character varying(40),
    displaydensity character varying(40),
    fontsize character varying(40),
    programstatus character varying(40),
    eventstatus character varying(40),
    sortorder integer,
    toplimit integer,
    externalaccess boolean,
    userid bigint,
    publicaccess character varying(8),
    favorites jsonb,
    subscribers jsonb,
    translations jsonb,
    orgunitfield character varying(255),
    userorgunittype character varying(20),
    sharing jsonb DEFAULT '{}'::jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    simpledimensions jsonb
);


ALTER TABLE public.eventreport OWNER TO dhis;

--
-- Name: eventreport_attributedimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventreport_attributedimensions (
    eventreportid bigint NOT NULL,
    sort_order integer NOT NULL,
    trackedentityattributedimensionid integer NOT NULL
);


ALTER TABLE public.eventreport_attributedimensions OWNER TO dhis;

--
-- Name: eventreport_categorydimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventreport_categorydimensions (
    eventreportid bigint NOT NULL,
    sort_order integer NOT NULL,
    categorydimensionid integer NOT NULL
);


ALTER TABLE public.eventreport_categorydimensions OWNER TO dhis;

--
-- Name: eventreport_categoryoptiongroupsetdimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventreport_categoryoptiongroupsetdimensions (
    eventreportid bigint NOT NULL,
    sort_order integer NOT NULL,
    categoryoptiongroupsetdimensionid integer NOT NULL
);


ALTER TABLE public.eventreport_categoryoptiongroupsetdimensions OWNER TO dhis;

--
-- Name: eventreport_columns; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventreport_columns (
    eventreportid bigint NOT NULL,
    sort_order integer NOT NULL,
    dimension character varying(255)
);


ALTER TABLE public.eventreport_columns OWNER TO dhis;

--
-- Name: eventreport_dataelementdimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventreport_dataelementdimensions (
    eventreportid bigint NOT NULL,
    sort_order integer NOT NULL,
    trackedentitydataelementdimensionid integer NOT NULL
);


ALTER TABLE public.eventreport_dataelementdimensions OWNER TO dhis;

--
-- Name: eventreport_filters; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventreport_filters (
    eventreportid bigint NOT NULL,
    sort_order integer NOT NULL,
    dimension character varying(255)
);


ALTER TABLE public.eventreport_filters OWNER TO dhis;

--
-- Name: eventreport_itemorgunitgroups; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventreport_itemorgunitgroups (
    eventreportid bigint NOT NULL,
    sort_order integer NOT NULL,
    orgunitgroupid bigint NOT NULL
);


ALTER TABLE public.eventreport_itemorgunitgroups OWNER TO dhis;

--
-- Name: eventreport_organisationunits; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventreport_organisationunits (
    eventreportid bigint NOT NULL,
    sort_order integer NOT NULL,
    organisationunitid bigint NOT NULL
);


ALTER TABLE public.eventreport_organisationunits OWNER TO dhis;

--
-- Name: eventreport_orgunitgroupsetdimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventreport_orgunitgroupsetdimensions (
    eventreportid bigint NOT NULL,
    sort_order integer NOT NULL,
    orgunitgroupsetdimensionid integer NOT NULL
);


ALTER TABLE public.eventreport_orgunitgroupsetdimensions OWNER TO dhis;

--
-- Name: eventreport_orgunitlevels; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventreport_orgunitlevels (
    eventreportid bigint NOT NULL,
    sort_order integer NOT NULL,
    orgunitlevel integer
);


ALTER TABLE public.eventreport_orgunitlevels OWNER TO dhis;

--
-- Name: eventreport_periods; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventreport_periods (
    eventreportid bigint NOT NULL,
    sort_order integer NOT NULL,
    periodid bigint NOT NULL
);


ALTER TABLE public.eventreport_periods OWNER TO dhis;

--
-- Name: eventreport_programindicatordimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventreport_programindicatordimensions (
    eventreportid bigint NOT NULL,
    sort_order integer NOT NULL,
    trackedentityprogramindicatordimensionid integer NOT NULL
);


ALTER TABLE public.eventreport_programindicatordimensions OWNER TO dhis;

--
-- Name: eventreport_rows; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventreport_rows (
    eventreportid bigint NOT NULL,
    sort_order integer NOT NULL,
    dimension character varying(255)
);


ALTER TABLE public.eventreport_rows OWNER TO dhis;

--
-- Name: eventvisualization; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventvisualization (
    eventvisualizationid bigint NOT NULL,
    uid character varying(11),
    code character varying(50),
    created timestamp without time zone,
    lastupdated timestamp without time zone,
    name character varying(230) NOT NULL,
    relativeperiodsid integer,
    userorganisationunit boolean,
    userorganisationunitchildren boolean,
    userorganisationunitgrandchildren boolean,
    externalaccess boolean,
    userid bigint,
    publicaccess character varying(8),
    programid bigint NOT NULL,
    programstageid bigint,
    startdate timestamp without time zone,
    enddate timestamp without time zone,
    sortorder integer,
    toplimit integer,
    outputtype character varying(30),
    dataelementvaluedimensionid bigint,
    attributevaluedimensionid bigint,
    aggregationtype character varying(30),
    collapsedatadimensions boolean,
    hidenadata boolean,
    completedonly boolean,
    description text,
    title character varying(255),
    lastupdatedby bigint,
    subtitle character varying(255),
    hidetitle boolean,
    hidesubtitle boolean,
    programstatus character varying(40),
    eventstatus character varying(40),
    favorites jsonb,
    subscribers jsonb,
    timefield character varying(255),
    translations jsonb,
    orgunitfield character varying(255),
    userorgunittype character varying(20),
    sharing jsonb DEFAULT '{}'::jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    type character varying(255) NOT NULL,
    showdata boolean,
    rangeaxismaxvalue double precision,
    rangeaxisminvalue double precision,
    rangeaxissteps integer,
    rangeaxisdecimals integer,
    domainaxislabel character varying(255),
    rangeaxislabel character varying(255),
    hidelegend boolean,
    targetlinevalue double precision,
    targetlinelabel character varying(255),
    baselinevalue double precision,
    baselinelabel character varying(255),
    regressiontype character varying(40),
    hideemptyrowitems character varying(40),
    percentstackedvalues boolean,
    cumulativevalues boolean,
    nospacebetweencolumns boolean,
    datatype character varying(230),
    hideemptyrows boolean,
    digitgroupseparator character varying(255),
    displaydensity character varying(255),
    fontsize character varying(255),
    showhierarchy boolean,
    rowtotals boolean,
    coltotals boolean,
    showdimensionlabels boolean,
    rowsubtotals boolean,
    colsubtotals boolean,
    legacy boolean,
    simpledimensions jsonb,
    eventrepetitions jsonb,
    legendsetid bigint,
    legenddisplaystrategy character varying(40),
    legenddisplaystyle character varying(40),
    legendshowkey boolean,
    skiprounding boolean DEFAULT false NOT NULL,
    sorting jsonb DEFAULT '[]'::jsonb
);


ALTER TABLE public.eventvisualization OWNER TO dhis;

--
-- Name: eventvisualization_attributedimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventvisualization_attributedimensions (
    eventvisualizationid bigint NOT NULL,
    trackedentityattributedimensionid integer NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.eventvisualization_attributedimensions OWNER TO dhis;

--
-- Name: eventvisualization_categorydimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventvisualization_categorydimensions (
    eventvisualizationid bigint NOT NULL,
    sort_order integer NOT NULL,
    categorydimensionid integer NOT NULL
);


ALTER TABLE public.eventvisualization_categorydimensions OWNER TO dhis;

--
-- Name: eventvisualization_categoryoptiongroupsetdimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventvisualization_categoryoptiongroupsetdimensions (
    eventvisualizationid bigint NOT NULL,
    sort_order integer NOT NULL,
    categoryoptiongroupsetdimensionid integer NOT NULL
);


ALTER TABLE public.eventvisualization_categoryoptiongroupsetdimensions OWNER TO dhis;

--
-- Name: eventvisualization_columns; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventvisualization_columns (
    eventvisualizationid bigint NOT NULL,
    dimension character varying(255),
    sort_order integer NOT NULL
);


ALTER TABLE public.eventvisualization_columns OWNER TO dhis;

--
-- Name: eventvisualization_dataelementdimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventvisualization_dataelementdimensions (
    eventvisualizationid bigint NOT NULL,
    trackedentitydataelementdimensionid integer NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.eventvisualization_dataelementdimensions OWNER TO dhis;

--
-- Name: eventvisualization_filters; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventvisualization_filters (
    eventvisualizationid bigint NOT NULL,
    dimension character varying(255),
    sort_order integer NOT NULL
);


ALTER TABLE public.eventvisualization_filters OWNER TO dhis;

--
-- Name: eventvisualization_itemorgunitgroups; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventvisualization_itemorgunitgroups (
    eventvisualizationid bigint NOT NULL,
    orgunitgroupid bigint NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.eventvisualization_itemorgunitgroups OWNER TO dhis;

--
-- Name: eventvisualization_organisationunits; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventvisualization_organisationunits (
    eventvisualizationid bigint NOT NULL,
    organisationunitid bigint NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.eventvisualization_organisationunits OWNER TO dhis;

--
-- Name: eventvisualization_orgunitgroupsetdimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventvisualization_orgunitgroupsetdimensions (
    eventvisualizationid bigint NOT NULL,
    sort_order integer NOT NULL,
    orgunitgroupsetdimensionid integer NOT NULL
);


ALTER TABLE public.eventvisualization_orgunitgroupsetdimensions OWNER TO dhis;

--
-- Name: eventvisualization_orgunitlevels; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventvisualization_orgunitlevels (
    eventvisualizationid bigint NOT NULL,
    orgunitlevel integer,
    sort_order integer NOT NULL
);


ALTER TABLE public.eventvisualization_orgunitlevels OWNER TO dhis;

--
-- Name: eventvisualization_periods; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventvisualization_periods (
    eventvisualizationid bigint NOT NULL,
    periodid bigint NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.eventvisualization_periods OWNER TO dhis;

--
-- Name: eventvisualization_programindicatordimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventvisualization_programindicatordimensions (
    eventvisualizationid bigint NOT NULL,
    trackedentityprogramindicatordimensionid integer NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.eventvisualization_programindicatordimensions OWNER TO dhis;

--
-- Name: eventvisualization_rows; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.eventvisualization_rows (
    eventvisualizationid bigint NOT NULL,
    dimension character varying(255),
    sort_order integer NOT NULL
);


ALTER TABLE public.eventvisualization_rows OWNER TO dhis;

--
-- Name: expression; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.expression (
    expressionid bigint NOT NULL,
    description character varying(255),
    expression text,
    slidingwindow boolean,
    missingvaluestrategy character varying(100) NOT NULL,
    translations jsonb DEFAULT '[]'::jsonb
);


ALTER TABLE public.expression OWNER TO dhis;

--
-- Name: externalfileresource; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.externalfileresource (
    externalfileresourceid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    accesstoken character varying(255),
    expires timestamp without time zone,
    fileresourceid bigint NOT NULL
);


ALTER TABLE public.externalfileresource OWNER TO dhis;

--
-- Name: externalmaplayer; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.externalmaplayer (
    externalmaplayerid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    attribution text,
    url text NOT NULL,
    legendseturl text,
    maplayerposition bytea NOT NULL,
    layers text,
    imageformat bytea NOT NULL,
    mapservice bytea NOT NULL,
    legendsetid bigint,
    userid bigint,
    publicaccess character varying(8),
    sharing jsonb DEFAULT '{}'::jsonb,
    translations jsonb DEFAULT '[]'::jsonb
);


ALTER TABLE public.externalmaplayer OWNER TO dhis;

--
-- Name: externalnotificationlogentry; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.externalnotificationlogentry (
    externalnotificationlogentryid bigint NOT NULL,
    uid character varying(11),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastsentat timestamp without time zone,
    retries integer,
    key text NOT NULL,
    templateuid text NOT NULL,
    allowmultiple boolean,
    triggerby character varying(255)
);


ALTER TABLE public.externalnotificationlogentry OWNER TO dhis;

--
-- Name: fileresource; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.fileresource (
    fileresourceid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    contenttype character varying(255) NOT NULL,
    contentlength bigint NOT NULL,
    contentmd5 character varying(32) NOT NULL,
    storagekey character varying(1024) NOT NULL,
    isassigned boolean NOT NULL,
    domain character varying(40),
    userid bigint,
    hasmultiplestoragefiles boolean,
    fileresourceowner character varying(255)
);


ALTER TABLE public.fileresource OWNER TO dhis;

--
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_schema_history OWNER TO dhis;

--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: public; Owner: dhis
--

CREATE SEQUENCE public.hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hibernate_sequence OWNER TO dhis;

--
-- Name: i18nlocale; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.i18nlocale (
    i18nlocaleid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(250) NOT NULL,
    locale character varying(15) NOT NULL
);


ALTER TABLE public.i18nlocale OWNER TO dhis;

--
-- Name: incomingsms; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.incomingsms (
    id bigint NOT NULL,
    originator character varying(255) NOT NULL,
    encoding integer NOT NULL,
    sentdate timestamp without time zone NOT NULL,
    receiveddate timestamp without time zone NOT NULL,
    text character varying(255),
    gatewayid character varying(255) NOT NULL,
    status integer NOT NULL,
    parsed boolean,
    statusmessage character varying(255),
    userid bigint,
    uid character varying(255)
);


ALTER TABLE public.incomingsms OWNER TO dhis;

--
-- Name: indicator; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.indicator (
    indicatorid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    shortname character varying(50) NOT NULL,
    description text,
    formname text,
    annualized boolean NOT NULL,
    decimals integer,
    indicatortypeid bigint NOT NULL,
    numerator text NOT NULL,
    numeratordescription text,
    denominator text NOT NULL,
    denominatordescription text,
    url character varying(255),
    style jsonb,
    aggregateexportcategoryoptioncombo character varying(255),
    aggregateexportattributeoptioncombo character varying(255),
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.indicator OWNER TO dhis;

--
-- Name: indicatorgroup; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.indicatorgroup (
    indicatorgroupid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    description text,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.indicatorgroup OWNER TO dhis;

--
-- Name: indicatorgroupmembers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.indicatorgroupmembers (
    indicatorid bigint NOT NULL,
    indicatorgroupid bigint NOT NULL
);


ALTER TABLE public.indicatorgroupmembers OWNER TO dhis;

--
-- Name: indicatorgroupset; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.indicatorgroupset (
    indicatorgroupsetid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    compulsory boolean,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    sharing jsonb DEFAULT '{}'::jsonb,
    shortname character varying(50) NOT NULL
);


ALTER TABLE public.indicatorgroupset OWNER TO dhis;

--
-- Name: indicatorgroupsetmembers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.indicatorgroupsetmembers (
    indicatorgroupid bigint NOT NULL,
    indicatorgroupsetid bigint NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.indicatorgroupsetmembers OWNER TO dhis;

--
-- Name: indicatorlegendsets; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.indicatorlegendsets (
    indicatorid bigint NOT NULL,
    sort_order integer NOT NULL,
    legendsetid bigint NOT NULL
);


ALTER TABLE public.indicatorlegendsets OWNER TO dhis;

--
-- Name: indicatortype; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.indicatortype (
    indicatortypeid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    indicatorfactor integer NOT NULL,
    indicatornumber boolean,
    translations jsonb
);


ALTER TABLE public.indicatortype OWNER TO dhis;

--
-- Name: intepretation_likedby; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.intepretation_likedby (
    interpretationid bigint NOT NULL,
    userid bigint NOT NULL
);


ALTER TABLE public.intepretation_likedby OWNER TO dhis;

--
-- Name: interpretation; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.interpretation (
    interpretationid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    mapid bigint,
    eventreportid bigint,
    eventchartid bigint,
    datasetid bigint,
    periodid bigint,
    organisationunitid bigint,
    interpretationtext text,
    created timestamp without time zone NOT NULL,
    likes integer,
    userid bigint,
    publicaccess character varying(8),
    mentions jsonb,
    visualizationid bigint,
    sharing jsonb DEFAULT '{}'::jsonb,
    eventvisualizationid bigint
);


ALTER TABLE public.interpretation OWNER TO dhis;

--
-- Name: interpretation_comments; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.interpretation_comments (
    interpretationid bigint NOT NULL,
    sort_order integer NOT NULL,
    interpretationcommentid bigint NOT NULL
);


ALTER TABLE public.interpretation_comments OWNER TO dhis;

--
-- Name: interpretationcomment; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.interpretationcomment (
    interpretationcommentid bigint NOT NULL,
    uid character varying(11),
    lastupdated timestamp without time zone NOT NULL,
    commenttext text,
    mentions jsonb,
    userid bigint NOT NULL,
    created timestamp without time zone NOT NULL
);


ALTER TABLE public.interpretationcomment OWNER TO dhis;

--
-- Name: jobconfiguration; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.jobconfiguration (
    jobconfigurationid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    cronexpression character varying(255),
    lastexecuted timestamp without time zone,
    lastruntimeexecution text,
    nextexecutiontime timestamp without time zone,
    enabled boolean NOT NULL,
    leaderonlyjob boolean DEFAULT false NOT NULL,
    jsonbjobparameters jsonb,
    jobtype character varying(120),
    jobstatus character varying(120),
    lastexecutedstatus character varying(120),
    delay integer
);


ALTER TABLE public.jobconfiguration OWNER TO dhis;

--
-- Name: keyjsonvalue; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.keyjsonvalue (
    keyjsonvalueid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    namespace character varying(255) NOT NULL,
    namespacekey character varying(255) NOT NULL,
    encrypted_value character varying(255),
    encrypted boolean,
    userid bigint,
    publicaccess character varying(8),
    jbvalue jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.keyjsonvalue OWNER TO dhis;

--
-- Name: lockexception; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.lockexception (
    lockexceptionid bigint NOT NULL,
    organisationunitid bigint,
    periodid bigint,
    datasetid bigint
);


ALTER TABLE public.lockexception OWNER TO dhis;

--
-- Name: map; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.map (
    mapid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    longitude double precision,
    latitude double precision,
    zoom integer,
    basemap character varying(255),
    title character varying(255),
    externalaccess boolean,
    userid bigint,
    publicaccess character varying(8),
    favorites jsonb,
    subscribers jsonb,
    translations jsonb,
    sharing jsonb DEFAULT '{}'::jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.map OWNER TO dhis;

--
-- Name: maplegend; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.maplegend (
    maplegendid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    startvalue double precision NOT NULL,
    endvalue double precision NOT NULL,
    color character varying(255),
    image character varying(255),
    maplegendsetid bigint,
    translations jsonb
);


ALTER TABLE public.maplegend OWNER TO dhis;

--
-- Name: maplegendset; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.maplegendset (
    maplegendsetid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    symbolizer character varying(255),
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.maplegendset OWNER TO dhis;

--
-- Name: mapmapviews; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.mapmapviews (
    mapid bigint NOT NULL,
    sort_order integer NOT NULL,
    mapviewid bigint NOT NULL
);


ALTER TABLE public.mapmapviews OWNER TO dhis;

--
-- Name: mapview; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.mapview (
    mapviewid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    description text,
    layer character varying(255) NOT NULL,
    relativeperiodsid integer,
    userorganisationunit boolean,
    userorganisationunitchildren boolean,
    userorganisationunitgrandchildren boolean,
    aggregationtype character varying(40),
    programid bigint,
    programstageid bigint,
    startdate timestamp without time zone,
    enddate timestamp without time zone,
    trackedentitytypeid bigint,
    programstatus character varying(40),
    followup boolean,
    organisationunitselectionmode character varying(40),
    method integer,
    classes integer,
    colorlow character varying(255),
    colorhigh character varying(255),
    colorscale character varying(255),
    legendsetid bigint,
    radiuslow integer,
    radiushigh integer,
    opacity double precision,
    orgunitgroupsetid bigint,
    arearadius integer,
    hidden boolean,
    labels boolean,
    labelfontsize character varying(255),
    labelfontweight character varying(255),
    labelfontstyle character varying(255),
    labelfontcolor character varying(255),
    eventclustering boolean,
    eventcoordinatefield character varying(255),
    eventpointcolor character varying(255),
    eventpointradius integer,
    config text,
    styledataitem jsonb,
    translations jsonb,
    renderingstrategy character varying(50) NOT NULL,
    userorgunittype character varying(20),
    thematicmaptype character varying(50),
    nodatacolor character varying(7),
    eventstatus character varying(50),
    organisationunitcolor character varying(7),
    orgunitfield character varying(255)
);


ALTER TABLE public.mapview OWNER TO dhis;

--
-- Name: mapview_attributedimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.mapview_attributedimensions (
    mapviewid bigint NOT NULL,
    sort_order integer NOT NULL,
    trackedentityattributedimensionid integer NOT NULL
);


ALTER TABLE public.mapview_attributedimensions OWNER TO dhis;

--
-- Name: mapview_categorydimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.mapview_categorydimensions (
    mapviewid bigint NOT NULL,
    categorydimensionid integer NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.mapview_categorydimensions OWNER TO dhis;

--
-- Name: mapview_categoryoptiongroupsetdimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.mapview_categoryoptiongroupsetdimensions (
    mapviewid bigint NOT NULL,
    sort_order integer NOT NULL,
    categoryoptiongroupsetdimensionid integer NOT NULL
);


ALTER TABLE public.mapview_categoryoptiongroupsetdimensions OWNER TO dhis;

--
-- Name: mapview_columns; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.mapview_columns (
    mapviewid bigint NOT NULL,
    sort_order integer NOT NULL,
    dimension character varying(255)
);


ALTER TABLE public.mapview_columns OWNER TO dhis;

--
-- Name: mapview_datadimensionitems; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.mapview_datadimensionitems (
    mapviewid bigint NOT NULL,
    sort_order integer NOT NULL,
    datadimensionitemid integer NOT NULL
);


ALTER TABLE public.mapview_datadimensionitems OWNER TO dhis;

--
-- Name: mapview_dataelementdimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.mapview_dataelementdimensions (
    mapviewid bigint NOT NULL,
    sort_order integer NOT NULL,
    trackedentitydataelementdimensionid integer NOT NULL
);


ALTER TABLE public.mapview_dataelementdimensions OWNER TO dhis;

--
-- Name: mapview_filters; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.mapview_filters (
    mapviewid bigint NOT NULL,
    dimension character varying(255),
    sort_order integer NOT NULL
);


ALTER TABLE public.mapview_filters OWNER TO dhis;

--
-- Name: mapview_itemorgunitgroups; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.mapview_itemorgunitgroups (
    mapviewid bigint NOT NULL,
    sort_order integer NOT NULL,
    orgunitgroupid bigint NOT NULL
);


ALTER TABLE public.mapview_itemorgunitgroups OWNER TO dhis;

--
-- Name: mapview_organisationunits; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.mapview_organisationunits (
    mapviewid bigint NOT NULL,
    sort_order integer NOT NULL,
    organisationunitid bigint NOT NULL
);


ALTER TABLE public.mapview_organisationunits OWNER TO dhis;

--
-- Name: mapview_orgunitgroupsetdimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.mapview_orgunitgroupsetdimensions (
    mapviewid bigint NOT NULL,
    sort_order integer NOT NULL,
    orgunitgroupsetdimensionid integer NOT NULL
);


ALTER TABLE public.mapview_orgunitgroupsetdimensions OWNER TO dhis;

--
-- Name: mapview_orgunitlevels; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.mapview_orgunitlevels (
    mapviewid bigint NOT NULL,
    sort_order integer NOT NULL,
    orgunitlevel integer
);


ALTER TABLE public.mapview_orgunitlevels OWNER TO dhis;

--
-- Name: mapview_periods; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.mapview_periods (
    mapviewid bigint NOT NULL,
    sort_order integer NOT NULL,
    periodid bigint NOT NULL
);


ALTER TABLE public.mapview_periods OWNER TO dhis;

--
-- Name: message; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.message (
    messageid bigint NOT NULL,
    uid character varying(11),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    messagetext text,
    internal boolean,
    metadata character varying(255),
    userid bigint
);


ALTER TABLE public.message OWNER TO dhis;

--
-- Name: message_sequence; Type: SEQUENCE; Schema: public; Owner: dhis
--

CREATE SEQUENCE public.message_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.message_sequence OWNER TO dhis;

--
-- Name: messageattachments; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.messageattachments (
    messageid bigint NOT NULL,
    fileresourceid bigint NOT NULL
);


ALTER TABLE public.messageattachments OWNER TO dhis;

--
-- Name: messageconversation; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.messageconversation (
    messageconversationid bigint NOT NULL,
    uid character varying(11),
    messagecount integer,
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    subject character varying(255) NOT NULL,
    messagetype character varying(255) NOT NULL,
    priority character varying(255),
    status character varying(255),
    user_assigned bigint,
    lastsenderid bigint,
    lastmessage timestamp without time zone,
    userid bigint,
    extmessageid character varying(64)
);


ALTER TABLE public.messageconversation OWNER TO dhis;

--
-- Name: messageconversation_messages; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.messageconversation_messages (
    messageconversationid bigint NOT NULL,
    sort_order integer NOT NULL,
    messageid bigint NOT NULL
);


ALTER TABLE public.messageconversation_messages OWNER TO dhis;

--
-- Name: messageconversation_sequence; Type: SEQUENCE; Schema: public; Owner: dhis
--

CREATE SEQUENCE public.messageconversation_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.messageconversation_sequence OWNER TO dhis;

--
-- Name: messageconversation_usermessages; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.messageconversation_usermessages (
    messageconversationid bigint NOT NULL,
    usermessageid integer NOT NULL
);


ALTER TABLE public.messageconversation_usermessages OWNER TO dhis;

--
-- Name: metadataproposal; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.metadataproposal (
    proposalid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    type character varying(6) NOT NULL,
    status character varying(12) NOT NULL,
    target character varying(30) NOT NULL,
    targetuid character varying(11),
    created timestamp without time zone NOT NULL,
    createdby bigint NOT NULL,
    change jsonb NOT NULL,
    comment character varying(255),
    reason character varying(1024),
    finalised timestamp without time zone,
    finalisedby bigint
);


ALTER TABLE public.metadataproposal OWNER TO dhis;

--
-- Name: metadataversion; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.metadataversion (
    versionid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    versiontype character varying(50),
    importdate timestamp without time zone,
    hashcode character varying(50) NOT NULL
);


ALTER TABLE public.metadataversion OWNER TO dhis;

--
-- Name: minmaxdataelement; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.minmaxdataelement (
    minmaxdataelementid bigint NOT NULL,
    sourceid bigint,
    dataelementid bigint,
    categoryoptioncomboid bigint,
    minimumvalue integer NOT NULL,
    maximumvalue integer NOT NULL,
    generatedvalue boolean NOT NULL
);


ALTER TABLE public.minmaxdataelement OWNER TO dhis;

--
-- Name: oauth2client; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.oauth2client (
    oauth2clientid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    cid character varying(230) NOT NULL,
    secret character varying(512) NOT NULL
);


ALTER TABLE public.oauth2client OWNER TO dhis;

--
-- Name: oauth2clientgranttypes; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.oauth2clientgranttypes (
    oauth2clientid bigint NOT NULL,
    sort_order integer NOT NULL,
    granttype character varying(255)
);


ALTER TABLE public.oauth2clientgranttypes OWNER TO dhis;

--
-- Name: oauth2clientredirecturis; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.oauth2clientredirecturis (
    oauth2clientid bigint NOT NULL,
    sort_order integer NOT NULL,
    redirecturi character varying(255)
);


ALTER TABLE public.oauth2clientredirecturis OWNER TO dhis;

--
-- Name: oauth_access_token; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.oauth_access_token (
    token_id character varying(256),
    token bytea,
    authentication_id character varying(256) NOT NULL,
    user_name character varying(256),
    client_id character varying(256),
    authentication bytea,
    refresh_token character varying(256)
);


ALTER TABLE public.oauth_access_token OWNER TO dhis;

--
-- Name: oauth_code; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.oauth_code (
    code character varying(256),
    authentication bytea
);

ALTER TABLE ONLY public.oauth_code REPLICA IDENTITY FULL;


ALTER TABLE public.oauth_code OWNER TO dhis;

--
-- Name: oauth_refresh_token; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.oauth_refresh_token (
    token_id character varying(256),
    token bytea,
    authentication bytea
);

ALTER TABLE ONLY public.oauth_refresh_token REPLICA IDENTITY FULL;


ALTER TABLE public.oauth_refresh_token OWNER TO dhis;

--
-- Name: optiongroup; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.optiongroup (
    optiongroupid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    shortname character varying(50) NOT NULL,
    optionsetid bigint,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    sharing jsonb DEFAULT '{}'::jsonb,
    description text
);


ALTER TABLE public.optiongroup OWNER TO dhis;

--
-- Name: optiongroupmembers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.optiongroupmembers (
    optiongroupid bigint NOT NULL,
    optionid bigint NOT NULL
);


ALTER TABLE public.optiongroupmembers OWNER TO dhis;

--
-- Name: optiongroupset; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.optiongroupset (
    optiongroupsetid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    datadimension boolean NOT NULL,
    optionsetid bigint,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.optiongroupset OWNER TO dhis;

--
-- Name: optiongroupsetmembers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.optiongroupsetmembers (
    optiongroupsetid bigint NOT NULL,
    sort_order integer NOT NULL,
    optiongroupid bigint NOT NULL
);


ALTER TABLE public.optiongroupsetmembers OWNER TO dhis;

--
-- Name: optionset; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.optionset (
    optionsetid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    valuetype character varying(50) NOT NULL,
    version integer,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.optionset OWNER TO dhis;

--
-- Name: optionvalue; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.optionvalue (
    optionvalueid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(230) NOT NULL,
    name character varying(230) NOT NULL,
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    sort_order integer,
    description text,
    formname text,
    style jsonb,
    optionsetid bigint,
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.optionvalue OWNER TO dhis;

--
-- Name: organisationunit; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.organisationunit (
    organisationunitid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    shortname character varying(50) NOT NULL,
    parentid bigint,
    path character varying(255),
    hierarchylevel integer,
    description text,
    openingdate date NOT NULL,
    closeddate date,
    comment text,
    url character varying(255),
    contactperson character varying(255),
    address character varying(255),
    email character varying(150),
    phonenumber character varying(150),
    userid bigint,
    translations jsonb,
    geometry public.geometry(Geometry,4326),
    attributevalues jsonb DEFAULT '{}'::jsonb,
    image bigint
);


ALTER TABLE public.organisationunit OWNER TO dhis;

--
-- Name: orgunitgroup; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.orgunitgroup (
    orgunitgroupid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    shortname character varying(50),
    symbol character varying(255),
    color character varying(255),
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    geometry public.geometry(Geometry,4326),
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.orgunitgroup OWNER TO dhis;

--
-- Name: orgunitgroupmembers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.orgunitgroupmembers (
    organisationunitid bigint NOT NULL,
    orgunitgroupid bigint NOT NULL
);


ALTER TABLE public.orgunitgroupmembers OWNER TO dhis;

--
-- Name: orgunitgroupset; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.orgunitgroupset (
    orgunitgroupsetid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    compulsory boolean NOT NULL,
    includesubhierarchyinanalytics boolean,
    datadimension boolean NOT NULL,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb,
    shortname character varying(50) NOT NULL
);


ALTER TABLE public.orgunitgroupset OWNER TO dhis;

--
-- Name: orgunitgroupsetdimension; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.orgunitgroupsetdimension (
    orgunitgroupsetdimensionid integer NOT NULL,
    orgunitgroupsetid bigint
);


ALTER TABLE public.orgunitgroupsetdimension OWNER TO dhis;

--
-- Name: orgunitgroupsetdimension_items; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.orgunitgroupsetdimension_items (
    orgunitgroupsetdimensionid integer NOT NULL,
    sort_order integer NOT NULL,
    orgunitgroupid bigint NOT NULL
);


ALTER TABLE public.orgunitgroupsetdimension_items OWNER TO dhis;

--
-- Name: orgunitgroupsetmembers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.orgunitgroupsetmembers (
    orgunitgroupsetid bigint NOT NULL,
    orgunitgroupid bigint NOT NULL
);


ALTER TABLE public.orgunitgroupsetmembers OWNER TO dhis;

--
-- Name: orgunitlevel; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.orgunitlevel (
    orgunitlevelid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    level integer NOT NULL,
    offlinelevels integer,
    translations jsonb
);


ALTER TABLE public.orgunitlevel OWNER TO dhis;

--
-- Name: outbound_sms; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.outbound_sms (
    id bigint NOT NULL,
    date timestamp without time zone NOT NULL,
    message text,
    status integer NOT NULL,
    sender character varying(255),
    uid character varying(255)
);


ALTER TABLE public.outbound_sms OWNER TO dhis;

--
-- Name: outbound_sms_recipients; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.outbound_sms_recipients (
    outbound_sms_id bigint NOT NULL,
    elt text
);

ALTER TABLE ONLY public.outbound_sms_recipients REPLICA IDENTITY FULL;


ALTER TABLE public.outbound_sms_recipients OWNER TO dhis;

--
-- Name: period; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.period (
    periodid bigint NOT NULL,
    periodtypeid integer,
    startdate date NOT NULL,
    enddate date NOT NULL
);


ALTER TABLE public.period OWNER TO dhis;

--
-- Name: periodboundary; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.periodboundary (
    periodboundaryid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    boundarytarget character varying(50),
    analyticsperiodboundarytype character varying(50),
    offsetperiods integer,
    offsetperiodtypeid integer,
    programindicatorid bigint
);


ALTER TABLE public.periodboundary OWNER TO dhis;

--
-- Name: periodtype; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.periodtype (
    periodtypeid integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.periodtype OWNER TO dhis;

--
-- Name: potentialduplicate; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.potentialduplicate (
    potentialduplicateid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    teia character varying(11) NOT NULL,
    teib character varying(11) NOT NULL,
    status character varying(255) NOT NULL,
    createdbyusername character varying(255) NOT NULL,
    lastupdatebyusername character varying(255) NOT NULL
);


ALTER TABLE public.potentialduplicate OWNER TO dhis;

--
-- Name: potentialduplicatesequence; Type: SEQUENCE; Schema: public; Owner: dhis
--

CREATE SEQUENCE public.potentialduplicatesequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.potentialduplicatesequence OWNER TO dhis;

--
-- Name: predictor; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.predictor (
    predictorid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    generatorexpressionid bigint,
    generatoroutput bigint NOT NULL,
    generatoroutputcombo bigint,
    skiptestexpressionid bigint,
    periodtypeid integer NOT NULL,
    sequentialsamplecount integer NOT NULL,
    annualsamplecount integer NOT NULL,
    sequentialskipcount integer,
    translations jsonb DEFAULT '[]'::jsonb,
    organisationunitdescendants character varying(100) DEFAULT 'SELECTED'::character varying,
    shortname character varying(50) NOT NULL
);


ALTER TABLE public.predictor OWNER TO dhis;

--
-- Name: predictorgroup; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.predictorgroup (
    predictorgroupid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.predictorgroup OWNER TO dhis;

--
-- Name: predictorgroupmembers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.predictorgroupmembers (
    predictorid bigint NOT NULL,
    predictorgroupid bigint NOT NULL
);


ALTER TABLE public.predictorgroupmembers OWNER TO dhis;

--
-- Name: predictororgunitlevels; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.predictororgunitlevels (
    predictorid bigint NOT NULL,
    orgunitlevelid bigint NOT NULL
);


ALTER TABLE public.predictororgunitlevels OWNER TO dhis;

--
-- Name: previouspasswords; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.previouspasswords (
    userid bigint NOT NULL,
    list_index integer NOT NULL,
    previouspassword text
);


ALTER TABLE public.previouspasswords OWNER TO dhis;

--
-- Name: program; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.program (
    programid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    shortname character varying(50) NOT NULL,
    description text,
    formname text,
    version integer,
    enrollmentdatelabel text,
    incidentdatelabel text,
    type character varying(255) NOT NULL,
    displayincidentdate boolean,
    onlyenrollonce boolean,
    skipoffline boolean NOT NULL,
    displayfrontpagelist boolean,
    usefirststageduringregistration boolean,
    capturecoordinates boolean,
    expirydays integer,
    completeeventsexpirydays integer,
    minattributesrequiredtosearch integer,
    maxteicounttoreturn integer,
    style jsonb,
    accesslevel character varying(100),
    expiryperiodtypeid integer,
    ignoreoverdueevents boolean,
    selectenrollmentdatesinfuture boolean,
    selectincidentdatesinfuture boolean,
    relatedprogramid bigint,
    categorycomboid bigint NOT NULL,
    trackedentitytypeid bigint,
    dataentryformid bigint,
    userid bigint,
    publicaccess character varying(8),
    featuretype character varying(255),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb,
    opendaysaftercoenddate integer DEFAULT 0
);


ALTER TABLE public.program OWNER TO dhis;

--
-- Name: program_attribute_group; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.program_attribute_group (
    programtrackedentityattributegroupid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    shortname character varying(255),
    description text,
    uniqunessype bytea NOT NULL,
    translations jsonb
);


ALTER TABLE public.program_attribute_group OWNER TO dhis;

--
-- Name: program_attributes; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.program_attributes (
    programtrackedentityattributeid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    programid bigint,
    trackedentityattributeid bigint NOT NULL,
    displayinlist boolean,
    mandatory boolean,
    sort_order integer,
    allowfuturedate boolean,
    renderoptionsasradio boolean,
    rendertype jsonb,
    searchable boolean
);


ALTER TABLE public.program_attributes OWNER TO dhis;

--
-- Name: program_organisationunits; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.program_organisationunits (
    organisationunitid bigint NOT NULL,
    programid bigint NOT NULL
);


ALTER TABLE public.program_organisationunits OWNER TO dhis;

--
-- Name: program_userroles; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.program_userroles (
    programid bigint,
    userroleid bigint NOT NULL
);

ALTER TABLE ONLY public.program_userroles REPLICA IDENTITY FULL;


ALTER TABLE public.program_userroles OWNER TO dhis;

--
-- Name: programexpression; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programexpression (
    programexpressionid bigint NOT NULL,
    description character varying(255),
    expression text
);


ALTER TABLE public.programexpression OWNER TO dhis;

--
-- Name: programindicator; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programindicator (
    programindicatorid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    shortname character varying(50) NOT NULL,
    description text,
    formname text,
    style jsonb,
    programid bigint NOT NULL,
    expression text,
    filter text,
    aggregationtype character varying(40),
    decimals integer,
    aggregateexportcategoryoptioncombo character varying(255),
    aggregateexportattributeoptioncombo character varying(255),
    displayinform boolean,
    analyticstype character varying(15) NOT NULL,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.programindicator OWNER TO dhis;

--
-- Name: programindicatorgroup; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programindicatorgroup (
    programindicatorgroupid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.programindicatorgroup OWNER TO dhis;

--
-- Name: programindicatorgroupmembers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programindicatorgroupmembers (
    programindicatorid bigint NOT NULL,
    programindicatorgroupid bigint NOT NULL
);


ALTER TABLE public.programindicatorgroupmembers OWNER TO dhis;

--
-- Name: programindicatorlegendsets; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programindicatorlegendsets (
    programindicatorid bigint NOT NULL,
    sort_order integer NOT NULL,
    legendsetid bigint NOT NULL
);


ALTER TABLE public.programindicatorlegendsets OWNER TO dhis;

--
-- Name: programinstance; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programinstance (
    programinstanceid bigint NOT NULL,
    uid character varying(11),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    createdatclient timestamp without time zone,
    lastupdatedatclient timestamp without time zone,
    incidentdate timestamp without time zone,
    enrollmentdate timestamp without time zone NOT NULL,
    enddate timestamp without time zone,
    followup boolean,
    completedby character varying(255),
    deleted boolean NOT NULL,
    storedby character varying(255),
    status character varying(50),
    trackedentityinstanceid bigint,
    programid bigint NOT NULL,
    organisationunitid bigint,
    geometry public.geometry,
    createdbyuserinfo jsonb,
    lastupdatedbyuserinfo jsonb
);


ALTER TABLE public.programinstance OWNER TO dhis;

--
-- Name: programinstance_messageconversation; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programinstance_messageconversation (
    programinstanceid bigint NOT NULL,
    sort_order integer NOT NULL,
    messageconversationid bigint NOT NULL
);


ALTER TABLE public.programinstance_messageconversation OWNER TO dhis;

--
-- Name: programinstance_sequence; Type: SEQUENCE; Schema: public; Owner: dhis
--

CREATE SEQUENCE public.programinstance_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.programinstance_sequence OWNER TO dhis;

--
-- Name: programinstancecomments; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programinstancecomments (
    programinstanceid bigint NOT NULL,
    sort_order integer NOT NULL,
    trackedentitycommentid bigint NOT NULL
);


ALTER TABLE public.programinstancecomments OWNER TO dhis;

--
-- Name: programmessage; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programmessage (
    id bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    text character varying(500) NOT NULL,
    subject character varying(200),
    processeddate timestamp without time zone,
    messagestatus character varying(50),
    trackedentityinstanceid bigint,
    organisationunitid bigint,
    programinstanceid bigint,
    programstageinstanceid bigint,
    translations jsonb,
    notificationtemplate character varying(255)
);


ALTER TABLE public.programmessage OWNER TO dhis;

--
-- Name: programmessage_deliverychannels; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programmessage_deliverychannels (
    programmessagedeliverychannelsid bigint NOT NULL,
    deliverychannel character varying(255)
);

ALTER TABLE ONLY public.programmessage_deliverychannels REPLICA IDENTITY FULL;


ALTER TABLE public.programmessage_deliverychannels OWNER TO dhis;

--
-- Name: programmessage_emailaddresses; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programmessage_emailaddresses (
    programmessageemailaddressid bigint NOT NULL,
    email text
);

ALTER TABLE ONLY public.programmessage_emailaddresses REPLICA IDENTITY FULL;


ALTER TABLE public.programmessage_emailaddresses OWNER TO dhis;

--
-- Name: programmessage_phonenumbers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programmessage_phonenumbers (
    programmessagephonenumberid bigint NOT NULL,
    phonenumber text
);

ALTER TABLE ONLY public.programmessage_phonenumbers REPLICA IDENTITY FULL;


ALTER TABLE public.programmessage_phonenumbers OWNER TO dhis;

--
-- Name: programnotificationinstance; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programnotificationinstance (
    programnotificationinstanceid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    programinstanceid bigint,
    programstageinstanceid bigint,
    programnotificationtemplateid bigint,
    scheduledat timestamp without time zone,
    sentat timestamp without time zone,
    programnotificationtemplatesnapshot jsonb
);


ALTER TABLE public.programnotificationinstance OWNER TO dhis;

--
-- Name: programnotificationtemplate; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programnotificationtemplate (
    programnotificationtemplateid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    relativescheduleddays integer,
    usergroupid bigint,
    trackedentityattributeid bigint,
    dataelementid bigint,
    subjecttemplate character varying(100),
    messagetemplate text NOT NULL,
    notifyparentorganisationunitonly boolean,
    notifyusersinhierarchyonly boolean,
    notificationtrigger character varying(255),
    notificationrecipienttype character varying(255),
    programstageid bigint,
    programid bigint,
    sendrepeatable boolean NOT NULL,
    translations jsonb DEFAULT '[]'::jsonb
);


ALTER TABLE public.programnotificationtemplate OWNER TO dhis;

--
-- Name: programnotificationtemplate_deliverychannel; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programnotificationtemplate_deliverychannel (
    programnotificationtemplatedeliverychannelid bigint NOT NULL,
    deliverychannel character varying(255)
);

ALTER TABLE ONLY public.programnotificationtemplate_deliverychannel REPLICA IDENTITY FULL;


ALTER TABLE public.programnotificationtemplate_deliverychannel OWNER TO dhis;

--
-- Name: programownershiphistory; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programownershiphistory (
    programownershiphistoryid integer NOT NULL,
    programid bigint,
    trackedentityinstanceid bigint,
    startdate timestamp without time zone,
    enddate timestamp without time zone,
    createdby character varying(255),
    organisationunitid bigint
);


ALTER TABLE public.programownershiphistory OWNER TO dhis;

--
-- Name: programrule; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programrule (
    programruleid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description character varying(255),
    programid bigint NOT NULL,
    programstageid bigint,
    rulecondition text,
    priority integer,
    translations jsonb
);


ALTER TABLE public.programrule OWNER TO dhis;

--
-- Name: programruleaction; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programruleaction (
    programruleactionid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    programruleid bigint,
    actiontype character varying(255) NOT NULL,
    dataelementid bigint,
    trackedentityattributeid bigint,
    programindicatorid bigint,
    programstagesectionid bigint,
    programstageid bigint,
    optionid bigint,
    optiongroupid bigint,
    location character varying(255),
    content text,
    data text,
    templateuid text,
    evaluationtime character varying(50),
    environments jsonb,
    translations jsonb
);


ALTER TABLE public.programruleaction OWNER TO dhis;

--
-- Name: programrulevariable; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programrulevariable (
    programrulevariableid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    programid bigint NOT NULL,
    sourcetype character varying(255) NOT NULL,
    trackedentityattributeid bigint,
    dataelementid bigint,
    usecodeforoptionset boolean,
    programstageid bigint,
    translations jsonb DEFAULT '[]'::jsonb,
    valuetype character varying(50) NOT NULL
);


ALTER TABLE public.programrulevariable OWNER TO dhis;

--
-- Name: programsection; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programsection (
    programsectionid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    formname text,
    style jsonb,
    rendertype jsonb,
    programid bigint,
    sortorder integer NOT NULL,
    translations jsonb
);


ALTER TABLE public.programsection OWNER TO dhis;

--
-- Name: programsection_attributes; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programsection_attributes (
    programsectionid bigint NOT NULL,
    sort_order integer NOT NULL,
    trackedentityattributeid bigint NOT NULL
);


ALTER TABLE public.programsection_attributes OWNER TO dhis;

--
-- Name: programstage; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programstage (
    programstageid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    formname text,
    mindaysfromstart integer NOT NULL,
    programid bigint,
    repeatable boolean NOT NULL,
    dataentryformid bigint,
    standardinterval integer,
    executiondatelabel character varying(255),
    duedatelabel character varying(255),
    autogenerateevent boolean,
    displaygenerateeventbox boolean,
    generatedbyenrollmentdate boolean,
    blockentryform boolean,
    remindcompleted boolean,
    allowgeneratenextvisit boolean,
    openafterenrollment boolean,
    reportdatetouse character varying(255),
    pregenerateuid boolean,
    style jsonb,
    hideduedate boolean,
    sort_order integer,
    featuretype character varying(255),
    periodtypeid integer,
    userid bigint,
    publicaccess character varying(8),
    validationstrategy character varying(32) NOT NULL,
    translations jsonb,
    enableuserassignment boolean NOT NULL,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    nextscheduledateid bigint,
    sharing jsonb DEFAULT '{}'::jsonb,
    referral boolean DEFAULT false NOT NULL
);


ALTER TABLE public.programstage OWNER TO dhis;

--
-- Name: programstagedataelement; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programstagedataelement (
    programstagedataelementid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    programstageid bigint,
    dataelementid bigint NOT NULL,
    compulsory boolean NOT NULL,
    allowprovidedelsewhere boolean,
    sort_order integer,
    displayinreports boolean,
    allowfuturedate boolean,
    renderoptionsasradio boolean,
    rendertype jsonb,
    skipsynchronization boolean NOT NULL,
    skipanalytics boolean NOT NULL
);


ALTER TABLE public.programstagedataelement OWNER TO dhis;

--
-- Name: programstageinstance; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programstageinstance (
    programstageinstanceid bigint NOT NULL,
    uid character varying(11),
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    createdatclient timestamp without time zone,
    lastupdatedatclient timestamp without time zone,
    lastsynchronized timestamp without time zone DEFAULT to_timestamp((0)::double precision) NOT NULL,
    programinstanceid bigint NOT NULL,
    programstageid bigint NOT NULL,
    attributeoptioncomboid bigint,
    deleted boolean NOT NULL,
    storedby character varying(255),
    duedate timestamp without time zone,
    executiondate timestamp without time zone,
    organisationunitid bigint,
    status character varying(25) NOT NULL,
    completedby character varying(255),
    completeddate timestamp without time zone,
    geometry public.geometry,
    eventdatavalues jsonb DEFAULT '{}'::jsonb NOT NULL,
    assigneduserid bigint,
    createdbyuserinfo jsonb,
    lastupdatedbyuserinfo jsonb
);


ALTER TABLE public.programstageinstance OWNER TO dhis;

--
-- Name: programstageinstance_messageconversation; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programstageinstance_messageconversation (
    programstageinstanceid bigint NOT NULL,
    sort_order integer NOT NULL,
    messageconversationid bigint NOT NULL
);


ALTER TABLE public.programstageinstance_messageconversation OWNER TO dhis;

--
-- Name: programstageinstance_sequence; Type: SEQUENCE; Schema: public; Owner: dhis
--

CREATE SEQUENCE public.programstageinstance_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.programstageinstance_sequence OWNER TO dhis;

--
-- Name: programstageinstancecomments; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programstageinstancecomments (
    programstageinstanceid bigint NOT NULL,
    sort_order integer NOT NULL,
    trackedentitycommentid bigint NOT NULL
);


ALTER TABLE public.programstageinstancecomments OWNER TO dhis;

--
-- Name: programstageinstancefilter; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programstageinstancefilter (
    programstageinstancefilterid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description character varying(255),
    program character varying(11) NOT NULL,
    programstage character varying(11),
    eventquerycriteria jsonb,
    userid bigint,
    publicaccess character varying(8),
    sharing jsonb DEFAULT '{}'::jsonb,
    translations jsonb
);


ALTER TABLE public.programstageinstancefilter OWNER TO dhis;

--
-- Name: programstagesection; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programstagesection (
    programstagesectionid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    formname text,
    style jsonb,
    rendertype jsonb,
    programstageid bigint,
    sortorder integer NOT NULL,
    translations jsonb
);


ALTER TABLE public.programstagesection OWNER TO dhis;

--
-- Name: programstagesection_dataelements; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programstagesection_dataelements (
    programstagesectionid bigint NOT NULL,
    sort_order integer NOT NULL,
    dataelementid bigint NOT NULL
);


ALTER TABLE public.programstagesection_dataelements OWNER TO dhis;

--
-- Name: programstagesection_programindicators; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programstagesection_programindicators (
    programstagesectionid bigint NOT NULL,
    sort_order integer NOT NULL,
    programindicatorid bigint NOT NULL
);


ALTER TABLE public.programstagesection_programindicators OWNER TO dhis;

--
-- Name: programtempowner; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programtempowner (
    programtempownerid bigint NOT NULL,
    programid bigint,
    trackedentityinstanceid bigint,
    validtill timestamp without time zone,
    userid bigint,
    reason character varying(50000)
);


ALTER TABLE public.programtempowner OWNER TO dhis;

--
-- Name: programtempownershipaudit; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programtempownershipaudit (
    programtempownershipauditid integer NOT NULL,
    programid bigint,
    trackedentityinstanceid bigint,
    created timestamp without time zone,
    accessedby character varying(255),
    reason character varying(50000)
);


ALTER TABLE public.programtempownershipaudit OWNER TO dhis;

--
-- Name: programtrackedentityattributegroupmembers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.programtrackedentityattributegroupmembers (
    programtrackedentityattributeid bigint NOT NULL,
    programtrackedentityattributegroupid bigint NOT NULL
);


ALTER TABLE public.programtrackedentityattributegroupmembers OWNER TO dhis;

--
-- Name: pushanalysis; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.pushanalysis (
    pushanalysisid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(255) NOT NULL,
    title character varying(255),
    message text,
    enabled boolean NOT NULL,
    schedulingdayoffrequency integer,
    schedulingfrequency bytea,
    dashboard bigint NOT NULL
);


ALTER TABLE public.pushanalysis OWNER TO dhis;

--
-- Name: pushanalysisrecipientusergroups; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.pushanalysisrecipientusergroups (
    usergroupid bigint NOT NULL,
    elt bigint NOT NULL
);


ALTER TABLE public.pushanalysisrecipientusergroups OWNER TO dhis;

--
-- Name: relationship; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.relationship (
    relationshipid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    style jsonb,
    relationshiptypeid bigint NOT NULL,
    from_relationshipitemid integer,
    to_relationshipitemid integer,
    key character varying NOT NULL,
    inverted_key character varying NOT NULL,
    deleted boolean DEFAULT false
);


ALTER TABLE public.relationship OWNER TO dhis;

--
-- Name: relationshipconstraint; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.relationshipconstraint (
    relationshipconstraintid integer NOT NULL,
    entity character varying(255),
    trackedentitytypeid bigint,
    programid bigint,
    programstageid bigint,
    dataview jsonb
);


ALTER TABLE public.relationshipconstraint OWNER TO dhis;

--
-- Name: relationshipitem; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.relationshipitem (
    relationshipitemid integer NOT NULL,
    relationshipid bigint,
    trackedentityinstanceid bigint,
    programinstanceid bigint,
    programstageinstanceid bigint
);


ALTER TABLE public.relationshipitem OWNER TO dhis;

--
-- Name: relationshiptype; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.relationshiptype (
    relationshiptypeid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description character varying(255),
    from_relationshipconstraintid integer,
    to_relationshipconstraintid integer,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    bidirectional boolean NOT NULL,
    fromtoname character varying(255) NOT NULL,
    tofromname character varying(255),
    sharing jsonb DEFAULT '{}'::jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    referral boolean DEFAULT false NOT NULL
);


ALTER TABLE public.relationshiptype OWNER TO dhis;

--
-- Name: relativeperiods; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.relativeperiods (
    relativeperiodsid integer NOT NULL,
    thisday boolean NOT NULL,
    yesterday boolean NOT NULL,
    last3days boolean NOT NULL,
    last7days boolean NOT NULL,
    last14days boolean NOT NULL,
    thismonth boolean NOT NULL,
    lastmonth boolean NOT NULL,
    thisbimonth boolean NOT NULL,
    lastbimonth boolean NOT NULL,
    thisquarter boolean NOT NULL,
    lastquarter boolean NOT NULL,
    thissixmonth boolean NOT NULL,
    lastsixmonth boolean NOT NULL,
    weeksthisyear boolean,
    monthsthisyear boolean NOT NULL,
    bimonthsthisyear boolean,
    quartersthisyear boolean NOT NULL,
    thisyear boolean NOT NULL,
    monthslastyear boolean NOT NULL,
    quarterslastyear boolean NOT NULL,
    lastyear boolean NOT NULL,
    last5years boolean NOT NULL,
    last12months boolean NOT NULL,
    last6months boolean NOT NULL,
    last3months boolean NOT NULL,
    last6bimonths boolean NOT NULL,
    last4quarters boolean NOT NULL,
    last2sixmonths boolean NOT NULL,
    thisfinancialyear boolean NOT NULL,
    lastfinancialyear boolean NOT NULL,
    last5financialyears boolean NOT NULL,
    thisweek boolean NOT NULL,
    lastweek boolean NOT NULL,
    thisbiweek boolean,
    lastbiweek boolean,
    last4weeks boolean NOT NULL,
    last4biweeks boolean,
    last12weeks boolean NOT NULL,
    last52weeks boolean NOT NULL,
    last30days boolean NOT NULL,
    last60days boolean NOT NULL,
    last90days boolean NOT NULL,
    last180days boolean NOT NULL,
    last10years boolean NOT NULL,
    last10financialyears boolean NOT NULL
);


ALTER TABLE public.relativeperiods OWNER TO dhis;

--
-- Name: report; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.report (
    reportid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    type character varying(50),
    designcontent text,
    relativeperiodsid integer,
    paramreportingmonth boolean,
    paramorganisationunit boolean,
    cachestrategy character varying(40),
    externalaccess boolean,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    visualizationid bigint,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.report OWNER TO dhis;

--
-- Name: reservedvalue; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.reservedvalue (
    reservedvalueid integer NOT NULL,
    expirydate timestamp without time zone NOT NULL,
    created timestamp without time zone NOT NULL,
    ownerobject character varying(255),
    owneruid character varying(255),
    key character varying(255),
    value character varying(255)
);


ALTER TABLE public.reservedvalue OWNER TO dhis;

--
-- Name: reservedvalue_sequence; Type: SEQUENCE; Schema: public; Owner: dhis
--

CREATE SEQUENCE public.reservedvalue_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reservedvalue_sequence OWNER TO dhis;

--
-- Name: section; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.section (
    sectionid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    datasetid bigint NOT NULL,
    sortorder integer NOT NULL,
    showrowtotals boolean,
    showcolumntotals boolean,
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    disabledataelementautogroup boolean DEFAULT false
);


ALTER TABLE public.section OWNER TO dhis;

--
-- Name: sectiondataelements; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.sectiondataelements (
    sectionid bigint NOT NULL,
    sort_order integer NOT NULL,
    dataelementid bigint NOT NULL
);


ALTER TABLE public.sectiondataelements OWNER TO dhis;

--
-- Name: sectiongreyedfields; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.sectiongreyedfields (
    sectionid bigint NOT NULL,
    dataelementoperandid bigint NOT NULL
);


ALTER TABLE public.sectiongreyedfields OWNER TO dhis;

--
-- Name: sectionindicators; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.sectionindicators (
    sectionid bigint NOT NULL,
    sort_order integer NOT NULL,
    indicatorid bigint NOT NULL
);


ALTER TABLE public.sectionindicators OWNER TO dhis;

--
-- Name: sequentialnumbercounter; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.sequentialnumbercounter (
    id integer NOT NULL,
    owneruid character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    counter integer
);


ALTER TABLE public.sequentialnumbercounter OWNER TO dhis;

--
-- Name: series; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.series (
    seriesid bigint NOT NULL,
    series character varying(255) NOT NULL,
    axis integer NOT NULL
);


ALTER TABLE public.series OWNER TO dhis;

--
-- Name: smscodes; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.smscodes (
    smscodeid integer NOT NULL,
    code character varying(255),
    formula text,
    compulsory boolean,
    dataelementid bigint,
    trackedentityattributeid bigint,
    optionid bigint
);


ALTER TABLE public.smscodes OWNER TO dhis;

--
-- Name: smscommandcodes; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.smscommandcodes (
    id bigint NOT NULL,
    codeid integer NOT NULL
);


ALTER TABLE public.smscommandcodes OWNER TO dhis;

--
-- Name: smscommands; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.smscommands (
    smscommandid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    name text,
    parsertype integer,
    separatorkey text,
    codeseparator text,
    defaultmessage text,
    receivedmessage text,
    wrongformatmessage text,
    nousermessage text,
    morethanoneorgunitmessage text,
    successmessage text,
    currentperiodusedforreporting boolean,
    completenessmethod text,
    datasetid bigint,
    usergroupid bigint,
    programid bigint,
    programstageid bigint
);


ALTER TABLE public.smscommands OWNER TO dhis;

--
-- Name: smscommandspecialcharacters; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.smscommandspecialcharacters (
    smscommandid bigint NOT NULL,
    specialcharacterid integer NOT NULL
);


ALTER TABLE public.smscommandspecialcharacters OWNER TO dhis;

--
-- Name: smsspecialcharacter; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.smsspecialcharacter (
    specialcharacterid integer NOT NULL,
    name text,
    value text
);


ALTER TABLE public.smsspecialcharacter OWNER TO dhis;

--
-- Name: sqlview; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.sqlview (
    sqlviewid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    sqlquery text NOT NULL,
    type character varying(40) NOT NULL,
    cachestrategy character varying(40) NOT NULL,
    externalaccess boolean,
    userid bigint,
    publicaccess character varying(8),
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.sqlview OWNER TO dhis;

--
-- Name: systemsetting; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.systemsetting (
    systemsettingid bigint NOT NULL,
    name character varying(255) NOT NULL,
    value text,
    translations jsonb
);


ALTER TABLE public.systemsetting OWNER TO dhis;

--
-- Name: tablehook; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.tablehook (
    analyticstablehookid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(255) NOT NULL,
    analyticstablephase character varying(50) NOT NULL,
    resourcetabletype character varying(50),
    analyticstabletype character varying(50),
    sql text NOT NULL
);


ALTER TABLE public.tablehook OWNER TO dhis;

--
-- Name: trackedentityattribute; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.trackedentityattribute (
    trackedentityattributeid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    shortname character varying(50) NOT NULL,
    description text,
    formname text,
    valuetype character varying(36) NOT NULL,
    aggregationtype character varying(40) NOT NULL,
    optionsetid bigint,
    inherit boolean,
    expression character varying(255),
    displayonvisitschedule boolean,
    sortorderinvisitschedule integer,
    displayinlistnoprogram boolean,
    sortorderinlistnoprogram integer,
    confidential boolean,
    uniquefield boolean,
    generated boolean,
    pattern character varying(255),
    textpattern jsonb,
    style jsonb,
    orgunitscope boolean,
    skipsynchronization boolean NOT NULL,
    userid bigint,
    publicaccess character varying(8),
    fieldmask character varying(255),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.trackedentityattribute OWNER TO dhis;

--
-- Name: trackedentityattributedimension; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.trackedentityattributedimension (
    trackedentityattributedimensionid integer NOT NULL,
    trackedentityattributeid bigint,
    legendsetid bigint,
    filter text
);


ALTER TABLE public.trackedentityattributedimension OWNER TO dhis;

--
-- Name: trackedentityattributelegendsets; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.trackedentityattributelegendsets (
    trackedentityattributeid bigint NOT NULL,
    sort_order integer NOT NULL,
    legendsetid bigint NOT NULL
);


ALTER TABLE public.trackedentityattributelegendsets OWNER TO dhis;

--
-- Name: trackedentityattributevalue; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.trackedentityattributevalue (
    trackedentityinstanceid bigint NOT NULL,
    trackedentityattributeid bigint NOT NULL,
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    value character varying(1200),
    encryptedvalue character varying(50000),
    storedby character varying(255)
);


ALTER TABLE public.trackedentityattributevalue OWNER TO dhis;

--
-- Name: trackedentityattributevalueaudit; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.trackedentityattributevalueaudit (
    trackedentityattributevalueauditid bigint NOT NULL,
    trackedentityinstanceid bigint,
    trackedentityattributeid bigint,
    value character varying(50000),
    encryptedvalue character varying(50000),
    created timestamp without time zone,
    modifiedby character varying(255),
    audittype character varying(100) NOT NULL
);


ALTER TABLE public.trackedentityattributevalueaudit OWNER TO dhis;

--
-- Name: trackedentitycomment; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.trackedentitycomment (
    trackedentitycommentid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    commenttext text,
    creator character varying(255)
);


ALTER TABLE public.trackedentitycomment OWNER TO dhis;

--
-- Name: trackedentitydataelementdimension; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.trackedentitydataelementdimension (
    trackedentitydataelementdimensionid integer NOT NULL,
    dataelementid bigint,
    legendsetid bigint,
    filter text,
    programstageid bigint
);


ALTER TABLE public.trackedentitydataelementdimension OWNER TO dhis;

--
-- Name: trackedentitydatavalueaudit; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.trackedentitydatavalueaudit (
    trackedentitydatavalueauditid bigint NOT NULL,
    programstageinstanceid bigint,
    dataelementid bigint,
    value character varying(50000),
    created timestamp without time zone,
    providedelsewhere boolean,
    modifiedby character varying(255),
    audittype character varying(100) NOT NULL
);


ALTER TABLE public.trackedentitydatavalueaudit OWNER TO dhis;

--
-- Name: trackedentitydatavalueaudit_sequence; Type: SEQUENCE; Schema: public; Owner: dhis
--

CREATE SEQUENCE public.trackedentitydatavalueaudit_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trackedentitydatavalueaudit_sequence OWNER TO dhis;

--
-- Name: trackedentityinstance; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.trackedentityinstance (
    trackedentityinstanceid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    createdatclient timestamp without time zone,
    lastupdatedatclient timestamp without time zone,
    inactive boolean DEFAULT false NOT NULL,
    deleted boolean NOT NULL,
    lastsynchronized timestamp without time zone DEFAULT to_timestamp((0)::double precision) NOT NULL,
    featuretype character varying(50),
    coordinates text,
    organisationunitid bigint NOT NULL,
    trackedentitytypeid bigint,
    geometry public.geometry,
    storedby character varying(255),
    createdbyuserinfo jsonb,
    lastupdatedbyuserinfo jsonb,
    potentialduplicate boolean DEFAULT false
);


ALTER TABLE public.trackedentityinstance OWNER TO dhis;

--
-- Name: trackedentityinstance_sequence; Type: SEQUENCE; Schema: public; Owner: dhis
--

CREATE SEQUENCE public.trackedentityinstance_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trackedentityinstance_sequence OWNER TO dhis;

--
-- Name: trackedentityinstanceaudit; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.trackedentityinstanceaudit (
    trackedentityinstanceauditid bigint NOT NULL,
    trackedentityinstance character varying(255),
    created timestamp without time zone,
    accessedby character varying(255),
    audittype character varying(100) NOT NULL,
    comment character varying(50000)
);


ALTER TABLE public.trackedentityinstanceaudit OWNER TO dhis;

--
-- Name: trackedentityinstanceaudit_sequence; Type: SEQUENCE; Schema: public; Owner: dhis
--

CREATE SEQUENCE public.trackedentityinstanceaudit_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trackedentityinstanceaudit_sequence OWNER TO dhis;

--
-- Name: trackedentityinstancefilter; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.trackedentityinstancefilter (
    trackedentityinstancefilterid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description character varying(255),
    sortorder integer,
    style jsonb,
    programid bigint NOT NULL,
    eventfilters jsonb,
    translations jsonb,
    sharing jsonb DEFAULT '{}'::jsonb,
    userid bigint,
    entityquerycriteria jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.trackedentityinstancefilter OWNER TO dhis;

--
-- Name: trackedentityprogramindicatordimension; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.trackedentityprogramindicatordimension (
    trackedentityprogramindicatordimensionid integer NOT NULL,
    programindicatorid bigint,
    legendsetid bigint,
    filter text
);


ALTER TABLE public.trackedentityprogramindicatordimension OWNER TO dhis;

--
-- Name: trackedentityprogramowner; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.trackedentityprogramowner (
    trackedentityprogramownerid integer NOT NULL,
    trackedentityinstanceid bigint,
    programid bigint NOT NULL,
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    organisationunitid bigint,
    createdby character varying(255) NOT NULL
);


ALTER TABLE public.trackedentityprogramowner OWNER TO dhis;

--
-- Name: trackedentitytype; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.trackedentitytype (
    trackedentitytypeid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    formname text,
    style jsonb,
    minattributesrequiredtosearch integer,
    maxteicounttoreturn integer,
    allowauditlog boolean,
    userid bigint,
    publicaccess character varying(8),
    featuretype character varying(255),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.trackedentitytype OWNER TO dhis;

--
-- Name: trackedentitytypeattribute; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.trackedentitytypeattribute (
    trackedentitytypeattributeid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    trackedentitytypeid bigint,
    trackedentityattributeid bigint NOT NULL,
    displayinlist boolean,
    mandatory boolean,
    searchable boolean,
    sort_order integer
);


ALTER TABLE public.trackedentitytypeattribute OWNER TO dhis;

--
-- Name: userapps; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.userapps (
    userinfoid bigint NOT NULL,
    sort_order integer NOT NULL,
    app character varying(255)
);


ALTER TABLE public.userapps OWNER TO dhis;

--
-- Name: userdatavieworgunits; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.userdatavieworgunits (
    userinfoid bigint NOT NULL,
    organisationunitid bigint NOT NULL
);


ALTER TABLE public.userdatavieworgunits OWNER TO dhis;

--
-- Name: usergroup; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.usergroup (
    usergroupid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    uuid uuid,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.usergroup OWNER TO dhis;

--
-- Name: usergroupmanaged; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.usergroupmanaged (
    managedbygroupid bigint NOT NULL,
    managedgroupid bigint NOT NULL
);


ALTER TABLE public.usergroupmanaged OWNER TO dhis;

--
-- Name: usergroupmembers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.usergroupmembers (
    userid bigint NOT NULL,
    usergroupid bigint NOT NULL
);


ALTER TABLE public.usergroupmembers OWNER TO dhis;

--
-- Name: userinfo; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.userinfo (
    userinfoid bigint NOT NULL,
    uid character varying(11),
    code character varying(50),
    lastupdated timestamp without time zone NOT NULL,
    created timestamp without time zone NOT NULL,
    surname character varying(160) NOT NULL,
    firstname character varying(160) NOT NULL,
    email character varying(160),
    phonenumber character varying(80),
    jobtitle character varying(160),
    introduction text,
    gender character varying(50),
    birthday date,
    nationality character varying(160),
    employer character varying(160),
    education text,
    interests text,
    languages text,
    welcomemessage text,
    lastcheckedinterpretations timestamp without time zone,
    whatsapp character varying(255),
    skype character varying(255),
    facebookmessenger character varying(255),
    telegram character varying(255),
    twitter character varying(255),
    avatar bigint,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    dataviewmaxorgunitlevel integer,
    lastupdatedby bigint,
    creatoruserid bigint,
    username character varying(255),
    password character varying(60),
    secret text,
    twofa boolean,
    externalauth boolean,
    openid text,
    ldapid text,
    passwordlastupdated timestamp without time zone,
    lastlogin timestamp without time zone,
    restoretoken character varying(255),
    restoreexpiry timestamp without time zone,
    selfregistered boolean,
    invitation boolean,
    disabled boolean,
    uuid uuid,
    accountexpiry timestamp without time zone,
    idtoken character varying(255)
);


ALTER TABLE public.userinfo OWNER TO dhis;

--
-- Name: userkeyjsonvalue; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.userkeyjsonvalue (
    userkeyjsonvalueid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    userid bigint NOT NULL,
    namespace character varying(255) NOT NULL,
    userkey character varying(255) NOT NULL,
    encrypted_value character varying(255),
    encrypted boolean,
    jbvalue jsonb
);


ALTER TABLE public.userkeyjsonvalue OWNER TO dhis;

--
-- Name: usermembership; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.usermembership (
    organisationunitid bigint NOT NULL,
    userinfoid bigint NOT NULL
);


ALTER TABLE public.usermembership OWNER TO dhis;

--
-- Name: usermessage; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.usermessage (
    usermessageid integer NOT NULL,
    usermessagekey character varying(255),
    userid bigint NOT NULL,
    isread boolean NOT NULL,
    isfollowup boolean
);


ALTER TABLE public.usermessage OWNER TO dhis;

--
-- Name: usermessage_sequence; Type: SEQUENCE; Schema: public; Owner: dhis
--

CREATE SEQUENCE public.usermessage_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.usermessage_sequence OWNER TO dhis;

--
-- Name: userrole; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.userrole (
    userroleid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description character varying(255),
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.userrole OWNER TO dhis;

--
-- Name: userroleauthorities; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.userroleauthorities (
    userroleid bigint NOT NULL,
    authority character varying(255)
);

ALTER TABLE ONLY public.userroleauthorities REPLICA IDENTITY FULL;


ALTER TABLE public.userroleauthorities OWNER TO dhis;

--
-- Name: userrolemembers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.userrolemembers (
    userroleid bigint NOT NULL,
    userid bigint NOT NULL
);


ALTER TABLE public.userrolemembers OWNER TO dhis;

--
-- Name: users_catdimensionconstraints; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.users_catdimensionconstraints (
    userid bigint NOT NULL,
    dataelementcategoryid bigint NOT NULL
);


ALTER TABLE public.users_catdimensionconstraints OWNER TO dhis;

--
-- Name: users_cogsdimensionconstraints; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.users_cogsdimensionconstraints (
    userid bigint NOT NULL,
    categoryoptiongroupsetid bigint NOT NULL
);


ALTER TABLE public.users_cogsdimensionconstraints OWNER TO dhis;

--
-- Name: usersetting; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.usersetting (
    userinfoid bigint NOT NULL,
    name character varying(255) NOT NULL,
    value bytea
);


ALTER TABLE public.usersetting OWNER TO dhis;

--
-- Name: userteisearchorgunits; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.userteisearchorgunits (
    userinfoid bigint NOT NULL,
    organisationunitid bigint NOT NULL
);


ALTER TABLE public.userteisearchorgunits OWNER TO dhis;

--
-- Name: validationnotificationtemplate; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.validationnotificationtemplate (
    validationnotificationtemplateid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    subjecttemplate character varying(100),
    messagetemplate text,
    notifyusersinhierarchyonly boolean,
    sendstrategy character varying(50) NOT NULL,
    translations jsonb DEFAULT '[]'::jsonb
);


ALTER TABLE public.validationnotificationtemplate OWNER TO dhis;

--
-- Name: validationnotificationtemplate_recipientusergroups; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.validationnotificationtemplate_recipientusergroups (
    validationnotificationtemplateid bigint NOT NULL,
    usergroupid bigint NOT NULL
);


ALTER TABLE public.validationnotificationtemplate_recipientusergroups OWNER TO dhis;

--
-- Name: validationnotificationtemplatevalidationrules; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.validationnotificationtemplatevalidationrules (
    validationnotificationtemplateid bigint NOT NULL,
    validationruleid bigint NOT NULL
);


ALTER TABLE public.validationnotificationtemplatevalidationrules OWNER TO dhis;

--
-- Name: validationresult; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.validationresult (
    validationresultid bigint NOT NULL,
    created timestamp without time zone NOT NULL,
    leftsidevalue double precision,
    rightsidevalue double precision,
    validationruleid bigint,
    periodid bigint,
    organisationunitid bigint,
    attributeoptioncomboid bigint,
    dayinperiod integer,
    notificationsent boolean
);


ALTER TABLE public.validationresult OWNER TO dhis;

--
-- Name: validationrule; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.validationrule (
    validationruleid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    instruction text,
    importance character varying(50),
    operator character varying(255) NOT NULL,
    leftexpressionid bigint,
    rightexpressionid bigint,
    skipformvalidation boolean,
    periodtypeid integer NOT NULL,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.validationrule OWNER TO dhis;

--
-- Name: validationrulegroup; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.validationrulegroup (
    validationrulegroupid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    lastupdatedby bigint,
    name character varying(230) NOT NULL,
    description text,
    userid bigint,
    publicaccess character varying(8),
    translations jsonb,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    sharing jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.validationrulegroup OWNER TO dhis;

--
-- Name: validationrulegroupmembers; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.validationrulegroupmembers (
    validationgroupid bigint NOT NULL,
    validationruleid bigint NOT NULL
);


ALTER TABLE public.validationrulegroupmembers OWNER TO dhis;

--
-- Name: validationruleorganisationunitlevels; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.validationruleorganisationunitlevels (
    validationruleid bigint NOT NULL,
    organisationunitlevel integer
);

ALTER TABLE ONLY public.validationruleorganisationunitlevels REPLICA IDENTITY FULL;


ALTER TABLE public.validationruleorganisationunitlevels OWNER TO dhis;

--
-- Name: version; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.version (
    versionid bigint NOT NULL,
    versionkey character varying(230) NOT NULL,
    versionvalue character varying(255)
);


ALTER TABLE public.version OWNER TO dhis;

--
-- Name: visualization; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.visualization (
    visualizationid bigint NOT NULL,
    uid character varying(11) NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    code character varying(50),
    title character varying(255),
    subtitle character varying(255),
    description text,
    created timestamp without time zone,
    startdate timestamp without time zone,
    enddate timestamp without time zone,
    sortorder integer,
    toplimit integer,
    userid bigint,
    userorgunittype character varying(20),
    publicaccess character varying(8),
    displaydensity character varying(255),
    fontsize character varying(255),
    relativeperiodsid integer,
    digitgroupseparator character varying(255),
    legendsetid bigint,
    legenddisplaystyle character varying(40),
    legenddisplaystrategy character varying(40),
    aggregationtype character varying(255),
    regressiontype character varying(40),
    targetlinevalue double precision,
    targetlinelabel character varying(255),
    rangeaxislabel character varying(255),
    rangeaxismaxvalue double precision,
    rangeaxissteps integer,
    rangeaxisdecimals integer,
    rangeaxisminvalue double precision,
    domainaxislabel character varying(255),
    baselinevalue double precision,
    baselinelabel character varying(255),
    numbertype character varying(40),
    measurecriteria character varying(255),
    hideemptyrowitems character varying(40),
    percentstackedvalues boolean,
    nospacebetweencolumns boolean,
    regression boolean,
    externalaccess boolean,
    userorganisationunit boolean,
    userorganisationunitchildren boolean,
    userorganisationunitgrandchildren boolean,
    paramreportingperiod boolean,
    paramorganisationunit boolean,
    paramparentorganisationunit boolean,
    paramgrandparentorganisationunit boolean,
    rowtotals boolean,
    coltotals boolean,
    cumulative boolean,
    rowsubtotals boolean,
    colsubtotals boolean,
    completedonly boolean,
    skiprounding boolean,
    showdimensionlabels boolean,
    hidetitle boolean,
    hidesubtitle boolean,
    hidelegend boolean,
    hideemptycolumns boolean,
    hideemptyrows boolean,
    showhierarchy boolean,
    showdata boolean,
    lastupdatedby bigint,
    lastupdated timestamp without time zone,
    favorites jsonb,
    subscribers jsonb,
    translations jsonb,
    series jsonb,
    fontstyle jsonb,
    colorset character varying(255),
    sharing jsonb DEFAULT '{}'::jsonb,
    outlieranalysis jsonb,
    fixcolumnheaders boolean NOT NULL,
    fixrowheaders boolean NOT NULL,
    attributevalues jsonb DEFAULT '{}'::jsonb,
    serieskey jsonb,
    axes jsonb,
    legendshowkey boolean
);


ALTER TABLE public.visualization OWNER TO dhis;

--
-- Name: visualization_axis; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.visualization_axis (
    visualizationid bigint NOT NULL,
    sort_order integer NOT NULL,
    axisid bigint NOT NULL
);


ALTER TABLE public.visualization_axis OWNER TO dhis;

--
-- Name: visualization_categorydimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.visualization_categorydimensions (
    visualizationid bigint NOT NULL,
    categorydimensionid integer NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.visualization_categorydimensions OWNER TO dhis;

--
-- Name: visualization_categoryoptiongroupsetdimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.visualization_categoryoptiongroupsetdimensions (
    visualizationid bigint NOT NULL,
    sort_order integer NOT NULL,
    categoryoptiongroupsetdimensionid integer NOT NULL
);


ALTER TABLE public.visualization_categoryoptiongroupsetdimensions OWNER TO dhis;

--
-- Name: visualization_columns; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.visualization_columns (
    visualizationid bigint NOT NULL,
    dimension character varying(255),
    sort_order integer NOT NULL
);


ALTER TABLE public.visualization_columns OWNER TO dhis;

--
-- Name: visualization_datadimensionitems; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.visualization_datadimensionitems (
    visualizationid bigint NOT NULL,
    datadimensionitemid integer NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.visualization_datadimensionitems OWNER TO dhis;

--
-- Name: visualization_dataelementgroupsetdimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.visualization_dataelementgroupsetdimensions (
    visualizationid bigint NOT NULL,
    sort_order integer NOT NULL,
    dataelementgroupsetdimensionid integer NOT NULL
);


ALTER TABLE public.visualization_dataelementgroupsetdimensions OWNER TO dhis;

--
-- Name: visualization_filters; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.visualization_filters (
    visualizationid bigint NOT NULL,
    dimension character varying(255),
    sort_order integer NOT NULL
);


ALTER TABLE public.visualization_filters OWNER TO dhis;

--
-- Name: visualization_itemorgunitgroups; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.visualization_itemorgunitgroups (
    visualizationid bigint NOT NULL,
    orgunitgroupid bigint NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.visualization_itemorgunitgroups OWNER TO dhis;

--
-- Name: visualization_organisationunits; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.visualization_organisationunits (
    visualizationid bigint NOT NULL,
    organisationunitid bigint NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.visualization_organisationunits OWNER TO dhis;

--
-- Name: visualization_orgunitgroupsetdimensions; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.visualization_orgunitgroupsetdimensions (
    visualizationid bigint NOT NULL,
    sort_order integer NOT NULL,
    orgunitgroupsetdimensionid integer NOT NULL
);


ALTER TABLE public.visualization_orgunitgroupsetdimensions OWNER TO dhis;

--
-- Name: visualization_orgunitlevels; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.visualization_orgunitlevels (
    visualizationid bigint NOT NULL,
    orgunitlevel integer,
    sort_order integer NOT NULL
);


ALTER TABLE public.visualization_orgunitlevels OWNER TO dhis;

--
-- Name: visualization_periods; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.visualization_periods (
    visualizationid bigint NOT NULL,
    periodid bigint NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.visualization_periods OWNER TO dhis;

--
-- Name: visualization_rows; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.visualization_rows (
    visualizationid bigint NOT NULL,
    dimension character varying(255),
    sort_order integer NOT NULL
);


ALTER TABLE public.visualization_rows OWNER TO dhis;

--
-- Name: visualization_yearlyseries; Type: TABLE; Schema: public; Owner: dhis
--

CREATE TABLE public.visualization_yearlyseries (
    visualizationid bigint NOT NULL,
    sort_order integer NOT NULL,
    yearlyseries character varying(255)
);


ALTER TABLE public.visualization_yearlyseries OWNER TO dhis;

--
-- Name: audit auditid; Type: DEFAULT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.audit ALTER COLUMN auditid SET DEFAULT nextval('public.audit_auditid_seq'::regclass);


--
-- Data for Name: aggregatedataexchange; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.aggregatedataexchange (aggregatedataexchangeid, uid, code, created, userid, lastupdated, lastupdatedby, translations, sharing, attributevalues, name, source, target) FROM stdin;
\.


--
-- Data for Name: api_token; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.api_token (apitokenid, uid, code, created, lastupdated, lastupdatedby, createdby, version, type, expire, key, attributes, sharing) FROM stdin;
\.


--
-- Data for Name: attribute; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.attribute (attributeid, uid, code, created, lastupdated, lastupdatedby, name, shortname, description, valuetype, mandatory, isunique, dataelementattribute, dataelementgroupattribute, indicatorattribute, indicatorgroupattribute, datasetattribute, organisationunitattribute, organisationunitgroupattribute, organisationunitgroupsetattribute, userattribute, usergroupattribute, programattribute, programstageattribute, trackedentitytypeattribute, trackedentityattributeattribute, categoryoptionattribute, categoryoptiongroupattribute, documentattribute, optionattribute, optionsetattribute, constantattribute, legendsetattribute, programindicatorattribute, sqlviewattribute, sectionattribute, categoryoptioncomboattribute, categoryoptiongroupsetattribute, dataelementgroupsetattribute, validationruleattribute, validationrulegroupattribute, categoryattribute, sortorder, optionsetid, userid, publicaccess, translations, sharing, visualizationattribute, mapattribute, eventreportattribute, eventchartattribute, relationshiptypeattribute) FROM stdin;
\.


--
-- Data for Name: attributevalue; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.attributevalue (attributevalueid, created, lastupdated, value, attributeid) FROM stdin;
\.


--
-- Data for Name: audit; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.audit (auditid, audittype, auditscope, createdat, createdby, klass, uid, code, attributes, data) FROM stdin;
\.


--
-- Data for Name: axis; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.axis (axisid, dimensionalitem, axis) FROM stdin;
\.


--
-- Data for Name: categories_categoryoptions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.categories_categoryoptions (categoryid, sort_order, categoryoptionid) FROM stdin;
23	1	22
\.


--
-- Data for Name: categorycombo; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.categorycombo (categorycomboid, uid, code, created, lastupdated, lastupdatedby, name, datadimensiontype, skiptotal, userid, publicaccess, translations, sharing) FROM stdin;
24	bjDvmb4bfuf	default	2024-10-21 15:44:56.903	2024-10-21 15:44:56.904	\N	default	DISAGGREGATION	f	\N	\N	[]	{"users": {}, "public": "rw------", "external": false, "userGroups": {}}
\.


--
-- Data for Name: categorycombos_categories; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.categorycombos_categories (categoryid, sort_order, categorycomboid) FROM stdin;
23	1	24
\.


--
-- Data for Name: categorycombos_optioncombos; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.categorycombos_optioncombos (categoryoptioncomboid, categorycomboid) FROM stdin;
25	24
\.


--
-- Data for Name: categorydimension; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.categorydimension (categorydimensionid, categoryid) FROM stdin;
\.


--
-- Data for Name: categorydimension_items; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.categorydimension_items (categorydimensionid, sort_order, categoryoptionid) FROM stdin;
\.


--
-- Data for Name: categoryoption_organisationunits; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.categoryoption_organisationunits (organisationunitid, categoryoptionid) FROM stdin;
\.


--
-- Data for Name: categoryoptioncombo; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.categoryoptioncombo (categoryoptioncomboid, uid, code, created, lastupdated, lastupdatedby, name, ignoreapproval, translations, attributevalues) FROM stdin;
25	HllvX50cXC0	default	2024-10-21 15:44:56.903	2024-10-21 15:44:56.904	\N	default	f	[]	{}
\.


--
-- Data for Name: categoryoptioncombos_categoryoptions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.categoryoptioncombos_categoryoptions (categoryoptioncomboid, categoryoptionid) FROM stdin;
25	22
\.


--
-- Data for Name: categoryoptiongroup; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.categoryoptiongroup (categoryoptiongroupid, uid, code, created, lastupdated, lastupdatedby, name, shortname, datadimensiontype, userid, publicaccess, translations, attributevalues, sharing) FROM stdin;
\.


--
-- Data for Name: categoryoptiongroupmembers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.categoryoptiongroupmembers (categoryoptiongroupid, categoryoptionid) FROM stdin;
\.


--
-- Data for Name: categoryoptiongroupset; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.categoryoptiongroupset (categoryoptiongroupsetid, uid, code, created, lastupdated, lastupdatedby, name, description, datadimension, datadimensiontype, userid, publicaccess, translations, attributevalues, sharing, shortname) FROM stdin;
\.


--
-- Data for Name: categoryoptiongroupsetdimension; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.categoryoptiongroupsetdimension (categoryoptiongroupsetdimensionid, categoryoptiongroupsetid) FROM stdin;
\.


--
-- Data for Name: categoryoptiongroupsetdimension_items; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.categoryoptiongroupsetdimension_items (categoryoptiongroupsetdimensionid, sort_order, categoryoptiongroupid) FROM stdin;
\.


--
-- Data for Name: categoryoptiongroupsetmembers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.categoryoptiongroupsetmembers (categoryoptiongroupid, categoryoptiongroupsetid, sort_order) FROM stdin;
\.


--
-- Data for Name: completedatasetregistration; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.completedatasetregistration (datasetid, periodid, sourceid, attributeoptioncomboid, date, storedby, lastupdatedby, lastupdated, completed) FROM stdin;
\.


--
-- Data for Name: configuration; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.configuration (configurationid, systemid, feedbackrecipientsid, offlineorgunitlevelid, infrastructuralindicatorsid, infrastructuraldataelementsid, infrastructuralperiodtypeid, selfregistrationrole, selfregistrationorgunit, facilityorgunitgroupset, facilityorgunitlevel, systemupdatenotificationrecipientsid) FROM stdin;
26	4ed0a8a3-79b2-4d04-b8d6-99297a0ea576	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: configuration_corswhitelist; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.configuration_corswhitelist (configurationid, corswhitelist) FROM stdin;
\.


--
-- Data for Name: constant; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.constant (constantid, uid, code, created, lastupdated, lastupdatedby, name, shortname, description, value, userid, publicaccess, translations, attributevalues, sharing) FROM stdin;
\.


--
-- Data for Name: dashboard; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dashboard (dashboardid, uid, code, created, lastupdated, lastupdatedby, name, description, userid, externalaccess, publicaccess, favorites, translations, sharing, restrictfilters, allowedfilters, layout, itemconfig) FROM stdin;
\.


--
-- Data for Name: dashboard_items; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dashboard_items (dashboardid, sort_order, dashboarditemid) FROM stdin;
\.


--
-- Data for Name: dashboarditem; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dashboarditem (dashboarditemid, uid, code, created, lastupdated, lastupdatedby, eventchartid, mapid, textcontent, messages, appkey, shape, x, y, height, width, eventreport, translations, visualizationid, eventvisualizationid) FROM stdin;
\.


--
-- Data for Name: dashboarditem_reports; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dashboarditem_reports (dashboarditemid, sort_order, reportid) FROM stdin;
\.


--
-- Data for Name: dashboarditem_resources; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dashboarditem_resources (dashboarditemid, sort_order, resourceid) FROM stdin;
\.


--
-- Data for Name: dashboarditem_users; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dashboarditem_users (dashboarditemid, sort_order, userid) FROM stdin;
\.


--
-- Data for Name: dataapproval; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataapproval (dataapprovalid, dataapprovallevelid, workflowid, periodid, organisationunitid, attributeoptioncomboid, accepted, created, creator, lastupdated, lastupdatedby) FROM stdin;
\.


--
-- Data for Name: dataapprovalaudit; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataapprovalaudit (dataapprovalauditid, levelid, workflowid, periodid, organisationunitid, attributeoptioncomboid, action, created, creator) FROM stdin;
\.


--
-- Data for Name: dataapprovallevel; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataapprovallevel (dataapprovallevelid, uid, code, created, lastupdated, lastupdatedby, name, level, orgunitlevel, categoryoptiongroupsetid, userid, publicaccess, translations, sharing) FROM stdin;
\.


--
-- Data for Name: dataapprovalworkflow; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataapprovalworkflow (workflowid, uid, code, created, lastupdated, lastupdatedby, name, periodtypeid, categorycomboid, userid, publicaccess, translations, sharing) FROM stdin;
\.


--
-- Data for Name: dataapprovalworkflowlevels; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataapprovalworkflowlevels (workflowid, dataapprovallevelid) FROM stdin;
\.


--
-- Data for Name: datadimensionitem; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.datadimensionitem (datadimensionitemid, indicatorid, dataelementid, dataelementoperand_dataelementid, dataelementoperand_categoryoptioncomboid, datasetid, metric, programindicatorid, programdataelement_programid, programdataelement_dataelementid, programattribute_programid, programattribute_attributeid) FROM stdin;
\.


--
-- Data for Name: dataelement; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataelement (dataelementid, uid, code, created, lastupdated, lastupdatedby, name, shortname, description, formname, style, valuetype, domaintype, aggregationtype, categorycomboid, url, zeroissignificant, optionsetid, commentoptionsetid, userid, publicaccess, fieldmask, translations, attributevalues, sharing, valuetypeoptions) FROM stdin;
70	RkJvBfKDu6z	BCG	2024-10-21 15:47:32.21	2024-10-21 15:47:32.21	1	BCG	BCG	\N	\N	\N	NUMBER	AGGREGATE	SUM	24	\N	t	\N	\N	1	\N	\N	[]	{}	{"owner": "M5zQapPyTZI", "users": {}, "public": "rw------", "external": false, "userGroups": {}}	\N
71	TKGKvcwuR7v	\N	2024-10-21 15:48:17.549	2024-10-21 15:48:17.549	1	IPV	IPV	\N	\N	\N	NUMBER	AGGREGATE	SUM	24	\N	t	\N	\N	1	\N	\N	[]	{}	{"owner": "M5zQapPyTZI", "users": {}, "public": "rw------", "external": false, "userGroups": {}}	\N
72	S7sI7yDpm0t	PCV-10	2024-10-21 15:48:29.824	2024-10-21 15:48:29.824	1	PCV-10	PCV-10	\N	\N	\N	NUMBER	AGGREGATE	SUM	24	\N	f	\N	\N	1	\N	\N	[]	{}	{"owner": "M5zQapPyTZI", "users": {}, "public": "rw------", "external": false, "userGroups": {}}	\N
\.


--
-- Data for Name: dataelementaggregationlevels; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataelementaggregationlevels (dataelementid, sort_order, aggregationlevel) FROM stdin;
\.


--
-- Data for Name: dataelementcategory; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataelementcategory (categoryid, uid, code, created, lastupdated, lastupdatedby, name, datadimensiontype, datadimension, userid, publicaccess, translations, attributevalues, sharing, shortname) FROM stdin;
23	GLevLNI9wkl	default	2024-10-21 15:44:56.902	2024-10-21 15:44:56.922	\N	default	DISAGGREGATION	f	\N	\N	[]	{}	{"users": {}, "public": "rw------", "external": false, "userGroups": {}}	default
\.


--
-- Data for Name: dataelementcategoryoption; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataelementcategoryoption (categoryoptionid, uid, code, created, lastupdated, lastupdatedby, name, shortname, startdate, enddate, style, userid, publicaccess, translations, formname, attributevalues, sharing, description) FROM stdin;
22	xYerKDKCefk	default	2024-10-21 15:44:56.901	2024-10-21 15:44:56.904	\N	default	\N	\N	\N	\N	\N	\N	[]	\N	{}	{"users": {}, "public": "rwrw----", "external": false, "userGroups": {}}	\N
\.


--
-- Data for Name: dataelementgroup; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataelementgroup (dataelementgroupid, uid, code, created, lastupdated, lastupdatedby, name, shortname, userid, publicaccess, translations, attributevalues, description, sharing) FROM stdin;
\.


--
-- Data for Name: dataelementgroupmembers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataelementgroupmembers (dataelementid, dataelementgroupid) FROM stdin;
\.


--
-- Data for Name: dataelementgroupset; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataelementgroupset (dataelementgroupsetid, uid, code, created, lastupdated, lastupdatedby, name, description, compulsory, datadimension, userid, publicaccess, translations, attributevalues, sharing, shortname) FROM stdin;
\.


--
-- Data for Name: dataelementgroupsetdimension; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataelementgroupsetdimension (dataelementgroupsetdimensionid, dataelementgroupsetid) FROM stdin;
\.


--
-- Data for Name: dataelementgroupsetdimension_items; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataelementgroupsetdimension_items (dataelementgroupsetdimensionid, sort_order, dataelementgroupid) FROM stdin;
\.


--
-- Data for Name: dataelementgroupsetmembers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataelementgroupsetmembers (dataelementgroupsetid, sort_order, dataelementgroupid) FROM stdin;
\.


--
-- Data for Name: dataelementlegendsets; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataelementlegendsets (dataelementid, sort_order, legendsetid) FROM stdin;
\.


--
-- Data for Name: dataelementoperand; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataelementoperand (dataelementoperandid, dataelementid, categoryoptioncomboid) FROM stdin;
\.


--
-- Data for Name: dataentryform; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataentryform (dataentryformid, uid, code, created, lastupdated, lastupdatedby, name, style, htmlcode, format, translations) FROM stdin;
\.


--
-- Data for Name: datainputperiod; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.datainputperiod (datainputperiodid, periodid, openingdate, closingdate, datasetid) FROM stdin;
\.


--
-- Data for Name: dataset; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.dataset (datasetid, uid, code, created, lastupdated, lastupdatedby, name, shortname, description, formname, style, periodtypeid, categorycomboid, mobile, version, expirydays, timelydays, notifycompletinguser, workflowid, openfutureperiods, fieldcombinationrequired, validcompleteonly, novaluerequirescomment, skipoffline, dataelementdecoration, renderastabs, renderhorizontally, compulsoryfieldscompleteonly, userid, publicaccess, dataentryform, notificationrecipients, translations, attributevalues, openperiodsaftercoenddate, sharing) FROM stdin;
73	Xzt6RhN5y71	\N	2024-10-21 15:49:07.934	2024-10-21 15:49:14.04	1	Vaccines Demo	\N	\N	\N	\N	10	24	f	1	0	15	f	\N	0	f	f	f	f	f	f	f	f	1	\N	\N	\N	[]	{}	0	{"owner": "M5zQapPyTZI", "users": {}, "public": "rw------", "external": false, "userGroups": {}}
\.


--
-- Data for Name: datasetelement; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.datasetelement (datasetelementid, datasetid, dataelementid, categorycomboid) FROM stdin;
77	73	72	\N
78	73	70	\N
79	73	71	\N
\.


--
-- Data for Name: datasetindicators; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.datasetindicators (indicatorid, datasetid) FROM stdin;
\.


--
-- Data for Name: datasetlegendsets; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.datasetlegendsets (datasetid, sort_order, legendsetid) FROM stdin;
\.


--
-- Data for Name: datasetnotification_datasets; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.datasetnotification_datasets (datasetnotificationtemplateid, datasetid) FROM stdin;
\.


--
-- Data for Name: datasetnotificationtemplate; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.datasetnotificationtemplate (datasetnotificationtemplateid, uid, code, created, lastupdated, lastupdatedby, name, subjecttemplate, messagetemplate, relativescheduleddays, notifyparentorganisationunitonly, notifyusersinhierarchyonly, sendstrategy, usergroupid, datasetnotificationtrigger, notificationrecipienttype, translations) FROM stdin;
\.


--
-- Data for Name: datasetnotificationtemplate_deliverychannel; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.datasetnotificationtemplate_deliverychannel (datasetnotificationtemplateid, deliverychannel) FROM stdin;
\.


--
-- Data for Name: datasetoperands; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.datasetoperands (datasetid, dataelementoperandid) FROM stdin;
\.


--
-- Data for Name: datasetsource; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.datasetsource (sourceid, datasetid) FROM stdin;
69	73
67	73
68	73
\.


--
-- Data for Name: datastatistics; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.datastatistics (statisticsid, uid, code, created, lastupdated, lastupdatedby, mapviews, eventreportviews, eventchartviews, dashboardviews, datasetreportviews, active_users, totalviews, maps, eventreports, eventcharts, dashboards, indicators, datavalues, users, visualizationviews, visualizations, passivedashboardviews, eventvisualizationviews, eventvisualizations) FROM stdin;
\.


--
-- Data for Name: datastatisticsevent; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.datastatisticsevent (eventid, eventtype, "timestamp", username, favoriteuid) FROM stdin;
\.


--
-- Data for Name: datavalue; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.datavalue (dataelementid, periodid, sourceid, categoryoptioncomboid, attributeoptioncomboid, value, storedby, created, lastupdated, comment, followup, deleted) FROM stdin;
70	80	68	25	25	\N	admin	2024-10-21 15:49:30.827	2024-10-21 15:49:40.759	\N	f	t
71	80	68	25	25	\N	admin	2024-10-21 15:49:31.216	2024-10-21 15:49:41.273	\N	f	t
72	80	68	25	25	\N	admin	2024-10-21 15:49:31.556	2024-10-21 15:49:41.746	\N	f	t
\.


--
-- Data for Name: datavalueaudit; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.datavalueaudit (datavalueauditid, dataelementid, periodid, organisationunitid, categoryoptioncomboid, attributeoptioncomboid, value, created, modifiedby, audittype) FROM stdin;
1	70	80	68	25	25	1	2024-10-21 15:49:40.758	admin	DELETE
2	71	80	68	25	25	1	2024-10-21 15:49:41.272	admin	DELETE
3	72	80	68	25	25	1	2024-10-21 15:49:41.745	admin	DELETE
\.


--
-- Data for Name: deletedobject; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.deletedobject (deletedobjectid, klass, uid, code, deleted_at, deleted_by) FROM stdin;
\.


--
-- Data for Name: document; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.document (documentid, uid, code, created, lastupdated, lastupdatedby, name, url, fileresource, external, contenttype, attachment, externalaccess, userid, publicaccess, translations, attributevalues, sharing) FROM stdin;
\.


--
-- Data for Name: eventchart; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventchart (eventchartid, uid, code, created, lastupdated, lastupdatedby, name, description, relativeperiodsid, userorganisationunit, userorganisationunitchildren, userorganisationunitgrandchildren, programid, programstageid, startdate, enddate, dataelementvaluedimensionid, attributevaluedimensionid, aggregationtype, completedonly, timefield, title, subtitle, hidetitle, hidesubtitle, type, showdata, hideemptyrowitems, hidenadata, programstatus, eventstatus, percentstackedvalues, cumulativevalues, rangeaxismaxvalue, rangeaxisminvalue, rangeaxissteps, rangeaxisdecimals, outputtype, collapsedatadimensions, domainaxislabel, rangeaxislabel, hidelegend, nospacebetweencolumns, regressiontype, targetlinevalue, targetlinelabel, baselinevalue, baselinelabel, sortorder, externalaccess, userid, publicaccess, favorites, subscribers, translations, orgunitfield, userorgunittype, sharing, attributevalues) FROM stdin;
\.


--
-- Data for Name: eventchart_attributedimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventchart_attributedimensions (eventchartid, sort_order, trackedentityattributedimensionid) FROM stdin;
\.


--
-- Data for Name: eventchart_categorydimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventchart_categorydimensions (eventchartid, sort_order, categorydimensionid) FROM stdin;
\.


--
-- Data for Name: eventchart_categoryoptiongroupsetdimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventchart_categoryoptiongroupsetdimensions (eventchartid, sort_order, categoryoptiongroupsetdimensionid) FROM stdin;
\.


--
-- Data for Name: eventchart_columns; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventchart_columns (eventchartid, sort_order, dimension) FROM stdin;
\.


--
-- Data for Name: eventchart_dataelementdimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventchart_dataelementdimensions (eventchartid, sort_order, trackedentitydataelementdimensionid) FROM stdin;
\.


--
-- Data for Name: eventchart_filters; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventchart_filters (eventchartid, sort_order, dimension) FROM stdin;
\.


--
-- Data for Name: eventchart_itemorgunitgroups; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventchart_itemorgunitgroups (eventchartid, sort_order, orgunitgroupid) FROM stdin;
\.


--
-- Data for Name: eventchart_organisationunits; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventchart_organisationunits (eventchartid, sort_order, organisationunitid) FROM stdin;
\.


--
-- Data for Name: eventchart_orgunitgroupsetdimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventchart_orgunitgroupsetdimensions (eventchartid, sort_order, orgunitgroupsetdimensionid) FROM stdin;
\.


--
-- Data for Name: eventchart_orgunitlevels; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventchart_orgunitlevels (eventchartid, sort_order, orgunitlevel) FROM stdin;
\.


--
-- Data for Name: eventchart_periods; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventchart_periods (eventchartid, sort_order, periodid) FROM stdin;
\.


--
-- Data for Name: eventchart_programindicatordimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventchart_programindicatordimensions (eventchartid, sort_order, trackedentityprogramindicatordimensionid) FROM stdin;
\.


--
-- Data for Name: eventchart_rows; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventchart_rows (eventchartid, sort_order, dimension) FROM stdin;
\.


--
-- Data for Name: eventreport; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventreport (eventreportid, uid, code, created, lastupdated, lastupdatedby, name, description, relativeperiodsid, userorganisationunit, userorganisationunitchildren, userorganisationunitgrandchildren, programid, programstageid, startdate, enddate, dataelementvaluedimensionid, attributevaluedimensionid, aggregationtype, completedonly, timefield, title, subtitle, hidetitle, hidesubtitle, datatype, rowtotals, coltotals, rowsubtotals, colsubtotals, hideemptyrows, hidenadata, showhierarchy, outputtype, collapsedatadimensions, showdimensionlabels, digitgroupseparator, displaydensity, fontsize, programstatus, eventstatus, sortorder, toplimit, externalaccess, userid, publicaccess, favorites, subscribers, translations, orgunitfield, userorgunittype, sharing, attributevalues, simpledimensions) FROM stdin;
\.


--
-- Data for Name: eventreport_attributedimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventreport_attributedimensions (eventreportid, sort_order, trackedentityattributedimensionid) FROM stdin;
\.


--
-- Data for Name: eventreport_categorydimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventreport_categorydimensions (eventreportid, sort_order, categorydimensionid) FROM stdin;
\.


--
-- Data for Name: eventreport_categoryoptiongroupsetdimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventreport_categoryoptiongroupsetdimensions (eventreportid, sort_order, categoryoptiongroupsetdimensionid) FROM stdin;
\.


--
-- Data for Name: eventreport_columns; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventreport_columns (eventreportid, sort_order, dimension) FROM stdin;
\.


--
-- Data for Name: eventreport_dataelementdimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventreport_dataelementdimensions (eventreportid, sort_order, trackedentitydataelementdimensionid) FROM stdin;
\.


--
-- Data for Name: eventreport_filters; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventreport_filters (eventreportid, sort_order, dimension) FROM stdin;
\.


--
-- Data for Name: eventreport_itemorgunitgroups; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventreport_itemorgunitgroups (eventreportid, sort_order, orgunitgroupid) FROM stdin;
\.


--
-- Data for Name: eventreport_organisationunits; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventreport_organisationunits (eventreportid, sort_order, organisationunitid) FROM stdin;
\.


--
-- Data for Name: eventreport_orgunitgroupsetdimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventreport_orgunitgroupsetdimensions (eventreportid, sort_order, orgunitgroupsetdimensionid) FROM stdin;
\.


--
-- Data for Name: eventreport_orgunitlevels; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventreport_orgunitlevels (eventreportid, sort_order, orgunitlevel) FROM stdin;
\.


--
-- Data for Name: eventreport_periods; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventreport_periods (eventreportid, sort_order, periodid) FROM stdin;
\.


--
-- Data for Name: eventreport_programindicatordimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventreport_programindicatordimensions (eventreportid, sort_order, trackedentityprogramindicatordimensionid) FROM stdin;
\.


--
-- Data for Name: eventreport_rows; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventreport_rows (eventreportid, sort_order, dimension) FROM stdin;
\.


--
-- Data for Name: eventvisualization; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventvisualization (eventvisualizationid, uid, code, created, lastupdated, name, relativeperiodsid, userorganisationunit, userorganisationunitchildren, userorganisationunitgrandchildren, externalaccess, userid, publicaccess, programid, programstageid, startdate, enddate, sortorder, toplimit, outputtype, dataelementvaluedimensionid, attributevaluedimensionid, aggregationtype, collapsedatadimensions, hidenadata, completedonly, description, title, lastupdatedby, subtitle, hidetitle, hidesubtitle, programstatus, eventstatus, favorites, subscribers, timefield, translations, orgunitfield, userorgunittype, sharing, attributevalues, type, showdata, rangeaxismaxvalue, rangeaxisminvalue, rangeaxissteps, rangeaxisdecimals, domainaxislabel, rangeaxislabel, hidelegend, targetlinevalue, targetlinelabel, baselinevalue, baselinelabel, regressiontype, hideemptyrowitems, percentstackedvalues, cumulativevalues, nospacebetweencolumns, datatype, hideemptyrows, digitgroupseparator, displaydensity, fontsize, showhierarchy, rowtotals, coltotals, showdimensionlabels, rowsubtotals, colsubtotals, legacy, simpledimensions, eventrepetitions, legendsetid, legenddisplaystrategy, legenddisplaystyle, legendshowkey, skiprounding, sorting) FROM stdin;
\.


--
-- Data for Name: eventvisualization_attributedimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventvisualization_attributedimensions (eventvisualizationid, trackedentityattributedimensionid, sort_order) FROM stdin;
\.


--
-- Data for Name: eventvisualization_categorydimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventvisualization_categorydimensions (eventvisualizationid, sort_order, categorydimensionid) FROM stdin;
\.


--
-- Data for Name: eventvisualization_categoryoptiongroupsetdimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventvisualization_categoryoptiongroupsetdimensions (eventvisualizationid, sort_order, categoryoptiongroupsetdimensionid) FROM stdin;
\.


--
-- Data for Name: eventvisualization_columns; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventvisualization_columns (eventvisualizationid, dimension, sort_order) FROM stdin;
\.


--
-- Data for Name: eventvisualization_dataelementdimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventvisualization_dataelementdimensions (eventvisualizationid, trackedentitydataelementdimensionid, sort_order) FROM stdin;
\.


--
-- Data for Name: eventvisualization_filters; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventvisualization_filters (eventvisualizationid, dimension, sort_order) FROM stdin;
\.


--
-- Data for Name: eventvisualization_itemorgunitgroups; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventvisualization_itemorgunitgroups (eventvisualizationid, orgunitgroupid, sort_order) FROM stdin;
\.


--
-- Data for Name: eventvisualization_organisationunits; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventvisualization_organisationunits (eventvisualizationid, organisationunitid, sort_order) FROM stdin;
\.


--
-- Data for Name: eventvisualization_orgunitgroupsetdimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventvisualization_orgunitgroupsetdimensions (eventvisualizationid, sort_order, orgunitgroupsetdimensionid) FROM stdin;
\.


--
-- Data for Name: eventvisualization_orgunitlevels; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventvisualization_orgunitlevels (eventvisualizationid, orgunitlevel, sort_order) FROM stdin;
\.


--
-- Data for Name: eventvisualization_periods; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventvisualization_periods (eventvisualizationid, periodid, sort_order) FROM stdin;
\.


--
-- Data for Name: eventvisualization_programindicatordimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventvisualization_programindicatordimensions (eventvisualizationid, trackedentityprogramindicatordimensionid, sort_order) FROM stdin;
\.


--
-- Data for Name: eventvisualization_rows; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.eventvisualization_rows (eventvisualizationid, dimension, sort_order) FROM stdin;
\.


--
-- Data for Name: expression; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.expression (expressionid, description, expression, slidingwindow, missingvaluestrategy, translations) FROM stdin;
\.


--
-- Data for Name: externalfileresource; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.externalfileresource (externalfileresourceid, uid, code, created, lastupdated, lastupdatedby, accesstoken, expires, fileresourceid) FROM stdin;
\.


--
-- Data for Name: externalmaplayer; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.externalmaplayer (externalmaplayerid, uid, code, created, lastupdated, lastupdatedby, name, attribution, url, legendseturl, maplayerposition, layers, imageformat, mapservice, legendsetid, userid, publicaccess, sharing, translations) FROM stdin;
\.


--
-- Data for Name: externalnotificationlogentry; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.externalnotificationlogentry (externalnotificationlogentryid, uid, created, lastupdated, lastsentat, retries, key, templateuid, allowmultiple, triggerby) FROM stdin;
\.


--
-- Data for Name: fileresource; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.fileresource (fileresourceid, uid, code, created, lastupdated, lastupdatedby, name, contenttype, contentlength, contentmd5, storagekey, isassigned, domain, userid, hasmultiplestoragefiles, fileresourceowner) FROM stdin;
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.flyway_schema_history (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
1	2.30.0	Populate dhis2 schema if empty database	JDBC	org.hisp.dhis.db.migration.base.V2_30_0__Populate_dhis2_schema_if_empty_database	\N	dhis	2024-10-21 15:44:31.270194	1995	t
2	2.31.1	Migrations for release v31	SQL	2.31/V2_31_1__Migrations_for_release_v31.sql	-271885416	dhis	2024-10-21 15:44:31.270194	217	t
3	2.31.2	Job configuration param to jsonb	JDBC	org.hisp.dhis.db.migration.v31.V2_31_2__Job_configuration_param_to_jsonb	\N	dhis	2024-10-21 15:44:31.270194	5	t
4	2.31.3	Program notification template to templateid	JDBC	org.hisp.dhis.db.migration.v31.V2_31_3__Program_notification_template_to_templateid	\N	dhis	2024-10-21 15:44:31.270194	6	t
5	2.31.4	Add defaults for validationstrategy	JDBC	org.hisp.dhis.db.migration.v31.V2_31_4__Add_defaults_for_validationstrategy	\N	dhis	2024-10-21 15:44:31.270194	1	t
6	2.31.5	Add new user role for new capture app	JDBC	org.hisp.dhis.db.migration.v31.V2_31_5__Add_new_user_role_for_new_capture_app	\N	dhis	2024-10-21 15:44:31.270194	1	t
7	2.31.6	Update default program access level to OPEN	SQL	2.31/V2_31_6__Update_default_program_access_level_to_OPEN.sql	389837453	dhis	2024-10-21 15:44:31.270194	0	t
8	2.31.7	Delete code klass unique constraint in deleted object	SQL	2.31/V2_31_7__Delete_code_klass_unique_constraint_in_deleted_object.sql	1445061512	dhis	2024-10-21 15:44:31.270194	1	t
9	2.31.9	Add user permissions for new data viz app	JDBC	org.hisp.dhis.db.migration.v31.V2_31_9__Add_user_permissions_for_new_data_viz_app	\N	dhis	2024-10-21 15:44:31.270194	0	t
10	2.31.10	Remove storagestatus column from fileresource table	SQL	2.31/V2_31_10__Remove_storagestatus_column_from_fileresource_table.sql	-1096225816	dhis	2024-10-21 15:44:31.270194	1	t
11	2.32.1	Org unit fields	SQL	2.32/V2_32_1__Org_unit_fields.sql	-1792150736	dhis	2024-10-21 15:44:31.270194	3	t
12	2.32.2	Complete data set registration fields	SQL	2.32/V2_32_2__Complete_data_set_registration_fields.sql	-1660385962	dhis	2024-10-21 15:44:31.270194	8	t
13	2.32.3	Program rule variable option code	SQL	2.32/V2_32_3__Program_rule_variable_option_code.sql	1675218695	dhis	2024-10-21 15:44:31.270194	1	t
14	2.32.4	Remove KafkaJob	SQL	2.32/V2_32_4__Remove_KafkaJob.sql	448507296	dhis	2024-10-21 15:44:31.270194	1	t
15	2.32.5	Remove program shortname constraint	SQL	2.32/V2_32_5__Remove_program_shortname_constraint.sql	623557658	dhis	2024-10-21 15:44:31.270194	1	t
16	2.32.6	Remove program approval workflow	SQL	2.32/V2_32_6__Remove_program_approval_workflow.sql	-665392634	dhis	2024-10-21 15:44:31.270194	1	t
17	2.32.7	Introduce jsonb eventdatavalues column	SQL	2.32/V2_32_7__Introduce_jsonb_eventdatavalues_column.sql	-161817378	dhis	2024-10-21 15:44:31.270194	4	t
18	2.32.8	OrgUnit geometry field	SQL	2.32/V2_32_8__OrgUnit_geometry_field.sql	2141862134	dhis	2024-10-21 15:44:31.270194	3	t
19	2.32.9	OrgUnitGroup geometry field	SQL	2.32/V2_32_9__OrgUnitGroup_geometry_field.sql	135519777	dhis	2024-10-21 15:44:31.270194	1	t
20	2.32.10	Use bigint for id columns	SQL	2.32/V2_32_10__Use_bigint_for_id_columns.sql	1959122901	dhis	2024-10-21 15:44:31.270194	4646	t
21	2.32.11	Remove TEI representative	SQL	2.32/V2_32_11__Remove_TEI_representative.sql	1168727321	dhis	2024-10-21 15:44:31.270194	1	t
22	2.32.12	Copy timestamp values into lastupdated field	SQL	2.32/V2_32_12__Copy_timestamp_values_into_lastupdated_field.sql	-1999611754	dhis	2024-10-21 15:44:31.270194	1	t
23	2.32.13	Add UserAssignment for Events	SQL	2.32/V2_32_13__Add_UserAssignment_for_Events.sql	-1769784669	dhis	2024-10-21 15:44:31.270194	3	t
24	2.32.14	Update relationshiptype bidirectional	SQL	2.32/V2_32_14__Update_relationshiptype_bidirectional.sql	-9899667	dhis	2024-10-21 15:44:31.270194	3	t
25	2.32.15	Add chart series	SQL	2.32/V2_32_15__Add_chart_series.sql	-1373861876	dhis	2024-10-21 15:44:31.270194	4	t
26	2.32.16	Assign Job Configuration UID	SQL	2.32/V2_32_16__Assign_Job_Configuration_UID.sql	1847518055	dhis	2024-10-21 15:44:31.270194	1	t
27	2.32.17	Separate sequence generators for highly used tables	SQL	2.32/V2_32_17__Separate_sequence_generators_for_highly_used_tables.sql	-590911677	dhis	2024-10-21 15:44:31.270194	13	t
28	2.32.18	PotentialDuplicate table	SQL	2.32/V2_32_18__PotentialDuplicate_table.sql	-1711695320	dhis	2024-10-21 15:44:31.270194	6	t
29	2.32.19	Create programstageinstancefilter table	SQL	2.32/V2_32_19__Create_programstageinstancefilter_table.sql	-1655494731	dhis	2024-10-21 15:44:31.270194	14	t
30	2.32.20	Create populate mapview filter dimension tables	SQL	2.32/V2_32_20__Create_populate_mapview_filter_dimension_tables.sql	1822920300	dhis	2024-10-21 15:44:31.270194	10	t
31	2.32.21	Create categories categoryoptions index	SQL	2.32/V2_32_21__Create_categories_categoryoptions_index.sql	-127279840	dhis	2024-10-21 15:44:31.270194	1	t
32	2.32.22	Migrate pie charts new format	SQL	2.32/V2_32_22__Migrate_pie_charts_new_format.sql	694570142	dhis	2024-10-21 15:44:31.270194	3	t
33	2.32.23	Migrate gauge charts new format	SQL	2.32/V2_32_23__Migrate_gauge_charts_new_format.sql	-1159638519	dhis	2024-10-21 15:44:31.270194	2	t
34	2.33.1	Job configuration job type column to varchar	JDBC	org.hisp.dhis.db.migration.v33.V2_33_1__Job_configuration_job_type_column_to_varchar	\N	dhis	2024-10-21 15:44:31.270194	6	t
35	2.33.2	Substitute job configurations with program data sync job type with new job configurations	SQL	2.33/V2_33_2__Substitute_job_configurations_with_program_data_sync_job_type_with_new_job_configurations.sql	-2120783418	dhis	2024-10-21 15:44:31.270194	4	t
36	2.33.3	Create cateogires categoryoptions index	SQL	2.33/V2_33_3__Create_cateogires_categoryoptions_index.sql	1407320962	dhis	2024-10-21 15:44:31.270194	2	t
37	2.33.4	Create categories categoryoptions index backport	SQL	2.33/V2_33_4__Create_categories_categoryoptions_index_backport.sql	722573432	dhis	2024-10-21 15:44:31.270194	1	t
38	2.33.5	Update job parameters with system setting values	JDBC	org.hisp.dhis.db.migration.v33.V2_33_5__Update_job_parameters_with_system_setting_values	\N	dhis	2024-10-21 15:44:31.270194	6	t
39	2.33.6	Set ptea attribute not null	SQL	2.33/V2_33_6__Set_ptea_attribute_not_null.sql	672673546	dhis	2024-10-21 15:44:31.270194	1	t
40	2.33.7	Set psde data element not null	SQL	2.33/V2_33_7__Set_psde_data_element_not_null.sql	-158490623	dhis	2024-10-21 15:44:31.270194	1	t
41	2.33.8	Drop tracked entity attribute program scope	SQL	2.33/V2_33_8__Drop_tracked_entity_attribute_program_scope.sql	1868872398	dhis	2024-10-21 15:44:31.270194	0	t
42	2.33.9	CategoryOption formname field	SQL	2.33/V2_33_9__CategoryOption_formname_field.sql	-517958816	dhis	2024-10-21 15:44:31.270194	2	t
43	2.33.10	Add hasMultiple flag in FileResource	SQL	2.33/V2_33_10__Add_hasMultiple_flag_in_FileResource.sql	-814072746	dhis	2024-10-21 15:44:31.270194	1	t
44	2.33.11	Add programstageid to trackedentitydataelementdimension	SQL	2.33/V2_33_11__Add_programstageid_to_trackedentitydataelementdimension.sql	1728506538	dhis	2024-10-21 15:44:31.270194	2	t
45	2.33.12	Add renderingstrategy to mapview	SQL	2.33/V2_33_12__Add_renderingstrategy_to_mapview.sql	15230967	dhis	2024-10-21 15:44:31.270194	1	t
46	2.33.13	Migrate text based system settings to use enums	JDBC	org.hisp.dhis.db.migration.v33.V2_33_13__Migrate_text_based_system_settings_to_use_enums	\N	dhis	2024-10-21 15:44:31.270194	9	t
47	2.33.14	Add translations for dataset section	SQL	2.33/V2_33_14__Add_translations_for_dataset_section.sql	-1792497106	dhis	2024-10-21 15:44:31.270194	3	t
48	2.33.15	Add jsonb attributevalues columns	SQL	2.33/V2_33_15__Add_jsonb_attributevalues_columns.sql	366047253	dhis	2024-10-21 15:44:31.270194	26	t
49	2.33.16	Mirgrate data to jsonb attributevalues columns	SQL	2.33/V2_33_16__Mirgrate_data_to_jsonb_attributevalues_columns.sql	-659978644	dhis	2024-10-21 15:44:31.270194	56	t
50	2.33.17	Introduce nextscheduledate for programstage	SQL	2.33/V2_33_17__Introduce_nextscheduledate_for_programstage.sql	2003578911	dhis	2024-10-21 15:44:31.270194	2	t
51	2.33.19	Drop trackedentitydatavalue table	SQL	2.33/V2_33_19__Drop_trackedentitydatavalue_table.sql	1765234989	dhis	2024-10-21 15:44:31.270194	2	t
52	2.34.1	Update program rule action with environments and evaluation time columns and default values	SQL	2.34/V2_34_1__Update_program_rule_action_with_environments_and_evaluation_time_columns_and_default_values.sql	1442270640	dhis	2024-10-21 15:44:31.270194	2	t
53	2.34.2	AddUserOrgUnitTypeColumn	SQL	2.34/V2_34_2__AddUserOrgUnitTypeColumn.sql	1056975172	dhis	2024-10-21 15:44:31.270194	7	t
54	2.34.3	RemoveOrphanProgramStageInstances	SQL	2.34/V2_34_3__RemoveOrphanProgramStageInstances.sql	-801139725	dhis	2024-10-21 15:44:31.270194	3	t
55	2.34.4	Fix case in predictor expressions	SQL	2.34/V2_34_4__Fix_case_in_predictor_expressions.sql	-1270735446	dhis	2024-10-21 15:44:31.270194	1	t
56	2.34.5	Convert job configuration binary columns into varchar data type	JDBC	org.hisp.dhis.db.migration.v34.V2_34_5__Convert_job_configuration_binary_columns_into_varchar_data_type	\N	dhis	2024-10-21 15:44:31.270194	12	t
57	2.34.6	Convert systemsetting value column from bytea to string	JDBC	org.hisp.dhis.db.migration.v34.V2_34_6__Convert_systemsetting_value_column_from_bytea_to_string	\N	dhis	2024-10-21 15:44:31.270194	4	t
58	2.34.7	Convert push analysis job parameters into list of string	JDBC	org.hisp.dhis.db.migration.v34.V2_34_7__Convert_push_analysis_job_parameters_into_list_of_string	\N	dhis	2024-10-21 15:44:31.270194	7	t
59	2.34.8	Create Audit Table	SQL	2.34/V2_34_8__Create_Audit_Table.sql	1297944788	dhis	2024-10-21 15:44:31.270194	3	t
60	2.34.9	Set embedded expressions nullable and unique	SQL	2.34/V2_34_9__Set_embedded_expressions_nullable_and_unique.sql	1515537010	dhis	2024-10-21 15:44:31.270194	10	t
61	2.34.10	Update gauge charts	SQL	2.34/V2_34_10__Update_gauge_charts.sql	1164588451	dhis	2024-10-21 15:44:31.270194	1	t
62	2.34.11	Remove unused system setting	SQL	2.34/V2_34_11__Remove_unused_system_setting.sql	1607170305	dhis	2024-10-21 15:44:31.270194	0	t
63	2.34.12	Add New Visualization Tables	SQL	2.34/V2_34_12__Add_New_Visualization_Tables.sql	1474252589	dhis	2024-10-21 15:44:31.270194	46	t
64	2.34.13	Migrate Data Into Visualization Tables	SQL	2.34/V2_34_13__Migrate_Data_Into_Visualization_Tables.sql	1483161664	dhis	2024-10-21 15:44:31.270194	12	t
65	2.34.14	Add delay column to jobconfiguration	SQL	2.34/V2_34_14__Add_delay_column_to_jobconfiguration.sql	1951404576	dhis	2024-10-21 15:44:31.270194	1	t
66	2.34.15	Remove continuousexecution column from jobconfiguration	SQL	2.34/V2_34_15__Remove_continuousexecution_column_from_jobconfiguration.sql	-1994369512	dhis	2024-10-21 15:44:31.270194	0	t
67	2.34.16	Add translations column into systemsetting table	SQL	2.34/V2_34_16__Add_translations_column_into_systemsetting_table.sql	932924626	dhis	2024-10-21 15:44:31.270194	0	t
68	2.34.17	Remove FKs and update authorities interpretations on Chart ReportTable Tables	SQL	2.34/V2_34_17__Remove_FKs_and_update_authorities_interpretations_on_Chart_ReportTable_Tables.sql	2112425239	dhis	2024-10-21 15:44:31.270194	103	t
69	2.34.18	Add default values for Visualization columns	SQL	2.34/V2_34_18__Add_default_values_for_Visualization_columns.sql	1280541517	dhis	2024-10-21 15:44:31.270194	0	t
70	2.34.20	Upgrade basemap from google to bing	SQL	2.34/V2_34_20__Upgrade_basemap_from_google_to_bing.sql	352864767	dhis	2024-10-21 15:44:31.270194	0	t
71	2.34.21	Update completedatasetregistration lastupdatedby	SQL	2.34/V2_34_21__Update_completedatasetregistration_lastupdatedby.sql	-254179127	dhis	2024-10-21 15:44:31.270194	0	t
72	2.35.1	Add teav btree index	JDBC	org.hisp.dhis.db.migration.v35.V2_35_1__Add_teav_btree_index	\N	dhis	2024-10-21 15:44:31.270194	5	t
73	2.35.2	Update data sync job parameters with system setting value	JDBC	org.hisp.dhis.db.migration.v35.V2_35_2__Update_data_sync_job_parameters_with_system_setting_value	\N	dhis	2024-10-21 15:44:31.270194	1	t
74	2.35.3	Add storedBy column for TEI	SQL	2.35/V2_35_3__Add_storedBy_column_for_TEI.sql	1233785778	dhis	2024-10-21 15:44:31.270194	0	t
75	2.35.4	Remove color set	SQL	2.35/V2_35_4__Remove_color_set.sql	-814290722	dhis	2024-10-21 15:44:31.270194	5	t
76	2.35.5	Add visualization series	SQL	2.35/V2_35_5__Add_visualization_series.sql	1415646944	dhis	2024-10-21 15:44:31.270194	0	t
77	2.35.6	Add Uuid Generator	SQL	2.35/V2_35_6__Add_Uuid_Generator.sql	-1220445013	dhis	2024-10-21 15:44:31.270194	0	t
78	2.35.7	Add Uuid User Columns	SQL	2.35/V2_35_7__Add_Uuid_User_Columns.sql	1407493979	dhis	2024-10-21 15:44:31.270194	4	t
79	2.35.8	Add mapview thematicmaptype	SQL	2.35/V2_35_8__Add_mapview_thematicmaptype.sql	-342517033	dhis	2024-10-21 15:44:31.270194	1	t
80	2.35.9	Add mapview nodatacolor	SQL	2.35/V2_35_9__Add_mapview_nodatacolor.sql	-2023434005	dhis	2024-10-21 15:44:31.270194	0	t
81	2.35.10	Add visualization fontstyle	SQL	2.35/V2_35_10__Add_visualization_fontstyle.sql	994671364	dhis	2024-10-21 15:44:31.270194	1	t
82	2.35.11	Add new Map View Event Status column	SQL	2.35/V2_35_11__Add_new_Map_View_Event_Status_column.sql	1656636221	dhis	2024-10-21 15:44:31.270194	0	t
83	2.35.12	Rename All AREA Type To STACKED AREA	SQL	2.35/V2_35_12__Rename_All_AREA_Type_To_STACKED_AREA.sql	-401862667	dhis	2024-10-21 15:44:31.270194	0	t
84	2.35.13	Add visualization colorset	SQL	2.35/V2_35_13__Add_visualization_colorset.sql	898327055	dhis	2024-10-21 15:44:31.270194	1	t
85	2.35.14	Add sequentialcounter procedure	SQL	2.35/V2_35_14__Add_sequentialcounter_procedure.sql	708322845	dhis	2024-10-21 15:44:31.270194	3	t
86	2.35.15	Add last x days relative periods	SQL	2.35/V2_35_15__Add_last_x_days_relative_periods.sql	-1999473993	dhis	2024-10-21 15:44:31.270194	4	t
87	2.35.16	Add description deg and indg	SQL	2.35/V2_35_16__Add_description_deg_and_indg.sql	909322188	dhis	2024-10-21 15:44:31.270194	1	t
88	2.35.17	Visualization Move Columns To Filters	JDBC	org.hisp.dhis.db.migration.v35.V2_35_17__Visualization_Move_Columns_To_Filters	\N	dhis	2024-10-21 15:44:31.270194	0	t
89	2.35.18	Add dataset openperiodsaftercoenddate	SQL	2.35/V2_35_18__Add_dataset_openperiodsaftercoenddate.sql	1212239503	dhis	2024-10-21 15:44:31.270194	1	t
90	2.35.19	Drop programinstanceaudit table	SQL	2.35/V2_35_19__Drop_programinstanceaudit_table.sql	613582783	dhis	2024-10-21 15:44:31.270194	1	t
91	2.35.20	Add uid column in sms table	SQL	2.35/V2_35_20__Add_uid_column_in_sms_table.sql	-411824369	dhis	2024-10-21 15:44:31.270194	8	t
92	2.35.21	Modify id in trackedentityattributevalueaudit to bigint	SQL	2.35/V2_35_21__Modify_id_in_trackedentityattributevalueaudit_to_bigint.sql	-1135812582	dhis	2024-10-21 15:44:31.270194	4	t
93	2.35.22	add sms authority to userauthoritygroups	JDBC	org.hisp.dhis.db.migration.v35.V2_35_22__add_sms_authority_to_userauthoritygroups	\N	dhis	2024-10-21 15:44:31.270194	0	t
94	2.36.1	normalize program rule variable names for duplicates	JDBC	org.hisp.dhis.db.migration.v36.V2_36_1__normalize_program_rule_variable_names_for_duplicates	\N	dhis	2024-10-21 15:44:31.270194	1	t
95	2.36.2	normalize program rule names for duplicates	JDBC	org.hisp.dhis.db.migration.v36.V2_36_2__normalize_program_rule_names_for_duplicates	\N	dhis	2024-10-21 15:44:31.270194	0	t
96	2.36.3	Add index for ou column on tei table	SQL	2.36/V2_36_3__Add_index_for_ou_column_on_tei_table.sql	-1430094831	dhis	2024-10-21 15:44:31.270194	1	t
97	2.36.4	Remove duplicate mappings from categoryoption to usergroups	JDBC	org.hisp.dhis.db.migration.v36.V2_36_4__Remove_duplicate_mappings_from_categoryoption_to_usergroups	\N	dhis	2024-10-21 15:44:31.270194	1	t
98	2.36.5	add template snapshot to program instance and remove fk	SQL	2.36/V2_36_5__add_template_snapshot_to_program_instance_and_remove_fk.sql	1578491962	dhis	2024-10-21 15:44:31.270194	3	t
99	2.36.6	Remove duplicate mappings from programstage to usergroups	JDBC	org.hisp.dhis.db.migration.v36.V2_36_6__Remove_duplicate_mappings_from_programstage_to_usergroups	\N	dhis	2024-10-21 15:44:31.270194	3	t
100	2.36.7	Add translations column into programruleaction table	SQL	2.36/V2_36_7__Add_translations_column_into_programruleaction_table.sql	-118790982	dhis	2024-10-21 15:44:31.270194	0	t
101	2.36.8	Add column object sharing	SQL	2.36/V2_36_8__Add_column_object_sharing.sql	-1388244525	dhis	2024-10-21 15:44:31.270194	27	t
102	2.36.9	Add custom jsonb functions for sharing	SQL	2.36/V2_36_9__Add_custom_jsonb_functions_for_sharing.sql	-1039846318	dhis	2024-10-21 15:44:31.270194	2	t
103	2.36.11	Migrate sharings to jsonb	JDBC	org.hisp.dhis.db.migration.v36.V2_36_11__Migrate_sharings_to_jsonb	\N	dhis	2024-10-21 15:44:31.270194	12	t
104	2.36.12	Add createdbyuserInfo lastupdatedbyuserinfo to ProgramStageInstance	SQL	2.36/V2_36_12__Add_createdbyuserInfo_lastupdatedbyuserinfo_to_ProgramStageInstance.sql	579880304	dhis	2024-10-21 15:44:31.270194	1	t
105	2.36.13	Add invitetoken and remove restorecode from users table	SQL	2.36/V2_36_13__Add_invitetoken_and_remove_restorecode_from_users_table.sql	322679304	dhis	2024-10-21 15:44:31.270194	1	t
106	2.36.14	Add programtempowner table	SQL	2.36/V2_36_14__Add_programtempowner_table.sql	1012506162	dhis	2024-10-21 15:44:31.270194	10	t
107	2.36.15	Remove skip zeros in analytics system setting	SQL	2.36/V2_36_15__Remove_skip_zeros_in_analytics_system_setting.sql	779697167	dhis	2024-10-21 15:44:31.270194	0	t
108	2.36.17	Remove referenced relationships from soft deleted events and enrollments	SQL	2.36/V2_36_17__Remove_referenced_relationships_from_soft_deleted_events_and_enrollments.sql	-453095978	dhis	2024-10-21 15:44:31.270194	1	t
109	2.36.19	Add outlier analysis column	SQL	2.36/V2_36_19__Add_outlier_analysis_column.sql	872124205	dhis	2024-10-21 15:44:31.270194	0	t
110	2.36.20	Drop legacy sharing tables	SQL	2.36/V2_36_20__Drop_legacy_sharing_tables.sql	-66347989	dhis	2024-10-21 15:44:31.270194	150	t
111	2.36.21	Add column account expiry into user credentials	SQL	2.36/V2_36_21__Add_column_account_expiry_into_user_credentials.sql	-1324085981	dhis	2024-10-21 15:44:31.270194	1	t
112	2.36.22	Add ComplexValueType jsonb column to data element	SQL	2.36/V2_36_22__Add_ComplexValueType_jsonb_column_to_data_element.sql	727752413	dhis	2024-10-21 15:44:31.270194	1	t
113	2.36.23	Add dashboard filterdimensions column	SQL	2.36/V2_36_23__Add_dashboard_filterdimensions_column.sql	-2059647539	dhis	2024-10-21 15:44:31.270194	4	t
114	2.36.24	Add data sharing to sqlview	JDBC	org.hisp.dhis.db.migration.v36.V2_36_24__Add_data_sharing_to_sqlview	\N	dhis	2024-10-21 15:44:31.270194	0	t
115	2.36.25	Add translation to program rule variable	SQL	2.36/V2_36_25__Add_translation_to_program_rule_variable.sql	642650539	dhis	2024-10-21 15:44:31.270194	1	t
116	2.36.26	Add column shortName	SQL	2.36/V2_36_26__Add_column_shortName.sql	409313924	dhis	2024-10-21 15:44:31.270194	2	t
117	2.36.27	Add unique shortName	JDBC	org.hisp.dhis.db.migration.v36.V2_36_27__Add_unique_shortName	\N	dhis	2024-10-21 15:44:31.270194	1	t
118	2.36.28	Add unique and not null to shortName	SQL	2.36/V2_36_28__Add_unique_and_not_null_to_shortName.sql	2081255715	dhis	2024-10-21 15:44:31.270194	9	t
119	2.36.29	Add indexes in relationshipitem and programinstance tables	SQL	2.36/V2_36_29__Add_indexes_in_relationshipitem_and_programinstance_tables.sql	1202153676	dhis	2024-10-21 15:44:31.270194	6	t
120	2.36.30	Add passivedashboardviews column to datastatistics table	SQL	2.36/V2_36_30__Add_passivedashboardviews_column_to_datastatistics_table.sql	-844989920	dhis	2024-10-21 15:44:31.270194	0	t
121	2.36.31	Add programid index in programintance table	SQL	2.36/V2_36_31__Add_programid_index_in_programintance_table.sql	2079795987	dhis	2024-10-21 15:44:31.270194	4	t
122	2.36.32	Add notificationtemplate column to programmessage table	SQL	2.36/V2_36_32__Add_notificationtemplate_column_to_programmessage_table.sql	-536283922	dhis	2024-10-21 15:44:31.270194	1	t
123	2.36.33	Add translations column to trackedEntityInstanceFilter table	SQL	2.36/V2_36_33__Add_translations_column_to_trackedEntityInstanceFilter_table.sql	152797532	dhis	2024-10-21 15:44:31.270194	1	t
124	2.37.1	Add Deferred Constraint to Interpretation Comments Table	SQL	2.37/V2_37_1__Add_Deferred_Constraint_to_Interpretation_Comments_Table.sql	360122688	dhis	2024-10-21 15:44:31.270194	2	t
125	2.37.2	Add index in tracker tables	SQL	2.37/V2_37_2__Add_index_in_tracker_tables.sql	-632008147	dhis	2024-10-21 15:44:31.270194	12	t
126	2.37.3	Update VISUALIZATION VIEW in datastatisticsevent table	SQL	2.37/V2_37_3__Update_VISUALIZATION_VIEW_in_datastatisticsevent_table.sql	-1588074185	dhis	2024-10-21 15:44:31.270194	0	t
127	2.37.4	Update ou path index	SQL	2.37/V2_37_4__Update_ou_path_index.sql	-1252262601	dhis	2024-10-21 15:44:31.270194	2	t
128	2.37.5	Add sendrepeatable column	SQL	2.37/V2_37_5__Add_sendrepeatable_column.sql	102006350	dhis	2024-10-21 15:44:31.270194	3	t
129	2.37.6	Clean trackedentitytypeattribute null foreign keys	SQL	2.37/V2_37_6__Clean_trackedentitytypeattribute_null_foreign_keys.sql	-1039541605	dhis	2024-10-21 15:44:31.270194	1	t
130	2.37.7	Fix negative sort orders in visualization rows columns	SQL	2.37/V2_37_7__Fix_negative_sort_orders_in_visualization_rows_columns.sql	1504013881	dhis	2024-10-21 15:44:31.270194	0	t
131	2.37.8	Add translations column into externalmaplayer table	SQL	2.37/V2_37_8__Add_translations_column_into_externalmaplayer_table.sql	-1415477344	dhis	2024-10-21 15:44:31.270194	0	t
132	2.37.9	Add last10years column into relativeperiods table	SQL	2.37/V2_37_9__Add_last10years_column_into_relativeperiods_table.sql	724938640	dhis	2024-10-21 15:44:31.270194	1	t
133	2.37.10	Add createdbyuserInfo lastupdatedbyuserinfo to ProgramInstance and TrackedEntityInstance	SQL	2.37/V2_37_10__Add_createdbyuserInfo_lastupdatedbyuserinfo_to_ProgramInstance_and_TrackedEntityInstance.sql	1261700433	dhis	2024-10-21 15:44:31.270194	2	t
134	2.37.11	Add last10financialyears column into relativeperiods table	SQL	2.37/V2_37_11__Add_last10financialyears_column_into_relativeperiods_table.sql	1282517200	dhis	2024-10-21 15:44:31.270194	1	t
135	2.37.12	Add translations column into notification template tables	SQL	2.37/V2_37_12__Add_translations_column_into_notification_template_tables.sql	-1659359413	dhis	2024-10-21 15:44:31.270194	2	t
136	2.37.13	Update programstageinstance status visited to active	SQL	2.37/V2_37_13__Update_programstageinstance_status_visited_to_active.sql	-973792171	dhis	2024-10-21 15:44:31.270194	0	t
137	2.37.14	Add image column into organisationunit table	SQL	2.37/V2_37_14__Add_image_column_into_organisationunit_table.sql	-984761768	dhis	2024-10-21 15:44:31.270194	4	t
138	2.37.15	Delete REMOVE EXPIRED RESERVED VALUES Job	SQL	2.37/V2_37_15__Delete_REMOVE_EXPIRED_RESERVED_VALUES_Job.sql	1254233743	dhis	2024-10-21 15:44:31.270194	1	t
139	2.37.16	Add REPLICA IDENTITY on tables without primary key	SQL	2.37/V2_37_16__Add_REPLICA_IDENTITY_on_tables_without_primary_key.sql	1441434802	dhis	2024-10-21 15:44:31.270194	6	t
140	2.37.17	Remove Chart and ReportTable	SQL	2.37/V2_37_17__Remove_Chart_and_ReportTable.sql	172668348	dhis	2024-10-21 15:44:31.270194	30	t
141	2.37.19	Migrate DataApproval id column to long	SQL	2.37/V2_37_19__Migrate_DataApproval_id_column_to_long.sql	-1365726151	dhis	2024-10-21 15:44:31.270194	7	t
142	2.37.22	Add ApiToken Table	SQL	2.37/V2_37_22__Add_ApiToken_Table.sql	1145880603	dhis	2024-10-21 15:44:31.270194	6	t
143	2.37.23	Add Potential Duplicate Flag To Tei	SQL	2.37/V2_37_23__Add_Potential_Duplicate_Flag_To_Tei.sql	851086003	dhis	2024-10-21 15:44:31.270194	1	t
144	2.37.24	Potential Duplicate Not Null teiB	SQL	2.37/V2_37_24__Potential_Duplicate_Not_Null_teiB.sql	-1024904053	dhis	2024-10-21 15:44:31.270194	1	t
145	2.37.25	Add disableDataElementAutoGroup column to section	SQL	2.37/V2_37_25__Add_disableDataElementAutoGroup_column_to_section.sql	-1436505888	dhis	2024-10-21 15:44:31.270194	1	t
146	2.37.26	Add Fix Columns in Visualization	SQL	2.37/V2_37_26__Add_Fix_Columns_in_Visualization.sql	-1774834607	dhis	2024-10-21 15:44:31.270194	3	t
147	2.37.27	Add ou move auth for roles with add auth	SQL	2.37/V2_37_27__Add_ou_move_auth_for_roles_with_add_auth.sql	1494537377	dhis	2024-10-21 15:44:31.270194	0	t
148	2.37.28	Add Layout And ItemConfig Columns Dashboard	SQL	2.37/V2_37_28__Add_Layout_And_ItemConfig_Columns_Dashboard.sql	605594794	dhis	2024-10-21 15:44:31.270194	1	t
149	2.37.29	Add translations column expression table	SQL	2.37/V2_37_29__Add_translations_column_expression_table.sql	1650968076	dhis	2024-10-21 15:44:31.270194	1	t
150	2.37.30	Add translations column predictor table	SQL	2.37/V2_37_30__Add_translations_column_predictor_table.sql	-1914085880	dhis	2024-10-21 15:44:31.270194	0	t
151	2.37.31	drop legacy translation table	SQL	2.37/V2_37_31__drop_legacy_translation_table.sql	1797982545	dhis	2024-10-21 15:44:31.270194	3	t
152	2.37.32	Add mapview organisationunitcolor	SQL	2.37/V2_37_32__Add_mapview_organisationunitcolor.sql	294320773	dhis	2024-10-21 15:44:31.270194	2	t
153	2.37.33	Add facility org unit group set level	SQL	2.37/V2_37_33__Add_facility_org_unit_group_set_level.sql	1604493704	dhis	2024-10-21 15:44:31.270194	6	t
154	2.37.34	Add programstagedataelement skipanalytics	SQL	2.37/V2_37_34__Add_programstagedataelement_skipanalytics.sql	133661822	dhis	2024-10-21 15:44:31.270194	2	t
155	2.37.35	Update Potential Duplicate	SQL	2.37/V2_37_35__Update_Potential_Duplicate.sql	-401039672	dhis	2024-10-21 15:44:31.270194	5	t
156	2.37.36	Add userinfo dataviewmaxorganisationunitlevel	SQL	2.37/V2_37_36__Add_userinfo_dataviewmaxorganisationunitlevel.sql	410522857	dhis	2024-10-21 15:44:31.270194	2	t
157	2.38.1	Add column shortName to group sets	SQL	2.38/V2_38_1__Add_column_shortName_to_group_sets.sql	-1387216343	dhis	2024-10-21 15:44:31.270194	1	t
158	2.38.2	Add unique shortName to group sets	JDBC	org.hisp.dhis.db.migration.v38.V2_38_2__Add_unique_shortName_to_group_sets	\N	dhis	2024-10-21 15:44:31.270194	0	t
159	2.38.3	Add unique and not null to group sets shortName	SQL	2.38/V2_38_3__Add_unique_and_not_null_to_group_sets_shortName.sql	1426970789	dhis	2024-10-21 15:44:31.270194	7	t
160	2.38.4	add columns for last updated to data approval	SQL	2.38/V2_38_4__add_columns_for_last_updated_to_data_approval.sql	1475655259	dhis	2024-10-21 15:44:31.270194	3	t
161	2.38.5	Add indexes to tei and psi table to improve tei querying	SQL	2.38/V2_38_5__Add_indexes_to_tei_and_psi_table_to_improve_tei_querying.sql	-1111194101	dhis	2024-10-21 15:44:31.270194	3	t
162	2.38.6	Add attributes for analytical objects	SQL	2.38/V2_38_6__Add_attributes_for_analytical_objects.sql	-607674042	dhis	2024-10-21 15:44:31.270194	9	t
163	2.38.7	Add metadata proposals	SQL	2.38/V2_38_7__Add_metadata_proposals.sql	-259450861	dhis	2024-10-21 15:44:31.270194	8	t
164	2.38.8	Remove legacy attributevalues tables	SQL	2.38/V2_38_8__Remove_legacy_attributevalues_tables.sql	-64391883	dhis	2024-10-21 15:44:31.270194	72	t
165	2.38.9	Add aggregated keys for relationships	SQL	2.38/V2_38_9__Add_aggregated_keys_for_relationships.sql	1315182340	dhis	2024-10-21 15:44:31.270194	10	t
166	2.38.10	Remove unused visualization columns and table	SQL	2.38/V2_38_10__Remove_unused_visualization_columns_and_table.sql	927205008	dhis	2024-10-21 15:44:31.270194	2	t
167	2.38.11	Add Event Visualization Tables	SQL	2.38/V2_38_11__Add_Event_Visualization_Tables.sql	-1580409640	dhis	2024-10-21 15:44:31.270194	62	t
168	2.38.12	Migrate Data Into Event Visualization Tables	SQL	2.38/V2_38_12__Migrate_Data_Into_Event_Visualization_Tables.sql	709144537	dhis	2024-10-21 15:44:31.270194	23	t
169	2.38.14	Add program opendaysaftercoenddate	SQL	2.38/V2_38_14__Add_program_opendaysaftercoenddate.sql	1388772325	dhis	2024-10-21 15:44:31.270194	1	t
170	2.38.15	Add index trackedentityprogramowner program orgunit	SQL	2.38/V2_38_15__Add_index_trackedentityprogramowner_program_orgunit.sql	-1387268405	dhis	2024-10-21 15:44:31.270194	1	t
171	2.38.16	Add includedescendantorgunits to predictor	SQL	2.38/V2_38_16__Add_includedescendantorgunits_to_predictor.sql	366407674	dhis	2024-10-21 15:44:31.270194	1	t
172	2.38.17	Add notnull constraint for sqlview type and cachestrategy	SQL	2.38/V2_38_17__Add_notnull_constraint_for_sqlview_type_and_cachestrategy.sql	1657855816	dhis	2024-10-21 15:44:31.270194	2	t
173	2.38.18	Add simpleDimension column into eventVisualization	SQL	2.38/V2_38_18__Add_simpleDimension_column_into_eventVisualization.sql	-881726168	dhis	2024-10-21 15:44:31.270194	1	t
174	2.38.19	Add ValueType column into programrulevariable	SQL	2.38/V2_38_19__Add_ValueType_column_into_programrulevariable.sql	1964969230	dhis	2024-10-21 15:44:31.270194	3	t
175	2.38.20	Script to rename column programid in programstageusergroupaccesses moved to 2 36 6 and this script updates constraint in programstageinstance	SQL	2.38/V2_38_20__Script_to_rename_column_programid_in_programstageusergroupaccesses_moved_to_2_36_6_and_this_script_updates_constraint_in_programstageinstance.sql	-531235053	dhis	2024-10-21 15:44:31.270194	2	t
176	2.38.21	Add eventRepetition column into eventVisualization	SQL	2.38/V2_38_21__Add_eventRepetition_column_into_eventVisualization.sql	-1283959480	dhis	2024-10-21 15:44:31.270194	0	t
177	2.38.22	Remove mistake of duplicated FK in visualization organisationunits	SQL	2.38/V2_38_22__Remove_mistake_of_duplicated_FK_in_visualization_organisationunits.sql	-1920368903	dhis	2024-10-21 15:44:31.270194	1	t
178	2.38.24	Set ProgramStage NotNull	SQL	2.38/V2_38_24__Set_ProgramStage_NotNull.sql	-391546467	dhis	2024-10-21 15:44:31.270194	1	t
179	2.38.25	Add messageId messageConversation	SQL	2.38/V2_38_25__Add_messageId_messageConversation.sql	61180192	dhis	2024-10-21 15:44:31.270194	1	t
180	2.38.26	Add Feedback recipients to configuration	SQL	2.38/V2_38_26__Add_Feedback_recipients_to_configuration.sql	829440205	dhis	2024-10-21 15:44:31.270194	3	t
181	2.38.27	Add sharing column to trackedentityinstancefilter	SQL	2.38/V2_38_27__Add_sharing_column_to_trackedentityinstancefilter.sql	180461158	dhis	2024-10-21 15:44:31.270194	1	t
182	2.38.28	add column to relationshipconstraint table	SQL	2.38/V2_38_28__add_column_to_relationshipconstraint_table.sql	-1687584821	dhis	2024-10-21 15:44:31.270194	25	t
183	2.38.31	Add createdby userid column to trackedentityinstancefilter	SQL	2.38/V2_38_31__Add_createdby_userid_column_to_trackedentityinstancefilter.sql	1978277139	dhis	2024-10-21 15:44:31.270194	2	t
184	2.38.32	Add new user role for analytics explain endpoint	JDBC	org.hisp.dhis.db.migration.v38.V2_38_32__Add_new_user_role_for_analytics_explain_endpoint	\N	dhis	2024-10-21 15:44:31.270194	1	t
185	2.38.33	Drop Legacy Constraints EventReport EventChart	SQL	2.38/V2_38_33__Drop_Legacy_Constraints_EventReport_EventChart.sql	197751156	dhis	2024-10-21 15:44:31.270194	31	t
186	2.38.34	Migrate users to userinfo	SQL	2.38/V2_38_34__Migrate_users_to_userinfo.sql	-1002422487	dhis	2024-10-21 15:44:31.270194	46	t
187	2.38.35	Migrate user to userinfo	JDBC	org.hisp.dhis.db.migration.v38.V2_38_35__Migrate_user_to_userinfo	\N	dhis	2024-10-21 15:44:31.270194	1	t
188	2.38.36	Drop users table	SQL	2.38/V2_38_36__Drop_users_table.sql	1589664013	dhis	2024-10-21 15:44:31.270194	12	t
189	2.38.37	Add entityquerycriteria column to trackedentityinstancefilter	JDBC	org.hisp.dhis.db.migration.v38.V2_38_37__Add_entityquerycriteria_column_to_trackedentityinstancefilter	\N	dhis	2024-10-21 15:44:31.270194	2	t
190	2.38.38	Updates Sms Config	SQL	2.38/V2_38_38__Updates_Sms_Config.sql	1358863470	dhis	2024-10-21 15:44:31.270194	1	t
191	2.38.39	Add organisationUnitCoordinateField column to mapView table	SQL	2.38/V2_38_39__Add_organisationUnitCoordinateField_column_to_mapView_table.sql	452220890	dhis	2024-10-21 15:44:31.270194	1	t
192	2.38.41	Add coc fk in smscode	SQL	2.38/V2_38_41__Add_coc_fk_in_smscode.sql	482752321	dhis	2024-10-21 15:44:31.270194	5	t
193	2.39.1	Add index to reserved value	SQL	2.39/V2_39_1__Add_index_to_reserved_value.sql	937741164	dhis	2024-10-21 15:44:31.270194	2	t
194	2.39.2	Add jsonb columns into visualization table fix	SQL	2.39/V2_39_2__Add_jsonb_columns_into_visualization_table_fix.sql	584602855	dhis	2024-10-21 15:44:31.270194	5	t
195	2.39.3	New Columns in Visualization	SQL	2.39/V2_39_3__New_Columns_in_Visualization.sql	-189516872	dhis	2024-10-21 15:44:31.270194	6	t
196	2.39.4	Rename Column in Visualization	SQL	2.39/V2_39_4__Rename_Column_in_Visualization.sql	762438058	dhis	2024-10-21 15:44:31.270194	2	t
197	2.39.5	Add column shortName to predictor table	SQL	2.39/V2_39_5__Add_column_shortName_to_predictor_table.sql	812742577	dhis	2024-10-21 15:44:31.270194	1	t
198	2.39.6	Add unique shortName to predictors	JDBC	org.hisp.dhis.db.migration.v39.V2_39_6__Add_unique_shortName_to_predictors	\N	dhis	2024-10-21 15:44:31.270194	0	t
199	2.39.7	Add unique and not null to predictor shortName	SQL	2.39/V2_39_7__Add_unique_and_not_null_to_predictor_shortName.sql	-763416647	dhis	2024-10-21 15:44:31.270194	2	t
200	2.39.8	Add soft delete feature relationship	SQL	2.39/V2_39_8__Add_soft_delete_feature_relationship.sql	1063079188	dhis	2024-10-21 15:44:31.270194	8	t
201	2.39.9	Add column attributevalues to relationshiptype	SQL	2.39/V2_39_9__Add_column_attributevalues_to_relationshiptype.sql	1479901531	dhis	2024-10-21 15:44:31.270194	1	t
202	2.39.10	Update programstageid in relationshipconstraint	SQL	2.39/V2_39_10__Update_programstageid_in_relationshipconstraint.sql	675482031	dhis	2024-10-21 15:44:31.270194	1	t
203	2.39.11	Add LegendSet Column Into EV	SQL	2.39/V2_39_11__Add_LegendSet_Column_Into_EV.sql	-1690774397	dhis	2024-10-21 15:44:31.270194	5	t
204	2.39.13	Potential Duplicate Update ALL Status	SQL	2.39/V2_39_13__Potential_Duplicate_Update_ALL_Status.sql	1579009756	dhis	2024-10-21 15:44:31.270194	1	t
205	2.39.14	Add referral column to relationshiptype	SQL	2.39/V2_39_14__Add_referral_column_to_relationshiptype.sql	285112607	dhis	2024-10-21 15:44:31.270194	2	t
206	2.39.15	Add owner Column Info fileresource table	SQL	2.39/V2_39_15__Add_owner_Column_Info_fileresource_table.sql	-2019617456	dhis	2024-10-21 15:44:31.270194	0	t
207	2.39.16	Add referral parameter to program stage	SQL	2.39/V2_39_16__Add_referral_parameter_to_program_stage.sql	-1564279552	dhis	2024-10-21 15:44:31.270194	3	t
208	2.39.17	Add missing programinstance rows for programs without registration	JDBC	org.hisp.dhis.db.migration.v39.V2_39_17__Add_missing_programinstance_rows_for_programs_without_registration	\N	dhis	2024-10-21 15:44:31.270194	0	t
209	2.39.18	add aggregatedataexchange table	SQL	2.39/V2_39_18__add_aggregatedataexchange_table.sql	1325481296	dhis	2024-10-21 15:44:31.270194	10	t
210	2.39.19	update column dataview in relationshipconstraint table	SQL	2.39/V2_39_19__update_column_dataview_in_relationshipconstraint_table.sql	1337733960	dhis	2024-10-21 15:44:31.270194	7	t
211	2.39.21	Add description optiongroup	SQL	2.39/V2_39_21__Add_description_optiongroup.sql	848939189	dhis	2024-10-21 15:44:31.270194	1	t
212	2.39.22	Update Fileresource fileresourceowner	SQL	2.39/V2_39_22__Update_Fileresource_fileresourceowner.sql	861472802	dhis	2024-10-21 15:44:31.270194	1	t
213	2.39.23	Add description column to category option	SQL	2.39/V2_39_23__Add_description_column_to_category_option.sql	-1310434734	dhis	2024-10-21 15:44:31.270194	1	t
214	2.39.24	Add index in table datasetsource	SQL	2.39/V2_39_24__Add_index_in_table_datasetsource.sql	853197400	dhis	2024-10-21 15:44:31.270194	3	t
215	2.39.25	Update job configuration job parameters	SQL	2.39/V2_39_25__Update_job_configuration_job_parameters.sql	1494635687	dhis	2024-10-21 15:44:31.270194	3	t
216	2.39.26	Add skip rounding to eventvisualization	SQL	2.39/V2_39_26__Add_skip_rounding_to_eventvisualization.sql	1405318974	dhis	2024-10-21 15:44:31.270194	1	t
217	2.39.27	Add sorting to eventvisualization.sql	SQL	2.39/V2_39_27__Add_sorting_to_eventvisualization.sql.sql	1975740290	dhis	2024-10-21 15:44:31.270194	1	t
218	2.39.28	Fix Audit Type Case Sensitive.sql	SQL	2.39/V2_39_28__Fix_Audit_Type_Case_Sensitive.sql.sql	-1608842935	dhis	2024-10-21 15:44:31.270194	5	t
219	2.39.29	Alter trackedentity inactive not null	SQL	2.39/V2_39_29__Alter_trackedentity_inactive_not_null.sql	-1422289360	dhis	2024-10-21 15:44:31.270194	1	t
\.


--
-- Data for Name: i18nlocale; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.i18nlocale (i18nlocaleid, uid, code, created, lastupdated, lastupdatedby, name, locale) FROM stdin;
27	VmAlqO0VERN	\N	2024-10-21 15:44:56.985	2024-10-21 15:44:56.985	\N	Afrikaans	af
28	afBnjlaqw07	\N	2024-10-21 15:44:56.986	2024-10-21 15:44:56.986	\N	Arabic	ar
29	kWBb1zIX0nU	\N	2024-10-21 15:44:56.986	2024-10-21 15:44:56.986	\N	Bislama	bi
30	hTGDr7Dvwnn	\N	2024-10-21 15:44:56.986	2024-10-21 15:44:56.986	\N	Amharic	am
31	G5sTcZBXaJ4	\N	2024-10-21 15:44:56.987	2024-10-21 15:44:56.987	\N	German	de
32	WY6XCofuPHR	\N	2024-10-21 15:44:56.987	2024-10-21 15:44:56.987	\N	Dzongkha	dz
33	MhdUzwTTF5Y	\N	2024-10-21 15:44:56.988	2024-10-21 15:44:56.988	\N	English	en
34	w3oIey2MBYo	\N	2024-10-21 15:44:56.988	2024-10-21 15:44:56.988	\N	Spanish	es
35	xTnvGn2ZgKe	\N	2024-10-21 15:44:56.988	2024-10-21 15:44:56.988	\N	Persian	fa
36	jtFGESBpCwF	\N	2024-10-21 15:44:56.988	2024-10-21 15:44:56.988	\N	French	fr
37	lGXLTWCCOjC	\N	2024-10-21 15:44:56.989	2024-10-21 15:44:56.989	\N	Gujarati	gu
38	eif6ciEoUjT	\N	2024-10-21 15:44:56.989	2024-10-21 15:44:56.989	\N	Hindi	hi
39	rfj3Y2KKOpU	\N	2024-10-21 15:44:56.989	2024-10-21 15:44:56.989	\N	Indonesian	in
40	QAxY2J0MR4z	\N	2024-10-21 15:44:56.99	2024-10-21 15:44:56.99	\N	Italian	it
41	QV6Dp3l5q7L	\N	2024-10-21 15:44:56.99	2024-10-21 15:44:56.99	\N	Khmer	km
42	l677QlctCjf	\N	2024-10-21 15:44:56.99	2024-10-21 15:44:56.99	\N	Lao	lo
43	kNJDdlu5ZDn	\N	2024-10-21 15:44:56.991	2024-10-21 15:44:56.991	\N	Burmese	my
44	bDTo0DSp6gN	\N	2024-10-21 15:44:56.991	2024-10-21 15:44:56.991	\N	Nepali	ne
45	A1eSTX7a5z8	\N	2024-10-21 15:44:56.992	2024-10-21 15:44:56.992	\N	Dutch	nl
46	u8cODNSPLa4	\N	2024-10-21 15:44:56.992	2024-10-21 15:44:56.992	\N	Norwegian	no
47	LXQ8OfBRzvk	\N	2024-10-21 15:44:56.993	2024-10-21 15:44:56.993	\N	Pashto	ps
48	P18HdOlyW8H	\N	2024-10-21 15:44:56.993	2024-10-21 15:44:56.993	\N	Portuguese	pt
49	FMRW2EZZ5ex	\N	2024-10-21 15:44:56.993	2024-10-21 15:44:56.994	\N	Russian	ru
50	ZFoO9GJOPEP	\N	2024-10-21 15:44:56.994	2024-10-21 15:44:56.994	\N	Kinyarwanda	rw
51	ytYKlYWFeOs	\N	2024-10-21 15:44:56.994	2024-10-21 15:44:56.994	\N	Swahili	sw
52	vbzNT0M9H5C	\N	2024-10-21 15:44:56.994	2024-10-21 15:44:56.994	\N	Tajik	tg
53	ChAaTvo5G4H	\N	2024-10-21 15:44:56.995	2024-10-21 15:44:56.995	\N	Vietnamese	vi
54	HuyM2zTOXaZ	\N	2024-10-21 15:44:56.995	2024-10-21 15:44:56.995	\N	Chinese	zh
\.


--
-- Data for Name: incomingsms; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.incomingsms (id, originator, encoding, sentdate, receiveddate, text, gatewayid, status, parsed, statusmessage, userid, uid) FROM stdin;
\.


--
-- Data for Name: indicator; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.indicator (indicatorid, uid, code, created, lastupdated, lastupdatedby, name, shortname, description, formname, annualized, decimals, indicatortypeid, numerator, numeratordescription, denominator, denominatordescription, url, style, aggregateexportcategoryoptioncombo, aggregateexportattributeoptioncombo, userid, publicaccess, translations, attributevalues, sharing) FROM stdin;
\.


--
-- Data for Name: indicatorgroup; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.indicatorgroup (indicatorgroupid, uid, code, created, lastupdated, lastupdatedby, name, userid, publicaccess, translations, attributevalues, description, sharing) FROM stdin;
\.


--
-- Data for Name: indicatorgroupmembers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.indicatorgroupmembers (indicatorid, indicatorgroupid) FROM stdin;
\.


--
-- Data for Name: indicatorgroupset; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.indicatorgroupset (indicatorgroupsetid, uid, code, created, lastupdated, lastupdatedby, name, description, compulsory, userid, publicaccess, translations, sharing, shortname) FROM stdin;
\.


--
-- Data for Name: indicatorgroupsetmembers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.indicatorgroupsetmembers (indicatorgroupid, indicatorgroupsetid, sort_order) FROM stdin;
\.


--
-- Data for Name: indicatorlegendsets; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.indicatorlegendsets (indicatorid, sort_order, legendsetid) FROM stdin;
\.


--
-- Data for Name: indicatortype; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.indicatortype (indicatortypeid, uid, code, created, lastupdated, lastupdatedby, name, indicatorfactor, indicatornumber, translations) FROM stdin;
\.


--
-- Data for Name: intepretation_likedby; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.intepretation_likedby (interpretationid, userid) FROM stdin;
\.


--
-- Data for Name: interpretation; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.interpretation (interpretationid, uid, lastupdated, mapid, eventreportid, eventchartid, datasetid, periodid, organisationunitid, interpretationtext, created, likes, userid, publicaccess, mentions, visualizationid, sharing, eventvisualizationid) FROM stdin;
\.


--
-- Data for Name: interpretation_comments; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.interpretation_comments (interpretationid, sort_order, interpretationcommentid) FROM stdin;
\.


--
-- Data for Name: interpretationcomment; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.interpretationcomment (interpretationcommentid, uid, lastupdated, commenttext, mentions, userid, created) FROM stdin;
\.


--
-- Data for Name: jobconfiguration; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.jobconfiguration (jobconfigurationid, uid, code, created, lastupdated, lastupdatedby, name, cronexpression, lastexecuted, lastruntimeexecution, nextexecutiontime, enabled, leaderonlyjob, jsonbjobparameters, jobtype, jobstatus, lastexecutedstatus, delay) FROM stdin;
55	pd6O228pqr0	\N	2024-10-21 15:44:57.009	2024-10-21 15:44:57.009	\N	File resource clean up	0 0 2 ? * *	\N	\N	\N	t	f	\N	FILE_RESOURCE_CLEANUP	SCHEDULED	NOT_STARTED	\N
56	BFa3jDsbtdO	\N	2024-10-21 15:44:57.041	2024-10-21 15:44:57.041	\N	Data statistics	0 0 2 ? * *	\N	\N	\N	t	f	\N	DATA_STATISTICS	SCHEDULED	NOT_STARTED	\N
57	Js3vHn2AVuG	\N	2024-10-21 15:44:57.053	2024-10-21 15:44:57.053	\N	Validation result notification	0 0 7 ? * *	\N	\N	\N	t	f	\N	VALIDATION_RESULTS_NOTIFICATION	SCHEDULED	NOT_STARTED	\N
58	sHMedQF7VYa	\N	2024-10-21 15:44:57.062	2024-10-21 15:44:57.062	\N	Credentials expiry alert	0 0 2 ? * *	\N	\N	\N	t	f	\N	CREDENTIALS_EXPIRY_ALERT	SCHEDULED	NOT_STARTED	\N
59	fUWM1At1TUx	\N	2024-10-21 15:44:57.071	2024-10-21 15:44:57.071	\N	User account expiry alert	0 0 2 ? * *	\N	\N	\N	t	f	\N	ACCOUNT_EXPIRY_ALERT	SCHEDULED	NOT_STARTED	\N
60	YvAwAmrqAtN	\N	2024-10-21 15:44:57.082	2024-10-21 15:44:57.082	\N	Dataset notification	0 0 2 ? * *	\N	\N	\N	t	f	\N	DATA_SET_NOTIFICATION	SCHEDULED	NOT_STARTED	\N
61	uwWCT2BMmlq	\N	2024-10-21 15:44:57.091	2024-10-21 15:44:57.091	\N	Remove expired or used reserved values	0 0 2 ? * *	\N	\N	\N	t	f	\N	REMOVE_USED_OR_EXPIRED_RESERVED_VALUES	SCHEDULED	NOT_STARTED	\N
62	vt21671bgno	\N	2024-10-21 15:44:57.101	2024-10-21 15:44:57.101	\N	System version update check notification	8 27 3 ? * *	\N	\N	\N	t	f	\N	SYSTEM_VERSION_UPDATE_CHECK	SCHEDULED	NOT_STARTED	\N
\.


--
-- Data for Name: keyjsonvalue; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.keyjsonvalue (keyjsonvalueid, uid, code, created, lastupdated, lastupdatedby, namespace, namespacekey, encrypted_value, encrypted, userid, publicaccess, jbvalue, sharing) FROM stdin;
\.


--
-- Data for Name: lockexception; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.lockexception (lockexceptionid, organisationunitid, periodid, datasetid) FROM stdin;
\.


--
-- Data for Name: map; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.map (mapid, uid, code, created, lastupdated, lastupdatedby, name, description, longitude, latitude, zoom, basemap, title, externalaccess, userid, publicaccess, favorites, subscribers, translations, sharing, attributevalues) FROM stdin;
\.


--
-- Data for Name: maplegend; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.maplegend (maplegendid, uid, code, created, lastupdated, lastupdatedby, name, startvalue, endvalue, color, image, maplegendsetid, translations) FROM stdin;
\.


--
-- Data for Name: maplegendset; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.maplegendset (maplegendsetid, uid, code, created, lastupdated, lastupdatedby, name, symbolizer, userid, publicaccess, translations, attributevalues, sharing) FROM stdin;
\.


--
-- Data for Name: mapmapviews; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.mapmapviews (mapid, sort_order, mapviewid) FROM stdin;
\.


--
-- Data for Name: mapview; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.mapview (mapviewid, uid, code, created, lastupdated, lastupdatedby, description, layer, relativeperiodsid, userorganisationunit, userorganisationunitchildren, userorganisationunitgrandchildren, aggregationtype, programid, programstageid, startdate, enddate, trackedentitytypeid, programstatus, followup, organisationunitselectionmode, method, classes, colorlow, colorhigh, colorscale, legendsetid, radiuslow, radiushigh, opacity, orgunitgroupsetid, arearadius, hidden, labels, labelfontsize, labelfontweight, labelfontstyle, labelfontcolor, eventclustering, eventcoordinatefield, eventpointcolor, eventpointradius, config, styledataitem, translations, renderingstrategy, userorgunittype, thematicmaptype, nodatacolor, eventstatus, organisationunitcolor, orgunitfield) FROM stdin;
\.


--
-- Data for Name: mapview_attributedimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.mapview_attributedimensions (mapviewid, sort_order, trackedentityattributedimensionid) FROM stdin;
\.


--
-- Data for Name: mapview_categorydimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.mapview_categorydimensions (mapviewid, categorydimensionid, sort_order) FROM stdin;
\.


--
-- Data for Name: mapview_categoryoptiongroupsetdimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.mapview_categoryoptiongroupsetdimensions (mapviewid, sort_order, categoryoptiongroupsetdimensionid) FROM stdin;
\.


--
-- Data for Name: mapview_columns; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.mapview_columns (mapviewid, sort_order, dimension) FROM stdin;
\.


--
-- Data for Name: mapview_datadimensionitems; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.mapview_datadimensionitems (mapviewid, sort_order, datadimensionitemid) FROM stdin;
\.


--
-- Data for Name: mapview_dataelementdimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.mapview_dataelementdimensions (mapviewid, sort_order, trackedentitydataelementdimensionid) FROM stdin;
\.


--
-- Data for Name: mapview_filters; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.mapview_filters (mapviewid, dimension, sort_order) FROM stdin;
\.


--
-- Data for Name: mapview_itemorgunitgroups; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.mapview_itemorgunitgroups (mapviewid, sort_order, orgunitgroupid) FROM stdin;
\.


--
-- Data for Name: mapview_organisationunits; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.mapview_organisationunits (mapviewid, sort_order, organisationunitid) FROM stdin;
\.


--
-- Data for Name: mapview_orgunitgroupsetdimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.mapview_orgunitgroupsetdimensions (mapviewid, sort_order, orgunitgroupsetdimensionid) FROM stdin;
\.


--
-- Data for Name: mapview_orgunitlevels; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.mapview_orgunitlevels (mapviewid, sort_order, orgunitlevel) FROM stdin;
\.


--
-- Data for Name: mapview_periods; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.mapview_periods (mapviewid, sort_order, periodid) FROM stdin;
\.


--
-- Data for Name: message; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.message (messageid, uid, created, lastupdated, messagetext, internal, metadata, userid) FROM stdin;
\.


--
-- Data for Name: messageattachments; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.messageattachments (messageid, fileresourceid) FROM stdin;
\.


--
-- Data for Name: messageconversation; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.messageconversation (messageconversationid, uid, messagecount, created, lastupdated, subject, messagetype, priority, status, user_assigned, lastsenderid, lastmessage, userid, extmessageid) FROM stdin;
\.


--
-- Data for Name: messageconversation_messages; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.messageconversation_messages (messageconversationid, sort_order, messageid) FROM stdin;
\.


--
-- Data for Name: messageconversation_usermessages; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.messageconversation_usermessages (messageconversationid, usermessageid) FROM stdin;
\.


--
-- Data for Name: metadataproposal; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.metadataproposal (proposalid, uid, type, status, target, targetuid, created, createdby, change, comment, reason, finalised, finalisedby) FROM stdin;
\.


--
-- Data for Name: metadataversion; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.metadataversion (versionid, uid, code, created, lastupdated, lastupdatedby, name, versiontype, importdate, hashcode) FROM stdin;
\.


--
-- Data for Name: minmaxdataelement; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.minmaxdataelement (minmaxdataelementid, sourceid, dataelementid, categoryoptioncomboid, minimumvalue, maximumvalue, generatedvalue) FROM stdin;
\.


--
-- Data for Name: oauth2client; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.oauth2client (oauth2clientid, uid, code, created, lastupdated, lastupdatedby, name, cid, secret) FROM stdin;
\.


--
-- Data for Name: oauth2clientgranttypes; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.oauth2clientgranttypes (oauth2clientid, sort_order, granttype) FROM stdin;
\.


--
-- Data for Name: oauth2clientredirecturis; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.oauth2clientredirecturis (oauth2clientid, sort_order, redirecturi) FROM stdin;
\.


--
-- Data for Name: oauth_access_token; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.oauth_access_token (token_id, token, authentication_id, user_name, client_id, authentication, refresh_token) FROM stdin;
\.


--
-- Data for Name: oauth_code; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.oauth_code (code, authentication) FROM stdin;
\.


--
-- Data for Name: oauth_refresh_token; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.oauth_refresh_token (token_id, token, authentication) FROM stdin;
\.


--
-- Data for Name: optiongroup; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.optiongroup (optiongroupid, uid, code, created, lastupdated, lastupdatedby, name, shortname, optionsetid, userid, publicaccess, translations, sharing, description) FROM stdin;
\.


--
-- Data for Name: optiongroupmembers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.optiongroupmembers (optiongroupid, optionid) FROM stdin;
\.


--
-- Data for Name: optiongroupset; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.optiongroupset (optiongroupsetid, uid, code, created, lastupdated, lastupdatedby, name, description, datadimension, optionsetid, userid, publicaccess, translations, sharing) FROM stdin;
\.


--
-- Data for Name: optiongroupsetmembers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.optiongroupsetmembers (optiongroupsetid, sort_order, optiongroupid) FROM stdin;
\.


--
-- Data for Name: optionset; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.optionset (optionsetid, uid, code, created, lastupdated, lastupdatedby, name, valuetype, version, userid, publicaccess, translations, attributevalues, sharing) FROM stdin;
\.


--
-- Data for Name: optionvalue; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.optionvalue (optionvalueid, uid, code, name, created, lastupdated, sort_order, description, formname, style, optionsetid, translations, attributevalues) FROM stdin;
\.


--
-- Data for Name: organisationunit; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.organisationunit (organisationunitid, uid, code, created, lastupdated, lastupdatedby, name, shortname, parentid, path, hierarchylevel, description, openingdate, closeddate, comment, url, contactperson, address, email, phonenumber, userid, translations, geometry, attributevalues, image) FROM stdin;
65	pq1gwdmhIqT	\N	2024-10-21 15:46:00.049	2024-10-21 15:46:00.187	1	Mozambique	Mozambique	\N	/pq1gwdmhIqT	1	\N	2023-12-31	\N	\N	\N	\N	\N	\N	\N	1	[]	\N	{}	\N
67	tXcc1uJBvu1	P001	2024-10-21 15:46:21.062	2024-10-21 15:46:21.153	1	Depósito Provincial Niassa	Depósito Provincial Niassa	65	/pq1gwdmhIqT/tXcc1uJBvu1	2	\N	2023-12-31	\N	\N	\N	\N	\N	\N	\N	1	[]	\N	{}	\N
68	buhtSZIesYb	D001	2024-10-21 15:46:35.883	2024-10-21 15:46:35.912	1	Depósito Distrital Cuamba	Depósito Distrital Cuamba	65	/pq1gwdmhIqT/buhtSZIesYb	2	\N	2023-12-31	\N	\N	\N	\N	\N	\N	\N	1	[]	\N	{}	\N
69	fQaFu9muM2s	D002	2024-10-21 15:46:53.286	2024-10-21 15:46:53.316	1	Depósito Distrital Lichinga	Depósito Distrital Lichinga	65	/pq1gwdmhIqT/fQaFu9muM2s	2	\N	2023-12-31	\N	\N	\N	\N	\N	\N	\N	1	[]	\N	{}	\N
\.


--
-- Data for Name: orgunitgroup; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.orgunitgroup (orgunitgroupid, uid, code, created, lastupdated, lastupdatedby, name, shortname, symbol, color, userid, publicaccess, translations, geometry, attributevalues, sharing) FROM stdin;
\.


--
-- Data for Name: orgunitgroupmembers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.orgunitgroupmembers (organisationunitid, orgunitgroupid) FROM stdin;
\.


--
-- Data for Name: orgunitgroupset; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.orgunitgroupset (orgunitgroupsetid, uid, code, created, lastupdated, lastupdatedby, name, description, compulsory, includesubhierarchyinanalytics, datadimension, userid, publicaccess, translations, attributevalues, sharing, shortname) FROM stdin;
\.


--
-- Data for Name: orgunitgroupsetdimension; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.orgunitgroupsetdimension (orgunitgroupsetdimensionid, orgunitgroupsetid) FROM stdin;
\.


--
-- Data for Name: orgunitgroupsetdimension_items; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.orgunitgroupsetdimension_items (orgunitgroupsetdimensionid, sort_order, orgunitgroupid) FROM stdin;
\.


--
-- Data for Name: orgunitgroupsetmembers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.orgunitgroupsetmembers (orgunitgroupsetid, orgunitgroupid) FROM stdin;
\.


--
-- Data for Name: orgunitlevel; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.orgunitlevel (orgunitlevelid, uid, code, created, lastupdated, lastupdatedby, name, level, offlinelevels, translations) FROM stdin;
\.


--
-- Data for Name: outbound_sms; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.outbound_sms (id, date, message, status, sender, uid) FROM stdin;
\.


--
-- Data for Name: outbound_sms_recipients; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.outbound_sms_recipients (outbound_sms_id, elt) FROM stdin;
\.


--
-- Data for Name: period; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.period (periodid, periodtypeid, startdate, enddate) FROM stdin;
80	10	2024-01-01	2024-01-31
\.


--
-- Data for Name: periodboundary; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.periodboundary (periodboundaryid, uid, code, created, lastupdated, lastupdatedby, boundarytarget, analyticsperiodboundarytype, offsetperiods, offsetperiodtypeid, programindicatorid) FROM stdin;
\.


--
-- Data for Name: periodtype; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.periodtype (periodtypeid, name) FROM stdin;
3	Daily
4	Weekly
5	WeeklyWednesday
6	WeeklyThursday
7	WeeklySaturday
8	WeeklySunday
9	BiWeekly
10	Monthly
11	BiMonthly
12	Quarterly
13	QuarterlyNov
14	SixMonthly
15	SixMonthlyApril
16	SixMonthlyNov
17	Yearly
18	FinancialApril
19	FinancialJuly
20	FinancialOct
21	FinancialNov
\.


--
-- Data for Name: potentialduplicate; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.potentialduplicate (potentialduplicateid, uid, created, lastupdated, teia, teib, status, createdbyusername, lastupdatebyusername) FROM stdin;
\.


--
-- Data for Name: predictor; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.predictor (predictorid, uid, code, created, lastupdated, lastupdatedby, name, description, generatorexpressionid, generatoroutput, generatoroutputcombo, skiptestexpressionid, periodtypeid, sequentialsamplecount, annualsamplecount, sequentialskipcount, translations, organisationunitdescendants, shortname) FROM stdin;
\.


--
-- Data for Name: predictorgroup; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.predictorgroup (predictorgroupid, uid, code, created, lastupdated, lastupdatedby, name, description, userid, publicaccess, translations, sharing) FROM stdin;
\.


--
-- Data for Name: predictorgroupmembers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.predictorgroupmembers (predictorid, predictorgroupid) FROM stdin;
\.


--
-- Data for Name: predictororgunitlevels; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.predictororgunitlevels (predictorid, orgunitlevelid) FROM stdin;
\.


--
-- Data for Name: previouspasswords; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.previouspasswords (userid, list_index, previouspassword) FROM stdin;
1	0	$2a$10$24YHRJhuK.6vqTYAnp3XX.6xXhQDZIDOzRPp45GDX.DZaVJRy5Ysy
\.


--
-- Data for Name: program; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.program (programid, uid, code, created, lastupdated, lastupdatedby, name, shortname, description, formname, version, enrollmentdatelabel, incidentdatelabel, type, displayincidentdate, onlyenrollonce, skipoffline, displayfrontpagelist, usefirststageduringregistration, capturecoordinates, expirydays, completeeventsexpirydays, minattributesrequiredtosearch, maxteicounttoreturn, style, accesslevel, expiryperiodtypeid, ignoreoverdueevents, selectenrollmentdatesinfuture, selectincidentdatesinfuture, relatedprogramid, categorycomboid, trackedentitytypeid, dataentryformid, userid, publicaccess, featuretype, translations, attributevalues, sharing, opendaysaftercoenddate) FROM stdin;
\.


--
-- Data for Name: program_attribute_group; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.program_attribute_group (programtrackedentityattributegroupid, uid, code, created, lastupdated, lastupdatedby, name, shortname, description, uniqunessype, translations) FROM stdin;
\.


--
-- Data for Name: program_attributes; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.program_attributes (programtrackedentityattributeid, uid, code, created, lastupdated, lastupdatedby, programid, trackedentityattributeid, displayinlist, mandatory, sort_order, allowfuturedate, renderoptionsasradio, rendertype, searchable) FROM stdin;
\.


--
-- Data for Name: program_organisationunits; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.program_organisationunits (organisationunitid, programid) FROM stdin;
\.


--
-- Data for Name: program_userroles; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.program_userroles (programid, userroleid) FROM stdin;
\.


--
-- Data for Name: programexpression; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programexpression (programexpressionid, description, expression) FROM stdin;
\.


--
-- Data for Name: programindicator; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programindicator (programindicatorid, uid, code, created, lastupdated, lastupdatedby, name, shortname, description, formname, style, programid, expression, filter, aggregationtype, decimals, aggregateexportcategoryoptioncombo, aggregateexportattributeoptioncombo, displayinform, analyticstype, userid, publicaccess, translations, attributevalues, sharing) FROM stdin;
\.


--
-- Data for Name: programindicatorgroup; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programindicatorgroup (programindicatorgroupid, uid, code, created, lastupdated, lastupdatedby, name, description, userid, publicaccess, translations, sharing) FROM stdin;
\.


--
-- Data for Name: programindicatorgroupmembers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programindicatorgroupmembers (programindicatorid, programindicatorgroupid) FROM stdin;
\.


--
-- Data for Name: programindicatorlegendsets; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programindicatorlegendsets (programindicatorid, sort_order, legendsetid) FROM stdin;
\.


--
-- Data for Name: programinstance; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programinstance (programinstanceid, uid, created, lastupdated, createdatclient, lastupdatedatclient, incidentdate, enrollmentdate, enddate, followup, completedby, deleted, storedby, status, trackedentityinstanceid, programid, organisationunitid, geometry, createdbyuserinfo, lastupdatedbyuserinfo) FROM stdin;
\.


--
-- Data for Name: programinstance_messageconversation; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programinstance_messageconversation (programinstanceid, sort_order, messageconversationid) FROM stdin;
\.


--
-- Data for Name: programinstancecomments; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programinstancecomments (programinstanceid, sort_order, trackedentitycommentid) FROM stdin;
\.


--
-- Data for Name: programmessage; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programmessage (id, uid, code, created, lastupdated, lastupdatedby, text, subject, processeddate, messagestatus, trackedentityinstanceid, organisationunitid, programinstanceid, programstageinstanceid, translations, notificationtemplate) FROM stdin;
\.


--
-- Data for Name: programmessage_deliverychannels; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programmessage_deliverychannels (programmessagedeliverychannelsid, deliverychannel) FROM stdin;
\.


--
-- Data for Name: programmessage_emailaddresses; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programmessage_emailaddresses (programmessageemailaddressid, email) FROM stdin;
\.


--
-- Data for Name: programmessage_phonenumbers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programmessage_phonenumbers (programmessagephonenumberid, phonenumber) FROM stdin;
\.


--
-- Data for Name: programnotificationinstance; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programnotificationinstance (programnotificationinstanceid, uid, code, created, lastupdated, lastupdatedby, name, programinstanceid, programstageinstanceid, programnotificationtemplateid, scheduledat, sentat, programnotificationtemplatesnapshot) FROM stdin;
\.


--
-- Data for Name: programnotificationtemplate; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programnotificationtemplate (programnotificationtemplateid, uid, code, created, lastupdated, lastupdatedby, name, relativescheduleddays, usergroupid, trackedentityattributeid, dataelementid, subjecttemplate, messagetemplate, notifyparentorganisationunitonly, notifyusersinhierarchyonly, notificationtrigger, notificationrecipienttype, programstageid, programid, sendrepeatable, translations) FROM stdin;
\.


--
-- Data for Name: programnotificationtemplate_deliverychannel; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programnotificationtemplate_deliverychannel (programnotificationtemplatedeliverychannelid, deliverychannel) FROM stdin;
\.


--
-- Data for Name: programownershiphistory; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programownershiphistory (programownershiphistoryid, programid, trackedentityinstanceid, startdate, enddate, createdby, organisationunitid) FROM stdin;
\.


--
-- Data for Name: programrule; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programrule (programruleid, uid, code, created, lastupdated, lastupdatedby, name, description, programid, programstageid, rulecondition, priority, translations) FROM stdin;
\.


--
-- Data for Name: programruleaction; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programruleaction (programruleactionid, uid, code, created, lastupdated, lastupdatedby, programruleid, actiontype, dataelementid, trackedentityattributeid, programindicatorid, programstagesectionid, programstageid, optionid, optiongroupid, location, content, data, templateuid, evaluationtime, environments, translations) FROM stdin;
\.


--
-- Data for Name: programrulevariable; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programrulevariable (programrulevariableid, uid, code, created, lastupdated, lastupdatedby, name, programid, sourcetype, trackedentityattributeid, dataelementid, usecodeforoptionset, programstageid, translations, valuetype) FROM stdin;
\.


--
-- Data for Name: programsection; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programsection (programsectionid, uid, code, created, lastupdated, lastupdatedby, name, description, formname, style, rendertype, programid, sortorder, translations) FROM stdin;
\.


--
-- Data for Name: programsection_attributes; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programsection_attributes (programsectionid, sort_order, trackedentityattributeid) FROM stdin;
\.


--
-- Data for Name: programstage; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programstage (programstageid, uid, code, created, lastupdated, lastupdatedby, name, description, formname, mindaysfromstart, programid, repeatable, dataentryformid, standardinterval, executiondatelabel, duedatelabel, autogenerateevent, displaygenerateeventbox, generatedbyenrollmentdate, blockentryform, remindcompleted, allowgeneratenextvisit, openafterenrollment, reportdatetouse, pregenerateuid, style, hideduedate, sort_order, featuretype, periodtypeid, userid, publicaccess, validationstrategy, translations, enableuserassignment, attributevalues, nextscheduledateid, sharing, referral) FROM stdin;
\.


--
-- Data for Name: programstagedataelement; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programstagedataelement (programstagedataelementid, uid, code, created, lastupdated, lastupdatedby, programstageid, dataelementid, compulsory, allowprovidedelsewhere, sort_order, displayinreports, allowfuturedate, renderoptionsasradio, rendertype, skipsynchronization, skipanalytics) FROM stdin;
\.


--
-- Data for Name: programstageinstance; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programstageinstance (programstageinstanceid, uid, code, created, lastupdated, createdatclient, lastupdatedatclient, lastsynchronized, programinstanceid, programstageid, attributeoptioncomboid, deleted, storedby, duedate, executiondate, organisationunitid, status, completedby, completeddate, geometry, eventdatavalues, assigneduserid, createdbyuserinfo, lastupdatedbyuserinfo) FROM stdin;
\.


--
-- Data for Name: programstageinstance_messageconversation; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programstageinstance_messageconversation (programstageinstanceid, sort_order, messageconversationid) FROM stdin;
\.


--
-- Data for Name: programstageinstancecomments; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programstageinstancecomments (programstageinstanceid, sort_order, trackedentitycommentid) FROM stdin;
\.


--
-- Data for Name: programstageinstancefilter; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programstageinstancefilter (programstageinstancefilterid, uid, created, lastupdated, lastupdatedby, name, description, program, programstage, eventquerycriteria, userid, publicaccess, sharing, translations) FROM stdin;
\.


--
-- Data for Name: programstagesection; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programstagesection (programstagesectionid, uid, code, created, lastupdated, lastupdatedby, name, description, formname, style, rendertype, programstageid, sortorder, translations) FROM stdin;
\.


--
-- Data for Name: programstagesection_dataelements; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programstagesection_dataelements (programstagesectionid, sort_order, dataelementid) FROM stdin;
\.


--
-- Data for Name: programstagesection_programindicators; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programstagesection_programindicators (programstagesectionid, sort_order, programindicatorid) FROM stdin;
\.


--
-- Data for Name: programtempowner; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programtempowner (programtempownerid, programid, trackedentityinstanceid, validtill, userid, reason) FROM stdin;
\.


--
-- Data for Name: programtempownershipaudit; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programtempownershipaudit (programtempownershipauditid, programid, trackedentityinstanceid, created, accessedby, reason) FROM stdin;
\.


--
-- Data for Name: programtrackedentityattributegroupmembers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.programtrackedentityattributegroupmembers (programtrackedentityattributeid, programtrackedentityattributegroupid) FROM stdin;
\.


--
-- Data for Name: pushanalysis; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.pushanalysis (pushanalysisid, uid, code, created, lastupdated, lastupdatedby, name, title, message, enabled, schedulingdayoffrequency, schedulingfrequency, dashboard) FROM stdin;
\.


--
-- Data for Name: pushanalysisrecipientusergroups; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.pushanalysisrecipientusergroups (usergroupid, elt) FROM stdin;
\.


--
-- Data for Name: relationship; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.relationship (relationshipid, uid, code, created, lastupdated, lastupdatedby, style, relationshiptypeid, from_relationshipitemid, to_relationshipitemid, key, inverted_key, deleted) FROM stdin;
\.


--
-- Data for Name: relationshipconstraint; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.relationshipconstraint (relationshipconstraintid, entity, trackedentitytypeid, programid, programstageid, dataview) FROM stdin;
\.


--
-- Data for Name: relationshipitem; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.relationshipitem (relationshipitemid, relationshipid, trackedentityinstanceid, programinstanceid, programstageinstanceid) FROM stdin;
\.


--
-- Data for Name: relationshiptype; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.relationshiptype (relationshiptypeid, uid, code, created, lastupdated, lastupdatedby, name, description, from_relationshipconstraintid, to_relationshipconstraintid, userid, publicaccess, translations, bidirectional, fromtoname, tofromname, sharing, attributevalues, referral) FROM stdin;
\.


--
-- Data for Name: relativeperiods; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.relativeperiods (relativeperiodsid, thisday, yesterday, last3days, last7days, last14days, thismonth, lastmonth, thisbimonth, lastbimonth, thisquarter, lastquarter, thissixmonth, lastsixmonth, weeksthisyear, monthsthisyear, bimonthsthisyear, quartersthisyear, thisyear, monthslastyear, quarterslastyear, lastyear, last5years, last12months, last6months, last3months, last6bimonths, last4quarters, last2sixmonths, thisfinancialyear, lastfinancialyear, last5financialyears, thisweek, lastweek, thisbiweek, lastbiweek, last4weeks, last4biweeks, last12weeks, last52weeks, last30days, last60days, last90days, last180days, last10years, last10financialyears) FROM stdin;
\.


--
-- Data for Name: report; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.report (reportid, uid, code, created, lastupdated, lastupdatedby, name, type, designcontent, relativeperiodsid, paramreportingmonth, paramorganisationunit, cachestrategy, externalaccess, userid, publicaccess, translations, visualizationid, sharing) FROM stdin;
\.


--
-- Data for Name: reservedvalue; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.reservedvalue (reservedvalueid, expirydate, created, ownerobject, owneruid, key, value) FROM stdin;
\.


--
-- Data for Name: section; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.section (sectionid, uid, code, created, lastupdated, lastupdatedby, name, description, datasetid, sortorder, showrowtotals, showcolumntotals, translations, attributevalues, disabledataelementautogroup) FROM stdin;
\.


--
-- Data for Name: sectiondataelements; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.sectiondataelements (sectionid, sort_order, dataelementid) FROM stdin;
\.


--
-- Data for Name: sectiongreyedfields; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.sectiongreyedfields (sectionid, dataelementoperandid) FROM stdin;
\.


--
-- Data for Name: sectionindicators; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.sectionindicators (sectionid, sort_order, indicatorid) FROM stdin;
\.


--
-- Data for Name: sequentialnumbercounter; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.sequentialnumbercounter (id, owneruid, key, counter) FROM stdin;
\.


--
-- Data for Name: series; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.series (seriesid, series, axis) FROM stdin;
\.


--
-- Data for Name: smscodes; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.smscodes (smscodeid, code, formula, compulsory, dataelementid, trackedentityattributeid, optionid) FROM stdin;
\.


--
-- Data for Name: smscommandcodes; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.smscommandcodes (id, codeid) FROM stdin;
\.


--
-- Data for Name: smscommands; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.smscommands (smscommandid, uid, created, lastupdated, name, parsertype, separatorkey, codeseparator, defaultmessage, receivedmessage, wrongformatmessage, nousermessage, morethanoneorgunitmessage, successmessage, currentperiodusedforreporting, completenessmethod, datasetid, usergroupid, programid, programstageid) FROM stdin;
\.


--
-- Data for Name: smscommandspecialcharacters; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.smscommandspecialcharacters (smscommandid, specialcharacterid) FROM stdin;
\.


--
-- Data for Name: smsspecialcharacter; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.smsspecialcharacter (specialcharacterid, name, value) FROM stdin;
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: sqlview; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.sqlview (sqlviewid, uid, code, created, lastupdated, lastupdatedby, name, description, sqlquery, type, cachestrategy, externalaccess, userid, publicaccess, attributevalues, sharing) FROM stdin;
\.


--
-- Data for Name: systemsetting; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.systemsetting (systemsettingid, name, value, translations) FROM stdin;
\.


--
-- Data for Name: tablehook; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.tablehook (analyticstablehookid, uid, code, created, lastupdated, lastupdatedby, name, analyticstablephase, resourcetabletype, analyticstabletype, sql) FROM stdin;
\.


--
-- Data for Name: trackedentityattribute; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.trackedentityattribute (trackedentityattributeid, uid, code, created, lastupdated, lastupdatedby, name, shortname, description, formname, valuetype, aggregationtype, optionsetid, inherit, expression, displayonvisitschedule, sortorderinvisitschedule, displayinlistnoprogram, sortorderinlistnoprogram, confidential, uniquefield, generated, pattern, textpattern, style, orgunitscope, skipsynchronization, userid, publicaccess, fieldmask, translations, attributevalues, sharing) FROM stdin;
\.


--
-- Data for Name: trackedentityattributedimension; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.trackedentityattributedimension (trackedentityattributedimensionid, trackedentityattributeid, legendsetid, filter) FROM stdin;
\.


--
-- Data for Name: trackedentityattributelegendsets; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.trackedentityattributelegendsets (trackedentityattributeid, sort_order, legendsetid) FROM stdin;
\.


--
-- Data for Name: trackedentityattributevalue; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.trackedentityattributevalue (trackedentityinstanceid, trackedentityattributeid, created, lastupdated, value, encryptedvalue, storedby) FROM stdin;
\.


--
-- Data for Name: trackedentityattributevalueaudit; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.trackedentityattributevalueaudit (trackedentityattributevalueauditid, trackedentityinstanceid, trackedentityattributeid, value, encryptedvalue, created, modifiedby, audittype) FROM stdin;
\.


--
-- Data for Name: trackedentitycomment; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.trackedentitycomment (trackedentitycommentid, uid, code, created, lastupdated, lastupdatedby, commenttext, creator) FROM stdin;
\.


--
-- Data for Name: trackedentitydataelementdimension; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.trackedentitydataelementdimension (trackedentitydataelementdimensionid, dataelementid, legendsetid, filter, programstageid) FROM stdin;
\.


--
-- Data for Name: trackedentitydatavalueaudit; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.trackedentitydatavalueaudit (trackedentitydatavalueauditid, programstageinstanceid, dataelementid, value, created, providedelsewhere, modifiedby, audittype) FROM stdin;
\.


--
-- Data for Name: trackedentityinstance; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.trackedentityinstance (trackedentityinstanceid, uid, code, created, lastupdated, lastupdatedby, createdatclient, lastupdatedatclient, inactive, deleted, lastsynchronized, featuretype, coordinates, organisationunitid, trackedentitytypeid, geometry, storedby, createdbyuserinfo, lastupdatedbyuserinfo, potentialduplicate) FROM stdin;
\.


--
-- Data for Name: trackedentityinstanceaudit; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.trackedentityinstanceaudit (trackedentityinstanceauditid, trackedentityinstance, created, accessedby, audittype, comment) FROM stdin;
\.


--
-- Data for Name: trackedentityinstancefilter; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.trackedentityinstancefilter (trackedentityinstancefilterid, uid, code, created, lastupdated, lastupdatedby, name, description, sortorder, style, programid, eventfilters, translations, sharing, userid, entityquerycriteria) FROM stdin;
\.


--
-- Data for Name: trackedentityprogramindicatordimension; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.trackedentityprogramindicatordimension (trackedentityprogramindicatordimensionid, programindicatorid, legendsetid, filter) FROM stdin;
\.


--
-- Data for Name: trackedentityprogramowner; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.trackedentityprogramowner (trackedentityprogramownerid, trackedentityinstanceid, programid, created, lastupdated, organisationunitid, createdby) FROM stdin;
\.


--
-- Data for Name: trackedentitytype; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.trackedentitytype (trackedentitytypeid, uid, code, created, lastupdated, lastupdatedby, name, description, formname, style, minattributesrequiredtosearch, maxteicounttoreturn, allowauditlog, userid, publicaccess, featuretype, translations, attributevalues, sharing) FROM stdin;
\.


--
-- Data for Name: trackedentitytypeattribute; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.trackedentitytypeattribute (trackedentitytypeattributeid, uid, code, created, lastupdated, lastupdatedby, trackedentitytypeid, trackedentityattributeid, displayinlist, mandatory, searchable, sort_order) FROM stdin;
\.


--
-- Data for Name: userapps; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.userapps (userinfoid, sort_order, app) FROM stdin;
\.


--
-- Data for Name: userdatavieworgunits; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.userdatavieworgunits (userinfoid, organisationunitid) FROM stdin;
1	65
\.


--
-- Data for Name: usergroup; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.usergroup (usergroupid, uid, code, created, lastupdated, lastupdatedby, name, userid, publicaccess, translations, attributevalues, uuid, sharing) FROM stdin;
\.


--
-- Data for Name: usergroupmanaged; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.usergroupmanaged (managedbygroupid, managedgroupid) FROM stdin;
\.


--
-- Data for Name: usergroupmembers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.usergroupmembers (userid, usergroupid) FROM stdin;
\.


--
-- Data for Name: userinfo; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.userinfo (userinfoid, uid, code, lastupdated, created, surname, firstname, email, phonenumber, jobtitle, introduction, gender, birthday, nationality, employer, education, interests, languages, welcomemessage, lastcheckedinterpretations, whatsapp, skype, facebookmessenger, telegram, twitter, avatar, attributevalues, dataviewmaxorgunitlevel, lastupdatedby, creatoruserid, username, password, secret, twofa, externalauth, openid, ldapid, passwordlastupdated, lastlogin, restoretoken, restoreexpiry, selfregistered, invitation, disabled, uuid, accountexpiry, idtoken) FROM stdin;
1	M5zQapPyTZI	admin	2024-10-21 15:47:50.649	2024-10-21 15:44:56.573	admin	admin	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{}	\N	1	1	admin	$2a$10$24YHRJhuK.6vqTYAnp3XX.6xXhQDZIDOzRPp45GDX.DZaVJRy5Ysy	\N	f	f	\N	\N	2024-10-21 15:44:56.64	2024-10-21 15:45:05.463	\N	\N	f	f	f	6507f586-f154-4ec1-a25e-d7aa51de5216	\N	\N
\.


--
-- Data for Name: userkeyjsonvalue; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.userkeyjsonvalue (userkeyjsonvalueid, uid, code, created, lastupdated, lastupdatedby, userid, namespace, userkey, encrypted_value, encrypted, jbvalue) FROM stdin;
63	rrPPpycHeHM	\N	2024-10-21 15:45:06.599	2024-10-21 15:45:06.599	1	1	dashboard	controlBarRows	\N	f	1
64	T5N5OJfArbp	\N	2024-10-21 15:45:06.607	2024-10-21 15:45:06.607	1	1	dashboard	showDescription	\N	f	false
\.


--
-- Data for Name: usermembership; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.usermembership (organisationunitid, userinfoid) FROM stdin;
65	1
\.


--
-- Data for Name: usermessage; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.usermessage (usermessageid, usermessagekey, userid, isread, isfollowup) FROM stdin;
\.


--
-- Data for Name: userrole; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.userrole (userroleid, uid, code, created, lastupdated, lastupdatedby, name, description, userid, publicaccess, translations, sharing) FROM stdin;
2	yrB6vc5Ip3r	Superuser	2024-10-21 15:44:56.631	2024-10-21 15:44:56.632	\N	Superuser	Superuser	\N	\N	[]	{"users": {}, "public": "--------", "external": false, "userGroups": {}}
\.


--
-- Data for Name: userroleauthorities; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.userroleauthorities (userroleid, authority) FROM stdin;
2	ALL
2	F_CAPTURE_DATASTORE_UPDATE
2	F_VIEW_EVENT_ANALYTICS
2	F_METADATA_EXPORT
2	F_METADATA_IMPORT
2	F_EXPORT_DATA
2	F_IMPORT_DATA
2	F_EXPORT_EVENTS
2	F_IMPORT_EVENTS
2	F_SKIP_DATA_IMPORT_AUDIT
2	F_APPROVE_DATA
2	F_APPROVE_DATA_LOWER_LEVELS
2	F_ACCEPT_DATA_LOWER_LEVELS
2	F_PERFORM_MAINTENANCE
2	F_PERFORM_ANALYTICS_EXPLAIN
2	F_LOCALE_ADD
2	F_GENERATE_MIN_MAX_VALUES
2	F_RUN_VALIDATION
2	F_PREDICTOR_RUN
2	F_SEND_EMAIL
2	F_ORGANISATIONUNIT_MOVE
2	F_ORGANISATION_UNIT_SPLIT
2	F_ORGANISATION_UNIT_MERGE
2	F_INSERT_CUSTOM_JS_CSS
2	F_VIEW_UNAPPROVED_DATA
2	F_USER_VIEW
2	F_REPLICATE_USER
2	F_USERGROUP_MANAGING_RELATIONSHIPS_ADD
2	F_USERGROUP_MANAGING_RELATIONSHIPS_VIEW
2	F_USER_GROUPS_READ_ONLY_ADD_MEMBERS
2	F_PROGRAM_DASHBOARD_CONFIG_ADMIN
2	F_TRACKED_ENTITY_INSTANCE_SEARCH_IN_ALL_ORGUNITS
2	F_TEI_CASCADE_DELETE
2	F_ENROLLMENT_CASCADE_DELETE
2	F_UNCOMPLETE_EVENT
2	F_EDIT_EXPIRED
2	F_IGNORE_TRACKER_REQUIRED_VALUE_VALIDATION
2	F_TRACKER_IMPORTER_EXPERIMENTAL
2	F_VIEW_SERVER_INFO
2	F_ORG_UNIT_PROFILE_ADD
2	F_TRACKED_ENTITY_MERGE
2	F_DATAVALUE_ADD
2	F_DATAVALUE_DELETE
2	F_SYSTEM_SETTING
\.


--
-- Data for Name: userrolemembers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.userrolemembers (userroleid, userid) FROM stdin;
2	1
\.


--
-- Data for Name: users_catdimensionconstraints; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.users_catdimensionconstraints (userid, dataelementcategoryid) FROM stdin;
\.


--
-- Data for Name: users_cogsdimensionconstraints; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.users_cogsdimensionconstraints (userid, categoryoptiongroupsetid) FROM stdin;
\.


--
-- Data for Name: usersetting; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.usersetting (userinfoid, name, value) FROM stdin;
\.


--
-- Data for Name: userteisearchorgunits; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.userteisearchorgunits (userinfoid, organisationunitid) FROM stdin;
1	65
\.


--
-- Data for Name: validationnotificationtemplate; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.validationnotificationtemplate (validationnotificationtemplateid, uid, code, created, lastupdated, lastupdatedby, name, subjecttemplate, messagetemplate, notifyusersinhierarchyonly, sendstrategy, translations) FROM stdin;
\.


--
-- Data for Name: validationnotificationtemplate_recipientusergroups; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.validationnotificationtemplate_recipientusergroups (validationnotificationtemplateid, usergroupid) FROM stdin;
\.


--
-- Data for Name: validationnotificationtemplatevalidationrules; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.validationnotificationtemplatevalidationrules (validationnotificationtemplateid, validationruleid) FROM stdin;
\.


--
-- Data for Name: validationresult; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.validationresult (validationresultid, created, leftsidevalue, rightsidevalue, validationruleid, periodid, organisationunitid, attributeoptioncomboid, dayinperiod, notificationsent) FROM stdin;
\.


--
-- Data for Name: validationrule; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.validationrule (validationruleid, uid, code, created, lastupdated, lastupdatedby, name, description, instruction, importance, operator, leftexpressionid, rightexpressionid, skipformvalidation, periodtypeid, userid, publicaccess, translations, attributevalues, sharing) FROM stdin;
\.


--
-- Data for Name: validationrulegroup; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.validationrulegroup (validationrulegroupid, uid, code, created, lastupdated, lastupdatedby, name, description, userid, publicaccess, translations, attributevalues, sharing) FROM stdin;
\.


--
-- Data for Name: validationrulegroupmembers; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.validationrulegroupmembers (validationgroupid, validationruleid) FROM stdin;
\.


--
-- Data for Name: validationruleorganisationunitlevels; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.validationruleorganisationunitlevels (validationruleid, organisationunitlevel) FROM stdin;
\.


--
-- Data for Name: version; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.version (versionid, versionkey, versionvalue) FROM stdin;
66	organisationUnit	99bb627d-bb20-49e8-8e12-2822615ca25e
\.


--
-- Data for Name: visualization; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.visualization (visualizationid, uid, name, type, code, title, subtitle, description, created, startdate, enddate, sortorder, toplimit, userid, userorgunittype, publicaccess, displaydensity, fontsize, relativeperiodsid, digitgroupseparator, legendsetid, legenddisplaystyle, legenddisplaystrategy, aggregationtype, regressiontype, targetlinevalue, targetlinelabel, rangeaxislabel, rangeaxismaxvalue, rangeaxissteps, rangeaxisdecimals, rangeaxisminvalue, domainaxislabel, baselinevalue, baselinelabel, numbertype, measurecriteria, hideemptyrowitems, percentstackedvalues, nospacebetweencolumns, regression, externalaccess, userorganisationunit, userorganisationunitchildren, userorganisationunitgrandchildren, paramreportingperiod, paramorganisationunit, paramparentorganisationunit, paramgrandparentorganisationunit, rowtotals, coltotals, cumulative, rowsubtotals, colsubtotals, completedonly, skiprounding, showdimensionlabels, hidetitle, hidesubtitle, hidelegend, hideemptycolumns, hideemptyrows, showhierarchy, showdata, lastupdatedby, lastupdated, favorites, subscribers, translations, series, fontstyle, colorset, sharing, outlieranalysis, fixcolumnheaders, fixrowheaders, attributevalues, serieskey, axes, legendshowkey) FROM stdin;
\.


--
-- Data for Name: visualization_axis; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.visualization_axis (visualizationid, sort_order, axisid) FROM stdin;
\.


--
-- Data for Name: visualization_categorydimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.visualization_categorydimensions (visualizationid, categorydimensionid, sort_order) FROM stdin;
\.


--
-- Data for Name: visualization_categoryoptiongroupsetdimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.visualization_categoryoptiongroupsetdimensions (visualizationid, sort_order, categoryoptiongroupsetdimensionid) FROM stdin;
\.


--
-- Data for Name: visualization_columns; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.visualization_columns (visualizationid, dimension, sort_order) FROM stdin;
\.


--
-- Data for Name: visualization_datadimensionitems; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.visualization_datadimensionitems (visualizationid, datadimensionitemid, sort_order) FROM stdin;
\.


--
-- Data for Name: visualization_dataelementgroupsetdimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.visualization_dataelementgroupsetdimensions (visualizationid, sort_order, dataelementgroupsetdimensionid) FROM stdin;
\.


--
-- Data for Name: visualization_filters; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.visualization_filters (visualizationid, dimension, sort_order) FROM stdin;
\.


--
-- Data for Name: visualization_itemorgunitgroups; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.visualization_itemorgunitgroups (visualizationid, orgunitgroupid, sort_order) FROM stdin;
\.


--
-- Data for Name: visualization_organisationunits; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.visualization_organisationunits (visualizationid, organisationunitid, sort_order) FROM stdin;
\.


--
-- Data for Name: visualization_orgunitgroupsetdimensions; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.visualization_orgunitgroupsetdimensions (visualizationid, sort_order, orgunitgroupsetdimensionid) FROM stdin;
\.


--
-- Data for Name: visualization_orgunitlevels; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.visualization_orgunitlevels (visualizationid, orgunitlevel, sort_order) FROM stdin;
\.


--
-- Data for Name: visualization_periods; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.visualization_periods (visualizationid, periodid, sort_order) FROM stdin;
\.


--
-- Data for Name: visualization_rows; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.visualization_rows (visualizationid, dimension, sort_order) FROM stdin;
\.


--
-- Data for Name: visualization_yearlyseries; Type: TABLE DATA; Schema: public; Owner: dhis
--

COPY public.visualization_yearlyseries (visualizationid, sort_order, yearlyseries) FROM stdin;
\.


--
-- Name: audit_auditid_seq; Type: SEQUENCE SET; Schema: public; Owner: dhis
--

SELECT pg_catalog.setval('public.audit_auditid_seq', 1, false);


--
-- Name: datavalueaudit_sequence; Type: SEQUENCE SET; Schema: public; Owner: dhis
--

SELECT pg_catalog.setval('public.datavalueaudit_sequence', 3, true);


--
-- Name: deletedobject_sequence; Type: SEQUENCE SET; Schema: public; Owner: dhis
--

SELECT pg_catalog.setval('public.deletedobject_sequence', 1, false);


--
-- Name: hibernate_sequence; Type: SEQUENCE SET; Schema: public; Owner: dhis
--

SELECT pg_catalog.setval('public.hibernate_sequence', 80, true);


--
-- Name: message_sequence; Type: SEQUENCE SET; Schema: public; Owner: dhis
--

SELECT pg_catalog.setval('public.message_sequence', 1, false);


--
-- Name: messageconversation_sequence; Type: SEQUENCE SET; Schema: public; Owner: dhis
--

SELECT pg_catalog.setval('public.messageconversation_sequence', 1, false);


--
-- Name: potentialduplicatesequence; Type: SEQUENCE SET; Schema: public; Owner: dhis
--

SELECT pg_catalog.setval('public.potentialduplicatesequence', 1, false);


--
-- Name: programinstance_sequence; Type: SEQUENCE SET; Schema: public; Owner: dhis
--

SELECT pg_catalog.setval('public.programinstance_sequence', 1, false);


--
-- Name: programstageinstance_sequence; Type: SEQUENCE SET; Schema: public; Owner: dhis
--

SELECT pg_catalog.setval('public.programstageinstance_sequence', 1, false);


--
-- Name: reservedvalue_sequence; Type: SEQUENCE SET; Schema: public; Owner: dhis
--

SELECT pg_catalog.setval('public.reservedvalue_sequence', 1, false);


--
-- Name: trackedentitydatavalueaudit_sequence; Type: SEQUENCE SET; Schema: public; Owner: dhis
--

SELECT pg_catalog.setval('public.trackedentitydatavalueaudit_sequence', 1, false);


--
-- Name: trackedentityinstance_sequence; Type: SEQUENCE SET; Schema: public; Owner: dhis
--

SELECT pg_catalog.setval('public.trackedentityinstance_sequence', 1, false);


--
-- Name: trackedentityinstanceaudit_sequence; Type: SEQUENCE SET; Schema: public; Owner: dhis
--

SELECT pg_catalog.setval('public.trackedentityinstanceaudit_sequence', 1, false);


--
-- Name: usermessage_sequence; Type: SEQUENCE SET; Schema: public; Owner: dhis
--

SELECT pg_catalog.setval('public.usermessage_sequence', 1, false);


--
-- Name: aggregatedataexchange aggregatedataexchange_code_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.aggregatedataexchange
    ADD CONSTRAINT aggregatedataexchange_code_key UNIQUE (code);


--
-- Name: aggregatedataexchange aggregatedataexchange_name_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.aggregatedataexchange
    ADD CONSTRAINT aggregatedataexchange_name_key UNIQUE (name);


--
-- Name: aggregatedataexchange aggregatedataexchange_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.aggregatedataexchange
    ADD CONSTRAINT aggregatedataexchange_pkey PRIMARY KEY (aggregatedataexchangeid);


--
-- Name: aggregatedataexchange aggregatedataexchange_uid_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.aggregatedataexchange
    ADD CONSTRAINT aggregatedataexchange_uid_key UNIQUE (uid);


--
-- Name: api_token api_token_code_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.api_token
    ADD CONSTRAINT api_token_code_key UNIQUE (code);


--
-- Name: api_token api_token_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.api_token
    ADD CONSTRAINT api_token_pkey PRIMARY KEY (apitokenid);


--
-- Name: api_token api_token_uid_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.api_token
    ADD CONSTRAINT api_token_uid_key UNIQUE (uid);


--
-- Name: attribute attribute_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.attribute
    ADD CONSTRAINT attribute_pkey PRIMARY KEY (attributeid);


--
-- Name: attributevalue attributevalue_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.attributevalue
    ADD CONSTRAINT attributevalue_pkey PRIMARY KEY (attributevalueid);


--
-- Name: audit audit_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.audit
    ADD CONSTRAINT audit_pkey PRIMARY KEY (auditid);


--
-- Name: axis axis_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.axis
    ADD CONSTRAINT axis_pkey PRIMARY KEY (axisid);


--
-- Name: categories_categoryoptions categories_categoryoptions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categories_categoryoptions
    ADD CONSTRAINT categories_categoryoptions_pkey PRIMARY KEY (categoryid, sort_order);


--
-- Name: categorycombo categorycombo_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorycombo
    ADD CONSTRAINT categorycombo_pkey PRIMARY KEY (categorycomboid);


--
-- Name: categorycombos_categories categorycombos_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorycombos_categories
    ADD CONSTRAINT categorycombos_categories_pkey PRIMARY KEY (categorycomboid, sort_order);


--
-- Name: categorycombos_optioncombos categorycombos_optioncombos_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorycombos_optioncombos
    ADD CONSTRAINT categorycombos_optioncombos_pkey PRIMARY KEY (categoryoptioncomboid);


--
-- Name: categorydimension_items categorydimension_items_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorydimension_items
    ADD CONSTRAINT categorydimension_items_pkey PRIMARY KEY (categorydimensionid, sort_order);


--
-- Name: categorydimension categorydimension_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorydimension
    ADD CONSTRAINT categorydimension_pkey PRIMARY KEY (categorydimensionid);


--
-- Name: categoryoption_organisationunits categoryoption_organisationunits_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoption_organisationunits
    ADD CONSTRAINT categoryoption_organisationunits_pkey PRIMARY KEY (categoryoptionid, organisationunitid);


--
-- Name: categoryoptioncombo categoryoptioncombo_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptioncombo
    ADD CONSTRAINT categoryoptioncombo_pkey PRIMARY KEY (categoryoptioncomboid);


--
-- Name: categoryoptioncombos_categoryoptions categoryoptioncombos_categoryoptions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptioncombos_categoryoptions
    ADD CONSTRAINT categoryoptioncombos_categoryoptions_pkey PRIMARY KEY (categoryoptioncomboid, categoryoptionid);


--
-- Name: categoryoptiongroup categoryoptiongroup_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroup
    ADD CONSTRAINT categoryoptiongroup_pkey PRIMARY KEY (categoryoptiongroupid);


--
-- Name: categoryoptiongroupmembers categoryoptiongroupmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupmembers
    ADD CONSTRAINT categoryoptiongroupmembers_pkey PRIMARY KEY (categoryoptiongroupid, categoryoptionid);


--
-- Name: categoryoptiongroupset categoryoptiongroupset_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupset
    ADD CONSTRAINT categoryoptiongroupset_pkey PRIMARY KEY (categoryoptiongroupsetid);


--
-- Name: categoryoptiongroupset categoryoptiongroupset_unique_shortname; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupset
    ADD CONSTRAINT categoryoptiongroupset_unique_shortname UNIQUE (shortname);


--
-- Name: categoryoptiongroupsetdimension_items categoryoptiongroupsetdimension_items_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupsetdimension_items
    ADD CONSTRAINT categoryoptiongroupsetdimension_items_pkey PRIMARY KEY (categoryoptiongroupsetdimensionid, sort_order);


--
-- Name: categoryoptiongroupsetdimension categoryoptiongroupsetdimension_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupsetdimension
    ADD CONSTRAINT categoryoptiongroupsetdimension_pkey PRIMARY KEY (categoryoptiongroupsetdimensionid);


--
-- Name: categoryoptiongroupsetmembers categoryoptiongroupsetmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupsetmembers
    ADD CONSTRAINT categoryoptiongroupsetmembers_pkey PRIMARY KEY (categoryoptiongroupsetid, sort_order);


--
-- Name: completedatasetregistration completedatasetregistration_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.completedatasetregistration
    ADD CONSTRAINT completedatasetregistration_pkey PRIMARY KEY (datasetid, periodid, sourceid, attributeoptioncomboid);


--
-- Name: configuration configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT configuration_pkey PRIMARY KEY (configurationid);


--
-- Name: constant constant_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.constant
    ADD CONSTRAINT constant_pkey PRIMARY KEY (constantid);


--
-- Name: dashboard_items dashboard_items_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboard_items
    ADD CONSTRAINT dashboard_items_pkey PRIMARY KEY (dashboardid, sort_order);


--
-- Name: dashboard dashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboard
    ADD CONSTRAINT dashboard_pkey PRIMARY KEY (dashboardid);


--
-- Name: dashboarditem dashboarditem_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem
    ADD CONSTRAINT dashboarditem_pkey PRIMARY KEY (dashboarditemid);


--
-- Name: dashboarditem_reports dashboarditem_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem_reports
    ADD CONSTRAINT dashboarditem_reports_pkey PRIMARY KEY (dashboarditemid, sort_order);


--
-- Name: dashboarditem_resources dashboarditem_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem_resources
    ADD CONSTRAINT dashboarditem_resources_pkey PRIMARY KEY (dashboarditemid, sort_order);


--
-- Name: dashboarditem_users dashboarditem_users_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem_users
    ADD CONSTRAINT dashboarditem_users_pkey PRIMARY KEY (dashboarditemid, sort_order);


--
-- Name: dataapproval dataapproval_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapproval
    ADD CONSTRAINT dataapproval_pkey PRIMARY KEY (dataapprovalid);


--
-- Name: dataapproval dataapproval_unique_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapproval
    ADD CONSTRAINT dataapproval_unique_key UNIQUE (dataapprovallevelid, workflowid, periodid, organisationunitid, attributeoptioncomboid);


--
-- Name: dataapprovalaudit dataapprovalaudit_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalaudit
    ADD CONSTRAINT dataapprovalaudit_pkey PRIMARY KEY (dataapprovalauditid);


--
-- Name: dataapprovallevel dataapprovallevel_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovallevel
    ADD CONSTRAINT dataapprovallevel_pkey PRIMARY KEY (dataapprovallevelid);


--
-- Name: dataapprovalworkflow dataapprovalworkflow_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalworkflow
    ADD CONSTRAINT dataapprovalworkflow_pkey PRIMARY KEY (workflowid);


--
-- Name: dataapprovalworkflowlevels dataapprovalworkflowlevels_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalworkflowlevels
    ADD CONSTRAINT dataapprovalworkflowlevels_pkey PRIMARY KEY (workflowid, dataapprovallevelid);


--
-- Name: datadimensionitem datadimensionitem_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datadimensionitem
    ADD CONSTRAINT datadimensionitem_pkey PRIMARY KEY (datadimensionitemid);


--
-- Name: dataelement dataelement_code_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelement
    ADD CONSTRAINT dataelement_code_key UNIQUE (code);


--
-- Name: dataelement dataelement_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelement
    ADD CONSTRAINT dataelement_pkey PRIMARY KEY (dataelementid);


--
-- Name: dataelementaggregationlevels dataelementaggregationlevels_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementaggregationlevels
    ADD CONSTRAINT dataelementaggregationlevels_pkey PRIMARY KEY (dataelementid, sort_order);


--
-- Name: dataelementcategory dataelementcategory_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementcategory
    ADD CONSTRAINT dataelementcategory_pkey PRIMARY KEY (categoryid);


--
-- Name: dataelementcategory dataelementcategory_unique_shortname; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementcategory
    ADD CONSTRAINT dataelementcategory_unique_shortname UNIQUE (shortname);


--
-- Name: dataelementcategoryoption dataelementcategoryoption_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementcategoryoption
    ADD CONSTRAINT dataelementcategoryoption_pkey PRIMARY KEY (categoryoptionid);


--
-- Name: dataelementgroup dataelementgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroup
    ADD CONSTRAINT dataelementgroup_pkey PRIMARY KEY (dataelementgroupid);


--
-- Name: dataelementgroupmembers dataelementgroupmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupmembers
    ADD CONSTRAINT dataelementgroupmembers_pkey PRIMARY KEY (dataelementgroupid, dataelementid);


--
-- Name: dataelementgroupset dataelementgroupset_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupset
    ADD CONSTRAINT dataelementgroupset_pkey PRIMARY KEY (dataelementgroupsetid);


--
-- Name: dataelementgroupset dataelementgroupset_unique_shortname; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupset
    ADD CONSTRAINT dataelementgroupset_unique_shortname UNIQUE (shortname);


--
-- Name: dataelementgroupsetdimension_items dataelementgroupsetdimension_items_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupsetdimension_items
    ADD CONSTRAINT dataelementgroupsetdimension_items_pkey PRIMARY KEY (dataelementgroupsetdimensionid, sort_order);


--
-- Name: dataelementgroupsetdimension dataelementgroupsetdimension_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupsetdimension
    ADD CONSTRAINT dataelementgroupsetdimension_pkey PRIMARY KEY (dataelementgroupsetdimensionid);


--
-- Name: dataelementgroupsetmembers dataelementgroupsetmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupsetmembers
    ADD CONSTRAINT dataelementgroupsetmembers_pkey PRIMARY KEY (dataelementgroupsetid, sort_order);


--
-- Name: dataelementlegendsets dataelementlegendsets_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementlegendsets
    ADD CONSTRAINT dataelementlegendsets_pkey PRIMARY KEY (dataelementid, sort_order);


--
-- Name: dataelementoperand dataelementoperand_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementoperand
    ADD CONSTRAINT dataelementoperand_pkey PRIMARY KEY (dataelementoperandid);


--
-- Name: dataentryform dataentryform_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataentryform
    ADD CONSTRAINT dataentryform_pkey PRIMARY KEY (dataentryformid);


--
-- Name: datainputperiod datainputperiod_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datainputperiod
    ADD CONSTRAINT datainputperiod_pkey PRIMARY KEY (datainputperiodid);


--
-- Name: dataset dataset_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT dataset_pkey PRIMARY KEY (datasetid);


--
-- Name: datasetelement datasetelement_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetelement
    ADD CONSTRAINT datasetelement_pkey PRIMARY KEY (datasetelementid);


--
-- Name: datasetelement datasetelement_unique_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetelement
    ADD CONSTRAINT datasetelement_unique_key UNIQUE (datasetid, dataelementid);


--
-- Name: datasetindicators datasetindicators_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetindicators
    ADD CONSTRAINT datasetindicators_pkey PRIMARY KEY (datasetid, indicatorid);


--
-- Name: datasetlegendsets datasetlegendsets_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetlegendsets
    ADD CONSTRAINT datasetlegendsets_pkey PRIMARY KEY (datasetid, sort_order);


--
-- Name: datasetnotification_datasets datasetnotification_datasets_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetnotification_datasets
    ADD CONSTRAINT datasetnotification_datasets_pkey PRIMARY KEY (datasetnotificationtemplateid, datasetid);


--
-- Name: datasetnotificationtemplate datasetnotificationtemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetnotificationtemplate
    ADD CONSTRAINT datasetnotificationtemplate_pkey PRIMARY KEY (datasetnotificationtemplateid);


--
-- Name: datasetoperands datasetoperands_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetoperands
    ADD CONSTRAINT datasetoperands_pkey PRIMARY KEY (datasetid, dataelementoperandid);


--
-- Name: datasetsource datasetsource_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetsource
    ADD CONSTRAINT datasetsource_pkey PRIMARY KEY (datasetid, sourceid);


--
-- Name: datastatistics datastatistics_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datastatistics
    ADD CONSTRAINT datastatistics_pkey PRIMARY KEY (statisticsid);


--
-- Name: datastatisticsevent datastatisticsevent_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datastatisticsevent
    ADD CONSTRAINT datastatisticsevent_pkey PRIMARY KEY (eventid);


--
-- Name: datavalue datavalue_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datavalue
    ADD CONSTRAINT datavalue_pkey PRIMARY KEY (dataelementid, periodid, sourceid, categoryoptioncomboid, attributeoptioncomboid);


--
-- Name: datavalueaudit datavalueaudit_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datavalueaudit
    ADD CONSTRAINT datavalueaudit_pkey PRIMARY KEY (datavalueauditid);


--
-- Name: deletedobject deletedobject_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.deletedobject
    ADD CONSTRAINT deletedobject_pkey PRIMARY KEY (deletedobjectid);


--
-- Name: document document_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT document_pkey PRIMARY KEY (documentid);


--
-- Name: eventchart_attributedimensions eventchart_attributedimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart_attributedimensions
    ADD CONSTRAINT eventchart_attributedimensions_pkey PRIMARY KEY (eventchartid, sort_order);


--
-- Name: eventchart_categorydimensions eventchart_categorydimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart_categorydimensions
    ADD CONSTRAINT eventchart_categorydimensions_pkey PRIMARY KEY (eventchartid, sort_order);


--
-- Name: eventchart_categoryoptiongroupsetdimensions eventchart_categoryoptiongroupsetdimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart_categoryoptiongroupsetdimensions
    ADD CONSTRAINT eventchart_categoryoptiongroupsetdimensions_pkey PRIMARY KEY (eventchartid, sort_order);


--
-- Name: eventchart_columns eventchart_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart_columns
    ADD CONSTRAINT eventchart_columns_pkey PRIMARY KEY (eventchartid, sort_order);


--
-- Name: eventchart_dataelementdimensions eventchart_dataelementdimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart_dataelementdimensions
    ADD CONSTRAINT eventchart_dataelementdimensions_pkey PRIMARY KEY (eventchartid, sort_order);


--
-- Name: eventchart_filters eventchart_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart_filters
    ADD CONSTRAINT eventchart_filters_pkey PRIMARY KEY (eventchartid, sort_order);


--
-- Name: eventchart_itemorgunitgroups eventchart_itemorgunitgroups_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart_itemorgunitgroups
    ADD CONSTRAINT eventchart_itemorgunitgroups_pkey PRIMARY KEY (eventchartid, sort_order);


--
-- Name: eventchart_organisationunits eventchart_organisationunits_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart_organisationunits
    ADD CONSTRAINT eventchart_organisationunits_pkey PRIMARY KEY (eventchartid, sort_order);


--
-- Name: eventchart_orgunitgroupsetdimensions eventchart_orgunitgroupsetdimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart_orgunitgroupsetdimensions
    ADD CONSTRAINT eventchart_orgunitgroupsetdimensions_pkey PRIMARY KEY (eventchartid, sort_order);


--
-- Name: eventchart_orgunitlevels eventchart_orgunitlevels_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart_orgunitlevels
    ADD CONSTRAINT eventchart_orgunitlevels_pkey PRIMARY KEY (eventchartid, sort_order);


--
-- Name: eventchart_periods eventchart_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart_periods
    ADD CONSTRAINT eventchart_periods_pkey PRIMARY KEY (eventchartid, sort_order);


--
-- Name: eventchart eventchart_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart
    ADD CONSTRAINT eventchart_pkey PRIMARY KEY (eventchartid);


--
-- Name: eventchart_programindicatordimensions eventchart_programindicatordimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart_programindicatordimensions
    ADD CONSTRAINT eventchart_programindicatordimensions_pkey PRIMARY KEY (eventchartid, sort_order);


--
-- Name: eventchart_rows eventchart_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart_rows
    ADD CONSTRAINT eventchart_rows_pkey PRIMARY KEY (eventchartid, sort_order);


--
-- Name: eventreport_attributedimensions eventreport_attributedimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport_attributedimensions
    ADD CONSTRAINT eventreport_attributedimensions_pkey PRIMARY KEY (eventreportid, sort_order);


--
-- Name: eventreport_categorydimensions eventreport_categorydimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport_categorydimensions
    ADD CONSTRAINT eventreport_categorydimensions_pkey PRIMARY KEY (eventreportid, sort_order);


--
-- Name: eventreport_categoryoptiongroupsetdimensions eventreport_categoryoptiongroupsetdimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport_categoryoptiongroupsetdimensions
    ADD CONSTRAINT eventreport_categoryoptiongroupsetdimensions_pkey PRIMARY KEY (eventreportid, sort_order);


--
-- Name: eventreport_columns eventreport_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport_columns
    ADD CONSTRAINT eventreport_columns_pkey PRIMARY KEY (eventreportid, sort_order);


--
-- Name: eventreport_dataelementdimensions eventreport_dataelementdimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport_dataelementdimensions
    ADD CONSTRAINT eventreport_dataelementdimensions_pkey PRIMARY KEY (eventreportid, sort_order);


--
-- Name: eventreport_filters eventreport_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport_filters
    ADD CONSTRAINT eventreport_filters_pkey PRIMARY KEY (eventreportid, sort_order);


--
-- Name: eventreport_itemorgunitgroups eventreport_itemorgunitgroups_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport_itemorgunitgroups
    ADD CONSTRAINT eventreport_itemorgunitgroups_pkey PRIMARY KEY (eventreportid, sort_order);


--
-- Name: eventreport_organisationunits eventreport_organisationunits_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport_organisationunits
    ADD CONSTRAINT eventreport_organisationunits_pkey PRIMARY KEY (eventreportid, sort_order);


--
-- Name: eventreport_orgunitgroupsetdimensions eventreport_orgunitgroupsetdimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport_orgunitgroupsetdimensions
    ADD CONSTRAINT eventreport_orgunitgroupsetdimensions_pkey PRIMARY KEY (eventreportid, sort_order);


--
-- Name: eventreport_orgunitlevels eventreport_orgunitlevels_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport_orgunitlevels
    ADD CONSTRAINT eventreport_orgunitlevels_pkey PRIMARY KEY (eventreportid, sort_order);


--
-- Name: eventreport_periods eventreport_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport_periods
    ADD CONSTRAINT eventreport_periods_pkey PRIMARY KEY (eventreportid, sort_order);


--
-- Name: eventreport eventreport_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport
    ADD CONSTRAINT eventreport_pkey PRIMARY KEY (eventreportid);


--
-- Name: eventreport_programindicatordimensions eventreport_programindicatordimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport_programindicatordimensions
    ADD CONSTRAINT eventreport_programindicatordimensions_pkey PRIMARY KEY (eventreportid, sort_order);


--
-- Name: eventreport_rows eventreport_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport_rows
    ADD CONSTRAINT eventreport_rows_pkey PRIMARY KEY (eventreportid, sort_order);


--
-- Name: eventvisualization_attributedimensions eventvisualization_attributedimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_attributedimensions
    ADD CONSTRAINT eventvisualization_attributedimensions_pkey PRIMARY KEY (eventvisualizationid, sort_order);


--
-- Name: eventvisualization_categorydimensions eventvisualization_categorydimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_categorydimensions
    ADD CONSTRAINT eventvisualization_categorydimensions_pkey PRIMARY KEY (eventvisualizationid, sort_order);


--
-- Name: eventvisualization_categoryoptiongroupsetdimensions eventvisualization_categoryoptiongroupsetdimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_categoryoptiongroupsetdimensions
    ADD CONSTRAINT eventvisualization_categoryoptiongroupsetdimensions_pkey PRIMARY KEY (eventvisualizationid, sort_order);


--
-- Name: eventvisualization_columns eventvisualization_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_columns
    ADD CONSTRAINT eventvisualization_columns_pkey PRIMARY KEY (eventvisualizationid, sort_order);


--
-- Name: eventvisualization_dataelementdimensions eventvisualization_dataelementdimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_dataelementdimensions
    ADD CONSTRAINT eventvisualization_dataelementdimensions_pkey PRIMARY KEY (eventvisualizationid, sort_order);


--
-- Name: eventvisualization_filters eventvisualization_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_filters
    ADD CONSTRAINT eventvisualization_filters_pkey PRIMARY KEY (eventvisualizationid, sort_order);


--
-- Name: eventvisualization_itemorgunitgroups eventvisualization_itemorgunitgroups_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_itemorgunitgroups
    ADD CONSTRAINT eventvisualization_itemorgunitgroups_pkey PRIMARY KEY (eventvisualizationid, sort_order);


--
-- Name: eventvisualization_organisationunits eventvisualization_organisationunits_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_organisationunits
    ADD CONSTRAINT eventvisualization_organisationunits_pkey PRIMARY KEY (eventvisualizationid, sort_order);


--
-- Name: eventvisualization_orgunitgroupsetdimensions eventvisualization_orgunitgroupsetdimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_orgunitgroupsetdimensions
    ADD CONSTRAINT eventvisualization_orgunitgroupsetdimensions_pkey PRIMARY KEY (eventvisualizationid, sort_order);


--
-- Name: eventvisualization_orgunitlevels eventvisualization_orgunitlevels_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_orgunitlevels
    ADD CONSTRAINT eventvisualization_orgunitlevels_pkey PRIMARY KEY (eventvisualizationid, sort_order);


--
-- Name: eventvisualization_periods eventvisualization_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_periods
    ADD CONSTRAINT eventvisualization_periods_pkey PRIMARY KEY (eventvisualizationid, sort_order);


--
-- Name: eventvisualization eventvisualization_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization
    ADD CONSTRAINT eventvisualization_pkey PRIMARY KEY (eventvisualizationid);


--
-- Name: eventvisualization_programindicatordimensions eventvisualization_programindicatordimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_programindicatordimensions
    ADD CONSTRAINT eventvisualization_programindicatordimensions_pkey PRIMARY KEY (eventvisualizationid, sort_order);


--
-- Name: eventvisualization_rows eventvisualization_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_rows
    ADD CONSTRAINT eventvisualization_rows_pkey PRIMARY KEY (eventvisualizationid, sort_order);


--
-- Name: expression expression_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.expression
    ADD CONSTRAINT expression_pkey PRIMARY KEY (expressionid);


--
-- Name: externalfileresource externalfileresource_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.externalfileresource
    ADD CONSTRAINT externalfileresource_pkey PRIMARY KEY (externalfileresourceid);


--
-- Name: externalmaplayer externalmaplayer_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.externalmaplayer
    ADD CONSTRAINT externalmaplayer_pkey PRIMARY KEY (externalmaplayerid);


--
-- Name: externalnotificationlogentry externalnotificationlogentry_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.externalnotificationlogentry
    ADD CONSTRAINT externalnotificationlogentry_pkey PRIMARY KEY (externalnotificationlogentryid);


--
-- Name: fileresource fileresource_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.fileresource
    ADD CONSTRAINT fileresource_pkey PRIMARY KEY (fileresourceid);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: i18nlocale i18nlocale_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.i18nlocale
    ADD CONSTRAINT i18nlocale_pkey PRIMARY KEY (i18nlocaleid);


--
-- Name: incomingsms incomingsms_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.incomingsms
    ADD CONSTRAINT incomingsms_pkey PRIMARY KEY (id);


--
-- Name: indicator indicator_code_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicator
    ADD CONSTRAINT indicator_code_key UNIQUE (code);


--
-- Name: indicator indicator_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicator
    ADD CONSTRAINT indicator_pkey PRIMARY KEY (indicatorid);


--
-- Name: indicatorgroup indicatorgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroup
    ADD CONSTRAINT indicatorgroup_pkey PRIMARY KEY (indicatorgroupid);


--
-- Name: indicatorgroupmembers indicatorgroupmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroupmembers
    ADD CONSTRAINT indicatorgroupmembers_pkey PRIMARY KEY (indicatorgroupid, indicatorid);


--
-- Name: indicatorgroupset indicatorgroupset_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroupset
    ADD CONSTRAINT indicatorgroupset_pkey PRIMARY KEY (indicatorgroupsetid);


--
-- Name: indicatorgroupset indicatorgroupset_unique_shortname; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroupset
    ADD CONSTRAINT indicatorgroupset_unique_shortname UNIQUE (shortname);


--
-- Name: indicatorgroupsetmembers indicatorgroupsetmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroupsetmembers
    ADD CONSTRAINT indicatorgroupsetmembers_pkey PRIMARY KEY (indicatorgroupsetid, sort_order);


--
-- Name: indicatorlegendsets indicatorlegendsets_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorlegendsets
    ADD CONSTRAINT indicatorlegendsets_pkey PRIMARY KEY (indicatorid, sort_order);


--
-- Name: indicatortype indicatortype_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatortype
    ADD CONSTRAINT indicatortype_pkey PRIMARY KEY (indicatortypeid);


--
-- Name: intepretation_likedby intepretation_likedby_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.intepretation_likedby
    ADD CONSTRAINT intepretation_likedby_pkey PRIMARY KEY (interpretationid, userid);


--
-- Name: interpretation_comments interpretation_comments_interpretationcommentid_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretation_comments
    ADD CONSTRAINT interpretation_comments_interpretationcommentid_key UNIQUE (interpretationcommentid) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: interpretation_comments interpretation_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretation_comments
    ADD CONSTRAINT interpretation_comments_pkey PRIMARY KEY (interpretationid, sort_order);


--
-- Name: interpretation interpretation_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretation
    ADD CONSTRAINT interpretation_pkey PRIMARY KEY (interpretationid);


--
-- Name: interpretationcomment interpretationcomment_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretationcomment
    ADD CONSTRAINT interpretationcomment_pkey PRIMARY KEY (interpretationcommentid);


--
-- Name: jobconfiguration jobconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.jobconfiguration
    ADD CONSTRAINT jobconfiguration_pkey PRIMARY KEY (jobconfigurationid);


--
-- Name: deletedobject key_deleted_object_klass_uid; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.deletedobject
    ADD CONSTRAINT key_deleted_object_klass_uid UNIQUE (klass, uid);


--
-- Name: section key_sectionnamedataset; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT key_sectionnamedataset UNIQUE (name, datasetid);


--
-- Name: keyjsonvalue keyjsonvalue_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.keyjsonvalue
    ADD CONSTRAINT keyjsonvalue_pkey PRIMARY KEY (keyjsonvalueid);


--
-- Name: keyjsonvalue keyjsonvalue_unique_key_in_namespace; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.keyjsonvalue
    ADD CONSTRAINT keyjsonvalue_unique_key_in_namespace UNIQUE (namespace, namespacekey);


--
-- Name: lockexception lockexception_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.lockexception
    ADD CONSTRAINT lockexception_pkey PRIMARY KEY (lockexceptionid);


--
-- Name: map map_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.map
    ADD CONSTRAINT map_pkey PRIMARY KEY (mapid);


--
-- Name: maplegend maplegend_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.maplegend
    ADD CONSTRAINT maplegend_pkey PRIMARY KEY (maplegendid);


--
-- Name: maplegendset maplegendset_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.maplegendset
    ADD CONSTRAINT maplegendset_pkey PRIMARY KEY (maplegendsetid);


--
-- Name: mapmapviews mapmapviews_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapmapviews
    ADD CONSTRAINT mapmapviews_pkey PRIMARY KEY (mapid, sort_order);


--
-- Name: mapview_attributedimensions mapview_attributedimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_attributedimensions
    ADD CONSTRAINT mapview_attributedimensions_pkey PRIMARY KEY (mapviewid, sort_order);


--
-- Name: mapview_categorydimensions mapview_categorydimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_categorydimensions
    ADD CONSTRAINT mapview_categorydimensions_pkey PRIMARY KEY (mapviewid, sort_order);


--
-- Name: mapview_categoryoptiongroupsetdimensions mapview_categoryoptiongroupsetdimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_categoryoptiongroupsetdimensions
    ADD CONSTRAINT mapview_categoryoptiongroupsetdimensions_pkey PRIMARY KEY (mapviewid, sort_order);


--
-- Name: mapview_columns mapview_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_columns
    ADD CONSTRAINT mapview_columns_pkey PRIMARY KEY (mapviewid, sort_order);


--
-- Name: mapview_datadimensionitems mapview_datadimensionitems_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_datadimensionitems
    ADD CONSTRAINT mapview_datadimensionitems_pkey PRIMARY KEY (mapviewid, sort_order);


--
-- Name: mapview_dataelementdimensions mapview_dataelementdimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_dataelementdimensions
    ADD CONSTRAINT mapview_dataelementdimensions_pkey PRIMARY KEY (mapviewid, sort_order);


--
-- Name: mapview_filters mapview_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_filters
    ADD CONSTRAINT mapview_filters_pkey PRIMARY KEY (mapviewid, sort_order);


--
-- Name: mapview_itemorgunitgroups mapview_itemorgunitgroups_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_itemorgunitgroups
    ADD CONSTRAINT mapview_itemorgunitgroups_pkey PRIMARY KEY (mapviewid, sort_order);


--
-- Name: mapview_organisationunits mapview_organisationunits_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_organisationunits
    ADD CONSTRAINT mapview_organisationunits_pkey PRIMARY KEY (mapviewid, sort_order);


--
-- Name: mapview_orgunitgroupsetdimensions mapview_orgunitgroupsetdimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_orgunitgroupsetdimensions
    ADD CONSTRAINT mapview_orgunitgroupsetdimensions_pkey PRIMARY KEY (mapviewid, sort_order);


--
-- Name: mapview_orgunitlevels mapview_orgunitlevels_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_orgunitlevels
    ADD CONSTRAINT mapview_orgunitlevels_pkey PRIMARY KEY (mapviewid, sort_order);


--
-- Name: mapview_periods mapview_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_periods
    ADD CONSTRAINT mapview_periods_pkey PRIMARY KEY (mapviewid, sort_order);


--
-- Name: mapview mapview_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview
    ADD CONSTRAINT mapview_pkey PRIMARY KEY (mapviewid);


--
-- Name: message message_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_pkey PRIMARY KEY (messageid);


--
-- Name: messageattachments messageattachments_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.messageattachments
    ADD CONSTRAINT messageattachments_pkey PRIMARY KEY (messageid, fileresourceid);


--
-- Name: messageconversation_messages messageconversation_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.messageconversation_messages
    ADD CONSTRAINT messageconversation_messages_pkey PRIMARY KEY (messageconversationid, sort_order);


--
-- Name: messageconversation messageconversation_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.messageconversation
    ADD CONSTRAINT messageconversation_pkey PRIMARY KEY (messageconversationid);


--
-- Name: messageconversation_usermessages messageconversation_usermessages_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.messageconversation_usermessages
    ADD CONSTRAINT messageconversation_usermessages_pkey PRIMARY KEY (messageconversationid, usermessageid);


--
-- Name: metadataproposal metadataproposal_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.metadataproposal
    ADD CONSTRAINT metadataproposal_pkey PRIMARY KEY (proposalid);


--
-- Name: metadataproposal metadataproposal_uid_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.metadataproposal
    ADD CONSTRAINT metadataproposal_uid_key UNIQUE (uid);


--
-- Name: metadataversion metadataversion_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.metadataversion
    ADD CONSTRAINT metadataversion_pkey PRIMARY KEY (versionid);


--
-- Name: minmaxdataelement minmaxdataelement_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.minmaxdataelement
    ADD CONSTRAINT minmaxdataelement_pkey PRIMARY KEY (minmaxdataelementid);


--
-- Name: minmaxdataelement minmaxdataelement_unique_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.minmaxdataelement
    ADD CONSTRAINT minmaxdataelement_unique_key UNIQUE (sourceid, dataelementid, categoryoptioncomboid);


--
-- Name: oauth2client oauth2client_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.oauth2client
    ADD CONSTRAINT oauth2client_pkey PRIMARY KEY (oauth2clientid);


--
-- Name: oauth2clientgranttypes oauth2clientgranttypes_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.oauth2clientgranttypes
    ADD CONSTRAINT oauth2clientgranttypes_pkey PRIMARY KEY (oauth2clientid, sort_order);


--
-- Name: oauth2clientredirecturis oauth2clientredirecturis_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.oauth2clientredirecturis
    ADD CONSTRAINT oauth2clientredirecturis_pkey PRIMARY KEY (oauth2clientid, sort_order);


--
-- Name: oauth_access_token oauth_access_token_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.oauth_access_token
    ADD CONSTRAINT oauth_access_token_pkey PRIMARY KEY (authentication_id);


--
-- Name: optiongroup optiongroup_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroup
    ADD CONSTRAINT optiongroup_pkey PRIMARY KEY (optiongroupid);


--
-- Name: optiongroupmembers optiongroupmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroupmembers
    ADD CONSTRAINT optiongroupmembers_pkey PRIMARY KEY (optiongroupid, optionid);


--
-- Name: optiongroupset optiongroupset_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroupset
    ADD CONSTRAINT optiongroupset_pkey PRIMARY KEY (optiongroupsetid);


--
-- Name: optiongroupsetmembers optiongroupsetmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroupsetmembers
    ADD CONSTRAINT optiongroupsetmembers_pkey PRIMARY KEY (optiongroupsetid, sort_order);


--
-- Name: optionset optionset_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optionset
    ADD CONSTRAINT optionset_pkey PRIMARY KEY (optionsetid);


--
-- Name: optionvalue optionvalue_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optionvalue
    ADD CONSTRAINT optionvalue_pkey PRIMARY KEY (optionvalueid);


--
-- Name: organisationunit organisationunit_code_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.organisationunit
    ADD CONSTRAINT organisationunit_code_key UNIQUE (code);


--
-- Name: organisationunit organisationunit_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.organisationunit
    ADD CONSTRAINT organisationunit_pkey PRIMARY KEY (organisationunitid);


--
-- Name: orgunitgroup orgunitgroup_name_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroup
    ADD CONSTRAINT orgunitgroup_name_key UNIQUE (name);


--
-- Name: orgunitgroup orgunitgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroup
    ADD CONSTRAINT orgunitgroup_pkey PRIMARY KEY (orgunitgroupid);


--
-- Name: orgunitgroupmembers orgunitgroupmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupmembers
    ADD CONSTRAINT orgunitgroupmembers_pkey PRIMARY KEY (orgunitgroupid, organisationunitid);


--
-- Name: orgunitgroupset orgunitgroupset_name_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupset
    ADD CONSTRAINT orgunitgroupset_name_key UNIQUE (name);


--
-- Name: orgunitgroupset orgunitgroupset_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupset
    ADD CONSTRAINT orgunitgroupset_pkey PRIMARY KEY (orgunitgroupsetid);


--
-- Name: orgunitgroupset orgunitgroupset_unique_shortname; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupset
    ADD CONSTRAINT orgunitgroupset_unique_shortname UNIQUE (shortname);


--
-- Name: orgunitgroupsetdimension_items orgunitgroupsetdimension_items_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupsetdimension_items
    ADD CONSTRAINT orgunitgroupsetdimension_items_pkey PRIMARY KEY (orgunitgroupsetdimensionid, sort_order);


--
-- Name: orgunitgroupsetdimension orgunitgroupsetdimension_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupsetdimension
    ADD CONSTRAINT orgunitgroupsetdimension_pkey PRIMARY KEY (orgunitgroupsetdimensionid);


--
-- Name: orgunitgroupsetmembers orgunitgroupsetmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupsetmembers
    ADD CONSTRAINT orgunitgroupsetmembers_pkey PRIMARY KEY (orgunitgroupsetid, orgunitgroupid);


--
-- Name: orgunitlevel orgunitlevel_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitlevel
    ADD CONSTRAINT orgunitlevel_pkey PRIMARY KEY (orgunitlevelid);


--
-- Name: outbound_sms outbound_sms_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.outbound_sms
    ADD CONSTRAINT outbound_sms_pkey PRIMARY KEY (id);


--
-- Name: period period_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.period
    ADD CONSTRAINT period_pkey PRIMARY KEY (periodid);


--
-- Name: periodboundary periodboundary_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.periodboundary
    ADD CONSTRAINT periodboundary_pkey PRIMARY KEY (periodboundaryid);


--
-- Name: periodtype periodtype_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.periodtype
    ADD CONSTRAINT periodtype_pkey PRIMARY KEY (periodtypeid);


--
-- Name: potentialduplicate potentialduplicate_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.potentialduplicate
    ADD CONSTRAINT potentialduplicate_pkey PRIMARY KEY (potentialduplicateid);


--
-- Name: potentialduplicate potentialduplicate_teia_teib; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.potentialduplicate
    ADD CONSTRAINT potentialduplicate_teia_teib UNIQUE (teia, teib);


--
-- Name: potentialduplicate potentialduplicate_uid_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.potentialduplicate
    ADD CONSTRAINT potentialduplicate_uid_key UNIQUE (uid);


--
-- Name: predictor predictor_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictor
    ADD CONSTRAINT predictor_pkey PRIMARY KEY (predictorid);


--
-- Name: predictor predictor_unique_shortname; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictor
    ADD CONSTRAINT predictor_unique_shortname UNIQUE (shortname);


--
-- Name: predictorgroup predictorgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictorgroup
    ADD CONSTRAINT predictorgroup_pkey PRIMARY KEY (predictorgroupid);


--
-- Name: predictorgroupmembers predictorgroupmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictorgroupmembers
    ADD CONSTRAINT predictorgroupmembers_pkey PRIMARY KEY (predictorgroupid, predictorid);


--
-- Name: predictororgunitlevels predictororgunitlevels_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictororgunitlevels
    ADD CONSTRAINT predictororgunitlevels_pkey PRIMARY KEY (predictorid, orgunitlevelid);


--
-- Name: previouspasswords previouspasswords_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.previouspasswords
    ADD CONSTRAINT previouspasswords_pkey PRIMARY KEY (userid, list_index);


--
-- Name: program_attribute_group program_attribute_group_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program_attribute_group
    ADD CONSTRAINT program_attribute_group_pkey PRIMARY KEY (programtrackedentityattributegroupid);


--
-- Name: program_attributes program_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program_attributes
    ADD CONSTRAINT program_attributes_pkey PRIMARY KEY (programtrackedentityattributeid);


--
-- Name: program_organisationunits program_organisationunits_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program_organisationunits
    ADD CONSTRAINT program_organisationunits_pkey PRIMARY KEY (programid, organisationunitid);


--
-- Name: program program_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT program_pkey PRIMARY KEY (programid);


--
-- Name: programexpression programexpression_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programexpression
    ADD CONSTRAINT programexpression_pkey PRIMARY KEY (programexpressionid);


--
-- Name: programindicator programindicator_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicator
    ADD CONSTRAINT programindicator_pkey PRIMARY KEY (programindicatorid);


--
-- Name: programindicatorgroup programindicatorgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicatorgroup
    ADD CONSTRAINT programindicatorgroup_pkey PRIMARY KEY (programindicatorgroupid);


--
-- Name: programindicatorgroupmembers programindicatorgroupmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicatorgroupmembers
    ADD CONSTRAINT programindicatorgroupmembers_pkey PRIMARY KEY (programindicatorgroupid, programindicatorid);


--
-- Name: programindicatorlegendsets programindicatorlegendsets_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicatorlegendsets
    ADD CONSTRAINT programindicatorlegendsets_pkey PRIMARY KEY (programindicatorid, sort_order);


--
-- Name: programinstance_messageconversation programinstance_messageconversation_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programinstance_messageconversation
    ADD CONSTRAINT programinstance_messageconversation_pkey PRIMARY KEY (programinstanceid, sort_order);


--
-- Name: programinstance programinstance_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programinstance
    ADD CONSTRAINT programinstance_pkey PRIMARY KEY (programinstanceid);


--
-- Name: programinstancecomments programinstancecomments_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programinstancecomments
    ADD CONSTRAINT programinstancecomments_pkey PRIMARY KEY (programinstanceid, sort_order);


--
-- Name: programmessage programmessage_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programmessage
    ADD CONSTRAINT programmessage_pkey PRIMARY KEY (id);


--
-- Name: programnotificationinstance programnotificationinstance_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programnotificationinstance
    ADD CONSTRAINT programnotificationinstance_pkey PRIMARY KEY (programnotificationinstanceid);


--
-- Name: programnotificationtemplate programnotificationtemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programnotificationtemplate
    ADD CONSTRAINT programnotificationtemplate_pkey PRIMARY KEY (programnotificationtemplateid);


--
-- Name: programownershiphistory programownershiphistory_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programownershiphistory
    ADD CONSTRAINT programownershiphistory_pkey PRIMARY KEY (programownershiphistoryid);


--
-- Name: programrule programrule_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programrule
    ADD CONSTRAINT programrule_pkey PRIMARY KEY (programruleid);


--
-- Name: programruleaction programruleaction_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programruleaction
    ADD CONSTRAINT programruleaction_pkey PRIMARY KEY (programruleactionid);


--
-- Name: programrulevariable programrulevariable_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programrulevariable
    ADD CONSTRAINT programrulevariable_pkey PRIMARY KEY (programrulevariableid);


--
-- Name: programsection_attributes programsection_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programsection_attributes
    ADD CONSTRAINT programsection_attributes_pkey PRIMARY KEY (programsectionid, sort_order);


--
-- Name: programsection programsection_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programsection
    ADD CONSTRAINT programsection_pkey PRIMARY KEY (programsectionid);


--
-- Name: programstage programstage_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstage
    ADD CONSTRAINT programstage_pkey PRIMARY KEY (programstageid);


--
-- Name: programstagedataelement programstagedataelement_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagedataelement
    ADD CONSTRAINT programstagedataelement_pkey PRIMARY KEY (programstagedataelementid);


--
-- Name: programstagedataelement programstagedataelement_unique_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagedataelement
    ADD CONSTRAINT programstagedataelement_unique_key UNIQUE (programstageid, dataelementid);


--
-- Name: programstageinstance_messageconversation programstageinstance_messageconversation_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstance_messageconversation
    ADD CONSTRAINT programstageinstance_messageconversation_pkey PRIMARY KEY (programstageinstanceid, sort_order);


--
-- Name: programstageinstance programstageinstance_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstance
    ADD CONSTRAINT programstageinstance_pkey PRIMARY KEY (programstageinstanceid);


--
-- Name: programstageinstancecomments programstageinstancecomments_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstancecomments
    ADD CONSTRAINT programstageinstancecomments_pkey PRIMARY KEY (programstageinstanceid, sort_order);


--
-- Name: programstageinstancefilter programstageinstancefilter_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstancefilter
    ADD CONSTRAINT programstageinstancefilter_pkey PRIMARY KEY (programstageinstancefilterid);


--
-- Name: programstagesection_dataelements programstagesection_dataelements_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagesection_dataelements
    ADD CONSTRAINT programstagesection_dataelements_pkey PRIMARY KEY (programstagesectionid, sort_order);


--
-- Name: programstagesection programstagesection_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagesection
    ADD CONSTRAINT programstagesection_pkey PRIMARY KEY (programstagesectionid);


--
-- Name: programstagesection_programindicators programstagesection_programindicators_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagesection_programindicators
    ADD CONSTRAINT programstagesection_programindicators_pkey PRIMARY KEY (programstagesectionid, sort_order);


--
-- Name: programtempowner programtempowner_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programtempowner
    ADD CONSTRAINT programtempowner_pkey PRIMARY KEY (programtempownerid);


--
-- Name: programtempownershipaudit programtempownershipaudit_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programtempownershipaudit
    ADD CONSTRAINT programtempownershipaudit_pkey PRIMARY KEY (programtempownershipauditid);


--
-- Name: program_attributes programtrackedentityattribute_unique_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program_attributes
    ADD CONSTRAINT programtrackedentityattribute_unique_key UNIQUE (programid, trackedentityattributeid);


--
-- Name: programtrackedentityattributegroupmembers programtrackedentityattributegroupmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programtrackedentityattributegroupmembers
    ADD CONSTRAINT programtrackedentityattributegroupmembers_pkey PRIMARY KEY (programtrackedentityattributeid, programtrackedentityattributegroupid);


--
-- Name: pushanalysis pushanalysis_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.pushanalysis
    ADD CONSTRAINT pushanalysis_pkey PRIMARY KEY (pushanalysisid);


--
-- Name: pushanalysisrecipientusergroups pushanalysisrecipientusergroups_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.pushanalysisrecipientusergroups
    ADD CONSTRAINT pushanalysisrecipientusergroups_pkey PRIMARY KEY (usergroupid, elt);


--
-- Name: relationship relationship_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationship
    ADD CONSTRAINT relationship_pkey PRIMARY KEY (relationshipid);


--
-- Name: relationshipconstraint relationshipconstraint_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshipconstraint
    ADD CONSTRAINT relationshipconstraint_pkey PRIMARY KEY (relationshipconstraintid);


--
-- Name: relationshipitem relationshipitem_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshipitem
    ADD CONSTRAINT relationshipitem_pkey PRIMARY KEY (relationshipitemid);


--
-- Name: relationshiptype relationshiptype_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshiptype
    ADD CONSTRAINT relationshiptype_pkey PRIMARY KEY (relationshiptypeid);


--
-- Name: relativeperiods relativeperiods_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relativeperiods
    ADD CONSTRAINT relativeperiods_pkey PRIMARY KEY (relativeperiodsid);


--
-- Name: report report_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.report
    ADD CONSTRAINT report_pkey PRIMARY KEY (reportid);


--
-- Name: reservedvalue reservedvalue_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.reservedvalue
    ADD CONSTRAINT reservedvalue_pkey PRIMARY KEY (reservedvalueid);


--
-- Name: section section_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT section_pkey PRIMARY KEY (sectionid);


--
-- Name: sectiondataelements sectiondataelements_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.sectiondataelements
    ADD CONSTRAINT sectiondataelements_pkey PRIMARY KEY (sectionid, sort_order);


--
-- Name: sectiongreyedfields sectiongreyedfields_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.sectiongreyedfields
    ADD CONSTRAINT sectiongreyedfields_pkey PRIMARY KEY (sectionid, dataelementoperandid);


--
-- Name: sectionindicators sectionindicators_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.sectionindicators
    ADD CONSTRAINT sectionindicators_pkey PRIMARY KEY (sectionid, sort_order);


--
-- Name: sequentialnumbercounter seqnumcount_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.sequentialnumbercounter
    ADD CONSTRAINT seqnumcount_pkey PRIMARY KEY (owneruid, key);


--
-- Name: series series_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_pkey PRIMARY KEY (seriesid);


--
-- Name: smscodes smscodes_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscodes
    ADD CONSTRAINT smscodes_pkey PRIMARY KEY (smscodeid);


--
-- Name: smscommandcodes smscommandcodes_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscommandcodes
    ADD CONSTRAINT smscommandcodes_pkey PRIMARY KEY (id, codeid);


--
-- Name: smscommands smscommands_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscommands
    ADD CONSTRAINT smscommands_pkey PRIMARY KEY (smscommandid);


--
-- Name: smscommandspecialcharacters smscommandspecialcharacters_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscommandspecialcharacters
    ADD CONSTRAINT smscommandspecialcharacters_pkey PRIMARY KEY (smscommandid, specialcharacterid);


--
-- Name: smsspecialcharacter smsspecialcharacter_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smsspecialcharacter
    ADD CONSTRAINT smsspecialcharacter_pkey PRIMARY KEY (specialcharacterid);


--
-- Name: sqlview sqlview_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.sqlview
    ADD CONSTRAINT sqlview_pkey PRIMARY KEY (sqlviewid);


--
-- Name: systemsetting systemsetting_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.systemsetting
    ADD CONSTRAINT systemsetting_pkey PRIMARY KEY (systemsettingid);


--
-- Name: tablehook tablehook_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.tablehook
    ADD CONSTRAINT tablehook_pkey PRIMARY KEY (analyticstablehookid);


--
-- Name: trackedentityattribute trackedentityattribute_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattribute
    ADD CONSTRAINT trackedentityattribute_pkey PRIMARY KEY (trackedentityattributeid);


--
-- Name: trackedentityattributedimension trackedentityattributedimension_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattributedimension
    ADD CONSTRAINT trackedentityattributedimension_pkey PRIMARY KEY (trackedentityattributedimensionid);


--
-- Name: trackedentityattributelegendsets trackedentityattributelegendsets_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattributelegendsets
    ADD CONSTRAINT trackedentityattributelegendsets_pkey PRIMARY KEY (trackedentityattributeid, sort_order);


--
-- Name: trackedentityattributevalue trackedentityattributevalue_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattributevalue
    ADD CONSTRAINT trackedentityattributevalue_pkey PRIMARY KEY (trackedentityinstanceid, trackedentityattributeid);


--
-- Name: trackedentityattributevalueaudit trackedentityattributevalueaudit_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattributevalueaudit
    ADD CONSTRAINT trackedentityattributevalueaudit_pkey PRIMARY KEY (trackedentityattributevalueauditid);


--
-- Name: trackedentitycomment trackedentitycomment_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitycomment
    ADD CONSTRAINT trackedentitycomment_pkey PRIMARY KEY (trackedentitycommentid);


--
-- Name: trackedentitydataelementdimension trackedentitydataelementdimension_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitydataelementdimension
    ADD CONSTRAINT trackedentitydataelementdimension_pkey PRIMARY KEY (trackedentitydataelementdimensionid);


--
-- Name: trackedentitydatavalueaudit trackedentitydatavalueaudit_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitydatavalueaudit
    ADD CONSTRAINT trackedentitydatavalueaudit_pkey PRIMARY KEY (trackedentitydatavalueauditid);


--
-- Name: trackedentityinstance trackedentityinstance_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityinstance
    ADD CONSTRAINT trackedentityinstance_pkey PRIMARY KEY (trackedentityinstanceid);


--
-- Name: trackedentityinstanceaudit trackedentityinstanceaudit_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityinstanceaudit
    ADD CONSTRAINT trackedentityinstanceaudit_pkey PRIMARY KEY (trackedentityinstanceauditid);


--
-- Name: trackedentityinstancefilter trackedentityinstancefilter_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityinstancefilter
    ADD CONSTRAINT trackedentityinstancefilter_pkey PRIMARY KEY (trackedentityinstancefilterid);


--
-- Name: trackedentityprogramindicatordimension trackedentityprogramindicatordimension_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityprogramindicatordimension
    ADD CONSTRAINT trackedentityprogramindicatordimension_pkey PRIMARY KEY (trackedentityprogramindicatordimensionid);


--
-- Name: trackedentityprogramowner trackedentityprogramowner_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityprogramowner
    ADD CONSTRAINT trackedentityprogramowner_pkey PRIMARY KEY (trackedentityprogramownerid);


--
-- Name: trackedentitytype trackedentitytype_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitytype
    ADD CONSTRAINT trackedentitytype_pkey PRIMARY KEY (trackedentitytypeid);


--
-- Name: trackedentitytypeattribute trackedentitytypeattribute_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitytypeattribute
    ADD CONSTRAINT trackedentitytypeattribute_pkey PRIMARY KEY (trackedentitytypeattributeid);


--
-- Name: trackedentitytypeattribute uk_10sblshxcb7dd4qi3s879u35h; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitytypeattribute
    ADD CONSTRAINT uk_10sblshxcb7dd4qi3s879u35h UNIQUE (uid);


--
-- Name: validationrule uk_13x63e3skbl5qj4mc1qgq2xex; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrule
    ADD CONSTRAINT uk_13x63e3skbl5qj4mc1qgq2xex UNIQUE (code);


--
-- Name: attribute uk_1774shfid1uaopl9tu8am19fq; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.attribute
    ADD CONSTRAINT uk_1774shfid1uaopl9tu8am19fq UNIQUE (code);


--
-- Name: optionvalue uk_18b68rcofdwt1sbr6rf55poog; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optionvalue
    ADD CONSTRAINT uk_18b68rcofdwt1sbr6rf55poog UNIQUE (uid);


--
-- Name: mapview uk_1dw8gju4leg7iud4gpsr5r1ng; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview
    ADD CONSTRAINT uk_1dw8gju4leg7iud4gpsr5r1ng UNIQUE (uid);


--
-- Name: dataelementcategory uk_1ev6xqtcsfr4wv6rel0lkg44n; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementcategory
    ADD CONSTRAINT uk_1ev6xqtcsfr4wv6rel0lkg44n UNIQUE (uid);


--
-- Name: optiongroupsetmembers uk_1film7lsn5m1wyeku7yh5anfa; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroupsetmembers
    ADD CONSTRAINT uk_1film7lsn5m1wyeku7yh5anfa UNIQUE (optiongroupid);


--
-- Name: report uk_1ie06vhy3begtwuuvrv0f71se; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.report
    ADD CONSTRAINT uk_1ie06vhy3begtwuuvrv0f71se UNIQUE (uid);


--
-- Name: validationrulegroup uk_1lvk8ftq028jrr28qouou9q3c; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrulegroup
    ADD CONSTRAINT uk_1lvk8ftq028jrr28qouou9q3c UNIQUE (code);


--
-- Name: programstageinstancecomments uk_1n7xvxj0jupob5f2v86cv8qer; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstancecomments
    ADD CONSTRAINT uk_1n7xvxj0jupob5f2v86cv8qer UNIQUE (trackedentitycommentid);


--
-- Name: programmessage uk_1qlw3rts2pog96ye7r6fqd122; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programmessage
    ADD CONSTRAINT uk_1qlw3rts2pog96ye7r6fqd122 UNIQUE (uid);


--
-- Name: dataelementgroupset uk_1xk8j7j0a3li8o0ukblanosky; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupset
    ADD CONSTRAINT uk_1xk8j7j0a3li8o0ukblanosky UNIQUE (name);


--
-- Name: programstagesection uk_22wt9yk9idujmywno44v9qf66; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagesection
    ADD CONSTRAINT uk_22wt9yk9idujmywno44v9qf66 UNIQUE (code);


--
-- Name: optiongroupset uk_2boebaetgus89t1k8nn4dac65; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroupset
    ADD CONSTRAINT uk_2boebaetgus89t1k8nn4dac65 UNIQUE (uid);


--
-- Name: programstagedataelement uk_2ejl9l5vm4rhtqj8eit31g0u6; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagedataelement
    ADD CONSTRAINT uk_2ejl9l5vm4rhtqj8eit31g0u6 UNIQUE (code);


--
-- Name: relationship uk_2gbm9ji77snuoll07yvpgj3o5; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationship
    ADD CONSTRAINT uk_2gbm9ji77snuoll07yvpgj3o5 UNIQUE (to_relationshipitemid);


--
-- Name: i18nlocale uk_2l0ovv74pjtairmeyiwy4i2ui; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.i18nlocale
    ADD CONSTRAINT uk_2l0ovv74pjtairmeyiwy4i2ui UNIQUE (uid);


--
-- Name: dataelement uk_2nhc265rlfu3dlc3qouvjdprl; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelement
    ADD CONSTRAINT uk_2nhc265rlfu3dlc3qouvjdprl UNIQUE (name);


--
-- Name: programindicatorgroup uk_2p9x16ryxtek0g6bqwd49et0c; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicatorgroup
    ADD CONSTRAINT uk_2p9x16ryxtek0g6bqwd49et0c UNIQUE (uid);


--
-- Name: programnotificationtemplate uk_2pimmculf9ttu2dxquomb9ram; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programnotificationtemplate
    ADD CONSTRAINT uk_2pimmculf9ttu2dxquomb9ram UNIQUE (uid);


--
-- Name: dataapprovallevel uk_2r18tvmbtksk69j35uxpwej44; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovallevel
    ADD CONSTRAINT uk_2r18tvmbtksk69j35uxpwej44 UNIQUE (code);


--
-- Name: userkeyjsonvalue uk_2ubxwwtgyqd0h2mvy46u3prfq; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userkeyjsonvalue
    ADD CONSTRAINT uk_2ubxwwtgyqd0h2mvy46u3prfq UNIQUE (code);


--
-- Name: map uk_37l2m3o1xfuagpki90gfh5kqb; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.map
    ADD CONSTRAINT uk_37l2m3o1xfuagpki90gfh5kqb UNIQUE (code);


--
-- Name: categorycombo uk_3a4ee92kxafw85hsopq4qle47; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorycombo
    ADD CONSTRAINT uk_3a4ee92kxafw85hsopq4qle47 UNIQUE (code);


--
-- Name: programruleaction uk_3c2n8db21er764e4skh3qg57w; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programruleaction
    ADD CONSTRAINT uk_3c2n8db21er764e4skh3qg57w UNIQUE (uid);


--
-- Name: validationrulegroup uk_3cl2o6ha8naw5w6my3q4el6gk; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrulegroup
    ADD CONSTRAINT uk_3cl2o6ha8naw5w6my3q4el6gk UNIQUE (name);


--
-- Name: dashboarditem uk_3idqsvkpmxpehxqv615s952vd; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem
    ADD CONSTRAINT uk_3idqsvkpmxpehxqv615s952vd UNIQUE (uid);


--
-- Name: orgunitgroup uk_3phvecdmy2msmcpitqifpcy3c; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroup
    ADD CONSTRAINT uk_3phvecdmy2msmcpitqifpcy3c UNIQUE (code);


--
-- Name: dataelement uk_3r6dr8m9qwa89afngtr43x9jh; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelement
    ADD CONSTRAINT uk_3r6dr8m9qwa89afngtr43x9jh UNIQUE (uid);


--
-- Name: dataapprovalworkflow uk_3svwn20y9qda34bmatesg5c0j; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalworkflow
    ADD CONSTRAINT uk_3svwn20y9qda34bmatesg5c0j UNIQUE (code);


--
-- Name: programmessage uk_3vgkycs0lsgpxaqtytfijr1ji; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programmessage
    ADD CONSTRAINT uk_3vgkycs0lsgpxaqtytfijr1ji UNIQUE (code);


--
-- Name: programindicator uk_4372w9f7asbu1ybpduj2xqjmt; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicator
    ADD CONSTRAINT uk_4372w9f7asbu1ybpduj2xqjmt UNIQUE (shortname);


--
-- Name: report uk_478bg522jkn8460hkeshlw1j1; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.report
    ADD CONSTRAINT uk_478bg522jkn8460hkeshlw1j1 UNIQUE (relativeperiodsid);


--
-- Name: program_attribute_group uk_48xfoqrfjnkuay28xeixjm0t0; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program_attribute_group
    ADD CONSTRAINT uk_48xfoqrfjnkuay28xeixjm0t0 UNIQUE (code);


--
-- Name: predictor uk_4b97sdsm2p477cc05eody10lm; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictor
    ADD CONSTRAINT uk_4b97sdsm2p477cc05eody10lm UNIQUE (name);


--
-- Name: tablehook uk_4bcigh7ivtiraxnhqrg72tldo; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.tablehook
    ADD CONSTRAINT uk_4bcigh7ivtiraxnhqrg72tldo UNIQUE (code);


--
-- Name: fileresource uk_4dlqoc6s8ilws9yhacy5qkddb; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.fileresource
    ADD CONSTRAINT uk_4dlqoc6s8ilws9yhacy5qkddb UNIQUE (code);


--
-- Name: periodboundary uk_4e9t02lypy6ynejqfegixx36k; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.periodboundary
    ADD CONSTRAINT uk_4e9t02lypy6ynejqfegixx36k UNIQUE (uid);


--
-- Name: trackedentitytype uk_4iylxmooa7ca562qvw4tjq5ys; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitytype
    ADD CONSTRAINT uk_4iylxmooa7ca562qvw4tjq5ys UNIQUE (uid);


--
-- Name: userkeyjsonvalue uk_4k3a3mf7dgr4b2btftg5jkmt7; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userkeyjsonvalue
    ADD CONSTRAINT uk_4k3a3mf7dgr4b2btftg5jkmt7 UNIQUE (uid);


--
-- Name: programnotificationinstance uk_4mi7q6tbreuo0hspppxyodibk; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programnotificationinstance
    ADD CONSTRAINT uk_4mi7q6tbreuo0hspppxyodibk UNIQUE (code);


--
-- Name: program_attribute_group uk_4n6nev8dlydiyu5k8xyjtsasl; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program_attribute_group
    ADD CONSTRAINT uk_4n6nev8dlydiyu5k8xyjtsasl UNIQUE (name);


--
-- Name: dataelementcategoryoption uk_4pi5lfmisrt8un89dnb17xrdy; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementcategoryoption
    ADD CONSTRAINT uk_4pi5lfmisrt8un89dnb17xrdy UNIQUE (uid);


--
-- Name: sqlview uk_50aqn6tun6lt4u3ablvdxgoi6; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.sqlview
    ADD CONSTRAINT uk_50aqn6tun6lt4u3ablvdxgoi6 UNIQUE (code);


--
-- Name: externalmaplayer uk_581ayy658kxytmijcfd2rxnq0; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.externalmaplayer
    ADD CONSTRAINT uk_581ayy658kxytmijcfd2rxnq0 UNIQUE (name);


--
-- Name: programindicator uk_59abitsfd3u0jx4ntrrblven0; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicator
    ADD CONSTRAINT uk_59abitsfd3u0jx4ntrrblven0 UNIQUE (uid);


--
-- Name: orgunitlevel uk_5km0xiwk0dg7pnoru5yfvqsdo; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitlevel
    ADD CONSTRAINT uk_5km0xiwk0dg7pnoru5yfvqsdo UNIQUE (uid);


--
-- Name: dataapprovallevel uk_5mq4bmpyevmr1ddkkopweted1; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovallevel
    ADD CONSTRAINT uk_5mq4bmpyevmr1ddkkopweted1 UNIQUE (name);


--
-- Name: eventchart uk_5w429v9hdlvivan4a69x3ntx5; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart
    ADD CONSTRAINT uk_5w429v9hdlvivan4a69x3ntx5 UNIQUE (relativeperiodsid);


--
-- Name: categoryoptioncombo uk_60p9gh2un0pb7l9tctfd4o3b3; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptioncombo
    ADD CONSTRAINT uk_60p9gh2un0pb7l9tctfd4o3b3 UNIQUE (code);


--
-- Name: externalmaplayer uk_64w4wa4oc3hkxo86hjo63cd1x; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.externalmaplayer
    ADD CONSTRAINT uk_64w4wa4oc3hkxo86hjo63cd1x UNIQUE (uid);


--
-- Name: tablehook uk_668dyd20363ufr44a805inegm; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.tablehook
    ADD CONSTRAINT uk_668dyd20363ufr44a805inegm UNIQUE (name);


--
-- Name: eventchart uk_679r4uoqpust6h694bed8nrh9; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart
    ADD CONSTRAINT uk_679r4uoqpust6h694bed8nrh9 UNIQUE (uid);


--
-- Name: eventchart uk_6dyim42vl218i9e9waqrvw36k; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventchart
    ADD CONSTRAINT uk_6dyim42vl218i9e9waqrvw36k UNIQUE (code);


--
-- Name: categoryoptiongroupset uk_6itpx2frqt3msln8p32rk7qta; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupset
    ADD CONSTRAINT uk_6itpx2frqt3msln8p32rk7qta UNIQUE (uid);


--
-- Name: trackedentitytypeattribute uk_6lycqfymeu4sdi4t3cdh6ul1k; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitytypeattribute
    ADD CONSTRAINT uk_6lycqfymeu4sdi4t3cdh6ul1k UNIQUE (code);


--
-- Name: optiongroup uk_6ni8qsiimdcy626hwls002flo; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroup
    ADD CONSTRAINT uk_6ni8qsiimdcy626hwls002flo UNIQUE (name);


--
-- Name: mapview uk_6nm3ynkrtuj01bpo1uwcryq06; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview
    ADD CONSTRAINT uk_6nm3ynkrtuj01bpo1uwcryq06 UNIQUE (code);


--
-- Name: dataelementgroup uk_6x37lph70r5mh15a71pf1tj17; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroup
    ADD CONSTRAINT uk_6x37lph70r5mh15a71pf1tj17 UNIQUE (shortname);


--
-- Name: relationship uk_74iy11sx99wxaut3skkphkvgi; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationship
    ADD CONSTRAINT uk_74iy11sx99wxaut3skkphkvgi UNIQUE (uid);


--
-- Name: tablehook uk_78x5lua91w1j6upu02wh8pfx9; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.tablehook
    ADD CONSTRAINT uk_78x5lua91w1j6upu02wh8pfx9 UNIQUE (uid);


--
-- Name: relationship uk_799tkjg7am2injr1dypaidt4p; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationship
    ADD CONSTRAINT uk_799tkjg7am2injr1dypaidt4p UNIQUE (code);


--
-- Name: programindicatorgroup uk_7carnwjb5dtsk6i5dn43wy9ck; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicatorgroup
    ADD CONSTRAINT uk_7carnwjb5dtsk6i5dn43wy9ck UNIQUE (name);


--
-- Name: programrule uk_7odx4uo6s5bg55kt1fxky4a8v; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programrule
    ADD CONSTRAINT uk_7odx4uo6s5bg55kt1fxky4a8v UNIQUE (code);


--
-- Name: relationshiptype uk_7rnfvkitq6l0kr5ju2slxopfi; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshiptype
    ADD CONSTRAINT uk_7rnfvkitq6l0kr5ju2slxopfi UNIQUE (uid);


--
-- Name: programindicator uk_7udjng39j4ddafjn57r58v7oq; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicator
    ADD CONSTRAINT uk_7udjng39j4ddafjn57r58v7oq UNIQUE (name);


--
-- Name: optionset uk_81gfx3yt7ngwmkk0t8qgcovhi; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optionset
    ADD CONSTRAINT uk_81gfx3yt7ngwmkk0t8qgcovhi UNIQUE (uid);


--
-- Name: maplegendset uk_842ips1xb81udqc3dw5uax7u5; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.maplegendset
    ADD CONSTRAINT uk_842ips1xb81udqc3dw5uax7u5 UNIQUE (name);


--
-- Name: programsection uk_84abcabq3so8ktgt726o5du9d; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programsection
    ADD CONSTRAINT uk_84abcabq3so8ktgt726o5du9d UNIQUE (uid);


--
-- Name: validationnotificationtemplate uk_87wso1e1xtxsl34nxey6nr922; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationnotificationtemplate
    ADD CONSTRAINT uk_87wso1e1xtxsl34nxey6nr922 UNIQUE (code);


--
-- Name: validationrulegroup uk_8alvmsgu0onl4i0a0sqb6mqx; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrulegroup
    ADD CONSTRAINT uk_8alvmsgu0onl4i0a0sqb6mqx UNIQUE (uid);


--
-- Name: relationshiptype uk_8d4xrx2gygb4aivpcwrp613hj; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshiptype
    ADD CONSTRAINT uk_8d4xrx2gygb4aivpcwrp613hj UNIQUE (name);


--
-- Name: indicatortype uk_8dcmrupnoi7hiiom466aoa2y; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatortype
    ADD CONSTRAINT uk_8dcmrupnoi7hiiom466aoa2y UNIQUE (code);


--
-- Name: mapview uk_8eyremdx683wcd9owh1t5jufs; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview
    ADD CONSTRAINT uk_8eyremdx683wcd9owh1t5jufs UNIQUE (relativeperiodsid);


--
-- Name: trackedentitycomment uk_8ul0w6gi3mdnr0kficn5syigg; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitycomment
    ADD CONSTRAINT uk_8ul0w6gi3mdnr0kficn5syigg UNIQUE (code);


--
-- Name: externalfileresource uk_8v1lxgqdnnocvm9ah6clxmjf; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.externalfileresource
    ADD CONSTRAINT uk_8v1lxgqdnnocvm9ah6clxmjf UNIQUE (code);


--
-- Name: dataelement uk_94srnunkibylfaxt4knxfn58e; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelement
    ADD CONSTRAINT uk_94srnunkibylfaxt4knxfn58e UNIQUE (code);


--
-- Name: maplegend uk_9csrw908a1fvfwbhjwm0jfl4e; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.maplegend
    ADD CONSTRAINT uk_9csrw908a1fvfwbhjwm0jfl4e UNIQUE (uid);


--
-- Name: section uk_9hvlbsw019hscf35xb5behfx9; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT uk_9hvlbsw019hscf35xb5behfx9 UNIQUE (code);


--
-- Name: i18nlocale uk_9j6xjgegveyc0uqs506yy2wrp; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.i18nlocale
    ADD CONSTRAINT uk_9j6xjgegveyc0uqs506yy2wrp UNIQUE (locale);


--
-- Name: metadataversion uk_9k7bv5o2ut4t0unxcwfyf1ay0; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.metadataversion
    ADD CONSTRAINT uk_9k7bv5o2ut4t0unxcwfyf1ay0 UNIQUE (code);


--
-- Name: attribute uk_9mqbhximifdn1n8ru52lan3fw; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.attribute
    ADD CONSTRAINT uk_9mqbhximifdn1n8ru52lan3fw UNIQUE (uid);


--
-- Name: validationrule uk_9ut6k8m3216v5kjcryy7d2y9w; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrule
    ADD CONSTRAINT uk_9ut6k8m3216v5kjcryy7d2y9w UNIQUE (name);


--
-- Name: programstageinstance uk_9ydk6ypaj0xdjoyo1d5asap3m; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstance
    ADD CONSTRAINT uk_9ydk6ypaj0xdjoyo1d5asap3m UNIQUE (code);


--
-- Name: section uk_a50otc0l2chm0heii6scpit4k; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT uk_a50otc0l2chm0heii6scpit4k UNIQUE (uid);


--
-- Name: indicatorgroupset uk_actuoxkkqulslxjpj5hagib9r; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroupset
    ADD CONSTRAINT uk_actuoxkkqulslxjpj5hagib9r UNIQUE (code);


--
-- Name: trackedentityinstancefilter uk_acvg948kspicwqw3gmg4ehu8i; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityinstancefilter
    ADD CONSTRAINT uk_acvg948kspicwqw3gmg4ehu8i UNIQUE (code);


--
-- Name: optiongroupset uk_aee54nmg1ci2cpitnpiwa845p; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroupset
    ADD CONSTRAINT uk_aee54nmg1ci2cpitnpiwa845p UNIQUE (name);


--
-- Name: dataelementgroup uk_aqbaj76r9qxmnylr6p8kj9g37; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroup
    ADD CONSTRAINT uk_aqbaj76r9qxmnylr6p8kj9g37 UNIQUE (name);


--
-- Name: constant uk_aygjfui3fpgrsxbj6qj782h6f; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.constant
    ADD CONSTRAINT uk_aygjfui3fpgrsxbj6qj782h6f UNIQUE (shortname);


--
-- Name: dataset uk_ayk5ey2r1fh1akknxtpcpyp9r; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT uk_ayk5ey2r1fh1akknxtpcpyp9r UNIQUE (uid);


--
-- Name: relationshiptype uk_aypbls80uca5qu23w4fbqns2f; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshiptype
    ADD CONSTRAINT uk_aypbls80uca5qu23w4fbqns2f UNIQUE (to_relationshipconstraintid);


--
-- Name: dataelementcategory uk_b0ii4jdfy88pffbapohsr2lor; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementcategory
    ADD CONSTRAINT uk_b0ii4jdfy88pffbapohsr2lor UNIQUE (name);


--
-- Name: programstage uk_b3oan3noe4cj9dvyi0amofndv; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstage
    ADD CONSTRAINT uk_b3oan3noe4cj9dvyi0amofndv UNIQUE (uid);


--
-- Name: predictorgroup uk_biaq93npnr9ho37lxo51sbt3b; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictorgroup
    ADD CONSTRAINT uk_biaq93npnr9ho37lxo51sbt3b UNIQUE (code);


--
-- Name: categoryoptiongroupset uk_bjs0n874pj6eoag98jmeidy9a; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupset
    ADD CONSTRAINT uk_bjs0n874pj6eoag98jmeidy9a UNIQUE (code);


--
-- Name: maplegendset uk_bv71u83esume24hp4gsaj5p4f; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.maplegendset
    ADD CONSTRAINT uk_bv71u83esume24hp4gsaj5p4f UNIQUE (code);


--
-- Name: dataapprovalworkflow uk_by4pqq1ans00ffmrgqqh9ehog; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalworkflow
    ADD CONSTRAINT uk_by4pqq1ans00ffmrgqqh9ehog UNIQUE (uid);


--
-- Name: dashboarditem uk_c8bnosb06cchme5sig7b54uot; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem
    ADD CONSTRAINT uk_c8bnosb06cchme5sig7b54uot UNIQUE (code);


--
-- Name: externalfileresource uk_ccwoighljmk4fy165ipnwl5n4; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.externalfileresource
    ADD CONSTRAINT uk_ccwoighljmk4fy165ipnwl5n4 UNIQUE (uid);


--
-- Name: datastatistics uk_cswvqawieb2sfq5qsy5wpqp1k; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datastatistics
    ADD CONSTRAINT uk_cswvqawieb2sfq5qsy5wpqp1k UNIQUE (code);


--
-- Name: programrulevariable uk_cto4jvd9q49voite13v0egy3i; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programrulevariable
    ADD CONSTRAINT uk_cto4jvd9q49voite13v0egy3i UNIQUE (code);


--
-- Name: programinstance uk_d3lsa2h8me94ksyp53l6rpe3g; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programinstance
    ADD CONSTRAINT uk_d3lsa2h8me94ksyp53l6rpe3g UNIQUE (uid);


--
-- Name: metadataversion uk_d3qpxp187x8t4c1rsn64crgqu; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.metadataversion
    ADD CONSTRAINT uk_d3qpxp187x8t4c1rsn64crgqu UNIQUE (hashcode);


--
-- Name: externalfileresource uk_d4gp8a84gn643g0r28hdnn4so; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.externalfileresource
    ADD CONSTRAINT uk_d4gp8a84gn643g0r28hdnn4so UNIQUE (fileresourceid);


--
-- Name: dataentryform uk_dhl0qt8y7hht7krbiym1e9x3n; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataentryform
    ADD CONSTRAINT uk_dhl0qt8y7hht7krbiym1e9x3n UNIQUE (code);


--
-- Name: categorycombo uk_dlhi39gmt2e0dun73f04w7w7u; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorycombo
    ADD CONSTRAINT uk_dlhi39gmt2e0dun73f04w7w7u UNIQUE (uid);


--
-- Name: programindicator uk_do17h5nk71uvc3xjry6kgevj9; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicator
    ADD CONSTRAINT uk_do17h5nk71uvc3xjry6kgevj9 UNIQUE (code);


--
-- Name: systemsetting uk_do99wgsyk5wflbhb937u5av8m; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.systemsetting
    ADD CONSTRAINT uk_do99wgsyk5wflbhb937u5av8m UNIQUE (name);


--
-- Name: optiongroup uk_dt8m81o2pw5p9ttid369e92bg; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroup
    ADD CONSTRAINT uk_dt8m81o2pw5p9ttid369e92bg UNIQUE (code);


--
-- Name: programrulevariable uk_e5mhmtj1h7xdfiio2panhapgg; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programrulevariable
    ADD CONSTRAINT uk_e5mhmtj1h7xdfiio2panhapgg UNIQUE (uid);


--
-- Name: programstage uk_e6s6o9jau6tx04m62t7ey4i81; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstage
    ADD CONSTRAINT uk_e6s6o9jau6tx04m62t7ey4i81 UNIQUE (code);


--
-- Name: maplegendset uk_ec7ehyocpresxxhm7yjstdnwt; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.maplegendset
    ADD CONSTRAINT uk_ec7ehyocpresxxhm7yjstdnwt UNIQUE (uid);


--
-- Name: constant uk_edy7cktu2fqg01r3n0fjyk1kk; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.constant
    ADD CONSTRAINT uk_edy7cktu2fqg01r3n0fjyk1kk UNIQUE (code);


--
-- Name: fileresource uk_eh2epuhchf9mci86ihl06i31g; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.fileresource
    ADD CONSTRAINT uk_eh2epuhchf9mci86ihl06i31g UNIQUE (uid);


--
-- Name: trackedentityattribute uk_eh4c3whbwi94nhh772q6l5t7m; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattribute
    ADD CONSTRAINT uk_eh4c3whbwi94nhh772q6l5t7m UNIQUE (code);


--
-- Name: organisationunit uk_ehl4v33tq7hlkmc28vbno1b4n; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.organisationunit
    ADD CONSTRAINT uk_ehl4v33tq7hlkmc28vbno1b4n UNIQUE (code);


--
-- Name: usergroup uk_ekb018cvmpvll5dgtn97leerj; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usergroup
    ADD CONSTRAINT uk_ekb018cvmpvll5dgtn97leerj UNIQUE (uid);


--
-- Name: document uk_elt3kiqdmmm5fwqfxsxk9lvh0; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT uk_elt3kiqdmmm5fwqfxsxk9lvh0 UNIQUE (code);


--
-- Name: keyjsonvalue uk_em6b7qxcas7dn6y506i3nd2x6; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.keyjsonvalue
    ADD CONSTRAINT uk_em6b7qxcas7dn6y506i3nd2x6 UNIQUE (uid);


--
-- Name: version uk_emoyyyy114ofh6cwo6do8xsi0; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.version
    ADD CONSTRAINT uk_emoyyyy114ofh6cwo6do8xsi0 UNIQUE (versionkey);


--
-- Name: dashboard uk_emyh4fed0f1kknqhimmrhnek8; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboard
    ADD CONSTRAINT uk_emyh4fed0f1kknqhimmrhnek8 UNIQUE (code);


--
-- Name: predictor uk_enhquk04unrpri78inaske3jq; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictor
    ADD CONSTRAINT uk_enhquk04unrpri78inaske3jq UNIQUE (uid);


--
-- Name: eventreport uk_eqd95mucf5pd856dqlwe6y36c; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport
    ADD CONSTRAINT uk_eqd95mucf5pd856dqlwe6y36c UNIQUE (code);


--
-- Name: smscommandspecialcharacters uk_etm1elt7pbwyia8e0kfnrvqo3; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscommandspecialcharacters
    ADD CONSTRAINT uk_etm1elt7pbwyia8e0kfnrvqo3 UNIQUE (specialcharacterid);


--
-- Name: trackedentityattribute uk_evp7d8obarxt3kewepigkwahc; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattribute
    ADD CONSTRAINT uk_evp7d8obarxt3kewepigkwahc UNIQUE (name);


--
-- Name: programindicatorgroup uk_f7wfef3jx1yl73stqs7b45ewb; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicatorgroup
    ADD CONSTRAINT uk_f7wfef3jx1yl73stqs7b45ewb UNIQUE (code);


--
-- Name: metadataversion uk_f93o7l4afmkassm3t4f2op9ps; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.metadataversion
    ADD CONSTRAINT uk_f93o7l4afmkassm3t4f2op9ps UNIQUE (name);


--
-- Name: programruleaction uk_fbferisvig2o4f5owb5lnygf3; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programruleaction
    ADD CONSTRAINT uk_fbferisvig2o4f5owb5lnygf3 UNIQUE (code);


--
-- Name: userrole uk_ff1da38in40mg91rlgqhw02ff; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userrole
    ADD CONSTRAINT uk_ff1da38in40mg91rlgqhw02ff UNIQUE (uid);


--
-- Name: sqlview uk_fps2ja521pudngaitlp0805du; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.sqlview
    ADD CONSTRAINT uk_fps2ja521pudngaitlp0805du UNIQUE (uid);


--
-- Name: orgunitgroupset uk_fuentbuhbbr0ix49td9jqlfe5; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupset
    ADD CONSTRAINT uk_fuentbuhbbr0ix49td9jqlfe5 UNIQUE (uid);


--
-- Name: program uk_fuq6kda6folarp19oggaf02vb; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT uk_fuq6kda6folarp19oggaf02vb UNIQUE (code);


--
-- Name: orgunitlevel uk_fvgc7isaflcan55g51ysm9df2; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitlevel
    ADD CONSTRAINT uk_fvgc7isaflcan55g51ysm9df2 UNIQUE (code);


--
-- Name: oauth2client uk_fx3xx9xe0xpurjt6v5p7rv8da; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.oauth2client
    ADD CONSTRAINT uk_fx3xx9xe0xpurjt6v5p7rv8da UNIQUE (uid);


--
-- Name: organisationunit uk_g1nrfjv5x04ap1ceohiwah380; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.organisationunit
    ADD CONSTRAINT uk_g1nrfjv5x04ap1ceohiwah380 UNIQUE (uid);


--
-- Name: oauth2client uk_gdfuf3j66jxnvwwnksjxqysac; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.oauth2client
    ADD CONSTRAINT uk_gdfuf3j66jxnvwwnksjxqysac UNIQUE (code);


--
-- Name: categoryoptiongroup uk_ge3y4pf6qlne9p7rfmhlvg941; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroup
    ADD CONSTRAINT uk_ge3y4pf6qlne9p7rfmhlvg941 UNIQUE (code);


--
-- Name: trackedentityattribute uk_gg9gc0pyaqjuxi8mr4y93i03w; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattribute
    ADD CONSTRAINT uk_gg9gc0pyaqjuxi8mr4y93i03w UNIQUE (shortname);


--
-- Name: relationshiptype uk_gio4nn8l23jikmebud3jwql43; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshiptype
    ADD CONSTRAINT uk_gio4nn8l23jikmebud3jwql43 UNIQUE (code);


--
-- Name: userinfo uk_gky85ptfkcumyuqhr5yvjxwsa; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userinfo
    ADD CONSTRAINT uk_gky85ptfkcumyuqhr5yvjxwsa UNIQUE (code);


--
-- Name: map uk_grp9b5jne53f806pc92sfd5s8; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.map
    ADD CONSTRAINT uk_grp9b5jne53f806pc92sfd5s8 UNIQUE (uid);


--
-- Name: relationship uk_gsvll3t3tsda7kx38waqnegkw; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationship
    ADD CONSTRAINT uk_gsvll3t3tsda7kx38waqnegkw UNIQUE (from_relationshipitemid);


--
-- Name: programstageinstance uk_gy44hufdeduoma7eeh3j6abm7; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstance
    ADD CONSTRAINT uk_gy44hufdeduoma7eeh3j6abm7 UNIQUE (uid);


--
-- Name: program uk_h4omjcs2ktifdrf2m36u886ae; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT uk_h4omjcs2ktifdrf2m36u886ae UNIQUE (uid);


--
-- Name: categorycombo uk_h97pko7n41oky8pfptkflp8l6; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorycombo
    ADD CONSTRAINT uk_h97pko7n41oky8pfptkflp8l6 UNIQUE (name);


--
-- Name: userrole uk_hebhkhm8gpwg9xsp8q4f7wlx1; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userrole
    ADD CONSTRAINT uk_hebhkhm8gpwg9xsp8q4f7wlx1 UNIQUE (code);


--
-- Name: userrole uk_hjocbvo9fla04bgj7ku32vwsn; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userrole
    ADD CONSTRAINT uk_hjocbvo9fla04bgj7ku32vwsn UNIQUE (name);


--
-- Name: attribute uk_hpwum0iq12fs4ej5d0tgy6wsn; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.attribute
    ADD CONSTRAINT uk_hpwum0iq12fs4ej5d0tgy6wsn UNIQUE (name);


--
-- Name: dataapprovallevel uk_hqekpuhjg3g4k4t7xdnu10jy4; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovallevel
    ADD CONSTRAINT uk_hqekpuhjg3g4k4t7xdnu10jy4 UNIQUE (orgunitlevel, categoryoptiongroupsetid);


--
-- Name: orgunitgroupset uk_hs57i9hma97ps6jpsrbb24lm9; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupset
    ADD CONSTRAINT uk_hs57i9hma97ps6jpsrbb24lm9 UNIQUE (code);


--
-- Name: dataapprovallevel uk_i1uhc0c8jgxkhlswl9fujsicf; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovallevel
    ADD CONSTRAINT uk_i1uhc0c8jgxkhlswl9fujsicf UNIQUE (uid);


--
-- Name: predictorgroup uk_i4dix5cj64521ivv59c0wgvfq; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictorgroup
    ADD CONSTRAINT uk_i4dix5cj64521ivv59c0wgvfq UNIQUE (uid);


--
-- Name: maplegend uk_id4stsb5slq35axmjeojnjnoa; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.maplegend
    ADD CONSTRAINT uk_id4stsb5slq35axmjeojnjnoa UNIQUE (code);


--
-- Name: sqlview uk_iedy6hh42wl3gr3m87ntd6so8; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.sqlview
    ADD CONSTRAINT uk_iedy6hh42wl3gr3m87ntd6so8 UNIQUE (name);


--
-- Name: jobconfiguration uk_igo4gx1d74k7m93vxnn4n77jf; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.jobconfiguration
    ADD CONSTRAINT uk_igo4gx1d74k7m93vxnn4n77jf UNIQUE (code);


--
-- Name: messageconversation_usermessages uk_j5pi1qwi2m228qrsxql48o61s; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.messageconversation_usermessages
    ADD CONSTRAINT uk_j5pi1qwi2m228qrsxql48o61s UNIQUE (usermessageid);


--
-- Name: categoryoptiongroup uk_j9oya1t1tvj8yn5h8fega4ltr; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroup
    ADD CONSTRAINT uk_j9oya1t1tvj8yn5h8fega4ltr UNIQUE (name);


--
-- Name: dataelement uk_jc27pe1xeptws5xprct7mgxrj; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelement
    ADD CONSTRAINT uk_jc27pe1xeptws5xprct7mgxrj UNIQUE (shortname);


--
-- Name: datasetnotificationtemplate uk_jjt6ctp2xi4d7vtv4pwkkdhh0; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetnotificationtemplate
    ADD CONSTRAINT uk_jjt6ctp2xi4d7vtv4pwkkdhh0 UNIQUE (uid);


--
-- Name: dataelementgroup uk_jo65jc3wyrxfekiu3upk80mtr; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroup
    ADD CONSTRAINT uk_jo65jc3wyrxfekiu3upk80mtr UNIQUE (code);


--
-- Name: program_attribute_group uk_ju40npt2p0kglya4e5041b4qc; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program_attribute_group
    ADD CONSTRAINT uk_ju40npt2p0kglya4e5041b4qc UNIQUE (uid);


--
-- Name: document uk_jxodv1lvot26euasttk021jio; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT uk_jxodv1lvot26euasttk021jio UNIQUE (uid);


--
-- Name: fileresource uk_jxqj907hbrng860p6mypvl63k; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.fileresource
    ADD CONSTRAINT uk_jxqj907hbrng860p6mypvl63k UNIQUE (storagekey);


--
-- Name: interpretation_comments uk_k48tayhxu52jiq782pikev9d9; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretation_comments
    ADD CONSTRAINT uk_k48tayhxu52jiq782pikev9d9 UNIQUE (interpretationcommentid);


--
-- Name: trackedentityattribute uk_kbqnrdakcjfooofmti30d4p8x; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattribute
    ADD CONSTRAINT uk_kbqnrdakcjfooofmti30d4p8x UNIQUE (uid);


--
-- Name: report uk_kc1wmcky1ooleovi36oqcqmqe; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.report
    ADD CONSTRAINT uk_kc1wmcky1ooleovi36oqcqmqe UNIQUE (code);


--
-- Name: categoryoptiongroupset uk_ke8p30sy68dl7fggednkimdb6; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupset
    ADD CONSTRAINT uk_ke8p30sy68dl7fggednkimdb6 UNIQUE (name);


--
-- Name: indicator uk_kmpefoaw81v4bxpoey6y1y3xl; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicator
    ADD CONSTRAINT uk_kmpefoaw81v4bxpoey6y1y3xl UNIQUE (code);


--
-- Name: indicatorgroup uk_kqbwxccoqctky1kdkimjya03s; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroup
    ADD CONSTRAINT uk_kqbwxccoqctky1kdkimjya03s UNIQUE (uid);


--
-- Name: i18nlocale uk_krm9w69donjqsejkmfw17jbcx; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.i18nlocale
    ADD CONSTRAINT uk_krm9w69donjqsejkmfw17jbcx UNIQUE (code);


--
-- Name: metadataversion uk_ktwf16f728hce9ahtpmm7w5lx; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.metadataversion
    ADD CONSTRAINT uk_ktwf16f728hce9ahtpmm7w5lx UNIQUE (uid);


--
-- Name: program_attributes uk_lgju00pi2jk7y6sl4dkhaykux; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program_attributes
    ADD CONSTRAINT uk_lgju00pi2jk7y6sl4dkhaykux UNIQUE (uid);


--
-- Name: externalnotificationlogentry uk_lner1ovmrqr5qrwn8gwfuhhhn; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.externalnotificationlogentry
    ADD CONSTRAINT uk_lner1ovmrqr5qrwn8gwfuhhhn UNIQUE (uid);


--
-- Name: eventreport uk_lnnx8vmalkhkmneryv1ytjq68; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport
    ADD CONSTRAINT uk_lnnx8vmalkhkmneryv1ytjq68 UNIQUE (uid);


--
-- Name: categoryoptiongroup uk_lrnagoy2wi83nwmataolh7t6d; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroup
    ADD CONSTRAINT uk_lrnagoy2wi83nwmataolh7t6d UNIQUE (shortname);


--
-- Name: orgunitgroup uk_lswbn93sime7vmdqqe9lks7ge; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroup
    ADD CONSTRAINT uk_lswbn93sime7vmdqqe9lks7ge UNIQUE (uid);


--
-- Name: orgunitlevel uk_ltwhby0s0iwayxrcdu6yefeqt; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitlevel
    ADD CONSTRAINT uk_ltwhby0s0iwayxrcdu6yefeqt UNIQUE (level);


--
-- Name: dataelementgroupset uk_lu295rc1y01c7p7t76y6ajaas; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupset
    ADD CONSTRAINT uk_lu295rc1y01c7p7t76y6ajaas UNIQUE (uid);


--
-- Name: programinstancecomments uk_lwep604j10w1ey7vunqdmotx2; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programinstancecomments
    ADD CONSTRAINT uk_lwep604j10w1ey7vunqdmotx2 UNIQUE (trackedentitycommentid);


--
-- Name: programstagesection uk_lycal9jdw3cs0wwebxciswwgr; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagesection
    ADD CONSTRAINT uk_lycal9jdw3cs0wwebxciswwgr UNIQUE (uid);


--
-- Name: trackedentityinstancefilter uk_m5k30j5e93n1no82gye7jgf25; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityinstancefilter
    ADD CONSTRAINT uk_m5k30j5e93n1no82gye7jgf25 UNIQUE (uid);


--
-- Name: validationnotificationtemplate uk_mbt1vxa5exs9cbqqs5px2mopx; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationnotificationtemplate
    ADD CONSTRAINT uk_mbt1vxa5exs9cbqqs5px2mopx UNIQUE (uid);


--
-- Name: externalnotificationlogentry uk_mcn0op3hsf5ajqg5k4oli4xkc; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.externalnotificationlogentry
    ADD CONSTRAINT uk_mcn0op3hsf5ajqg5k4oli4xkc UNIQUE (key);


--
-- Name: dataelementcategoryoption uk_mlop2afk26fwowa69lr9a138y; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementcategoryoption
    ADD CONSTRAINT uk_mlop2afk26fwowa69lr9a138y UNIQUE (code);


--
-- Name: datasetnotificationtemplate uk_mq0y6uuq2erprg2siebo2mk1o; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetnotificationtemplate
    ADD CONSTRAINT uk_mq0y6uuq2erprg2siebo2mk1o UNIQUE (code);


--
-- Name: dashboard uk_myox13mr8r27oxl7ts33ntpd5; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboard
    ADD CONSTRAINT uk_myox13mr8r27oxl7ts33ntpd5 UNIQUE (uid);


--
-- Name: dataapprovalworkflow uk_n18s4feicujvngv2ajoesdgio; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalworkflow
    ADD CONSTRAINT uk_n18s4feicujvngv2ajoesdgio UNIQUE (name);


--
-- Name: indicatorgroupset uk_n4xputyk31femiaxls6lbl2rw; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroupset
    ADD CONSTRAINT uk_n4xputyk31femiaxls6lbl2rw UNIQUE (uid);


--
-- Name: pushanalysis uk_n5ax669vkj63nx3rrvlushqdm; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.pushanalysis
    ADD CONSTRAINT uk_n5ax669vkj63nx3rrvlushqdm UNIQUE (code);


--
-- Name: indicatortype uk_n8mbmryeksa80ucyxj0vg6p9b; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatortype
    ADD CONSTRAINT uk_n8mbmryeksa80ucyxj0vg6p9b UNIQUE (name);


--
-- Name: oauth2client uk_ni7epmbxtn4jcax3ya324ff9w; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.oauth2client
    ADD CONSTRAINT uk_ni7epmbxtn4jcax3ya324ff9w UNIQUE (cid);


--
-- Name: optiongroup uk_nipo7t010a80osh7okxswav2g; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroup
    ADD CONSTRAINT uk_nipo7t010a80osh7okxswav2g UNIQUE (uid);


--
-- Name: messageconversation_messages uk_nqdtggpr548q0tnbu919puw0p; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.messageconversation_messages
    ADD CONSTRAINT uk_nqdtggpr548q0tnbu919puw0p UNIQUE (messageid);


--
-- Name: oauth2client uk_nwgvrevv2slj1bvc9m01p89lf; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.oauth2client
    ADD CONSTRAINT uk_nwgvrevv2slj1bvc9m01p89lf UNIQUE (name);


--
-- Name: optiongroup uk_nwq3y4xqct21tdl0l77bvmpoe; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroup
    ADD CONSTRAINT uk_nwq3y4xqct21tdl0l77bvmpoe UNIQUE (shortname);


--
-- Name: constant uk_nywvip5682tuvxrnwjomeyg6y; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.constant
    ADD CONSTRAINT uk_nywvip5682tuvxrnwjomeyg6y UNIQUE (uid);


--
-- Name: predictor uk_o0v1fdqiyte40ffm9q3nhcj4v; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictor
    ADD CONSTRAINT uk_o0v1fdqiyte40ffm9q3nhcj4v UNIQUE (code);


--
-- Name: constant uk_o2xbcli806eba6dkdfco0o3kc; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.constant
    ADD CONSTRAINT uk_o2xbcli806eba6dkdfco0o3kc UNIQUE (name);


--
-- Name: dataset uk_oeni5ndit5g033f1s1j08bdry; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT uk_oeni5ndit5g033f1s1j08bdry UNIQUE (code);


--
-- Name: categoryoptiongroup uk_ol8n7oq6clgxvqjedlpn85aqo; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroup
    ADD CONSTRAINT uk_ol8n7oq6clgxvqjedlpn85aqo UNIQUE (uid);


--
-- Name: trackedentityinstance uk_orq3pwtro2yu9yydh046bn40j; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityinstance
    ADD CONSTRAINT uk_orq3pwtro2yu9yydh046bn40j UNIQUE (code);


--
-- Name: programstagedataelement uk_os4r1umsvtmbuqm2bo25s5ej0; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagedataelement
    ADD CONSTRAINT uk_os4r1umsvtmbuqm2bo25s5ej0 UNIQUE (uid);


--
-- Name: programnotificationtemplate uk_ot8a05g9d4k5l67xi062xx5w6; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programnotificationtemplate
    ADD CONSTRAINT uk_ot8a05g9d4k5l67xi062xx5w6 UNIQUE (code);


--
-- Name: dataelementgroup uk_otvwcgv4bxjtqfj3flhrnmgf7; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroup
    ADD CONSTRAINT uk_otvwcgv4bxjtqfj3flhrnmgf7 UNIQUE (uid);


--
-- Name: indicatortype uk_p0p3bwhgbsdemu14v23p47qne; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatortype
    ADD CONSTRAINT uk_p0p3bwhgbsdemu14v23p47qne UNIQUE (uid);


--
-- Name: optionset uk_p0rvldurcmk0x3mx39lt5uvsd; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optionset
    ADD CONSTRAINT uk_p0rvldurcmk0x3mx39lt5uvsd UNIQUE (name);


--
-- Name: programrule uk_p7arcbl58mmcrj2didtr0ruqh; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programrule
    ADD CONSTRAINT uk_p7arcbl58mmcrj2didtr0ruqh UNIQUE (uid);


--
-- Name: dataelementgroupset uk_p7egnv3sj4ugyl23mk4vga40k; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupset
    ADD CONSTRAINT uk_p7egnv3sj4ugyl23mk4vga40k UNIQUE (code);


--
-- Name: dataentryform uk_p8tvo9tqrdn5tb45d0g5cko5o; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataentryform
    ADD CONSTRAINT uk_p8tvo9tqrdn5tb45d0g5cko5o UNIQUE (name);


--
-- Name: dataelementcategoryoption uk_pbj3u1nk9vnuof8f47utvowmv; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementcategoryoption
    ADD CONSTRAINT uk_pbj3u1nk9vnuof8f47utvowmv UNIQUE (name);


--
-- Name: datastatistics uk_ppi146eky8fodu97t1o21vkd8; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datastatistics
    ADD CONSTRAINT uk_ppi146eky8fodu97t1o21vkd8 UNIQUE (uid);


--
-- Name: programstageinstancefilter uk_programstageinstancefilter_uid; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstancefilter
    ADD CONSTRAINT uk_programstageinstancefilter_uid UNIQUE (uid);


--
-- Name: organisationunit uk_pw2bgc9ykjad2obefeqha28t4; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.organisationunit
    ADD CONSTRAINT uk_pw2bgc9ykjad2obefeqha28t4 UNIQUE (path);


--
-- Name: dataelementcategory uk_pw87bi64e3ev11k7dwrmljo78; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementcategory
    ADD CONSTRAINT uk_pw87bi64e3ev11k7dwrmljo78 UNIQUE (code);


--
-- Name: predictorgroup uk_pxnxtb4ywoh2m74vosk2httc3; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictorgroup
    ADD CONSTRAINT uk_pxnxtb4ywoh2m74vosk2httc3 UNIQUE (name);


--
-- Name: dataentryform uk_q0obvr5rvxhlnjs367y1f0bav; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataentryform
    ADD CONSTRAINT uk_q0obvr5rvxhlnjs367y1f0bav UNIQUE (uid);


--
-- Name: eventreport uk_q0oyainj1lis9c8kkh5sky2ri; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventreport
    ADD CONSTRAINT uk_q0oyainj1lis9c8kkh5sky2ri UNIQUE (relativeperiodsid);


--
-- Name: usergroup uk_q20sh82vk885ooi7fekwtboej; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usergroup
    ADD CONSTRAINT uk_q20sh82vk885ooi7fekwtboej UNIQUE (code);


--
-- Name: optiongroupset uk_q9jv2e3fy49hc1havuwnr0res; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroupset
    ADD CONSTRAINT uk_q9jv2e3fy49hc1havuwnr0res UNIQUE (code);


--
-- Name: categoryoptioncombo uk_qki43s9vdndg15c9tyv718u1j; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptioncombo
    ADD CONSTRAINT uk_qki43s9vdndg15c9tyv718u1j UNIQUE (uid);


--
-- Name: i18nlocale uk_qogg9a7yy4qconomxt4j4upql; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.i18nlocale
    ADD CONSTRAINT uk_qogg9a7yy4qconomxt4j4upql UNIQUE (name);


--
-- Name: dataelementcategoryoption uk_qp9201a4m6jl53sei0huh4l6s; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementcategoryoption
    ADD CONSTRAINT uk_qp9201a4m6jl53sei0huh4l6s UNIQUE (shortname);


--
-- Name: relationshiptype uk_qq5b8o288bhpe59e5ks3op8jy; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshiptype
    ADD CONSTRAINT uk_qq5b8o288bhpe59e5ks3op8jy UNIQUE (from_relationshipconstraintid);


--
-- Name: pushanalysis uk_qunv1hucv9wi5pt92tur929mr; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.pushanalysis
    ADD CONSTRAINT uk_qunv1hucv9wi5pt92tur929mr UNIQUE (uid);


--
-- Name: orgunitgroup uk_qwk9qdapql867enp5r7fa0uic; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroup
    ADD CONSTRAINT uk_qwk9qdapql867enp5r7fa0uic UNIQUE (name);


--
-- Name: program_attributes uk_r2f9o8i6th2w8vqdexdfo72ui; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program_attributes
    ADD CONSTRAINT uk_r2f9o8i6th2w8vqdexdfo72ui UNIQUE (code);


--
-- Name: externalmaplayer uk_r3ugbbibdsyn234isip3346v4; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.externalmaplayer
    ADD CONSTRAINT uk_r3ugbbibdsyn234isip3346v4 UNIQUE (code);


--
-- Name: validationresult uk_r6ebedjcac8c49c53aa1mpa8e; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationresult
    ADD CONSTRAINT uk_r6ebedjcac8c49c53aa1mpa8e UNIQUE (validationruleid, periodid, organisationunitid, attributeoptioncomboid, dayinperiod);


--
-- Name: trackedentityinstance uk_rbr4kyuk4s0kb4jo1r77cuaq9; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityinstance
    ADD CONSTRAINT uk_rbr4kyuk4s0kb4jo1r77cuaq9 UNIQUE (uid);


--
-- Name: jobconfiguration uk_rqkhk3ebvk1kflf7qigbaxeyp; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.jobconfiguration
    ADD CONSTRAINT uk_rqkhk3ebvk1kflf7qigbaxeyp UNIQUE (name);


--
-- Name: optionset uk_rvfiukug5ui7qidoiln3el3aa; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optionset
    ADD CONSTRAINT uk_rvfiukug5ui7qidoiln3el3aa UNIQUE (code);


--
-- Name: periodboundary uk_sbipy5btkgy542bdbx7mxppdd; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.periodboundary
    ADD CONSTRAINT uk_sbipy5btkgy542bdbx7mxppdd UNIQUE (code);


--
-- Name: jobconfiguration uk_sdng31h9qjawcikcllry8a8a5; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.jobconfiguration
    ADD CONSTRAINT uk_sdng31h9qjawcikcllry8a8a5 UNIQUE (uid);


--
-- Name: indicatorgroup uk_sspviu4m0l0lf7ef3t3cagfxd; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroup
    ADD CONSTRAINT uk_sspviu4m0l0lf7ef3t3cagfxd UNIQUE (code);


--
-- Name: validationrule uk_t0dg39dopew9f6y64ucsx7194; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrule
    ADD CONSTRAINT uk_t0dg39dopew9f6y64ucsx7194 UNIQUE (uid);


--
-- Name: orgunitgroup uk_t0srkng3akwg3pcp5qlwcx06n; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroup
    ADD CONSTRAINT uk_t0srkng3akwg3pcp5qlwcx06n UNIQUE (shortname);


--
-- Name: orgunitgroupset uk_t5lxvc1km3ylon5st1fuabsgl; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupset
    ADD CONSTRAINT uk_t5lxvc1km3ylon5st1fuabsgl UNIQUE (name);


--
-- Name: trackedentitycomment uk_t94h9p111tcydbm6je22tla52; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitycomment
    ADD CONSTRAINT uk_t94h9p111tcydbm6je22tla52 UNIQUE (uid);


--
-- Name: smscommandcodes uk_t9e1mnpydje0rsvinxq68q1i6; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscommandcodes
    ADD CONSTRAINT uk_t9e1mnpydje0rsvinxq68q1i6 UNIQUE (codeid);


--
-- Name: indicator uk_ta80keoi67443tkvvmx8l872x; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicator
    ADD CONSTRAINT uk_ta80keoi67443tkvvmx8l872x UNIQUE (uid);


--
-- Name: programnotificationinstance uk_takpuhb2893t7bbbak9ym3kq9; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programnotificationinstance
    ADD CONSTRAINT uk_takpuhb2893t7bbbak9ym3kq9 UNIQUE (uid);


--
-- Name: period uk_tbkbjga8h4j5u33d7hbcuk66t; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.period
    ADD CONSTRAINT uk_tbkbjga8h4j5u33d7hbcuk66t UNIQUE (periodtypeid, startdate, enddate);


--
-- Name: trackedentityprogramowner uk_tei_program; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityprogramowner
    ADD CONSTRAINT uk_tei_program UNIQUE (trackedentityinstanceid, programid);


--
-- Name: programsection uk_tglbwfy1e3ubt5x5hab46qbh6; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programsection
    ADD CONSTRAINT uk_tglbwfy1e3ubt5x5hab46qbh6 UNIQUE (code);


--
-- Name: trackedentitytype uk_thb8irn2kmm7jay3vcogqxy3x; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitytype
    ADD CONSTRAINT uk_thb8irn2kmm7jay3vcogqxy3x UNIQUE (name);


--
-- Name: keyjsonvalue uk_tikknlgl0im3w68yvlb0swrgd; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.keyjsonvalue
    ADD CONSTRAINT uk_tikknlgl0im3w68yvlb0swrgd UNIQUE (code);


--
-- Name: trackedentitytype uk_to3d8d23u9behgh9acdu2wjvl; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitytype
    ADD CONSTRAINT uk_to3d8d23u9behgh9acdu2wjvl UNIQUE (code);


--
-- Name: userinfo uk_userinfo_username; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userinfo
    ADD CONSTRAINT uk_userinfo_username UNIQUE (username);


--
-- Name: predictor unique_generator_expression; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictor
    ADD CONSTRAINT unique_generator_expression UNIQUE (generatorexpressionid);


--
-- Name: validationrule unique_left_expression; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrule
    ADD CONSTRAINT unique_left_expression UNIQUE (leftexpressionid);


--
-- Name: validationrule unique_right_expression; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrule
    ADD CONSTRAINT unique_right_expression UNIQUE (rightexpressionid);


--
-- Name: predictor unique_skip_test_expression; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictor
    ADD CONSTRAINT unique_skip_test_expression UNIQUE (skiptestexpressionid);


--
-- Name: userapps userapps_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userapps
    ADD CONSTRAINT userapps_pkey PRIMARY KEY (userinfoid, sort_order);


--
-- Name: userdatavieworgunits userdatavieworgunits_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userdatavieworgunits
    ADD CONSTRAINT userdatavieworgunits_pkey PRIMARY KEY (userinfoid, organisationunitid);


--
-- Name: usergroup usergroup_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usergroup
    ADD CONSTRAINT usergroup_pkey PRIMARY KEY (usergroupid);


--
-- Name: usergroupmanaged usergroupmanaged_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usergroupmanaged
    ADD CONSTRAINT usergroupmanaged_pkey PRIMARY KEY (managedbygroupid, managedgroupid);


--
-- Name: usergroupmembers usergroupmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usergroupmembers
    ADD CONSTRAINT usergroupmembers_pkey PRIMARY KEY (usergroupid, userid);


--
-- Name: userinfo userinfo_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userinfo
    ADD CONSTRAINT userinfo_pkey PRIMARY KEY (userinfoid);


--
-- Name: userkeyjsonvalue userkeyjsonvalue_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userkeyjsonvalue
    ADD CONSTRAINT userkeyjsonvalue_pkey PRIMARY KEY (userkeyjsonvalueid);


--
-- Name: userkeyjsonvalue userkeyjsonvalue_unique_key_on_user_and_namespace; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userkeyjsonvalue
    ADD CONSTRAINT userkeyjsonvalue_unique_key_on_user_and_namespace UNIQUE (userid, namespace, userkey);


--
-- Name: usermembership usermembership_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usermembership
    ADD CONSTRAINT usermembership_pkey PRIMARY KEY (userinfoid, organisationunitid);


--
-- Name: usermessage usermessage_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usermessage
    ADD CONSTRAINT usermessage_pkey PRIMARY KEY (usermessageid);


--
-- Name: userrole userrole_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userrole
    ADD CONSTRAINT userrole_pkey PRIMARY KEY (userroleid);


--
-- Name: userrolemembers userrolemembers_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userrolemembers
    ADD CONSTRAINT userrolemembers_pkey PRIMARY KEY (userid, userroleid);


--
-- Name: users_catdimensionconstraints users_catdimensionconstraints_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.users_catdimensionconstraints
    ADD CONSTRAINT users_catdimensionconstraints_pkey PRIMARY KEY (userid, dataelementcategoryid);


--
-- Name: users_cogsdimensionconstraints users_cogsdimensionconstraints_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.users_cogsdimensionconstraints
    ADD CONSTRAINT users_cogsdimensionconstraints_pkey PRIMARY KEY (userid, categoryoptiongroupsetid);


--
-- Name: usersetting usersetting_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usersetting
    ADD CONSTRAINT usersetting_pkey PRIMARY KEY (userinfoid, name);


--
-- Name: userteisearchorgunits userteisearchorgunits_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userteisearchorgunits
    ADD CONSTRAINT userteisearchorgunits_pkey PRIMARY KEY (userinfoid, organisationunitid);


--
-- Name: validationnotificationtemplate validationnotificationtemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationnotificationtemplate
    ADD CONSTRAINT validationnotificationtemplate_pkey PRIMARY KEY (validationnotificationtemplateid);


--
-- Name: validationnotificationtemplate_recipientusergroups validationnotificationtemplate_recipientusergroups_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationnotificationtemplate_recipientusergroups
    ADD CONSTRAINT validationnotificationtemplate_recipientusergroups_pkey PRIMARY KEY (validationnotificationtemplateid, usergroupid);


--
-- Name: validationnotificationtemplatevalidationrules validationnotificationtemplatevalidationrules_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationnotificationtemplatevalidationrules
    ADD CONSTRAINT validationnotificationtemplatevalidationrules_pkey PRIMARY KEY (validationnotificationtemplateid, validationruleid);


--
-- Name: validationresult validationresult_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationresult
    ADD CONSTRAINT validationresult_pkey PRIMARY KEY (validationresultid);


--
-- Name: validationrule validationrule_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrule
    ADD CONSTRAINT validationrule_pkey PRIMARY KEY (validationruleid);


--
-- Name: validationrulegroup validationrulegroup_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrulegroup
    ADD CONSTRAINT validationrulegroup_pkey PRIMARY KEY (validationrulegroupid);


--
-- Name: validationrulegroupmembers validationrulegroupmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrulegroupmembers
    ADD CONSTRAINT validationrulegroupmembers_pkey PRIMARY KEY (validationgroupid, validationruleid);


--
-- Name: version version_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.version
    ADD CONSTRAINT version_pkey PRIMARY KEY (versionid);


--
-- Name: version version_versionkey_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.version
    ADD CONSTRAINT version_versionkey_key UNIQUE (versionkey);


--
-- Name: visualization_axis visualization_axis_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_axis
    ADD CONSTRAINT visualization_axis_pkey PRIMARY KEY (visualizationid, sort_order);


--
-- Name: visualization_categorydimensions visualization_categorydimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_categorydimensions
    ADD CONSTRAINT visualization_categorydimensions_pkey PRIMARY KEY (visualizationid, sort_order);


--
-- Name: visualization_categoryoptiongroupsetdimensions visualization_categoryoptiongroupsetdimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_categoryoptiongroupsetdimensions
    ADD CONSTRAINT visualization_categoryoptiongroupsetdimensions_pkey PRIMARY KEY (visualizationid, sort_order);


--
-- Name: visualization visualization_code_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization
    ADD CONSTRAINT visualization_code_key UNIQUE (code);


--
-- Name: visualization_columns visualization_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_columns
    ADD CONSTRAINT visualization_columns_pkey PRIMARY KEY (visualizationid, sort_order);


--
-- Name: visualization_datadimensionitems visualization_datadimensionitems_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_datadimensionitems
    ADD CONSTRAINT visualization_datadimensionitems_pkey PRIMARY KEY (visualizationid, sort_order);


--
-- Name: visualization_dataelementgroupsetdimensions visualization_dataelementgroupsetdimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_dataelementgroupsetdimensions
    ADD CONSTRAINT visualization_dataelementgroupsetdimensions_pkey PRIMARY KEY (visualizationid, sort_order);


--
-- Name: visualization_filters visualization_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_filters
    ADD CONSTRAINT visualization_filters_pkey PRIMARY KEY (visualizationid, sort_order);


--
-- Name: visualization_itemorgunitgroups visualization_itemorgunitgroups_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_itemorgunitgroups
    ADD CONSTRAINT visualization_itemorgunitgroups_pkey PRIMARY KEY (visualizationid, sort_order);


--
-- Name: visualization_organisationunits visualization_organisationunits_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_organisationunits
    ADD CONSTRAINT visualization_organisationunits_pkey PRIMARY KEY (visualizationid, sort_order);


--
-- Name: visualization_orgunitgroupsetdimensions visualization_orgunitgroupsetdimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_orgunitgroupsetdimensions
    ADD CONSTRAINT visualization_orgunitgroupsetdimensions_pkey PRIMARY KEY (visualizationid, sort_order);


--
-- Name: visualization_orgunitlevels visualization_orgunitlevels_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_orgunitlevels
    ADD CONSTRAINT visualization_orgunitlevels_pkey PRIMARY KEY (visualizationid, sort_order);


--
-- Name: visualization_periods visualization_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_periods
    ADD CONSTRAINT visualization_periods_pkey PRIMARY KEY (visualizationid, sort_order);


--
-- Name: visualization visualization_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization
    ADD CONSTRAINT visualization_pkey PRIMARY KEY (visualizationid);


--
-- Name: visualization visualization_relativeperiodsid_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization
    ADD CONSTRAINT visualization_relativeperiodsid_key UNIQUE (relativeperiodsid);


--
-- Name: visualization_rows visualization_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_rows
    ADD CONSTRAINT visualization_rows_pkey PRIMARY KEY (visualizationid, sort_order);


--
-- Name: visualization visualization_uid_key; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization
    ADD CONSTRAINT visualization_uid_key UNIQUE (uid);


--
-- Name: visualization_yearlyseries visualization_yearlyseries_pkey; Type: CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_yearlyseries
    ADD CONSTRAINT visualization_yearlyseries_pkey PRIMARY KEY (visualizationid, sort_order);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- Name: id_datavalueaudit_created; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX id_datavalueaudit_created ON public.datavalueaudit USING btree (created);


--
-- Name: in_categories_categoryoptions_coid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_categories_categoryoptions_coid ON public.categories_categoryoptions USING btree (categoryoptionid, categoryid);


--
-- Name: in_categoryoptioncombo_name; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_categoryoptioncombo_name ON public.categoryoptioncombo USING btree (name);


--
-- Name: in_dataapprovallevel_level; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_dataapprovallevel_level ON public.dataapprovallevel USING btree (level);


--
-- Name: in_datasetsource_sourceid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_datasetsource_sourceid ON public.datasetsource USING btree (sourceid);


--
-- Name: in_datavalue_deleted; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_datavalue_deleted ON public.datavalue USING btree (deleted);


--
-- Name: in_datavalue_lastupdated; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_datavalue_lastupdated ON public.datavalue USING btree (lastupdated);


--
-- Name: in_datavalueaudit; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_datavalueaudit ON public.datavalueaudit USING btree (dataelementid, periodid, organisationunitid, categoryoptioncomboid, attributeoptioncomboid);


--
-- Name: in_interpretation_mentions_username; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_interpretation_mentions_username ON public.interpretation USING gin (((mentions -> 'username'::text)) jsonb_path_ops);


--
-- Name: in_interpretationcomment_mentions_username; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_interpretationcomment_mentions_username ON public.interpretationcomment USING gin (((mentions -> 'username'::text)) jsonb_path_ops);


--
-- Name: in_messageconversation_extmessageid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_messageconversation_extmessageid ON public.messageconversation USING hash (extmessageid);


--
-- Name: in_organisationunit_hierarchylevel; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_organisationunit_hierarchylevel ON public.organisationunit USING btree (hierarchylevel);


--
-- Name: in_organisationunit_path; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_organisationunit_path ON public.organisationunit USING btree (path varchar_pattern_ops);


--
-- Name: in_parentid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_parentid ON public.organisationunit USING btree (parentid);


--
-- Name: in_programinstance_deleted; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_programinstance_deleted ON public.programinstance USING btree (deleted);


--
-- Name: in_programinstance_programid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_programinstance_programid ON public.programinstance USING btree (programid);


--
-- Name: in_programinstance_trackedentityinstanceid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_programinstance_trackedentityinstanceid ON public.programinstance USING btree (trackedentityinstanceid);


--
-- Name: in_programstageinstance_status_executiondate; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_programstageinstance_status_executiondate ON public.programstageinstance USING btree (status, executiondate);


--
-- Name: in_programtempowner_validtill; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_programtempowner_validtill ON public.programtempowner USING btree (date_part('epoch'::text, validtill));


--
-- Name: in_psi_deleted_assigneduserid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_psi_deleted_assigneduserid ON public.programstageinstance USING btree (deleted, assigneduserid);


--
-- Name: in_relationship_inverted_key; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_relationship_inverted_key ON public.relationship USING btree (inverted_key);


--
-- Name: in_relationship_key; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_relationship_key ON public.relationship USING btree (key);


--
-- Name: in_relationshipitem_programinstanceid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_relationshipitem_programinstanceid ON public.relationshipitem USING btree (programinstanceid);


--
-- Name: in_relationshipitem_programstageinstanceid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_relationshipitem_programstageinstanceid ON public.relationshipitem USING btree (programstageinstanceid);


--
-- Name: in_relationshipitem_trackedentityinstanceid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_relationshipitem_trackedentityinstanceid ON public.relationshipitem USING btree (trackedentityinstanceid);


--
-- Name: in_reservedvalue_value_generation; Type: INDEX; Schema: public; Owner: dhis
--

CREATE UNIQUE INDEX in_reservedvalue_value_generation ON public.reservedvalue USING btree (ownerobject, owneruid, key, lower((value)::text));


--
-- Name: in_trackedentity_attribute_value; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_trackedentity_attribute_value ON public.trackedentityattributevalue USING btree (trackedentityattributeid, lower((value)::text));


--
-- Name: in_trackedentityattributevalue_attributeid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_trackedentityattributevalue_attributeid ON public.trackedentityattributevalue USING btree (trackedentityattributeid);


--
-- Name: in_trackedentityinstance_created; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_trackedentityinstance_created ON public.trackedentityinstance USING btree (created);


--
-- Name: in_trackedentityinstance_deleted; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_trackedentityinstance_deleted ON public.trackedentityinstance USING btree (deleted);


--
-- Name: in_trackedentityinstance_organisationunitid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_trackedentityinstance_organisationunitid ON public.trackedentityinstance USING btree (organisationunitid);


--
-- Name: in_trackedentityinstance_trackedentityattribute_value; Type: INDEX; Schema: public; Owner: dhis
--

CREATE UNIQUE INDEX in_trackedentityinstance_trackedentityattribute_value ON public.trackedentityattributevalue USING btree (trackedentityinstanceid, trackedentityattributeid, lower((value)::text));


--
-- Name: in_trackedentityprogramowner_program_orgunit; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX in_trackedentityprogramowner_program_orgunit ON public.trackedentityprogramowner USING btree (programid, organisationunitid);


--
-- Name: in_unique_trackedentityprogramowner_teiid_programid_ouid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE UNIQUE INDEX in_unique_trackedentityprogramowner_teiid_programid_ouid ON public.trackedentityprogramowner USING btree (trackedentityinstanceid, programid, organisationunitid);


--
-- Name: in_userinfo_ldapid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE UNIQUE INDEX in_userinfo_ldapid ON public.userinfo USING btree (ldapid);


--
-- Name: in_userinfo_openid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE UNIQUE INDEX in_userinfo_openid ON public.userinfo USING btree (openid);


--
-- Name: in_userinfo_username; Type: INDEX; Schema: public; Owner: dhis
--

CREATE UNIQUE INDEX in_userinfo_username ON public.userinfo USING btree (username);


--
-- Name: in_userinfo_uuid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE UNIQUE INDEX in_userinfo_uuid ON public.userinfo USING btree (uuid);


--
-- Name: index_programinstance; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX index_programinstance ON public.programinstance USING btree (programinstanceid);


--
-- Name: index_trackedentitydatavalueaudit_programstageinstanceid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX index_trackedentitydatavalueaudit_programstageinstanceid ON public.trackedentitydatavalueaudit USING btree (programstageinstanceid);


--
-- Name: interpretation_lastupdated; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX interpretation_lastupdated ON public.interpretation USING btree (lastupdated);


--
-- Name: maplegend_endvalue; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX maplegend_endvalue ON public.maplegend USING btree (endvalue);


--
-- Name: maplegend_startvalue; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX maplegend_startvalue ON public.maplegend USING btree (startvalue);


--
-- Name: messageconversation_lastmessage; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX messageconversation_lastmessage ON public.messageconversation USING btree (lastmessage);


--
-- Name: outbound_sms_status_index; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX outbound_sms_status_index ON public.outbound_sms USING btree (status);


--
-- Name: programstageinstance_executiondate; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX programstageinstance_executiondate ON public.programstageinstance USING btree (executiondate);


--
-- Name: programstageinstance_organisationunitid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX programstageinstance_organisationunitid ON public.programstageinstance USING btree (organisationunitid);


--
-- Name: programstageinstance_programinstanceid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX programstageinstance_programinstanceid ON public.programstageinstance USING btree (programinstanceid);


--
-- Name: sms_originator_index; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX sms_originator_index ON public.incomingsms USING btree (originator);


--
-- Name: sms_status_index; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX sms_status_index ON public.incomingsms USING btree (status);


--
-- Name: userkeyjsonvalue_user; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX userkeyjsonvalue_user ON public.userkeyjsonvalue USING btree (userid);


--
-- Name: usermessage_isread; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX usermessage_isread ON public.usermessage USING btree (isread);


--
-- Name: usermessage_userid; Type: INDEX; Schema: public; Owner: dhis
--

CREATE INDEX usermessage_userid ON public.usermessage USING btree (userid);


--
-- Name: uuid_usergroup_idx; Type: INDEX; Schema: public; Owner: dhis
--

CREATE UNIQUE INDEX uuid_usergroup_idx ON public.usergroup USING btree (uuid);


--
-- Name: indicatorlegendsets fk1ps7mt73qi3wnt6f5g6w6flga; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorlegendsets
    ADD CONSTRAINT fk1ps7mt73qi3wnt6f5g6w6flga FOREIGN KEY (indicatorid) REFERENCES public.indicator(indicatorid);


--
-- Name: programmessage_phonenumbers fk3408hwfswvwfqyfngk1tf5ju8; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programmessage_phonenumbers
    ADD CONSTRAINT fk3408hwfswvwfqyfngk1tf5ju8 FOREIGN KEY (programmessagephonenumberid) REFERENCES public.programmessage(id);


--
-- Name: programnotificationtemplate_deliverychannel fk45uc7wfpi4u5gunpl127ehkn2; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programnotificationtemplate_deliverychannel
    ADD CONSTRAINT fk45uc7wfpi4u5gunpl127ehkn2 FOREIGN KEY (programnotificationtemplatedeliverychannelid) REFERENCES public.programnotificationtemplate(programnotificationtemplateid);


--
-- Name: programnotificationtemplate fk4uq2bl31hdu2s4e07rltemk3d; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programnotificationtemplate
    ADD CONSTRAINT fk4uq2bl31hdu2s4e07rltemk3d FOREIGN KEY (programstageid) REFERENCES public.programstage(programstageid);


--
-- Name: validationnotificationtemplatevalidationrules fk6oepnl7prbw10034c5vot1jii; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationnotificationtemplatevalidationrules
    ADD CONSTRAINT fk6oepnl7prbw10034c5vot1jii FOREIGN KEY (validationnotificationtemplateid) REFERENCES public.validationnotificationtemplate(validationnotificationtemplateid);


--
-- Name: validationnotificationtemplate_recipientusergroups fk804hp0os62rpdtroxhrrio76v; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationnotificationtemplate_recipientusergroups
    ADD CONSTRAINT fk804hp0os62rpdtroxhrrio76v FOREIGN KEY (usergroupid) REFERENCES public.usergroup(usergroupid);


--
-- Name: datasetlegendsets fk9f6ich22mw6be835i07khg9ld; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetlegendsets
    ADD CONSTRAINT fk9f6ich22mw6be835i07khg9ld FOREIGN KEY (datasetid) REFERENCES public.dataset(datasetid);


--
-- Name: programnotificationtemplate fk9whlsdwfojxbp8yclqolqwm9; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programnotificationtemplate
    ADD CONSTRAINT fk9whlsdwfojxbp8yclqolqwm9 FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: aggregatedataexchange fk_aggregatedataexchange_lastupdateby_userinfoid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.aggregatedataexchange
    ADD CONSTRAINT fk_aggregatedataexchange_lastupdateby_userinfoid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: aggregatedataexchange fk_aggregatedataexchange_userid_userinfoid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.aggregatedataexchange
    ADD CONSTRAINT fk_aggregatedataexchange_userid_userinfoid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: attribute fk_attribute_optionsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.attribute
    ADD CONSTRAINT fk_attribute_optionsetid FOREIGN KEY (optionsetid) REFERENCES public.optionset(optionsetid);


--
-- Name: attribute fk_attribute_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.attribute
    ADD CONSTRAINT fk_attribute_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: attributevalue fk_attributevalue_attributeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.attributevalue
    ADD CONSTRAINT fk_attributevalue_attributeid FOREIGN KEY (attributeid) REFERENCES public.attribute(attributeid);


--
-- Name: trackedentityattributevalue fk_attributevalue_trackedentityattributeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattributevalue
    ADD CONSTRAINT fk_attributevalue_trackedentityattributeid FOREIGN KEY (trackedentityattributeid) REFERENCES public.trackedentityattribute(trackedentityattributeid);


--
-- Name: trackedentityattributevalue fk_attributevalue_trackedentityinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattributevalue
    ADD CONSTRAINT fk_attributevalue_trackedentityinstanceid FOREIGN KEY (trackedentityinstanceid) REFERENCES public.trackedentityinstance(trackedentityinstanceid);


--
-- Name: trackedentityattributevalueaudit fk_attributevalueaudit_trackedentityattributeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattributevalueaudit
    ADD CONSTRAINT fk_attributevalueaudit_trackedentityattributeid FOREIGN KEY (trackedentityattributeid) REFERENCES public.trackedentityattribute(trackedentityattributeid);


--
-- Name: trackedentityattributevalueaudit fk_attributevalueaudit_trackedentityinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattributevalueaudit
    ADD CONSTRAINT fk_attributevalueaudit_trackedentityinstanceid FOREIGN KEY (trackedentityinstanceid) REFERENCES public.trackedentityinstance(trackedentityinstanceid);


--
-- Name: categories_categoryoptions fk_categories_categoryoptions_categoryid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categories_categoryoptions
    ADD CONSTRAINT fk_categories_categoryoptions_categoryid FOREIGN KEY (categoryid) REFERENCES public.dataelementcategory(categoryid);


--
-- Name: categories_categoryoptions fk_category_categoryoptionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categories_categoryoptions
    ADD CONSTRAINT fk_category_categoryoptionid FOREIGN KEY (categoryoptionid) REFERENCES public.dataelementcategoryoption(categoryoptionid);


--
-- Name: categorycombos_categories fk_categorycombo_categoryid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorycombos_categories
    ADD CONSTRAINT fk_categorycombo_categoryid FOREIGN KEY (categoryid) REFERENCES public.dataelementcategory(categoryid);


--
-- Name: categorycombos_optioncombos fk_categorycombo_categoryoptioncomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorycombos_optioncombos
    ADD CONSTRAINT fk_categorycombo_categoryoptioncomboid FOREIGN KEY (categoryoptioncomboid) REFERENCES public.categoryoptioncombo(categoryoptioncomboid);


--
-- Name: categorycombo fk_categorycombo_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorycombo
    ADD CONSTRAINT fk_categorycombo_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: categorycombos_categories fk_categorycombos_categories_categorycomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorycombos_categories
    ADD CONSTRAINT fk_categorycombos_categories_categorycomboid FOREIGN KEY (categorycomboid) REFERENCES public.categorycombo(categorycomboid);


--
-- Name: categorycombos_optioncombos fk_categorycombos_optioncombos_categorycomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorycombos_optioncombos
    ADD CONSTRAINT fk_categorycombos_optioncombos_categorycomboid FOREIGN KEY (categorycomboid) REFERENCES public.categorycombo(categorycomboid);


--
-- Name: categorydimension fk_categorydimension_category; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorydimension
    ADD CONSTRAINT fk_categorydimension_category FOREIGN KEY (categoryid) REFERENCES public.dataelementcategory(categoryid);


--
-- Name: categorydimension_items fk_categorydimension_items_categorydimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorydimension_items
    ADD CONSTRAINT fk_categorydimension_items_categorydimensionid FOREIGN KEY (categorydimensionid) REFERENCES public.categorydimension(categorydimensionid);


--
-- Name: categorydimension_items fk_categorydimension_items_categoryoptionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorydimension_items
    ADD CONSTRAINT fk_categorydimension_items_categoryoptionid FOREIGN KEY (categoryoptionid) REFERENCES public.dataelementcategoryoption(categoryoptionid);


--
-- Name: categoryoptioncombos_categoryoptions fk_categoryoption_categoryoptioncomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptioncombos_categoryoptions
    ADD CONSTRAINT fk_categoryoption_categoryoptioncomboid FOREIGN KEY (categoryoptioncomboid) REFERENCES public.categoryoptioncombo(categoryoptioncomboid);


--
-- Name: categoryoption_organisationunits fk_categoryoption_organisationunits_categoryoptionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoption_organisationunits
    ADD CONSTRAINT fk_categoryoption_organisationunits_categoryoptionid FOREIGN KEY (categoryoptionid) REFERENCES public.dataelementcategoryoption(categoryoptionid);


--
-- Name: categoryoption_organisationunits fk_categoryoption_organisationunits_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoption_organisationunits
    ADD CONSTRAINT fk_categoryoption_organisationunits_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: smscodes fk_categoryoptioncombo_categoryoptioncomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscodes
    ADD CONSTRAINT fk_categoryoptioncombo_categoryoptioncomboid FOREIGN KEY (optionid) REFERENCES public.categoryoptioncombo(categoryoptioncomboid);


--
-- Name: categoryoptioncombos_categoryoptions fk_categoryoptioncombos_categoryoptions_categoryoptionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptioncombos_categoryoptions
    ADD CONSTRAINT fk_categoryoptioncombos_categoryoptions_categoryoptionid FOREIGN KEY (categoryoptionid) REFERENCES public.dataelementcategoryoption(categoryoptionid);


--
-- Name: categoryoptiongroup fk_categoryoptiongroup_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroup
    ADD CONSTRAINT fk_categoryoptiongroup_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: categoryoptiongroupmembers fk_categoryoptiongroupmembers_categoryoptiongroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupmembers
    ADD CONSTRAINT fk_categoryoptiongroupmembers_categoryoptiongroupid FOREIGN KEY (categoryoptionid) REFERENCES public.dataelementcategoryoption(categoryoptionid);


--
-- Name: categoryoptiongroupmembers fk_categoryoptiongroupmembers_categoryoptionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupmembers
    ADD CONSTRAINT fk_categoryoptiongroupmembers_categoryoptionid FOREIGN KEY (categoryoptiongroupid) REFERENCES public.categoryoptiongroup(categoryoptiongroupid);


--
-- Name: categoryoptiongroupset fk_categoryoptiongroupset_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupset
    ADD CONSTRAINT fk_categoryoptiongroupset_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: categoryoptiongroupsetmembers fk_categoryoptiongroupsetmembers_categoryoptiongroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupsetmembers
    ADD CONSTRAINT fk_categoryoptiongroupsetmembers_categoryoptiongroupid FOREIGN KEY (categoryoptiongroupid) REFERENCES public.categoryoptiongroup(categoryoptiongroupid);


--
-- Name: categoryoptiongroupsetmembers fk_categoryoptiongroupsetmembers_categoryoptiongroupsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupsetmembers
    ADD CONSTRAINT fk_categoryoptiongroupsetmembers_categoryoptiongroupsetid FOREIGN KEY (categoryoptiongroupsetid) REFERENCES public.categoryoptiongroupset(categoryoptiongroupsetid);


--
-- Name: completedatasetregistration fk_completedatasetregistration_attributeoptioncomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.completedatasetregistration
    ADD CONSTRAINT fk_completedatasetregistration_attributeoptioncomboid FOREIGN KEY (attributeoptioncomboid) REFERENCES public.categoryoptioncombo(categoryoptioncomboid);


--
-- Name: completedatasetregistration fk_completedatasetregistration_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.completedatasetregistration
    ADD CONSTRAINT fk_completedatasetregistration_organisationunitid FOREIGN KEY (sourceid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: configuration_corswhitelist fk_configuration_corswhitelist; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.configuration_corswhitelist
    ADD CONSTRAINT fk_configuration_corswhitelist FOREIGN KEY (configurationid) REFERENCES public.configuration(configurationid);


--
-- Name: configuration fk_configuration_facilityorgunitgroupset; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT fk_configuration_facilityorgunitgroupset FOREIGN KEY (facilityorgunitgroupset) REFERENCES public.orgunitgroupset(orgunitgroupsetid);


--
-- Name: configuration fk_configuration_facilityorgunitlevel; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT fk_configuration_facilityorgunitlevel FOREIGN KEY (facilityorgunitlevel) REFERENCES public.orgunitlevel(orgunitlevelid);


--
-- Name: configuration fk_configuration_feedback_recipients; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT fk_configuration_feedback_recipients FOREIGN KEY (feedbackrecipientsid) REFERENCES public.usergroup(usergroupid);


--
-- Name: configuration fk_configuration_infrastructural_dataelements; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT fk_configuration_infrastructural_dataelements FOREIGN KEY (infrastructuraldataelementsid) REFERENCES public.dataelementgroup(dataelementgroupid);


--
-- Name: configuration fk_configuration_infrastructural_indicators; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT fk_configuration_infrastructural_indicators FOREIGN KEY (infrastructuralindicatorsid) REFERENCES public.indicatorgroup(indicatorgroupid);


--
-- Name: configuration fk_configuration_infrastructural_periodtype; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT fk_configuration_infrastructural_periodtype FOREIGN KEY (infrastructuralperiodtypeid) REFERENCES public.periodtype(periodtypeid);


--
-- Name: configuration fk_configuration_offline_orgunit_level; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT fk_configuration_offline_orgunit_level FOREIGN KEY (offlineorgunitlevelid) REFERENCES public.orgunitlevel(orgunitlevelid);


--
-- Name: configuration fk_configuration_selfregistrationorgunit; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT fk_configuration_selfregistrationorgunit FOREIGN KEY (selfregistrationorgunit) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: configuration fk_configuration_selfregistrationrole; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT fk_configuration_selfregistrationrole FOREIGN KEY (selfregistrationrole) REFERENCES public.userrole(userroleid);


--
-- Name: configuration fk_configuration_systemupdatenotification_recipients; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT fk_configuration_systemupdatenotification_recipients FOREIGN KEY (systemupdatenotificationrecipientsid) REFERENCES public.usergroup(usergroupid);


--
-- Name: constant fk_constant_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.constant
    ADD CONSTRAINT fk_constant_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: metadataproposal fk_createdby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.metadataproposal
    ADD CONSTRAINT fk_createdby_userid FOREIGN KEY (createdby) REFERENCES public.userinfo(userinfoid);


--
-- Name: dashboard_items fk_dashboard_items_dashboardid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboard_items
    ADD CONSTRAINT fk_dashboard_items_dashboardid FOREIGN KEY (dashboardid) REFERENCES public.dashboard(dashboardid);


--
-- Name: dashboard_items fk_dashboard_items_dashboarditemid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboard_items
    ADD CONSTRAINT fk_dashboard_items_dashboarditemid FOREIGN KEY (dashboarditemid) REFERENCES public.dashboarditem(dashboarditemid);


--
-- Name: dashboard fk_dashboard_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboard
    ADD CONSTRAINT fk_dashboard_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: dashboarditem fk_dashboarditem_eventchartid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem
    ADD CONSTRAINT fk_dashboarditem_eventchartid FOREIGN KEY (eventchartid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: dashboarditem fk_dashboarditem_eventreportid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem
    ADD CONSTRAINT fk_dashboarditem_eventreportid FOREIGN KEY (eventreport) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: dashboarditem fk_dashboarditem_evisualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem
    ADD CONSTRAINT fk_dashboarditem_evisualizationid FOREIGN KEY (eventvisualizationid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: dashboarditem fk_dashboarditem_mapid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem
    ADD CONSTRAINT fk_dashboarditem_mapid FOREIGN KEY (mapid) REFERENCES public.map(mapid);


--
-- Name: dashboarditem_reports fk_dashboarditem_reports_dashboardid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem_reports
    ADD CONSTRAINT fk_dashboarditem_reports_dashboardid FOREIGN KEY (dashboarditemid) REFERENCES public.dashboarditem(dashboarditemid);


--
-- Name: dashboarditem_reports fk_dashboarditem_reports_reportid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem_reports
    ADD CONSTRAINT fk_dashboarditem_reports_reportid FOREIGN KEY (reportid) REFERENCES public.report(reportid);


--
-- Name: dashboarditem_resources fk_dashboarditem_resources_dashboardid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem_resources
    ADD CONSTRAINT fk_dashboarditem_resources_dashboardid FOREIGN KEY (dashboarditemid) REFERENCES public.dashboarditem(dashboarditemid);


--
-- Name: dashboarditem_resources fk_dashboarditem_resources_resourceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem_resources
    ADD CONSTRAINT fk_dashboarditem_resources_resourceid FOREIGN KEY (resourceid) REFERENCES public.document(documentid);


--
-- Name: dashboarditem_users fk_dashboarditem_users_dashboardid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem_users
    ADD CONSTRAINT fk_dashboarditem_users_dashboardid FOREIGN KEY (dashboarditemid) REFERENCES public.dashboarditem(dashboarditemid);


--
-- Name: dashboarditem_users fk_dashboarditem_users_userinfoid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem_users
    ADD CONSTRAINT fk_dashboarditem_users_userinfoid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: dashboarditem fk_dashboarditem_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem
    ADD CONSTRAINT fk_dashboarditem_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: dataapproval fk_dataapproval_attributeoptioncomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapproval
    ADD CONSTRAINT fk_dataapproval_attributeoptioncomboid FOREIGN KEY (attributeoptioncomboid) REFERENCES public.categoryoptioncombo(categoryoptioncomboid);


--
-- Name: dataapproval fk_dataapproval_creator; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapproval
    ADD CONSTRAINT fk_dataapproval_creator FOREIGN KEY (creator) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataapprovalaudit fk_dataapproval_creator; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalaudit
    ADD CONSTRAINT fk_dataapproval_creator FOREIGN KEY (creator) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataapproval fk_dataapproval_dataapprovallevel; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapproval
    ADD CONSTRAINT fk_dataapproval_dataapprovallevel FOREIGN KEY (dataapprovallevelid) REFERENCES public.dataapprovallevel(dataapprovallevelid);


--
-- Name: dataapproval fk_dataapproval_lastupdateby; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapproval
    ADD CONSTRAINT fk_dataapproval_lastupdateby FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataapproval fk_dataapproval_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapproval
    ADD CONSTRAINT fk_dataapproval_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: dataapproval fk_dataapproval_periodid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapproval
    ADD CONSTRAINT fk_dataapproval_periodid FOREIGN KEY (periodid) REFERENCES public.period(periodid);


--
-- Name: dataapproval fk_dataapproval_workflowid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapproval
    ADD CONSTRAINT fk_dataapproval_workflowid FOREIGN KEY (workflowid) REFERENCES public.dataapprovalworkflow(workflowid);


--
-- Name: dataapprovalaudit fk_dataapprovalaudit_attributeoptioncomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalaudit
    ADD CONSTRAINT fk_dataapprovalaudit_attributeoptioncomboid FOREIGN KEY (attributeoptioncomboid) REFERENCES public.categoryoptioncombo(categoryoptioncomboid);


--
-- Name: dataapprovalaudit fk_dataapprovalaudit_levelid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalaudit
    ADD CONSTRAINT fk_dataapprovalaudit_levelid FOREIGN KEY (levelid) REFERENCES public.dataapprovallevel(dataapprovallevelid);


--
-- Name: dataapprovalaudit fk_dataapprovalaudit_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalaudit
    ADD CONSTRAINT fk_dataapprovalaudit_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: dataapprovalaudit fk_dataapprovalaudit_periodid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalaudit
    ADD CONSTRAINT fk_dataapprovalaudit_periodid FOREIGN KEY (periodid) REFERENCES public.period(periodid);


--
-- Name: dataapprovalaudit fk_dataapprovalaudit_workflowid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalaudit
    ADD CONSTRAINT fk_dataapprovalaudit_workflowid FOREIGN KEY (workflowid) REFERENCES public.dataapprovalworkflow(workflowid);


--
-- Name: dataapprovallevel fk_dataapprovallevel_categoryoptiongroupsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovallevel
    ADD CONSTRAINT fk_dataapprovallevel_categoryoptiongroupsetid FOREIGN KEY (categoryoptiongroupsetid) REFERENCES public.categoryoptiongroupset(categoryoptiongroupsetid);


--
-- Name: dataapprovallevel fk_dataapprovallevel_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovallevel
    ADD CONSTRAINT fk_dataapprovallevel_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataapprovalworkflow fk_dataapprovalworkflow_categorycomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalworkflow
    ADD CONSTRAINT fk_dataapprovalworkflow_categorycomboid FOREIGN KEY (categorycomboid) REFERENCES public.categorycombo(categorycomboid);


--
-- Name: dataapprovalworkflow fk_dataapprovalworkflow_periodtypeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalworkflow
    ADD CONSTRAINT fk_dataapprovalworkflow_periodtypeid FOREIGN KEY (periodtypeid) REFERENCES public.periodtype(periodtypeid);


--
-- Name: dataapprovalworkflow fk_dataapprovalworkflow_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalworkflow
    ADD CONSTRAINT fk_dataapprovalworkflow_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataapprovalworkflowlevels fk_dataapprovalworkflowlevels_levelid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalworkflowlevels
    ADD CONSTRAINT fk_dataapprovalworkflowlevels_levelid FOREIGN KEY (dataapprovallevelid) REFERENCES public.dataapprovallevel(dataapprovallevelid);


--
-- Name: dataapprovalworkflowlevels fk_dataapprovalworkflowlevels_workflowid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalworkflowlevels
    ADD CONSTRAINT fk_dataapprovalworkflowlevels_workflowid FOREIGN KEY (workflowid) REFERENCES public.dataapprovalworkflow(workflowid);


--
-- Name: datadimensionitem fk_datadimensionitem_dataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datadimensionitem
    ADD CONSTRAINT fk_datadimensionitem_dataelementid FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: datadimensionitem fk_datadimensionitem_dataelementoperand_categoryoptioncomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datadimensionitem
    ADD CONSTRAINT fk_datadimensionitem_dataelementoperand_categoryoptioncomboid FOREIGN KEY (dataelementoperand_categoryoptioncomboid) REFERENCES public.categoryoptioncombo(categoryoptioncomboid);


--
-- Name: datadimensionitem fk_datadimensionitem_dataelementoperand_dataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datadimensionitem
    ADD CONSTRAINT fk_datadimensionitem_dataelementoperand_dataelementid FOREIGN KEY (dataelementoperand_dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: datadimensionitem fk_datadimensionitem_datasetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datadimensionitem
    ADD CONSTRAINT fk_datadimensionitem_datasetid FOREIGN KEY (datasetid) REFERENCES public.dataset(datasetid);


--
-- Name: datadimensionitem fk_datadimensionitem_indicatorid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datadimensionitem
    ADD CONSTRAINT fk_datadimensionitem_indicatorid FOREIGN KEY (indicatorid) REFERENCES public.indicator(indicatorid);


--
-- Name: datadimensionitem fk_datadimensionitem_programattribute_attributeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datadimensionitem
    ADD CONSTRAINT fk_datadimensionitem_programattribute_attributeid FOREIGN KEY (programattribute_attributeid) REFERENCES public.trackedentityattribute(trackedentityattributeid);


--
-- Name: datadimensionitem fk_datadimensionitem_programattribute_programid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datadimensionitem
    ADD CONSTRAINT fk_datadimensionitem_programattribute_programid FOREIGN KEY (programattribute_programid) REFERENCES public.program(programid);


--
-- Name: datadimensionitem fk_datadimensionitem_programdataelement_dataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datadimensionitem
    ADD CONSTRAINT fk_datadimensionitem_programdataelement_dataelementid FOREIGN KEY (programdataelement_dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: datadimensionitem fk_datadimensionitem_programdataelement_programid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datadimensionitem
    ADD CONSTRAINT fk_datadimensionitem_programdataelement_programid FOREIGN KEY (programdataelement_programid) REFERENCES public.program(programid);


--
-- Name: datadimensionitem fk_datadimensionitem_programindicatorid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datadimensionitem
    ADD CONSTRAINT fk_datadimensionitem_programindicatorid FOREIGN KEY (programindicatorid) REFERENCES public.programindicator(programindicatorid);


--
-- Name: dataelement fk_dataelement_categorycomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelement
    ADD CONSTRAINT fk_dataelement_categorycomboid FOREIGN KEY (categorycomboid) REFERENCES public.categorycombo(categorycomboid);


--
-- Name: dataelement fk_dataelement_commentoptionsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelement
    ADD CONSTRAINT fk_dataelement_commentoptionsetid FOREIGN KEY (commentoptionsetid) REFERENCES public.optionset(optionsetid);


--
-- Name: smscodes fk_dataelement_dataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscodes
    ADD CONSTRAINT fk_dataelement_dataelementid FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: dataelementlegendsets fk_dataelement_legendsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementlegendsets
    ADD CONSTRAINT fk_dataelement_legendsetid FOREIGN KEY (legendsetid) REFERENCES public.maplegendset(maplegendsetid);


--
-- Name: dataelement fk_dataelement_optionsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelement
    ADD CONSTRAINT fk_dataelement_optionsetid FOREIGN KEY (optionsetid) REFERENCES public.optionset(optionsetid);


--
-- Name: dataelement fk_dataelement_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelement
    ADD CONSTRAINT fk_dataelement_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataelementaggregationlevels fk_dataelementaggregationlevels_dataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementaggregationlevels
    ADD CONSTRAINT fk_dataelementaggregationlevels_dataelementid FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: dataelementcategory fk_dataelementcategory_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementcategory
    ADD CONSTRAINT fk_dataelementcategory_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataelementcategoryoption fk_dataelementcategoryoption_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementcategoryoption
    ADD CONSTRAINT fk_dataelementcategoryoption_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataelementgroupmembers fk_dataelementgroup_dataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupmembers
    ADD CONSTRAINT fk_dataelementgroup_dataelementid FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: dataelementgroup fk_dataelementgroup_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroup
    ADD CONSTRAINT fk_dataelementgroup_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataelementgroupmembers fk_dataelementgroupmembers_dataelementgroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupmembers
    ADD CONSTRAINT fk_dataelementgroupmembers_dataelementgroupid FOREIGN KEY (dataelementgroupid) REFERENCES public.dataelementgroup(dataelementgroupid);


--
-- Name: dataelementgroupsetmembers fk_dataelementgroupset_dataelementgroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupsetmembers
    ADD CONSTRAINT fk_dataelementgroupset_dataelementgroupid FOREIGN KEY (dataelementgroupid) REFERENCES public.dataelementgroup(dataelementgroupid);


--
-- Name: dataelementgroupset fk_dataelementgroupset_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupset
    ADD CONSTRAINT fk_dataelementgroupset_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataelementgroupsetmembers fk_dataelementgroupsetmembers_dataelementgroupsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupsetmembers
    ADD CONSTRAINT fk_dataelementgroupsetmembers_dataelementgroupsetid FOREIGN KEY (dataelementgroupsetid) REFERENCES public.dataelementgroupset(dataelementgroupsetid);


--
-- Name: dataelementoperand fk_dataelementoperand_dataelement; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementoperand
    ADD CONSTRAINT fk_dataelementoperand_dataelement FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: dataelementoperand fk_dataelementoperand_dataelementcategoryoptioncombo; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementoperand
    ADD CONSTRAINT fk_dataelementoperand_dataelementcategoryoptioncombo FOREIGN KEY (categoryoptioncomboid) REFERENCES public.categoryoptioncombo(categoryoptioncomboid);


--
-- Name: datainputperiod fk_datainputperiod_period; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datainputperiod
    ADD CONSTRAINT fk_datainputperiod_period FOREIGN KEY (periodid) REFERENCES public.period(periodid);


--
-- Name: dataset fk_dataset_categorycomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT fk_dataset_categorycomboid FOREIGN KEY (categorycomboid) REFERENCES public.categorycombo(categorycomboid);


--
-- Name: datasetoperands fk_dataset_dataelementoperandid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetoperands
    ADD CONSTRAINT fk_dataset_dataelementoperandid FOREIGN KEY (dataelementoperandid) REFERENCES public.dataelementoperand(dataelementoperandid);


--
-- Name: dataset fk_dataset_dataentryform; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT fk_dataset_dataentryform FOREIGN KEY (dataentryform) REFERENCES public.dataentryform(dataentryformid);


--
-- Name: smscommands fk_dataset_datasetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscommands
    ADD CONSTRAINT fk_dataset_datasetid FOREIGN KEY (datasetid) REFERENCES public.dataset(datasetid);


--
-- Name: datasetindicators fk_dataset_indicatorid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetindicators
    ADD CONSTRAINT fk_dataset_indicatorid FOREIGN KEY (indicatorid) REFERENCES public.indicator(indicatorid);


--
-- Name: datasetlegendsets fk_dataset_legendsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetlegendsets
    ADD CONSTRAINT fk_dataset_legendsetid FOREIGN KEY (legendsetid) REFERENCES public.maplegendset(maplegendsetid);


--
-- Name: dataset fk_dataset_notificationrecipients; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT fk_dataset_notificationrecipients FOREIGN KEY (notificationrecipients) REFERENCES public.usergroup(usergroupid);


--
-- Name: datasetsource fk_dataset_organisationunit; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetsource
    ADD CONSTRAINT fk_dataset_organisationunit FOREIGN KEY (sourceid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: dataset fk_dataset_periodtypeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT fk_dataset_periodtypeid FOREIGN KEY (periodtypeid) REFERENCES public.periodtype(periodtypeid);


--
-- Name: dataset fk_dataset_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT fk_dataset_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataset fk_dataset_workflowid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT fk_dataset_workflowid FOREIGN KEY (workflowid) REFERENCES public.dataapprovalworkflow(workflowid);


--
-- Name: completedatasetregistration fk_datasetcompleteregistration_datasetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.completedatasetregistration
    ADD CONSTRAINT fk_datasetcompleteregistration_datasetid FOREIGN KEY (datasetid) REFERENCES public.dataset(datasetid);


--
-- Name: completedatasetregistration fk_datasetcompleteregistration_periodid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.completedatasetregistration
    ADD CONSTRAINT fk_datasetcompleteregistration_periodid FOREIGN KEY (periodid) REFERENCES public.period(periodid);


--
-- Name: datainputperiod fk_datasetdatainputperiods_datasetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datainputperiod
    ADD CONSTRAINT fk_datasetdatainputperiods_datasetid FOREIGN KEY (datasetid) REFERENCES public.dataset(datasetid);


--
-- Name: datasetelement fk_datasetelement_categorycomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetelement
    ADD CONSTRAINT fk_datasetelement_categorycomboid FOREIGN KEY (categorycomboid) REFERENCES public.categorycombo(categorycomboid);


--
-- Name: datasetindicators fk_datasetindicators_datasetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetindicators
    ADD CONSTRAINT fk_datasetindicators_datasetid FOREIGN KEY (datasetid) REFERENCES public.dataset(datasetid);


--
-- Name: datasetelement fk_datasetmembers_dataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetelement
    ADD CONSTRAINT fk_datasetmembers_dataelementid FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: datasetelement fk_datasetmembers_datasetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetelement
    ADD CONSTRAINT fk_datasetmembers_datasetid FOREIGN KEY (datasetid) REFERENCES public.dataset(datasetid);


--
-- Name: datasetnotificationtemplate fk_datasetnotification_usergroup; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetnotificationtemplate
    ADD CONSTRAINT fk_datasetnotification_usergroup FOREIGN KEY (usergroupid) REFERENCES public.usergroup(usergroupid);


--
-- Name: datasetoperands fk_datasetoperands_datasetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetoperands
    ADD CONSTRAINT fk_datasetoperands_datasetid FOREIGN KEY (datasetid) REFERENCES public.dataset(datasetid);


--
-- Name: datasetnotification_datasets fk_datasets_datasetnotificationtemplateid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetnotification_datasets
    ADD CONSTRAINT fk_datasets_datasetnotificationtemplateid FOREIGN KEY (datasetnotificationtemplateid) REFERENCES public.datasetnotificationtemplate(datasetnotificationtemplateid);


--
-- Name: datasetsource fk_datasetsource_datasetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetsource
    ADD CONSTRAINT fk_datasetsource_datasetid FOREIGN KEY (datasetid) REFERENCES public.dataset(datasetid);


--
-- Name: datavalue fk_datavalue_attributeoptioncomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datavalue
    ADD CONSTRAINT fk_datavalue_attributeoptioncomboid FOREIGN KEY (attributeoptioncomboid) REFERENCES public.categoryoptioncombo(categoryoptioncomboid);


--
-- Name: datavalue fk_datavalue_categoryoptioncomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datavalue
    ADD CONSTRAINT fk_datavalue_categoryoptioncomboid FOREIGN KEY (categoryoptioncomboid) REFERENCES public.categoryoptioncombo(categoryoptioncomboid);


--
-- Name: datavalue fk_datavalue_dataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datavalue
    ADD CONSTRAINT fk_datavalue_dataelementid FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: datavalue fk_datavalue_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datavalue
    ADD CONSTRAINT fk_datavalue_organisationunitid FOREIGN KEY (sourceid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: datavalue fk_datavalue_periodid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datavalue
    ADD CONSTRAINT fk_datavalue_periodid FOREIGN KEY (periodid) REFERENCES public.period(periodid);


--
-- Name: datavalueaudit fk_datavalueaudit_attributeoptioncomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datavalueaudit
    ADD CONSTRAINT fk_datavalueaudit_attributeoptioncomboid FOREIGN KEY (attributeoptioncomboid) REFERENCES public.categoryoptioncombo(categoryoptioncomboid);


--
-- Name: datavalueaudit fk_datavalueaudit_categoryoptioncomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datavalueaudit
    ADD CONSTRAINT fk_datavalueaudit_categoryoptioncomboid FOREIGN KEY (categoryoptioncomboid) REFERENCES public.categoryoptioncombo(categoryoptioncomboid);


--
-- Name: datavalueaudit fk_datavalueaudit_dataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datavalueaudit
    ADD CONSTRAINT fk_datavalueaudit_dataelementid FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: datavalueaudit fk_datavalueaudit_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datavalueaudit
    ADD CONSTRAINT fk_datavalueaudit_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: datavalueaudit fk_datavalueaudit_periodid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datavalueaudit
    ADD CONSTRAINT fk_datavalueaudit_periodid FOREIGN KEY (periodid) REFERENCES public.period(periodid);


--
-- Name: categoryoptiongroupsetdimension fk_dimension_categoryoptiongroupsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupsetdimension
    ADD CONSTRAINT fk_dimension_categoryoptiongroupsetid FOREIGN KEY (categoryoptiongroupsetid) REFERENCES public.categoryoptiongroupset(categoryoptiongroupsetid);


--
-- Name: dataelementgroupsetdimension fk_dimension_dataelementgroupsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupsetdimension
    ADD CONSTRAINT fk_dimension_dataelementgroupsetid FOREIGN KEY (dataelementgroupsetid) REFERENCES public.dataelementgroupset(dataelementgroupsetid);


--
-- Name: categoryoptiongroupsetdimension_items fk_dimension_items_categoryoptiongroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupsetdimension_items
    ADD CONSTRAINT fk_dimension_items_categoryoptiongroupid FOREIGN KEY (categoryoptiongroupid) REFERENCES public.categoryoptiongroup(categoryoptiongroupid);


--
-- Name: categoryoptiongroupsetdimension_items fk_dimension_items_categoryoptiongroupsetdimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupsetdimension_items
    ADD CONSTRAINT fk_dimension_items_categoryoptiongroupsetdimensionid FOREIGN KEY (categoryoptiongroupsetdimensionid) REFERENCES public.categoryoptiongroupsetdimension(categoryoptiongroupsetdimensionid);


--
-- Name: dataelementgroupsetdimension_items fk_dimension_items_dataelementgroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupsetdimension_items
    ADD CONSTRAINT fk_dimension_items_dataelementgroupid FOREIGN KEY (dataelementgroupid) REFERENCES public.dataelementgroup(dataelementgroupid);


--
-- Name: dataelementgroupsetdimension_items fk_dimension_items_dataelementgroupsetdimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupsetdimension_items
    ADD CONSTRAINT fk_dimension_items_dataelementgroupsetdimensionid FOREIGN KEY (dataelementgroupsetdimensionid) REFERENCES public.dataelementgroupsetdimension(dataelementgroupsetdimensionid);


--
-- Name: orgunitgroupsetdimension_items fk_dimension_items_orgunitgroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupsetdimension_items
    ADD CONSTRAINT fk_dimension_items_orgunitgroupid FOREIGN KEY (orgunitgroupid) REFERENCES public.orgunitgroup(orgunitgroupid);


--
-- Name: orgunitgroupsetdimension_items fk_dimension_items_orgunitgroupsetdimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupsetdimension_items
    ADD CONSTRAINT fk_dimension_items_orgunitgroupsetdimensionid FOREIGN KEY (orgunitgroupsetdimensionid) REFERENCES public.orgunitgroupsetdimension(orgunitgroupsetdimensionid);


--
-- Name: orgunitgroupsetdimension fk_dimension_orgunitgroupsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupsetdimension
    ADD CONSTRAINT fk_dimension_orgunitgroupsetid FOREIGN KEY (orgunitgroupsetid) REFERENCES public.orgunitgroupset(orgunitgroupsetid);


--
-- Name: document fk_document_fileresourceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT fk_document_fileresourceid FOREIGN KEY (fileresource) REFERENCES public.fileresource(fileresourceid);


--
-- Name: document fk_document_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT fk_document_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: trackedentitydatavalueaudit fk_entityinstancedatavalueaudit_dataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitydatavalueaudit
    ADD CONSTRAINT fk_entityinstancedatavalueaudit_dataelementid FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: trackedentitydatavalueaudit fk_entityinstancedatavalueaudit_programstageinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitydatavalueaudit
    ADD CONSTRAINT fk_entityinstancedatavalueaudit_programstageinstanceid FOREIGN KEY (programstageinstanceid) REFERENCES public.programstageinstance(programstageinstanceid);


--
-- Name: eventvisualization_attributedimensions fk_evisualization_attributedimensions_attributedimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_attributedimensions
    ADD CONSTRAINT fk_evisualization_attributedimensions_attributedimensionid FOREIGN KEY (trackedentityattributedimensionid) REFERENCES public.trackedentityattributedimension(trackedentityattributedimensionid);


--
-- Name: eventvisualization_attributedimensions fk_evisualization_attributedimensions_evisualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_attributedimensions
    ADD CONSTRAINT fk_evisualization_attributedimensions_evisualizationid FOREIGN KEY (eventvisualizationid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: eventvisualization fk_evisualization_attributevaluedimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization
    ADD CONSTRAINT fk_evisualization_attributevaluedimensionid FOREIGN KEY (attributevaluedimensionid) REFERENCES public.trackedentityattribute(trackedentityattributeid);


--
-- Name: eventvisualization_categorydimensions fk_evisualization_categorydimensions_categorydimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_categorydimensions
    ADD CONSTRAINT fk_evisualization_categorydimensions_categorydimensionid FOREIGN KEY (categorydimensionid) REFERENCES public.categorydimension(categorydimensionid);


--
-- Name: eventvisualization_categorydimensions fk_evisualization_categorydimensions_evisualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_categorydimensions
    ADD CONSTRAINT fk_evisualization_categorydimensions_evisualizationid FOREIGN KEY (eventvisualizationid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: eventvisualization_categoryoptiongroupsetdimensions fk_evisualization_catoptiongroupsetdimensions_evisualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_categoryoptiongroupsetdimensions
    ADD CONSTRAINT fk_evisualization_catoptiongroupsetdimensions_evisualizationid FOREIGN KEY (eventvisualizationid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: eventvisualization_columns fk_evisualization_columns_evisualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_columns
    ADD CONSTRAINT fk_evisualization_columns_evisualizationid FOREIGN KEY (eventvisualizationid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: eventvisualization_dataelementdimensions fk_evisualization_dataelementdimensions_dataelementdimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_dataelementdimensions
    ADD CONSTRAINT fk_evisualization_dataelementdimensions_dataelementdimensionid FOREIGN KEY (trackedentitydataelementdimensionid) REFERENCES public.trackedentitydataelementdimension(trackedentitydataelementdimensionid);


--
-- Name: eventvisualization_dataelementdimensions fk_evisualization_dataelementdimensions_evisualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_dataelementdimensions
    ADD CONSTRAINT fk_evisualization_dataelementdimensions_evisualizationid FOREIGN KEY (eventvisualizationid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: eventvisualization fk_evisualization_dataelementvaluedimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization
    ADD CONSTRAINT fk_evisualization_dataelementvaluedimensionid FOREIGN KEY (dataelementvaluedimensionid) REFERENCES public.dataelement(dataelementid);


--
-- Name: eventvisualization_categoryoptiongroupsetdimensions fk_evisualization_dimensions_catoptiongroupsetdimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_categoryoptiongroupsetdimensions
    ADD CONSTRAINT fk_evisualization_dimensions_catoptiongroupsetdimensionid FOREIGN KEY (categoryoptiongroupsetdimensionid) REFERENCES public.categoryoptiongroupsetdimension(categoryoptiongroupsetdimensionid);


--
-- Name: eventvisualization_orgunitgroupsetdimensions fk_evisualization_dimensions_ogunitgroupsetdimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_orgunitgroupsetdimensions
    ADD CONSTRAINT fk_evisualization_dimensions_ogunitgroupsetdimensionid FOREIGN KEY (orgunitgroupsetdimensionid) REFERENCES public.orgunitgroupsetdimension(orgunitgroupsetdimensionid);


--
-- Name: eventvisualization_filters fk_evisualization_filters_evisualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_filters
    ADD CONSTRAINT fk_evisualization_filters_evisualizationid FOREIGN KEY (eventvisualizationid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: eventvisualization_itemorgunitgroups fk_evisualization_itemorgunitgroups_orgunitgroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_itemorgunitgroups
    ADD CONSTRAINT fk_evisualization_itemorgunitgroups_orgunitgroupid FOREIGN KEY (orgunitgroupid) REFERENCES public.orgunitgroup(orgunitgroupid);


--
-- Name: eventvisualization_itemorgunitgroups fk_evisualization_itemorgunitunitgroups_evisualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_itemorgunitgroups
    ADD CONSTRAINT fk_evisualization_itemorgunitunitgroups_evisualizationid FOREIGN KEY (eventvisualizationid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: eventvisualization fk_evisualization_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization
    ADD CONSTRAINT fk_evisualization_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: eventvisualization fk_evisualization_legendsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization
    ADD CONSTRAINT fk_evisualization_legendsetid FOREIGN KEY (legendsetid) REFERENCES public.maplegendset(maplegendsetid);


--
-- Name: eventvisualization_organisationunits fk_evisualization_organisationunits_evisualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_organisationunits
    ADD CONSTRAINT fk_evisualization_organisationunits_evisualizationid FOREIGN KEY (eventvisualizationid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: eventvisualization_organisationunits fk_evisualization_organisationunits_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_organisationunits
    ADD CONSTRAINT fk_evisualization_organisationunits_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: eventvisualization_orgunitgroupsetdimensions fk_evisualization_orgunitgroupsetdimensions_evisualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_orgunitgroupsetdimensions
    ADD CONSTRAINT fk_evisualization_orgunitgroupsetdimensions_evisualizationid FOREIGN KEY (eventvisualizationid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: eventvisualization_orgunitlevels fk_evisualization_orgunitlevels_evisualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_orgunitlevels
    ADD CONSTRAINT fk_evisualization_orgunitlevels_evisualizationid FOREIGN KEY (eventvisualizationid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: eventvisualization_periods fk_evisualization_periods_evisualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_periods
    ADD CONSTRAINT fk_evisualization_periods_evisualizationid FOREIGN KEY (eventvisualizationid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: eventvisualization_periods fk_evisualization_periods_periodid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_periods
    ADD CONSTRAINT fk_evisualization_periods_periodid FOREIGN KEY (periodid) REFERENCES public.period(periodid);


--
-- Name: eventvisualization_programindicatordimensions fk_evisualization_prindicatordimensions_prindicatordimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_programindicatordimensions
    ADD CONSTRAINT fk_evisualization_prindicatordimensions_prindicatordimensionid FOREIGN KEY (trackedentityprogramindicatordimensionid) REFERENCES public.trackedentityprogramindicatordimension(trackedentityprogramindicatordimensionid);


--
-- Name: eventvisualization fk_evisualization_programid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization
    ADD CONSTRAINT fk_evisualization_programid FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: eventvisualization_programindicatordimensions fk_evisualization_programindicatordim_programindicatordimid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_programindicatordimensions
    ADD CONSTRAINT fk_evisualization_programindicatordim_programindicatordimid FOREIGN KEY (trackedentityprogramindicatordimensionid) REFERENCES public.trackedentityprogramindicatordimension(trackedentityprogramindicatordimensionid);


--
-- Name: eventvisualization_programindicatordimensions fk_evisualization_programindicatordimensions_evisualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_programindicatordimensions
    ADD CONSTRAINT fk_evisualization_programindicatordimensions_evisualizationid FOREIGN KEY (eventvisualizationid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: eventvisualization fk_evisualization_programstageid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization
    ADD CONSTRAINT fk_evisualization_programstageid FOREIGN KEY (programstageid) REFERENCES public.programstage(programstageid);


--
-- Name: eventvisualization fk_evisualization_relativeperiodsid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization
    ADD CONSTRAINT fk_evisualization_relativeperiodsid FOREIGN KEY (relativeperiodsid) REFERENCES public.relativeperiods(relativeperiodsid);


--
-- Name: eventvisualization fk_evisualization_report_relativeperiodsid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization
    ADD CONSTRAINT fk_evisualization_report_relativeperiodsid FOREIGN KEY (relativeperiodsid) REFERENCES public.relativeperiods(relativeperiodsid);


--
-- Name: eventvisualization_rows fk_evisualization_rows_evisualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization_rows
    ADD CONSTRAINT fk_evisualization_rows_evisualizationid FOREIGN KEY (eventvisualizationid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: eventvisualization fk_evisualization_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.eventvisualization
    ADD CONSTRAINT fk_evisualization_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: externalmaplayer fk_externalmaplayer_legendsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.externalmaplayer
    ADD CONSTRAINT fk_externalmaplayer_legendsetid FOREIGN KEY (legendsetid) REFERENCES public.maplegendset(maplegendsetid);


--
-- Name: externalmaplayer fk_externalmaplayer_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.externalmaplayer
    ADD CONSTRAINT fk_externalmaplayer_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: externalfileresource fk_fileresource_externalfileresource; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.externalfileresource
    ADD CONSTRAINT fk_fileresource_externalfileresource FOREIGN KEY (fileresourceid) REFERENCES public.fileresource(fileresourceid);


--
-- Name: fileresource fk_fileresource_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.fileresource
    ADD CONSTRAINT fk_fileresource_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: metadataproposal fk_finalisedby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.metadataproposal
    ADD CONSTRAINT fk_finalisedby_userid FOREIGN KEY (finalisedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: users_catdimensionconstraints fk_fk_users_catconstraints_dataelementcategoryid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.users_catdimensionconstraints
    ADD CONSTRAINT fk_fk_users_catconstraints_dataelementcategoryid FOREIGN KEY (dataelementcategoryid) REFERENCES public.dataelementcategory(categoryid);


--
-- Name: users_cogsdimensionconstraints fk_fk_users_cogsconstraints_categoryoptiongroupsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.users_cogsdimensionconstraints
    ADD CONSTRAINT fk_fk_users_cogsconstraints_categoryoptiongroupsetid FOREIGN KEY (categoryoptiongroupsetid) REFERENCES public.categoryoptiongroupset(categoryoptiongroupsetid);


--
-- Name: incomingsms fk_incomingsms_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.incomingsms
    ADD CONSTRAINT fk_incomingsms_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: indicator fk_indicator_indicatortypeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicator
    ADD CONSTRAINT fk_indicator_indicatortypeid FOREIGN KEY (indicatortypeid) REFERENCES public.indicatortype(indicatortypeid);


--
-- Name: indicatorlegendsets fk_indicator_legendsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorlegendsets
    ADD CONSTRAINT fk_indicator_legendsetid FOREIGN KEY (legendsetid) REFERENCES public.maplegendset(maplegendsetid);


--
-- Name: indicator fk_indicator_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicator
    ADD CONSTRAINT fk_indicator_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: indicatorgroupmembers fk_indicatorgroup_indicatorid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroupmembers
    ADD CONSTRAINT fk_indicatorgroup_indicatorid FOREIGN KEY (indicatorid) REFERENCES public.indicator(indicatorid);


--
-- Name: indicatorgroup fk_indicatorgroup_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroup
    ADD CONSTRAINT fk_indicatorgroup_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: indicatorgroupmembers fk_indicatorgroupmembers_indicatorgroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroupmembers
    ADD CONSTRAINT fk_indicatorgroupmembers_indicatorgroupid FOREIGN KEY (indicatorgroupid) REFERENCES public.indicatorgroup(indicatorgroupid);


--
-- Name: indicatorgroupsetmembers fk_indicatorgroupset_indicatorgroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroupsetmembers
    ADD CONSTRAINT fk_indicatorgroupset_indicatorgroupid FOREIGN KEY (indicatorgroupid) REFERENCES public.indicatorgroup(indicatorgroupid);


--
-- Name: indicatorgroupset fk_indicatorgroupset_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroupset
    ADD CONSTRAINT fk_indicatorgroupset_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: indicatorgroupsetmembers fk_indicatorgroupsetmembers_indicatorgroupsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroupsetmembers
    ADD CONSTRAINT fk_indicatorgroupsetmembers_indicatorgroupsetid FOREIGN KEY (indicatorgroupsetid) REFERENCES public.indicatorgroupset(indicatorgroupsetid);


--
-- Name: intepretation_likedby fk_intepretation_likedby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.intepretation_likedby
    ADD CONSTRAINT fk_intepretation_likedby_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: interpretation_comments fk_interpretation_comments_interpretationcommentid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretation_comments
    ADD CONSTRAINT fk_interpretation_comments_interpretationcommentid FOREIGN KEY (interpretationcommentid) REFERENCES public.interpretationcomment(interpretationcommentid);


--
-- Name: interpretation_comments fk_interpretation_comments_interpretationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretation_comments
    ADD CONSTRAINT fk_interpretation_comments_interpretationid FOREIGN KEY (interpretationid) REFERENCES public.interpretation(interpretationid);


--
-- Name: interpretation fk_interpretation_datasetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretation
    ADD CONSTRAINT fk_interpretation_datasetid FOREIGN KEY (datasetid) REFERENCES public.dataset(datasetid);


--
-- Name: interpretation fk_interpretation_eventchartid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretation
    ADD CONSTRAINT fk_interpretation_eventchartid FOREIGN KEY (eventreportid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: interpretation fk_interpretation_eventreportid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretation
    ADD CONSTRAINT fk_interpretation_eventreportid FOREIGN KEY (eventchartid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: interpretation fk_interpretation_evisualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretation
    ADD CONSTRAINT fk_interpretation_evisualizationid FOREIGN KEY (eventvisualizationid) REFERENCES public.eventvisualization(eventvisualizationid);


--
-- Name: intepretation_likedby fk_interpretation_likedby_interpretationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.intepretation_likedby
    ADD CONSTRAINT fk_interpretation_likedby_interpretationid FOREIGN KEY (interpretationid) REFERENCES public.interpretation(interpretationid);


--
-- Name: interpretation fk_interpretation_mapid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretation
    ADD CONSTRAINT fk_interpretation_mapid FOREIGN KEY (mapid) REFERENCES public.map(mapid);


--
-- Name: interpretation fk_interpretation_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretation
    ADD CONSTRAINT fk_interpretation_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: interpretation fk_interpretation_periodid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretation
    ADD CONSTRAINT fk_interpretation_periodid FOREIGN KEY (periodid) REFERENCES public.period(periodid);


--
-- Name: interpretation fk_interpretation_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretation
    ADD CONSTRAINT fk_interpretation_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: interpretation fk_interpretation_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretation
    ADD CONSTRAINT fk_interpretation_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: interpretationcomment fk_interpretationcomment_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.interpretationcomment
    ADD CONSTRAINT fk_interpretationcomment_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: keyjsonvalue fk_keyjsonvalue_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.keyjsonvalue
    ADD CONSTRAINT fk_keyjsonvalue_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: attribute fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.attribute
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: categorycombo fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categorycombo
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: categoryoptioncombo fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptioncombo
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: categoryoptiongroup fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroup
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: categoryoptiongroupset fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.categoryoptiongroupset
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: constant fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.constant
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: dashboard fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboard
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: dashboarditem fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dashboarditem
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataapprovallevel fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovallevel
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataapprovalworkflow fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataapprovalworkflow
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataelement fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelement
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataelementcategory fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementcategory
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataelementcategoryoption fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementcategoryoption
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataelementgroup fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroup
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataelementgroupset fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementgroupset
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataentryform fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataentryform
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: dataset fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: datasetnotificationtemplate fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetnotificationtemplate
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: datastatistics fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datastatistics
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: document fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: externalfileresource fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.externalfileresource
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: externalmaplayer fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.externalmaplayer
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: fileresource fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.fileresource
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: i18nlocale fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.i18nlocale
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: indicator fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicator
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: indicatorgroup fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroup
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: indicatorgroupset fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatorgroupset
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: indicatortype fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.indicatortype
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: jobconfiguration fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.jobconfiguration
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: keyjsonvalue fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.keyjsonvalue
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: map fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.map
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: maplegend fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.maplegend
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: maplegendset fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.maplegendset
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: mapview fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: metadataversion fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.metadataversion
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: oauth2client fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.oauth2client
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: optiongroup fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroup
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: optiongroupset fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroupset
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: optionset fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optionset
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: organisationunit fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.organisationunit
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: orgunitgroup fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroup
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: orgunitgroupset fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupset
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: orgunitlevel fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitlevel
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: periodboundary fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.periodboundary
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: predictor fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictor
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: predictorgroup fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictorgroup
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: program fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: program_attribute_group fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program_attribute_group
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: program_attributes fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program_attributes
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: programindicator fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicator
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: programindicatorgroup fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicatorgroup
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: programmessage fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programmessage
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: programnotificationinstance fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programnotificationinstance
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: programnotificationtemplate fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programnotificationtemplate
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: programrule fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programrule
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: programruleaction fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programruleaction
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: programrulevariable fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programrulevariable
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: programsection fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programsection
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: programstage fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstage
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: programstagedataelement fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagedataelement
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: programstagesection fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagesection
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: pushanalysis fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.pushanalysis
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: relationship fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationship
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: relationshiptype fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshiptype
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: report fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.report
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: section fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: sqlview fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.sqlview
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: tablehook fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.tablehook
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: trackedentityattribute fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattribute
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: trackedentitycomment fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitycomment
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: trackedentityinstance fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityinstance
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: trackedentityinstancefilter fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityinstancefilter
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: trackedentitytype fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitytype
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: trackedentitytypeattribute fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitytypeattribute
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: usergroup fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usergroup
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: userkeyjsonvalue fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userkeyjsonvalue
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: userrole fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userrole
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: validationnotificationtemplate fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationnotificationtemplate
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: validationrule fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrule
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: validationrulegroup fk_lastupdateby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrulegroup
    ADD CONSTRAINT fk_lastupdateby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: programstageinstancefilter fk_lastupdatedby_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstancefilter
    ADD CONSTRAINT fk_lastupdatedby_userid FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: maplegendset fk_legendset_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.maplegendset
    ADD CONSTRAINT fk_legendset_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: lockexception fk_lockexception_datasetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.lockexception
    ADD CONSTRAINT fk_lockexception_datasetid FOREIGN KEY (datasetid) REFERENCES public.dataset(datasetid);


--
-- Name: lockexception fk_lockexception_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.lockexception
    ADD CONSTRAINT fk_lockexception_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: lockexception fk_lockexception_periodid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.lockexception
    ADD CONSTRAINT fk_lockexception_periodid FOREIGN KEY (periodid) REFERENCES public.period(periodid);


--
-- Name: maplegend fk_maplegend_maplegendsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.maplegend
    ADD CONSTRAINT fk_maplegend_maplegendsetid FOREIGN KEY (maplegendsetid) REFERENCES public.maplegendset(maplegendsetid);


--
-- Name: mapmapviews fk_mapmapview_mapid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapmapviews
    ADD CONSTRAINT fk_mapmapview_mapid FOREIGN KEY (mapid) REFERENCES public.map(mapid);


--
-- Name: mapmapviews fk_mapmapview_mapviewid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapmapviews
    ADD CONSTRAINT fk_mapmapview_mapviewid FOREIGN KEY (mapviewid) REFERENCES public.mapview(mapviewid);


--
-- Name: mapview_attributedimensions fk_mapview_attributedimensions_attributedimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_attributedimensions
    ADD CONSTRAINT fk_mapview_attributedimensions_attributedimensionid FOREIGN KEY (trackedentityattributedimensionid) REFERENCES public.trackedentityattributedimension(trackedentityattributedimensionid);


--
-- Name: mapview_attributedimensions fk_mapview_attributedimensions_mapviewid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_attributedimensions
    ADD CONSTRAINT fk_mapview_attributedimensions_mapviewid FOREIGN KEY (mapviewid) REFERENCES public.mapview(mapviewid);


--
-- Name: mapview_categorydimensions fk_mapview_categorydimensions_categorydimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_categorydimensions
    ADD CONSTRAINT fk_mapview_categorydimensions_categorydimensionid FOREIGN KEY (categorydimensionid) REFERENCES public.categorydimension(categorydimensionid);


--
-- Name: mapview_categorydimensions fk_mapview_categorydimensions_mapviewid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_categorydimensions
    ADD CONSTRAINT fk_mapview_categorydimensions_mapviewid FOREIGN KEY (mapviewid) REFERENCES public.mapview(mapviewid);


--
-- Name: mapview_categoryoptiongroupsetdimensions fk_mapview_catoptiongroupsetdimensions_mapviewid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_categoryoptiongroupsetdimensions
    ADD CONSTRAINT fk_mapview_catoptiongroupsetdimensions_mapviewid FOREIGN KEY (mapviewid) REFERENCES public.mapview(mapviewid);


--
-- Name: mapview_columns fk_mapview_columns_mapviewid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_columns
    ADD CONSTRAINT fk_mapview_columns_mapviewid FOREIGN KEY (mapviewid) REFERENCES public.mapview(mapviewid);


--
-- Name: mapview_datadimensionitems fk_mapview_datadimensionitems_datadimensionitemid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_datadimensionitems
    ADD CONSTRAINT fk_mapview_datadimensionitems_datadimensionitemid FOREIGN KEY (datadimensionitemid) REFERENCES public.datadimensionitem(datadimensionitemid);


--
-- Name: mapview_datadimensionitems fk_mapview_datadimensionitems_mapviewid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_datadimensionitems
    ADD CONSTRAINT fk_mapview_datadimensionitems_mapviewid FOREIGN KEY (mapviewid) REFERENCES public.mapview(mapviewid);


--
-- Name: mapview_dataelementdimensions fk_mapview_dataelementdimensions_dataelementdimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_dataelementdimensions
    ADD CONSTRAINT fk_mapview_dataelementdimensions_dataelementdimensionid FOREIGN KEY (trackedentitydataelementdimensionid) REFERENCES public.trackedentitydataelementdimension(trackedentitydataelementdimensionid);


--
-- Name: mapview_dataelementdimensions fk_mapview_dataelementdimensions_mapviewid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_dataelementdimensions
    ADD CONSTRAINT fk_mapview_dataelementdimensions_mapviewid FOREIGN KEY (mapviewid) REFERENCES public.mapview(mapviewid);


--
-- Name: mapview_categoryoptiongroupsetdimensions fk_mapview_dimensions_catoptiongroupsetdimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_categoryoptiongroupsetdimensions
    ADD CONSTRAINT fk_mapview_dimensions_catoptiongroupsetdimensionid FOREIGN KEY (categoryoptiongroupsetdimensionid) REFERENCES public.categoryoptiongroupsetdimension(categoryoptiongroupsetdimensionid);


--
-- Name: mapview_orgunitgroupsetdimensions fk_mapview_dimensions_orgunitgroupsetdimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_orgunitgroupsetdimensions
    ADD CONSTRAINT fk_mapview_dimensions_orgunitgroupsetdimensionid FOREIGN KEY (orgunitgroupsetdimensionid) REFERENCES public.orgunitgroupsetdimension(orgunitgroupsetdimensionid);


--
-- Name: mapview_filters fk_mapview_filters_mapviewid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_filters
    ADD CONSTRAINT fk_mapview_filters_mapviewid FOREIGN KEY (mapviewid) REFERENCES public.mapview(mapviewid);


--
-- Name: mapview_itemorgunitgroups fk_mapview_itemorgunitgroups_orgunitgroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_itemorgunitgroups
    ADD CONSTRAINT fk_mapview_itemorgunitgroups_orgunitgroupid FOREIGN KEY (orgunitgroupid) REFERENCES public.orgunitgroup(orgunitgroupid);


--
-- Name: mapview_itemorgunitgroups fk_mapview_itemorgunitunitgroups_mapviewid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_itemorgunitgroups
    ADD CONSTRAINT fk_mapview_itemorgunitunitgroups_mapviewid FOREIGN KEY (mapviewid) REFERENCES public.mapview(mapviewid);


--
-- Name: mapview fk_mapview_maplegendsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview
    ADD CONSTRAINT fk_mapview_maplegendsetid FOREIGN KEY (legendsetid) REFERENCES public.maplegendset(maplegendsetid);


--
-- Name: mapview_organisationunits fk_mapview_organisationunits_mapviewid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_organisationunits
    ADD CONSTRAINT fk_mapview_organisationunits_mapviewid FOREIGN KEY (mapviewid) REFERENCES public.mapview(mapviewid);


--
-- Name: mapview_organisationunits fk_mapview_organisationunits_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_organisationunits
    ADD CONSTRAINT fk_mapview_organisationunits_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: mapview_orgunitgroupsetdimensions fk_mapview_orgunitgroupsetdimensions_mapviewid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_orgunitgroupsetdimensions
    ADD CONSTRAINT fk_mapview_orgunitgroupsetdimensions_mapviewid FOREIGN KEY (mapviewid) REFERENCES public.mapview(mapviewid);


--
-- Name: mapview fk_mapview_orgunitgroupsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview
    ADD CONSTRAINT fk_mapview_orgunitgroupsetid FOREIGN KEY (orgunitgroupsetid) REFERENCES public.orgunitgroupset(orgunitgroupsetid);


--
-- Name: mapview_orgunitlevels fk_mapview_orgunitlevels_mapviewid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_orgunitlevels
    ADD CONSTRAINT fk_mapview_orgunitlevels_mapviewid FOREIGN KEY (mapviewid) REFERENCES public.mapview(mapviewid);


--
-- Name: mapview_periods fk_mapview_periods_mapviewid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_periods
    ADD CONSTRAINT fk_mapview_periods_mapviewid FOREIGN KEY (mapviewid) REFERENCES public.mapview(mapviewid);


--
-- Name: mapview_periods fk_mapview_periods_periodid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview_periods
    ADD CONSTRAINT fk_mapview_periods_periodid FOREIGN KEY (periodid) REFERENCES public.period(periodid);


--
-- Name: mapview fk_mapview_programid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview
    ADD CONSTRAINT fk_mapview_programid FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: mapview fk_mapview_programstageid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview
    ADD CONSTRAINT fk_mapview_programstageid FOREIGN KEY (programstageid) REFERENCES public.programstage(programstageid);


--
-- Name: mapview fk_mapview_relativeperiodsid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview
    ADD CONSTRAINT fk_mapview_relativeperiodsid FOREIGN KEY (relativeperiodsid) REFERENCES public.relativeperiods(relativeperiodsid);


--
-- Name: mapview fk_mapview_trackedentitytypeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.mapview
    ADD CONSTRAINT fk_mapview_trackedentitytypeid FOREIGN KEY (trackedentitytypeid) REFERENCES public.trackedentitytype(trackedentitytypeid);


--
-- Name: map fk_mapview_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.map
    ADD CONSTRAINT fk_mapview_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: message fk_message_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT fk_message_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: messageattachments fk_messageattachments_fileresourceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.messageattachments
    ADD CONSTRAINT fk_messageattachments_fileresourceid FOREIGN KEY (fileresourceid) REFERENCES public.fileresource(fileresourceid);


--
-- Name: messageconversation fk_messageconversation_lastsender_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.messageconversation
    ADD CONSTRAINT fk_messageconversation_lastsender_userid FOREIGN KEY (lastsenderid) REFERENCES public.userinfo(userinfoid);


--
-- Name: messageconversation_messages fk_messageconversation_messages_messageconversationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.messageconversation_messages
    ADD CONSTRAINT fk_messageconversation_messages_messageconversationid FOREIGN KEY (messageconversationid) REFERENCES public.messageconversation(messageconversationid);


--
-- Name: messageconversation_messages fk_messageconversation_messages_messageid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.messageconversation_messages
    ADD CONSTRAINT fk_messageconversation_messages_messageid FOREIGN KEY (messageid) REFERENCES public.message(messageid);


--
-- Name: messageconversation fk_messageconversation_user_user_assigned; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.messageconversation
    ADD CONSTRAINT fk_messageconversation_user_user_assigned FOREIGN KEY (user_assigned) REFERENCES public.userinfo(userinfoid);


--
-- Name: messageconversation fk_messageconversation_user_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.messageconversation
    ADD CONSTRAINT fk_messageconversation_user_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: messageconversation_usermessages fk_messageconversation_usermessages_messageconversationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.messageconversation_usermessages
    ADD CONSTRAINT fk_messageconversation_usermessages_messageconversationid FOREIGN KEY (messageconversationid) REFERENCES public.messageconversation(messageconversationid);


--
-- Name: messageconversation_usermessages fk_messageconversation_usermessages_usermessageid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.messageconversation_usermessages
    ADD CONSTRAINT fk_messageconversation_usermessages_usermessageid FOREIGN KEY (usermessageid) REFERENCES public.usermessage(usermessageid);


--
-- Name: minmaxdataelement fk_minmaxdataelement_categoryoptioncomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.minmaxdataelement
    ADD CONSTRAINT fk_minmaxdataelement_categoryoptioncomboid FOREIGN KEY (categoryoptioncomboid) REFERENCES public.categoryoptioncombo(categoryoptioncomboid);


--
-- Name: minmaxdataelement fk_minmaxdataelement_dataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.minmaxdataelement
    ADD CONSTRAINT fk_minmaxdataelement_dataelementid FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: minmaxdataelement fk_minmaxdataelement_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.minmaxdataelement
    ADD CONSTRAINT fk_minmaxdataelement_organisationunitid FOREIGN KEY (sourceid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: oauth2clientgranttypes fk_oauth2clientgranttypes_oauth2clientid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.oauth2clientgranttypes
    ADD CONSTRAINT fk_oauth2clientgranttypes_oauth2clientid FOREIGN KEY (oauth2clientid) REFERENCES public.oauth2client(oauth2clientid);


--
-- Name: oauth2clientredirecturis fk_oauth2clientredirecturis_oauth2clientid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.oauth2clientredirecturis
    ADD CONSTRAINT fk_oauth2clientredirecturis_oauth2clientid FOREIGN KEY (oauth2clientid) REFERENCES public.oauth2client(oauth2clientid);


--
-- Name: optiongroup fk_optiongroup_optionsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroup
    ADD CONSTRAINT fk_optiongroup_optionsetid FOREIGN KEY (optionsetid) REFERENCES public.optionset(optionsetid);


--
-- Name: optiongroup fk_optiongroup_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroup
    ADD CONSTRAINT fk_optiongroup_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: optiongroupmembers fk_optiongroupmembers_optiongroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroupmembers
    ADD CONSTRAINT fk_optiongroupmembers_optiongroupid FOREIGN KEY (optionid) REFERENCES public.optionvalue(optionvalueid);


--
-- Name: optiongroupmembers fk_optiongroupmembers_optionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroupmembers
    ADD CONSTRAINT fk_optiongroupmembers_optionid FOREIGN KEY (optiongroupid) REFERENCES public.optiongroup(optiongroupid);


--
-- Name: optiongroupset fk_optiongroupset_optionsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroupset
    ADD CONSTRAINT fk_optiongroupset_optionsetid FOREIGN KEY (optionsetid) REFERENCES public.optionset(optionsetid);


--
-- Name: optiongroupset fk_optiongroupset_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroupset
    ADD CONSTRAINT fk_optiongroupset_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: optiongroupsetmembers fk_optiongroupsetmembers_optiongroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroupsetmembers
    ADD CONSTRAINT fk_optiongroupsetmembers_optiongroupid FOREIGN KEY (optiongroupid) REFERENCES public.optiongroup(optiongroupid);


--
-- Name: optiongroupsetmembers fk_optiongroupsetmembers_optiongroupsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optiongroupsetmembers
    ADD CONSTRAINT fk_optiongroupsetmembers_optiongroupsetid FOREIGN KEY (optiongroupsetid) REFERENCES public.optiongroupset(optiongroupsetid);


--
-- Name: optionset fk_optionset_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optionset
    ADD CONSTRAINT fk_optionset_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: optionvalue fk_optionsetmembers_optionsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.optionvalue
    ADD CONSTRAINT fk_optionsetmembers_optionsetid FOREIGN KEY (optionsetid) REFERENCES public.optionset(optionsetid);


--
-- Name: organisationunit fk_organisationunit_fileresourceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.organisationunit
    ADD CONSTRAINT fk_organisationunit_fileresourceid FOREIGN KEY (image) REFERENCES public.fileresource(fileresourceid);


--
-- Name: organisationunit fk_organisationunit_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.organisationunit
    ADD CONSTRAINT fk_organisationunit_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: validationruleorganisationunitlevels fk_organisationunitlevel_validationtuleid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationruleorganisationunitlevels
    ADD CONSTRAINT fk_organisationunitlevel_validationtuleid FOREIGN KEY (validationruleid) REFERENCES public.validationrule(validationruleid);


--
-- Name: orgunitgroupmembers fk_orgunitgroup_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupmembers
    ADD CONSTRAINT fk_orgunitgroup_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: orgunitgroup fk_orgunitgroup_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroup
    ADD CONSTRAINT fk_orgunitgroup_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: orgunitgroupmembers fk_orgunitgroupmembers_orgunitgroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupmembers
    ADD CONSTRAINT fk_orgunitgroupmembers_orgunitgroupid FOREIGN KEY (orgunitgroupid) REFERENCES public.orgunitgroup(orgunitgroupid);


--
-- Name: orgunitgroupsetmembers fk_orgunitgroupset_orgunitgroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupsetmembers
    ADD CONSTRAINT fk_orgunitgroupset_orgunitgroupid FOREIGN KEY (orgunitgroupid) REFERENCES public.orgunitgroup(orgunitgroupid);


--
-- Name: orgunitgroupset fk_orgunitgroupset_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupset
    ADD CONSTRAINT fk_orgunitgroupset_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: orgunitgroupsetmembers fk_orgunitgroupsetmembers_orgunitgroupsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.orgunitgroupsetmembers
    ADD CONSTRAINT fk_orgunitgroupsetmembers_orgunitgroupsetid FOREIGN KEY (orgunitgroupsetid) REFERENCES public.orgunitgroupset(orgunitgroupsetid);


--
-- Name: organisationunit fk_parentid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.organisationunit
    ADD CONSTRAINT fk_parentid FOREIGN KEY (parentid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: period fk_period_periodtypeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.period
    ADD CONSTRAINT fk_period_periodtypeid FOREIGN KEY (periodtypeid) REFERENCES public.periodtype(periodtypeid);


--
-- Name: periodboundary fk_periodboundary_periodtype; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.periodboundary
    ADD CONSTRAINT fk_periodboundary_periodtype FOREIGN KEY (offsetperiodtypeid) REFERENCES public.periodtype(periodtypeid);


--
-- Name: periodboundary fk_periodboundary_programindicator; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.periodboundary
    ADD CONSTRAINT fk_periodboundary_programindicator FOREIGN KEY (programindicatorid) REFERENCES public.programindicator(programindicatorid);


--
-- Name: predictor fk_predictor_generatorexpressionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictor
    ADD CONSTRAINT fk_predictor_generatorexpressionid FOREIGN KEY (generatorexpressionid) REFERENCES public.expression(expressionid);


--
-- Name: predictor fk_predictor_outputcomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictor
    ADD CONSTRAINT fk_predictor_outputcomboid FOREIGN KEY (generatoroutputcombo) REFERENCES public.categoryoptioncombo(categoryoptioncomboid);


--
-- Name: predictor fk_predictor_outputdataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictor
    ADD CONSTRAINT fk_predictor_outputdataelementid FOREIGN KEY (generatoroutput) REFERENCES public.dataelement(dataelementid);


--
-- Name: predictorgroupmembers fk_predictorgroup_predictorid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictorgroupmembers
    ADD CONSTRAINT fk_predictorgroup_predictorid FOREIGN KEY (predictorid) REFERENCES public.predictor(predictorid);


--
-- Name: predictorgroup fk_predictorgroup_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictorgroup
    ADD CONSTRAINT fk_predictorgroup_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: predictorgroupmembers fk_predictorgroupmembers_predictorgroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictorgroupmembers
    ADD CONSTRAINT fk_predictorgroupmembers_predictorgroupid FOREIGN KEY (predictorgroupid) REFERENCES public.predictorgroup(predictorgroupid);


--
-- Name: predictororgunitlevels fk_predictororgunitlevels_orgunitlevelid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictororgunitlevels
    ADD CONSTRAINT fk_predictororgunitlevels_orgunitlevelid FOREIGN KEY (orgunitlevelid) REFERENCES public.orgunitlevel(orgunitlevelid);


--
-- Name: predictororgunitlevels fk_predictororgunitlevels_predictorid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictororgunitlevels
    ADD CONSTRAINT fk_predictororgunitlevels_predictorid FOREIGN KEY (predictorid) REFERENCES public.predictor(predictorid);


--
-- Name: program_attributes fk_program_attributeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program_attributes
    ADD CONSTRAINT fk_program_attributeid FOREIGN KEY (trackedentityattributeid) REFERENCES public.trackedentityattribute(trackedentityattributeid);


--
-- Name: program fk_program_categorycomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT fk_program_categorycomboid FOREIGN KEY (categorycomboid) REFERENCES public.categorycombo(categorycomboid);


--
-- Name: program fk_program_dataentryformid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT fk_program_dataentryformid FOREIGN KEY (dataentryformid) REFERENCES public.dataentryform(dataentryformid);


--
-- Name: program fk_program_expiryperiodtypeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT fk_program_expiryperiodtypeid FOREIGN KEY (expiryperiodtypeid) REFERENCES public.periodtype(periodtypeid);


--
-- Name: program_organisationunits fk_program_organisationunits_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program_organisationunits
    ADD CONSTRAINT fk_program_organisationunits_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: program_organisationunits fk_program_organisationunits_programid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program_organisationunits
    ADD CONSTRAINT fk_program_organisationunits_programid FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: programsection fk_program_programid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programsection
    ADD CONSTRAINT fk_program_programid FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: programstagesection fk_program_programstageid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagesection
    ADD CONSTRAINT fk_program_programstageid FOREIGN KEY (programstageid) REFERENCES public.programstage(programstageid);


--
-- Name: program fk_program_relatedprogram; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT fk_program_relatedprogram FOREIGN KEY (relatedprogramid) REFERENCES public.program(programid);


--
-- Name: program fk_program_trackedentitytypeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT fk_program_trackedentitytypeid FOREIGN KEY (trackedentitytypeid) REFERENCES public.trackedentitytype(trackedentitytypeid);


--
-- Name: program fk_program_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT fk_program_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: programindicatorlegendsets fk_programindicator_legendsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicatorlegendsets
    ADD CONSTRAINT fk_programindicator_legendsetid FOREIGN KEY (legendsetid) REFERENCES public.maplegendset(maplegendsetid);


--
-- Name: programindicator fk_programindicator_program; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicator
    ADD CONSTRAINT fk_programindicator_program FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: programindicator fk_programindicator_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicator
    ADD CONSTRAINT fk_programindicator_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: programindicatorgroupmembers fk_programindicatorgroup_programindicatorid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicatorgroupmembers
    ADD CONSTRAINT fk_programindicatorgroup_programindicatorid FOREIGN KEY (programindicatorid) REFERENCES public.programindicator(programindicatorid);


--
-- Name: programindicatorgroup fk_programindicatorgroup_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicatorgroup
    ADD CONSTRAINT fk_programindicatorgroup_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: programindicatorgroupmembers fk_programindicatorgroupmembers_programindicatorgroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicatorgroupmembers
    ADD CONSTRAINT fk_programindicatorgroupmembers_programindicatorgroupid FOREIGN KEY (programindicatorgroupid) REFERENCES public.programindicatorgroup(programindicatorgroupid);


--
-- Name: programinstance fk_programinstance_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programinstance
    ADD CONSTRAINT fk_programinstance_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: programinstance fk_programinstance_programid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programinstance
    ADD CONSTRAINT fk_programinstance_programid FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: programinstance fk_programinstance_trackedentityinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programinstance
    ADD CONSTRAINT fk_programinstance_trackedentityinstanceid FOREIGN KEY (trackedentityinstanceid) REFERENCES public.trackedentityinstance(trackedentityinstanceid);


--
-- Name: programinstancecomments fk_programinstancecomments_programinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programinstancecomments
    ADD CONSTRAINT fk_programinstancecomments_programinstanceid FOREIGN KEY (programinstanceid) REFERENCES public.programinstance(programinstanceid);


--
-- Name: programinstancecomments fk_programinstancecomments_trackedentitycommentid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programinstancecomments
    ADD CONSTRAINT fk_programinstancecomments_trackedentitycommentid FOREIGN KEY (trackedentitycommentid) REFERENCES public.trackedentitycomment(trackedentitycommentid);


--
-- Name: programmessage fk_programmessage_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programmessage
    ADD CONSTRAINT fk_programmessage_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: programmessage fk_programmessage_programinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programmessage
    ADD CONSTRAINT fk_programmessage_programinstanceid FOREIGN KEY (programinstanceid) REFERENCES public.programinstance(programinstanceid);


--
-- Name: programmessage fk_programmessage_programstageinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programmessage
    ADD CONSTRAINT fk_programmessage_programstageinstanceid FOREIGN KEY (programstageinstanceid) REFERENCES public.programstageinstance(programstageinstanceid);


--
-- Name: programmessage fk_programmessage_trackedentityinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programmessage
    ADD CONSTRAINT fk_programmessage_trackedentityinstanceid FOREIGN KEY (trackedentityinstanceid) REFERENCES public.trackedentityinstance(trackedentityinstanceid);


--
-- Name: programownershiphistory fk_programownershiphistory_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programownershiphistory
    ADD CONSTRAINT fk_programownershiphistory_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: programownershiphistory fk_programownershiphistory_programid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programownershiphistory
    ADD CONSTRAINT fk_programownershiphistory_programid FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: programownershiphistory fk_programownershiphistory_trackedentityinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programownershiphistory
    ADD CONSTRAINT fk_programownershiphistory_trackedentityinstanceid FOREIGN KEY (trackedentityinstanceid) REFERENCES public.trackedentityinstance(trackedentityinstanceid);


--
-- Name: programrule fk_programrule_program; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programrule
    ADD CONSTRAINT fk_programrule_program FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: programrule fk_programrule_programstage; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programrule
    ADD CONSTRAINT fk_programrule_programstage FOREIGN KEY (programstageid) REFERENCES public.programstage(programstageid);


--
-- Name: programruleaction fk_programruleaction_dataelement; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programruleaction
    ADD CONSTRAINT fk_programruleaction_dataelement FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: programruleaction fk_programruleaction_option; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programruleaction
    ADD CONSTRAINT fk_programruleaction_option FOREIGN KEY (optionid) REFERENCES public.optionvalue(optionvalueid);


--
-- Name: programruleaction fk_programruleaction_optiongroup; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programruleaction
    ADD CONSTRAINT fk_programruleaction_optiongroup FOREIGN KEY (optiongroupid) REFERENCES public.optiongroup(optiongroupid);


--
-- Name: programruleaction fk_programruleaction_programindicator; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programruleaction
    ADD CONSTRAINT fk_programruleaction_programindicator FOREIGN KEY (programindicatorid) REFERENCES public.programindicator(programindicatorid);


--
-- Name: programruleaction fk_programruleaction_programrule; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programruleaction
    ADD CONSTRAINT fk_programruleaction_programrule FOREIGN KEY (programruleid) REFERENCES public.programrule(programruleid);


--
-- Name: programruleaction fk_programruleaction_programstage; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programruleaction
    ADD CONSTRAINT fk_programruleaction_programstage FOREIGN KEY (programstageid) REFERENCES public.programstage(programstageid);


--
-- Name: programruleaction fk_programruleaction_programstagesection; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programruleaction
    ADD CONSTRAINT fk_programruleaction_programstagesection FOREIGN KEY (programstagesectionid) REFERENCES public.programstagesection(programstagesectionid);


--
-- Name: programruleaction fk_programruleaction_trackedentityattribute; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programruleaction
    ADD CONSTRAINT fk_programruleaction_trackedentityattribute FOREIGN KEY (trackedentityattributeid) REFERENCES public.trackedentityattribute(trackedentityattributeid);


--
-- Name: programrulevariable fk_programrulevariable_dataelement; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programrulevariable
    ADD CONSTRAINT fk_programrulevariable_dataelement FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: programrulevariable fk_programrulevariable_program; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programrulevariable
    ADD CONSTRAINT fk_programrulevariable_program FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: programrulevariable fk_programrulevariable_programstage; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programrulevariable
    ADD CONSTRAINT fk_programrulevariable_programstage FOREIGN KEY (programstageid) REFERENCES public.programstage(programstageid);


--
-- Name: programrulevariable fk_programrulevariable_trackedentityattribute; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programrulevariable
    ADD CONSTRAINT fk_programrulevariable_trackedentityattribute FOREIGN KEY (trackedentityattributeid) REFERENCES public.trackedentityattribute(trackedentityattributeid);


--
-- Name: programsection_attributes fk_programsection_attributes_trackedentityattributeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programsection_attributes
    ADD CONSTRAINT fk_programsection_attributes_trackedentityattributeid FOREIGN KEY (trackedentityattributeid) REFERENCES public.trackedentityattribute(trackedentityattributeid);


--
-- Name: programsection_attributes fk_programsections_attributes_programsectionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programsection_attributes
    ADD CONSTRAINT fk_programsections_attributes_programsectionid FOREIGN KEY (programsectionid) REFERENCES public.programsection(programsectionid);


--
-- Name: programstage fk_programstage_dataentryform; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstage
    ADD CONSTRAINT fk_programstage_dataentryform FOREIGN KEY (dataentryformid) REFERENCES public.dataentryform(dataentryformid);


--
-- Name: programstage fk_programstage_nextscheduledateid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstage
    ADD CONSTRAINT fk_programstage_nextscheduledateid FOREIGN KEY (nextscheduledateid) REFERENCES public.dataelement(dataelementid);


--
-- Name: programstage fk_programstage_periodtypeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstage
    ADD CONSTRAINT fk_programstage_periodtypeid FOREIGN KEY (periodtypeid) REFERENCES public.periodtype(periodtypeid);


--
-- Name: programstage fk_programstage_program; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstage
    ADD CONSTRAINT fk_programstage_program FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: programstage fk_programstage_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstage
    ADD CONSTRAINT fk_programstage_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: programstagedataelement fk_programstagedataelement_dataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagedataelement
    ADD CONSTRAINT fk_programstagedataelement_dataelementid FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: programstagedataelement fk_programstagedataelement_programstageid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagedataelement
    ADD CONSTRAINT fk_programstagedataelement_programstageid FOREIGN KEY (programstageid) REFERENCES public.programstage(programstageid);


--
-- Name: programstageinstance fk_programstageinstance_assigneduserid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstance
    ADD CONSTRAINT fk_programstageinstance_assigneduserid FOREIGN KEY (assigneduserid) REFERENCES public.userinfo(userinfoid);


--
-- Name: programstageinstance fk_programstageinstance_attributeoptioncomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstance
    ADD CONSTRAINT fk_programstageinstance_attributeoptioncomboid FOREIGN KEY (attributeoptioncomboid) REFERENCES public.categoryoptioncombo(categoryoptioncomboid);


--
-- Name: programstageinstance fk_programstageinstance_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstance
    ADD CONSTRAINT fk_programstageinstance_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: programstageinstance fk_programstageinstance_programinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstance
    ADD CONSTRAINT fk_programstageinstance_programinstanceid FOREIGN KEY (programinstanceid) REFERENCES public.programinstance(programinstanceid);


--
-- Name: programstageinstance fk_programstageinstance_programstageid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstance
    ADD CONSTRAINT fk_programstageinstance_programstageid FOREIGN KEY (programstageid) REFERENCES public.programstage(programstageid);


--
-- Name: programstageinstancecomments fk_programstageinstancecomments_programstageinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstancecomments
    ADD CONSTRAINT fk_programstageinstancecomments_programstageinstanceid FOREIGN KEY (programstageinstanceid) REFERENCES public.programstageinstance(programstageinstanceid);


--
-- Name: programstageinstancecomments fk_programstageinstancecomments_trackedentitycommentid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstancecomments
    ADD CONSTRAINT fk_programstageinstancecomments_trackedentitycommentid FOREIGN KEY (trackedentitycommentid) REFERENCES public.trackedentitycomment(trackedentitycommentid);


--
-- Name: programstageinstancefilter fk_programstageinstancefilter_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstancefilter
    ADD CONSTRAINT fk_programstageinstancefilter_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: programnotificationtemplate fk_programstagenotification_dataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programnotificationtemplate
    ADD CONSTRAINT fk_programstagenotification_dataelementid FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: programnotificationinstance fk_programstagenotification_pi; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programnotificationinstance
    ADD CONSTRAINT fk_programstagenotification_pi FOREIGN KEY (programinstanceid) REFERENCES public.programinstance(programinstanceid);


--
-- Name: programnotificationinstance fk_programstagenotification_psi; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programnotificationinstance
    ADD CONSTRAINT fk_programstagenotification_psi FOREIGN KEY (programstageinstanceid) REFERENCES public.programstageinstance(programstageinstanceid);


--
-- Name: programnotificationtemplate fk_programstagenotification_trackedentityattributeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programnotificationtemplate
    ADD CONSTRAINT fk_programstagenotification_trackedentityattributeid FOREIGN KEY (trackedentityattributeid) REFERENCES public.trackedentityattribute(trackedentityattributeid);


--
-- Name: programnotificationtemplate fk_programstagenotification_usergroup; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programnotificationtemplate
    ADD CONSTRAINT fk_programstagenotification_usergroup FOREIGN KEY (usergroupid) REFERENCES public.usergroup(usergroupid);


--
-- Name: programstagesection_dataelements fk_programstagesection_dataelements_dataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagesection_dataelements
    ADD CONSTRAINT fk_programstagesection_dataelements_dataelementid FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: programstagesection_dataelements fk_programstagesection_dataelements_programstagesectionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagesection_dataelements
    ADD CONSTRAINT fk_programstagesection_dataelements_programstagesectionid FOREIGN KEY (programstagesectionid) REFERENCES public.programstagesection(programstagesectionid);


--
-- Name: programstagesection_programindicators fk_programstagesection_programindicators_indicatorid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagesection_programindicators
    ADD CONSTRAINT fk_programstagesection_programindicators_indicatorid FOREIGN KEY (programindicatorid) REFERENCES public.programindicator(programindicatorid);


--
-- Name: programstagesection_programindicators fk_programstagesection_programindicators_sectionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstagesection_programindicators
    ADD CONSTRAINT fk_programstagesection_programindicators_sectionid FOREIGN KEY (programstagesectionid) REFERENCES public.programstagesection(programstagesectionid);


--
-- Name: programtempowner fk_programtempowner_programid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programtempowner
    ADD CONSTRAINT fk_programtempowner_programid FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: programtempowner fk_programtempowner_trackedentityinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programtempowner
    ADD CONSTRAINT fk_programtempowner_trackedentityinstanceid FOREIGN KEY (trackedentityinstanceid) REFERENCES public.trackedentityinstance(trackedentityinstanceid);


--
-- Name: programtempowner fk_programtempowner_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programtempowner
    ADD CONSTRAINT fk_programtempowner_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: programtempownershipaudit fk_programtempownershipaudit_programid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programtempownershipaudit
    ADD CONSTRAINT fk_programtempownershipaudit_programid FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: programtempownershipaudit fk_programtempownershipaudit_trackedentityinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programtempownershipaudit
    ADD CONSTRAINT fk_programtempownershipaudit_trackedentityinstanceid FOREIGN KEY (trackedentityinstanceid) REFERENCES public.trackedentityinstance(trackedentityinstanceid);


--
-- Name: program_attributes fk_programtrackedentityattribute_programid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program_attributes
    ADD CONSTRAINT fk_programtrackedentityattribute_programid FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: programtrackedentityattributegroupmembers fk_programtrackedentityattributegroup_attributeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programtrackedentityattributegroupmembers
    ADD CONSTRAINT fk_programtrackedentityattributegroup_attributeid FOREIGN KEY (programtrackedentityattributeid) REFERENCES public.program_attributes(programtrackedentityattributeid);


--
-- Name: programtrackedentityattributegroupmembers fk_programtrackedentityattributegroupmembers_groupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programtrackedentityattributegroupmembers
    ADD CONSTRAINT fk_programtrackedentityattributegroupmembers_groupid FOREIGN KEY (programtrackedentityattributegroupid) REFERENCES public.program_attribute_group(programtrackedentityattributegroupid);


--
-- Name: pushanalysisrecipientusergroups fk_pushanalysis_recipientusergroups; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.pushanalysisrecipientusergroups
    ADD CONSTRAINT fk_pushanalysis_recipientusergroups FOREIGN KEY (elt) REFERENCES public.usergroup(usergroupid);


--
-- Name: relationship fk_relationship_from_relationshipitemid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationship
    ADD CONSTRAINT fk_relationship_from_relationshipitemid FOREIGN KEY (from_relationshipitemid) REFERENCES public.relationshipitem(relationshipitemid) ON DELETE CASCADE;


--
-- Name: relationship fk_relationship_relationshiptypeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationship
    ADD CONSTRAINT fk_relationship_relationshiptypeid FOREIGN KEY (relationshiptypeid) REFERENCES public.relationshiptype(relationshiptypeid);


--
-- Name: relationship fk_relationship_to_relationshipitemid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationship
    ADD CONSTRAINT fk_relationship_to_relationshipitemid FOREIGN KEY (to_relationshipitemid) REFERENCES public.relationshipitem(relationshipitemid) ON DELETE CASCADE;


--
-- Name: relationshipconstraint fk_relationshipconstraint_program_programid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshipconstraint
    ADD CONSTRAINT fk_relationshipconstraint_program_programid FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: relationshipconstraint fk_relationshipconstraint_programstage_programstageid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshipconstraint
    ADD CONSTRAINT fk_relationshipconstraint_programstage_programstageid FOREIGN KEY (programstageid) REFERENCES public.programstage(programstageid);


--
-- Name: relationshipconstraint fk_relationshipconstraint_trackedentitytype_trackedentitytypeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshipconstraint
    ADD CONSTRAINT fk_relationshipconstraint_trackedentitytype_trackedentitytypeid FOREIGN KEY (trackedentitytypeid) REFERENCES public.trackedentitytype(trackedentitytypeid);


--
-- Name: relationshipitem fk_relationshipitem_programinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshipitem
    ADD CONSTRAINT fk_relationshipitem_programinstanceid FOREIGN KEY (programinstanceid) REFERENCES public.programinstance(programinstanceid);


--
-- Name: relationshipitem fk_relationshipitem_programstageinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshipitem
    ADD CONSTRAINT fk_relationshipitem_programstageinstanceid FOREIGN KEY (programstageinstanceid) REFERENCES public.programstageinstance(programstageinstanceid);


--
-- Name: relationshipitem fk_relationshipitem_relationshipid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshipitem
    ADD CONSTRAINT fk_relationshipitem_relationshipid FOREIGN KEY (relationshipid) REFERENCES public.relationship(relationshipid) ON DELETE CASCADE;


--
-- Name: relationshipitem fk_relationshipitem_trackedentityinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshipitem
    ADD CONSTRAINT fk_relationshipitem_trackedentityinstanceid FOREIGN KEY (trackedentityinstanceid) REFERENCES public.trackedentityinstance(trackedentityinstanceid);


--
-- Name: relationshiptype fk_relationshiptype_from_relationshipconstraintid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshiptype
    ADD CONSTRAINT fk_relationshiptype_from_relationshipconstraintid FOREIGN KEY (from_relationshipconstraintid) REFERENCES public.relationshipconstraint(relationshipconstraintid);


--
-- Name: relationshiptype fk_relationshiptype_to_relationshipconstraintid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshiptype
    ADD CONSTRAINT fk_relationshiptype_to_relationshipconstraintid FOREIGN KEY (to_relationshipconstraintid) REFERENCES public.relationshipconstraint(relationshipconstraintid);


--
-- Name: relationshiptype fk_relationshiptype_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.relationshiptype
    ADD CONSTRAINT fk_relationshiptype_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: report fk_report_relativeperiodsid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.report
    ADD CONSTRAINT fk_report_relativeperiodsid FOREIGN KEY (relativeperiodsid) REFERENCES public.relativeperiods(relativeperiodsid);


--
-- Name: report fk_report_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.report
    ADD CONSTRAINT fk_report_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: report fk_report_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.report
    ADD CONSTRAINT fk_report_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: sectiondataelements fk_section_dataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.sectiondataelements
    ADD CONSTRAINT fk_section_dataelementid FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: sectiongreyedfields fk_section_dataelementoperandid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.sectiongreyedfields
    ADD CONSTRAINT fk_section_dataelementoperandid FOREIGN KEY (dataelementoperandid) REFERENCES public.dataelementoperand(dataelementoperandid);


--
-- Name: section fk_section_datasetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT fk_section_datasetid FOREIGN KEY (datasetid) REFERENCES public.dataset(datasetid);


--
-- Name: sectionindicators fk_section_indicatorid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.sectionindicators
    ADD CONSTRAINT fk_section_indicatorid FOREIGN KEY (indicatorid) REFERENCES public.indicator(indicatorid);


--
-- Name: sectiondataelements fk_sectiondataelements_sectionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.sectiondataelements
    ADD CONSTRAINT fk_sectiondataelements_sectionid FOREIGN KEY (sectionid) REFERENCES public.section(sectionid);


--
-- Name: sectiongreyedfields fk_sectiongreyedfields_sectionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.sectiongreyedfields
    ADD CONSTRAINT fk_sectiongreyedfields_sectionid FOREIGN KEY (sectionid) REFERENCES public.section(sectionid);


--
-- Name: sectionindicators fk_sectionindicators_sectionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.sectionindicators
    ADD CONSTRAINT fk_sectionindicators_sectionid FOREIGN KEY (sectionid) REFERENCES public.section(sectionid);


--
-- Name: smscommands fk_smscommand_program; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscommands
    ADD CONSTRAINT fk_smscommand_program FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: smscommands fk_smscommand_programstage; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscommands
    ADD CONSTRAINT fk_smscommand_programstage FOREIGN KEY (programstageid) REFERENCES public.programstage(programstageid);


--
-- Name: smscommands fk_smscommand_usergroup; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscommands
    ADD CONSTRAINT fk_smscommand_usergroup FOREIGN KEY (usergroupid) REFERENCES public.usergroup(usergroupid);


--
-- Name: sqlview fk_sqlview_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.sqlview
    ADD CONSTRAINT fk_sqlview_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: trackedentityattributedimension fk_teattributedimension_attributeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattributedimension
    ADD CONSTRAINT fk_teattributedimension_attributeid FOREIGN KEY (trackedentityattributeid) REFERENCES public.trackedentityattribute(trackedentityattributeid);


--
-- Name: trackedentityattributedimension fk_teattributedimension_legendsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattributedimension
    ADD CONSTRAINT fk_teattributedimension_legendsetid FOREIGN KEY (legendsetid) REFERENCES public.maplegendset(maplegendsetid);


--
-- Name: trackedentitydataelementdimension fk_tedataelementdimension_dataelementid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitydataelementdimension
    ADD CONSTRAINT fk_tedataelementdimension_dataelementid FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: trackedentitydataelementdimension fk_tedataelementdimension_legendsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitydataelementdimension
    ADD CONSTRAINT fk_tedataelementdimension_legendsetid FOREIGN KEY (legendsetid) REFERENCES public.maplegendset(maplegendsetid);


--
-- Name: trackedentitydataelementdimension fk_tedataelementdimension_programstageid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitydataelementdimension
    ADD CONSTRAINT fk_tedataelementdimension_programstageid FOREIGN KEY (programstageid) REFERENCES public.programstage(programstageid);


--
-- Name: trackedentityprogramindicatordimension fk_teprogramindicatordimension_legendsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityprogramindicatordimension
    ADD CONSTRAINT fk_teprogramindicatordimension_legendsetid FOREIGN KEY (legendsetid) REFERENCES public.maplegendset(maplegendsetid);


--
-- Name: trackedentityprogramindicatordimension fk_teprogramindicatordimension_programindicatorid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityprogramindicatordimension
    ADD CONSTRAINT fk_teprogramindicatordimension_programindicatorid FOREIGN KEY (programindicatorid) REFERENCES public.programindicator(programindicatorid);


--
-- Name: trackedentityattributelegendsets fk_trackedentityattribute_legendsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattributelegendsets
    ADD CONSTRAINT fk_trackedentityattribute_legendsetid FOREIGN KEY (legendsetid) REFERENCES public.maplegendset(maplegendsetid);


--
-- Name: trackedentityattribute fk_trackedentityattribute_optionsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattribute
    ADD CONSTRAINT fk_trackedentityattribute_optionsetid FOREIGN KEY (optionsetid) REFERENCES public.optionset(optionsetid);


--
-- Name: smscodes fk_trackedentityattribute_trackedentityattributeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscodes
    ADD CONSTRAINT fk_trackedentityattribute_trackedentityattributeid FOREIGN KEY (trackedentityattributeid) REFERENCES public.trackedentityattribute(trackedentityattributeid);


--
-- Name: trackedentityattribute fk_trackedentityattribute_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattribute
    ADD CONSTRAINT fk_trackedentityattribute_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: trackedentityinstance fk_trackedentityinstance_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityinstance
    ADD CONSTRAINT fk_trackedentityinstance_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: trackedentityinstance fk_trackedentityinstance_trackedentitytypeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityinstance
    ADD CONSTRAINT fk_trackedentityinstance_trackedentitytypeid FOREIGN KEY (trackedentitytypeid) REFERENCES public.trackedentitytype(trackedentitytypeid);


--
-- Name: trackedentityinstancefilter fk_trackedentityinstancefilter_programid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityinstancefilter
    ADD CONSTRAINT fk_trackedentityinstancefilter_programid FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: trackedentityinstancefilter fk_trackedentityinstancefilter_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityinstancefilter
    ADD CONSTRAINT fk_trackedentityinstancefilter_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: trackedentityprogramowner fk_trackedentityprogramowner_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityprogramowner
    ADD CONSTRAINT fk_trackedentityprogramowner_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: trackedentityprogramowner fk_trackedentityprogramowner_programid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityprogramowner
    ADD CONSTRAINT fk_trackedentityprogramowner_programid FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: trackedentityprogramowner fk_trackedentityprogramowner_trackedentityinstanceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityprogramowner
    ADD CONSTRAINT fk_trackedentityprogramowner_trackedentityinstanceid FOREIGN KEY (trackedentityinstanceid) REFERENCES public.trackedentityinstance(trackedentityinstanceid);


--
-- Name: trackedentitytype fk_trackedentitytype_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitytype
    ADD CONSTRAINT fk_trackedentitytype_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: trackedentitytypeattribute fk_trackedentitytypeattribute_trackedentityattributeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitytypeattribute
    ADD CONSTRAINT fk_trackedentitytypeattribute_trackedentityattributeid FOREIGN KEY (trackedentityattributeid) REFERENCES public.trackedentityattribute(trackedentityattributeid);


--
-- Name: trackedentitytypeattribute fk_trackedentitytypeattribute_trackedentitytypeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentitytypeattribute
    ADD CONSTRAINT fk_trackedentitytypeattribute_trackedentitytypeid FOREIGN KEY (trackedentitytypeid) REFERENCES public.trackedentitytype(trackedentitytypeid);


--
-- Name: userinfo fk_user_fileresourceid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userinfo
    ADD CONSTRAINT fk_user_fileresourceid FOREIGN KEY (avatar) REFERENCES public.fileresource(fileresourceid);


--
-- Name: userapps fk_userapps_userinfoid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userapps
    ADD CONSTRAINT fk_userapps_userinfoid FOREIGN KEY (userinfoid) REFERENCES public.userinfo(userinfoid);


--
-- Name: userdatavieworgunits fk_userdatavieworgunits_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userdatavieworgunits
    ADD CONSTRAINT fk_userdatavieworgunits_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: userdatavieworgunits fk_userdatavieworgunits_userinfoid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userdatavieworgunits
    ADD CONSTRAINT fk_userdatavieworgunits_userinfoid FOREIGN KEY (userinfoid) REFERENCES public.userinfo(userinfoid);


--
-- Name: usergroup fk_usergroup_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usergroup
    ADD CONSTRAINT fk_usergroup_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: usergroupmanaged fk_usergroupmanaging_managedbygroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usergroupmanaged
    ADD CONSTRAINT fk_usergroupmanaging_managedbygroupid FOREIGN KEY (managedbygroupid) REFERENCES public.usergroup(usergroupid);


--
-- Name: usergroupmanaged fk_usergroupmanaging_managedgroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usergroupmanaged
    ADD CONSTRAINT fk_usergroupmanaging_managedgroupid FOREIGN KEY (managedgroupid) REFERENCES public.usergroup(usergroupid);


--
-- Name: usergroupmembers fk_usergroupmembers_usergroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usergroupmembers
    ADD CONSTRAINT fk_usergroupmembers_usergroupid FOREIGN KEY (usergroupid) REFERENCES public.usergroup(usergroupid);


--
-- Name: usergroupmembers fk_usergroupmembers_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usergroupmembers
    ADD CONSTRAINT fk_usergroupmembers_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: usermembership fk_userinfo_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usermembership
    ADD CONSTRAINT fk_userinfo_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: userkeyjsonvalue fk_userkeyjsonvalue_user; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userkeyjsonvalue
    ADD CONSTRAINT fk_userkeyjsonvalue_user FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: usermembership fk_usermembership_userinfoid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usermembership
    ADD CONSTRAINT fk_usermembership_userinfoid FOREIGN KEY (userinfoid) REFERENCES public.userinfo(userinfoid);


--
-- Name: usermessage fk_usermessage_user; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usermessage
    ADD CONSTRAINT fk_usermessage_user FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: userrole fk_userrole_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userrole
    ADD CONSTRAINT fk_userrole_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: userroleauthorities fk_userroleauthorities_userroleid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userroleauthorities
    ADD CONSTRAINT fk_userroleauthorities_userroleid FOREIGN KEY (userroleid) REFERENCES public.userrole(userroleid);


--
-- Name: userrolemembers fk_userrolemembers_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userrolemembers
    ADD CONSTRAINT fk_userrolemembers_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: userrolemembers fk_userrolemembers_userroleid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userrolemembers
    ADD CONSTRAINT fk_userrolemembers_userroleid FOREIGN KEY (userroleid) REFERENCES public.userrole(userroleid);


--
-- Name: users_catdimensionconstraints fk_users_catconstraints_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.users_catdimensionconstraints
    ADD CONSTRAINT fk_users_catconstraints_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: users_cogsdimensionconstraints fk_users_cogsconstraints_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.users_cogsdimensionconstraints
    ADD CONSTRAINT fk_users_cogsconstraints_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: usersetting fk_usersetting_userinfoid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.usersetting
    ADD CONSTRAINT fk_usersetting_userinfoid FOREIGN KEY (userinfoid) REFERENCES public.userinfo(userinfoid);


--
-- Name: userteisearchorgunits fk_userteisearchorgunits_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userteisearchorgunits
    ADD CONSTRAINT fk_userteisearchorgunits_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: userteisearchorgunits fk_userteisearchorgunits_userinfoid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.userteisearchorgunits
    ADD CONSTRAINT fk_userteisearchorgunits_userinfoid FOREIGN KEY (userinfoid) REFERENCES public.userinfo(userinfoid);


--
-- Name: validationnotificationtemplate_recipientusergroups fk_validationnotificationtemplate_usergroup; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationnotificationtemplate_recipientusergroups
    ADD CONSTRAINT fk_validationnotificationtemplate_usergroup FOREIGN KEY (validationnotificationtemplateid) REFERENCES public.validationnotificationtemplate(validationnotificationtemplateid);


--
-- Name: validationresult fk_validationresult_attributeoptioncomboid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationresult
    ADD CONSTRAINT fk_validationresult_attributeoptioncomboid FOREIGN KEY (attributeoptioncomboid) REFERENCES public.categoryoptioncombo(categoryoptioncomboid);


--
-- Name: validationresult fk_validationresult_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationresult
    ADD CONSTRAINT fk_validationresult_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: validationresult fk_validationresult_period; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationresult
    ADD CONSTRAINT fk_validationresult_period FOREIGN KEY (periodid) REFERENCES public.period(periodid);


--
-- Name: validationresult fk_validationresult_validationruleid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationresult
    ADD CONSTRAINT fk_validationresult_validationruleid FOREIGN KEY (validationruleid) REFERENCES public.validationrule(validationruleid);


--
-- Name: validationrule fk_validationrule_leftexpressionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrule
    ADD CONSTRAINT fk_validationrule_leftexpressionid FOREIGN KEY (leftexpressionid) REFERENCES public.expression(expressionid);


--
-- Name: predictor fk_validationrule_periodtypeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictor
    ADD CONSTRAINT fk_validationrule_periodtypeid FOREIGN KEY (periodtypeid) REFERENCES public.periodtype(periodtypeid);


--
-- Name: validationrule fk_validationrule_periodtypeid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrule
    ADD CONSTRAINT fk_validationrule_periodtypeid FOREIGN KEY (periodtypeid) REFERENCES public.periodtype(periodtypeid);


--
-- Name: validationrule fk_validationrule_rightexpressionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrule
    ADD CONSTRAINT fk_validationrule_rightexpressionid FOREIGN KEY (rightexpressionid) REFERENCES public.expression(expressionid);


--
-- Name: predictor fk_validationrule_skiptestexpressionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.predictor
    ADD CONSTRAINT fk_validationrule_skiptestexpressionid FOREIGN KEY (skiptestexpressionid) REFERENCES public.expression(expressionid);


--
-- Name: validationrule fk_validationrule_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrule
    ADD CONSTRAINT fk_validationrule_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: validationnotificationtemplatevalidationrules fk_validationrule_validationnotificationtemplateid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationnotificationtemplatevalidationrules
    ADD CONSTRAINT fk_validationrule_validationnotificationtemplateid FOREIGN KEY (validationruleid) REFERENCES public.validationrule(validationruleid);


--
-- Name: validationrulegroup fk_validationrulegroup_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrulegroup
    ADD CONSTRAINT fk_validationrulegroup_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: validationrulegroupmembers fk_validationrulegroup_validationruleid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrulegroupmembers
    ADD CONSTRAINT fk_validationrulegroup_validationruleid FOREIGN KEY (validationruleid) REFERENCES public.validationrule(validationruleid);


--
-- Name: validationrulegroupmembers fk_validationrulegroupmembers_validationrulegroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.validationrulegroupmembers
    ADD CONSTRAINT fk_validationrulegroupmembers_validationrulegroupid FOREIGN KEY (validationgroupid) REFERENCES public.validationrulegroup(validationrulegroupid);


--
-- Name: visualization_axis fk_visualization_axis_axisid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_axis
    ADD CONSTRAINT fk_visualization_axis_axisid FOREIGN KEY (axisid) REFERENCES public.axis(axisid);


--
-- Name: visualization_axis fk_visualization_axis_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_axis
    ADD CONSTRAINT fk_visualization_axis_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: visualization_categorydimensions fk_visualization_categorydimensions_categorydimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_categorydimensions
    ADD CONSTRAINT fk_visualization_categorydimensions_categorydimensionid FOREIGN KEY (categorydimensionid) REFERENCES public.categorydimension(categorydimensionid);


--
-- Name: visualization_categorydimensions fk_visualization_categorydimensions_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_categorydimensions
    ADD CONSTRAINT fk_visualization_categorydimensions_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: visualization_categoryoptiongroupsetdimensions fk_visualization_catoptiongroupsetdimensions_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_categoryoptiongroupsetdimensions
    ADD CONSTRAINT fk_visualization_catoptiongroupsetdimensions_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: visualization_columns fk_visualization_columns_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_columns
    ADD CONSTRAINT fk_visualization_columns_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: visualization_datadimensionitems fk_visualization_datadimensionitems_datadimensionitemid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_datadimensionitems
    ADD CONSTRAINT fk_visualization_datadimensionitems_datadimensionitemid FOREIGN KEY (datadimensionitemid) REFERENCES public.datadimensionitem(datadimensionitemid);


--
-- Name: visualization_datadimensionitems fk_visualization_datadimensionitems_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_datadimensionitems
    ADD CONSTRAINT fk_visualization_datadimensionitems_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: visualization_dataelementgroupsetdimensions fk_visualization_dataelementgroupsetdimensions_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_dataelementgroupsetdimensions
    ADD CONSTRAINT fk_visualization_dataelementgroupsetdimensions_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: visualization_categoryoptiongroupsetdimensions fk_visualization_dimensions_catoptiongroupsetdimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_categoryoptiongroupsetdimensions
    ADD CONSTRAINT fk_visualization_dimensions_catoptiongroupsetdimensionid FOREIGN KEY (categoryoptiongroupsetdimensionid) REFERENCES public.categoryoptiongroupsetdimension(categoryoptiongroupsetdimensionid);


--
-- Name: visualization_dataelementgroupsetdimensions fk_visualization_dimensions_dataelementgroupsetdimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_dataelementgroupsetdimensions
    ADD CONSTRAINT fk_visualization_dimensions_dataelementgroupsetdimensionid FOREIGN KEY (dataelementgroupsetdimensionid) REFERENCES public.dataelementgroupsetdimension(dataelementgroupsetdimensionid);


--
-- Name: visualization_orgunitgroupsetdimensions fk_visualization_dimensions_orgunitgroupsetdimensionid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_orgunitgroupsetdimensions
    ADD CONSTRAINT fk_visualization_dimensions_orgunitgroupsetdimensionid FOREIGN KEY (orgunitgroupsetdimensionid) REFERENCES public.orgunitgroupsetdimension(orgunitgroupsetdimensionid);


--
-- Name: visualization_filters fk_visualization_filters_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_filters
    ADD CONSTRAINT fk_visualization_filters_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: visualization_itemorgunitgroups fk_visualization_itemorgunitgroups_orgunitgroupid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_itemorgunitgroups
    ADD CONSTRAINT fk_visualization_itemorgunitgroups_orgunitgroupid FOREIGN KEY (orgunitgroupid) REFERENCES public.orgunitgroup(orgunitgroupid);


--
-- Name: visualization_itemorgunitgroups fk_visualization_itemorgunitunitgroups_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_itemorgunitgroups
    ADD CONSTRAINT fk_visualization_itemorgunitunitgroups_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: visualization fk_visualization_lastupdateby; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization
    ADD CONSTRAINT fk_visualization_lastupdateby FOREIGN KEY (lastupdatedby) REFERENCES public.userinfo(userinfoid);


--
-- Name: visualization fk_visualization_legendsetid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization
    ADD CONSTRAINT fk_visualization_legendsetid FOREIGN KEY (legendsetid) REFERENCES public.maplegendset(maplegendsetid);


--
-- Name: visualization_organisationunits fk_visualization_organisationunits_organisationunitid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_organisationunits
    ADD CONSTRAINT fk_visualization_organisationunits_organisationunitid FOREIGN KEY (organisationunitid) REFERENCES public.organisationunit(organisationunitid);


--
-- Name: visualization_organisationunits fk_visualization_organisationunits_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_organisationunits
    ADD CONSTRAINT fk_visualization_organisationunits_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: visualization_orgunitgroupsetdimensions fk_visualization_orgunitgroupsetdimensions_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_orgunitgroupsetdimensions
    ADD CONSTRAINT fk_visualization_orgunitgroupsetdimensions_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: visualization_orgunitlevels fk_visualization_orgunitlevels_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_orgunitlevels
    ADD CONSTRAINT fk_visualization_orgunitlevels_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: visualization_periods fk_visualization_periods_periodid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_periods
    ADD CONSTRAINT fk_visualization_periods_periodid FOREIGN KEY (periodid) REFERENCES public.period(periodid);


--
-- Name: visualization_periods fk_visualization_periods_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_periods
    ADD CONSTRAINT fk_visualization_periods_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: visualization fk_visualization_relativeperiodsid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization
    ADD CONSTRAINT fk_visualization_relativeperiodsid FOREIGN KEY (relativeperiodsid) REFERENCES public.relativeperiods(relativeperiodsid);


--
-- Name: visualization_rows fk_visualization_rows_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_rows
    ADD CONSTRAINT fk_visualization_rows_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: visualization fk_visualization_userid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization
    ADD CONSTRAINT fk_visualization_userid FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: visualization_yearlyseries fk_visualization_yearlyseries_visualizationid; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.visualization_yearlyseries
    ADD CONSTRAINT fk_visualization_yearlyseries_visualizationid FOREIGN KEY (visualizationid) REFERENCES public.visualization(visualizationid);


--
-- Name: dataelementlegendsets fkbrsplevygf9yr4hvydhix39ug; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.dataelementlegendsets
    ADD CONSTRAINT fkbrsplevygf9yr4hvydhix39ug FOREIGN KEY (dataelementid) REFERENCES public.dataelement(dataelementid);


--
-- Name: programmessage_emailaddresses fkbyaw75hj8du8w14hpuhxj762w; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programmessage_emailaddresses
    ADD CONSTRAINT fkbyaw75hj8du8w14hpuhxj762w FOREIGN KEY (programmessageemailaddressid) REFERENCES public.programmessage(id);


--
-- Name: smscommandcodes fkc6ibwny8jp0hq6l6w0w2untt4; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscommandcodes
    ADD CONSTRAINT fkc6ibwny8jp0hq6l6w0w2untt4 FOREIGN KEY (id) REFERENCES public.smscommands(smscommandid);


--
-- Name: trackedentityattributelegendsets fkcdkajbb0rpnpwuo57i894s0dg; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.trackedentityattributelegendsets
    ADD CONSTRAINT fkcdkajbb0rpnpwuo57i894s0dg FOREIGN KEY (trackedentityattributeid) REFERENCES public.trackedentityattribute(trackedentityattributeid);


--
-- Name: smscommandspecialcharacters fkch98ncn24f71dft102f7of537; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscommandspecialcharacters
    ADD CONSTRAINT fkch98ncn24f71dft102f7of537 FOREIGN KEY (smscommandid) REFERENCES public.smscommands(smscommandid);


--
-- Name: programstageinstance_messageconversation fkdmc46bnsqath7p6mrsrb89eml; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstance_messageconversation
    ADD CONSTRAINT fkdmc46bnsqath7p6mrsrb89eml FOREIGN KEY (messageconversationid) REFERENCES public.messageconversation(messageconversationid);


--
-- Name: smscommandcodes fke1eymlpayuhawlo8pfuwue654; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscommandcodes
    ADD CONSTRAINT fke1eymlpayuhawlo8pfuwue654 FOREIGN KEY (codeid) REFERENCES public.smscodes(smscodeid);


--
-- Name: datasetnotification_datasets fken6g44y648k1fembweltcao3e; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetnotification_datasets
    ADD CONSTRAINT fken6g44y648k1fembweltcao3e FOREIGN KEY (datasetid) REFERENCES public.dataset(datasetid);


--
-- Name: previouspasswords fkg6n5kwuhypwdvkn15ke824kpb; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.previouspasswords
    ADD CONSTRAINT fkg6n5kwuhypwdvkn15ke824kpb FOREIGN KEY (userid) REFERENCES public.userinfo(userinfoid);


--
-- Name: program_userroles fkgb55kdvtf92qykh2840inyhst; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.program_userroles
    ADD CONSTRAINT fkgb55kdvtf92qykh2840inyhst FOREIGN KEY (programid) REFERENCES public.program(programid);


--
-- Name: pushanalysis fkibpy72i2p9nfkdtqqe6my34nr; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.pushanalysis
    ADD CONSTRAINT fkibpy72i2p9nfkdtqqe6my34nr FOREIGN KEY (dashboard) REFERENCES public.dashboard(dashboardid);


--
-- Name: programinstance_messageconversation fkj3dr5vrqclcaodu7x4rm1qsbo; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programinstance_messageconversation
    ADD CONSTRAINT fkj3dr5vrqclcaodu7x4rm1qsbo FOREIGN KEY (programinstanceid) REFERENCES public.programinstance(programinstanceid);


--
-- Name: programinstance_messageconversation fkjy8ap861np4x3c5glxv8l8719; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programinstance_messageconversation
    ADD CONSTRAINT fkjy8ap861np4x3c5glxv8l8719 FOREIGN KEY (messageconversationid) REFERENCES public.messageconversation(messageconversationid);


--
-- Name: programindicatorlegendsets fkkbd9rqv83w4nwogj5fchtxj9y; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programindicatorlegendsets
    ADD CONSTRAINT fkkbd9rqv83w4nwogj5fchtxj9y FOREIGN KEY (programindicatorid) REFERENCES public.programindicator(programindicatorid);


--
-- Name: programstageinstance_messageconversation fkks9i10v8xg7d22hlhmesia51l; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programstageinstance_messageconversation
    ADD CONSTRAINT fkks9i10v8xg7d22hlhmesia51l FOREIGN KEY (programstageinstanceid) REFERENCES public.programstageinstance(programstageinstanceid);


--
-- Name: outbound_sms_recipients fkktmkxjuo5b3v1q2jqk7lymh0p; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.outbound_sms_recipients
    ADD CONSTRAINT fkktmkxjuo5b3v1q2jqk7lymh0p FOREIGN KEY (outbound_sms_id) REFERENCES public.outbound_sms(id);


--
-- Name: programmessage_deliverychannels fkljv6vp4ro5l6stx7dclnkenen; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.programmessage_deliverychannels
    ADD CONSTRAINT fkljv6vp4ro5l6stx7dclnkenen FOREIGN KEY (programmessagedeliverychannelsid) REFERENCES public.programmessage(id);


--
-- Name: pushanalysisrecipientusergroups fklllvhilfsouycft98q82ph66q; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.pushanalysisrecipientusergroups
    ADD CONSTRAINT fklllvhilfsouycft98q82ph66q FOREIGN KEY (usergroupid) REFERENCES public.pushanalysis(pushanalysisid);


--
-- Name: datasetnotificationtemplate_deliverychannel fkpmebskggkjfjfwxw7u43twmg2; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.datasetnotificationtemplate_deliverychannel
    ADD CONSTRAINT fkpmebskggkjfjfwxw7u43twmg2 FOREIGN KEY (datasetnotificationtemplateid) REFERENCES public.datasetnotificationtemplate(datasetnotificationtemplateid);


--
-- Name: smscommandspecialcharacters fktl0s6blarqvbvjhnoa94drtb2; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.smscommandspecialcharacters
    ADD CONSTRAINT fktl0s6blarqvbvjhnoa94drtb2 FOREIGN KEY (specialcharacterid) REFERENCES public.smsspecialcharacter(specialcharacterid);


--
-- Name: potentialduplicate potentialduplicate_lastupdatedby_user; Type: FK CONSTRAINT; Schema: public; Owner: dhis
--

ALTER TABLE ONLY public.potentialduplicate
    ADD CONSTRAINT potentialduplicate_lastupdatedby_user FOREIGN KEY (lastupdatebyusername) REFERENCES public.userinfo(username);


--
-- PostgreSQL database dump complete
--

