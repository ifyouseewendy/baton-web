## Deprecation

This project used to be called **FtpMonitor**, when initialized to handle and display daily and hourly data from third-party platforms.

## Functions

+ Jobs in `app/jobs`, handle daily and hourly order, record data into model, and display by `/data/:platform` route.

+ Thor tasks in `lib/tasks`, handle some converting and checking works for files interaction with Jidong and Xiaojin.


```
$ ruby lib/tasks/jingdong.rb
$ ruby lib/tasks/xiaojin.rb
```
