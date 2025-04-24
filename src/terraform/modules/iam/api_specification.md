# API IAMロールおよびポリシー仕様書

## API タスク実行Policy

- **CloudWatch Logs**: 「`/aws/ecs/${var.environment}-${var.project}-api`」内のログストリームおよびログイベントを作成および管理するための書き込みアクセスを提供。
- **SSMパラメータストア**: 「`/${var.environment}/${var.project}/api`」プレフィックスを持つキーに限定し、APIのパラメータ値の取得を許可。

## ECSタスクロール

APIのECSタスクにアタッチされるロールです。

### アタッチするポリシー
- Nothing

## ECSタスク実行ロール

APIのECSタスクを実行するためのロールです。

### アタッチするポリシー
- AWS マネージドポリシーのAmazonECSTaskExecutionRolePolicy
- API タスク実行Policy

## API Backup 管理ロール

APIバックアップ管理を実行するためのロールです。

### アタッチするポリシー
- マネージドポリシー AWSBackupServiceRolePolicyForBackup
- マネージドポリシー AWSBackupServiceRolePolicyForRestores

## RDS クラスターモニタリングロール

RDS クラスターのインスタンスのEnhanced Monitoring（詳細モニタリング）を有効にするためのロールです。

### アタッチするポリシー
- マネージドポリシー AmazonRDSEnhancedMonitoringRole
