#!/bin/bash

PROJECT_PATH=/home/ec2-user/springboot-deploy
$PROJECT_PATH/gradlew build
cp $PROJECT_PATH/build/libs/*.jar /home/ec2-user/build/
$PROJECT_PATH/scripts/deploy.sh