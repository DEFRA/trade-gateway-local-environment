#!/bin/sh

set -eu

AWS_ENDPOINT="http://floci:4566"
REGION="eu-west-2"

# Intra SNS topics
INTRA_INTERNAL_TOPIC_NAME="trade_gateway_publisher_intra_stream_internal.fifo"
INTRA_UPDATES_TOPIC_NAME="trade_gateway_publisher_intra_updates.fifo"

# Intra input queue and dead-letter queue
INTRA_QUEUE_NAME="trade_gateway_publisher_intra_stream_internal_publisher.fifo"
INTRA_DLQ_NAME="trade_gateway_publisher_intra_stream_internal_publisher-deadletter.fifo"

# Queue used by integration tests to observe outbound Intra messages
INTRA_TEST_QUEUE_NAME="trade_gateway_publisher_intra_updates_test.fifo"

# CHED SNS topics
CHED_INTERNAL_TOPIC_NAME="trade_gateway_publisher_ched_stream_internal.fifo"
CHED_UPDATES_TOPIC_NAME="trade_gateway_publisher_ched_updates.fifo"

# CHED input queue and dead-letter queue
CHED_QUEUE_NAME="trade_gateway_publisher_ched_stream_internal_publisher.fifo"
CHED_DLQ_NAME="trade_gateway_publisher_ched_stream_internal_publisher-deadletter.fifo"


aws_local() {
  aws \
    --endpoint-url "$AWS_ENDPOINT" \
    --region "$REGION" \
    "$@"
}


create_topic() {
  topic_name="$1"

  aws_local sns create-topic \
    --name "$topic_name" \
    --attributes FifoTopic=true,ContentBasedDeduplication=true \
    --query TopicArn \
    --output text
}


create_queue() {
  queue_name="$1"

  aws_local sqs create-queue \
    --queue-name "$queue_name" \
    --attributes FifoQueue=true,ContentBasedDeduplication=true \
    --query QueueUrl \
    --output text
}


get_queue_arn() {
  queue_url="$1"

  aws_local sqs get-queue-attributes \
    --queue-url "$queue_url" \
    --attribute-names QueueArn \
    --query Attributes.QueueArn \
    --output text
}


set_redrive_policy() {
  queue_url="$1"
  dead_letter_queue_arn="$2"

  cat > /tmp/redrive-attributes.json <<EOF
{
  "RedrivePolicy": "{\"deadLetterTargetArn\":\"$dead_letter_queue_arn\",\"maxReceiveCount\":\"1\"}"
}
EOF

  aws_local sqs set-queue-attributes \
    --queue-url "$queue_url" \
    --attributes file:///tmp/redrive-attributes.json
}


set_sns_queue_policy() {
  queue_url="$1"
  queue_arn="$2"
  topic_arn="$3"

  policy=$(
    cat <<EOF
{"Version":"2012-10-17","Statement":[{"Sid":"AllowSnsToSendMessage","Effect":"Allow","Principal":{"Service":"sns.amazonaws.com"},"Action":"sqs:SendMessage","Resource":"$queue_arn","Condition":{"ArnEquals":{"aws:SourceArn":"$topic_arn"}}}]}
EOF
  )

  escaped_policy=$(
    printf '%s' "$policy" |
      sed 's/\\/\\\\/g; s/"/\\"/g'
  )

  cat > /tmp/queue-policy-attributes.json <<EOF
{
  "Policy": "$escaped_policy"
}
EOF

  aws_local sqs set-queue-attributes \
    --queue-url "$queue_url" \
    --attributes file:///tmp/queue-policy-attributes.json
}


subscription_exists() {
  topic_arn="$1"
  queue_arn="$2"

  subscriptions=$(
    aws_local sns list-subscriptions-by-topic \
      --topic-arn "$topic_arn" \
      --query "Subscriptions[?Endpoint=='$queue_arn'].SubscriptionArn" \
      --output text
  )

  [ -n "$subscriptions" ]
}


subscribe_queue() {
  topic_arn="$1"
  queue_arn="$2"

  if subscription_exists "$topic_arn" "$queue_arn"; then
    echo "Subscription already exists:"
    echo "  $topic_arn"
    echo "  -> $queue_arn"
    return
  fi

  aws_local sns subscribe \
    --topic-arn "$topic_arn" \
    --protocol sqs \
    --notification-endpoint "$queue_arn" \
    --attributes RawMessageDelivery=true \
    --query SubscriptionArn \
    --output text
}


echo
echo "Creating SNS FIFO topics..."

INTRA_INTERNAL_TOPIC_ARN=$(create_topic "$INTRA_INTERNAL_TOPIC_NAME")
INTRA_UPDATES_TOPIC_ARN=$(create_topic "$INTRA_UPDATES_TOPIC_NAME")

CHED_INTERNAL_TOPIC_ARN=$(create_topic "$CHED_INTERNAL_TOPIC_NAME")
CHED_UPDATES_TOPIC_ARN=$(create_topic "$CHED_UPDATES_TOPIC_NAME")

echo "Created SNS topics:"
echo "  $INTRA_INTERNAL_TOPIC_ARN"
echo "  $INTRA_UPDATES_TOPIC_ARN"
echo "  $CHED_INTERNAL_TOPIC_ARN"
echo "  $CHED_UPDATES_TOPIC_ARN"


echo
echo "Creating SQS FIFO queues..."

INTRA_QUEUE_URL=$(create_queue "$INTRA_QUEUE_NAME")
INTRA_DLQ_URL=$(create_queue "$INTRA_DLQ_NAME")
INTRA_TEST_QUEUE_URL=$(create_queue "$INTRA_TEST_QUEUE_NAME")

CHED_QUEUE_URL=$(create_queue "$CHED_QUEUE_NAME")
CHED_DLQ_URL=$(create_queue "$CHED_DLQ_NAME")

echo "Created SQS queues:"
echo "  $INTRA_QUEUE_URL"
echo "  $INTRA_DLQ_URL"
echo "  $INTRA_TEST_QUEUE_URL"
echo "  $CHED_QUEUE_URL"
echo "  $CHED_DLQ_URL"


echo
echo "Retrieving SQS queue ARNs..."

INTRA_QUEUE_ARN=$(get_queue_arn "$INTRA_QUEUE_URL")
INTRA_DLQ_ARN=$(get_queue_arn "$INTRA_DLQ_URL")
INTRA_TEST_QUEUE_ARN=$(get_queue_arn "$INTRA_TEST_QUEUE_URL")

CHED_QUEUE_ARN=$(get_queue_arn "$CHED_QUEUE_URL")
CHED_DLQ_ARN=$(get_queue_arn "$CHED_DLQ_URL")

echo "Retrieved SQS queue ARNs:"
echo "  $INTRA_QUEUE_ARN"
echo "  $INTRA_DLQ_ARN"
echo "  $INTRA_TEST_QUEUE_ARN"
echo "  $CHED_QUEUE_ARN"
echo "  $CHED_DLQ_ARN"


echo
echo "Applying dead-letter queue configuration..."

set_redrive_policy \
  "$INTRA_QUEUE_URL" \
  "$INTRA_DLQ_ARN"

set_redrive_policy \
  "$CHED_QUEUE_URL" \
  "$CHED_DLQ_ARN"


echo
echo "Allowing SNS topics to publish to their SQS queues..."

set_sns_queue_policy \
  "$INTRA_QUEUE_URL" \
  "$INTRA_QUEUE_ARN" \
  "$INTRA_INTERNAL_TOPIC_ARN"

set_sns_queue_policy \
  "$CHED_QUEUE_URL" \
  "$CHED_QUEUE_ARN" \
  "$CHED_INTERNAL_TOPIC_ARN"

set_sns_queue_policy \
  "$INTRA_TEST_QUEUE_URL" \
  "$INTRA_TEST_QUEUE_ARN" \
  "$INTRA_UPDATES_TOPIC_ARN"


echo
echo "Creating SNS-to-SQS subscriptions..."

# Internal Intra messages are delivered to the publisher's Intra queue.
subscribe_queue \
  "$INTRA_INTERNAL_TOPIC_ARN" \
  "$INTRA_QUEUE_ARN"

# Internal CHED messages are delivered to the publisher's CHED queue.
subscribe_queue \
  "$CHED_INTERNAL_TOPIC_ARN" \
  "$CHED_QUEUE_ARN"

# Outbound Intra update messages are delivered to the integration-test queue.
subscribe_queue \
  "$INTRA_UPDATES_TOPIC_ARN" \
  "$INTRA_TEST_QUEUE_ARN"


echo
echo "Verifying SNS topics..."

aws_local sns get-topic-attributes \
  --topic-arn "$INTRA_INTERNAL_TOPIC_ARN" >/dev/null

aws_local sns get-topic-attributes \
  --topic-arn "$INTRA_UPDATES_TOPIC_ARN" >/dev/null

aws_local sns get-topic-attributes \
  --topic-arn "$CHED_INTERNAL_TOPIC_ARN" >/dev/null

aws_local sns get-topic-attributes \
  --topic-arn "$CHED_UPDATES_TOPIC_ARN" >/dev/null


echo "Verifying SQS queues..."

aws_local sqs get-queue-url \
  --queue-name "$INTRA_QUEUE_NAME" >/dev/null

aws_local sqs get-queue-url \
  --queue-name "$INTRA_DLQ_NAME" >/dev/null

aws_local sqs get-queue-url \
  --queue-name "$INTRA_TEST_QUEUE_NAME" >/dev/null

aws_local sqs get-queue-url \
  --queue-name "$CHED_QUEUE_NAME" >/dev/null

aws_local sqs get-queue-url \
  --queue-name "$CHED_DLQ_NAME" >/dev/null


echo "Verifying SNS subscriptions..."

subscription_exists \
  "$INTRA_INTERNAL_TOPIC_ARN" \
  "$INTRA_QUEUE_ARN"

subscription_exists \
  "$CHED_INTERNAL_TOPIC_ARN" \
  "$CHED_QUEUE_ARN"

subscription_exists \
  "$INTRA_UPDATES_TOPIC_ARN" \
  "$INTRA_TEST_QUEUE_ARN"


echo
echo "All trade-gateway-publisher AWS resources are ready."