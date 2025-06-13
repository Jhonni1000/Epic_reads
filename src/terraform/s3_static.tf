resource "aws_s3_bucket" "epic_reads_static_website" {
    bucket = "epic-reads-static-website"

    tags = {
        Environment = "Dev"
        managed_by = "OPAKI"
    }
}
