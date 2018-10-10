package com.packtpub.esh.tweets2hdfs;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.elasticsearch.hadoop.mr.EsInputFormat;

import java.io.File;
import java.io.IOException;

public class Driver extends Configured implements Tool {

    private static String query = "{\n" +
            "  \"query\": {\n" +
            "    \"bool\": {\n" +
            "      \"should\": [\n" +
            "        {\n" +
            "          \"term\": {\n" +
            "            \"text\": {\n" +
            "              \"value\": \"elasticsearch\"\n" +
            "            }\n" +
            "          \n" +
            "          }\n" +
            "        },{\n" +
            "          \"term\": {\n" +
            "            \"text\": {\n" +
            "              \"value\": \"kibana\"\n" +
            "            }\n" +
            "          \n" +
            "          }\n" +
            "        },{\n" +
            "          \"term\": {\n" +
            "            \"text\": {\n" +
            "              \"value\": \"analysis\"\n" +
            "            }\n" +
            "          \n" +
            "          }\n" +
            "        },{\n" +
            "          \"term\": {\n" +
            "            \"text\": {\n" +
            "              \"value\": \"visualize\"\n" +
            "            }\n" +
            "          \n" +
            "          }\n" +
            "        },{\n" +
            "          \"term\": {\n" +
            "            \"text\": {\n" +
            "              \"value\": \"realtime\"\n" +
            "            }\n" +
            "          \n" +
            "          }\n" +
            "        }\n" +
            "      ]\n" +
            // "      ,\"minimum_number_should_match\": 2\n" +
            "      ,\"minimum_should_match\": 2\n" + // ES 6+
            "    }\n" +
            "    \n" +
            "  }\n" +
            "}";

    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
        File file = new File("eshadoop-site.xml");
        if (file.exists()) {
            conf.addResource(file.toURI().toURL());
        }
        ToolRunner.run(conf, new Driver(), args);
    }

    @Override
    public int run(String[] args) throws Exception {
        Configuration conf = getConf();

        // ElasticSearch Server nodes to point to
        conf.setIfUnset("es.nodes", "localhost:9200");
        // ElasticSearch index and type name in {indexName}/{typeName} format
        // conf.setIfUnset("es.resource", "esh/tweets");
        conf.setIfUnset("es.resource", "esh_tweets/tweets");
        conf.setIfUnset("es.query", query);

        // Create Job instance
        Job job = Job.getInstance(conf, "tweets to hdfs mapper");
        // set Driver class
        job.setJarByClass(Driver.class);
        job.setMapperClass(Tweets2HdfsMapper.class);
        // set OutputFormat to EsOutputFormat provided by ElasticSearch-Hadoop jar
        job.setInputFormatClass(EsInputFormat.class);
        job.setNumReduceTasks(0);
        FileOutputFormat.setOutputPath(job, new Path(args[0]));

        return job.waitForCompletion(true) ? 0 : 1;
    }
}
