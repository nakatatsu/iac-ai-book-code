# 作業スクリプト起動用Makefile

SCRIPTS_DIR = ./scripts
.DEFAULT_GOAL := menu

# メニューを出す
menu:
	@bash $(SCRIPTS_DIR)/menu.sh

# gitにcommitする
commit:
	@git add . && git commit -m "update" || true

# スケルトン付きのモジュールディレクトリを用意する
prepare:
	@bash $(SCRIPTS_DIR)/prepare/module.sh $(identifier)

# スケルトン付きの環境用ディレクトリを用意する
prepare_environment:
	@bash $(SCRIPTS_DIR)/prepare/environment.sh $(environment)

# 概要説明書(readme.md)を生成する
requirements:
	@bash $(SCRIPTS_DIR)/requirements/generate.sh $(identifier)

# 概要説明書をもとにモジュール仕様書を生成する
specification:
	@bash $(SCRIPTS_DIR)/specification/generate.sh $(identifier) $(type)

# コードを生成する
code:
	@bash $(SCRIPTS_DIR)/code/generate.sh $(identifier) $(type)

# 環境用コードを生成する。modulesはカンマ区切りでモジュール名を指定
code_environment:
	@bash $(SCRIPTS_DIR)/code/environment.sh $(environment) $(modules)

# 仕様書とコードを突合する
cross_checking:
	@bash $(SCRIPTS_DIR)/tests/cross_checking.sh $(identifier) $(type)

# モジュールのコードのチェックと修正
test:
	@bash $(SCRIPTS_DIR)/tests/test.sh $(identifier)

# モジュールのテストのためterraform planを実行する
test_plan:
	@bash $(SCRIPTS_DIR)/tests/test_plan.sh $(identifier)

# モジュールのテストのためterraform applyを実行する
test_apply:
	@bash $(SCRIPTS_DIR)/tests/test_apply.sh $(identifier)

# モジュール作成の過程で作られる一時ファイルを削除する
clean_up:
	@bash $(SCRIPTS_DIR)/tests/clean_up.sh $(identifier)

# モジュールのテストのために作成したAWS上のリソースを削除する
test_destroy:
	@bash $(SCRIPTS_DIR)/tests/test_destroy.sh $(identifier)

# 逆エンジニアリングによる仕様推測
reverse_engineering:
	@bash $(SCRIPTS_DIR)/reverse_engineering/generate.sh $(identifier) $(type)
