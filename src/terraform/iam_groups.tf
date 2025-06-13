locals {
    group_names = ["AdminGroup", "DevelopersGroup", "TestGroup"]
}

resource "aws_iam_group" "org_group" {
    for_each = toset(local.group_names)
    name = each.value
}

resource "aws_iam_group_policy_attachment" "admin_group_policy" {
    group = aws_iam_group.org_group["AdminGroup"].name
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "developers_group_policy" {
    for_each = toset(
        [
        "arn:aws:iam::aws:policy/AmazonEC2FullAccess", 
        "arn:aws:iam::aws:policy/AmazonS3FullAccess", 
        "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
        ]
    )
    group = aws_iam_group.org_group["DevelopersGroup"].name
    policy_arn = each.value
}

resource "aws_iam_group_policy_attachment" "test_group_policy" {
    group = aws_iam_group.org_group["TestGroup"].name
    policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess" 
}