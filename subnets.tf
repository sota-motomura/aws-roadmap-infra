# パブリックサブネット
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block               = "10.0.0.0/24"
  availability_zone        = "ap-northeast-1a"
  map_public_ip_on_launch  = true
  tags = { Name = "public-1a" }
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block               = "10.0.1.0/24"
  availability_zone        = "ap-northeast-1c"
  map_public_ip_on_launch  = true
  tags = { Name = "public-1c" }
}

# アプリ層サブネット(プライベート)
resource "aws_subnet" "app_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-northeast-1a"
  tags = { Name = "app-1a" }
}

resource "aws_subnet" "app_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-northeast-1c"
  tags = { Name = "app-1c" }
}

# データ層サブネット(プライベート、最も閉じた層)
resource "aws_subnet" "data_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "ap-northeast-1a"
  tags = { Name = "data-1a" }
}

resource "aws_subnet" "data_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "ap-northeast-1c"
  tags = { Name = "data-1c" }
}

# NATゲートウェイ(コスト削減のため1aのみ)
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "phase1-nat-eip" }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1a.id
  tags          = { Name = "phase1-nat" }
}

# ルートテーブル:パブリック
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = { Name = "app-rt" }
}

resource "aws_route_table" "data" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "data-rt" }
}


resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "app_1a" {
  subnet_id      = aws_subnet.app_1a.id
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table_association" "app_1c" {
  subnet_id      = aws_subnet.app_1c.id
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table_association" "data_1a" {
  subnet_id      = aws_subnet.data_1a.id
  route_table_id = aws_route_table.data.id
}

resource "aws_route_table_association" "data_1c" {
  subnet_id      = aws_subnet.data_1c.id
  route_table_id = aws_route_table.data.id
}