PROJECT = project
TB ?= uart_rx_tb
TOP ?= top

BUILD_DIR = build
SIM_DIR = sim_build
SIM_FILES_DIR = testbench
CONSTRAINTS = \
	constraints/pins.cst

FAMILY = GW1N-9C
DEVICE = GW1NR-LV9QN88PC6/I5

SRCS = \
	src/uart/uart_rx.v \
	src/uart/uart_tx.v \
	src/top/top_uart_echo.v \
	src/fifo/sync_fifo.v \
	src/packaging/packaging.v \
	

YOSYS = yosys
NEXTPNR = nextpnr-gowin
GOWIN_PACK = gowin_pack
IVERILOG = iverilog
VVP = vvp
LOADER = openFPGALoader
FORMAT = verible-verilog-format

.PHONY: all syn pnr pack sim flash clean lint wave

all: pack

syn: $(BUILD_DIR)/$(PROJECT).json
$(BUILD_DIR)/$(PROJECT).json: $(SRCS)
	mkdir -p $(BUILD_DIR)
	$(YOSYS) -p "read_verilog $(SRCS); synth_gowin -top $(TOP) -json $@"


pnr: $(BUILD_DIR)/$(PROJECT).pnr
$(BUILD_DIR)/$(PROJECT).pnr: $(BUILD_DIR)/$(PROJECT).json
	$(NEXTPNR) --json $< --write $@ --device $(DEVICE) --family $(FAMILY) --cst $(CONSTRAINTS)


pack: $(BUILD_DIR)/$(PROJECT).fs
$(BUILD_DIR)/$(PROJECT).fs: $(BUILD_DIR)/$(PROJECT).pnr
	$(GOWIN_PACK) -d $(FAMILY) -o $@ $<


sim:
	mkdir -p $(SIM_DIR)
	$(IVERILOG) -o $(SIM_DIR)/$(TB).vvp -s $(TB) $(SRCS) $(SIM_FILES_DIR)/$(TB).v
	cd $(SIM_DIR) && vvp $(TB).vvp

flash: $(BUILD_DIR)/$(PROJECT).fs
	$(LOADER) -b tangnano9k $<

clean:
	rm -rf $(BUILD_DIR) $(SIM_DIR)

lint:
	$(IVERILOG) -Wall -tnull $(SRCS)

wave:
	gtkwave $(SIM_DIR)/$(TB).vcd 2>NUL