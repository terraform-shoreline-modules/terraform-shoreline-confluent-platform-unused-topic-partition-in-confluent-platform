

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