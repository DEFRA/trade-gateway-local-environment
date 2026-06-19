#!/bin/bash

# test-reports
awslocal s3 mb s3://reports

# trade-gateway
awslocal sns create-topic --name trade_gateway_ched_updates
awslocal sns create-topic --name trade_gateway_docom_updates
awslocal sns create-topic --name trade_gateway_intra_updates
