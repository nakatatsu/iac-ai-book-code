# スタブAPI コンテナ

## 目的

- インフラの疎通確認を行うため、簡易なREST APIを提供するコンテナを作成する

## 期待すること

- Pythonを用いること
- 下記のエンドポイントを持つこと
    - ヘルスチェック用(/)
    - DB疎通確認用(/db)
    - エラー出力用(/error)

## 禁止事項
- 特になし

## Local起動

```
docker build -t api .
docker run -p 80:80 api
```
