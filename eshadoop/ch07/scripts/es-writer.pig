
-- REGISTER hdfs://localhost:9000/eshadoop/lib/elasticsearch-hadoop-6.3.2.jar;
REGISTER hdfs://$dfs_name/eshadoop/lib/elasticsearch-hadoop-6.3.2.jar;

-- Match the reducer parallelism to the number of shards available
SET default_parallel 5;

-- Disable combining input splits
SET pig.noSplitCombination TRUE;

-- Load CSV file into SOURCE
SOURCE = load '/eshadoop/input/ch07/csv/crimes_dataset.csv' using PigStorage(',') as (id:chararray, caseNumber:chararray,
    date:datetime, block:chararray, iucr:chararray, primaryType:chararray, description:chararray,
    location:chararray, arrest:boolean, domestic:boolean, lat:double,lon:double);

TARGET = foreach SOURCE generate id, caseNumber,
    date, block, iucr, primaryType, description,
    location, arrest, domestic, TOTUPLE(lon, lat) AS geoLocation;

-- Store to ES index
STORE TARGET INTO 'esh_pig/crimes'
    USING org.elasticsearch.hadoop.pig.EsStorage(
--      'es.nodes = 10.10.8.111:9200',
        'es.nodes = $es_nodes',
        'es.http.timeout = 5m',
        'es.index.auto.create = true',
        'es.mapping.names=arrest:isArrest, domestic:isDomestic',
        'es.mapping.id=id');

