package com.packtpub.esh.complaints;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.elasticsearch.hadoop.mr.EsOutputFormat;

import java.io.File;


public class Driver extends Configured implements Tool {

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
        conf.setIfUnset("es.resource", "esh_complaints/complaints");

        // Create Job instance
        Job job = Job.getInstance(conf, "complaints mapper");
        // set Driver class
        job.setJarByClass(Driver.class);
        job.setMapperClass(ComplaintsMapper.class);
        // set OutputFormat to EsOutputFormat provided by ElasticSearch-Hadoop jar
        job.setOutputFormatClass(EsOutputFormat.class);
        job.setNumReduceTasks(0);
        FileInputFormat.addInputPath(job, new Path(args[0]));

        return job.waitForCompletion(true) ? 0 : 1;
    }

}