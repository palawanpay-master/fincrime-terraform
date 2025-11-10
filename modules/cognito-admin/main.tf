## Make sure User Service is deployed when using this
data "aws_lambda_function" "cognito_custom_message" {
  function_name = "${var.common.project_name}-user-service-${var.common.environment}-CognitoCustomMessage"
}

data "aws_lambda_function" "post_authentication" {
  function_name = "${var.common.project_name}-user-service-${var.common.environment}-CognitoPostAuthentication"
}

data "aws_lambda_function" "pre_token" {
  function_name = "${var.common.project_name}-user-service-${var.common.environment}-CognitoPreToken"
}
data "aws_lambda_function" "pre_signup" {
  function_name = "${var.common.project_name}-user-service-${var.common.environment}-CognitoPreSignup"
}


resource "aws_lambda_permission" "allow_cognito_custom_message" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.cognito_custom_message.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.admin.arn
}

resource "aws_lambda_permission" "allow_cognito_post_auth" {
  statement_id  = "AllowCognitoPostAuth"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.post_authentication.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.admin.arn
}

resource "aws_lambda_permission" "allow_cognito_pre_token" {
  statement_id  = "AllowCognitoPreToken"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.pre_token.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.admin.arn
}
resource "aws_lambda_permission" "allow_cognito_pre_signup" {
  statement_id  = "AllowCognitoPreSignup"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.pre_signup.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.admin.arn
}

# Admin User Pool
resource "aws_cognito_user_pool" "admin" {
  name = "${var.common.project_name}-${var.common.environment}-admin-user-pool"
  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  lambda_config {
    custom_message       = data.aws_lambda_function.cognito_custom_message.arn
    post_authentication  = data.aws_lambda_function.post_authentication.arn
    pre_token_generation = data.aws_lambda_function.pre_token.arn
    pre_sign_up          = data.aws_lambda_function.pre_signup.arn
  }

  auto_verified_attributes = ["email"]
  deletion_protection      = "INACTIVE"


  device_configuration {
    challenge_required_on_new_device      = false
    device_only_remembered_on_user_prompt = false
  }
  mfa_configuration = "OPTIONAL"
  software_token_mfa_configuration {
    enabled = true
  }
  password_policy {
    minimum_length                   = 12
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 3
  }

  schema {
    name                = "role"
    attribute_data_type = "String"
    mutable             = true
    required            = false
    string_attribute_constraints {
      min_length = 1
      max_length = 64
    }
  }
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_cognito_user_pool_domain" "admin_domain" {
  domain       = var.cognito_domain_prefix
  user_pool_id = aws_cognito_user_pool.admin.id
}

resource "aws_cognito_identity_provider" "microsoft_saml" {
  user_pool_id  = aws_cognito_user_pool.admin.id
  provider_name = "MICROSOFT-SAML" # you'll reference this in the client
  provider_type = "SAML"

  provider_details = {
    MetadataURL = var.microsoft_saml_metadata_url
    IDPSignout  = "true"
  }

  attribute_mapping = {
    email              = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
    given_name         = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"
    family_name        = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"
    preferred_username = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
    phone_number       = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/mobilephone"
  }
}

# Admin User Pool Client
resource "aws_cognito_user_pool_client" "admin_client" {
  name         = "${var.common.project_name}-${var.common.environment}-admin-user-pool-client"
  user_pool_id = aws_cognito_user_pool.admin.id


  # Hosted UI / OAuth
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"] # or ["code", "implicit"]
  allowed_oauth_scopes                 = ["openid", "email", "profile", "aws.cognito.signin.user.admin"]

  callback_urls = var.cognito_callback_urls
  logout_urls   = var.cognito_logout_urls

  # Allow both Cognito (username/email) and Microsoft SAML
  supported_identity_providers = [
    "COGNITO",
    aws_cognito_identity_provider.microsoft_saml.provider_name,
  ]

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30


  # optional: to allow SRP / admin auth etc.
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH"
  ]
}

# Admin Identity Pool
resource "aws_cognito_identity_pool" "admin_identity_pool" {
  identity_pool_name               = "${var.common.project_name}-${var.common.environment}-admin-identity-pool"
  allow_unauthenticated_identities = true

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.admin_client.id
    provider_name           = "cognito-idp.${var.common.region}.amazonaws.com/${aws_cognito_user_pool.admin.id}"
    server_side_token_check = false
  }
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

# Admin Authenticated Role
resource "aws_iam_role" "admin_authenticated_role" {
  name = "${var.common.project_name}-${var.common.environment}-admin-authenticated-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.admin_identity_pool.id
          },
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "admin_authenticated_role_policy" {
  name = "${var.common.project_name}-${var.common.environment}-admin-authenticated-policy"
  role = aws_iam_role.admin_authenticated_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "mobileanalytics:PutEvents",
          "cognito-sync:*",
          "cognito-identity:*",
        ],
        Resource = "*",
      },
      {
        Effect   = "Allow",
        Action   = "s3:*",
        Resource = "*",
      },
    ]
  })
}

# Admin Authenticated Role Mapping
resource "aws_cognito_identity_pool_roles_attachment" "admin_identity_pool_role_mapping" {
  identity_pool_id = aws_cognito_identity_pool.admin_identity_pool.id
  roles = {
    authenticated = aws_iam_role.admin_authenticated_role.arn
  }
}
