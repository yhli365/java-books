#!/bin/bash
curl -XPUT http://localhost:9200/esh_complaints
curl -XPUT http://localhost:9200/esh_complaints/complaints/_mapping -d '
{
         "complaints": {
            "properties": {
               "company": {
                  "type": "keyword",
				  "ignore_above": 256
               },
               "companyResponse": {
                  "type": "keyword",
				  "ignore_above": 256
               },
               "complaintId": {
                  "type": "keyword",
				  "ignore_above": 256
               },
               "consumerDisputed": {
                  "type": "boolean"
               },
               "dateReceived": {
                  "type": "date",
                  "format": "MM/dd/yyyy||MM/dd/yy"
               },
               "dateSent": {
                  "type": "date",
                  "format": "MM/dd/yyyy||MM/dd/yy"
               },
               "issue_raw": {
                  "type": "keyword",
                  "ignore_above": 256
               },
               "issue": {
                  "type": "text"
               },
               "location": {
                  "type": "geo_point"
               },
               "product": {
                  "type": "keyword",
                  "ignore_above": 256,
                  "fields": {
                     "analyzed": {
                        "type": "text"
                     }
                  }
               },
               "state": {
                  "type": "keyword",
                  "ignore_above": 256
               },
               "subissue": {
                  "type": "keyword",
                  "ignore_above": 256,
                  "fields": {
                     "analyzed": {
                        "type": "text"
                     }
                  }
               },
               "submittedVia": {
                  "type": "keyword",
                  "ignore_above": 256
               },
               "subproduct": {
                  "type": "keyword",
                  "ignore_above": 256,
                  "fields": {
                     "analyzed": {
                        "type": "text"
                     }
                  }
               },
               "timelyResponse": {
                  "type": "boolean"
               },
               "zip": {
                  "type": "keyword",
                  "ignore_above": 256
               }
            }
         }
}'