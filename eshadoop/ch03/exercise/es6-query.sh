#!/usr/bin/env bash

#[编写查询语句]--------

#URI查询
curl -X﻿GET http://localhost:9200/hrms/candidate/_search?pretty=true&q=skills:elasticsearch

#match_all查询
curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
  "query": {
    "match_all": {}
  }
}'

#term查询
curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
  "query": {
    "term": {
	  "skills": {
	    "value": "elasticsearch"
	  }
	}
  }
}'

#boolean查询(MUST/MUST_NOT/SHOULD)
curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
  "query": {
    "bool": {
	  "must": [
	  {
	    "term": {
	      "address.city": {
	        "value": "Mumbai"
	      }
	    }
	  }
	  ],
	  "should": [
	  {
	    "terms": {
	      "skills": ["elasticsearch", "lucene"]
	    }
	  }
	  ]
	}
  }
}'

#match查询
curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
  "query": {
    "match": {
	  "comments": {
	    "query": "hacking java"
	  }
	}
  }
}'

curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
  "query": {
    "match_phrase": {
	  "comments": {
	    "query": "ethical hacking"
	  }
	}
  }
}'

#range查询
curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
  "query": {
    "range": {
	  "experience": {
	    "gte": 5,
		"lte": 10
	  }
	}
  }
}'

#wildcard查询
curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
  "query": {
    "wildcard": {
	  "firstName": "bra*"
	}
  }
}'

#[过滤器]-----------------------

#exists过滤器
curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
    "query": {
        "bool" : {
            "must" : {
                "match_all" : {}
            },
            "filter" : {
                "exists" : {
                    "field": "achievements"
                }
            }
        }
    }
}'

#geo_distance过滤器
curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
    "query": {
        "bool" : {
            "must" : {
                "match_all" : {}
            },
            "filter" : {
                "geo_distance" : {
                    "distance" : "80km",
                    "address.geo" : {
                        "lat" : 23.05,
                        "lon" : 72.97
                    }
                }
            }
        }
    }
}'

#[聚合查询]-----------------------

#terms聚合
#--查找所有候选人中排名前三的城市：
curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
  "aggs": {
    "candidates_by_region": {
	  "terms": {
	    "field": "address.city",
		"size": 3
	  }
	}
  }
}'

#--查找所有候选人中排名后三的城市：
curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
  "aggs": {
    "candidates_by_region": {
	  "terms": {
	    "field": "address.city",
		"size": 3,
		"order": {
		  "_count": "asc"
		}
	  }
	}
  }
}'

#--查找所有候选人中城市排名：
curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
  "aggs": {
    "candidates_by_region": {
	  "terms": {
	    "field": "address.city"
	  }
	}
  }
}'

#histogram聚合
#--在对候选人的查询中，对其工作年限以3年为一个区间进行聚合，并获取相应区间内的候选人的人数：
curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
  "aggs": {
    "cand_exp_dist": {
	  "histogram": {
	    "field": "experience",
		"interval": 3,
		"min_doc_count": 0
	  }
	}
  }
}'

#range聚合
#--对候选人的工作年限按照一定的区间进行聚合
curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
  "aggs": {
    "cand_exp_dist": {
	  "range": {
	    "field": "experience",
		"ranges": [
		  {
		    "from": 0,
			"to": 3
		  },
		  {
		    "from": 3,
			"to": 7
		  },
		  {
		    "from": 7,
			"to": 10
		  },
		  {
		    "from": 10,
			"to": 20
		  }
		]
	  }
	}
  }
}'

#geo_distance聚合
#--查找出具有elasticsearch工作经验的候选人在以孟买为中心的地域分布情况：
curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
  "query": {
    "term": {
	  "skills": {
	    "value": "elasticsearch"
	  }
	}
  },
  "aggs": {
    "around_mumbai": {
	  "geo_distance": {
	    "field": "address.geo",
		"origin": "18.97, 72.82",
		"unit": "km",
		"ranges": [
		  {
			"to": 200
		  },
		  {
		    "from": 200,
			"to": 500
		  },
		  {
		    "from": 500,
			"to": 1000
		  },
		  {
		    "from": 1000
		  }
		]
	  }
	}
  },
  "size": 10,
  "post_filter": {
    "term": {
	  "address.city": "Mumbai"
	}
  }
}'

#嵌套聚合
#--我们想知道在候选人最多的5个城市中拥有不同技能的候选人的平均工作年限：
curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
  "aggs": {
    "by_city": {
	  "terms": {
	    "field": "address.city",
		"size": 5
	  },
	  "aggs": {
	    "by_skill": {
		  "terms": {
		    "field": "skills.keyword",
			"size": 5
		  },
		  "aggs": {
		    "average": {
			  "avg": {
			    "field": "experience"
			  }
			}
		  }
		}
	  }	  
	}
  },
  "size": 0
}'

#自测题
#--按照城市计算候选人的平均薪水，这些候选人至少拥有"lucene" "elasticsearch" "kibana"和"analytics"中的两项技能，同时他们有5到10年的工作经验。
curl -X﻿POST http://localhost:9200/hrms/candidate/_search?pretty -d '{
  "query": {
    "bool" : {
	  "must" : {
		"match_all" : {}
	  },
      "filter": {
        "bool": {
          "must": [
            {
              "range": {
                "experience": {
                  "gte": 5,
                  "lte": 10
                }
              }
            },
            {
              "terms": {
                "skills": [ "elasticsearch", "kibana", "lucene", "analytics" ]
              }
            }
          ]
        }
      }
    }
  },
  "aggs": {
    "by_city": {
      "terms": {
        "field": "address.city",
        "size": 5
      },
      "aggs": {
        "by_skill": {
          "terms": {
            "field": "skills.keyword",
            "size": 5
       },
        "aggs":{
          "average": {
            "avg": {
                "field": "salary"
            }
           }
         }
       }
     }
    }
  },
  "size": 0
}' 

