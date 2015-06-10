## Introduction

本项目旨在自动化开通与第三方机构（互联网平台、交易所）的对接过程。

## Reference

+ 开通金融与交易所合作解决方案.pdf
+ 开通金融与小金理财技术合作解决方案.pdf
+ 开通金融与互联网平台技术合作解决方案.pdf
+ 京东金融非标理财合作接口方案.pdf
+ [对接京东 - 技术注意事项](https://quip.com/WLduAlYbiBPH)
+ [京东 - 开通 - 广交所上线操作流程](https://quip.com/ClscABmJ9SGn)
+ [SFTP 帐户信息](https://quip.com/LKnJAgidOEs5)

## Specification

### Models

![structure.v1](doc/structure.v1.png)

### Recipe

作为流程模板，在创建项目时指定，生成预定义的一系列任务。

例，

```
# config/recipes/jingdong.yml

name: 'Jingdong Default Project'
description: ''
recipe: 'jingdong'
stages:
  - name: '准备期'
    description: ''
    tasks:
      - name: '获取交易所上传的准备文件'
        description: ''
        steps:
          - name: '检查交易所是否上传文件至 FTP'
            description: ''
            job_id: "111"
...
```

通过 `job_id` 指定该 `step` 需执行的任务，即上例中 step 对应 `app/jobs/jingdong_job/step111.rb` 所定义的任务。

## Setup

```sh
$ git clone git@github.com:ifyouseewendy/baton-web.git
$ bundle install --local
```

### Resource Directory

Create file storage directory.

```sh
$ mkdir public/resources
```

### SSH

Add ssh config locally, and add your public key into `~/.ssh/authorized_keys` on server.

```
# ~/.ssh/config

Host kaitong.aliyun
  HostName 123.57.60.56
  User deploy
  Port 10080
```

### p7zip

Depend on [p7zip](https://wiki.archlinux.org/index.php/P7zip) for generating OSX/Linux/Win compatible zip file.

> Read this post for details http://goo.gl/k0esDi

```sh
$ brew install p7zip
$ sudo yum install p7zip p7zip-plugins # CentOS
$ sudo apt-get install p7zip-full p7zip-rar # Ubuntu
```

## Development

### File Operation

+ SFTP related operations are encapsulated in [file_agent.rb](/app/jobs/file_agent.rb).
+ Web user uploads are handled by CarrierWave, check [attach_file.rb](app/models/attach_file.rb).

Both SFTP and Carrierwave save or read files to a uniform path:

```ruby
"public/resources/#{organization}/#{project.id}/[download|upload]"
```

So you need to manually create dir `public/resources` locally, and this dir is auto linked by mina during deployment.

### Thor

Use thor to generate organization specific files, then replace it with step jobs.

```sh
$ ruby lib/tasks/jingdong.rb
$ ruby lib/tasks/xiaojin.rb
```

### Mailer

+ Dev by [mailcatcher](http://mailcatcher.me/) (not included in Gemfile).
+ Use kaitongamc mail in production.


## Test

+ Unit test by `$ rake`
+ [Sample](samples/) files are used to test uploading on web page.


## Deployment

```sh
$ mina deploy
```


## Changelog

#### Version 0.1

项目原名为 ftp-monitor，用来监控 FTP 以及执行一些 thor 任务来完成与各机构的文件交互，这部分代码保存在 ftp-monitor 分支。

#### Version 1.0

1. 页面样式取自 [Departure](https://tryblocks.com/departure/index.html)，保存在 `lib/assets`
1. 项目级别 CRUD
2. 项目、阶段、任务、步骤，四层嵌套模型
3. 京东的流程模板（互联网平台：京东，交易所：广交所）

## Todo List
