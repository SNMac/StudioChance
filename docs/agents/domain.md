# 도메인 문서

엔지니어링 스킬이 코드베이스를 탐색할 때 이 저장소의 도메인 문서를 어떻게 읽을지 정한다.

## 탐색 전에 읽을 것

- 저장소 루트의 **`CONTEXT.md`**, 또는
- 저장소 루트에 **`CONTEXT-MAP.md`** 가 있으면 그 파일: 컨텍스트마다 `CONTEXT.md`를 하나씩 가리킨다. 주제와 관련된 것을 모두 읽는다.
- **`docs/adr/`**: 작업하려는 영역에 걸친 ADR을 읽는다. 멀티 컨텍스트 저장소라면 컨텍스트 범위의 결정이 담긴 `src/<context>/docs/adr/`도 확인한다.

이 파일들이 없으면 **아무 말 없이 진행한다.** 없다는 사실을 지적하지 말고, 미리 만들자고 제안하지도 않는다. `/domain-modeling` 스킬(`/grill-with-docs`, `/improve-codebase-architecture`에서 이어짐)이 용어나 결정이 실제로 확정될 때 필요한 만큼 만든다.

## 파일 구조

싱글 컨텍스트 저장소(대부분의 저장소):

```
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── src/
```

멀티 컨텍스트 저장소(루트에 `CONTEXT-MAP.md`가 있음):

```
/
├── CONTEXT-MAP.md
├── docs/adr/                          ← 시스템 전체 결정
└── src/
    ├── ordering/
    │   ├── CONTEXT.md
    │   └── docs/adr/                  ← 컨텍스트별 결정
    └── billing/
        ├── CONTEXT.md
        └── docs/adr/
```

## 용어집의 어휘를 쓸 것

결과물에서 도메인 개념을 가리킬 때(이슈 제목, 리팩터링 제안, 가설, 테스트 이름 등) `CONTEXT.md`에 정의된 용어를 그대로 쓴다. 용어집이 명시적으로 피하는 동의어로 바꿔 쓰지 않는다.

필요한 개념이 용어집에 없다면 신호로 받아들인다. 프로젝트가 쓰지 않는 말을 지어내고 있거나(다시 생각할 것), 실제로 빠진 용어다(`/domain-modeling`용으로 기록해 둘 것).

## ADR 충돌 표시

결과물이 기존 ADR과 어긋나면 조용히 덮어쓰지 말고 명시적으로 드러낸다.

> _ADR-0007(event-sourced orders)과 충돌하지만, 다음 이유로 다시 논의할 가치가 있다…_

## 기존 설계 결정

`docs/adr/`가 생기기 전의 아키텍처 결정은 CLAUDE.md `## 아키텍처 설계 결정` 섹션에 D2~D11로 기록되어 있다.
ADR과 같은 무게로 취급하고, 충돌하면 위의 "ADR 충돌 표시" 규칙을 따른다.
