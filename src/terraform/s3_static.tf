resource "aws_s3_bucket" "epic_reads_static_website" {
    bucket = "epic_reads_static_website"

    tags = {
        Environment = "Dev"
        managed_by = "OPAKI"
    }
}
