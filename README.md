
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Unused topic partition in Confluent Platform
---

This incident type indicates that there is an unused topic partition in the Confluent Platform. This can lead to reduced efficiency and increased Broker overhead. It is recommended to delete unused partitions to avoid these issues. This incident may be triggered by a monitoring tool or an alert and can be resolved by verifying if the unused partition is intentional and deleting it if required.

### Parameters
```shell
# Environment Variables

export ZOOKEEPER_PORT="PLACEHOLDER"

export TOPIC_NAME="PLACEHOLDER"

export CONFLUENT_PATH="PLACEHOLDER"

export ZOOKEEPER_HOST="PLACEHOLDER"

export PARTITION_NUMBER="PLACEHOLDER"

export KAFKA_BROKER_ADDRESS="PLACEHOLDER"

export PATH_TO_KAFKA_FOLDER="PLACEHOLDER"

export PARTITION_NAME="PLACEHOLDER"
```

## Debug

### Check the status of the Kafka brokers
```shell
systemctl status kafka.service
```

### Check if the topic exists
```shell
${CONFLUENT_PATH}/bin/kafka-topics --zookeeper ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT} --describe --topic ${TOPIC_NAME}
```

### List all the Kafka topics
```shell
${CONFLUENT_PATH}/bin/kafka-topics --zookeeper ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT} --list
```

### Check the disk usage of the Kafka brokers
```shell
df -h
```

### Check the available memory
```shell
free -h
```

### Check the Kafka logs
```shell
tail -f ${CONFLUENT_PATH}/logs/kafka.log
```

### Check the Zookeeper logs
```shell
tail -f ${CONFLUENT_PATH}/logs/zookeeper.log
```

### A new topic partition was created and then left unused by mistake.
```shell


#!/bin/bash



# Parameters

KAFKA_BROKER=${KAFKA_BROKER_ADDRESS}

TOPIC_NAME=${TOPIC_NAME}

PARTITION_NUMBER=${PARTITION_NUMBER}



# Check if partition is empty

partition_size=$(kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list $KAFKA_BROKER --topic $TOPIC_NAME --partitions $PARTITION_NUMBER --time -1 | awk -F ":" '{sum += $3} END {print sum}')

if [ "$partition_size" -eq "0" ]; then

  echo "Partition $PARTITION_NUMBER in topic $TOPIC_NAME is empty."

else

  echo "Partition $PARTITION_NUMBER in topic $TOPIC_NAME is not empty."

fi



# Check if any messages have been written to the partition

latest_offset=$(kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list $KAFKA_BROKER --topic $TOPIC_NAME --partitions $PARTITION_NUMBER --time -1 | awk -F ":" '{print $3}')

earliest_offset=$(kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list $KAFKA_BROKER --topic $TOPIC_NAME --partitions $PARTITION_NUMBER --time -2 | awk -F ":" '{print $3}')

if [ "$latest_offset" -eq "$earliest_offset" ]; then

  echo "No messages have been written to partition $PARTITION_NUMBER in topic $TOPIC_NAME."

else

  echo "Messages have been written to partition $PARTITION_NUMBER in topic $TOPIC_NAME."

fi


```

### A topic partition was purposely left unused, but the overhead caused by it was not considered.
```shell


#!/bin/bash



# Set the topic name and partition number

topic=${TOPIC_NAME}

partition=${PARTITION_NUMBER}



# Get the byte in rate for the topic partition

bytes_in=$(curl -s -X GET "http://localhost:9090/api/v1/query?query=avg(last_5m):avg:confluent.kafka.server.topic.bytes_in_per_sec.rate{$topic-partition=$partition}" | jq -r '.data.result[].value[1]')



# Get the byte out rate for the topic partition

bytes_out=$(curl -s -X GET "http://localhost:9090/api/v1/query?query=avg(last_5m):avg:confluent.kafka.server.topic.bytes_out_per_sec.rate{$topic-partition=$partition}" | jq -r '.data.result[].value[1]')



# Check if both byte in and byte out rates are 0

if (( $(echo "$bytes_in + $bytes_out == 0" | bc -l) )); then

  echo "The partition appears to be unused."

else

  echo "The partition is being used."

fi


```

## Repair

### Verify the partition is actually unused.
```shell


#!/bin/bash



# Set the required environment variables

export KAFKA_HOME=${PATH_TO_KAFKA_FOLDER}

export TOPIC_NAME=${TOPIC_NAME}

export PARTITION_NUMBER=${PARTITION_NUMBER}



# Get the partition details using Kafka command-line tools

partition_details=$($KAFKA_HOME/bin/kafka-topics.sh --describe --topic $TOPIC_NAME --zookeeper localhost:2181 | grep -w "Partition:$PARTITION_NUMBER")



# Check if the partition is unused

if [[ $partition_details == *"leader: none"* ]] && [[ $partition_details == *"isr: []"* ]]; then

    echo "Partition $PARTITION_NUMBER is unused."

else

    echo "Partition $PARTITION_NUMBER is being used."

fi


```

### If the partition is unused, delete it to reduce Broker overhead.
```shell


#!/bin/bash



# Replace ${PARTITION_NAME} with the name of the unused partition

partition_name=${PARTITION_NAME}



# Check if the partition is unused

if kafka-topics.sh --zookeeper ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT} --describe --topic ${TOPIC_NAME} | grep -q "${PARTITION_NAME}\t[[:digit:]]\t"; then

    # Delete the partition

    kafka-topics.sh --zookeeper ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT} --delete --topic ${TOPIC_NAME} --partitions ${PARTITION_NAME}

    echo "Unused partition ${PARTITION_NAME} has been deleted."

else

    echo "Partition ${PARTITION_NAME} is not unused."

fi


```

### Verify the partition is actually unused.
```shell


#!/bin/bash



# Set the required environment variables

export KAFKA_HOME=${PATH_TO_KAFKA_FOLDER}

export TOPIC_NAME=${TOPIC_NAME}

export PARTITION_NUMBER=${PARTITION_NUMBER}



# Get the partition details using Kafka command-line tools

partition_details=$($KAFKA_HOME/bin/kafka-topics.sh --describe --topic $TOPIC_NAME --zookeeper localhost:2181 | grep -w "Partition:$PARTITION_NUMBER")



# Check if the partition is unused

if [[ $partition_details == *"leader: none"* ]] && [[ $partition_details == *"isr: []"* ]]; then

    echo "Partition $PARTITION_NUMBER is unused."

else

    echo "Partition $PARTITION_NUMBER is being used."

fi


```