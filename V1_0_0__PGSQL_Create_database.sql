--create database "documentflow-dev-test1";

DO
$create_role$
  BEGIN
--    IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'documentflow-dev') THEN
    IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '') THEN
--      RAISE NOTICE 'Role "documentflow-dev" already exists. Skipping.';
      RAISE NOTICE 'Role "user-dev" already exists. Skipping.';
    ELSE
      BEGIN
        -- nested block
--        CREATE ROLE "documentflow-dev" LOGIN PASSWORD 'documentflow-dev';
        CREATE ROLE "user-dev" LOGIN PASSWORD 'user-dev';
      EXCEPTION
--        WHEN duplicate_object THEN RAISE NOTICE 'Role "documentflow-dev" was just created by a concurrent transaction. Skipping.';
        WHEN duplicate_object THEN RAISE NOTICE 'Role "user-dev" was just created by a concurrent transaction. Skipping.';
      END;
    END IF;
  END
$create_role$;

GRANT SELECT, INSERT, UPDATE, DELETE
  ON ALL TABLES
  IN SCHEMA public
--  TO "documentflow-dev";
  TO "user-dev";
-- Enable this for all new tables.
ALTER DEFAULT PRIVILEGES
  GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLES
--  TO "documentflow-dev";
  TO "user-dev";

-- Allow our user to use SEQUENCES.
-- ALTER DEFAULT PRIVILEGES FOR ROLE "artem.brik" IN SCHEMA public GRANT SELECT ON TABLES TO "user-dev";

-- It's required to insert data with auto-incrementing primary keys for instance.
--GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO "documentflow-dev";
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO "user-dev";
ALTER DEFAULT PRIVILEGES
  GRANT USAGE, SELECT
  ON SEQUENCES
--  TO "documentflow-dev";
  TO "user-dev";


REVOKE GRANT OPTION
  FOR ALL PRIVILEGES
  ON ALL TABLES
  IN SCHEMA public
--  FROM "documentflow-dev";
  FROM "user-dev";
ALTER DEFAULT PRIVILEGES
  REVOKE GRANT OPTION
  FOR ALL PRIVILEGES
  ON TABLES
--  FROM "documentflow-dev";
  FROM "user-dev";


create table if not exists public.sysclasses
(
  id          uuid    default gen_random_uuid()                            not null
    primary key,
  tablename   varchar(128) unique                                          not null,
  baseclassid uuid    default '00000000-0000-0000-0000-000000000000'::uuid not null,
  isdisabled  boolean default false                                        not null
);

create table if not exists public.sysclassfields
(
  id           uuid    default gen_random_uuid() not null
    primary key,
  classid      uuid                              not null
    references public.sysclasses,
  name         varchar(128)                      not null,
  fieldtype    varchar(128)                      not null,
  defaultvalue varchar,
  isprimarykey boolean default false             not null,
  isnullable   boolean default false             not null,
  isdisabled   boolean default false             not null,
  refclassid   uuid,
  CONSTRAINT sysclassfields_classid_name_key UNIQUE (classid, name)
    INCLUDE (id, classid, name, fieldtype, defaultvalue, isprimarykey, isnullable, isdisabled, refclassid)
);

create table if not exists public.sysbaseobjects
(
  id              uuid    default gen_random_uuid()              not null
    primary key,
  code            varchar(128) generated always as (name) stored not null,
  name            varchar(128) unique                            not null
    constraint sysbaseobjects_name_idx unique,
  caption         varchar(128)                                   not null,
  objecttype      varchar(64)                                    not null,
  classid         uuid                                           not null
    references public.sysclasses,
  isvirtualobject boolean default false                          not null,
  isdisabled      boolean default false                          not null
);


create table if not exists public.sysobjectactions
(
--  id         bigint primary key generated always as identity (increment 1 start 1 minvalue 1)  not null,
  id         bigserial primary key                                                             not null,
  name       varchar(64) unique                                                                not null,
  caption    varchar(128)                                                                      not null,
  isdisabled boolean default false                                                             not null
);



create table if not exists public.refdocumentgroups
(
  id         uuid    default gen_random_uuid() primary key                not null,
  code       varchar(32) unique                                           not null,
  caption    varchar(128)                                                 not null,
  parentid   uuid    default '00000000-0000-0000-0000-000000000000'::uuid not null,
  isvirtual  boolean default false                                        not null,
  isdisabled boolean default false                                        not null
);

insert into public.refdocumentgroups(id, code, caption)
values ('8849b98a-0bbd-4367-b708-befe3ea539ba', '', 'general group');

create table if not exists public.sysdocumenttypes
(
  id              uuid                                                                                    not null --default gen_random_uuid()
    primary key references public.sysbaseobjects,
  documentgroupid uuid                                                                                    not null references public.refdocumentgroups,
  parentid        uuid    default '00000000-0000-0000-0000-000000000000'::uuid                            not null,
  ishavechild     boolean default false                                                                   not null,
  isversionenabled boolean default false,
  ischild         boolean generated always as (parentid != '00000000-0000-0000-0000-000000000000') stored not null
  
);

create table if not exists public.sysreferences
(
  id            uuid primary key      not null --default gen_random_uuid()
    references public.sysbaseobjects,
  isclientstore boolean default false not null
);

-- Table: public.refcompanies
-- DROP TABLE IF EXISTS public.refcompanies;
create table if not exists public.refcompanies
(
  id              uuid    default gen_random_uuid()                            not null
    primary key,
  code            varchar(32)                                                  not null
    unique,
  parentid        uuid    default '00000000-0000-0000-0000-000000000000'::uuid not null,
  isdisabled      boolean default false                                        not null,
  caption         varchar(256)                                                 not null,
  externalversion bigint  default '-1'::bigint                                 not null
);

create table if not exists public.refsubdivisions
(
  id              uuid    default gen_random_uuid()                            not null
    primary key,
  code            varchar(32)                                                  not null
    unique,
  caption         varchar(256)                                                 not null,
  parentid        uuid    default '00000000-0000-0000-0000-000000000000'::uuid not null,
  companyid       uuid                                                         not null
    references public.refcompanies,
  isdisabled      boolean default false                                        not null,
  iscanberanked   boolean default false                                        not null,
  isimported      boolean default false                                        not null,
  externalversion bigint  default '-1'::bigint                                 not null
--    businessfunctionid uuid                                                         not null
--        references public._refbusinessfunctions
);

create table if not exists public.refjobpositions
(
  id        uuid    default gen_random_uuid() primary key not null,
  code      varchar(32) unique                            not null,
  caption   varchar(256)                                  not null,
  companyid uuid                                          not null references public.refcompanies,
  isdisable boolean default false                         not null
);

create table if not exists public.sysusers
(
    id              uuid    default gen_random_uuid() not null
        primary key,
    username        varchar(128)                      not null
        unique,
    displayname     varchar(256)                      not null,
    isdisabled      boolean default false             not null
--  isimported      boolean default false             not null,
--  usersource      varchar(128),
--  externalversion bigint  default '-1'::bigint      not null
);
create table if not exists public.refuserdetails
(
    id              uuid primary key not null
        references public.sysusers,
    firstname       varchar(128)     not null,
    lastname        varchar(128)     not null,
    email           varchar(128),
    activecompanyid uuid
        references public.refcompanies
);

create table if not exists public.refemploees
(
--  id            uuid default gen_random_uuid() primary key not null,
  userid        uuid                                       not null references public.sysusers,
  subdivisionid uuid                                       not null references public.refsubdivisions,
  joppositionid uuid                                       not null references public.refjobpositions,
  CONSTRAINT refemploees_pkey PRIMARY KEY (userid, subdivisionid, joppositionid)
);

create table if not exists public.refdocumentstatuses
(
  id         bigint primary key,
  code       varchar(64) unique not null,
  caption    varchar(128)       not null,
  isdisabled boolean default false
);

create table if not exists public.refactionbystatuses
(
    id           uuid default gen_random_uuid() primary key not null,
    objecttypeid uuid references public.sysbaseobjects      not null,
    actionid     bigint references public.sysobjectactions  not null,
    status       int references public.refdocumentstatuses  not null
);



create table if not exists public.docbasedocuments
(
  id             uuid                     default gen_random_uuid()                            not null
    primary key,
  documenttypeid uuid                                                                          not null
    references public.sysdocumenttypes,
  documentnumber varchar(32)                                                                   not null,

  parentid       uuid                     default '00000000-0000-0000-0000-000000000000'::uuid not null, --references public.docbasedocuments,
  versionid      uuid                                                                          not null,
--    documentstatus varchar(64) default 'empty'                                                   not null,
  documentstatus bigint                   default '0'::bigint                                  not null references public.refdocumentstatuses,
  creationtime   timestamp with time zone default now(),
  statustime     timestamp with time zone default now()                                        not null,
  changetime     timestamp with time zone default now()                                        not null,
  sourceid       uuid
    references public.docbasedocuments,
  externalid     varchar(128),
  isimported     boolean                  default false                                        not null
);


create table if not exists public.docownerdocuments
(
  id            uuid not null primary key references public.docbasedocuments,
  companyid     uuid not null references public.refcompanies,
  subdivisionid uuid not null references public.refsubdivisions,
  userid        uuid not null references public.sysusers
);

create table if not exists public.docdocumentversions
(
  id            uuid                     default gen_random_uuid()                            not null
    primary key,
--  versionnumber bigserial generated always as identity (increment 1 start 1 minvalue 1 )      not null, --  maxvalue 9223372036854775807 cache 1,
  versionnumber bigserial       not null, --  maxvalue 9223372036854775807 cache 1,
  code          varchar(32) generated always as (versionnumber::character varying(32)) stored not null,
  caption       varchar(512)                                                                  not null,
  versiondate   timestamp with time zone default now()                                        not null,
  documentid    uuid                                                                          not null
    references public.docbasedocuments,
  isdisabled    boolean                  default false                                        not null
);

-- SEQUENCE: public.docdocumentversions_versionnumber_seq
-- DROP SEQUENCE IF EXISTS public.docdocumentversions_versionnumber_seq;
--create sequence if not exists public.docdocumentversions_versionnumber_seq;
--alter sequence public.docdocumentversions_versionnumber_seq owned by public.docdocumentversions.versionnumber;

/* ================================================================================================================== */
create table if not exists public.refcounterpartytypes
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null, -- unique,
  caption    varchar(128)                                  not null,
  islegal    boolean                                       not null,
  isdisabled boolean default false                         not null
);

insert into public.refcounterpartytypes
values ('45338464-0142-4e27-9ca2-b4ecbc8bb269', '', 'Фізична особа', false, false),
       ('78b1c536-721e-42f2-8b7f-3656462f7352', '', 'Фізична особа, нерезидент', false, false),
       ('b4323eb6-4135-40a3-8b6f-4c6e5988a18b', '', 'Юридична особа', true, false),
       ('cc59bf3c-9575-449a-8668-a4683d0c5754', '', 'ФОП (фізична особа-підприємець)', true, false),
       ('8b9a52b4-34fe-4de3-bb90-eb1b13e69651', '', 'Об''єднання громадян', true, false),
       ('093d6354-4cd2-472a-b985-9f0a35945728', '', 'Платник податку що не підлягає включенню в ЄДР', true, false)
ON CONFLICT(id) DO NOTHING;


create table if not exists public.refidentitydocumenttypes
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null, -- unique,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refidentitydocumenttypes
values ('5aa1bc7f-f09b-48dd-a9db-8822f9742285', '', 'Паспорт громадянина Украіни', false),
       ('83e67125-278c-4428-b51b-6e1c2ebb7d88', '', 'Тимчасове посвідчення громадянина Украіни', false),
       ('1fed53a5-c3e8-45e3-a6bb-0adcfffff158', '', 'Посвідка на постійне проживання', false),
       ('3a6195d0-62b6-4095-942b-6ad4b6ffd471', '', 'Посвідка на тимчасове проживання', false),
       ('3e365c60-748d-4ee5-9c2a-2cbdda038315', '', 'Картка мігранта', false),
       ('1770005c-341d-42b4-bc69-25e895f1e551', '', 'Паспорт громадянина іноземної держави', false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refconsumercategories
(
  id           uuid    default gen_random_uuid() primary key not null,
  code         varchar(16)                                   not null unique,
  caption      varchar(128)                                  not null,
  iscontragent boolean                                       not null,
  isdisabled   boolean default false                         not null
);

insert into public.refconsumercategories
values ('ed65d119-40db-4d45-93db-22afa90f3faa', '3', 'Теплоенергетика', true, false),
       ('b6290844-b50e-46c3-8e5c-3c8fdd8daf61', '1', 'Промисловість', true, false),
       ('35be47ec-4cc8-46c0-9e24-3d57231b3fb3', '5', 'Населення', true, false),
       ('13993031-24cb-4a35-b4d6-8ac2781164cb', '4', 'Релігія', true, false),
       ('194c245f-bf09-4ca8-b9d5-af05f6a7c6ef', '2', 'Бюджет', true, false),
       ('08548142-1e5d-4b52-bceb-f6b5b129477f', '6', 'Несанкціонований споживач', false, false)
ON CONFLICT(id) DO NOTHING;

/*
skiped references
RefMinimumPressureValues
*/

create table if not exists public.refaddresses
(
  id         uuid    default gen_random_uuid() primary key not null,
  country    varchar(128)                                  not null,
  zipcode    varchar(16)                                   not null,
  region     varchar(128)                                  not null,
  district   varchar(128)                                  not null,
  settlement varchar(128)                                  not null,
  streettype varchar(16)                                   not null,
  street     varchar(128)                                  not null,
  house      varchar(8)                                    ,
  apartment  varchar(8)                                    ,
  cadastralnumber varchar(32),
  isdisabled boolean default false                         not null
);

create table if not exists public.refstreettypes
(
  id                 uuid    default gen_random_uuid() primary key not null,
  caption      varchar(128)                                  not null,
  isdisabled   boolean default false                         not null
);

insert into public.refstreettypes values
  ('3c79ea79-1cce-486e-892d-db960550e682',  'вулиця', false),
 ('d5fb55ec-7245-4629-a1df-d42ddbca569e',  'бульвар', false),
 ('74cc9eb1-79bf-4898-a116-1039ac9d7ecb',  'площа', false),
 ('594e33d7-2f0e-4caf-a0d3-79f17784e8a6',  'проспект', false),
 ('a0ed2b58-8d25-4b10-a83f-ff587719a16d',  'провулок', false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refaddresstypes
(
  id                 uuid    default gen_random_uuid() primary key not null,
  code varchar(32) not null default '',
  caption      varchar(128)                                  not null,
  isdisabled   boolean default false                         not null
);

insert into public.refaddresstypes values
  ('b9f532d0-3a3a-487f-b9b0-600250effcb7',  'адреса реєстрації', false),
  ('e44b19fb-f138-4fa0-8d52-18c29dae2f12',  'адреса проживання', false),
  ('985f2fa0-5dc6-4e03-b016-10214e4da56b',  'адреса доставки', false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refcounterparties
(
  id                 uuid    default gen_random_uuid() primary key not null,
  counterpartytypeid uuid                                          not null references public.refcounterpartytypes,
  code               varchar(32)                                   not null,
  caption varchar(1024) generated always as ( COALESCE(shortname, longname) ) stored,
  shortname          varchar(256),
  longname           varchar(1024)                                  not null,
  taxnumber          varchar(12),
  vatnumber          varchar(16),
  parentid           uuid references refcounterparties,
  phones             varchar(128)                                  not null,
  email              varchar(128),
  firstname          varchar(64),
  patronymicname     varchar(64),
  lastname           varchar(128),
  birthdate          timestamp with time zone,
  istaxnumberrefusal boolean default false                         not null,
  isdisabled         boolean default false                         not null,
  isvalidated        boolean default false                         not null,
  consumercategoryid uuid references public.refconsumercategories,--refconsumertype:        ireferencecore;
  personalaccount    varchar(32),
  eicxcode           varchar(32)
);

create table if not exists public.refcounterpartyaddresses
(
  id             uuid default gen_random_uuid() primary key not null,
  counterpartyid uuid                                       not null references public.refcounterparties,
  addresstypeid uuid                               not null references public.refaddresstypes,
  country    varchar(128)                                  not null,
  zipcode    varchar(16)                                   not null,
  region     varchar(128)                                  not null,
  district   varchar(128)                                  not null,
  settlement varchar(128)                                  not null,
  streettype varchar(16)                                   not null,
  street     varchar(128)                                  not null,
  house      varchar(8)                                    ,
  apartment  varchar(8)                                    ,
  isdisabled   boolean default false                         not null
);


/* ????????? */
create table if not exists public.refcustomerobjects
(
  id             uuid default gen_random_uuid() primary key not null,
  counterpartyid uuid                                       not null references public.refcounterparties,
  objectname     varchar(128)                               not null,
  country    varchar(128)                                  not null,
  zipcode    varchar(16)                                   not null,
  region     varchar(128)                                  not null,
  district   varchar(128)                                  not null,
  settlement varchar(128)                                  not null,
  streettype varchar(16)                                   not null,
  street     varchar(128)                                  not null,
  house      varchar(8)                                    ,
  apartment  varchar(8)                                    ,
--  addressid      uuid                                       not null references public.refaddresses
  cadastralnumber varchar(32),
  isdisabled   boolean default false                         not null
);


create table if not exists public.refidentitydocuments
(
  id                     uuid    default gen_random_uuid() primary key not null,
  counterpartyid         uuid                                          not null references public.refcounterparties,
  identitydocumenttypeid uuid                                          not null references public.refidentitydocumenttypes,
--refidentitydocumenttype: refidentitydocumenttype;
  documentnumber         varchar(16)                                   not null,
  registernumber         varchar(16)                                   not null,
  issuedate              timestamp with time zone                      not null,
  authoritythatissued    varchar(256)                                  not null,
  startdate              timestamp with time zone,
  enddate                timestamp with time zone,
  isdisabled             boolean default false                         not null
);

create table if not exists public.refmanagementadministrators
(
  id         uuid    default gen_random_uuid() primary key                not null,
  caption    varchar(128)                                                 not null,
  --regionid uuid,
  parentid   uuid    default '00000000-0000-0000-0000-000000000000'::uuid not null,
  companyid  uuid                                                         not null references public.refcompanies,

  isgroup    boolean default false                                        not null,
  isdisabled boolean default false                                        not null
);
/*
insert into public.refmanagementadministrators values ('b54afa6e-708f-45fe-bb5f-2ef45dc50098', 'Гайсинське УЕГГ', '00000000-0000-0000-0000-000000000000', '15003c84-0f5d-0904-11e1-48164464887e', true, false);
insert into public.refmanagementadministrators values ('714db6ca-ca62-4d0e-92d2-71f4fba6f0c6', 'Тульчинське УЕГГ', '00000000-0000-0000-0000-000000000000', '15003c84-0f5d-0904-11e1-48164464887e', true, false);
*/

create table if not exists public.refcustomerservices
(
  id         uuid    default gen_random_uuid() primary key                not null,
  code       varchar(32)                                                  not null,
  caption    varchar(128)                                                 not null,
  --regionid uuid,
  parentid   uuid    default '00000000-0000-0000-0000-000000000000'::uuid not null,

  isgroup    boolean default false                                        not null,
  isdisabled boolean default false                                        not null
);

insert into public.refcustomerservices
values ('4c4b1bdf-91b7-4631-a058-2a5d75138c18', '', 'Реконструкції системи газопостачання',
        '00000000-0000-0000-0000-000000000000', false, false),
       ('cdb55ffa-94fd-4be3-8fcb-cd8f67a1a33b', '', 'Приєднання до ГРМ', '00000000-0000-0000-0000-000000000000', false,
        false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refbanks
(
  id         uuid    default gen_random_uuid() primary key       not null,
  code       varchar(6)                                          not null unique,
  caption    varchar(128) generated always as (shortname) stored not null,
  shortname  varchar(128)                                        not null,
  fullname   varchar(512)                                        not null,
  status     varchar(32)                                         not null,
  statusdate timestamp with time zone,
  isdisabled boolean default false                               not null
);

create table if not exists public.refcounterpartybankaccaunts
(
  id             uuid default gen_random_uuid() primary key not null,
  counterpartyid uuid                                       not null references public.refcounterparties,
  iban           varchar(29)                                not null,
  bankid         uuid                                       not null references public.refbanks
);

/*======================================================================================================================
 CONTRACTS
======================================================================================================================*/

create table if not exists public.doccontracts
(
  id             uuid default gen_random_uuid() primary key not null
    references public.docownerdocuments,
  counterpartyid uuid                                       not null references public.refcounterparties,
  contractnumber varchar(64),
  signdate       timestamp with time zone,
  startdate      timestamp with time zone                   not null,
  enddate        timestamp with time zone                   not null,
  contractsum    decimal(18, 2)
);

/*======================================================================================================================
 PLANING
======================================================================================================================*/
create table if not exists public.refprojecttypes
(
  id         uuid    default gen_random_uuid() primary key                not null,
  code       varchar(32)                                                  not null,
  caption    varchar(128)                                                 not null,
  parentid   uuid    default '00000000-0000-0000-0000-000000000000'::uuid not null,
  isgroup    boolean default false,
  isdisabled boolean default false
);


create table if not exists public.refcalendarperiods
(
  id         uuid    default gen_random_uuid() primary key                not null,
  code       varchar(32)                                                  not null,
  caption    varchar(128)                                                 not null,
  parentid   uuid    default '00000000-0000-0000-0000-000000000000'::uuid not null,
  startdate  timestamp with time zone,
  level      int                                                          not null,
  isgroup    boolean default false,
  isdisabled boolean default false
);

create table if not exists public.refactivitydirections
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(32)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false
);

--operational or base projects
create table if not exists public.docbaseprojects
(
  id                       uuid default gen_random_uuid() primary key not null
    references public.docownerdocuments,
  yearperiodid             uuid                                       not null references public.refcalendarperiods,
  activitydirectionid      uuid                                       not null references public.refactivitydirections,
  projecttypeid            uuid                                       not null references public.refprojecttypes,
  responsiblesubdivisionid uuid                                       not null references public.refsubdivisions,
  projectname              varchar(256)                               not null,
  description              varchar(1024)
);


create table if not exists public.doccommercialprojects
(
  id             uuid default gen_random_uuid() primary key not null
    references public.docbaseprojects,
  counterpartyid uuid                                       not null references public.refcounterparties,
  contractid     uuid                                       not null references public.doccontracts
);

create table if not exists public.refcashflowarticles
(
  id         uuid    default gen_random_uuid() primary key                not null,
  code       varchar(32)                                                  not null,
  caption    varchar(128)                                                 not null,
  parentid   uuid    default '00000000-0000-0000-0000-000000000000'::uuid not null,
  isgroup    boolean default false,
  isdisabled boolean default false
);

create table if not exists public.docprojectbudgets
(
  id           uuid default gen_random_uuid() primary key not null
    references public.docbasedocuments,
  periodid     uuid                                       not null references public.refcalendarperiods,
  budgetcodeid uuid                                       not null references public.refcashflowarticles,
  sum          decimal(18, 2)
);

create table if not exists public.refunits
(
  id         uuid    default gen_random_uuid() primary key       not null,
  code       varchar(16)                                         not null unique,
  caption    varchar(128) generated always as (shortname) stored not null,
  shortname  varchar(16)                                         not null,
  longname   varchar(64)                                         not null,
  isdisabled boolean default false
);


create table if not exists public.refnomenclatureclasses
(
  id         uuid    default gen_random_uuid() primary key                not null,
  code       varchar(32)                                                  not null,
  caption    varchar(128)                                                 not null,
  parentid   uuid    default '00000000-0000-0000-0000-000000000000'::uuid not null,
  isgroup    boolean default false,
  isdisabled boolean default false
);


create table if not exists public.refcommonprocurementvalues
(
  id         uuid    default gen_random_uuid()                            not null
    primary key,
  code       varchar(32)                                                  not null unique,
  caption    varchar(256)                                                 not null,
  captioneng varchar(256)                                                 not null,
  parentid   uuid    default '00000000-0000-0000-0000-000000000000'::uuid not null,
  isgroup    boolean default false                                        not null,
  isdisabled boolean default false                                        not null
);


create table if not exists public.refnomenclaturetypes
(
  id         int     default 1     not null
    primary key,
  code       varchar(32)           not null unique,
  caption    varchar(256)          not null,
  isdisabled boolean default false not null
);

insert into public.refnomenclaturetypes
values (1, '1', 'Товар', false),
       (2, '2', 'Послуга', false),
       (4, '4', 'Робота', false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refnomenclatures
(
  id                  uuid    default gen_random_uuid() primary key                                   not null,
  code                varchar(32) generated always as (longid::varchar(32)) stored                    not null unique,
  caption             varchar(256)                                                                    not null,
  parentid            uuid    default '00000000-0000-0000-0000-000000000000'::uuid                    not null,
  nomeclaturetype     int     default 1                                                               not null references public.refnomenclaturetypes,
  defaultunitid       uuid references public.refunits,
  cpvid               uuid                                                                            not null references public.refcommonprocurementvalues, --'99999999-9999-9999-9999-999999999999'::uuid
  layer               int                                                                             not null,
  nomenclatureclassid uuid                                                                            not null references public.refnomenclatureclasses,
--  longid              bigint generated always as identity (increment 1 start 100001 minvalue 100001 ) not null,                                              --  maxvalue 9223372036854775807 cache 1
  longid              bigserial  not null,                                              --  maxvalue 9223372036854775807 cache 1
  isgroup             boolean default false,
  isdisabled          boolean default false
);

--create sequence if not exists public.refnomenclatures_longid_seq start 100001;
--alter sequence public.refnomenclatures_longid_seq owned by public.refnomenclatures.longid;

create table if not exists public.docprojectnomenclatures
(
  id             uuid default gen_random_uuid() primary key not null
    references public.docbasedocuments,
  nomenclatureid uuid                                       not null references public.refnomenclatures,
  unitid         uuid                                       not null references public.refunits,
  count          decimal(18, 3)                             not null,
  price          decimal(18, 4)                             not null
);

create table if not exists public.refwarehousetypes
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(32)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false
);


create table if not exists public.refwarehouses
(
  id              uuid    default gen_random_uuid() primary key                not null,
  code            varchar(32)                                                  not null,
  caption         varchar(128)                                                 not null,
  parentid        uuid    default '00000000-0000-0000-0000-000000000000'::uuid not null,
  warehousetypeid uuid                                                         not null references public.refwarehousetypes,
  companyid       uuid                                                         not null references public.refcompanies,
  isgroup         boolean default false,
  isdisabled      boolean default false
);

create table if not exists public.docrequests
(
  id             uuid default gen_random_uuid() primary key not null
    references public.docownerdocuments,
  projectid      uuid                                       not null references public.docbaseprojects,
  counterpartyid uuid references public.refcounterparties,
  contractid     uuid references public.doccontracts,
  warehouseid    uuid references public.refwarehouses,
  requestbasis   varchar(512)                               not null
);
create table if not exists public.docrequestqueries
(
  id                    uuid default gen_random_uuid() primary key not null
    references public.docbasedocuments,
  nomenclatureid        uuid                                       not null references public.refnomenclatures,
  unitid                uuid                                       not null references public.refunits,
  count                 decimal(18, 3)                             not null,
  price                 decimal(18, 4)                             not null,
  projectnomenclatureid uuid                                       not null references public.docprojectnomenclatures,
--    expecteddeliverydate timestamp with time zone,
  desiredpaymentdate    timestamp with time zone
);
/*======================================================================================================================
 ORDERS
======================================================================================================================*/
create table if not exists public.docorders
(
  id                   uuid default gen_random_uuid() primary key not null
    references public.docownerdocuments,
  counterpartyid       uuid references public.refcounterparties   not null,
  contractid           uuid references public.doccontracts,
  warehouseid          uuid references public.refwarehouses,
  orderbasis           varchar(256)                               not null,
  expecteddeliverydate timestamp with time zone,
  desiredpaymentdate   timestamp with time zone
);


create table if not exists public.docorderqueries
(
  id             uuid default gen_random_uuid() primary key not null
    references public.docbasedocuments,
  nomenclatureid uuid                                       not null references public.refnomenclatures,
  unitid         uuid                                       not null references public.refunits,
--    count decimal(18,3) not null,
  price          decimal(18, 4)                             not null
);

create table if not exists public.docorderrequests
(
  requestqueryid       uuid primary key           not null references public.docrequestqueries,
  orderqueryid         uuid                       not null references public.docorderqueries,
  conversionmultiplier decimal(18, 6) default 1.0 not null
);

/*======================================================================================================================
 TECHNICAL CONDITIONS
======================================================================================================================*/


create table if not exists public.doctcapplications
(
  id                                               uuid default gen_random_uuid() primary key not null
    references public.docownerdocuments,
  counterpartyid                                   uuid                                       not null references public.refcounterparties,
  customerobjectid                                 uuid                                       not null references public.refcustomerobjects,
  customerserviceid                                uuid                                       not null references public.refcustomerservices,
  managementadministratorid                        uuid                                       not null references public.refmanagementadministrators,
  reconstructionexpected                           varchar(512)                               not null,
  totalnumberofdocuments                           int  default 0                             not null,
  totalnumberofsheetsdocuments                     int  default 0                             not null,
  numberofsheetsownershipdocuments                 int  default 0                             not null,
  numberofsheetscopiescertifyingdocuments          int  default 0                             not null,
  numberofsheetscopiespowerofattorney              int  default 0                             not null,
  numberofsheetscopiesdecisionindividualheatsystem int  default 0                             not null
);

create table if not exists public.doctcsurveyletters
(
  id                                     uuid           default gen_random_uuid() primary key not null
    references public.doctcapplications,
  gasobjectworkkind                      varchar(64)                                          not null,
  numberoffloors                         int            default 0                             not null,
  numberofapartments                     int            default 0                             not null,
  objecttotalarea                        decimal(18, 3) default 0                             not null,
  objectownershiptype                    varchar(64)                                          not null,
  landownershiptype                      varchar(64)                                          not null,
  metersize                              decimal(18, 1) default 0                             not null,
  technicalcapacity                      decimal(18, 3) default 0                             not null,
  powerreserve                           decimal(18, 3) default 0                             not null,
  equipmentsupplier                      varchar(64)                                          not null,
  projectdeveloperproviderexternalsupply varchar(64)                                          not null,
  projectdeveloperproviderinternalsupply varchar(64)                                          not null,
  executorworksexternalsupply            varchar(64)                                          not null,
  executorworksinternalsupply            varchar(64)                                          not null,
  executorworksinstallationmeteringunit  varchar(64)                                          not null,
  methodofsubmittingdocuments            varchar(64)                                          not null,
  numberofdocuments                      int            default 0                             not null,
  numbersheetsofdocuments                int            default 0                             not null

);

create table if not exists public.reftcprojectedgasequipments
(
  id                       uuid default gen_random_uuid() primary key                                                              not null,
  surveyletterid           uuid                                                                                                    not null references public.doctcsurveyletters,
  equipmentname            varchar(256)                                                                                            not null,
  installequipmentcount    int  default 0                                                                                          not null,
  installequipmentpower    decimal(18, 3)                                                                                          not null,
  installequipmentvolume   decimal(18, 3) generated always as ((installequipmentcount * installequipmentpower) / 10.55) stored     not null,
  existingequipmentcount   int                                                                                                     not null,
  existingequipmentpower   decimal(18, 3)                                                                                          not null,
  existingequipmentvolume  decimal(18, 3) generated always as ((existingequipmentcount * existingequipmentpower) / 10.55) stored   not null,
  dismantleequipmentcount  int                                                                                                     not null,
  dismantleequipmentpower  decimal(18, 3)                                                                                          not null,
  dismantleequipmentvolume decimal(18, 3) generated always as ((dismantleequipmentcount * dismantleequipmentpower) / 10.55) stored not null,
  status                   int  default 1                                                                                          not null
);


create table if not exists public.reftechnicalconditiontypes
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.reftechnicalconditiontypes
values ('e9e563b7-71a5-4f55-a7b9-dfbf64e402f0', '1', 'Технічні умови приєднання для фізичних осіб', false),
       ('85172883-ad8c-4d18-892a-902f9b6b774c', '2', 'Технічні умови приєднання для юридичних осіб', false),
       ('acbf0788-85a0-44db-be67-9a3fe5fbf367', '3', 'Технічні умови реконструкції для фізичних осіб', false),
       ('3b3b0ad9-7091-4cbd-88f3-20a1b82cadc3', '4', 'Технічні умови реконструкції для юридичних осіб', false)
ON CONFLICT(id) DO NOTHING;


create table if not exists public.doctcinspectionacts
(
  id                        uuid default gen_random_uuid() primary key not null
    references public.docownerdocuments,
  actnumber                 varchar(64)                                not null,
  tcapplicationid           uuid                                       not null references public.doctcapplications,
  technicalconditiontypeid  uuid                                       not null references public.reftechnicalconditiontypes,
  counterpartyid            uuid                                       not null references public.refcounterparties,
  customerobjectid          uuid                                       not null references public.refcustomerobjects,
  managementadministratorid uuid                                       not null references public.refmanagementadministrators,
  functionalpurpose         varchar(64)
);

create table if not exists public.doctcinspectionactjoins
(
  id                                      uuid default gen_random_uuid() primary key not null
    references public.doctcinspectionacts,
  powersupplypoint                        varchar(128),
  placeprovidepower                       varchar(256),
  gaspipelinetype                         varchar(32),
  gaspipelinekind                         varchar(32),
  gaspipelinematerial                     varchar(32),
  gaspipelinediameter                     int                                        not null,
  powersupplydesignpressure               decimal(18, 3)                             not null,
  workingpressureattheconnectionpoint     decimal(18, 3)                             not null,
  minimumpressurevalue                    decimal(18, 4)                             not null,
  roadsurfacetype                         varchar(32),
  gasnetworkowner                         varchar(32),
  gasnetworkownerinformation              varchar(256),
  attachmentpoint                         varchar(128),
  connectionpointdesignpressure           decimal(18, 3)                             not null,
  connectionpointtechnicalcapacity        decimal(18, 3)                             not null,
  terraintype                             varchar(128),
  distancepowersupplypointtolandplot      decimal(18, 3)                             not null,
  connectiontype                          varchar(32),
  predictedmeasurementpoint               varchar(128),
  stateofreadinessforinternalgasification varchar(128)
);

create table if not exists public.doctcinspectionactreconstructions
(
  id                                         uuid default gen_random_uuid() primary key not null
    references public.doctcinspectionacts,
  existingpowersupplypoint                   varchar(256),
  existingpointgaspipelinediameter           int                                        not null,
  pressurecategoryattheconnectionpoint       varchar(64),
  existingattachmentpoint                    varchar(64),
  existingattachmentpointgaspipelinediameter int                                        not null,
  attachmentpointdesignpressure              decimal(18, 3)                             not null,
  attachmentpointworkingpressure             decimal(18, 3)                             not null,
  attachmentpointminimumpressure             decimal(18, 4)                             not null,
  attachmentpointtechnicalexistingcapacity   decimal(18, 3)                             not null,
  areaofthepremises                          decimal(18, 3)                             not null,
  heightofthepremises                        decimal(18, 3)                             not null,
  volumeofthepremise                         decimal(18, 3)                             not null,
  numberoffloors                             int                                        not null,
  resultoftheexamination                     varchar(64)
);

create table if not exists public.tcinspectionactgasequipments
(
  id                uuid default gen_random_uuid() primary key                                            not null,
  tcinspectionactid uuid                                                                                  not null references public.doctcinspectionactreconstructions,
  equipmentname     varchar(256)                                                                          not null,
  equipmentcount    int                                                                                   not null,
  equipmentpower    decimal(18, 3)                                                                        not null,
  equipmentvolume   decimal(18, 3) generated always as ((equipmentcount * equipmentpower) / 10.55) stored not null,
  comment           varchar(256),
  status            int  default 1                                                                        not null
);

create table if not exists public.tcinspectionactmeasuringequipments
(
  id                  uuid default gen_random_uuid() primary key not null,
  tcinspectionactid   uuid                                       not null references public.doctcinspectionactreconstructions,
  measuringdevicename varchar(128)                               not null,
  metersize           decimal(18, 1)                             not null,
  measurementlimit    decimal(18, 4)                             not null,
  factorynumber       varchar(16)                                not null,
  graduationyear      int                                        not null,
  presenceoflfoutput  boolean                                    not null,
  status              int  default 1                             not null
);

create table if not exists public.doctctechnicalconditions
(

  id                                     uuid default gen_random_uuid() primary key not null
    references public.docownerdocuments,
  counterpartyid                         uuid                                       not null references public.refcounterparties,
  customerobjectid                       uuid                                       not null references public.refcustomerobjects,

  actnumber                              varchar(64)                                not null,
  tcapplicationid                        uuid                                       not null references public.doctcapplications,
  tcinspectionactid                      uuid                                       not null references public.doctcinspectionacts,
  technicalconditiontypeid               uuid                                       not null references public.reftechnicalconditiontypes,
  managementadministratorid              uuid                                       not null references public.refmanagementadministrators,
  functionalpurpose                      varchar(64),
  technicalconditionnumber               varchar(32),
  dateofissue                            timestamp with time zone,
  placeprovidepower                      varchar(128)                               not null,
  attachmentpoint                        varchar(128)                               not null,
  numberaccountingnodes                  int                                        not null,
  projectdeveloperproviderexternalsupply varchar(32),
  executorworksexternalsupply            varchar(32),
  projectdeveloperproviderinternalsupply varchar(32),
  executorworksinternalsupply            varchar(32),
  categorymeteringunitoperatingpressure  varchar(64),
  categorypmin                           decimal(18, 4)                             not null,
  categorypmax                           decimal(18, 4)                             not null,
  categorytmin                           decimal(18, 3)                             not null,
  categorytmax                           decimal(18, 3)                             not null,
  categorydensity                        decimal(18, 1)                             not null,
  categorylowerheat                      decimal(18, 0)                             not null,
  metersize                              decimal(18, 1)                             not null,
  additionalrequirementsexternalsupply   varchar(512),
  additionalrequirementsinternalsupply   varchar(512),
  additionalrequirementsaccountingnode   varchar(512),
  connectiontype                         varchar(32),
  commercialgasmeteringunitprovider      varchar(32),
  powersupplydesignpressure              decimal(18, 3)                             not null,
  connectionpointdesignpressure          decimal(18, 3)                             not null,
  predictedmeasurementpoint              varchar(64),
  technicalcapacity                      decimal(18, 3)                             not null,
  totaltechnicalcapacity                 decimal(18, 3)                             not null,
  minimumpressurevalue                   decimal(18, 4)                             not null,
  meteringunitoperatingpressure          decimal(18, 4)                             not null,
  statusaccountingnode                   varchar(32),
  consumertype                           varchar(32),
  reconstructionexpected                 varchar(128),
  pressuredesignmax                      decimal(18, 4)                             not null,
  pressureoperational                    decimal(18, 4)                             not null,
  pressuremin                            decimal(18, 4)                             not null,
  maxconsumptionbeforereconstruction     decimal(18, 3)                             not null,
  maxconsumptionafterreconstruction      decimal(18, 3)                             not null
);


/* ====================================================================================================================+
    technical condition references
===================================================================================================================== */
create table if not exists public.refattachmentpoints
(
  id         uuid    default gen_random_uuid() primary key not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refattachmentpoints(id, caption, isdisabled)
values ('ceeb8ebb-e128-4604-8082-0a95b3f6932d', 'на межі земельної ділянки oб''єкта Замовника', false),
       ('b1f167a8-28a9-403e-a40f-5bdd5804779e', 'збігається з місцем забезпечення потужності', false),
       ('b2c4e4d5-3d15-45d8-b70c-f7ce07af1681', 'на території oб''єкта Замовника', false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refcommercialgasmeteringunitproviders
(
  id         uuid    default gen_random_uuid() primary key not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refcommercialgasmeteringunitproviders(id, caption, isdisabled)
values ('c456fc99-8e50-4087-a49b-c507303d4ff0', 'Оператор ГРМ', false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refconnectionpointdesignpressures
(
  id         uuid    default gen_random_uuid() primary key                            not null,
  caption    varchar(32) generated always as (pressure::character varying(32)) stored not null,
  pressure   decimal(18, 3)                                                           not null,
  isdisabled boolean default false                                                    not null
);

insert into public.refconnectionpointdesignpressures (id, pressure, isdisabled)
values ('b641f8b5-e1c5-4fec-9a0e-2d1ec5573d82', 0.300, false),
       ('5e2d9891-a714-41bf-aab6-3c88b0677167', 0.003, false),
       ('d54571e9-bee8-45b3-b8ca-8f58099e1607', 0.600, false),
       ('2fb223c6-f67d-4acd-9dbd-badb7014462d', 1.200, false),
       ('0d4795b6-c2d1-4096-987b-d37c4ac4a461', 0.005, false)
ON CONFLICT(id) DO NOTHING;


create table if not exists public.refconnectiontypes
(
  id         uuid    default gen_random_uuid() primary key not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refconnectiontypes
values ('61c073ab-ca8c-4e51-8cb8-17f6cf8332a5', 'Нестандартне', false),
       ('e3ccd2de-b173-4871-bae6-53c141456148', 'Стандартне', false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refexaminationresults
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refexaminationresults(id, code, caption, isdisabled)
values ('d3a95494-6e7f-40e4-b2f5-05306be11a1d', '', 'Потребує виготовлення Технічних умов', false),
       ('914c57ed-764a-4ab1-b948-3c666fe56eff', '', 'Передбачає перенесення точки приєднання', false),
       ('dc6cd938-07cf-4b14-b24e-44d11adb35f5', '', 'Потребує виготовлення Ескізного Проєкту', false),
       ('9534eae9-0850-4dd0-99a8-5291f36e9b3e', '', 'Передбачає реконструкцію зі збільшенням потужності', false),
       ('07dd51d9-6139-42d8-a510-aab25e6116a1', '', 'Реконструкція не відповідає вимогам ДБН/ПБСГ', false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.reffunctionalpurposes
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.reffunctionalpurposes (id, caption, code, isdisabled)
values ('f51730fb-65e9-408d-8811-02cc3d4b83e5', 'об''єкт теплопостачання', '', false),
       ('22663ff7-8693-457f-bc76-056fa2868862', 'будівля громадського харчування', '', false),
       ('61b91904-7e14-4667-8b3a-0c9176606d80', 'будинок з трьома та більше квартирами', '', false),
       ('173c025a-b009-4f21-95fd-16f21458e426', 'ресторан', '', false),
       ('bd03dc76-3810-4739-8323-1736718d245e', 'громадська будівля', '', false),
       ('b79dc85e-e715-4969-8a64-29b0ebf47cff', 'квартира (багатоквартирний будинок)', '', false),
       ('f06b9b01-3f68-412f-9e7c-39dad8ee77bc', 'Блокованний будинок житловий', '', false),
       ('1f4f7e35-dea2-4f39-993d-42c085558a63', 'готель', '', false),
       ('861acb75-7559-469f-b4d8-5ffa4676a48d', 'будинок з двома квартирами', '', false),
       ('765d6fa5-fd95-41e4-bb5a-6de1a092a3fb', 'навчальний заклад', '', false),
       ('e24238e6-24b3-4072-a693-748a5ce66145', 'торгівельна будівля', '', false),
       ('959e135a-8670-4983-85f0-7a08e0bc93c4', 'офісна будівля', '', false),
       ('7cd1a586-6cb8-4206-b00a-84d2fcdeba7e', 'промислова будівля', '', false),
       ('2c579988-28ab-4c6e-b9f9-9fd3465e8342', 'розважальний заклад', '', false),
       ('4cd75490-249b-4175-86f1-a802ee4820fc', 'нежитлове приміщення', '', false),
       ('109501a2-849b-47fb-a0a5-ae39098a0d58', 'медичний заклад', '', false),
       ('023351dc-407c-4c19-9354-c3f89d3adda6', 'будинок одноквартирний', '', false),
       ('b0a6fdd1-7057-4a37-bf5b-c425cea1813d', 'релігійна будівля', '', false),
       ('d6f069d7-1622-4a83-a5b8-c906ea656001', 'будівля для зберігання зерна', '', false),
       ('c6797ca0-3e30-4d9f-848a-c91243ae4a34', 'Будинок житловий', '', false),
       ('2c0454cb-bdbd-48fa-ac24-c9de51ebb48e', 'будинок житловий готельного типу', '', false),
       ('58c6f12c-6806-4b5a-ac6c-e2e6b43b9858', 'спорткомплекс', '', false),
       ('c5d912a9-5901-4018-9a3c-f311b90c3e69', 'адміністративна будівля', '', false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refgasnetworkowners
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refgasnetworkowners(id, code, caption, isdisabled)
values ('175668d1-8633-4d57-982c-65593e286345', '', 'в господарському віддані', false),
       ('0ec9f78f-0ad3-4dd4-9127-76273119b6f2', '', 'в експлуатації', false),
       ('1e429b3b-12bd-4dde-b5c8-806ff4c8b92c', '', 'приєднання потребує погодження власника мереж', false),
       ('f51b69a6-9b24-4367-938f-98f0f3a27e12', '', 'в користуванні', false),
       ('4f358c3e-6046-4e85-a6a0-b1ffb2368059', '', 'мережі знаходяться у власності Оператора ГРМ', false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refgaspipelinediameters
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refgaspipelinediameters(id, code, caption, isdisabled)
values ('6cd3aeb2-cc10-4ab3-9204-0f0d9c0b6715', '', '80', false),
       ('6d513bee-81e5-47c7-829d-10fe5a4b53ed', '', '25', false),
       ('270dfd65-8b03-4a0d-812e-16bad75bc861', '', '400', false),
       ('affa7d27-b329-4617-a89c-1cd1ae2e8330', '', '90', false),
       ('403d9e4c-cc9b-4d51-b7cb-2c1e1b28e0a1', '', '250', false),
       ('b663e655-0ca8-4db4-b94b-309e83a4cfde', '', '1000', false),
       ('9312f6ea-eb47-420d-87f1-3a48d4e30b56', '', '1200', false),
       ('c4a39591-8795-4d6d-9efc-3f0e0845bcb9', '', '40', false),
       ('6adcf6da-9fe3-4fb8-b852-4c44c5f54b06', '', '125', false),
       ('569b3c2e-76d0-430d-92ae-617ea9512554', '', '15', false),
       ('ada1561e-7759-4ee9-a053-62198cbf3307', '', '800', false),
       ('22cd5225-539c-461b-9779-7ac25cf34cd2', '', '32', false),
       ('d6d34caa-68f8-4ab1-b6f5-7e278517d1ba', '', '150', false),
       ('c8704058-3163-434a-9ade-8b086441800b', '', '600', false),
       ('5cef98f3-1d4f-4fbf-9081-8cadeb95d070', '', '100', false),
       ('4350141e-26f3-4cce-b51e-979c99ad2deb', '', '50', false),
       ('2753c60d-3fd4-4aa1-9990-b0b15ce07b76', '', '225', false),
       ('aa2ef9fe-9f1f-489b-9623-cae588f2d8aa', '', '300', false),
       ('6b28cd59-7407-4e27-bf0b-dd2840f21ec3', '', '20', false),
       ('3945b4eb-90f6-410e-b0f1-e19fef0a9560', '', '500', false),
       ('0644827e-8939-4cc6-a1fe-e79ff97f0aea', '', '200', false),
       ('d2cbf4fb-1081-445e-a9aa-ecfbf5235304', '', '10', false),
       ('f97eb523-1cb4-4839-8d2f-f0d976236d61', '', '160', false),
       ('962c8526-71b5-4889-8968-f3c84d35621d', '', '65', false)
ON CONFLICT(id) DO NOTHING;


create table if not exists public.refgaspipelinekinds
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refgaspipelinekinds(id, code, caption, isdisabled)
values ('f8988b7b-5bed-4202-887d-05eed4e57424', '', 'Ввідний', false),
       ('91f30ec6-f4da-427b-9b74-7a78113b4c06', '', 'Розподільчий', false),
       ('2f52231a-a589-4013-8b18-8e2558dc0ecb', '', 'Газопровід-ввід', false),
       ('6cb4442d-bc85-4de1-a6d3-e9f7c344e0e7', '', 'Внутрішній', false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refgaspipelinematerials
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refgaspipelinematerials(id, code, caption, isdisabled)
values ('f8b31e57-3d06-49e7-ac47-a6446e589fb3', '', 'Поліетилен', false),
       ('37263ab2-0bd3-4207-8490-eb96e579d308', '', 'Сталь', false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refgaspipelinetypes
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refgaspipelinetypes(id, code, caption, isdisabled)
values ('c28d5fb3-5a4e-4a78-b898-23ac2ab720db', '', 'Наземний', false),
       ('a9258100-cbf4-494b-bb4c-75b4f6053208', '', 'Підземний', false),
       ('2ff8cb5e-ff5f-497d-9b80-b0b57646d60a', '', 'Надземний', false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refmeteringunitoperatingpressures
(
  id         uuid default gen_random_uuid() primary key not null,
  caption    varchar(128)                               not null,
  pmin       decimal(18, 3)                             not null,
  pmax       decimal(18, 3)                             not null,
  tmin       decimal(18, 0)                             not null,
  tmax       decimal(18, 0)                             not null,
  density    decimal(18, 1)                             not null,
  lowerheat  decimal(18, 0)                             not null,
  isdisabled boolean                                    not null
);

insert into public.refmeteringunitoperatingpressures (id, caption, pmin, pmax, tmin, tmax, density, lowerheat, isdisabled)
values ('d16d6ce3-60fc-4c91-b0e8-5d109e6ca1d4', 'Г4', 0.180, 1.200, -25, 40, 0.7, 8250, false),
       ('c78d7485-c427-48c4-8099-a698d57c2bfe', 'Г2', 0.080, 0.300, -25, 40, 0.7, 8250, false),
       ('3cdff711-dabe-4ee5-af5b-c9b89da55c65', 'Г3', 0.180, 0.600, -25, 40, 0.7, 8250, false),
       ('191e5c3a-a660-47b5-8f94-eb680979e380', 'Г1 (ГСО менше 100 кВт)', 0.001, 0.003, -25, 40, 0.7, 8250, false),
       ('bdfba42a-6105-4982-af69-fcad7e600d5b', 'Г1 (ГСО більше 100 кВт)', 0.001, 0.005, -25, 40, 0.7, 8250, false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refmetersizes
(
  id         uuid    default gen_random_uuid() primary key                             not null,
--    code varchar(16) not null,
  caption    varchar(32) generated always as (bandwidth::character varying(32)) stored not null,
  bandwidth  decimal(18, 1)                                                            not null,
  isdisabled boolean default false                                                     not null
);

insert into public.refmetersizes (id, bandwidth, isdisabled)
values ('eb86f8c4-00d9-4d77-a9d2-084075d7a29d', 160.0, false),
       ('6560e27c-44bb-4914-906e-0fba230d6311', 2500.0, false),
       ('7edcc23d-3519-433a-ad7f-128bfe6e8c72', 10.0, false),
       ('b6acc41f-b3fd-41a4-a71b-14bc1ba8c4aa', 65.0, false),
       ('22eb7dc9-8ffa-48d9-bebb-1a1f93d20d70', 25.0, false),
       ('3c8039b0-ba8b-420d-9fc1-1b47521324ec', 250.0, false),
       ('286c9dd7-da76-438a-a7c6-2eabc745cc73', 6.0, false),
       ('2a75cae5-9dbb-4cb8-91de-33d442d10e1a', 40.0, false),
       ('6670aa37-4e14-4d1a-a78a-8febabd2785b', 100.0, false),
       ('842041d5-a9df-431a-99bf-ac40884cde32', 400.0, false),
       ('e78bb364-b7f7-4a98-880f-b9f7baed3618', 1.6, false),
       ('7c29b17c-dc81-4479-9e87-bf3d7de5948f', 4.0, false),
       ('121c95e4-c978-4dd3-b88f-c53da0d662c5', 2.5, false),
       ('0e2f3b66-ff6b-4c31-8185-e5f075654d3a', 1000.0, false),
       ('4ff9631f-269e-4821-9730-e83df6f5425a', 16.0, false),
       ('ac6e8a6a-49a9-4bfa-bc50-f4982e4a31a7', 1600.0, false),
       ('b753ecf9-f9ef-4b9d-98e2-f5dc65e5060d', 650.0, false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refownershiptypes
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refownershiptypes(id, code, caption, isdisabled)
values ('d559f42e-46cc-4b43-b518-42559f38c806', '5', 'Приватна', false),
       ('00d50844-9239-465d-8117-49f622040a4d', '4', 'Безгосподарна', false),
       ('2e8fe943-6143-4014-abb5-4fd850008c9b', '2', 'Комунальна', false),
       ('48579aa5-3d3f-453b-b5e5-b5525aa1d1bd', '3', 'Власна', false),
       ('5ebf8975-55f8-4ac4-ab89-ec7e3ccced91', '1', 'Державна', false)
ON CONFLICT(id) DO NOTHING;


create table if not exists public.refplacepowersupplydesignpressures
(
  id         uuid    default gen_random_uuid() primary key                            not null,
  caption    varchar(32) generated always as (pressure::character varying(32)) stored not null,
  pressure   decimal(18, 3)                                                           not null,
  isdisabled boolean default false                                                    not null
);

insert into public.refplacepowersupplydesignpressures (id, pressure, isdisabled)
values ('e4ed74eb-2638-415a-b599-a7062c2eb653', 1.200, false),
       ('8ec3d697-c687-4b10-bb52-b011e50cdfed', 0.600, false),
       ('8b3975e8-6305-4aa4-80dd-ce93ea112386', 0.300, false),
       ('ac98ead3-f586-4575-97ff-f32096b88a04', 0.003, false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refpredictedmeasurementpoints
(
  id         uuid    default gen_random_uuid() primary key not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refpredictedmeasurementpoints(id, caption, isdisabled)
values ('c8a5ed4e-4e1c-4d2a-840d-0262c7bf1b86', 'на території замовника (для загального обліку)', false),
       ('6adf8473-132e-4397-971e-0bad31223bfc', 'на межі земельної (для нежитлових приміщень)', false),
       ('6bef5fcf-48ce-45c6-86fe-1def525530be', 'на території oб''єкта Замовника', true),
       ('d049c434-4acb-4082-86d7-487a3d45001a', 'на межі земельної (для житлових приміщень)', false),
       ('3b17e180-6b7d-4363-880a-6a09e8e2348c', 'в точці приєднання', true),
       ('34387097-7e20-47ca-a7c3-70140645305b', 'в точці приєднання (для загального обліку)', false),
       ('43fb52bf-66e8-4452-a8ce-8aec985c1401', 'на межі земельної (для загального обліку)', false),
       ('40cf866a-8c53-47c4-96ae-8ee67851d535', 'в точці приєднання (для нежитлових приміщень)', false),
       ('5c9c1b7f-12d6-414a-a2a5-a191d0a92818', 'на межі земельної ділянки oб''єкта Замовника', true),
       ('f81d5fcd-3a57-4bf4-bab8-b3b709ab84ab', 'на території замовника (для нежитлових приміщень)', false),
       ('2d057548-49b6-4560-bc6a-cea742977c68', 'на території замовника (для житлових приміщень)', false),
       ('1ede01a5-0808-4bcf-821a-d82950411bb4', 'в точці приєднання (для житлових приміщень)', false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refpressurecategories
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refpressurecategories(id, code, caption, isdisabled)
values ('d66c4760-ba8b-419e-919b-484a2fb68de8', '', 'низького тиску', false),
       ('ae4fb61b-bb7b-42ee-ae68-98f803132240', '', 'середнього тиску', false),
       ('a73d7300-52a2-4dd1-a149-b4ef5d8daa41', '', 'високого тиску', false)
ON CONFLICT(id) DO NOTHING;

-- ====================================================================================================================
-- RefProjectDeveloperProvides
-- ====================================================================================================================
create table if not exists public.refworkproviders
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refworkproviders (id, code, caption, isdisabled)
values ('79ecadce-bcd7-4125-83a1-2a087b5cdcf4', '', 'Оператор ГРМ', false),
       ('c19cf82c-e52e-488b-a152-2e3f16b63cf9', '', 'Замовник', false)
ON CONFLICT(id) DO NOTHING;


create table if not exists public.refreconstructiongassupplysystemservices
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refreconstructiongassupplysystemservices (id, code, caption, isdisabled)
values ('fb999dd5-049a-46a4-8116-2688dba57bda', '', 'заміна газових приладів', false),
       ('02ddc8f7-6500-4315-bb58-50d727eafab4', '', 'технічне переоснащення системи газопостачання', false),
       ('52220cdf-4a42-4c53-bf6f-a8df7461bc80', '', 'демонтаж газових приладів', false),
       ('20ba917f-1fdf-42d6-9800-ac982f364043', '', 'додаткове встановлення', false),
       ('40f0cbc6-5cd6-4728-be6e-b39284a8815f', '', 'встановлення вузла обліку газу', false),
       ('36732455-a6b0-4fef-a481-c8666b641c4a', '', 'заміна вузла обліку газу', false),
       ('5391b4d1-df2b-4288-9b15-ceedb40bee6b', '', 'перенесення газових приладів', false),
       ('26ea5e7c-a0f4-4e97-b29b-f783f7cd046c', '', 'автономне опалення', false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refroadsurfacetypes
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refroadsurfacetypes(id, code, caption, isdisabled)
values ('a93daef7-d68f-48ac-861b-246120aa8398', '', 'цементобетон', false),
       ('52d248bc-a8d0-4536-b536-3cca5093b39c', '', 'асфальтобетоне', false),
       ('a161304c-5f58-4137-8d41-616dc3f80480', '', 'бруківка', false),
       ('1a413fa4-99b3-4c60-bf00-a3578e10f8a7', '', 'грунтова', false),
       ('aabe37c8-29dc-474e-ad2e-fc876e72aa8b', '', 'щебневе', false)
ON CONFLICT(id) DO NOTHING;


create table if not exists public.refterraintypes
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);

insert into public.refterraintypes(id, code, caption, isdisabled)
values ('178cb4e0-f188-48fb-ac05-0d046f208c15', '', 'міська', false),
       ('d8aa9802-48d7-44c6-bd74-3df7fbe28933', '', 'сільська', false)
ON CONFLICT(id) DO NOTHING;

create table if not exists public.refmethodsofsubmittingdocuments
(
  id         uuid    default gen_random_uuid() primary key not null,
  code       varchar(16)                                   not null,
  caption    varchar(128)                                  not null,
  isdisabled boolean default false                         not null
);
insert into public.refmethodsofsubmittingdocuments
values ('e78735ff-5057-4a99-bf0b-8a723ecdeb82', '', 'нарочно', false),
       ('e55cc522-2a35-44fa-b0d1-3e30c4f912bd', '', 'поштою', false),
       ('e1b7ce71-7e71-45a6-a4f0-0ae26c8f1245', '', 'на електронну адресу', false)
ON CONFLICT(id) DO NOTHING;


/*====================================================================================================================*/

CREATE OR REPLACE FUNCTION public.f_getobjectclasstree(inputid uuid)
  returns table
          (
            classid     uuid,
            tablename   varchar(128),
            baseclassid uuid,
            obectid     uuid,
            level       int
          )
  LANGUAGE 'sql'
as
$body$
WITH RECURSIVE classTree as (select sc.id     classid,
                                    sc.tablename,
                                    sc.baseclassid, /*rc.idfieldname, */
                                    sbo.id as documenttypeid,
                                    1      as classlevel
                             from sysclasses sc
                                    inner join sysbaseobjects sbo on sbo.classid = sc.id
--	inner join refdocumenttypes rdt on rdt.classid = sc.id
                             where sbo.id = inputid
                             --	where rc.baseid = '00000000-0000-0000-0000-000000000000'::uuid
                             union all
                             select sc.id                classid,
                                    sc.tablename,
                                    sc.baseclassid, /*sc.idfieldname,*/
                                    ct.documenttypeid,
                                    ct.classlevel + 1 as classlevel
                             from sysclasses as sc
                                    inner join classTree ct on ct.baseclassid = sc.id
  --	where rc.id = vars.classid
)
select *
from classTree;
$body$;


/*====================================================================================================================*/
create or replace procedure public.sp_fill_system_tables()
  language plpgsql
as
$$
begin
  /*======================================================================================================================
  update classes
  ======================================================================================================================*/
  insert into public.sysclasses(id, tablename, isdisabled)
  SELECT gen_random_uuid()
       , t.tableName
       , false
  FROM pg_catalog.pg_tables t
         left join sysClasses sc on sc.tablename = t.tablename
  where (t.tablename like 'ref%'
    or t.tablename like 'doc%'
    or t.tablename like 'rel%')
    and sc.id is null;


/*======================================================================================================================
update class field
======================================================================================================================*/

  INSERT INTO public.sysclassfields(id, classid, name, fieldtype, defaultvalue, isnullable, isdisabled, isprimarykey)
  SELECT gen_random_uuid()                                                  id
       , sc.id                                                              classid
--	,rcf.id fieldId
       , cs.column_name
       , cs.data_type
       , cs.column_default
       , cs.is_nullable::boolean
       , false                                                           as isdisabled
       , case when pkey.column_name is not null then true else false end as isprimarykey
  --  , pkey.*
  --,rc.id classid
  FROM information_schema.columns cs
--	inner join vars on vars.schemaName = cs.table_schema
         inner join sysclasses sc on sc.tablename = cs.table_name::varchar(128)
         left join sysclassfields scf on scf.classId = sc.id
         left outer join (SELECT la.attname::varchar(128)           as column_name
                               , c.conrelid::regclass::varchar(128) AS table_name
                          FROM pg_constraint as c
                                 JOIN pg_index AS i ON i.indexrelid = c.conindid
                                 JOIN pg_attribute AS la ON la.attrelid = c.conrelid AND la.attnum = c.conkey[1]
                          where array_length(c.conkey, 1) = 1
                            and connamespace = 'public'::regnamespace
                            and contype = 'p')
    as pkey on pkey.column_name = cs.column_name and pkey.table_name = sc.tablename
  WHERE scf.id is null
  order by sc.id;

/*======================================================================================================================
update base class id
======================================================================================================================*/

  update sysclasses sc
  set baseclassid = sc02.id
  --SELECT distinct la.attrelid::regclass AS referencing_table,
--       la.attname AS referencing_column
--      ,c.confrelid::regclass as foreign_table
--      , ra.attname as foreign_column
--      ,c.contype
  FROM pg_constraint AS c
         JOIN pg_index AS i ON i.indexrelid = c.conindid
         JOIN pg_attribute AS la ON la.attrelid = c.conrelid AND la.attnum = c.conkey[1]
         JOIN pg_attribute AS ra ON ra.attrelid = c.confrelid AND ra.attnum = c.confkey[1]

         join sysclasses sc01 on sc01.tablename = la.attrelid::regclass::varchar(128)
         join sysclassfields scf01
              on scf01.classid = sc01.id and scf01.name = la.attname::varchar(128) and scf01.isprimarykey

         join sysclasses sc02 on sc02.tablename = c.confrelid::regclass::varchar(128)
         join sysclassfields scf02
              on scf02.classid = sc02.id and scf02.name = ra.attname::varchar(128) and scf02.isprimarykey
  where sc01.id = sc.id;

/*======================================================================================================================
update class fields references
======================================================================================================================*/

  update sysclassfields scf
  set refclassid = scf02.classid

/*
SELECT distinct la.attrelid::regclass AS referencing_table,
   la.attname AS referencing_column
  ,scf01.isprimarykey
  ,c.confrelid::regclass as foreign_table
  , ra.attname as foreign_column
--  ,c.contype
  ,scf02.isprimarykey
*/

  FROM pg_constraint AS c
         JOIN pg_index AS i ON i.indexrelid = c.conindid
         JOIN pg_attribute AS la ON la.attrelid = c.conrelid AND la.attnum = c.conkey[1]
         JOIN pg_attribute AS ra ON ra.attrelid = c.confrelid AND ra.attnum = c.confkey[1]

         join sysclasses sc01 on sc01.tablename = la.attrelid::regclass::varchar(128)
         join sysclassfields scf01
              on scf01.classid = sc01.id and scf01.name = la.attname::varchar(128) and scf01.isprimarykey = false

         join sysclasses sc02 on sc02.tablename = c.confrelid::regclass::varchar(128)
         join sysclassfields scf02
              on scf02.classid = sc02.id and scf02.name = ra.attname::varchar(128) and scf02.isprimarykey
  where scf01.id = scf.id;


end;
$$;
