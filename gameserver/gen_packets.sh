#!/usr/bin/env bash

mkdir -p example
protoc --go_out=.. --python_out=example packets.proto
