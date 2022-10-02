#
# Makefile for kForth-32
#
# Copyright (c) 1998--2022 Krishna Myneni, 
#   <krishna.myneni@ccreweb.org>
#
# This software is provided under the terms of the GNU 
# Affero General Public License (AGPL), v3.0 or later.
#
# Possible invocations:
#
#	make		creates dynamically linked release executable
#	make clean	remove all object files belonging to this project
#	make debug	create statically linked debug executable
#	make archive	create a compressed tar file (for release)
#       make snapshot   create a development snapshot
#
# Notes:
#
#   1. If a debug version is being built, always invoke "make clean" 
#      before "make debug".
#
#
# Default debug option creates a release version of the executable.
# Invoke "make debug" if you want to create an executable
# that contains debugging information for the GNU debugger (gdb).

VERSION = 2.4.1
DEF_DIR_VAR=KFORTH_DIR
BUILD_DATE=`date +%F`
DEBUG = 
TARGET_CPU = x86
TARGET_OS  = linux

# location of gcc and g++
GCCDIR = /usr/bin

# library path
LIBPATH = /usr/lib:/usr/lib32

CPP = ${GCCDIR}/g++
CC  = ${GCCDIR}/gcc
CPPFLAGS = -c -m32 -Wall 
CFLAGS = -c -m32 -Wall
FAST = -D__FAST__
NOFPSTACK = -D__NO_FPSTACK__
OBJS = kforth.o ForthVM.o ForthCompiler.o vm32.o vmc.o
FOBJS = kforth-fast.o ForthVM-fast.o ForthCompiler-fast.o vm32-fast.o vmc-fast.o
# LIBS = -lreadline -lncurses -ldl -lm
LIBS = -lreadline -ldl -lm

all:	
	make kforth32
	make kforth32-fast


kforth32: ${OBJS} 
	${CPP} -m32 -o kforth32 ${DEBUG} ${OBJS} -L${LIBPATH} ${LIBS}

kforth32-fast: ${FOBJS}
	${CPP} -m32 -o kforth32-fast ${DEBUG} ${FOBJS} -L${LIBPATH} ${LIBS}

clean:
	- rm -f ${OBJS} ${FOBJS} kforth32 kforth32-fast


debug:
	make kforth32 "DEBUG = -g"

kforth.o: kforth.cpp ForthVM.h ForthCompiler.h VMerrors.h
	${CPP} ${CPPFLAGS} ${DEBUG} -DVERSION=\"${VERSION}\" \
	-DBUILD_DATE=\"${BUILD_DATE}\" kforth.cpp

kforth-fast.o: kforth.cpp ForthVM.h ForthCompiler.h VMerrors.h
	${CPP} ${CPPFLAGS} ${DEBUG} -DVERSION=\"${VERSION}\" \
	-DBUILD_DATE=\"${BUILD_DATE}\" ${FAST} -o kforth-fast.o kforth.cpp

ForthCompiler.o: ForthCompiler.cpp ForthCompiler.h fbc.h ForthWords.h \
	VMerrors.h kfmacros.h
	${CPP} ${CPPFLAGS} ${DEBUG} ${NOFPSTACK} ForthCompiler.cpp

ForthCompiler-fast.o: ForthCompiler.cpp ForthCompiler.h fbc.h ForthWords.h \
	VMerrors.h kfmacros.h
	${CPP} ${CPPFLAGS} ${DEBUG} ${FAST} ${NOFPSTACK} -o ForthCompiler-fast.o \
	ForthCompiler.cpp

ForthVM.o: ForthVM.cpp ForthVM.h fbc.h ForthCompiler.h VMerrors.h kfmacros.h
	${CPP} ${CPPFLAGS} -DDIR_ENV_VAR=\"${DEF_DIR_VAR}\" \
        ${DEBUG} ${NOFPSTACK} ForthVM.cpp

ForthVM-fast.o: ForthVM.cpp ForthVM.h fbc.h ForthCompiler.h VMerrors.h kfmacros.h
	${CPP} ${CPPFLAGS} -DDIR_ENV_VAR=\"${DEF_DIR_VAR}\" \
        ${DEBUG} ${NOFPSTACK} ${FAST} -o ForthVM-fast.o ForthVM.cpp

vmc.o: vmc.c kfmacros.h
	${CC} ${CFLAGS} ${DEBUG} ${NOFPSTACK} vmc.c

vmc-fast.o: vmc.c kfmacros.h
	${CC} ${CFLAGS} ${DEBUG} ${NOFPSTACK} ${FAST} -o vmc-fast.o vmc.c

vm32.o: vm32.s vm32-common.s
	as --32 -o vm32.o vm32.s

vm32-fast.o: vm32-fast.s vm32-common.s
	as --32 -o vm32-fast.o vm32-fast.s



# end of makefile

