

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