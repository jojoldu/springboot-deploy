# 3. AWS Code Pipeline으로 배포하기

[지난 시간](http://jojoldu.tistory.com/281)에 Code Deploy 사용하는 방법에 대해 설명드렸습니다.  
  


## 3-1. Code Pipeline 구축하기

먼저 Code Pipeline 웹콘솔로 이동합니다.  
**파이프라인 생성**버튼을 클릭합니다.

![codepipeline3](./images/codepipeline/codepipeline3.png)

Code Pipeline 이름을 등록합니다.

![codepipeline4](./images/codepipeline/codepipeline4.png)

소스를 Github에 가져오도록 선택하고, **Github에 연결**을 클릭합니다.

![codepipeline5-1](./images/codepipeline/codepipeline5-1.png)

OAuth 리다이렉트가 끝나면 리포지토리와 브랜치를 선택합니다.

![codepipeline5-2](./images/codepipeline/codepipeline5-2.png)

여기서 고급을 보면 실행 트리거가 2개가 있습니다.  

* master 브랜치에 PUSH 발생시 자동 실행
* 파이프라인 수동 실행

이번 포스팅에선 **수동 실행**을 선택하겠습니다.  

![codepipeline6](./images/codepipeline/codepipeline6.png)

기존에 등록한 Code Deploy를 선택합니다.

![codepipeline7](./images/codepipeline/codepipeline7.png)

Code Build와 마찬가지로 필요한 IAM Role을 여기서 바로 생성하겠습니다.

![codepipeline8](./images/codepipeline/codepipeline8.png)

![codepipeline9](./images/codepipeline/codepipeline9.png)

IAM Role 생성이 끝나면 자동으로 등록됩니다.

![codepipeline10](./images/codepipeline/codepipeline10.png)

최종적으로 본인이 지정한 스펙을 검토하신뒤 생성합니다.

![codepipeline11](./images/codepipeline/codepipeline11.png)

![codepipeline12](./images/codepipeline/codepipeline12.png)

배포하기 전에 Code Deploy로 채워진 ```~/build/``` 디렉토리를 싹 비우겠습니다.

```bash
sudo rm -rf ~/build/*
```

![codepipeline13](./images/codepipeline/codepipeline13.png)

