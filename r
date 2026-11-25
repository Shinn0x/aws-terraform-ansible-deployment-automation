{
    "Roles": [
        {
            "Path": "/service-role/",
            "RoleName": "Amazon_EventBridge_Invoke_Lambda_1891271616",
            "RoleId": "AROARCU6HWPK5F25TCDUF",
            "Arn": "arn:aws:iam::074420040661:role/service-role/Amazon_EventBridge_Invoke_Lambda_1891271616",
            "CreateDate": "2026-11-19T08:56:27+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Sid": "TrustEventBridgeService",
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "events.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole",
                        "Condition": {
                            "StringEquals": {
                                "aws:SourceAccount": "074420040661",
                                "aws:SourceArn": "arn:aws:events:us-east-1:074420040661:rule/slack"
                            }
                        }
                    }
                ]
            },
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/service-role/",
            "RoleName": "Amazon_EventBridge_Scheduler_LAMBDA_7614c2e917",
            "RoleId": "AROARCU6HWPK6IIWDKEZO",
            "Arn": "arn:aws:iam::074420040661:role/service-role/Amazon_EventBridge_Scheduler_LAMBDA_7614c2e917",
            "CreateDate": "2026-11-19T06:34:19+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "scheduler.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole",
                        "Condition": {
                            "StringEquals": {
                                "aws:SourceAccount": "074420040661"
                            }
                        }
                    }
                ]
            },
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/service-role/",
            "RoleName": "api-gateway-root-get-role-fp0g555n",
            "RoleId": "AROARCU6HWPK2QYHQB5TK",
            "Arn": "arn:aws:iam::074420040661:role/service-role/api-gateway-root-get-role-fp0g555n",
            "CreateDate": "2026-08-03T20:04:18+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "lambda.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/aws-service-role/ops.apigateway.amazonaws.com/",
            "RoleName": "AWSServiceRoleForAPIGateway",
            "RoleId": "AROARCU6HWPKSTG3C5SEL",
            "Arn": "arn:aws:iam::074420040661:role/aws-service-role/ops.apigateway.amazonaws.com/AWSServiceRoleForAPIGateway",
            "CreateDate": "2026-08-03T18:42:57+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "ops.apigateway.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "Description": "The Service Linked Role is used by Amazon API Gateway.",
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/aws-service-role/ecs.application-autoscaling.amazonaws.com/",
            "RoleName": "AWSServiceRoleForApplicationAutoScaling_ECSService",
            "RoleId": "AROARCU6HWPKYL45ESEJP",
            "Arn": "arn:aws:iam::074420040661:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService",
            "CreateDate": "2026-08-11T15:09:01+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "ecs.application-autoscaling.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/aws-service-role/ecs.amazonaws.com/",
            "RoleName": "AWSServiceRoleForECS",
            "RoleId": "AROARCU6HWPKS6GGIOSWU",
            "Arn": "arn:aws:iam::074420040661:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS",
            "CreateDate": "2026-08-11T14:48:38+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "ecs.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "Description": "Policy to enable Amazon ECS to manage your EC2 instances and related resources.",
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/aws-service-role/elasticloadbalancing.amazonaws.com/",
            "RoleName": "AWSServiceRoleForElasticLoadBalancing",
            "RoleId": "AROARCU6HWPKYMABKZWL6",
            "Arn": "arn:aws:iam::074420040661:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing",
            "CreateDate": "2026-08-11T15:03:07+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "elasticloadbalancing.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "Description": "Allows ELB to call AWS services on your behalf.",
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/aws-service-role/rds.amazonaws.com/",
            "RoleName": "AWSServiceRoleForRDS",
            "RoleId": "AROARCU6HWPKRWBOS6RSH",
            "Arn": "arn:aws:iam::074420040661:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS",
            "CreateDate": "2026-08-02T09:17:41+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "rds.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "Description": "Allows Amazon RDS to manage AWS resources on your behalf",
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/aws-service-role/resource-explorer-2.amazonaws.com/",
            "RoleName": "AWSServiceRoleForResourceExplorer",
            "RoleId": "AROARCU6HWPKXQ57RBHMO",
            "Arn": "arn:aws:iam::074420040661:role/aws-service-role/resource-explorer-2.amazonaws.com/AWSServiceRoleForResourceExplorer",
            "CreateDate": "2026-08-02T09:40:03+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "resource-explorer-2.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/aws-service-role/support.amazonaws.com/",
            "RoleName": "AWSServiceRoleForSupport",
            "RoleId": "AROARCU6HWPKZRPXYGZHP",
            "Arn": "arn:aws:iam::074420040661:role/aws-service-role/support.amazonaws.com/AWSServiceRoleForSupport",
            "CreateDate": "2026-08-02T08:31:01+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "support.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "Description": "Enables resource access for AWS to provide billing, administrative and support services",
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/aws-service-role/trustedadvisor.amazonaws.com/",
            "RoleName": "AWSServiceRoleForTrustedAdvisor",
            "RoleId": "AROARCU6HWPK6G7UDDM2X",
            "Arn": "arn:aws:iam::074420040661:role/aws-service-role/trustedadvisor.amazonaws.com/AWSServiceRoleForTrustedAdvisor",
            "CreateDate": "2026-08-02T08:31:01+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "trustedadvisor.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "Description": "Access for the AWS Trusted Advisor Service to help reduce cost, increase performance, and improve security of your AWS environment.",
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/service-role/",
            "RoleName": "beach-rvsp-role-gicj0pfa",
            "RoleId": "AROARCU6HWPKWCJY76I6U",
            "Arn": "arn:aws:iam::074420040661:role/service-role/beach-rvsp-role-gicj0pfa",
            "CreateDate": "2026-09-03T14:37:45+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "lambda.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/",
            "RoleName": "ecsTaskExecutionRole",
            "RoleId": "AROARCU6HWPKVA72WYSSF",
            "Arn": "arn:aws:iam::074420040661:role/ecsTaskExecutionRole",
            "CreateDate": "2026-08-11T14:52:35+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2008-10-17",
                "Statement": [
                    {
                        "Sid": "",
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "ecs-tasks.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/service-role/",
            "RoleName": "http-function-url-tutorial-role-hl3vb27g",
            "RoleId": "AROARCU6HWPK5BSJVK57D",
            "Arn": "arn:aws:iam::074420040661:role/service-role/http-function-url-tutorial-role-hl3vb27g",
            "CreateDate": "2026-08-02T09:12:47+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "lambda.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/service-role/",
            "RoleName": "ListProcessor-role-rzemy8vq",
            "RoleId": "AROARCU6HWPKTYHJOTBCP",
            "Arn": "arn:aws:iam::074420040661:role/service-role/ListProcessor-role-rzemy8vq",
            "CreateDate": "2026-08-03T15:26:47+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "lambda.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/service-role/",
            "RoleName": "myFunctionName-role-vak6u7jp",
            "RoleId": "AROARCU6HWPKQRT2MVKTW",
            "Arn": "arn:aws:iam::074420040661:role/service-role/myFunctionName-role-vak6u7jp",
            "CreateDate": "2026-11-19T05:49:10+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "lambda.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/service-role/",
            "RoleName": "pi-gateway-root-get-hello-world-role-6xo4p85u",
            "RoleId": "AROARCU6HWPKRZTOAXRWF",
            "Arn": "arn:aws:iam::074420040661:role/service-role/pi-gateway-root-get-hello-world-role-6xo4p85u",
            "CreateDate": "2026-08-03T21:13:57+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "lambda.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/service-role/",
            "RoleName": "SlackAlert-role-xkt5htl3",
            "RoleId": "AROARCU6HWPKSSH4VZ4IQ",
            "Arn": "arn:aws:iam::074420040661:role/service-role/SlackAlert-role-xkt5htl3",
            "CreateDate": "2026-11-19T08:34:03+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "lambda.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/service-role/",
            "RoleName": "StepFunctions-HelloWorldStateMachine-role-f1azw4hsc",
            "RoleId": "AROARCU6HWPKUOHEPEETS",
            "Arn": "arn:aws:iam::074420040661:role/service-role/StepFunctions-HelloWorldStateMachine-role-f1azw4hsc",
            "CreateDate": "2026-08-04T14:33:01+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "states.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/",
            "RoleName": "tarot-api-lambda-role",
            "RoleId": "AROARCU6HWPKVP44AICIU",
            "Arn": "arn:aws:iam::074420040661:role/tarot-api-lambda-role",
            "CreateDate": "2026-08-12T14:24:00+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "lambda.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "Description": "Allows Lambda functions to call AWS services on your behalf.",
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/",
            "RoleName": "vego-app-thumbnails-func-role-gdwq08hm",
            "RoleId": "AROARCU6HWPK3C6GW3N2E",
            "Arn": "arn:aws:iam::074420040661:role/vego-app-thumbnails-func-role-gdwq08hm",
            "CreateDate": "2026-08-03T15:44:24+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "lambda.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "Description": "",
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/",
            "RoleName": "znv-ecs-exec-role",
            "RoleId": "AROARCU6HWPKSIYSBVARU",
            "Arn": "arn:aws:iam::074420040661:role/znv-ecs-exec-role",
            "CreateDate": "2026-08-27T14:16:11+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Sid": "",
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "ecs-tasks.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "Description": "Allows ECS tasks to call AWS services on your behalf.",
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/",
            "RoleName": "znv-ssm-role",
            "RoleId": "AROARCU6HWPKZVJCVTHX6",
            "Arn": "arn:aws:iam::074420040661:role/znv-ssm-role",
            "CreateDate": "2026-08-26T17:59:24+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "ec2.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "Description": "Allows EC2 instances to call AWS services on your behalf.",
            "MaxSessionDuration": 3600
        },
        {
            "Path": "/",
            "RoleName": "znv-vpc-logs-role",
            "RoleId": "AROARCU6HWPKXHT56YEE5",
            "Arn": "arn:aws:iam::074420040661:role/znv-vpc-logs-role",
            "CreateDate": "2026-08-27T14:40:27+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Sid": "Statement1",
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "vpc-flow-logs.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            },
            "Description": "",
            "MaxSessionDuration": 3600
        }
    ]
}
