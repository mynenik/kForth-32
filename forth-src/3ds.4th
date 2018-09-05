\ 3ds.4th
\
\ Read 3D models from AutoCad 3ds files
\
\ Krishna Myneni, Creative Consulting for Research and Education
\ Revisions:
\
[undefined] struct [IF] s" struct.4th" included     [THEN]
[undefined] int16: [IF] s" struct-ext.4th" included [THEN]

\ Chunk IDs
base @
HEX
4d4d  constant  CHUNK_ID_MAIN
4d4d  constant  CHUNK_ID_EDIT
4000  constant  CHUNK_ID_EDIT_OBJECT
4100  constant  CHUNK_ID_EDIT_OBJECT_TRIMESH
4110  constant  CHUNK_ID_VERTEXLIST
4120  constant  CHUNK_ID_POLYGONLIST
4140  constant  CHUNK_ID_MAPPING
base !

struct
  sfloat: 3ds_Vertex->x 
  sfloat: 3ds_Vertex->y
  sfloat: 3ds_Vertex->z
end-struct 3ds_Vertex%

struct
  int16: 3ds_Polygon->a
  int16: 3ds_Polygon->b
  int16: 3ds_Polygon->c
end-struct 3ds_Polygon%

3ds_Vertex%  %size constant VTX_SIZE
3ds_Polygon% %size constant PGN_SIZE

: 3ds_Vertex create 3ds_Vertex% %allot drop ;

: 3ds_Vertex! ( fx fy fz avertex -- )
   dup >r 3ds_Vertex->z sf!  r@ 3ds_Vertex->y sf!  r> 3ds_Vertex->x sf! ;

: 3ds_Polygon! ( a b c apolygon -- )
   dup >r 3ds_Polygon->c w!  r@ 3ds_Polygon->b w!  r> 3ds_Polygon->a w! ;


: read-3ds ( a u -- )
	
;

