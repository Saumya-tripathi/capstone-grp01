resource "aws_iot_thing" "thing02" {
  name = "sprinkler_02"
}

output "thing_name02" {
  value = aws_iot_thing.thing02.name
}

resource "tls_private_key" "SP02" {
  algorithm   = "RSA"
  rsa_bits = 2048
}

resource "tls_self_signed_cert" "SP02" {
  private_key_pem = tls_private_key.SP02.private_key_pem

  validity_period_hours = 240

  allowed_uses = [
  ]

  subject {
    organization = "test"
  }
  provisioner "local-exec" {
    command = "echo ${nonsensitive(tls_private_key.SP01.private_key_pem)} > sp02_pem_private.pem.key"
  }
}

resource "aws_iot_certificate" "SP02" {
  certificate_pem = trimspace(tls_self_signed_cert.SP02.cert_pem)
  active = true
  #csr    = file(tls_self_signed_cert.cert02.cert_pem)
  provisioner "local-exec" {
    command = "echo ${tls_self_signed_cert.SP01.cert_pem} > sp02_cert.crt"
  }
}

/*output "cert02" {
  value = tls_self_signed_cert.cert02.cert_pem
}

output "key02" {
  value = tls_private_key.key02.private_key_pem
  sensitive = true
}*/

/*data "aws_arn" "thing02" {
  arn = aws_iot_thing.thing02.arn
}*/

resource "aws_iot_policy" "policy02" {
  name = "thing_policy_02"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
        "Action": [
          "iot:*"
        ],
        "Resource": "*"
      }/*,
      {
        Action = [
          "iot:Connect",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${data.aws_arn.thing.region}:${data.aws_arn.thing.account}:client/$${iot:Connection.Thing.ThingName}"
      },
      {
        Action = [
          "iot:Publish",
          "iot:Receive",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${data.aws_arn.thing.region}:${data.aws_arn.thing.account}:topic/$aws/things/$${iot:Connection.Thing.ThingName}*//*"
      },
      {
        Action = [
          "iot:Subscribe",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${data.aws_arn.thing.region}:${data.aws_arn.thing.account}:topicfilter/$aws/things/$${iot:Connection.Thing.ThingName}*//*"
      }*/
    ]
  })
}

resource "aws_iot_policy_attachment" "attachment02" {
  policy = aws_iot_policy.policy02.name
  target = aws_iot_certificate.SP02.arn
}

resource "aws_iot_thing_principal_attachment" "attachment02" {
  principal = aws_iot_certificate.SP02.arn
  thing     = aws_iot_thing.thing02.name
}
