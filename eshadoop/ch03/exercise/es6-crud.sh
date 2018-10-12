#!/usr/bin/env bash

curl --version

#[Elasticsearch的CRUD]--------

#创建文档
curl -X﻿POST http://localhost:9200/hrms/candidate/1?pretty -d '{
  "firstName": "Emerson",
  "lastName": "Atkins",
  "skills": ["Java", "Hadoop", "Elasticsearch"]
}'

#获取文档
curl -X﻿GET http://localhost:9200/hrms/candidate/1?pretty

#更新文档
curl -X﻿POST http://localhost:9200/hrms/candidate/1/_update?pretty -d '{
  "doc": {
    "experience": 8
  }
}'

#删除文档
curl -XDELETE http://localhost:9200/hrms/candidate/1?pretty

#创建索引
curl -XPUT http://localhost:9200/hrms?pretty

#获取当前索引
curl -X﻿GET 'http://localhost:9200/_cat/indices?v'

#删除指定索引
curl -XDELETE http://localhost:9200/hrms

#[映射]------------------------

#检查映射
curl -X﻿GET http://localhost:9200/hrms/candidate/_mapping?pretty

#创建映射
curl -XPUT http://localhost:9200/hrms/candidate/_mapping?pretty -d '{
        "properties": {
          "experience": {
            "type": "float"
          },
          "firstName": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "lastName": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
	      "birthDate" : {                 
		    "type" : "date",                 
		    "format" : "dd/MM/YYYY" 
	      },
	      "salary" : {                 
		    "type" : "double" 
	      },
          "skills": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "address": {
             "type": "object",
             "properties": {
               "street": {"type" : "text"},
               "city": {
                 "type" : "text", 
                 "index" : false
               },
               "region": {"type" : "text"},
               "geo": {"type": "geo_point"}
             }
          }
        }
}'

#创建索引模板
curl -XPUT http://localhost:9200/_template/hrms-template?pretty -d '{
  "template": "hrms*",
  "settings": {
    "number_of_shards": 2
  },
  "mappings": {
    "candidate": {
	  "properties": {
	    "experience": {
	      "type": "float"
	    }
	  }
	}
  }
}'

#查看索引模板
curl -XGET http://localhost:9200/_template/hrms-template?pretty

#删除索引模板
curl -XDELETE http://localhost:9200/_template/hrms-template?pretty

#[控制索引过程]--------------------

#在创建索引时，自定义分析器
curl -XPUT http://localhost:9200/myhrms?pretty -d '{
  "settings": {
    "analysis": {
	  "analyzer": {
	    "tweets_analyzer": {
		  "tokenizer": "whitespace",
		  "filter": ["stop", "lowercase", "snowball"]
		}
	  }
	}
  }
}'

#查看索引配置
curl -X﻿GET http://localhost:9200/myhrms/_settings?pretty

