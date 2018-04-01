#!/bin/bash

./gradlew build
cp /home/ec2-user/springboot-deploy/build/libs/*.jar /home/ec2-user/build/
./scripts/deploy.sh