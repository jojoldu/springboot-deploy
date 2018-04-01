# AWS Auto Scaling

 
## 1. EC2 인스턴스 생성


### 1-1. Java8 설치

EC2 인스턴스로 ssh 접속후 다음의 명령어를 실행합니다.

```bash
sudo yum update
sudo yum install -y java-1.8.0-openjdk-devel.x86_64
sudo /usr/sbin/alternatives --config java
sudo yum remove java-1.7.0-openjdk
java -version
```

![1](./images/autoscaling/1.png)

git을 설치합니다.

```bash
sudo yum install git
git --version
```

```bash
mkdir ~/app/
mkdir ~/build/
```

여기서 ```~/app/```은 초기 인스턴스가 생성시 가장 최신의 프로젝트를 Git에서 받아서 저장할 디렉토리입니다.  
그리고 ```~/build/```은 CodeDeploy 를 통해서 배포용 파일들을 받을 디렉토리입니다.
이외에 필요한 것들이 더 있으시면 설치하시면 됩니다.  

### 1-2. Code Deploy Agent 설치

#### 그룹 생성

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:*",
                "codedeploy:*",
                "ec2:*",
                "lambda:*",
                "elasticloadbalancing:*",
                "s3:*",
                "cloudwatch:*",
                "logs:*",
                "sns:*"
            ],
            "Resource": "*"
        }
    ]
}
```

#### 사용자 추가

![사용자1](./images/autoscaling/사용자1.png)

![사용자2](./images/autoscaling/사용자2.png)

#### EC2에 Code Deploy Agent 설치

```bash
sudo yum install -y aws-cli
```

```bash
cd /home/ec2-user/ 
sudo aws configure
```

![agent1](./images/autoscaling/agent1.png)

* Access Key
* Secret Access Key
* region name
  * ap-northeast-2
  * 서울 리전을 얘기합니다.
* output format
  * json


설치파일 받기

```bash
wget https://aws-codedeploy-ap-northeast-2.s3.amazonaws.com/latest/install
```

```bash
chmod +x ./install
```

```bash
sudo ./install auto
```

설치가 완료되셨으면 아래 명령어로 Agent가 실행중인지 확인합니다.

```bash
sudo service codedeploy-agent status
```

마지막으로 EC2 인스턴스가 부팅되면 자동으로 AWS CodeDeploy Agent가 실행될 수 있도록 /etc/init.d/에 쉘 스크립트 파일을 하나 생성하겠습니다.

```bash
sudo vim /etc/init.d/codedeploy-startup.sh
```

```bash
#!/bin/bash 
echo 'Starting codedeploy-agent' 
sudo service codedeploy-agent start
```

### 1-3. Cloud Watch 세팅


## 2. AMI 생성

![2](./images/autoscaling/2.png)

![3](./images/autoscaling/3.png)

![4](./images/autoscaling/4.png)

![5](./images/autoscaling/5.png)

pending이 avaliable로 변경되면 이미지 생성이 완료된 것입니다.

## 3. Auto Scaling Group에서 Launch Configuration 생성

사용자 데이터

```bash
#!/bin/bash

cd /home/ec2-user
git clone https://github.com/jojoldu/springboot-deploy.git
cd springboot-deploy
./gradlew build
cp /home/ec2-user/springboot-deploy/build/libs/*.jar /home/ec2-user/build/
chown ec2-user:ec2-user /home/ec2-user/build/*.jar
su ec2-user ./scripts/deploy.sh
```

개선

```bash
#!/bin/bash

cd /home/ec2-user
su ec2-user git clone https://github.com/jojoldu/springboot-deploy.git
su ec2-user /home/ec2-user/springboot-deploy/scripts/init.sh
```

```bash
#!/bin/bash
./gradlew build
cp /home/ec2-user/springboot-deploy/build/libs/*.jar /home/ec2-user/build/
./deploy.sh
```


## CodePipeline CloudWatch Alarm

```json
{
  "source": [
    "aws.codepipeline"
  ],
  "detail-type": [
    "CodePipeline Action Execution State Change"
  ],
  "detail": {
    "state": [
      "FAILED"
    ],
    "type": {
      "category": [
        "Deploy",
        "Build"
      ]
    }
  }
}
```


## 알게된 것들

### 팁

* appspec.yml -> hooks에 실행시킬 스크립트 안에서 다시 다른 스크립트를 실행하면 CodeDeploy의 로그가 남겨지지 않는다


### 로그 위치

