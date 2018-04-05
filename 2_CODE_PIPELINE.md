# 2. AWS Code Pipeline으로 배포하기

[지난 시간](http://jojoldu.tistory.com/281)에 Code Deploy에 대해 설명드렸습니다.  

Code Deploy는 특정 인스턴스 혹은 IDC 서버에 배포하는 것외에, Auto Scaling Group (이하 **ASG**라고 하겠습니다.) 으로 배포할 수도 있습니다.  
즉, Code Deploy를 이용한다면 AWS CLI로 모든 인스턴스 주소를 다 찾아내서 배포하지 않아도 된다는 이야기입니다.  
그래서 EC2 혹은 ASG를 사용하는 곳에선 아래와 같은 형태로 배포 프로세스를 사용합니다.  


![아키텍처1](./images/codepipeline/아키텍처1.png)

Code Deploy에서 배포할 파일을 가져오는 방법은 2가지가 있습니다.  

* Github
* S3


