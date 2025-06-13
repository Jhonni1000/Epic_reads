locals {
    group_names = ["AdminGroup", "DevelopersGroup", "TestGroup"]
}

resource "aws_iam_group" "org_group" {
    for_each = local.group_names
    name = each.value.group_names
}

resource "aws_iam_group_policy" "admin_group_policy" {
    name = "admin_group_policy"
    group = local.group_names[0]
    policy = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy" "developers_group_policy" {
    name = "developers_group_policy"
    group = local.group_names[1]
    policy = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AmazonRDSFullAccess"]
}

resource "aws_iam_group_policy" "test_group_policy" {
    name = "test_group_policy"
    group = local.group_names[2]
    policy = "arn:aws:iam::aws:policy/ReadOnlyAccess" 
}