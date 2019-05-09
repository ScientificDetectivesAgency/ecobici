select a.*
from osm_cdmx a
join (select * from alcaldias 
	  where nomgeo = 'Benito Juárez'
		 or nomgeo = 'Alvaro Obregón'
		 or nomgeo = 'Miguel Hidalgo'
		 or nomgeo = 'Cuauhtémoc') b  
	 on st_intersects(a.geom, b.geom))

create index #nombre_tabla#_gix on #nombre_tabla# using GIST(geom);

select a.*
from denue_cdmx a
join (select * from alcaldias 
	  where nomgeo = 'Benito Juárez'
		 or nomgeo = 'Alvaro Obregón'
		 or nomgeo = 'Miguel Hidalgo'
		 or nomgeo = 'Cuauhtémoc') b  
on st_intersects(a.geom, b.geom))


alter table #tabla_puntos# add column closest_node bigint; 
update #tabla_puntos# set closest_node = u.closest_node
from  
(select b.id as #id_puntos#, (
  SELECT a.id
  FROM #tabla_vertices# As a
  ORDER BY b.geom <-> a.the_geom LIMIT 1
)as closest_node
from  #tabla_puntos# b) as c
where c.#id_puntos# = #tabla_puntos#.id

alter table #tabla_red# add column source integer;
alter table  #tabla_red# add column target integer;

select pgr_createTopology ('#tabla_red#', 0.0001, 'geom', 'id');

select * from #Tabla_vertices# v,
(SELECT node FROM pgr_drivingDistance(
        'SELECT #id#, source, target, cost, reverse_cost FROM #RED#',
        #NodoDeOrigen#, 0.16
      )) as service
where v.id = service.node
 
-- Ruta 
select b.geom, a.*
from
(select node, edge as id, cost from pgr_dijkstra(
  ' SELECT  id,
           source::int4,
           target::int4,
           cost::float8 AS cost
    FROM  #TABLA RED#', #NodoDeOrigen#, #NodoDeDestino#, directed:=false)) as a
join #TABLA RED# b
on a.id = b.id
