#!env pwsh

docker build --build-arg publish_trimmed=true --build-arg publish_single_file=true -t minimal-repro:0.0.1 . `
; docker run -it --rm minimal-repro:0.0.1
