## Introduction

本项目旨在自动化开通与第三方机构（互联网平台、交易所）的对接过程。

## Development

Test

```
rake
```

## Deployment

Add ssh host

```
# ~/.ssh/config

Host kaitong.aliyun
  HostName 123.57.60.56
  User deploy
  Port 10080
  IdentityFile ~/.ssh/id_rsa_kaitong
```

Add public/resources link

```
$ mkdir ~/resources
$ ln -svf ~/resources {path-to-baton-web}/public
```

Dependent on [p7zip](https://wiki.archlinux.org/index.php/P7zip) for generating OSX/Linux/Win compatible zip file.

> Read this post for details http://goo.gl/k0esDi

```
$ brew install p7zip
$ sudo yum install p7zip p7zip-plugins # CentOS
$ sudo apt-get install p7zip-full p7zip-rar # Ubuntu
```

## Notes

项目原名叫 ftp-monitor，用来监控 FTP 以及执行一些 thor 任务来完成与各机构的文件交互。这部分工作保存在 ftp-monitor 分支。

## Changelog

#### Version 1.0

1. 项目级别 CRUD。
2. 项目、阶段、任务、步骤，四层嵌套模型。
1. 京东的流程模板。（互联网平台：京东，交易所：广交所）

