# シミュレーション特論 第1回レポート課題 (26AK01)

姫野ベンチマーク（OpenMP 並列版）を用いた HPC 演算性能測定プロジェクトです。

## 課題概要

| 課題 | 内容 |
|------|------|
| 【1】 | グリッド S/M/L、スレッド数 1 で MFLOPS 測定 |
| 【2】 | グリッド S、`-O0`〜`-O3` で比較 |
| 【3】 | グリッド S、スレッド数 1/2/4/8 で比較 |
| 発展 | MPI 版、プロセス数 1/2/4/8（任意） |

グリッドサイズ（[姫野ベンチ公式](https://i.riken.jp/supercom/documents/himenobmt/)）:

| サイズ | 配列サイズ (i×j×k) |
|--------|-------------------|
| S | 128 × 64 × 64 |
| M | 256 × 128 × 128 |
| L | 512 × 256 × 256 |

## プロジェクト構成

```
26AK01/
├── README.md
├── Makefile
├── scripts/
│   ├── download_sources.sh   # RIKEN からソース取得
│   ├── compile.sh            # OpenMP 版コンパイル
│   ├── run_benchmark.sh      # 1 回実行
│   ├── run_all_tasks.sh      # 課題 1〜3 一括実行
│   └── parse_output.sh       # ログから結果抽出
├── jobs/                     # PBS ジョブスクリプト
├── mpi/                      # 発展課題 (MPI)
└── results/
    ├── raw/                  # 実行ログ
    └── report_templates.md   # レポート用表テンプレート
```

## 使い方（HPC クラスタ）

### 1. プロジェクトを HPC にコピー

```powershell
# Windows から（プロジェクト作成後）
scp -r C:\src\advanced_simulation_26AK01 hpc:~/advanced_simulation_26AK01
```

```bash
# HPC 窓口サーバ (ydev) にログイン後
ssh hpc
cd ~/advanced_simulation_26AK01/26AK01
```

### 2. ソースコード取得

[姫野ベンチ OpenMP 版 (C + OMP, dynamic allocate)](https://i.riken.jp/supercom/documents/himenobmt/download/mpi-vpp/) を取得します。

```bash
bash scripts/download_sources.sh
```

### 3. コンパイル

```bash
module load intel/2025
bash scripts/compile.sh          # デフォルト -O2
OPT_LEVEL=-O3 bash scripts/compile.sh
```

コンパイルコマンド例（レポート記載用）:

```bash
icx -fopenmp -O2 -o bin/himeno_omp src/himenoBMTxpa.c
```

### 4. ジョブ投入（計算ノードで測定）

**窓口サーバではなく計算ノードで測定すること**（課題の指示）。

```bash
# 課題 1〜3 を一括
qsub jobs/run_all.pbs

# 個別に投入する場合
qsub jobs/task1_grid_size.pbs
qsub jobs/task2_optimization.pbs
qsub jobs/task3_threads.pbs
```

ジョブ状態確認:

```bash
qstat
# 完了後
bash scripts/parse_output.sh results/raw/*.log
```

### 5. インタラクティブで試す場合

```bash
qsub -IX -q Eduq -l select=1:ncpus=8:mem=16gb /bin/bash
cd $PBS_O_WORKDIR   # 必要に応じて
bash scripts/run_benchmark.sh S results/raw/test.log
```

## 手動実行例

```bash
export OMP_NUM_THREADS=1
./bin/himeno_omp S    # グリッド S
./bin/himeno_omp M
./bin/himeno_omp L
```

出力から以下をレポートに転記:

- `cpu : X sec.` → CPU time (sec.)
- `Loop executed for N times` → Loop executed
- `MFLOPS measured : Y` → MFLOPS

## レポートに記載する情報

- 計算ノード名（`hostname` の出力）
- CPU 型番（`lscpu`）
- メモリ量（`free -h`）
- コンパイルコマンド
- 各課題の測定表

テンプレート: `results/report_templates.md`

## 発展課題（MPI・任意）

```bash
qsub jobs/mpi_extension.pbs
# または
bash mpi/run_mpi_tasks.sh
```

MPI 版のビルド手順（課題 PDF より）:

1. `cc_himenoBMTxp_mpi.lzh` を展開
2. `Makefile.sample` を `Makefile` にコピーし、`mpicc` → `mpicc -cc=icx` に変更
3. `module load intelmpi/2025`
4. `./paramset.sh S 2 2 2`（例: 8 プロセス）
5. `make` → `mpirun -np 8 ./a.out`

## 参考リンク

- [姫野ベンチマーク](https://i.riken.jp/supercom/documents/himenobmt/)
- [TUT HPC コンパイル方法](https://hpcportal.imc.tut.ac.jp/wiki/HowToCompile)
- [TUT HPC ジョブ投入](https://hpcportal.imc.tut.ac.jp/wiki/HowToSubmitJob)
- [TUT HPC クラスタ仕様](https://hpcportal.imc.tut.ac.jp/wiki/ClusterSystemSpec)
