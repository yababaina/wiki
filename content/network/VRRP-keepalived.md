---
title: VRRP
---

분류: [[network/index]]
[[tools/keepalived]] 연결 필요

# 개념

`VRRP`(Virtual Router Redundancy Protocol)란 동일 서브넷에 있는 2대 이상의 라우터(또는 Linux 호스트)가 하나의 가상 라우터처럼 동작하도록, `VIP`를 공유하고 장애 시 자동으로 역할을 넘기는 L3 이중화 프로토콜이다. (RFC 5798)

클라이언트는 물리 노드 IP가 아니라 `VIP`로 접속하고, Active 노드에 장애가 나면 `Standby`가 `VIP`를 인수한다. 
이는 [[infrastructure/HA#Virtual IP (VIP, 가상 IP)|VIP + Failover]] 패턴의 네트워크 계층 구현에 해당하며, 전체 HA 설계 맥락은 [[infrastructure/HA]] 문서에 서술되어 있다.

게이트웨이, L4/L7 진입점, 방화벽 이중화 등 단일 IP로 서비스를 노출해야 하는 구간에서 `SPOF`를 줄이기 위해 자주 사용한다. 

# 관련 용어 설명

| 용어 | 의미 |
| -------- | -------- |
| `VIP`(Virtual IP) | 클라이언트 / 상위 장비가 접속하는 공통 서비스 IP를 뜻하며 한 시점에 `Active` 1대만 소유함 |
| `RIP`(Real IP) | 각 노드에 실제로 붙어 있는 물리 IP를 뜻하며 VRRP 통신 / 관리용 |
| `Active` | `VIP`를 인터페이스에 붙이고 트래픽을 처리하며 주기적으로 `VRRP Advertisement` 전송 |
| `Standby` | `Active`의 광고를 수신하며 대기하며 `Active` 장애 시 승격됨 |
프로토콜 개념 서술
장비 이중화

- VIP
- RIP
- Fail over
- Health Check
- Master / Slave 장비
- HA 설계 - infrastructure/HA 와 연결
- VRRP와 비슷한 다른 프로토콜 (HSRP, GLBP, FHRP)

# 사용 툴
- keepalived
[[tools/keepalived]] 연결 필요


참고한 글
https://lascrea.tistory.com/211
https://limvo.tistory.com/13