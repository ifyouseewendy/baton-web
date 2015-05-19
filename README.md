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
