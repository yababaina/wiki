---
title: exec
---

# exec

현재 실행 중인 프로세스 이미지를 새로운 프로세스 이미지로 교체하기 위해 사용한다. 
프로세스 이미지가 교체되면 프로세스 실행 코드는 교체되지만 기본적인 프로세스 정보는 유지된다.

**유지되는 프로세스 정보**
- PID
- PPID
- FD 등

# exec 계열 함수 종류

```c
int execl(const char *path, const char *arg, ...);
int execlp(const char *file, const char *arg, ...);
int execle(const char *path, const char *arg, ..., char * const envp[]);

int execv(const char *path, char *const argv[]);
int execvp(const char *file, char *const argv[]);
int execve(const char *path, char *const argv[], char * const envp[]);
```
- 첫 번째 인수명이 `path`인 경우 디렉터리를 입력
- 첫 번째 인수명이 `file`인 경우 PATH 환경변수를 입력
    - 위 두 사항은 `posix_spawn` 에서도 동일함
- `execl~`로 시작하는 함수는 실행할 파일의 인수 목록을 가변 인수 리스트로 받음
- `execv~`로 시작하는 함수는 실행할 파일의 인수 목록을 벡터로 받음
- `exec`로 프로세스 이미지를 교체하면 이후로는 기존 코드가 실행되지 않음

# close-on-exec

기본적으로 `exec`은 부모 프로세스의 파일 기술자를 복제한다.
하지만 부모 프로세스가 `fork`하기 전 특정 파일기술자에 `fcntl`로 `FD_CLOEXEC` 플래그를 지정하면 `exec` 시 해당 파일기술자는 닫힌다.

## 예시

```c
int ret_fcntl;
if ((ret_fcntl = fcntl(fd, F_SETFD, FD_CLOEXEC)) == -1) {
    perror("FAIL: fcntl(F_SETFD, FD_CLOEXEC)");
    exit(EXIT_FAILURE);
}

```

# 참고: system 함수

`system` 함수는 셸을 실행시켜서 명령어를 실행하는 기능으로서 `fork-exec`을 간단하게 구현한 형태이다.

```c
system("ls -al")
```

`system`은 실행 명령어가 작동되는 동안에 부모 프로세스가 잠시 정지된다.
자식 프로세스 정지, 종료 상태를 통보해 주는 `SIGCHID` 시그널도 블록되고, 종료 시그널인 `SIGINT`, `SIGQUIT`도 무시되므로 가급적 사용하지 않는게 좋다.