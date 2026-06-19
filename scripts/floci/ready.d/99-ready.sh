#!/bin/bash

function is_ready() {
  # test-reports
  awslocal s3 ls s3://reports || return 1

  # trade-gateway
  awslocal sns list-topics --query "Topics[?ends_with(TopicArn, ':trade_gateway_ched_updates')].TopicArn" || return 1
  awslocal sns list-topics --query "Topics[?ends_with(TopicArn, ':trade_gateway_docom_updates')].TopicArn" || return 1
  awslocal sns list-topics --query "Topics[?ends_with(TopicArn, ':trade_gateway_intra_updates')].TopicArn" || return 1

  # trade-gateway-publisher
  awslocal sns list-topics --query "Topics[?ends_with(TopicArn, ':trade_gateway_publisher_ched_stream_internal.fifo')].TopicArn" || return 1
  awslocal sns list-topics --query "Topics[?ends_with(TopicArn, ':trade_gateway_publisher_ched_updates.fifo')].TopicArn" || return 1
  awslocal sns list-topics --query "Topics[?ends_with(TopicArn, ':trade_gateway_publisher_intra_stream_internal.fifo')].TopicArn" || return 1
  awslocal sns list-topics --query "Topics[?ends_with(TopicArn, ':trade_gateway_publisher_intra_updates.fifo')].TopicArn" || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_ched_stream_internal_publisher.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_intra_stream_internal_publisher.fifo || return 1

  return 0
}

while ! is_ready; do
  echo "Waiting until ready..."
  sleep 1
done
