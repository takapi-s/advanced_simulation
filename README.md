# シミュレーション特論 レポート課題

シミュレーション特論のレポート課題をまとめたリポジトリです。

## プロジェクト構成

```
advanced_simulation_26AK01/
├── README.md          # 本ファイル
├── 26AK01/            # 第1回レポート課題（姫野ベンチマーク）
└── 26AK02/            # 第2回レポート課題
```

## 各課題

| フォルダ | 内容 |
|----------|------|
| [26AK01/](26AK01/) | 姫野ベンチマーク（OpenMP 並列版）による HPC 演算性能測定 |
| [26AK02/](26AK02/) | 第2回レポート課題 |

## 使い方

各課題フォルダ内の `README.md` を参照してください。

```bash
# 第1回課題
cd 26AK01
bash scripts/download_sources.sh
bash scripts/compile.sh
qsub jobs/run_all.pbs

# 第2回課題
cd 26AK02
```
