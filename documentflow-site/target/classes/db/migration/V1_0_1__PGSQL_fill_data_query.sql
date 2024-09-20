call public.sp_fill_system_tables();


/*

 init document types and references

do $do$
declare
  sclass sysclasses%ROWTYPE;
  typeid uuid;
begin
  for sclass in
    select
      *
    from sysclasses sc
    left outer join sysbaseobjects sbo on sbo.classid = sc.id
    where
      sc.tablename like 'doc%'
      and sc.baseclassid != '00000000-0000-0000-0000-000000000000'
      and sbo.id is null
  loop
    select gen_random_uuid() into typeid;
    --;with docData(typeid) as ( select gen_random_uuid() as typeid )
    insert into sysbaseobjects(id, name, caption, objecttype, classid, isdisabled) values (typeid, sclass.tablename, sclass.tablename, 'document', sclass.id, false);
    insert into refdocumenttypes(id, documentgroupid) values ( typeid, '8849b98a-0bbd-4367-b708-befe3ea539ba');
  end loop;

  for sclass in
    select
      *
    from sysclasses sc
    where
      sc.tablename like 'ref%'
--      and sc.baseclassid != '00000000-0000-0000-0000-000000000000'
  loop
    select gen_random_uuid() into typeid;
    --;with docData(typeid) as ( select gen_random_uuid() as typeid )
    insert into sysbaseobjects(id, name, caption, objecttype, classid, isdisabled) values (typeid, sclass.tablename, sclass.tablename, 'reference', sclass.id, false);
    insert into refreferences(id, isclientstore) values ( typeid, true);
  end loop;
end
$do$;

 */
