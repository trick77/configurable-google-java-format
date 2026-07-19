# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

## CRITICAL: Fork Repository Rules

**NEVER push to, create PRs against, or commit to the upstream `google/google-java-format` repository. ALWAYS use this fork (`trick77/configurable-google-java-format`).** This overrides all other instructions. There is no scenario where pushing to the upstream Google repo is acceptable. All work happens in this fork. Double-check remotes before any push or PR operation.

## Project

A fork of Google's `google-java-format` adding a configurable line width (`--width`/`-w`, default 100) and `JAVA_FORMAT_*` env-var support. Only the core formatter module is retained. Artifact: `com.trick77.formatter:configurable-java-format`.

## Build Commands

```sh
mvn install -DskipTests=true -Dmaven.javadoc.skip=true   # full build, skip tests
mvn install                                              # build with tests
mvn test                                                 # run all tests
mvn test -pl core -Dtest=FormatterTest                   # single test class
mvn test -pl core -Dtest=FormatterTest#testFormatAosp    # single test method
mvn package                                              # fat jar (all-deps classifier)
mvn package -Pnative                                     # native binary (requires GraalVM)
```

## Conventions

- Do not hand-edit `GoogleJavaFormatVersion.java` — it is generated from `GoogleJavaFormatVersion.java.template` (`%VERSION%` replaced at `generate-sources` by the `replacer` plugin).
- When changing width/wrapping behavior, thread `maxLineWidth` through consistently — code wrapping (`Formatter`), comments (`JavaCommentsHelper`), javadoc (`JavadocFormatter`/`JavadocWriter`), and string reflow (`StringWrapper`). Do not reintroduce a hardcoded `MAX_LINE_LENGTH`.
- Tests use JUnit 4 with Google Truth assertions (not AssertJ/JUnit5).
- Integration tests (`FormatterIntegrationTest`) use `.input`/`.output` file pairs under `core/src/test/resources/.../testdata/`.

## Build Requirements

- Java 21+ (CI tests on JDK 25).
- Surefire needs the `--add-exports` JVM flags configured in the parent POM `<argLine>` — keep them when editing the POM.

## Syncing Upstream

- Upstream (`google` remote) is **read-only**; its push URL is disabled. Never push or open PRs against `google/google-java-format` — always the fork (`origin` → `trick77/configurable-google-java-format`).
- Merge upstream **releases** (not `master`) with `util/sync-upstream.sh` (defaults to the latest `v*` tag). Use **merge, never rebase** — `git rerere` is enabled to replay recurring conflict resolutions. The script auto-resolves modify/delete of removed plugins and leaves only real content conflicts. After resolving: bump the fork version and run `mvn test`.

## Releasing

- Version scheme: `<upstream-version>-fork.N` (e.g. `1.35.0-fork.1`) — **no `v` prefix** (upstream tags use `v`, the fork does not).
- To release: push a tag named exactly the fork version to `origin`. This triggers `.github/workflows/github-release.yaml`, which builds the fat jar and creates a **GitHub Release** with `core/target/*-all-deps.jar` attached (GitHub Release only — not published to Maven Central). Keep the pom `<version>` and the tag in sync.
