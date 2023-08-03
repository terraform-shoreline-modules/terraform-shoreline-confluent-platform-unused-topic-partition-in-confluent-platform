

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