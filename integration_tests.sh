#!/bin/sh
 
echo "Starting script...."

TEST_ID=`openssl rand -hex 6`
echo "Test id is: $TEST_ID"

node integration_test/setup/index.js "$TEST_ID"

flutter drive --driver=test_driver/integration_test.dart --target=integration_test/integration_tests.dart --dart-define="testId=$TEST_ID"


