fast:
	dub -debug --config=exe --compiler=dmd

all: fast
	make -C GraphvizOutput

test:
	dub test --coverage
