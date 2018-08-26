\ fitsio.h.4th
\
\ Forth translation of C file fitsio.h
\ by Krishna Myneni, Creative Consulting for Research & Education, 
\ krishna.myneni@ccreweb.org
\
\  The FITSIO software was written by William Pence at the High Energy 
\  Astrophysics Science Archive Research Center (HEASARC) at the NASA
\  Goddard Space Flight Center.
\
\ Copyright (Unpublished--all rights reserved under the copyright laws of
\ the United States), U.S. Government as represented by the Administrator
\ of the National Aeronautics and Space Administration.  No copyright is
\ claimed in the United States under Title 17, U.S. Code.
\
\ Permission to freely use, copy, modify, and distribute this software
\ and its documentation without fee is hereby granted, provided that this
\ copyright notice and disclaimer of warranty appears in all copies.
\
\ DISCLAIMER:
\
\ THE SOFTWARE IS PROVIDED 'AS IS' WITHOUT ANY WARRANTY OF ANY KIND,
\ EITHER EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING, BUT NOT LIMITED TO,
\ ANY WARRANTY THAT THE SOFTWARE WILL CONFORM TO SPECIFICATIONS, ANY
\ IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
\ PURPOSE, AND FREEDOM FROM INFRINGEMENT, AND ANY WARRANTY THAT THE
\ DOCUMENTATION WILL CONFORM TO THE SOFTWARE, OR ANY WARRANTY THAT THE
\ SOFTWARE WILL BE ERROR FREE.  IN NO EVENT SHALL NASA BE LIABLE FOR ANY
\ DAMAGES, INCLUDING, BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL OR
\ CONSEQUENTIAL DAMAGES, ARISING OUT OF, RESULTING FROM, OR IN ANY WAY
\ CONNECTED WITH THIS SOFTWARE, WHETHER OR NOT BASED UPON WARRANTY,
\ CONTRACT, TORT , OR OTHERWISE, WHETHER OR NOT INJURY WAS SUSTAINED BY
\ PERSONS OR PROPERTY OR OTHERWISE, AND WHETHER OR NOT LOSS WAS SUSTAINED
\ FROM, OR AROSE OUT OF THE RESULTS OF, OR USE OF, THE SOFTWARE OR
\ SERVICES PROVIDED HEREUNDER."


0   constant NULL        \ generic for C functions

\ Constants and structures from fitsio.h

0   constant READONLY          \ options when opening a file
1   constant READWRITE 

40 constant NIOBUF   \ number of IO buffers to create (default = 40)
          \ !! Significantly increasing NIOBUF may degrade performance !! 

2880 constant IOBUFLEN        \ size in bytes of each IO buffer (DONT CHANGE!)

\ String Lengths, for use when allocating character arrays:

1025 constant FLEN_FILENAME   \ max length of a filename
72   constant FLEN_KEYWORD    \ max length of a keyword
81   constant FLEN_CARD       \ max length of a FITS header card
71   constant FLEN_VALUE      \ max length of a keyword value string
73   constant FLEN_COMMENT    \ max length of a keyword comment string
81   constant FLEN_ERRMSG     \ max length of a CFITSIO error message
31   constant FLEN_STATUS     \ max length of a CFITSIO status text string

\ BITPIX data type code values for FITS images:

  8 constant  BYTE_IMG       \   8-bit unsigned integers 
 16 constant  SHORT_IMG      \  16-bit   signed integers 
 32 constant  LONG_IMG       \  32-bit   signed integers 
 64 constant  LONGLONG_IMG   \  64-bit   signed integers 
-32 constant  FLOAT_IMG      \  32-bit single precision floating point 
-64 constant  DOUBLE_IMG     \  64-bit double precision floating point 

\  The following 4 data type codes are also supported by CFITSIO:
10 constant  SBYTE_IMG       \  8-bit signed integers, equivalent to 
                             \  BITPIX = 8, BSCALE = 1, BZERO = -128 
20 constant  USHORT_IMG      \ 16-bit unsigned integers, equivalent to 
                             \  BITPIX = 16, BSCALE = 1, BZERO = 32768 
40 constant  ULONG_IMG       \ 32-bit unsigned integers, equivalent to 
                             \  BITPIX = 32, BSCALE = 1, BZERO = 2147483648 

\ Codes for the data type of binary table columns and/or for the
\ data type of variables when reading or writing keywords or data:

\                             DATATYPE               TFORM CODE
  1 constant  TBIT           \                             'X' 
 11 constant  TBYTE          \  8-bit unsigned byte,       'B' 
 14 constant  TLOGICAL       \  logicals (int for keywords     
                             \   and char for table cols   'L' 
 16 constant  TSTRING        \  ASCII string,              'A' 
 21 constant  TSHORT         \  signed short,              'I' 
 41 constant  TLONG          \  signed long,                   
 81 constant  TLONGLONG      \  64-bit long signed integer 'K' 
 42 constant  TFLOAT         \  single precision float,    'E' 
 82 constant  TDOUBLE        \  double precision float,    'D' 
 83 constant  TCOMPLEX       \  complex (pair of floats)   'C' 
163 constant  TDBLCOMPLEX    \  double complex (2 doubles) 'M' 

\  The following data type codes are also supported by CFITSIO:
31 constant TINT             \  int                            
12 constant TSBYTE           \  8-bit signed byte,         'S' 
30 constant TUINT            \  unsigned int               'V' 
20 constant TUSHORT          \  unsigned short             'U'  
40 constant TULONG           \  unsigned long                  

\  The following data type code is only for use with fits\_get\_coltype
41 constant TINT32BIT        \  signed 32-bit int,         'J' 


\ HDU type code values (value returned when moving to new HDU):

 0 constant  IMAGE_HDU       \  Primary Array or IMAGE HDU
 1 constant  ASCII_TBL       \  ASCII  table HDU
 2 constant  BINARY_TBL      \  Binary table HDU
-1 constant  ANY_HDU         \  matches any type of HDU

\ Column name and string matching case-sensitivity:

 1 constant  CASESEN         \ do case-sensitive string match
 0 constant  CASEINSEN       \ do case-insensitive string match

\ Logical states (if TRUE and FALSE are not already defined):

\  1 constant TRUE
\  0 constant FALSE

\ Values to represent undefined floating point numbers:

-9.11912E-36          fconstant  FLOATNULLVALUE  
-9.1191291391491E-36  fconstant  DOUBLENULLVALUE 

\ Image compression algorithm definitions
 1 constant  SUBTRACTIVE_DITHER_1
 6 constant  MAX_COMPRESS_DIM 
11 constant  RICE_1
21 constant  GZIP_1
31 constant  PLIO_1  
41 constant  HCOMPRESS_1
51 constant  BZIP2_1     \ not publicly supported; only for test purposes 
 0 constant  NOCOMPRESS


555 constant VALIDSTRUC  \ magic value used to identify if structure is valid 

: ptr: 1 4 field ;
[undefined] int64: [IF] : int64: 1 8 field ; [THEN]

struct                    \ structure used to store basic FITS file information 

    int: filehandle       \  handle returned by the file open function 
    int: driver           \  defines which set of I/O drivers should be used
    int: open_count       \  number of opened 'fitsfiles' using this structure
    ptr: filename         \  file name
    int: validcode        \  magic value used to verify that structure is valid
    int: only_one         \  flag meaning only copy the specified extension
    int64: filesize       \  current size of the physical disk file in bytes
    int64: logfilesize    \  logical size of file, including unflushed buffers
    int: lasthdu          \  is this the last HDU in the file? 0 = no, else yes
    int64: bytepos        \  current logical I/O pointer position in file
    int64: io_pos         \  current I/O pointer position in the physical file
    int: curbuf           \  number of I/O buffer currently in use
    int: curhdu           \  current HDU number; 0 = primary array
    int: hdutype          \  0 = primary array, 1 = ASCII table, 2 = binary table
    int: writemode        \  0 = readonly, 1 = readwrite
    int: maxhdu           \  highest numbered HDU known to exist in the file
    int: _MAXHDU          \  dynamically allocated dimension of headstart array
    int64: *headstart     \  byte offset in file to start of each HDU
    int64:  headend       \  byte offest in file to end of the current HDU header
    int64: ENDpos         \  byte offest to where the END keyword was last written
    int64: nextkey        \  byte offset in file to beginning of next keyword
    int64: datastart      \  byte offset in file to start of the current data unit
    int: imgdim           \  dimension of image; cached for fast access
    99 cells 2* buf: imgnaxis \ length of each axis; cached for fast access
    int: tfield            \ number of fields in the table (primary array has 2
    int64: origrows       \  original number of rows (value of NAXIS2 keyword)
    int64: numrows        \  number of rows in the table (dynamically updated)
    int64: rowlength      \  length of a table row or image size (bytes)
    ptr:   tableptr       \  pointer to the table structure
    int64: heapstart      \  heap start byte relative to start of data unit
    int64: heapsize       \  size of the heap, in bytes

         \ the following elements are related to compressed images
    int: request_compress_type  \ requested image compression algorithm 
    MAX_COMPRESS_DIM cells buf: request_tilesize \ requested tiling size 

    sfloat: request_hcomp_scale   \ requested HCOMPRESS scale factor 
    int: request_hcomp_smooth     \ requested HCOMPRESS smooth parameter
    int: request_quantize_dither  \ requested dithering mode when quantizing
                                  \ floating point images to integer

    int: compressimg        \ 1 if HDU contains a compressed image, else 0 
    int: quantize_dither    \ floating point pixel quantization algorithm
    12 buf: zcmptype        \ compression type string
    int: compress_type      \ type of compression algorithm
    int: zbitpix            \ FITS data type of image (BITPIX)
    int: zndim              \ dimension of image
    MAX_COMPRESS_DIM cells buf: znaxis   \ length of each axis
    MAX_COMPRESS_DIM cells buf: tilesize \ size of compression tiles
    int32: maxtilelen        \ max number of pixels in each image tile
    int32: maxelem	    \ maximum length of variable length arrays

    int: cn_compressed	    \ column number for COMPRESSED_DATA column
    int: cn_uncompressed    \ column number for UNCOMPRESSED_DATA column
    int: cn_zscale	    \ column number for ZSCALE column
    int: cn_zzero	    \ column number for ZZERO column
    int: cn_zblank          \ column number for the ZBLANK column

    dfloat: zscale          \ scaling value, if same for all tiles
    dfloat: zzero           \ zero pt, if same for all tiles
    dfloat: cn_bscale       \ value of the BSCALE keyword in header
    dfloat: cn_bzero        \ value of the BZERO keyword (may be reset)
    dfloat: cn_actual_bzero \ actual value of the BZERO keyword 
    int: zblank             \ value for null pixels, if not a column

    int: rice_blocksize     \ first compression parameter: pixels/block
    int: rice_bytepix       \ 2nd compression parameter: bytes/pixel
    sfloat: quantize_level  \ floating point quantization level
    sfloat: hcomp_scale      \ 1st hcompress compression parameter
    int: hcomp_smooth       \ 2nd hcompress compression parameter

    int:  tilerow           \ row number of the uncompressed tiledata
    int32: tiledatasize     \ length of the tile data in bytes
    int: tiletype           \ datatype of the tile (TINT, TSHORT, etc)
    ptr: tiledata           \ uncompressed tile of data, for row tilerow
    ptr: tilenullarray      \ optional array of null value flags
    int: tileanynull        \ anynulls in this tile?

    ptr: iobuffer           \ pointer to FITS file I/O buffers
    NIOBUF cells buf: bufrecnum \ file record number of each of the buffers
    NIOBUF cells buf: dirty     \ has the corresponding buffer been modified?
    NIOBUF cells buf: ageindex  \ relative age of each buffer
end-struct FITSfile%

struct                      \ structure used to store basic HDU information

    int: HDUposition        \ HDU position in file; 0 = first HDU
    ptr: Fptr               \ pointer to FITS file structure
end-struct fitsfile%

\ error status codes

-106  constant  CREATE_DISK_FILE     \ create disk file, without extended filename syntax
-105  constant  OPEN_DISK_FILE       \ open disk file, without extended filename syntax
-104  constant  SKIP_TABLE           \ move to 1st image when opening file
-103  constant  SKIP_IMAGE           \ move to 1st table when opening file
-102  constant  SKIP_NULL_PRIMARY    \ skip null primary array when opening file
-101  constant  USE_MEM_BUFF         \ use memory buffer when opening file
 -11  constant  OVERFLOW_ERR         \ overflow during datatype conversion
  -9  constant  PREPEND_PRIMARY      \ used in ffiimg to insert new primary array
 101  constant  SAME_FILE            \ input and output files are the same
 103  constant  TOO_MANY_FILES       \ tried to open too many FITS files
 104  constant  FILE_NOT_OPENED      \ could not open the named file
 105  constant  FILE_NOT_CREATED     \ could not create the named file
 106  constant  WRITE_ERROR          \ error writing to FITS file
 107  constant  END_OF_FILE          \ tried to move past end of file
 108  constant  READ_ERROR           \ error reading from FITS file
 110  constant  FILE_NOT_CLOSED      \ could not close the file
 111  constant  ARRAY_TOO_BIG        \ array dimensions exceed internal limit
 112  constant  READONLY_FILE        \ Cannot write to readonly file
 113  constant  MEMORY_ALLOCATION    \ Could not allocate memory
 114  constant  BAD_FILEPTR          \ invalid fitsfile pointer
 115  constant  NULL_INPUT_PTR       \ NULL input pointer to routine
 116  constant  SEEK_ERROR           \ error seeking position in file

 121  constant  BAD_URL_PREFIX       \ invalid URL prefix on file name
 122  constant  TOO_MANY_DRIVERS     \ tried to register too many IO drivers
 123  constant  DRIVER_INIT_FAILED   \ driver initialization failed
 124  constant  NO_MATCHING_DRIVER   \ matching driver is not registered
 125  constant  URL_PARSE_ERROR      \ failed to parse input file URL
 126  constant  RANGE_PARSE_ERROR    \ failed to parse input file URL

 150  constant  SHARED_ERRBASE	
SHARED_ERRBASE 1+   constant  SHARED_BADARG	
SHARED_ERRBASE 2 +  constant  SHARED_NULPTR	
SHARED_ERRBASE 3 +  constant  SHARED_TABFULL	
SHARED_ERRBASE 4 +  constant  SHARED_NOTINIT	
SHARED_ERRBASE 5 +  constant  SHARED_IPCERR	
SHARED_ERRBASE 6 +  constant  SHARED_NOMEM	
SHARED_ERRBASE 7 +  constant  SHARED_AGAIN	
SHARED_ERRBASE 8 +  constant  SHARED_NOFILE	
SHARED_ERRBASE 9 +  constant  SHARED_NORESIZE	

 201  constant  HEADER_NOT_EMPTY   \  header already contains keywords
 202  constant  KEY_NO_EXIST       \  keyword not found in header
 203  constant  KEY_OUT_BOUNDS     \  keyword record number is out of bounds
 204  constant  VALUE_UNDEFINED    \  keyword value field is blank
 205  constant  NO_QUOTE           \  string is missing the closing quote
 206  constant  BAD_INDEX_KEY      \  illegal indexed keyword name
 207  constant  BAD_KEYCHAR        \  illegal character in keyword name or card
 208  constant  BAD_ORDER          \  required keywords out of order
 209  constant  NOT_POS_INT        \  keyword value is not a positive integer
 210  constant  NO_END             \  couldn't find END keyword
 211  constant  BAD_BITPIX         \  illegal BITPIX keyword value
 212  constant  BAD_NAXIS          \  illegal NAXIS keyword value
 213  constant  BAD_NAXES          \  illegal NAXISn keyword value
 214  constant  BAD_PCOUNT         \  illegal PCOUNT keyword value
 215  constant  BAD_GCOUNT         \  illegal GCOUNT keyword value
 216  constant  BAD_TFIELDS        \  illegal TFIELDS keyword value
 217  constant  NEG_WIDTH          \  negative table row size
 218  constant  NEG_ROWS           \  negative number of rows in table
 219  constant  COL_NOT_FOUND      \  column with this name not found in table
 220  constant  BAD_SIMPLE         \  illegal value of SIMPLE keyword
 221  constant  NO_SIMPLE          \  Primary array doesn't start with SIMPLE
 222  constant  NO_BITPIX          \  Second keyword not BITPIX
 223  constant  NO_NAXIS           \  Third keyword not NAXIS
 224  constant  NO_NAXES           \  Couldn't find all the NAXISn keywords
 225  constant  NO_XTENSION        \  HDU doesn't start with XTENSION keyword
 226  constant  NOT_ATABLE         \  the CHDU is not an ASCII table extension
 227  constant  NOT_BTABLE         \  the CHDU is not a binary table extension
 228  constant  NO_PCOUNT          \  couldn't find PCOUNT keyword
 229  constant  NO_GCOUNT          \  couldn't find GCOUNT keyword
 230  constant  NO_TFIELDS         \  couldn't find TFIELDS keyword
 231  constant  NO_TBCOL           \  couldn't find TBCOLn keyword
 232  constant  NO_TFORM           \  couldn't find TFORMn keyword
 233  constant  NOT_IMAGE          \  the CHDU is not an IMAGE extension
 234  constant  BAD_TBCOL          \  TBCOLn keyword value < 0 or > rowlength
 235  constant  NOT_TABLE          \  the CHDU is not a table
 236  constant  COL_TOO_WIDE       \  column is too wide to fit in table
 237  constant  COL_NOT_UNIQUE     \  more than 1 column name matches template
 241  constant  BAD_ROW_WIDTH      \  sum of column widths not = NAXIS1
 251  constant  UNKNOWN_EXT        \  unrecognizable FITS extension type
 252  constant  UNKNOWN_REC        \  unrecognizable FITS record
 253  constant  END_JUNK           \  END keyword is not blank
 254  constant  BAD_HEADER_FILL    \  Header fill area not blank
 255  constant  BAD_DATA_FILL      \  Data fill area not blank or zero
 261  constant  BAD_TFORM          \  illegal TFORM format code
 262  constant  BAD_TFORM_DTYPE    \  unrecognizable TFORM datatype code
 263  constant  BAD_TDIM           \  illegal TDIMn keyword value
 264  constant  BAD_HEAP_PTR       \  invalid BINTABLE heap address
 
 301  constant  BAD_HDU_NUM         \ HDU number < 1 or > MAXHDU
 302  constant  BAD_COL_NUM         \ column number < 1 or > tfields
 304  constant  NEG_FILE_POS        \ tried to move before beginning of file
 306  constant  NEG_BYTES           \ tried to read or write negative bytes
 307  constant  BAD_ROW_NUM         \ illegal starting row number in table
 308  constant  BAD_ELEM_NUM        \ illegal starting element number in vector
 309  constant  NOT_ASCII_COL       \ this is not an ASCII string column
 310  constant  NOT_LOGICAL_COL     \ this is not a logical datatype column
 311  constant  BAD_ATABLE_FORMAT   \ ASCII table column has wrong format
 312  constant  BAD_BTABLE_FORMAT   \ Binary table column has wrong format
 314  constant  NO_NULL             \ null value has not been defined
 317  constant  NOT_VARI_LEN        \ this is not a variable length column
 320  constant  BAD_DIMEN           \ illegal number of dimensions in array
 321  constant  BAD_PIX_NUM         \ first pixel number greater than last pixel
 322  constant  ZERO_SCALE          \ illegal BSCALE or TSCALn keyword = 0
 323  constant  NEG_AXIS            \ illegal axis length < 1
 
 340  constant  NOT_GROUP_TABLE         
 341  constant  HDU_ALREADY_MEMBER      
 342  constant  MEMBER_NOT_FOUND        
 343  constant  GROUP_NOT_FOUND         
 344  constant  BAD_GROUP_ID            
 345  constant  TOO_MANY_HDUS_TRACKED   
 346  constant  HDU_ALREADY_TRACKED     
 347  constant  BAD_OPTION              
 348  constant  IDENTICAL_POINTERS      
 349  constant  BAD_GROUP_ATTACH        
 350  constant  BAD_GROUP_DETACH        

 401  constant  BAD_I2C             \ bad int to formatted string conversion
 402  constant  BAD_F2C             \ bad float to formatted string conversion
 403  constant  BAD_INTKEY          \ can't interprete keyword value as integer
 404  constant  BAD_LOGICALKEY      \ can't interprete keyword value as logical
 405  constant  BAD_FLOATKEY        \ can't interprete keyword value as float
 406  constant  BAD_DOUBLEKEY       \ can't interprete keyword value as double
 407  constant  BAD_C2I             \ bad formatted string to int conversion
 408  constant  BAD_C2F             \ bad formatted string to float conversion
 409  constant  BAD_C2D             \ bad formatted string to double conversion
 410  constant  BAD_DATATYPE        \ bad keyword datatype code
 411  constant  BAD_DECIM           \ bad number of decimal places specified
 412  constant  NUM_OVERFLOW        \ overflow during datatype conversion

 413  constant  DATA_COMPRESSION_ERR   \ error in imcompress routines
 414  constant  DATA_DECOMPRESSION_ERR \ error in imcompress routines
 415  constant  NO_COMPRESSED_TILE     \ compressed tile doesn't exist

 420  constant  BAD_DATE           \ error in date or time conversion

 431  constant  PARSE_SYNTAX_ERR   \ syntax error in parser expression
 432  constant  PARSE_BAD_TYPE     \ expression did not evaluate to desired type
 433  constant  PARSE_LRG_VECTOR   \ vector result too large to return in array
 434  constant  PARSE_NO_OUTPUT    \ data parser failed not sent an out column
 435  constant  PARSE_BAD_COL      \ bad data encounter while parsing column
 436  constant  PARSE_BAD_OUTPUT   \ Output file not of proper type

 501  constant  ANGLE_TOO_BIG      \ celestial angle too large for projection
 502  constant  BAD_WCS_VAL        \ bad celestial coordinate or pixel value
 503  constant  WCS_ERROR          \ error in celestial coordinate calculation
 504  constant  BAD_WCS_PROJ       \ unsupported type of celestial projection
 505  constant  NO_WCS_KEY         \ celestial coordinate keywords not found
 506  constant  APPROX_WCS_KEY     \ approximate WCS keywords were calculated

 999  constant  NO_CLOSE_ERROR     \ special value used internally to switch off
                                   \ the error message from ffclos and ffchdu

\ end of fitsio.h.4th

