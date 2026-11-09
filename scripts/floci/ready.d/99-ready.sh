#!/usr/bin/env bash

function is_ready() {
  # test-reports
  awslocal s3 ls s3://reports || return 1

  # trade-gateway-publisher
  awslocal sns get-topic-attributes --topic-arn "arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_ched_stream_internal.fifo" >/dev/null || return 1
  awslocal sns get-topic-attributes --topic-arn "arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_ched_updates.fifo" >/dev/null || return 1
  awslocal sns get-topic-attributes --topic-arn "arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_intra_stream_internal.fifo" >/dev/null || return 1
  awslocal sns get-topic-attributes --topic-arn "arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_intra_updates.fifo" >/dev/null || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_ched_stream_internal_publisher-deadletter.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_ched_stream_internal_publisher.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_ched_stream_internal_asb_publisher-deadletter.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_ched_stream_internal_asb_publisher.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_intra_stream_internal_publisher-deadletter.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_intra_stream_internal_publisher.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_intra_stream_internal_asb_publisher-deadletter.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_intra_stream_internal_asb_publisher.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_intra_updates_test.fifo || return 1

  # trade-gateway: CHED attachment downloads
  awslocal sns get-topic-attributes --topic-arn "arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_ched_attachments_internal.fifo" >/dev/null || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_ched_attachments_internal_downloader-deadletter.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_ched_attachments_internal_downloader.fifo || return 1
  awslocal s3 ls s3://trade-gateway-documents || return 1

  # cdp-uploader
  awslocal s3 ls s3://cdp-uploader-quarantine || return 1
  awslocal sqs get-queue-url --queue-name cdp-clamav-results || return 1
  awslocal sqs get-queue-url --queue-name cdp-uploader-scan-results-callback.fifo || return 1
  awslocal sqs get-queue-url --queue-name cdp-uploader-download-requests || return 1
  awslocal sqs get-queue-url --queue-name mock-clamav || return 1

  return 0
}

is_ready
