#!/bin/bash
CURRENT_PATH=$(pwd)
DEPLOY_SCRIPT=$CURRENT_PATH/deploy.sh

## 실행권한 추가
chmod +x $DEPLOY_SCRIPT

## 스크립트 실행
$DEPLOY_SCRIPT > /home/ec2-user/deploy.log