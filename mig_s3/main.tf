resource "aws_s3_bucket" "state_file_bucket" {
    bucket = "sfbucket220"

    tags={
        Name="sfbucket220"
        Environment="Lab"
    }
    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_s3_bucket_versioning" "version_my_bucket" {
  bucket = aws_s3_bucket.state_file_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_lock_tbl" {
  name           = "terraform-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags           = {
    Name = "terraform-lock"
  }
}

resource "aws_kms_key" "migkey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 7
}

resource "aws_s3_bucket" "sfbucket220" {
  bucket = "sfbucket220"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_sse" {
  bucket = aws_s3_bucket.sfbucket220.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.migkey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

