# 姫野ベンチ OpenMP 版（C + OMP, dynamic allocate）
# HPC 上で scripts/download_sources.sh 実行後に使用

SRC_DIR   ?= src
BUILD_DIR ?= build
BIN_DIR   ?= bin

# 展開後のソースファイル名（RIKEN 配布物）
SRC       ?= $(SRC_DIR)/himenoBMTxpa.c
TARGET    ?= $(BIN_DIR)/himeno_omp

CC        ?= icx
CFLAGS    ?= -fopenmp
LDFLAGS   ?= -fopenmp

.PHONY: all clean dirs

all: dirs $(TARGET)

dirs:
	@mkdir -p $(BUILD_DIR) $(BIN_DIR)

$(TARGET): $(SRC) | dirs
	$(CC) $(CFLAGS) $(OPT) -o $@ $< $(LDFLAGS)

clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)
