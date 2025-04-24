import os
import logging
from flask import Flask, jsonify
import psycopg2

# ログ設定: STDOUTにメッセージのみ出力する
logging.basicConfig(level=logging.INFO, format='%(message)s')
logger = logging.getLogger(__name__)

app = Flask(__name__)

def check_db_connectivity() -> bool:
    """
    PostgreSQLに接続を試み、成功すればTrue、失敗すればFalseを返す。
    接続パラメータは環境変数から取得する。
    """
    try:
        # 環境変数から接続情報を取得（デフォルト値も指定）
        host = os.environ.get('DB_HOST', 'localhost')
        port = os.environ.get('DB_PORT', '5432')
        user = os.environ.get('DB_USER', 'postgres')
        password = os.environ.get('DB_PASSWORD', '')
        dbname = os.environ.get('DB_NAME', 'postgres')

        # PostgreSQLに接続を試みる
        conn = psycopg2.connect(
            host=host,
            port=port,
            user=user,
            password=password,
            dbname=dbname
        )

        conn.close()
        return True
    except Exception as e:
        logger.info(f"DB connection failed: {e}")
        return False

@app.route('/', methods=['GET'])
def healthcheck():
    """
    アプリケーション稼働確認用エンドポイント。
    JSONレスポンス {"status": "ok"} を返す。
    """
    return jsonify({"status": "ok"}), 200

@app.route('/db', methods=['GET'])
def db_endpoint():
    """
    DB疎通確認用エンドポイント。
    check_db_connectivity() の結果に応じて "Success" (200) または "Fail" (500) を返す。
    """
    if check_db_connectivity():
        return "Success", 200
    else:
        return "Fail", 500

@app.route('/error', methods=['GET'])
def error_endpoint():
    """
    エラーログ出力テスト用エンドポイント。
    ロガーにエラーメッセージを出力し、HTTPステータス500を返す。
    """
    logger.info("[Error] Whoops, our code threw a tantrum!")
    return jsonify({"status": "error"}), 500

if __name__ == '__main__':
    # コンテナ内で動作させるため、ホストは0.0.0.0、ポートは80を指定する
    app.run(host='0.0.0.0', port=80)
