# Terraform ディレクトリ構成

このディレクトリには、OCI Quest（MuShop アプリケーション）を OCI 上にデプロイするための Terraform コードが含まれています。

## ディレクトリ構成と役割

```
terraform/
├── README.md           # このファイル
├── admin/             # 管理者向けマルチ環境構築設定
├── modules/           # 再利用可能なTerraformモジュール
└── quest/             # 単一環境（基本）構築設定
```

### 各ディレクトリの詳細

#### `admin/`

- **目的**: 複数チームのベース環境を構築
- **特徴**:
  - 複数のコンパートメントを自動作成
  - チームごとに VCN、ATP、コンピュートインスタンスを配布
  - `member_sample.json`でチーム情報を管理
- **主要ファイル**:
  - `main.tf`: メインの構成定義
  - `locals.tf`: ローカル変数
  - `providers.tf`: プロバイダー設定
  - `variables.tf`: 入力変数
  - `schema.yaml`: Resource Manager 用スキーマ

#### `modules/`

- **目的**: 再利用可能な Terraform モジュールのライブラリ
- **サブディレクトリ**:
  - `atp/`: Autonomous Database（ATP/ADW）リソース
  - `identity/`: コンパートメント、ユーザー、グループ管理
  - `init-compute/`: コンピュートインスタンス初期設定
  - `log_analytics/`: ログ分析設定
  - `object_storage/`: Object Storage バケット設定
  - `vcn/`: 仮想クラウドネットワーク（サブネット、ゲートウェイ等）

#### `quest/`

- **目的**: MuShop アプリケーション構築
- **特徴**:
  - Always Free ティアリソースを使用
  - 3 層 Web アプリケーション構成
  - コンピュート、データベース、ロードバランサーを含む完全な環境
- **主要コンポーネント**:
  - `compute.tf`: コンピュートインスタンス設定
  - `loadbalancer.tf`: ロードバランサー設定
  - `providers.tf`: OCI プロバイダー設定
  - `variables.tf`: 構築設定変数
  - `scripts/`: アプリケーション初期化スクリプト

# Quick Start

1. `admin/member_sample.json`を参考に参加者情報を入力しておく
1. `admin`ディレクトリを OCI Resource Manager にスタックとしてアップロードし、メンバー情報ファイル含む必要な情報を入力する
1. 上記のスタックを apply する
   1. この段階で各ユーザーや各チームごとにコンパートメントが作成される
1. 作成された各コンパートメントごとに、OCI Resource Manager のスタックを作成し、`quest`ディレクトリをアップロードする
1. 上記のスタックを apply する

# 注意事項

- 各ユーザーが行なった変更は Terraform 側が認知できないので、各ユーザーが行なった変更は取り消すか、対象リソースを削除してからでないと`destroy`することはできない
- Terraform で環境を構築することはできるが、上記以外にも削除には特別な手順を踏む必要がある（確認後追記）
