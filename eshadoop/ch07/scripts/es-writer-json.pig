
-- REGISTER hdfs://localhost:9000/lib/elasticsearch-hadoop-2.1.1.jar;
REGISTER hdfs://$dfs_name/eshadoop/lib/elasticsearch-hadoop-6.3.2.jar;

-- Match the reducer parallelism to the number of shards available
SET default_parallel 5;

-- Disable combining input splits
SET pig.noSplitCombination TRUE;

-- Load JSON file into SOURCE
JSON_DATA = load '/eshadoop/input/ch07/json/crimes.json' using PigStorage() AS (json:chararray);

-- Store to ES index
STORE JSON_DATA INTO 'esh_pig/crimes_json'
    USING org.elasticsearch.hadoop.pig.EsStorage(
    'es.nodes = $es_nodes',
    'es.input.json = true');

