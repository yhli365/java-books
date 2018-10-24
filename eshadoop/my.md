# Book
=============================
## Elasticsearch集成Hadoop最佳实践 201706
```
ISBN：9787302469674
[源码](https://github.com/vishalbrevitaz/eshadoop)
[电子书籍]()
```

## 环境
```
elasticsearch-hadoop-6.3.2.zip
elasticsearch-6.3.2.tar.gz
kibana-6.3.2-linux-x86_64.tar.gz
hadoop-2.6.0-cdh5.14.0.tar.gz
hadoop-2.6.0-cdh5.14.0-native.tar.gz
pig-0.16.0.tar.gz
apache-hive-1.2.2-bin.tar.gz
curl --version
```

## Maven
```
mvn clean
mvn compile
mvn dependency:sources
mvn package
```

# Content
=============================
## settings
```
$ vi ~/conf/eshadoop-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property>
    <name>es.nodes</name>
    <value>10.10.8.111:9200</value>
  </property>
</configuration>
```

## review
```
#ch02p27
EsInputFormat/EsOutputFormat/es.input.json=yes
#ch02p37
ES如何对Hadoop中的类型进行自动匹配。
#ch02p49
属性es.query可以是如下三种格式：URI或者参数；JSON格式的DSL；外部资源路径。
```

## ch01 环境部署
```
$ hdfs dfs -mkdir -p /eshadoop/input
$ hdfs dfs -put ch01 /eshadoop/input
$ hadoop jar ch01-0.0.1-job.jar /eshadoop/input/ch01/sample.txt
$ hadoop jar ch01-0.0.1-job.jar -Des.nodes=10.10.8.111:9200 /eshadoop/input/ch01/sample.txt
```

## ch02 初识ES-Hadoop
```
# 实际案例——网络数据监控
$ unzip network-logs.zip
$ hdfs dfs -put ch02 /eshadoop/input
$ hadoop jar ch02-0.0.1-nwlogs-job.jar /eshadoop/input/ch02/network-logs.txt
# 查看TopN结果
$ curl -XPOST http://localhost:9200/esh_network/_search?pretty -d '{
  "aggs": {
    "top-categories": {
	  "terms": {
	    "field": "category.keyword",
		"size": 5
	  }
	}
  },
  "size": 0
}'
# 将Twitter数据导入Elasticsearch
$ hadoop jar ch02-0.0.1-tweets2es-job.jar /eshadoop/input/ch02/tweets.csv
$ curl -XPOST http://localhost:9200/esh_tweets/_search?pretty -d '
{
  "query": {
    "bool": {
      "should": [
        {
          "term": {
            "text": {
              "value": "elasticsearch"
            }
          }
		},{
		  "term": {
            "text": {
              "value": "kibana"
            }
          }
		},{
		  "term": {
            "text": {
              "value": "analysis"
            }
          }
		},{
		  "term": {
            "text": {
              "value": "visualize"
            }
          }
		},{
		  "term": {
            "text": {
              "value": "realtime"
            }
          }
		}
      ],
	  "minimum_should_match": 2
	}
  }
}'
# 将Twitter数据从Elasticsearch写回HDFS
$ hdfs dfs -rm -r /eshadoop/output/ch02
$ hadoop jar ch02-0.0.1-tweets2hdfs-job.jar /eshadoop/output/ch02
$ hdfs dfs -ls /eshadoop/output/ch02
$ hdfs dfs -tail /eshadoop/output/ch02/part-m-00000
```

## ch03 深入理解Elasticsearch
```
#与Elasticsearch交互: es6-crud.sh
#Elastic查询和聚合: es6-setup-hrms.sh, es6-query.sh
```

## ch04 利用Kibana进行大数据可视化
```
# 准备数据, 数据集的内容是消费者对美国的金融产品和服务机构的投诉信息。由(http://catalog.data.gov/dataset/consumer-complaindatabase)提供的开放数据。
$ sh es6-setup-mappings.sh
$ unzip consumer_complaints.zip
$ hdfs dfs -put ch04 /eshadoop/input
$ hadoop jar ch04-0.0.1-job.jar /eshadoop/input/ch04/consumer_complaints.csv
curl -XGET http://localhost:9200/esh_complaints/complaints/_search?pretty
# 启动kibana
# --索引配置(Management/Index Patterns/Create Index Pattern)
Index pattern: esh_complaints
Time Filter field name: dateSent
# --数据发现Discovery
Time Range: 2012-01-01 15:17:51.063 2016-01-01 15:17:51.063
Search:
  loan
  issue:(collect AND debt)
  issue:(payments OR loan)
  dateSent[01/01/2012 TO 12/31/2012]
  (+loan -payments)
  collection~
# --数据可视化Visualize
#哪个公司投诉最多？
饼图: complaints_pie
#在投诉最多的5个公司中，它们被投诉的主要问题是什么。
堆积柱状图: complaints_bar
#在某个时间区间内，不同的产品有多少投诉？
堆积柱状图: complaints_bar2
#在同一时间区间内，不同州的投诉数量是多少？
面积图: complaints_area
#投诉最多的8个州中每个州中排名前5的公司在该州占的比例是多少？
饼图组图: complaints_pie_groups
#投诉最多的5个州中，每个州被投诉最多的5个产品的分布是什么样的？
环形图: complaints_pie_circle
#这些投诉在地理位置上的分布是怎样的？
瓦片地图: complaints_coordinatemap
# --动态图表Dashboard
选择上述可视化图添加到仪表盘(complaints_dashboard)，你还可以设置下述选项，仪表盘中所有的图都会根据过滤出的数据重新计算：
  查询过滤器: loan
  时间过滤器:
  自动刷新的时间间隔:
仪表盘迁移: Management/Saved Objects/
  选择可视化图Visualizations，单击Export: k6-complaints-visualizations.json
  选择仪表盘Dashboards，单击Export: k6-complaints-dashboard.json
```

## ch05 实时分析
```
#significant term聚合
#使用Percolator对推文分类
```

## ch06 ES-Hadoop配置
```
#分布式环境中的Elasticsearch
#ES-Hadoop架构
#生产环境配置
#集群管理
```

## ch07 与Hadoop生态系统集成
```
#与Pig集成
$ hdfs dfs -mkdir -p /eshadoop/lib
$ hdfs dfs -put elasticsearch-hadoop-6.3.2.jar /eshadoop/lib
$ hdfs dfs -mkdir -p /eshadoop/input/ch07/csv
$ hdfs dfs -put ch07/crimes_dataset.csv /eshadoop/input/ch07/csv
$ hdfs dfs -mkdir -p /eshadoop/input/ch07/json
$ hdfs dfs -put ch07/crimes.json /eshadoop/input/json
$ pig es-writer.pig
$ pig es-writer-json.pig
$ pig es-reader.pig

#与Hive集成

```
