FROM swift:4.2.1
COPY Package.swift ./Package.swift
COPY Sources ./Sources
COPY Tests ./Tests
RUN swift test --configuration debug
