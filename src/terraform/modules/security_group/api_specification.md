# api セキュリティグループ仕様書

- **ALB**
  - **説明**: To allow the ALB to accept inbound HTTPS requests from the Internet.
  - **インバウンドルール**:
    - HTTPS (Port 443): Allow from 0.0.0.0/0
    - HTTP (Port 80): Allow from 0.0.0.0/0
  - **アウトバウンドルール**:
    - HTTP (Port 80): Allow to API security group

- **API**
  - **説明**: To allow the API container to interact securely within the AWS environment and to allow inbound traffic from the ALB.
  - **インバウンドルール**:
    - HTTP (Port 80): Allow from ALB security group
  - **アウトバウンドルール**:
    - HTTPS (Port 443): Allow to external services
    - PostgreSQL (Port 5432): Allow to Aurora DB security group

- **Aurora DB**
  - **説明**: To allow secure connections from the API containers for database operations.
  - **インバウンドルール**:
    - PostgreSQL (Port 5432): Allow from API security group
  - **アウトバウンドルール**:
    - Nothing
