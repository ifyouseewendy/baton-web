## Specification

A demo for process management.

![structure.v1](doc/structure.v1.png)

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

### Mailer

+ Dev by [mailcatcher](http://mailcatcher.me/) (not included in Gemfile).
+ Use kaitongamc mail in production.


## Test

### Unit Test

```
$ rake
```

### Test env

+ `FileAgent` handles target path based on env option
+ Carrierwave saves file to path based on relevant step env.

## Deployment

```sh
$ mina deploy
```

