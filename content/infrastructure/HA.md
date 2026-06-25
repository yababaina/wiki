---
title: HA
---

분류: [[infrastructure/index]]

# 개념

`HA`(High Availability, 고가용성)란 서버, 네트워크, 스토리지 등 시스템의 일부 구성 요소에 장애가 발생하더라도, 전체 시스템은 중단을 최소화하여 지속적으로 정상 운영될 수 있도록 보장하는 성질을 의미한다.

**[[#가용성|가용성]]이 높은 서비스를 가리켜 고가용성의 서비스라고 이야기한다.**

## 가용성 

가용성이란 서비스 운영 중 서비스가 정상적으로 동작하는 비율이 얼마나 되는지 시간 측면 관점으로 설명하는 지표이다. 
즉, 시스템의 신뢰도를 평가할 때 사용되는 중요한 지표이다.

예를 들어 100일을 운영한 서비스가 총 1일간 제대로 동작하지 않았다면, 이 서비스의 가용성은 99%이다.
이를 수식으로 나타내면 아래와 같다.

`Availability` = [ `MTBF` / (`MTBF` + `MTTR`) ] * 100

- `MTBF`(Mean Time Between Failures): 평균 무고장 시간
- `MTTR`(Mean Time To Repair): 평균 수리 시간

가용성은 시스템이 고장 나지 않고 버티는 시간인 `MTBF`를 극대화하고, 장애 발생 시 복구에 걸리는 시간인 `MTTR`을 최소화함으로써 달성된다.

![[infrastructure/img/HA_percentage.png]]

가용한 시간은 일반적으로 9s(nines)라는 표현 방식을 사용한다. 
가장 이상적인 목표인 '파이브 나인스(99.999%)'는 연간 다운 타임이 단 5분 15초 이내임을 의미한다.

# HA vs Fault Tolerance, DR

- `HA`: 구성 요소 장애 시 다운타임을 최소화하고 서비스 연속성 유지
- `Fault Tolerance`: 일부 구성 요소가 고장 나도 서비스 중단 없이 동작
- `DR`(Disaster Recovery): 데이터센터 전체, 가용 영역, 리전, 대규모 데이터 손상 등 광범위한 재해 후 서비스 / 데이터 복구

# HA 설계가 필요한 이유

하드웨어 / 소프트웨어 / 네트워크는 언젠가 장애가 발생할 수 있다는 전제 위에서 시스템을 설계한다.
단일 서버 / 단일 경로 / 단일 스토리지만으로 서비스를 운영하면, 작은 장애 하나가 전체 서비스 중단으로 이어질 수 있다.
이런 부분 장애가 발생해도 서비스가 계속 제공되도록, 중복 구성과 자동 전환으로 [[#가용성|MTTR]]을 줄이기 위해 HA 설계가 필요하다.

## SPOF (Single Point of Failure, 단일 장애점)

`SPOF`란 해당 구성 요소 하나에 장애가 발생했을 때 시스템 전체 또는 핵심 서비스가 이용 불가가 되는 지점을 말한다.

![[infrastructure/img/spof.png]]

위 그림에서 `SPOF`는 모든 지점이다. 
웹 서버에 장애가 나면, 클라이언트의 요청이 WAS로 도달할 수 없다. WAS, Database도 마찬가지로 장애가 발생하면 모든 서비스가 이용 불능이 된다. 즉, 가용성이 떨어질 확률이 굉장히 많다.

`SPOF`가 많다는 것은 곧 낮은 가용성의 서비스일 가능성이 높다는 의미이다. 
그렇기 때문에 HA 설계를 할 때 `SPOF`를 제거하는 것이 중요하다.

`SPOF`를 줄이는 대표적인 방법은 동일 역할의 구성 요소를 2개 이상 두고, 장애 시 다른 쪽으로 [[#Failover|failover]] 하거나 [[#Load Balancing|로드 밸런싱]]으로 부하를 나누는 것이다. 

# HA 아키텍처

## 공통 메커니즘

HA 클러스터 / 이중화 구성에서 반복적으로 등장하는 기술 요소이다.
[[#구성 패턴|구성 패턴]]은 아래 메커니즘을 어떻게 배치 및 연결하느냐의 차이로 이해할 수 있다.

### Health Check

노드 / 프로세스 / 포트 / HTTP 응답 등이 정상인지 주기적으로 확인하는 기능이다.
장애를 감지하지 못하면 `failover`나 로드 밸런서의 트래픽 전환이 실행되지 않는다.
HA의 출발점이며, 로드 밸런서 / 오케스트레이터(Kubernetes 등) / 클러스터 매니저가 공통으로 사용한다.

### Heartbeat

클러스터를 구성하는 노드들이 서로 생존 여부를 주기적으로 알리는 신호이다.
한 노드의 heartbeat가 끊기면 다른 노드가 장애로 판단하고 후속 조치(failover 등)를 수행한다.
전용 heartbeat 네트워크를 두거나, 공유 스토리지 / [[#Quorum (쿼럼 / 정족수 투표)|quorum]] 경로와 함께 쓰기도 한다.

### Failover

Active 노드 / 경로에 장애가 감지되면 Standby 또는 다른 healthy 노드로 역할 / 트래픽을 넘기는 동작이며 `MTTR`을 줄이는 핵심 수단이다.
전환 시 짧은 서비스 중단이 발생할 수 있으며, 그 길이는 구성 패턴과 데이터 동기화 방식에 따라 달라진다.

### Virtual IP (VIP, 가상 IP)

클라이언트가 접속하는 서비스 IP를 물리 노드와 분리해 두는 방식이다.
`failover` 시 VIP(및 관련 MAC/ARP)가 새 Active 노드로 이동하므로, 클라이언트는 동일 IP로 계속 접속한다.
방화벽 / L4 스위치 / Keepalived / Pacemaker 등 [[#Active - Standby (Active - Passive)|Active-Standby]] 구성에서 자주 사용한다.

### Replication

노드 간 데이터 / 상태를 동기화하는 기능이다.
Standby가 Active를 대신할 때 데이터 불일치 / 유실을 막기 위해 필요하다.
동기 복제는 `RPO(Recovery Point Objective, 복구 시점 목표)`에 유리하지만 지연 / 성능 부담이 있고, 비동기 복제는 성능은 나으나 전환 시 일부 데이터 손실 가능성이 있다. 

### Load Balancing

여러 healthy 노드에 트래픽을 분산한다.
단일 노드 과부하 / 장애 확산을 줄이고, unhealthy 노드를 풀에서 제외할 수 있다.
`failover`와는 목적이 다르지만, [[#Active - Active|Active-Active]] 패턴의 핵심 요소이다.
로드 밸런서 자체도 `SPOF`가 될 수 있으므로 LB 이중화를 함께 검토한다.

### 정리

| 메커니즘 | 역할 | SPOF 해결과의 관계 |
|----------|------|---------------------|
| Health Check | 장애 감지 | failover·LB 전환의 전제 |
| Heartbeat | 노드 생존 확인 | 클러스터 장애 판단 |
| Failover | 역할·경로 전환 | Standby로 SPOF 완화 |
| VIP | 접속 주소 고정 | 전환 시 클라이언트 재설정 최소화 |
| Replication | 데이터 동기화 | 전환 후에도 데이터 일관성 |
| Load Balancing | 트래픽 분산 | 다중 노드로 SPOF 제거 + 부하 분산 |

## 구성 패턴

위 메커니즘을 노드 역할과 트래픽 처리 방식에 따라 묶은 대표적인 HA 형태이다.

### Active - Standby (Active - Passive)

![[infrastructure/img/failover.png]]

- `Active(Primary)` 1대만 실제 트래픽 / 쓰기를 처리하고, `Standby(Secondary)`는 대기한다.
- `Active` 장애 시 `Standby`가 VIP를 인수하거나 `Active` 역할로 `failover` 한다.
- Heartbeat + VIP + Replication 조합이 흔하다.
- `Standby`가 idle이므로 비용 대비 단순하지만, `failover` 동안 짧은 중단이 있을 수 있다.

### Active - Active

![[infrastructure/img/health-check.png]]

- 모든 노드가 동시에 트래픽을 처리한다.
- 앞단 Load Balancer + [[#Health Check|Health Check]]로 장애 노드를 제외하고 나머지가 부하를 흡수한다.
- 한 노드 장애 시에도 서비스 중단 없이 용량만 줄어드는 형태가 많다.
- 데이터 동기화 / 충돌 처리가 필요해 Standby보다 설계 / 운영 복잡도가 높다. 

### N + 1

- 정상 부하를 처리하는 데 N대가 필요할 때, 1대를 예비로 둔다.
- N대 중 1대가 장애가 나도 나머지 N대가 부하를 감당한다.
- Active - Active에 가깝지만, 예비 1대는 평상시 idle 또는 경량 부하일 수 있다.
- 비용과 가용성의 중간 지점으로 자주 쓰인다.

# HA의 리스크 - 스플릿 브레인(Split-Brain)

스플릿 브레인은 두 노드가 물리적으로는 모두 멀쩡하지만, 그 사이를 잇는 Heartbeat 네트워크 라인만 단절되었을 때 발생하는 리스크이다. 

Node B(Standby)는 Node A가 죽었다고 오판하며 스스로를 Active로 승격하고, 원래 살아 있던 Node A도 계속 자신이 Active라고 우기는 `Dual Active` 상태가 된다. 
이 상태에서 양쪽 노드가 공유 스토리지(DB)에 동시 쓰기(Write)를 시도하면, 데이터 베이스의 정합성이 영구적으로 파괴된다.

## 스플릿 브레인 방어 메커니즘

### Quorum (쿼럼 / 정족수 투표)

노드를 2개가 아닌 홀수 노드 또는 외부의 투표용 노드를 둔다.
네트워크가 단절되었을 때, 다수결의 원칙(과반수 쿼럼)을 확보한 노드 그룹만 살아남고, 과반을 잃은 노드는 스스로를 차단하여 시스템을 보호한다.

### STONITH (Shoot The Other Node In The Head)

자신이 Active가 될 때, 상대방 노드가 살아있을 일말의 가능성조차 배제하기 위해 `PDU`(원격 전원 제어 장치)를 통해 상대방 서버의 전원을 물리적으로 강제 차단(Fencing)시켜버리는 가장 확실한 수단이다.

## 참고

### 입문 글

- [고가용성(HA)과 재해복구(DR) 설계 전략 정리](https://imt-log.tistory.com/entry/arch-ha) — MTBF/MTTR, 나인, Active-Active/Standby, RTO/RPO
- [고가용성을 확보하기 위한 아키텍처 설계](https://hudi.blog/high-availability-architecture/) — SPOF, Five Nines, 로드 밸런서
- [High Availability](https://velog.io/@agnusdei1207/High-Availability) — HA 정의, DR·Fault Tolerance 비교, 클러스터링
- [이해하기: 가용성과 고가용성](https://www.stevenjlee.net/2020/06/28/%ec%9d%b4%ed%95%b4%ed%95%98%ea%b8%b0-%ea%b0%80%ec%9a%a9%ec%84%b1-availability-%ea%b3%bc-%ea%b3%a0%ea%b0%80%ec%9a%a9%ec%84%b1-high-availability/) — 가용성 수식, SPOF, 로드 밸런싱