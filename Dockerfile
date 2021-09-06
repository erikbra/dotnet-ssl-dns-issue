FROM mcr.microsoft.com/dotnet/sdk:5.0-alpine AS build-env

WORKDIR /app

# Copy csproj and restore as distinct layers
COPY MinimalRepro/MinimalRepro.csproj MinimalRepro/MinimalRepro.csproj
COPY dotnet-ssl-dns-issue.sln dotnet-ssl-dns-issue.sln


RUN dotnet restore $(ls *.sln) --runtime alpine-x64

# Copy everything else and build
COPY . ./

RUN dotnet publish $(ls *.sln) -c Release -o /app/out --no-restore \  
  --runtime alpine-x64 \
  --self-contained true \
  -p:PublishTrimmed=true \
  -p:PublishSingleFile=true


# Build runtime image
FROM mcr.microsoft.com/dotnet/runtime-deps:5.0-alpine
ARG app_name=MinimalRepro

ENV appname="./${app_name}"

WORKDIR /app
COPY --from=build-env /app/out .

ENTRYPOINT $appname
