#!/bin/bash

# test-reports
awslocal s3 mb s3://reports

# trade-gateway
awslocal sns create-topic --name trade_gateway_ched_updates
awslocal sns create-topic --name trade_gateway_docom_updates
awslocal sns create-topic --name trade_gateway_intra_updates

# trade-gateway-publisher
awslocal sns create-topic --name trade_gateway_publisher_ched_stream_internal.fifo --attributes '{"FifoTopic":"true","ContentBasedDeduplication":"true"}'
awslocal sns create-topic --name trade_gateway_publisher_ched_updates.fifo --attributes '{"FifoTopic":"true","ContentBasedDeduplication":"true"}'
awslocal sns create-topic --name trade_gateway_publisher_intra_stream_internal.fifo --attributes '{"FifoTopic":"true","ContentBasedDeduplication":"true"}'
awslocal sns create-topic --name trade_gateway_publisher_intra_updates.fifo --attributes '{"FifoTopic":"true","ContentBasedDeduplication":"true"}'
awslocal sqs create-queue --queue-name trade_gateway_publisher_ched_stream_internal_publisher.fifo --attributes '{"FifoQueue":"true","ContentBasedDeduplication":"true"}'
awslocal sqs create-queue --queue-name trade_gateway_publisher_intra_stream_internal_publisher.fifo --attributes '{"FifoQueue":"true","ContentBasedDeduplication":"true"}'
awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_ched_stream_internal.fifo --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_gateway_publisher_ched_stream_internal_publisher.fifo --attributes '{"RawMessageDelivery":"true"}'
awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_intra_stream_internal.fifo --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_gateway_publisher_intra_stream_internal_publisher.fifo --attributes '{"RawMessageDelivery":"true"}'
