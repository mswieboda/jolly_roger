CRYSTAL_COMPILER := crystal
SOURCE_DIR := src
SOURCE_FILE := jr
BUILD_DIR := build
LIB_DIR := lib
SDL3_MIXER_LIB_DIR := /usr/local/lib
LINKFLAGS := -L$(SDL3_MIXER_LIB_DIR) -Wl,-rpath,$(SDL3_MIXER_LIB_DIR)
RM_CMD := rm -rf
MKDIR_CMD := mkdir -p
PACKER_FILE := build/assets.pack
PACKER_BIN := bin/gsdl-packer

# Phony targets don't represent files
.PHONY: default build run install_gsdl_tools packer release clean

# The default target, executed when you just run `make`
default: run

build:
	@echo "Building..."
	$(MKDIR_CMD) $(BUILD_DIR)
	$(CRYSTAL_COMPILER) build $(SOURCE_DIR)/$(SOURCE_FILE).cr -o $(BUILD_DIR)/$(SOURCE_FILE)_debug --link-flags "$(LINKFLAGS)" --error-trace

run: build
	@echo "Running..."
	./$(BUILD_DIR)/$(SOURCE_FILE)_debug

$(PACKER_BIN):
	@echo "Installing GameSDL tools..."
	$(CRYSTAL_COMPILER) lib/game_sdl/install_gsdl_tools.cr

install_gsdl_tools: $(PACKER_BIN)

packer: $(PACKER_BIN)
	@echo "Packing assets via GameSDL packer..."
	./$(PACKER_BIN)

release:
	@echo "Building release..."
	$(MKDIR_CMD) $(BUILD_DIR)
	$(CRYSTAL_COMPILER) build $(SOURCE_DIR)/$(SOURCE_FILE).cr -o $(BUILD_DIR)/$(SOURCE_FILE) --release --link-flags "$(LINKFLAGS)" --no-debug
	@echo "Running release..."
	./$(BUILD_DIR)/$(SOURCE_FILE)

clean:
	@echo "Executing clean..."
	$(RM_CMD) $(BUILD_DIR)
	$(RM_CMD) $(LIB_DIR)
