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
