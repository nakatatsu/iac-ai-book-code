# api モジュール仕様書

## 1. リソース

- リソース名: ECS Cluster
  - 要件:
    - 名前: 環境名とプロジェクト名を用いること
    - メトリクス: containerInsightsを有効にすること
  - 禁止事項:
    - 特になし

- リソース名: ECS Service
  - 要件:
    - スケーリング: CPU負荷に応じてスケーリングさせる。
    - 最低タスク数はvar.minimum_task_countで設定する
    - 実行環境: サーバーレス（Fargate）を利用すること
  - 禁止事項:
    - Public Subnetに配置してはならない

- リソース名: ECS Task Definition
  - 要件:
    - 容量: x64系の軽量なタスクを用いること
    - ネットワーク: "awsvpc"モードを採用すること
  - 禁止事項:
    - 特になし

- リソース名: CloudWatch Logsロググループ  
  - 要件:
    - ロググループ: ECS Taskのログを保存するためのロググループを作成すること
    - 保存期間: 365days
    - メトリクスフィルター適用対象: 後述するメトリクスフィルターをこのロググループに対して設定する
  - 禁止事項:
    - 特になし

- リソース名: CloudWatch Logsメトリクスフィルター  
  - 要件:
    - フィルターパターン: "\"[Error]\"" にマッチする条件を指定する

- リソース名: CloudWatchアラーム  
  - 要件:
    - リソース名: ECSServiceAverageCPUUtilization監視に使用
    - 監視対象メトリクス: 上記メトリクスフィルターが送信するカスタムメトリクス
    - 閾値設定: 1分間に1件以上のエラー発生時に通知する
    - アラームアクション: SNSトピックへ通知する

- リソース名: SNSトピック  
  - 要件:
    - アクセスポリシー: CloudWatchアラームからメッセージをパブリッシュできるよう設定する

- リソース名: SNSサブスクリプション  
  - 要件:
    - 通知プロトコル: 通知をEmailで送信する。通知先のメールアドレスはvar.notification_emailで設定する。

- リソース名: ALB (Application Load Balancer)
  - 要件:
    - 名前: 環境名とプロジェクト名を用いること
    - セキュリティ: 必要なルールのみ許可し、HTTPSを強制する
    - サブネット: パブリックサブネットに配置する
  - 禁止事項:
    - CloudFrontを通さない

- リソース名: ALBリスナー
  - 要件:
    - ポート: 443番ポートでリッスンする(HTTPS)
    - リダイレクト: HTTPからHTTPSへのリダイレクトを設定する
    - 証明書: ACMから取得する
    - セキュリティ: HTTPSを強制するためのリダイレクトルールを設定する
  - 禁止事項:
    - 特になし

- リソース名: ALBターゲットグループ
  - 要件:
    - ターゲット: ECSサービスのタスクをターゲットとする
    - ヘルスチェック: ヘルスチェックのエンドポイントは(/)を用いる。
  - 禁止事項:
    - 特になし

- リソース名: Route 53
  - 要件:
    - ドメイン: 指定のドメインを使用し、DNSレコードを設定すること
  - 禁止事項:
    - 特になし

- リソース名: ACM (AWS Certificate Manager)
  - 要件:
    - 証明書: 指定のドメインでTLS証明書を取得すること
  - 禁止事項:
    - 特になし

- リソース名: Route 53
  - 要件:
    - ドメイン: ACMのDNS検証に必要なレコードを追加する
  - 禁止事項:
    - 特になし

- リソース名: ECR (Elastic Container Registry)
  - 要件:
    - コンテナ保存: コンテナイメージを保存するためのリポジトリを用意すること
  - 禁止事項:
    - 特になし

- リソース名: Aurora Serverless v2 (PostgreSQL)
  - 要件:
    - データ永続化: PostgreSQLを利用し、冗長性とバックアップを確保すること
  - 禁止事項:
    - VPC作成は不要

- リソース名: CloudWatch
  - 要件:
    - 監視: リソースのメトリクス収集と特定のアラート設定を行うこと
  - 禁止事項:
    - 特になし

- リソース名: KMS(CMK)
  - 要件:
    - 目的: api関連のサービスで用いることのできるCMKキーを提供する
    - 許可: CloudWatchからの操作を許可する
    - 権限: 管理者およびSNSから利用できるようにする
  - 禁止事項:
    - 特になし

- リソース名: S3 (Simple Storage Service)
  - 要件:
    - バケットポリシー: ALBログを受け入れるためにに必要なバケットポリシーを追加する
  - 禁止事項:
    - 特になし

- リソース名: AWS Backup
  - 要件:
    - バックアップ管理: Aurora Serverless v2のバックアップを管理するためのバックアッププランとバックアップボールトを設定すること
    - スケジュール: 定期的なバックアップスケジュールを設定すること
    - 保管期間: バックアップの保管は毎日30日分を残すほか、毎月の月初に1年残す。
  - 禁止事項:
    - 特になし

- リソース名: SSMパラメータストア
  - 要件:
    - パラメータ保存: DBユーザー名とパスワードを保存する。
  - 禁止事項:
    - 特になし

## 2. variable（Optional）

- **vpc_id**: VPC ID
- **region**: リージョン
- **environment**: 部署やプロジェクトの実行環境情報
- **project**: プロジェクト名
- **public_subnet_ids**: パブリックサブネットのIDリスト
- **private_subnet_ids**: プライベートサブネットのIDリスト
- **domain_name**: 使用するドメイン名
- **minimum_task_count**: 最小タスク数
- **api_role_arn**: ECS Task role for APIのARN
- **api_task_execution_role_arn**: ECS Task Execution roleのARN
- **api_backup_role_arn**: Backup management roleのARN
- **api_alb_security_group_id**: ALBセキュリティグループのID
- **api_security_group_id**: APIセキュリティグループのID
- **api_db_security_group_id**: PostgreSQL DatabaseセキュリティグループのID
- **elb_aws_account_for_s3**: ALBのログを保存できるようにするためのS3バケットポリシー、に利用するElastic Load Balancing AWS アカウントID(ref. https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/enable-access-logging.html)
- **notification_email**: アラートを送る先のメールアドレス
- **rds_monitoring_role_arn**: RDS クラスターのインスタンスの拡張モニタリングを有効にするためのロールのARN
- **db_username**: データベースのユーザー名
- **db_password**: データベースのパスワード
- **default_db_name**: デフォルトのデータベース名

## 3. output（Optional）

- **alb_arn**: ALBのARN

## 4. 備考（Optional）

- WAFは今回オミットします

