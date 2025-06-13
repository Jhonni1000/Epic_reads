resource "aws_s3_bucket" "epic_reads_static_website" {
    bucket = "epic-reads-static-website"

    tags = {
        Environment = "Dev"
        managed_by = "OPAKI"
    }
}

resource "aws_s3_bucket_website_configuration" "epic_reads_static_website" {
    bucket = aws_s3_bucket.epic_reads_static_website.id

    index_document {
        suffix = "index.html"
    }

    error_document {
        key = "error.html"
    }
}

resource "aws_s3_bucket_public_access_block" "epic_reads_static_website" {
    bucket = aws_s3_bucket.epic_reads_static_website.id

    block_public_acls =  false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "epic_reads_static_website" {
    bucket = aws_s3_bucket.epic_reads_static_website.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "s3:GetObject"
                Effect = "Allow"
                Principal = "*"
                Resource = "${aws_s3_bucket.epic_reads_static_website.arn}/*"
            }
        ]
    })
    depends_on = [ aws_s3_bucket_public_access_block.epic_reads_static_website ]
}

output "website_url" {
    value = aws_s3_bucket_website_configuration.epic_reads_static_website.website_endpoint
}