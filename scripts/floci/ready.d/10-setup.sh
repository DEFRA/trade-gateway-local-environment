#!/usr/bin/env bash

# test-reports
awslocal s3 mb s3://reports

# trade-gateway-publisher
awslocal sns create-topic --name trade_gateway_publisher_ched_stream_internal.fifo --attributes '{"FifoTopic":"true","ContentBasedDeduplication":"true"}'
awslocal sns create-topic --name trade_gateway_publisher_ched_updates.fifo --attributes '{"FifoTopic":"true","ContentBasedDeduplication":"true"}'
awslocal sns create-topic --name trade_gateway_publisher_intra_stream_internal.fifo --attributes '{"FifoTopic":"true","ContentBasedDeduplication":"true"}'
awslocal sns create-topic --name trade_gateway_publisher_intra_updates.fifo --attributes '{"FifoTopic":"true","ContentBasedDeduplication":"true"}'

awslocal sqs create-queue --queue-name trade_gateway_publisher_ched_stream_internal_publisher-deadletter.fifo --attributes '{"FifoQueue":"true","ContentBasedDeduplication":"true"}'
awslocal sqs create-queue --queue-name trade_gateway_publisher_ched_stream_internal_publisher.fifo --attributes '{"FifoQueue":"true","ContentBasedDeduplication":"true","RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_gateway_publisher_ched_stream_internal_publisher-deadletter.fifo\",\"maxReceiveCount\":\"1\"}","Policy":"{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"sns.amazonaws.com\"},\"Action\":\"sqs:SendMessage\",\"Resource\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_gateway_publisher_ched_stream_internal_publisher.fifo\",\"Condition\":{\"ArnEquals\":{\"aws:SourceArn\":\"arn:aws:sns:'"$AWS_REGION"':000000000000:trade_gateway_publisher_ched_updates.fifo\"}}}]}"}'

awslocal sqs create-queue --queue-name trade_gateway_publisher_ched_stream_internal_asb_publisher-deadletter.fifo --attributes '{"FifoQueue":"true","ContentBasedDeduplication":"true"}'
awslocal sqs create-queue --queue-name trade_gateway_publisher_ched_stream_internal_asb_publisher.fifo --attributes '{"FifoQueue":"true","ContentBasedDeduplication":"true","RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_gateway_publisher_ched_stream_internal_asb_publisher-deadletter.fifo\",\"maxReceiveCount\":\"1\"}","Policy":"{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"sns.amazonaws.com\"},\"Action\":\"sqs:SendMessage\",\"Resource\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_gateway_publisher_ched_stream_internal_asb_publisher.fifo\",\"Condition\":{\"ArnEquals\":{\"aws:SourceArn\":\"arn:aws:sns:'"$AWS_REGION"':000000000000:trade_gateway_publisher_ched_stream_internal.fifo\"}}}]}" }'

awslocal sqs create-queue --queue-name trade_gateway_publisher_intra_stream_internal_publisher-deadletter.fifo --attributes '{"FifoQueue":"true","ContentBasedDeduplication":"true"}'
awslocal sqs create-queue --queue-name trade_gateway_publisher_intra_stream_internal_publisher.fifo --attributes '{"FifoQueue":"true","ContentBasedDeduplication":"true","RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_gateway_publisher_intra_stream_internal_publisher-deadletter.fifo\",\"maxReceiveCount\":\"1\"}","Policy":"{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"sns.amazonaws.com\"},\"Action\":\"sqs:SendMessage\",\"Resource\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_gateway_publisher_intra_stream_internal_publisher.fifo\",\"Condition\":{\"ArnEquals\":{\"aws:SourceArn\":\"arn:aws:sns:'"$AWS_REGION"':000000000000:trade_gateway_publisher_intra_stream_internal.fifo\"}}}]}"}'

awslocal sqs create-queue --queue-name trade_gateway_publisher_intra_stream_internal_asb_publisher-deadletter.fifo --attributes '{"FifoQueue":"true","ContentBasedDeduplication":"true"}'
awslocal sqs create-queue --queue-name trade_gateway_publisher_intra_stream_internal_asb_publisher.fifo --attributes '{"FifoQueue":"true","ContentBasedDeduplication":"true","RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_gateway_publisher_intra_stream_internal_asb_publisher-deadletter.fifo\",\"maxReceiveCount\":\"1\"}","Policy":"{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"sns.amazonaws.com\"},\"Action\":\"sqs:SendMessage\",\"Resource\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_gateway_publisher_intra_stream_internal_asb_publisher.fifo\",\"Condition\":{\"ArnEquals\":{\"aws:SourceArn\":\"arn:aws:sns:'"$AWS_REGION"':000000000000:trade_gateway_publisher_intra_updates.fifo\"}}}]}" }'

awslocal sqs create-queue --queue-name trade_gateway_publisher_intra_updates_test.fifo --attributes '{"FifoQueue":"true","ContentBasedDeduplication":"true","Policy":"{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"sns.amazonaws.com\"},\"Action\":\"sqs:SendMessage\",\"Resource\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_gateway_publisher_intra_updates_test.fifo\",\"Condition\":{\"ArnEquals\":{\"aws:SourceArn\":\"arn:aws:sns:'"$AWS_REGION"':000000000000:trade_gateway_publisher_intra_updates.fifo\"}}}]}"}'

awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_ched_stream_internal.fifo --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_gateway_publisher_ched_stream_internal_publisher.fifo --attributes '{"RawMessageDelivery":"true"}'
awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_ched_updates.fifo --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_gateway_publisher_ched_stream_internal_asb_publisher.fifo --attributes '{"RawMessageDelivery":"true"}'
awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_intra_stream_internal.fifo --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_gateway_publisher_intra_stream_internal_publisher.fifo --attributes '{"RawMessageDelivery":"true"}'
awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_intra_updates.fifo --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_gateway_publisher_intra_stream_internal_asb_publisher.fifo --attributes '{"RawMessageDelivery":"true"}'
awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_intra_updates.fifo --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_gateway_publisher_intra_updates_test.fifo --attributes '{"RawMessageDelivery":"true"}'

# trade-gateway: CHED attachment downloads
awslocal sns create-topic --name trade_gateway_ched_attachments_internal.fifo --attributes '{"FifoTopic":"true","ContentBasedDeduplication":"true"}'

awslocal sqs create-queue --queue-name trade_gateway_ched_attachments_internal_downloader-deadletter.fifo --attributes '{"FifoQueue":"true","ContentBasedDeduplication":"true"}'
awslocal sqs create-queue --queue-name trade_gateway_ched_attachments_internal_downloader.fifo --attributes '{"FifoQueue":"true","ContentBasedDeduplication":"true","VisibilityTimeout":"120","RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_gateway_ched_attachments_internal_downloader-deadletter.fifo\",\"maxReceiveCount\":\"3\"}","Policy":"{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"sns.amazonaws.com\"},\"Action\":\"sqs:SendMessage\",\"Resource\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_gateway_ched_attachments_internal_downloader.fifo\",\"Condition\":{\"ArnEquals\":{\"aws:SourceArn\":\"arn:aws:sns:'"$AWS_REGION"':000000000000:trade_gateway_ched_attachments_internal.fifo\"}}}]}"}'

awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_ched_attachments_internal.fifo --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_gateway_ched_attachments_internal_downloader.fifo --attributes '{"RawMessageDelivery":"true"}'

# Scanned attachments expire after 190 days, 10 days after their Mongo record (180-day TTL index).
awslocal s3 mb s3://trade-gateway-documents
awslocal s3api put-bucket-lifecycle-configuration --bucket trade-gateway-documents --lifecycle-configuration '{"Rules":[{"ID":"expire-ched-attachments","Status":"Enabled","Filter":{"Prefix":""},"Expiration":{"Days":190}}]}'

# cdp-uploader: quarantine bucket, scan result queues, and the mock scanner's queue fed by bucket events
awslocal s3 mb s3://cdp-uploader-quarantine
awslocal sqs create-queue --queue-name cdp-clamav-results
awslocal sqs create-queue --queue-name cdp-uploader-scan-results-callback.fifo --attributes '{"FifoQueue":"true","ContentBasedDeduplication":"true"}'
awslocal sqs create-queue --queue-name cdp-uploader-download-requests
awslocal sqs create-queue --queue-name mock-clamav
awslocal s3api put-bucket-notification-configuration --bucket cdp-uploader-quarantine --notification-configuration '{"QueueConfigurations":[{"QueueArn":"arn:aws:sqs:'"$AWS_REGION"':000000000000:mock-clamav","Events":["s3:ObjectCreated:*"]}]}'
