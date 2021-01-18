SOURCES = alu.v

.PHONY: test
test: $(SOURCES)
	iverilog alu_tb.v
	./a.out
