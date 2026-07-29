---
title: 00-etc
---

# 특정 함수 헤더 파일 찾기

특정 함수에 대해 필요한 헤더 파일을 알고 싶다면 `man <함수명>` 명령 실행 후 `SYNOPSIS` 섹션을 확인한다.

### 예시 (`inet_ntoa`)

<details>
<summary><code>inet_ntoa man page</code></summary>

```shell
inet(3)                                        Library Functions Manual                                       inet(3)

NAME
    inet_aton, inet_addr, inet_network, inet_ntoa, inet_makeaddr, inet_lnaof, inet_netof - Internet address manip‐
    ulation routines

LIBRARY
    Standard C library (libc, -lc)

SYNOPSIS
    #include <sys/socket.h>
    #include <netinet/in.h>
    #include <arpa/inet.h>

    int inet_aton(const char *cp, struct in_addr *inp);

    in_addr_t inet_addr(const char *cp);
    in_addr_t inet_network(const char *cp);

    [[deprecated]] char *inet_ntoa(struct in_addr in);

    [[deprecated]] struct in_addr inet_makeaddr(in_addr_t net,
                                                in_addr_t host);

    [[deprecated]] in_addr_t inet_lnaof(struct in_addr in);
    [[deprecated]] in_addr_t inet_netof(struct in_addr in);

Feature Test Macro Requirements for glibc (see feature_test_macros(7)):

Manual page inet_ntoa(3) line 1 (press h for help or q to quit)
```
</details>

# Feature test macro와 표준 

