# セットアップ

## インストール

### Terraform（Ubuntu 22）

Terraformをインストールするための手順です。
```
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform
```

```
sudo apt-get remove terraform
wget https://releases.hashicorp.com/terraform/1.10.3/terraform_1.10.3_linux_amd64.zip
sudo apt-get install unzip -y
unzip terraform_1.10.3_linux_amd64.zip
sudo mv terraform /usr/bin/
```

#### Terraformプラグインキャッシュの設定（オプション）

1. ターミナルで以下のコマンドを実行し、`.bashrc`ファイルを編集します。  

   ```bash
   vi ~/.bashrc
   ```
2. ファイルの末尾に以下の行を追加します：  
   ```bash
   export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
   ```
3. 変更を適用します。

   ```bash
   source ~/.bashrc
   ```
   
### Python（3.12）

Python 3.12をインストールするための手順です。

```
sudo apt update
sudo apt upgrade -y
sudo apt install -y python3-pip
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install -y python3.12
```

### sops

`sops`をインストールする方法です。これは機密情報をGitに保存するために暗号化・復号する目的で用います。

```
curl -LO https://github.com/getsops/sops/releases/download/v3.9.0/sops-v3.9.0.linux.amd64
sudo mv sops-v3.9.0.linux.amd64 /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops
```

まだキーがない場合は下記で作成します

```
aws kms create-key --description "Key for SOPS encryption"
aws kms create-alias --alias-name "alias/sops-key" --target-key-id <KEY_ID>
```


---

### Pythonパッケージ

必要なPythonパッケージをインストールします。

```

sudo apt install -y python3.12-venv
python3 -m venv .venv
source .venv/bin/activate


pip install openai
pip install Jinja2

deactivate
```

---

## tflint

TerraformのLinterです

```
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
cd src/terraform/tests
tflint --init
```

## checkov

`checkov`はインフラコードのセキュリティとベストプラクティスをチェックするツールです。しかし新しいOpenAIとコンフリクトしたため隔離します。

```
python3 -m venv .venv_checkov
source .venv_checkov/bin/activate
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
pip install --upgrade pip
pip install checkov Jinja2
```

---

## スクリプトディレクトリへのPATH設定

scripts/にPATHを設定します。

例：
```
export PATH=$PATH:/home/main/githubRD/sample-iac/scripts
```

## 環境変数の設定

以下の環境変数を設定します。

```
export IAC_ROOT="/home/main/githubRD/sample-iac" # (自分の保存した場所に合わせる)
export OPENAI_API_KEY="sk-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
export SOPS_KMS_ARN="arn:aws:kms:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```

```
source ~/.bashrc
```

## WindowsでCursorを使用してWSL2に接続

1. `Remote Development (ms-vscode-remote)`拡張機能をインストールします。  
2. Cursorで`Ctrl+P`を押してコマンドパレットを開きます。  
3. `Connect to WSL using Distro`を選択し、使用するディストリビューション（例：`Ubuntu`）を選びます。  


