---
title: NAT
---

분류: [[network/index]]

## NAT란?

![[network/img/NAT.png]]

**NAT(Network Address Translation, 네트워크 주소 변환)** 은 IP 패킷의 **출발지(Source) 또는 목적지(Destination) IP·포트**를 다른 값으로 바꿔 전달하는 기술이다.

주로 다음 목적으로 사용한다.

- **사설 IP → 공인 IP 변환**: 내부 PC가 인터넷에 나갈 때
- **공인 IP → 사설 IP 변환**: 외부에서 내부 서버(웹, DB 등)로 접속할 때
- **주소 재매핑**: 네트워크 구간이 겹치거나 주소 체계를 바꿀 때

NAT는 보통 **라우터, 방화벽, 일부 L3 스위치, Linux(ip/nftables)** 에서 수행한다. 

## NAT가 동작하는 위치

