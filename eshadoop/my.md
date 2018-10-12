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

