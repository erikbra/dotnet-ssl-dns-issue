# dotnet-ssl-dns-issue
Demonstrates a difference in handling of invalid domain names in Linux vs Windows on .net core. Uses wordpress.com as an example, 
as they have both wildcard DNS entries, and TLS certs on *.wordpress.com on all addresses.

## The issue:

When connecting to an _invalid_ domain name according to RFC 1035 containing underscores, but responding with a valid TLS certificate, 
.NET behaves differently on Windows vs. Linux. The request fails with `RemoteCertificateNameMismatch` on Linux, but succeeds on Windows.

## Expected: 

The behaviour should be the same on Linux and Windows.

## Repro:

There are two Powershell scripts in the root folder:

* run-locally.ps1
* run-in-docker.ps1

They run the repro with dotnet locally on the box you run it on, and in docker (alpine-x64), respectively.

### Running on Windows and macOS outputs

```
Running on: Microsoft Windows NT 10.0.19043.0
==================================================

nonexistent-but-valid-domainname.wordpress.com
****************************************
Response: StatusCode: 200, ReasonPhrase: 'OK', Version: 1.1, Content: System.Net.Http.HttpConnectionResponseContent, Headers:
{
  Server: nginx
  Date: Mon, 06 Sep 2021 11:16:54 GMT
  Transfer-Encoding: chunked
  Connection: keep-alive
  Vary: Accept-Encoding
  X-hacker: If you're reading this, you should visit automattic.com/jobs and apply to join the fun, mention this header.
  Host-Header: WordPress.com
  X-Frame-Options: SAMEORIGIN
  X-ac: 2.arn _dca
  Strict-Transport-Security: max-age=15552000; preload
  Content-Type: text/html; charset=utf-8
}

invalid_hostname_with_underscores.wordpress.com
****************************************
Response: StatusCode: 200, ReasonPhrase: 'OK', Version: 1.1, Content: System.Net.Http.HttpConnectionResponseContent, Headers:
{
  Server: nginx
  Date: Mon, 06 Sep 2021 11:16:54 GMT
  Transfer-Encoding: chunked
  Connection: keep-alive
  Vary: Accept-Encoding
  X-hacker: If you're reading this, you should visit automattic.com/jobs and apply to join the fun, mention this header.
  Host-Header: WordPress.com
  X-Frame-Options: SAMEORIGIN
  X-ac: 2.arn _dca
  Strict-Transport-Security: max-age=15552000; preload
  Content-Type: text/html; charset=utf-8
}
```


### Running in docker (on Alpine-x64), or natively on Linux outputs

```
Running on: Unix 5.10.16.3
==================================================

nonexistent-but-valid-domainname.wordpress.com
****************************************
Response: StatusCode: 200, ReasonPhrase: 'OK', Version: 1.1, Content: System.Net.Http.HttpConnectionResponseContent, Headers:
{
  Server: nginx
  Date: Mon, 06 Sep 2021 11:16:34 GMT
  Transfer-Encoding: chunked
  Connection: keep-alive
  Vary: Accept-Encoding
  X-hacker: If you're reading this, you should visit automattic.com/jobs and apply to join the fun, mention this header.
  Host-Header: WordPress.com
  X-Frame-Options: SAMEORIGIN
  X-ac: 1.arn _dca
  Strict-Transport-Security: max-age=15552000; preload
  Content-Type: text/html; charset=utf-8
}

invalid_hostname_with_underscores.wordpress.com
****************************************
Inner exceptionSystem.Security.Authentication.AuthenticationException: The remote certificate is invalid according to the validation procedure: RemoteCertificateNameMismatch
   at System.Net.Security.SslStream.SendAuthResetSignal(ProtocolToken message, ExceptionDispatchInfo exception)
   at System.Net.Security.SslStream.ForceAuthenticationAsync[TIOAdapter](TIOAdapter adapter, Boolean receiveFirst, Byte[] reAuthenticationData, Boolean isApm)
   at System.Net.Http.ConnectHelper.EstablishSslConnectionAsyncCore(Boolean async, Stream stream, SslClientAuthenticationOptions sslOptions, CancellationToken cancellationToken)
```


## References:

https://datatracker.ietf.org/doc/html/rfc1035#section-2.3.1

> The labels must follow the rules for ARPANET host names.  They must
start with a letter, end with a letter or digit, and have as interior
characters only letters, digits, and hyphen.  There are also some
restrictions on the length.  Labels must be 63 characters or less.
