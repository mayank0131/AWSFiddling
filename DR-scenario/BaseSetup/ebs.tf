data "aws_ebs_snapshot" "latest" {
  count       = var.create_volume_from_snapshot ? 1 : 0
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Name"
    values = ["dr-volume-snapshot"]
  }
}

resource "aws_ebs_volume" "from_snapshot" {
  count             = var.create_volume_from_snapshot ? 1 : 0
  snapshot_id       = data.aws_ebs_snapshot.latest[0].id
  availability_zone = local.selected_az
  tags = {
    "Name"     = "volume-1",
    "Snapshot" = "true"
  }
}

resource "aws_ebs_volume" "base_volume" {
  count             = var.create_volume_from_snapshot ? 0 : 1
  availability_zone = local.selected_az
  size              = 40
  tags = {
    "Name"     = "volume-1",
    "Snapshot" = "true"
  }
}

resource "aws_dlm_lifecycle_policy" "ebs_snapshot" {
  description        = "Create snapshot every 24 hours and retain last one"
  execution_role_arn = aws_iam_role.dlm_role.arn
  state              = "ENABLED"
  policy_details {
    resource_types = ["VOLUME"]
    target_tags = {
      Snapshot = "true"
    }
    schedule {
      name = "daily snapshot"
      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["12:36"]
      }
      retain_rule {
        count = 2
      }
      tags_to_add = {
        "Name" = "dr-volume-snapshot"
      }
    }
  }
}

