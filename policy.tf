resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 8
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = false
  allow_users_to_change_password = true
}
resource "aws_iam_user_policy" "rocket_employee_policy" {
  count  = length(var.username)
  name   = "std_employee_policy"
  user   = element(var.username, count.index)
  policy = file("policies/user_role.json")
}
resource "aws_iam_user_policy" "terraform_automated_user" {
  name   = "au_tf_user"
  user   = var.au_tf_user
  policy = file("policies/au_tf_role.json")
}

module "iam_readonly_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-read-only-policy"
  version = "~> 4"
  allowed_services = [
    "codeartifact",
    "s3",
    "rds",
    "lambda",
    "ec2"
  ]
  web_console_services = [
    "resource-groups",
    "tag",
    "health",
    "ce"
  ]

  name = "${var.environment}-readonly"
  path = "/"

}

resource "aws_iam_user_policy_attachment" "test-attach" {
  count      = length(var.username)
  user       = element(var.username, count.index)
  policy_arn = module.iam_readonly_policy.arn
}
