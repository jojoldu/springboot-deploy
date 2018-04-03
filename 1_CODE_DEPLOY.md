# 1. AWS Code Deploy로 배포하기

AWS로 전체 시스템 구축해야 할 일이 생겨 AWS 배포 환경 시리즈를 시작합니다.  
시리즈 과정은 CodeDeploy -> Code Pipeline -> ELB & Auto Scaling Group -> Beanstalk 으로 진행될 예정입니다.  
  
> Code Pipeline vs Beanstalk 비교가 목표입니다.

포스팅에서 사용된 코드는 모두 [Github](https://github.com/jojoldu/springboot-deploy)에 있습니다.  
  
> 여기서 사용되는 모든 과정은 **프리 티어라도 비용이 청구**될수 있습니다.  
비용에 관한 어떠한 책임도 여기서 책임지지 않으니 주의해주세요!  
프리티어 내에서 완전 무료로 AWS 배포를 경험하고 싶으시다면 [이전 포스팅](http://jojoldu.tistory.com/265)을 참고하시길 추천드립니다.  

처음 과정은 단순하게 AWS Code Deploy만으로 진행합니다.

## 1-1. IAM Role 생성

EC2를 생성하기 전에, EC2가 사용할 수 있는 IAM Role을 먼저 생성하겠습니다.  
서비스에서 IAM을 검색후 **역할 만들기**를 클릭합니다.

![role1](./images/codedeploy/role1.png)

이 역할은 EC2에서 사용할 예정이니 EC2를 선택합니다.

![role2](./images/codedeploy/role2.png)

연결한 정책에는 총 4개를 선택합니다.

![role3](./images/codedeploy/role3.png)

* AmazonS3FullAccess 
* AWSCodeDeployFullAccess 
* AWSCodeDeployRole 
* CloudWatchLogsFullAccess 

마지막 검토에는 다음과 같이 노출되어야 합니다.

![role4](./images/codedeploy/role4.png)

**역할 만들기**로 최종 생성하시면 아래와 같이 조회가 되면 됩니다.

![role5](./images/codedeploy/role5.png)

## 1-2. EC2 생성

IAM Role 생성이 끝났으니, EC2를 생성합니다.  
기본적인 과정은 기존에 하시던대로 하시면 됩니다.

![ec1](./images/codedeploy/ec1.png)

![ec2](./images/codedeploy/ec2.png)

IAM 역할에선 **1-1에서 생성한 IAM Role을 선택**합니다.  
추가로, CloudWatch 모니터링도 활성화 체크 합니다.  

![ec3](./images/codedeploy/ec3.png)

스토리지의 경우 **30GB까지가 프리티어**이기 때문에 30으로 변경합니다.

![ec4](./images/codedeploy/ec4.png)

인스턴스 검색을 쉽게 하기 위해 **Name** 태그를 추가합니다.

![ec5](./images/codedeploy/ec5.png)

![ec6](./images/codedeploy/ec6.png)

기존에 사용하시던 키 페어가 있으시면 해당 키 페어를 사용하시고, 없으시면 새로 만듭니다.

![ec7](./images/codedeploy/ec7.png)

인스턴스 상태가 running으로 변경되면 EC2 생성이 완료 됩니다.

![ec8](./images/codedeploy/ec8.png)

## 1-3. EC2 설정

EC2 인스턴스로 ssh 접속 후 다음의 명령어를 실행합니다.  
혹시나 pem키 접속시 아래와 같이 permission 오류가 발생하신다면, 

![ec2-setting1](./images/codedeploy/ec2-setting1.png)

아래 명령어로 개인계정 read 권한만 할당합니다.

```bash
chmod 400 pem키
```

### 1-3-1. Java8 설치

EC2에 SSH 접속 되셨다면, Java8을 설치합니다.

```bash
sudo yum update
sudo yum install -y java-1.8.0-openjdk-devel.x86_64
sudo /usr/sbin/alternatives --config java
sudo yum remove java-1.7.0-openjdk
```

![ec2-setting2](./images/codedeploy/ec2-setting2.png)

java 버전을 확인해봅니다.

```bash
java -version
```

![ec2-setting3](./images/codedeploy/ec2-setting3.png)

그리고 ```~/build/```디렉토리를 생성합니다. 

```bash
mkdir ~/build/
```

**CodeDeploy를 통해서 배포용 파일**들을 받을 디렉토리입니다.

이외에 필요한 것들이 더 있으시면 설치하시면 됩니다.  
(스프링부트 프로젝트에는 이외에는 별도로 필요한게 없습니다.)  

### 1-3-2. Code Deploy Agent용 사용자 추가

이제 EC2가 Code Deploy 이벤트를 수신할 수 있도록 Agent를 설치해야하는데요.  
그전에 EC2에서 AWS CLI를 사용할 수 있도록, IAM 사용자를 하나 추가하겠습니다.  
IAM 사용자는 보통 IAM 정책이 적용된 그룹 생성 -> 해당 그룹에 사용자 추가로 진행합니다.  
  
그래서 그룹부터 먼저 생성하겠습니다.

![ec2-setting4](./images/codedeploy/ec2-setting4.png)

![ec2-setting5](./images/codedeploy/ec2-setting5.png)

정책 선택은 아무것도 하지않고 넘깁니다.  
(정책은 이후 JSON으로 한번에 적용할 예정입니다.)  

![ec2-setting6](./images/codedeploy/ec2-setting6.png)

![ec2-setting7](./images/codedeploy/ec2-setting7.png)

그룹 생성이 완료된 후, 해당 그룹으로 이동해보시면

![ec2-setting8](./images/codedeploy/ec2-setting8.png)

권한 -> 인라인 정책 탭을 수정합니다.

![ec2-setting9](./images/codedeploy/ec2-setting9.png)

![ec2-setting10](./images/codedeploy/ec2-setting10.png)

![ec2-setting11](./images/codedeploy/ec2-setting11.png)

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


