## Notes

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
