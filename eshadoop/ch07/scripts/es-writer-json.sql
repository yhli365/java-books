DROP TABLE IF EXISTS source_json;
DROP TABLE IF EXISTS crimes_json;

-- create source table

-- create Elasticsearch table
CREATE EXTERNAL TABLE crimes_json (
        jsonData      STRING)
STORED BY 'org.elasticsearch.hadoop.hive.EsStorageHandler'
TBLPROPERTIES('es.resource' = 'esh_hive/crimes_json', 'es.input.json' = 'true');

-- insert data to Elasticsearch from another table called 'source'

