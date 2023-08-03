resource "shoreline_notebook" "unused_topic_partition_in_confluent_platform" {
  name       = "unused_topic_partition_in_confluent_platform"
  data       = file("${path.module}/data/unused_topic_partition_in_confluent_platform.json")
  depends_on = [shoreline_action.invoke_partition_checker,shoreline_action.invoke_kafka_partition_usage,shoreline_action.invoke_partition_details,shoreline_action.invoke_del_unused_part,shoreline_action.invoke_kafka_partition_status]
}

resource "shoreline_file" "partition_checker" {
  name             = "partition_checker"
  input_file       = "${path.module}/data/partition_checker.sh"
  md5              = filemd5("${path.module}/data/partition_checker.sh")
  description      = "A new topic partition was created and then left unused by mistake."
  destination_path = "/agent/scripts/partition_checker.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "kafka_partition_usage" {
  name             = "kafka_partition_usage"
  input_file       = "${path.module}/data/kafka_partition_usage.sh"
  md5              = filemd5("${path.module}/data/kafka_partition_usage.sh")
  description      = "A topic partition was purposely left unused, but the overhead caused by it was not considered."
  destination_path = "/agent/scripts/kafka_partition_usage.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "partition_details" {
  name             = "partition_details"
  input_file       = "${path.module}/data/partition_details.sh"
  md5              = filemd5("${path.module}/data/partition_details.sh")
  description      = "Verify the partition is actually unused."
  destination_path = "/agent/scripts/partition_details.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "del_unused_part" {
  name             = "del_unused_part"
  input_file       = "${path.module}/data/del_unused_part.sh"
  md5              = filemd5("${path.module}/data/del_unused_part.sh")
  description      = "If the partition is unused, delete it to reduce Broker overhead."
  destination_path = "/agent/scripts/del_unused_part.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "kafka_partition_status" {
  name             = "kafka_partition_status"
  input_file       = "${path.module}/data/kafka_partition_status.sh"
  md5              = filemd5("${path.module}/data/kafka_partition_status.sh")
  description      = "Verify the partition is actually unused."
  destination_path = "/agent/scripts/kafka_partition_status.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_partition_checker" {
  name        = "invoke_partition_checker"
  description = "A new topic partition was created and then left unused by mistake."
  command     = "`chmod +x /agent/scripts/partition_checker.sh && /agent/scripts/partition_checker.sh`"
  params      = ["KAFKA_BROKER_ADDRESS","TOPIC_NAME","PARTITION_NUMBER"]
  file_deps   = ["partition_checker"]
  enabled     = true
  depends_on  = [shoreline_file.partition_checker]
}

resource "shoreline_action" "invoke_kafka_partition_usage" {
  name        = "invoke_kafka_partition_usage"
  description = "A topic partition was purposely left unused, but the overhead caused by it was not considered."
  command     = "`chmod +x /agent/scripts/kafka_partition_usage.sh && /agent/scripts/kafka_partition_usage.sh`"
  params      = ["TOPIC_NAME","PARTITION_NUMBER"]
  file_deps   = ["kafka_partition_usage"]
  enabled     = true
  depends_on  = [shoreline_file.kafka_partition_usage]
}

resource "shoreline_action" "invoke_partition_details" {
  name        = "invoke_partition_details"
  description = "Verify the partition is actually unused."
  command     = "`chmod +x /agent/scripts/partition_details.sh && /agent/scripts/partition_details.sh`"
  params      = ["PATH_TO_KAFKA_FOLDER","TOPIC_NAME","PARTITION_NUMBER"]
  file_deps   = ["partition_details"]
  enabled     = true
  depends_on  = [shoreline_file.partition_details]
}

resource "shoreline_action" "invoke_del_unused_part" {
  name        = "invoke_del_unused_part"
  description = "If the partition is unused, delete it to reduce Broker overhead."
  command     = "`chmod +x /agent/scripts/del_unused_part.sh && /agent/scripts/del_unused_part.sh`"
  params      = ["ZOOKEEPER_PORT","TOPIC_NAME","ZOOKEEPER_HOST","PARTITION_NAME"]
  file_deps   = ["del_unused_part"]
  enabled     = true
  depends_on  = [shoreline_file.del_unused_part]
}

resource "shoreline_action" "invoke_kafka_partition_status" {
  name        = "invoke_kafka_partition_status"
  description = "Verify the partition is actually unused."
  command     = "`chmod +x /agent/scripts/kafka_partition_status.sh && /agent/scripts/kafka_partition_status.sh`"
  params      = ["PATH_TO_KAFKA_FOLDER","TOPIC_NAME","PARTITION_NUMBER"]
  file_deps   = ["kafka_partition_status"]
  enabled     = true
  depends_on  = [shoreline_file.kafka_partition_status]
}

