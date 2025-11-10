# Module Parameters
# Define project variables for usability of other modules

output "bucket_name" {
  value = aws_s3_bucket.private_bucket.bucket
}
