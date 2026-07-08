# 26AK02 ビルド設定
# 使用例: make / make clean / make run_q1

CC      ?= icx
CFLAGS  ?= -O2 -std=c11 -Wall -Wextra
LDFLAGS ?= -qmkl
MKL_CFLAGS ?= -I$(MKLROOT)/include

BIN_DIR := bin
SRC_DIR := src

Q1_CG    := $(BIN_DIR)/q1_cg
Q1_EIGEN := $(BIN_DIR)/q1_eigen
Q2_GEMM  := $(BIN_DIR)/q2_gemm

.PHONY: all clean run_q1 run_q2

all: $(Q1_CG) $(Q1_EIGEN) $(Q2_GEMM)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(Q1_CG): $(SRC_DIR)/q1_cg.c | $(BIN_DIR)
	$(CC) $(CFLAGS) -o $@ $< -lm

$(Q1_EIGEN): $(SRC_DIR)/q1_eigen.c | $(BIN_DIR)
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

$(Q2_GEMM): $(SRC_DIR)/q2_gemm.c | $(BIN_DIR)
	$(CC) $(CFLAGS) $(MKL_CFLAGS) -o $@ $< $(LDFLAGS) -lm

run_q1: $(Q1_CG) $(Q1_EIGEN)
	@echo "=== q1_cg ==="
	./$(Q1_CG)
	@echo ""
	@echo "=== q1_eigen ==="
	./$(Q1_EIGEN)

run_q2: $(Q2_GEMM)
	./$(Q2_GEMM) 2000 1

clean:
	rm -rf $(BIN_DIR)
