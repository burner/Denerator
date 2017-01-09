fast:
	dub -debug

all: fast
	make -C GraphvizOutput

test:
	dub test --coverage
