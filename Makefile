SRC_DIR=src

LINK_CONFIG=ld.cfg
ROM_BIN=test3.bin

CL65_FLAGS+=--cpu 65C02
CL65_FLAGS+=-t none
CL65_FLAGS+=-C "$(LINK_CONFIG)"

CL65?=$(shell PATH="$(PATH)" which cl65)
ifeq ($(CL65),)
$(error The cl65 tool was not found.)
endif

MINIPRO?=$(shell PATH="$(PATH)" which minipro)
ifeq ($(CL65),)
$(error The minipro tool was not found.)
endif

SOURCES+=$(wildcard $(SRC_DIR)/*.s)
OBJECTS+=$(patsubst %.s,%.o,$(filter %.s,$(SOURCES)))

.PHONY: all download clean

all: $(ROM_BIN)

program: all
	sudo $(MINIPRO) -p at28c256 -w $(ROM_BIN)

clean:
	rm -f $(OBJECTS)

$(ROM_BIN): $(OBJECTS) $(LINK_CONFIG)
	$(CL65) $(CL65_FLAGS) -m $(ROM_BIN).map -o "$@" $(OBJECTS)

$(SRC_DIR)/%.o: $(SRC_DIR)/%.s $(LINK_CONFIG)
	$(CL65) $(CL65_FLAGS) -c -o "$@" "$<"
