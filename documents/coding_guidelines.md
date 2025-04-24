# Terraform コーディングガイドライン

## 1. 共通

### 1.1 命名規則

- 略語の使用を避け、正式名称を使用します。(e.g., `[NG] cg [OK] coding guidelines `)
- ただし`RDS`や`id`のように固有名詞として用いられている略語は利用できます。

### 1.2 冪等性の確保

- Terraformコードは冪等性を持たせて記述します。
- [NG] すなわち同一のコードを再実行したにも関わらずエラーやリソース変更が起きてはいけません。

### 1.3 整形

- `terraform fmt`を使用してコードを自動整形します。

### 1.4 バージョンの固定

- Terraformおよびプロバイダーのバージョンは完全に固定します。(e.g., `required_version = "= 1.9.6"`)
- [NG] `>=`や`~>`のような幅のあるバージョン指定をしてはいけません。

### 1.5 モジュールの利用

- resourceブロックは全てモジュールに記載します。

### 1.6 コメントの記載
- 必要に応じてコードにコメントを追加します。
- [NG] 誤ったコメントや必要なくなったコメントを放置してはいけません。(e.g., `# 下記コメントは2020年4月1日を過ぎると必要なくなります。（以下略）`)
- [NG] コードの記載と意味が変わらないコメントを記載してはいけません。（e.g., `resource "aws_instance" "api"  # API用のEC2インスタンス`）


## 2. ディレクトリとファイル構成

### 命名規則

- ディレクトリ名およびファイル名は全てスネークケースを使用します。(e.g., `awesome_module/awesome_specifications.md`)

### 2.1 モジュールディレクトリ

- モジュールは`modules/`ディレクトリ以下にそれぞれサブディレクトリを作って保存します。(e.g., `modules/api/`)
- モジュールテスト用のディレクトリは、各モジュールの直下にtests/の名前で作成します。(e.g., `modules/api/tests/`)
- 各モジュールは以下のファイルを必ず含めます。記載すべきことがなければ空ファイルで保存します。
  - `main.tf`: `resource`ブロックと`data`ブロックを記述します。
  - `variables.tf`: `variable`ブロックを記述します。
  - `outputs.tf`: `output`ブロックを記述します。
- [NG] モジュールディレクトリ内でterraformブロックやprovidersブロックを使ってはいけません。

### 2.2 環境ごとのディレクトリ

- 各環境を表現するディレクトリはterraform用ディレクトリの直下に保存します（e.g., `development/`、`staging/`、`production/`）。
- 各環境のディレクトリには以下のファイルを含めます。
  - `providers.tf`: terraformブロックとprovidersブロックを記載します。
  - `main.tf`: moduleブロックとdataブロックを記載します。
  - `variables.tf`: `variable`ブロックを記述します。
  - `terraform.tfvars.json`: 機密情報を含む各種の値を保存します。機密情報は暗号化する必要があります。暗号化する方法は別紙を参照ください。[NG] gitリポジトリにこのファイルを保存してはいけません。
  - `terraform.tfvars.json.enc`: `terraform.tfvars.json`を暗号化したファイルです。

## 2. 記述ルール

### 2.1 命名規則

#### 2.1.1 Terraform

- Terraformのコード内の変数や各ブロックの名前にはすべてスネークケースを使用します。(e.g., `web_server`)
- リソース名にはその用途または特性を説明する名前を使用します。(e.g., `bastion`, `main`)
- [NG] リソースタイプと意味が重複する命名をしてはいけません。(e.g., `resource "aws_instance" "ec2_instance"`)
- [NG] 各resouceブロックのTagでデフォルトタグの名前（`Environment`と`Project`）を使ってはいけません。

#### 2.1.2 AWS

- AWS内の名称はケバブケースを使います。(e.g., `production-practitioner-api`)
- リソース名あるいはそれに該当するものは`[環境名]-[プロジェクト名]([-追加情報(あれば)])`のように命名します。(e.g., `production-practitioner`, `production-practitioner-api`)
- [NG] リソースタイプに含まれる情報を名前に付与してはいけません。(e.g., `production-practitioner-policy`, `production-practitioner-role`, `production-practitioner-alb`)

### 2.2 variableとoutput

- 機密情報を格納するvariableには必ず`sensitive = true`を設定します。
- [NG] Variableにデフォルト値を入れてはいけません。
- variableのtypeの利用は任意です。
- variableやoutputには極力をdescriptionを追加します。

### 2.3 ハードコーディングの回避

- AMI IDやインスタンスタイプ、VPC IDなど、同じモジュールでもケースバイケースで変わる値は極力dataブロックやvariableブロックを使用して表現します。

### 2.4 暗号化の利用

- S3, EBS, RDSなど、ストレージを利用する際は必ず暗号化します。鍵はKMSに限らずAWS提供のものも利用できます。

## 3. 運用ルール

### 3.1 `.tfstate`拡張子を持つファイルの管理

- [NG] `.tfstate`拡張子を持つファイル(以後`*.tfstate`と記載)をGitにコミットしてはいけません。
- 原則として`.tfstate`はS3バケットに保存します。
- 実験的な個人専用環境のみ`.tfstate`をローカルに保存できます。

### 3.2 機密情報の扱い

- [NG] どのような形式であれ、Gitに保存されるファイルに機密情報を平文で記載してはいけません。
- Gitに機密情報を保存する場合は必ず暗号化します。

