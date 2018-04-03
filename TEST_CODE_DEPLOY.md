# Github & AWS Code Deploy 연동


![codedeploy1](./images/github/codedeploy1.png)

```yml
version: 0.0
os: linux
files:
  - source:  /
    destination: /home/ec2-user/build/
```


![codedeploy2](./images/github/codedeploy2.png)

CodeDeploy 로그 확인

```bash
cd /var/log/aws/codedeploy-agent
```

![codedeploy3](./images/github/codedeploy3.png)

![codedeploy4](./images/github/codedeploy4.png)

![codedeploy5](./images/github/codedeploy5.png)

![codedeploy6](./images/github/codedeploy6.png)

![codedeploy7](./images/github/codedeploy7.png)

![codedeploy8](./images/github/codedeploy8.png)

![codedeploy9](./images/github/codedeploy9.png)

![codedeploy10](./images/github/codedeploy10.png)

![codedeploy11](./images/github/codedeploy11.png)

![codedeploy12](./images/github/codedeploy12.png)

## CloudWatch로 CodeDeploy 로그 전송

```bash
wget https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py
wget https://s3.amazonaws.com/aws-codedeploy-us-east-1/cloudwatch/codedeploy_logs.conf
chmod +x ./awslogs-agent-setup.py
sudo python awslogs-agent-setup.py -n -r ap-northeast-2 -c s3://aws-codedeploy-us-east-1/cloudwatch/awslogs.conf
sudo mkdir -p /var/awslogs/etc/config
sudo cp codedeploy_logs.conf /var/awslogs/etc/config/
```

log 그룹을 변경하겠습니다.

```bash
sudo vim /var/awslogs/etc/config/codedeploy_logs.conf
```

```bash
[codedeploy-agent-logs]
datetime_format = %Y-%m-%d %H:%M:%S
file = /var/log/aws/codedeploy-agent/codedeploy-agent.log
log_stream_name = {instance_id}-codedeploy-agent-log
log_group_name = dwlee-codedeploy-agent-log

[codedeploy-updater-logs]
file = /tmp/codedeploy-agent.update.log
log_stream_name = {instance_id}-codedeploy-updater-log
log_group_name = dwlee-codedeploy-updater-log

[codedeploy-deployment-logs]
file = /opt/codedeploy-agent/deployment-root/deployment-logs/codedeploy-agent-deployments.log
log_stream_name = {instance_id}-codedeploy-deployments-log
log_group_name = dwlee-codedeploy-deployments-log
```

```bash
sudo service awslogs restart
```

