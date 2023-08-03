

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