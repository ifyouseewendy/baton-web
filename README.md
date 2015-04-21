## 项目说明

1. 现有的 Model 结构只是早期实现，暂时保留用来记录天级销售数据。
2. 主要操作均为 thor 任务完成。


## 与小金、途牛合作

### 《天级客户明细销售表》

将天级销售数据记入 DB，并在 `/data/tuniu/` 显示。

```sh
ruby lib/tasks/xiaojin.rb daily_order_check
  --platform=tuniu
  --project=alpha
  --from=/Users/wendi/Workspace/kaitong/ftp-monitor/tuniu_天极客户明细销售表_20150421.csv
```

### 《客户明细销售表》

1. 将“资产单元编号”映射为“产品代码”

```sh
ruby lib/tasks/xiaojin.rb convert
  --code=K00001
  --column=2
  --from=/Users/wendi/Workspace/kaitong/ftp-monitor/test/tasks/resources/xiaojin/客户销售明细表.csv
```

2. 使用上一步的结果文件，生成广交所需要的客户明细销售表。

```sh
ruby lib/tasks/xiaojin.rb generate_gjs_details
  --platform='小金理财'
  --from=/Users/wendi/Workspace/kaitong/ftp-monitor/test/tasks/resources/xiaojin/客户销售明细表.csv
```

## 与京东合作
