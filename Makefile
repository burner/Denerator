fast:
	dub -debug --config=exe

all: fast
	make -C GraphvizOutput

test:
	dub test --coverage
