--update cuerpo set beneficio=('[{"BONONOCTURNO":0.00,"BONODEANTIGUEDAD":742.50,"LACTANCIA":0.00,"detalleLACTANCIA":[{"recibe":"no","monto":0,"porcentajerciva":13.00,"nummes":0,"descripcion":"","cuenta":0}],"BNATALIDAD":0.00,"detalleBNATALIDAD":[{"fechanacbebe":"","monto":0}],"AGRUPADOR AGUINALDOS-INDEMNIZACION":0,"AGRUPADOR AGUINALDOS-INDEMNIZACION":0,"PRIMAANUAL":0,"DOMINICAL":0,"DISTRIBUCIONDOMINICAL":0,"HORAEXTRAP":0.00,"detallehe":[{"horasimple":0.00,"hbasico":3470.95,"horaspromedio":202.08,  "canthoras":"0.0000","pagar":0.00,"detalle":[]}],"BONOCATEGORIZACION":294.25,"OTROS BONOS":0,"BONO TEMPORAL":0,"BONO VARIABLE":0,"BONO DE APOYO":0,"BONO ENC. AGENCIAS":0,"BONO PARA CANASTON":0,"RECONOCIMIENTO A LA LEALTAD":0,"BONO REPOSICION SUELDO":0,"BONO EXTRAORDINARIO":0,"BONO FERIA":0,"BONO UNICO":0,"listadetallebono":[{"grupo":"OTROS BONOS","listab":[{"nombre":"BONO APOYO PRODUCCION Y  ALMACEN 2","valor":0.00},{"nombre":"BONO ENCARGADOS DE PROCESOS","valor":0.00},{"nombre":"BONO EXTRAORDINARIO COMERCIAL","valor":0.00},{"nombre":"BONO ETIQUETADO","valor":0.00},{"nombre":"BONO EXTRAORDINARIO VENTAS","valor":0.00},{"nombre":"BONO  A LA  EFICIENCIA ALM 1-2","valor":0.00},{"nombre":"BONO A LA EFICIENCIA  ALM 3","valor":0.00},{"nombre":"BONO A LA EFICIENCIA ALM TRANSITORIO","valor":0.00},{"nombre":"BONO EXTRAORDINARIO MANTENIMIENTO","valor":0.00},{"nombre":"BONO REPOSICION DOMIN ADM","valor":0.00}]},{"grupo":"BONO TEMPORAL","listab":[{"nombre":"BONO TEMPORAL","valor":0}]},{"grupo":"BONO VARIABLE","listab":[{"nombre":"BONO VARIABLE","valor":0}]},{"grupo":"BONO DE APOYO","listab":[{"nombre":"BONO DE APOYO","valor":0}]},{"grupo":"BONO ENC. AGENCIAS","listab":[{"nombre":"BONO ENC. AGENCIAS","valor":0}]},{"grupo":"BONO PARA CANASTON","listab":[{"nombre":"BONO PARA CANASTON","valor":0}]},{"grupo":"RECONOCIMIENTO A LA LEALTAD","listab":[{"nombre":"RECONOCIMIENTO A LA LEALTAD","valor":0}]},{"grupo":"BONO REPOSICION SUELDO","listab":[{"nombre":"BONO REPOSICION SUELDO","valor":0}]},{"grupo":"BONO EXTRAORDINARIO","listab":[{"nombre":"BONO EXTRAORDINARIO","valor":0}]},{"grupo":"BONO FERIA","listab":[{"nombre":"BONO FERIA","valor":0}]},{"grupo":"BONO UNICO","listab":[{"nombre":"BONO UNICO","valor":0}]}]
/*
create or replace function armaractualizacion(p_idplanilla int) returns void  as $$
declare
lista record;
p_mes int;
p_anio int;
p_idcuerpo int;
p_idplanillaf int;
p_idcabecera int;
begin 
select  mes, anio into p_mes, p_anio from planilla where id=p_idplanilla;
for lista in select * from cuerpo where eliminado=false and tipo= 1 and idplanilla=p_idplanilla
loop
select id into p_idplanillaf from ftbl_rrhh_planilla where eliminado=false and mes=p_mes and anio=p_anio;
select id into p_idcuerpo from ftbl_rrhh_cuerpo where idempleado=lista.idempleado and eliminado=false and idplanilla=p_idplanillaf; 
update ftbl_rrhh_cuerpo set beneficio=lista.beneficio where id=p_idcuerpo;
select id+1 into p_idcabecera from ftbl_rrhh_cabecera order by id desc limit 1; 
insert into ftbl_rrhh_cabecera(id, nombre, nombref,tipo,idplanilla,orden,grupo , enplanilla)
( select p_idcabecera as id,'GRATIFICACION'::varchar(70) as nombre,'GRATIFICACION'::varchar(70) as nombref,	6::int as tipo,	p_idplanillaf as idplanilla,	61::int as orden,''::varchar(100) as grupo,false as en)
union	
( select  p_idcabecera+1 as id,'BONO GRATIFICACION'::varchar(70) as nombre,	'BONO GRATIFICACION'::varchar(70) as nombref,	6::int  as tipo,	p_idplanillaf as idplanilla	,62:: int as orden	,'GRATIFICACION'::varchar(100) as grupo , false as en);

end loop;
 
end;
$$
language plpgsql

create or replace function migrar_infotributario(p_idempleado int,p_fecha date)  returns void as $$
declare
lista record;
p_id int :
begin
select id into p_id from ftbl_rrhh_formulario100 order by id desc limit 1;
for  lista in   select * from general.formulario110 where idempleado=p_idempleado and eliminado=false and fechapresentacion>=p_fecha order by id asc
loop

p_id:=1+p_id;
raise info '%',' id a registrarse --->'||p_id;
insert into ftbl_rrhh_formulario100(id, idempleado, fechapresentacion,montopresentado, porcentaje,montodescontado,saldo,usuario,fecha) values
(p_id, lista.idempleado, lista.fechapresentacion,lista.montopresentado, lista.porcentaje,lista.montodescontado,lista.saldo,lista.usuario,lista.fecha);
end loop;
end;
$$
language plpgsql;*/


-- Function: public.lista_planilla_retroactivo(integer, text)

-- DROP FUNCTION public.lista_planilla_retroactivo(integer, text);
-- Function: public.lista_planilla_retroactivo_afp(integer, text, integer)

-- DROP FUNCTION public.lista_planilla_retroactivo_afp(integer, text, integer);

CREATE OR REPLACE FUNCTION public.lista_planilla_retroactivo_afp(
    IN p_idrectoractivo integer,
    IN p_contratosseleccionados text,
    IN p_mes integer)
  RETURNS TABLE(ci text, nombrecompleto character varying, fechaingreso text, haberbasico numeric, bantiguedad numeric, dominical numeric, ddominical numeric, horasextras numeric, afp numeric) AS
$BODY$
declare
listaempleado record;
p_mesinicio int;
p_mesfin int ;
p_anio int;
p_hbasico numeric(12,2);
p_dominical numeric(12,2);
p_distribuciondominical numeric(12,2);
p_antiguedad numeric(12,2);
p_hextra numeric(12,2);
p_afp numeric(12,2);


p_fechaingreso text;
p_fecharetiro text;
p_activo int;

consulta text ;
p_cantidad int;
p_idplanilla int;
p_nuevominimo numeric(12,2);
p_porcentaje numeric(12,4);
begin
select  mesinicio,mesfin,anio,monto,porcentaje into  p_mesinicio,p_mesfin,p_anio,p_nuevominimo,p_porcentaje from planillaretroactivo where id=p_idrectoractivo;
 if p_contratosseleccionados='' then
 p_contratosseleccionados:='0';
 end if;

if p_porcentaje=0 then

consulta:='select case when p.complementoci='''' then p.ci::text else  (p.ci)||''-''||p.complementoci end  as ci, p.nombrecompleto, p.sexo, e.id from general.persona p inner join general.empleado e on e.idpersona=p.id where   e.id in  
(select distinct  t.idempleado from(select distinct  idempleado, (json_array_elements(general)->>''hbasico'')::numeric(12,2) as hb,(json_array_elements(general)->>''dias'')::int as dias,(json_array_elements(beneficio)->>''BONODEANTIGUEDAD'')::numeric(12,2) as antiguedad from
 cuerpo where eliminado=false  and idtipocontrato in('|| p_contratosseleccionados||')  and idplanilla in
(select id from planilla where eliminado =false and mes = '|| p_mes||' and anio= '||p_anio||')) as t where (((t.hb*30)/t.dias)::numeric(12,2)<'||p_nuevominimo||') or t.antiguedad>0)
order by p.nombrecompleto  asc';
else
consulta:='select case when p.complementoci='''' then p.ci::text else  (p.ci)||''-''||p.complementoci end  as ci, p.nombrecompleto, p.sexo, e.id from general.persona p inner join general.empleado e on e.idpersona=p.id where   e.id in  
(select distinct  t.idempleado from(select distinct  idempleado, (json_array_elements(general)->>''hbasico'')::numeric(12,2) as hb,(json_array_elements(general)->>''dias'')::int as dias,(json_array_elements(beneficio)->>''BONODEANTIGUEDAD'')::numeric(12,2) as antiguedad from
 cuerpo where eliminado=false  and idtipocontrato in('|| p_contratosseleccionados||')  and idplanilla in
(select id from planilla where eliminado =false and mes = '|| p_mes||' and anio= '||p_anio||')) as t ) 
order by p.nombrecompleto  asc';
end if;
raise info '%',consulta;

for listaempleado in  execute consulta



loop
    
    select to_char(hee.fechaplanilla,'dd/mm/YYYY'),
    case when hee.activo=1 then 
     (select  mostrar_fecharetiro_retroactivo
( hee.id, hee.idempleado ,p_mesinicio ,p_mesfin , p_anio ))
    
    else to_char(hee.fecharetiro,'dd/mm/YYYY')  end
     into p_fechaingreso,p_fecharetiro 
      from general.historialestadoempleado hee where hee.eliminado=false and hee.idempleado=listaempleado.id order by hee.id desc limit 1;
select id into p_idplanilla from planilla where mes=p_mes and anio=p_anio and eliminado=false ;
 
 
  if (select count(*) from cuerpo where eliminado=false and idempleado=listaempleado.id and idplanilla=p_idplanilla)>0 then
         execute 'select 
          sum(t.hbasico) as hb,
          sum(t.antiguedad) as antiguedad,
           sum(t.dominical) as dominical,
          sum(t.ddominical) as ddominical,
          sum(t.he) as he,
          sum(t.afptrabajador) as afptrabajador
          
 from (
   select
          (json_array_elements(informacionretroactivo)->>''hbasico'')::numeric(12,2) as hbasico,
        (json_array_elements(informacionretroactivo)->>''BONODEANTIGUEDAD'')::numeric(12,2) as antiguedad,
        (json_array_elements(informacionretroactivo)->>''DOMINICAL'')::numeric(12,2) as dominical,
        (json_array_elements(informacionretroactivo)->>''DISTRIBUCIONDOMINICAL'')::numeric(12,2) as ddominical,
        (json_array_elements(informacionretroactivo)->>''HORAEXTRAP'')::numeric(12,2) as he,
       
       
        
        (json_array_elements(informacionretroactivo)->>''totalga'')::numeric(12,2)  as tg,
        (json_array_elements(informacionretroactivo)->>''AFPAPORTETRABAJADOR'')::numeric(12,2) as afptrabajador
        
 from cuerpo where eliminado=false and idempleado='|| listaempleado.id||' and idtipocontrato in('||p_contratosseleccionados||')  and idplanilla= '||p_idplanilla||')  as t' 
         
         into  p_hbasico ,p_antiguedad,p_dominical,p_distribuciondominical,p_hextra,p_afp;
 

         
         
return query( select listaempleado.ci as ci,listaempleado.nombrecompleto as nombrecompleto,p_fechaingreso as fechaingreso,
p_hbasico as haberbasico,p_antiguedad as bantiguedad,p_dominical as dominical,p_distribuciondominical as ddominical,p_hextra as horasextras,p_afp as afp);
       
 
    

  end if;
 

end loop;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.lista_planilla_retroactivo_afp(integer, text, integer)
  OWNER TO postgres;
