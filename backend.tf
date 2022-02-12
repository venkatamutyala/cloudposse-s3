terraform {
  cloud {
    organization = "cloudposse-s3-homework"

    workspaces {
      name = "cloudposse-s3"
    }
  }
}