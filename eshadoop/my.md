# Book
=============================
## Elasticsearch集成Hadoop最佳实践
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
```

## Maven
```
mvn clean
mvn compile
mvn package
```

# Content
=============================
## ch01
```
$ hdfs dfs -mkdir -p /eshadoop/input
$ hdfs dfs -put ch01 /eshadoop/input
$ hadoop jar ch01-0.0.1-job.jar /eshadoop/input/ch01/sample.txt
```
