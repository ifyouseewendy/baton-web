## Introduction

本项目旨在自动化开通与第三方机构（互联网平台、交易所）的对接过程。

## Reference

+ 开通金融与交易所合作解决方案.pdf
+ 开通金融与小金理财技术合作解决方案.pdf
+ 开通金融与互联网平台技术合作解决方案.pdf
+ 京东金融非标理财合作接口方案.pdf
+ [对接京东 - 技术注意事项](https://quip.com/WLduAlYbiBPH)
+ [京东 - 开通 - 广交所上线操作流程](https://quip.com/ClscABmJ9SGn)
+ [SFTP 相关信息](https://quip.com/FjxaAkaag8LR)

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

### Unit Test

```
$ rake
```

### Samples

[Sample](samples/) files are used to test uploading on web page.

### Test env

> Select when creating project.

There are two strategies,

1. Pass `{env: :test}` option to job run, and use `FileAgent` to mock SFTP download and upload.
2. Always pass `{env: :online}` option, but use test user on SFTP. Change platform (`'jingdong'`) to test name (`'jingdong_test'`) when creating project.

Strategy 2 is being used now.

## Deployment

```sh
$ mina deploy
```


## Changelog

#### Version 0.1.0

项目原名为 ftp-monitor，用来监控 FTP 以及执行一些 thor 任务来完成与各机构的文件交互，这部分代码保存在 ftp-monitor 分支。

#### Version 1.0.0

1. 页面样式取自 [Departure](https://tryblocks.com/departure/index.html)，保存在 `lib/assets`
1. 项目级别 CRUD
2. 项目、阶段、任务、步骤，四层嵌套模型
3. 京东的流程模板（互联网平台：京东，交易所：广交所）

## Todo

*Version 1.1.0*

+ 辽金所：由于辽金所相对特殊，提供的京东文件只能达到半成品的状态，所以没办法添加流程。建议在主页增加一个 one-off 任务入口，提供多个独立的、不保存状态的页面工具，例如，获取某一天某个机构的上传文件，用户上传产品合同模板后按指定规则批量生成产品合同等。对于一些像辽金所这种没法流程化的对接过程，提供半自动化的操作工具。
+ 小金：由于只上线过一份资产，并且现有的文件命名方式，不支持一天内传送两份资产的转让信息。建议解决这个问题上线第二份资产后，添加小金流程。
+ 武金所：跟武金所连调后，做相应调整

*Version 2.0.0*

现有的使用场景为内部使用，方便对接与上线流程，后续应该添加用户视角:

1. 将现有功能开放给开通内部用户
2. 允许机构注册使用，并只能查看各在在当前阶段需要完成的任务
Gk
