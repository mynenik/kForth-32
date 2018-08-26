\ libcfitsio.4th
\
\ Forth interface to the CFITSIO library for reading/writing 
\ FITS format files.
\
\ Copyright (c) 2009 Creative Consulting for Research and Education
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
\
\ Requires kForth ver >= 1.5.0 and the following files:
\
\   lib-interface.4th, struct.4th, struct-ext.4th,
\   fitsio.4th
\
\ Notes:
\
\   1. Requires version 3.20 or greater of the CFITSIO library.
\      See the following link:
\
\         http://heasarc.gsfc.nasa.gov/docs/software/fitsio/fitsio.html
\
\   2. For interfacing to kForth, the shared object library must be a 32-bit
\      library. If building the shared object library on a 64-bit system, you
\      must manually modify the Makefile to specify flags to build a
\      32-bit version of the library:
\
\        a) Execute ./configure to generate the Makefile.
\
\        b) Use an editor to open the Makefile, and add "-m32" on
\           the line which begins "CFLAGS = "
\
\        c) Add "-m32" following "cc " on the line which begins with
\           "SHLIB_LD = "
\
\        d) Build the shared object library by performing,
\
\             make shared
\
\           This will generate the libcfitsio.so file, which may be
\           copied to a system directory such as /usr/lib or /usr/lib32
\
\ Revisions: 
\   2009-10-10  km
\   2009-10-17  km  further additions
\   2009-11-21  km  revised ffvers to use consistent interface

include ans-words
include asm
include strings
include lib-interface
include struct
include struct-ext

vocabulary FITSIO
also FITSIO definitions

include fitsio.4th


0 value hndl_cfitsio
s" libcfitsio.so" open-lib 
dup 0= [IF] check-lib-error [THEN]
to hndl_cfitsio
cr .( Opened the CFITSIO library )

\ Error Status Routines
s" ffgerr"  C-word  ffgerr  ( nstatus  aerrtext -- )
s" ffgmsg"  C-word  ffgmsg  ( aerr_message -- n )
s" ffrprt"  C-word  ffrprt  ( astream nstatus -- )
cr .( loaded error status routines )

\ FITS File I/O Routines
s" ffopen"  C-word  ffopen   ( afptr afname niomode astatus -- n )
s" ffdkopn" C-word  ffdkopn  ( afptr afname niomode astatus -- n )
s" ffdopn"  C-word  ffdopn   ( afptr afname niomode astatus -- n )
s" fftopn"  C-word  fftopn   ( afptr afname niomode astatus -- n )
s" ffiopn"  C-word  ffiopn   ( afptr afname niomode astatus -- n )
s" ffreopen" C-word ffreopen ( aopenfptr anewfptr astatus -- n )
s" ffinit"  C-word  ffinit   ( afptr afname astatus -- n )
s" ffdkinit" C-word  ffdkinit ( afptr afname astatus -- n )
s" ffclos"  C-word  ffclos   ( afptr astatus -- n )
s" ffdelt"  C-word  ffdelt   ( afptr astatus -- n )
s" ffflnm"  C-word  ffflnm   ( afptr afname astatus -- n )
s" ffflmd"  C-word  ffflmd   ( afptr afmode astatus -- n )
s" ffurlt"  C-word  ffurlt   ( afptr aurlType astatus -- n )
s" ffexist" C-word  ffexist  ( ainfile anexists astatus -- n )
s" fftplt"  C-word  fftplt   ( afptr afilename atempname astatus -- n )
s" ffflus"  C-word  ffflus   ( afptr astatus -- n )
s" ffflsh"  C-word  ffflsh   ( afptr nclearbuf astatus -- n )
s" ffdelt"  C-word  ffdelt   ( afptr astatus -- n )
s" ffflnm"  C-word  ffflnm   ( afptr afilename astatus -- n )
s" ffflmd"  C-word  ffflmd   ( afptr afilemode astatus -- n )
s" fits_delete_iraf_file"  C-word  fits_delete_iraf_file ( afilename \
     astatus -- n )
s" fits_split_names" C-word  fits_split_names  ( alist -- a )
cr .( loaded file access routines )

\ HDU Access Routines
s" ffmahd"  C-word  ffmahd   ( afptr nhdunum aexttype astatus -- n )
s" ffmrhd"  C-word  ffmrhd   ( afptr nhdumov aexttype astatus -- n )
s" ffmnhd"  C-word  ffmnhd   ( afptr nexttype ahduname nhduvers astatus -- n )
s" ffthdu"  C-word  ffthdu   ( afptr anhdu astatus -- n )
s" ffcrhd"  C-word  ffcrhd   ( afptr astatus -- n )
s" ffcrim"  C-word  ffcrim   ( afptr  nbitpix  naxis  anaxes  astatus -- n )
s" ffcrimll" C-word  ffcrimll ( afptr nbitpix naxis adnaxes astatus -- n )
s" ffcrtb"   C-word  ffcrtb  ( afptr ntbltype dnaxis2 ntfields attype \
     aptform aptunit aextname astatus -- n )
s" ffiimg"  C-word  ffiimg   ( afptr nbitpix naxis anaxes astatus -- n )
s" ffiimgll" C-word ffiimgll ( afptr nbitpix naxis anaxes astatus -- n )
s" ffitab"  C-word  ffitab   ( afptr dnaxis1 dnaxis2 ntfields aattype \
     atbcol aatform aatunit aextname astatus -- n )
s" ffibin"  C-word  ffibin   ( afptr dnaxis2 ntfields aattype aatform \
     aatunit aextname dpcount astatus -- n )
s" ffghdn"  C-word  ffghdn   ( afptr achdunum -- n )
s" ffghdt"  C-word  ffghdt   ( afptr aexttype astatus -- n )
s" ffghad"  C-word  ffghad   ( afptr aheadstart adatastart adataend \
     astatus -- n )
s" ffghadll" C-word ffghadll ( aftpr aheadstart adatastart adataend \
     astatus -- n )
s" ffghof"  C-word  ffghof   ( afptr aheadstart adatastart adataend \
     astatus -- n )
s" ffghsp"  C-word  ffghsp   ( afptr anexist anmore astatus -- n )
s" ffghps"  C-word  ffghps   ( afptr anexist aposition astatus -- n )
s" ffmaky"  C-word  ffmaky   ( afptr nrec astatus -- n )
s" ffmrky"  C-word  ffmrky   ( afptr nrec astatus -- n )
s" ffcpfl"  C-word  ffcpfl   ( ainfptr aoutfptr nprev ncur nfollow \
     astatus --n )
s" ffcopy"  C-word  ffcopy   ( ainfptr aoutfptr nmorekeys astatus -- n )
s" ffwrhdu" C-word  ffwrhdu  ( afptr aoutstream astatus -- n )
s" ffcphd"  C-word  ffcphd   ( ainfptr aoutfptr astatus -- n )
s" ffdhdu"  C-word  ffdhdu   ( afptr ahdutype astatus -- n )
s" ffchfl"  C-word  ffchfl  ( afptr astatus -- n )
s" ffcdfl"  C-word  ffcdfl  ( afptr astatus -- n )
cr .( loaded HDU access routines )

\ Keyword I/O Routines
s" ffgky"   C-word  ffgky   ( afptr ndtype akeyname avalue acomm \
                                astatus -- n )
s" ffgkey"  C-word  ffgkey  ( afptr akeyname akeyval acomm astatus -- n )
s" ffgcrd"  C-word  ffgcrd  ( afptr akeyname acard astatus -- n )
s" ffgrec"  C-word  ffgrec  ( afptr nrec acard astatus -- n )
s" ffgkyn"  C-word  ffgkyn  ( afptr nkey akeyname akeyval acomm astatus \
                                -- n )
s" ffgkys"  C-word  ffgkys  ( afptr akeyname avalue acomm astatus -- n )
s" ffgkls"  C-word  ffgkls  ( afptr akeyname aavalue acomm astatus -- n )
s" ffgkyl"  C-word  ffgkyl  ( afptr akeyname avalue acomm astatus -- n )
s" ffgnxk"  C-word  ffgnxk  ( afptr ainclist ninc aexclist nexc acard \
                                astatus -- n )
s" ffgunt"  C-word  ffgunt  ( afptr akeyname aunit astatus -- n )
s" ffhdr2str" C-word ffhdr2str  ( afptr nexclude_comm aaexclist \
     nexc aaheader ankeys astatus -- n )
s" ffpky"   C-word  ffpky   ( afptr ndtype akeyname avalue acomm \
     astatus -- n )
s" ffuky"   C-word  ffuky   ( afptr ndtype akeyname avalue acomm \
     astatus -- n )
s" ffpkyu"  C-word  ffpkyu  ( afptr akeyname acomm astatus -- n )
s" ffukyu"  C-word  ffukyu  ( afptr akeyname acomm astatus -- n )
s" ffpcom"  C-word  ffpcom  ( afptr acomm astatus -- n )
s" ffphis"  C-word  ffphis  ( afptr ahistory astatus -- n )
s" ffpdat"  C-word  ffpdat  ( afptr astatus -- n )
s" ffprec"  C-word  ffprec  ( afptr acard astatus -- n )
s" ffucrd"  C-word  ffucrd  ( afptr akeyname acard astatus -- n )
s" ffmcom"  C-word  ffmcom  ( afptr akeyname acomm astatus -- n )
s" ffpunt"  C-word  ffpunt  ( afptr akeyname aunit astatus -- n )
s" ffmnam"  C-word  ffmnam  ( afptr aoldname anewname astatus -- n )
s" ffdrec"  C-word  ffdrec  ( afptr nkeypos astatus -- n )
s" ffdkey"  C-word  ffdkey  ( afptr akeyname astatus -- n )
s" ffmrec"  C-word  ffmrec  ( afptr nkey acard astatus -- n )
s" ffmcrd"  C-word  ffmcrd  ( afptr akeyname acard astatus -- n )
s" ffmnam"  C-word  ffmnam  ( afptr aoldname anewname astatus -- n )
s" ffmkyu"  C-word  ffmkyu  ( afptr akeyname acomm astatus -- n )
s" ffmkys"  C-word  ffmkys  ( afptr akeyname avalue acomm astatus -- n )
s" ffirec"  C-word  ffirec  ( afptr nkey acard astatus -- n )
s" ffikey"  C-word  ffikey  ( afptr acard astatus -- n )
cr .( loaded keyword reading/writing routines )

\ Primary Array or IMAGE Extension I/O Routines
s" ffgidt"   C-word  ffgidt   ( afptr aimgtype astatus -- n )
s" ffgiet"   C-word  ffgiet   ( afptr aimgtype astatus -- n )
s" ffgidm"   C-word  ffgidm   ( afptr anaxis astatus -- n )
s" ffgisz"   C-word  ffgisz   ( afptr nlen anaxes astatus -- n )
s" ffgiszll" C-word  ffgiszll ( afptr nlen adnaxes astatus -- n )
s" ffgipr"   C-word  ffgipr   ( afptr nmaxaxis aimgtype anaxis -- n )
s" ffgiprll" C-word  ffgiprll ( afptr nmaxaxis aimgtype anaxis -- n )
s" ffrsim"   C-word  ffrsim   ( afptr nbitpix naxis anaxes astatus -- n )
s" ffrsimll" C-word  ffrsimll ( afptr nbitpix naxis anaxes astatus -- n )

s" fits_copy_cell2image"  C-word  fits_copy_cell2image  ( afptr anewptr \
     acolname nrownum astatus -- n )
s" fits_copy_image2cell"  C-word  fits_copy_image2cell  ( afptr anewptr \
     acolname nrownum  ncopykeyflag astatus -- n )
s" ffpss"    C-word  ffpss   ( afptr ndtype afpixel alpixel aarray \
     astatus -- n )
s" ffppx"    C-word  ffppx   ( afptr ndtype afirstpix dnelem aarray \
     astatus -- n )
s" ffppxll"  C-word  ffppxll ( afptr ndtype afirstpix dnelem aarray \
     astatus -- n )
s" ffppxn"   C-word  ffppxn  ( afptr ndtype afirstpix dnelem aarray \ 
     anulval astatus -- n )
s" ffppxnll" C-word  ffppxnll  ( afptr ndtype afirstpix dnelem aarray \
     anulval astatus -- n )
s" ffppr"    C-word  ffppr  ( afptr ndtype dfirst dnelem aarray astatus \
      -- n )
s" ffpprn"   C-word  ffpprn ( afptr dfirstelem dnelem astatus -- n )
s" ffgsv"    C-word  ffgsv  ( afptr ndtype ablc atrc ainc anulval aarray \
     aanynul astatus -- n )
s" ffgpv"    C-word  ffgpv  ( afptr ndtype dfirstelem dnelem anulval \
     aarray aanynul astatus -- n )
s" ffgpvb"   C-word  ffgpvb ( afptr ngroup dfirstelem dnelem nulval \
     aarray aanynul astatus -- n )
s" ffgpvsb"  C-word  ffgpvsb ( afptr ngroup dfirstelem dnelem nulval \
     aarray aanynul astatus -- n )
s" ffgpf"    C-word  ffgpf  ( afptr ndtype dfirstelem dnelem aarray \
     anullarray aanynul astatus -- n )
s" ffgpxv"   C-word  ffgpxv ( afptr ndtype afirstpix dnelem anulval \
     aarray aanynul astatus -- n )
s" ffgpxvll" C-word  ffgpxvll ( afptr ndtype afirstpix dnelem anulval \
     aarray aanynul astatus -- n )
s" ffgpxf"   C-word  ffgpxf   ( afptr ndtype afirstpix dnelem aarray \ 
     anullarray aanynul astatus -- n )
s" ffgpxfll" C-word  ffgpxfll ( afptr ndtype afirstpix dnelem aarray \
     anullarray aanynul astatus -- n )
s" ffgrec"  C-word  ffgrec  ( afptr nrec acard astatus -- n )
cr .( loaded image extension routines ) 

\ Image Compression Routines
s" fits_set_compression_type" C-word  fits_set_compression_type  ( afptr \
     nctype astatus -- n )
s" fits_set_tile_dim"  C-word  fits_set_tile_dim  ( afptr ndim adims \
     astatus -- n )
s" fits_set_noise_bits"  C-word  fits_set_noise_bits  ( afptr noisebits \
     astatus -- n )
s" fits_set_quantize_level"  C-word  fits_set_quantize_level  ( afptr \
     sqlevel astatus -- n )
s" fits_set_hcomp_scale"  C-word  fits_set_hcomp_scale ( afptr sscale \
     astatus -- n )
s" fits_set_hcomp_smooth" C-word  fits_set_hcomp_smooth  ( afptr nsmooth \
     astatus -- n )
s" fits_set_quantize_dither"  C-word  fits_set_quantize_dither ( afptr \
     ndither astatus -- n )
s" fits_get_compression_type" C-word  fits_get_compression_type  ( afptr \
     actype astatus -- n )
s" fits_get_tile_dim"   C-word  fits_get_tile_dim  ( afptr ndim adims \
     astatus -- n )
s" fits_get_quantize_level"  C-word  fits_get_quantize_level  ( afptr aqlevel \
     astatus -- n )
s" fits_get_noise_bits"  C-word  fits_get_noise_bits  ( afptr anoisebits \
     astatus -- n )
s" fits_get_hcomp_scale"  C-word  fits_get_hcomp_scale  ( afptr ascale \
     astatus -- n )
s" fits_get_hcomp_smooth"  C-word  fits_get_hcomp_smooth  ( afptr asmooth \
     astatus -- n )
s" fits_img_compress"   C-word  fits_img_compress  ( ainfptr aoutfptr \
     astatus -- n )
\ s" fits_compress_img"  C-word  fits_compress_img  ( ainfptr aoutfptr \
\     ncompress_type  atilesize nparm1 nparm2 astatus -- n )
s" fits_is_compressed_image" C-word  fits_is_compressed_image ( afptr \
     astatus -- n )
\ s" fits_decompress_img"  C-word  fits_decompress_img  ( ainfptr aoutfptr \
\     astatus -- n )
s" fits_img_decompress"  C-word  fits_img_decompress  ( ainfptr aoutfptr \
     astatus -- n )
cr .( loaded image compression routines )

\ ASCII and Binary Table Routines
s" ffgnrw"   C-word  ffgnrw  ( afptr anrows astatus -- n )
s" ffgnrwll" C-word  ffgnrwll  ( afptr adnrows astatus -- n )
s" ffgncl"   C-word  ffgncl  ( afptr ancols astatus -- n )
s" ffgcno"   C-word  ffgcno  ( afptr ncasesen atemplt acolnum astatus -- n )
s" ffgcnn"   C-word  ffgcnn  ( afptr ncasesen atemptl acolname acolnum \
     astatus -- n )
s" ffgtcl"   C-word  ffgtcl   ( afptr ncolnum atypecode arepeat awidth \
     astatus -- n )
s" ffgtclll" C-word  ffgtclll ( afptr ncolnum atypecode adrepeat \
     adwidth astatus -- n )
s" ffeqty"   C-word  ffeqty   ( afptr ncolnum atypecode arepeat awidth \
     astatus -- n )
s" ffeqtyll" C-word  ffeqtyll  ( afptr ncolnum atypecode arepeat awidth \
     astatus -- n )
s" ffgcdw"   C-word  ffgcdw  ( afptr ncolnum awidth astatus -- n )
s" ffgtdm"   C-word  ffgtdm  ( afptr ncolnum nmaxdim anaxis anaxes \
     astatus -- n )
s" ffptdmll" C-word  ffptdmll ( afptr ncolnum nmaxdim anaxis anaxes \
     astatus -- n )
s" ffirow"   C-word  ffirow  ( afptr dfirstrow dnrows astatus -- n )
s" ffdrow"   C-word  ffdrow  ( afptr dfirstrow dnrows astatus -- n )
s" ffdrrg"   C-word  ffdrrg  ( afptr aranges astatus -- n )
s" ffdrws"   C-word  ffdrws  ( afptr arownum nrows astatus -- n )
s" ffdrwsll" C-word  ffdrwsll ( afptr adrownum dnrows astatus -- n )
s" fficol"   C-word  fficol  ( afptr numcol attype atform astatus -- n )
s" fficls"   C-word  fficls  ( afptr nfirstcol ncols attype atform \
     astatus -- n )
s" ffmvec"   C-word  ffmvec  ( afptr ncolnum dnewveclen astatus -- n )
s" ffdcol"   C-word  ffdcol  ( afptr numcol astatus -- n )
s" ffcpcl"   C-word  ffcpcl  ( ainfptr aoutfptr nincol noutcol \
     ncreate_col astatus -- n )
s" ffpcl"    C-word  ffpcl   ( afptr ndtype ncolnum dfirstrow \
     dfirstelem dnelem aarray astatus -- n )
s" ffpcls"   C-word  ffpcls  ( afptr ncolnum dfirstrow dfirstelem dnelem \
     aparray astatus -- n )
s" ffpcll"   C-word  ffpcll  ( afptr ncolnum dfirstrow dfirstelem dnelem \
     aarray astatus -- n )
s" ffpclb"   C-word  ffpclb  ( afptr ncolnum dfirstrow dfirstelem dnelem \
     aarray astatus -- n )
s" ffpcn"    C-word  ffpcn  ( afptr ndtype ncolnum dfirstrow dfirstelem \
     dnelem aarray anulval astatus -- n )
s" ffpclu"   C-word  ffpclu  ( afptr ncolnum dfirstrow dfirstelem \
     dnelem astatus -- n )
s" ffptbb"   C-word  ffptbb  ( afptr dfirstrow dfirstchar dnchars avalues \
     astatus -- n )
s" ffprwu"   C-word  ffprwu  ( afptr dfirstrow dnrows astatus -- n )
s" ffgcv"    C-word  ffgcv   ( afptr ndtype ncolnum dfirstrow dfirstelem \
     dnelem anulval aarray aanynul astatus -- n )
s" ffgcf"    C-word  ffgcf   ( afptr ndtype ncolnum dfirstrow dfirstelem \
     dnelem aarray anullarray aanynul astatus -- n )
s" ffgtbb"   C-word  ffgtbb  ( afptr dfirstrow dfirstchar dnchars avalues \
     astatus -- n )
s" fftexp"   C-word  fftexp  ( afptr aexpr nmaxdim adatatype anelem anaxis \
     anaxes astatus -- n )
s" fffrow"   C-word  fffrow  ( ainfptr aexpr nfirstrow nrows an_good_rows \
     arow_status astatus -- n )
s" ffffrw"   C-word  ffffrw  ( afptr aexpr arownum astatus -- n )
s" fffrwc"   C-word  fffrwc  ( afptr aexpr atimeCol aparCol avalCol ntimes \
     atimes atime_status astatus -- n )
s" ffsrow"   C-word  ffsrow  ( ainfptr aoutfptr aexpr astatus -- n )
s" ffcrow"   C-word  ffcrow  ( afptr ndatatype aexpr nfirstrow nelements \
     anulval aarray aanynul astatus -- n )
s" ffcalc_rng" C-word  ffcalc_rng  ( ainfptr aexpr aoutfptr aparName \
     aparInfo nRngs astart aend astatus -- n )
s" ffcalc"   C-word  ffcalc  ( ainfptr aexpr aoutfptr aparName aparInfo \
     astatus -- n )

s" fits_calc_binning"  C-word  fits_calc_binning  ( afptr naxis acolname \
     aminin amaxin abinsizein aminname amaxname abinname acolnum ahaxes \
     aamin aamax abinsize astatus -- n )
s" fits_write_keys_histo" C-word  fits_write_keys_histo  ( afptr ahistptr \
     naxis acolnum astatus -- n )
s" fits_rebin_wcs"  C-word  fits_rebin_wcs  ( afptr naxis amin abinsize \
     astatus -- n )
s" fits_make_hist"  C-word  fits_make_hist  ( afptr ahistptr nbitpix naxis \
     anaxes acolnum aamin aamax abinsize sweight nwtcolnum nrecip \
     aselectrow astatus -- n )
s" fits_pixel_filter" C-word  fits_pixel_filter  ( afilter astatus -- n )
s" fits_copy_pixlist2image"  C-word  fits_copy_pixlist2image  ( ainfptr \
     aoutfptr nfirstkey naxis acolnum astatus -- n )

cr .( loaded table routines )

\ Utility Routines
s" ffcsum"   C-word  ffcsum  ( afptr nrec asum astatus -- n )
s" ffesum"   C-word  ffesum  ( usum ncomplm aascii -- )
s" ffdsum"   C-word  ffdsum  ( aascii ncomplm asum -- u )
s" ffpcks"   C-word  ffpcks  ( afptr astatus -- n )
s" ffupck"   C-word  ffupck  ( afptr astatus -- n )
s" ffvcks"   C-word  ffvcks  ( afptr adatastatus ahdustatus astatus -- n )
s" ffgcks"   C-word  ffgcks  ( afptr adatasum ahdusum astatus -- n )
s" ffgsdt"   C-word  ffgsdt  ( aday amonth ayear astatus -- n )
s" ffgstm"   C-word  ffgstm  ( atimestr atimeref astatus -- n )
s" ffdt2s"   C-word  ffdt2s  ( nyear nmonth nday adatestr astatus -- n )
s" fftm2s"   C-word  fftm2s  ( nyear nmonth nday nhour nmin dsecond \
     ndecimals adatestr astatus -- n )
s" ffvers"   C-word  ffvers  ( aversion -- s )
s" ffupch"   C-word  ffupch  ( astring -- )
s" ffpmsg"   C-word  ffpmsg  ( aerrmessage -- )
s" ffpmrk"   C-word  ffpmrk  ( -- )
s" ffcmsg"   C-word  ffcmsg  ( -- )
s" ffcmrk"   C-word  ffcmrk  ( -- )
s" ffcmps"   C-word  ffcmps  ( atemplt acolname ncasesen amatch aexact -- )
s" fftkey"   C-word  fftkey  ( akeyword astatus -- n )
s" fftrec"   C-word  fftrec  ( acard astatus -- n )
s" ffnchk"   C-word  ffnchk  ( afptr astatus -- n )
s" ffkeyn"   C-word  ffkeyn  ( akeyroot nvalue akeyname astatus -- n )
s" ffnkey"   C-word  ffnkey  ( nvalue akeyroot akeyname astatus -- n )
s" ffgkcl"   C-word  ffgkcl  ( acard -- n )
s" ffdtyp"   C-word  ffdtyp  ( acval adtype astatus -- n )
s" ffpsvc"   C-word  ffpsvc  ( acard avalue acomm astatus -- n )
s" ffgknm"   C-word  ffgknm  ( acard aname alength astatus  -- n )
s" ffgthd"   C-word  ffgthd  ( atmplt acard anhdtype astatus -- n )
s" ffbnfm"   C-word  ffbnfm  ( atform adatacode arepeat awidth astatus -- n )
s" ffbnfmll" C-word  ffbnfmll ( atform adatacode arepeat awidth astatus -- n )
s" ffasfm"   C-word  ffasfm  ( atform adatacode awidth adecim astatus -- n )
s" ffgabc"   C-word  ffgabc  ( ntfields aatform nspace arowlen atbcol \
     astatus -- n )
s" fits_translate_keyword"  C-word  fits_translate_keyword  ( ainrec \
     aoutrec apatterns npat n_value n_offset n_range apat_num ai aj am an \
     astatus -- n )
s" fits_translate_keywords" C-word  fits_translate_keywords  ( ainfptr \
     aoutfptr nfirstkey apatterns npat n_value n_offset n_range \
     astatus -- n )
cr .( loaded utility routines )


\ Standard long name versions of the API words
' ffvers  alias  fits_get_version

\ ' ffrwrg   alias fits_parse_range
\ ' ffrwrgll alias fits_parse_rangell


\ File Open/Close Routines
' ffopen  alias  fits_open_file
' ffdopn  alias  fits_open_data
' fftopn  alias  fits_open_table
' ffiopn  alias  fits_open_image
' ffinit  alias  fits_create_file
' fftplt  alias  fits_create_template
' ffclos  alias  fits_close_file
' ffexist alias  fits_file_exists
' ffflsh  alias  fits_flush_buffer
' ffflus  alias  fits_flush_file
' ffdelt  alias  fits_delete_file
' ffcpfl  alias  fits_copy_file
' ffflnm  alias  fits_file_name
' ffflmd  alias  fits_file_mode
' ffurlt  alias  fits_url_type

\ HDU-level Routines
' ffthdu  alias  fits_get_num_hdus
' ffghdn  alias  fits_get_hdu_num
' ffghdt  alias  fits_get_hdu_type
' ffghad  alias  fits_get_hduaddr
' ffghadll alias fits_get_hduaddrll
' ffghof  alias  fits_get_hduoff
' ffmahd  alias  fits_movabs_hdu  
' ffmrhd  alias  fits_movrel_hdu
' ffmnhd  alias  fits_movnam_hdu
' ffcrhd  alias  fits_create_hdu
' ffdhdu  alias  fits_delete_hdu
' ffwrhdu alias  fits_write_hdu
' ffcopy  alias  fits_copy_hdu


\ Image I/O Routines
' ffgidt  alias  fits_get_img_type
' ffgidm  alias  fits_get_img_dim
' ffgisz  alias  fits_get_img_size
' ffgipr  alias  fits_get_img_param
' ffcrim  alias  fits_create_img
' ffcrimll alias fits_create_imgll
' ffiimg  alias  fits_insert_img
' ffiimgll alias fits_insert_imgll
' ffrsim  alias  fits_resize_img
' ffrsimll alias fits_resize_imgll
' ffppx   alias  fits_write_pix
' ffppxn  alias  fits_write_pixnull
' ffgpxv  alias  fits_read_pix
' ffpss   alias  fits_write_subset
' ffgsv   alias  fits_read_subset
' ffgpv   alias  fits_read_img
' ffgpf   alias  fits_read_imgnull
' ffgpvb  alias  fits_read_img_byt
' ffgpvsb alias  fits_read_img_sbyt
' ffppr   alias  fits_write_img
\ ' ffcpimg  alias  fits_copy_image_section

\ Table I/O Routines
' ffcrtb  alias  fits_create_tbl
' ffgnrw  alias  fits_get_num_rows
' ffgncl  alias  fits_get_num_cols
' ffgcno  alias  fits_get_colnum
' ffgcnn  alias  fits_get_colname
' ffgtcl  alias  fits_get_coltype
' ffirow  alias  fits_insert_rows
' ffdrow  alias  fits_delete_rows
' ffdrrg  alias  fits_delete_rowrange
' ffdrws  alias  fits_delete_rowlist
' fficol  alias  fits_insert_col    
' fficls  alias  fits_insert_cols
' ffdcol  alias  fits_delete_col
' ffcpcl  alias  fits_copy_col
' ffpcl   alias  fits_write_col
' ffpcn   alias  fits_write_colnull
' ffpclu  alias  fits_write_col_null
' ffgcv   alias  fits_read_col      
' ffsrow  alias  fits_select_rows
' ffcalc  alias  fits_calculator
' ffgtbb  alias  fits_read_tblbytes
' ffptbb  alias  fits_write_tblbytes

\ Header Keyword I/O Routines
' ffghsp  alias  fits_get_hdrspace
' ffghps  alias  fits_get_hdrpos
' ffmaky  alias  fits_movabs_key
' ffmrky  alias  fits_movrel_key
' ffgnxk  alias  fits_find_nextkey
' ffgrec  alias  fits_read_record
' ffgcrd  alias  fits_read_card
' ffgky   alias  fits_read_key
' ffgunt  alias  fits_read_key_unit
' ffgkey  alias  fits_read_keyword
' ffgkys  alias  fits_read_key_str
' ffgkyl  alias  fits_read_key_log
' ffuky   alias  fits_update_key
' ffprec  alias  fits_write_record
' ffpky   alias  fits_write_key 
' ffpunt  alias  fits_write_key_unit
' ffpcom  alias  fits_write_comment
' ffphis  alias  fits_write_history
' ffpdat  alias  fits_write_date
' ffmrec  alias  fits_modify_record
' ffmcrd  alias  fits_modify_card
' ffmnam  alias  fits_modify_name
' ffmcom  alias  fits_modify_comment
' ffmkyu  alias  fits_modify_key_null
' ffmkys  alias  fits_modify_key_str
' ffirec  alias  fits_insert_record
' ffikey  alias  fits_insert_card
' ffdrec  alias  fits_delete_record
' ffdkey  alias  fits_delete_key
' ffcphd  alias  fits_copy_header
' ffhdr2str  alias  fits_hdr2str

\ Utility Routines
' ffesum  alias  fits_encode_chksum
' ffdsum  alias  fits_decode_chksum 
' ffpcks  alias  fits_write_chksum
' ffvcks  alias  fits_verify_chksum
' ffpsvc  alias  fits_parse_value
' ffdtyp  alias  fits_get_keytype
' ffgkcl  alias  fits_get_keyclass
' ffgthd  alias  fits_parse_template

' ffucrd  alias  fits_update_card  
' ffgerr  alias  fits_get_errstatus
' ffpmsg  alias  fits_write_errmsg
' ffpmrk  alias  fits_write_errmark
' ffgmsg  alias  fits_read_errmsg
' ffcmsg  alias  fits_clear_errmsg
' ffcmrk  alias  fits_clear_errmark
' ffrprt  alias  fits_report_error
' ffcmps  alias  fits_compare_str


variable cfitsio_version        \ use: cfitsio_version sf@ 

cr
cr .( CFITSIO Library Version )  cfitsio_version ffvers  f.

also forth definitions


