resource "aws_kms_key" "dohp-kms-key" {
  description = "domain key"
}

resource "aws_codeartifact_domain" "dohp-codeartifact-domain" {
  domain         = var.aws_codeartifact_domain_name
  encryption_key = aws_kms_key.dohp-kms-key.arn
}

resource "aws_codeartifact_repository" "dohp-codeartifact-repository" {
  repository = var.aws_codeartifact_repository_name
  domain     = aws_codeartifact_domain.dohp-codeartifact-domain.domain
}
