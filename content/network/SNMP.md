---
title: SNMP
---

분류: [[network/index]]

# 개념

`SNMP`(*Simple Network Management Protocol*)란 IP 기반 네트워크 상의 각 호스트로부터 정기적으로 여러 관리 정보를 자동으로 수집하거나 실시간으로 상태를 모니터링 및 설정할 수 있는 **프로토콜**이다.

시스템이나 네트워크 관리자로 하여금 원격으로 네트워크 장비를 모니터링하고 환경설정 등의 운영을 할 수 있도록 한다.

OSI `Application` 계층이며 `UDP` 프로토콜을 사용한다.

# 구성

기본적으로 `Manager`, `Agent`로 나뉜다.

`Manager`는 `Agent`에 필요한 정보를 요청하는 모듈이며 Listen 포트는 `162/UDP`를 사용한다.
`Polling` 방식을 사용하며 `Agent`의 `161/UDP` 포트로 정보를 요청한다.

`Agent`는 관리 대상 시스템에 설치되어 필요한 정보를 [[#MIB (Management Information Base)|MIB]] 형태로 수집하고 `Manager`에게 전달해 주는 모듈이다.
이벤트 발생 시 이를 `Manager` `162/UDP` 포트로 알리는 `Event Reporting` 방식을 사용한다.
Listen 포트는 `161/UDP`를 사용한다.

# 동작

![[network/img/SNMP.png]]

`Manager`와 `Agent`가 통신하기에 앞서, 최소 다음 3가지 사항이 일치해야 한다.

- SNMP 버전
- `Community String` (SNMP `v1`/`v2c`인 경우)
- [[#PDU 종류|PDU]](Protocol Data Unit)

# PDU 종류

PDU 종류는 다음과 같다.

## Manager -> Agent

- `Get Request`: Manager가 Agent로 원하는 객체의 특정 정보를 요청한다.
- `Get Next Request`: Manager가 Agent로 이미 요청한 정보의 다음 정보를 요청한다.
- `GetBulk Request`(`v2c+`): 대량의 데이터가 필요한 경우 `Get Next Request` 반복 대신 대량으로 조회한다.
- `Set Request`: Manager가 Agent로 특정한 값을 설정하기 위해 사용한다.

## Agent -> Manager

- `Get Response`: Manager가 요청한 정보를 전송한다.
- `Trap`: Agent가 Manager에 어떤 정보를 알리기 위해 사용하며, `notify`라고도 한다.
- `Inform`(`v2c+`): `Trap` + Manager 확인 응답을 받아 일반 `Trap`보다 신뢰성을 높다.

`Trap`은 비동기로 동작하며, `Trap` 제외 모든 PDU는 동기적으로 동작한다.

# 버전 별 특징

SNMP는 `v1` → `v2c` → `v3` 순으로 발전했으며, **보안 모델**과 **지원 PDU**가 가장 큰 차이이다.
실무에서는 **`v2c`(레거시)** 와 **`v3`(보안 권장)** 가 주로 쓰인다.

## SNMP v1

- `RFC 1157` 기반의 최초 버전
- `Community String`(`public`, `private` 등)으로 접근 제어 가능하지만 평문 전송이라 보안에 취약함
- PDU: `Get`, `GetNext`, `Set`, `GetResponse`, `Trap`
- 32비트 카운터 등 데이터 타입 / 기능이 제한적
- 오래된 장비 / 프린터 등 레거시 환경에서 볼 수 있음

## SNMP v2

- SNMP `v2p` (Party 기반 보안) 등 초기 `v2`는 표준은 있으나 실무 도입이 거의 없음
- 기능은 `v2c`와 비슷하지만 Community 기반 `v2c`가 사실상 `v2`의 역할을 대신함
- 문서에서 `v2`만 언급할 때는 `v2c`를 의미하는 경우가 많음

## SNMP v2c

- `Community String` 방식은 `v1`과 같고, 기능만 `v2` 수준으로 확장된 버전
- `GetBulk`, `Inform` PDU 지원
- 64비트 카운터 등으로 대용량 트래픽 통계 수집에 유리
- `Community String`이 평문이므로, 보안이 중요한 구간에서는 `v3` 사용 권장

## SNMP v3

- `Community String`을 사용하지 않고 `Username` + 보안 레벨로 접근 제어
- `USM`(User-based Security Model): 인증 / 암호화 정책 정의
- `VACM`(View-based Access Control Model): [[#OID (Object Identifier)|OID]] 단위 읽기 / 쓰기 권한 제어
- 보안 레벨
  - `noAuthNoPriv`: 인증 / 암호화 없음
  - `authNoPriv`: 인증만
  - `authPriv`: 인증 + 암호화
- `v1`/`v2c` 대비 DoS / 스니핑 / 비인가 설정 변경 위험을 크게 줄일 수 있음

# MIB / SMI / OID
SNMP로 주고받는 정보는 객체 단위로 정의되며, 이들의 집합 / 규칙을 `MIB` / `OID` / `SMI`로 표현한다.

## MIB (Management Information Base)

- Agent가 관리하는 객체들의 논리적 DB
- 각 객체는 트리 구조로 배치됨
- Manager는 `Get` / `Set` 사용 시 특정 OID를 지정해 값을 읽거나 씀
- 예: CPU 사용률, 인터페이스 트래픽, 시스템 가동 시간 등

### MIB 예시

| MIB | 용도 |
| ----- | ----- |
| `IF-MIB` | 인터페이스 트래픽, up / down 상태 |
| `HOST-RESOURCES-MIB` | CPU, 메모리, 디스크 |
| `SNMPv2-MIB` (`system` 그룹) | 호스트명, uptime, `sysContact` 등 |

## SMI (Structure of Management Information)
- MIB에 어떤 객체를 어떤 타입 / 속성으로 정의할지 정하는 규칙
- 객체 속성 예: 이름, 문법, `access`(`read-only` / `read-write`), `status`
- `SMIv1`(`RFC 1155`), `SMIv2`(`RFC 2578`)
  - `v2c` / `v3` 환경에서는 `SMIv2`가 일반적
- 데이터 표기는 `ASN.1`, 실제 전송 시에는 `BER` 인코딩으로 직렬화

## OID (Object Identifier)
- MIB 트리에서 객체 하나를 가리키는 고유 경로 (점으로 구분된 숫자열)
- 예: `1.3.6.1.2.1.1.1.0` → `sysDescr` (시스템 설명) 인스턴스

## 참고

### 입문 글

- [SNMP란?](https://itragdoll.tistory.com/43) — Manager/Agent, PDU, MIB 등 개념 정리 참고

### 표준 문서

- [RFC 1157 — SNMPv1](https://www.rfc-editor.org/rfc/rfc1157)
- [RFC 3410 — SNMPv3 소개](https://www.rfc-editor.org/rfc/rfc3410)
- [RFC 2578 — SMIv2](https://www.rfc-editor.org/rfc/rfc2578)