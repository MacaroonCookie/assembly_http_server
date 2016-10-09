SRCDIR=${PWD}/src
OUTDIR=${PWD}/build

CC=gcc
CCFLAGS=-g
CCLIBS=

all: ${OUTDIR}/server.o
	${CC} -o ${OUTDIR}/server ${OUTDIR}/server.o ${CCLIBS}

${OUTDIR}/server.o: ${SRCDIR}/server.s ${OUTDIR}
	${CC} -o ${OUTDIR}/server.o -c ${SRCDIR}/server.S

${OUTDIR}:
	mkdir ${OUTDIR}

debug:
	gdb ${OUTDIR}/server

run:
	${OUTDIR}/server

clean:
	rm -rf ${OUTDIR}
