--CALCOLA DISTANZA MAX E MIN TRA SLOT E TARGET

update public."Ambiti_amministrativi_Comune" a
set stat_mindist = sq.min, stat_maxdist = sq.max
from (
SELECT s.comune_nom, min(st_distance(s.geom, t.geom)),  max(st_distance(s.geom, t.geom))
FROM
  ludopatia.slot_pnt_pol s, ludopatia.target_pnt t
WHERE 
s.comune_nom = t.comune_nom
-- and s.comune_nom ilike 'cumiana%'
-- and t.comune_nom ilike 'cumiana%'
-- and (st_distance(s.geom, t.geom)) = 0
group by s.comune_nom) sq 

where a.comune_nom = sq.comune_nom





--VERIFICA NEL COMUNE DI TORINO CHE NON CI SIANO ELEMENTI GEOMETRICI SOVRAPPOSTI NEI LAYER SLOT E TARGET
SELECT s.gid, t.gid
FROM
  ludopatia.slot_pnt_pol s, ludopatia.target_pnt t
WHERE 
--upper(s.citta) = upper(t.citta)
--and 
s.citta ilike 'torino%'
and t.citta ilike 'torino%'
and s.geom = t.geom




-- AGGIORNA IL CAMPO STAT_NUMTARGET (NUMERO DI TARGET) NEL LAYER AMBITI AMMINISTRATIVI

update public."Ambiti_amministrativi_Comune"
set stat_numtarget = sq.numero
from (
select c.comune_ist, count(t.geom) numero
from public."Ambiti_amministrativi_Comune" c, ludopatia.target_pnt t
where st_intersects(c.geom,t.geom)
--and c.comune_ist = '001237'
group by c.comune_ist
) as sq
where public."Ambiti_amministrativi_Comune".comune_ist = sq.comune_ist;




-- AGGIORNA IL CAMPO STAT_NUMSLOT (NUMERO DI SLOT) NEL LAYER AMBITI AMMINISTRATIVI

update public."Ambiti_amministrativi_Comune"
set stat_numslot = sq.numero
from (
select c.comune_ist, count(s.geom) numero
from public."Ambiti_amministrativi_Comune" c, ludopatia.slot_pnt_pol s
where st_intersects(c.geom,s.geom)
--and c.comune_ist = '001237'
group by c.comune_ist
) as sq
where public."Ambiti_amministrativi_Comune".comune_ist = sq.comune_ist;




-- SELEZIONA I COMUNI CHE HANNO TARGET NEL PROPRIO TERRITORIO (CAMPO STAT_NUMTARGET NON VUOTO)
select *
from public."Ambiti_amministrativi_Comune"
where stat_numtarget is not null





---UPDATE SLOT CON COMUNE E ISTAT DA LAYER COMUNI
update ludopatia.slot_pnt_pol a
set comune_nom = sq.comune_nom, comune_ist = sq.comune_ist
from (
select c.comune_nom, c.comune_ist,  s.gid
from ludopatia.slot_pnt_pol s, public."Ambiti_amministrativi_Comune" c
where st_intersects(s.geom,c.geom)
--and c.comune_nom ilike 'rivoli'
) as sq
where a.gid = sq.gid




-----UPDATE TARGET CON COMUNE E ISTAT DA LAYER COMUNI

update ludopatia.target_pnt a
set comune_nom = sq.comune_nom, comune_ist = sq.comune_ist
from (
select c.comune_nom, c.comune_ist,  t.gid
from ludopatia.target_pnt t, public."Ambiti_amministrativi_Comune" c
where st_intersects(t.geom,c.geom)
--and c.comune_nom ilike 'rivoli'
) as sq
where a.gid = sq.gid




-- CREA UN BUFFER ATTORNO AL PUNTO DELLA SLOT, TAGLIATO SUL COMUNE

update ludopatia.slot_pnt_pol a
set geombuf = sq.miageo
from (
select st_multi(st_intersection(st_buffer(t.geom,distanza_minima),c.geom)) miageo, t.gid --, st_GeometryType(st_intersection(st_buffer(t.geom,distanza_minima),c.geom))
from ludopatia.slot_pnt_pol t, public."Ambiti_amministrativi_Comune" c
where st_intersects(t.geom,c.geom)
and t.comune_nom ilike 'cumiana'
--and st_GeometryType(st_intersection(st_buffer(t.geom,distanza_minima),c.geom)) = 'ST_MultiPolygon'
) as sq
where a.gid = sq.gid






