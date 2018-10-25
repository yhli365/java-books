-- REGISTER hdfs://localhost:9000/lib/elasticsearch-hadoop-2.1.1.jar;
REGISTER hdfs://$dfs_name/eshadoop/lib/elasticsearch-hadoop-6.3.2.jar;

ES = LOAD 'esh_pig/crimes' using org.elasticsearch.hadoop.pig.EsStorage(
     'es.nodes = $es_nodes',
     '{"query" : { "term" : { "primaryType" : "theft" } } }');

dump ES;
