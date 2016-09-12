fast:
	dub -debug

all: fast
	make -C GraphvizOutput
