package com.packtpub.esh.streaming;


import org.apache.storm.Config;
import org.apache.storm.spout.SpoutOutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseRichSpout;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Values;
import org.apache.storm.utils.Utils;
import twitter4j.FilterQuery;
import twitter4j.Status;
import twitter4j.StatusAdapter;
import twitter4j.StatusListener;
import twitter4j.TwitterStream;
import twitter4j.TwitterStreamFactory;
import twitter4j.auth.AccessToken;
import twitter4j.conf.ConfigurationBuilder;

import java.util.Map;
import java.util.concurrent.LinkedBlockingQueue;

@SuppressWarnings("serial")
public class TweetsCollectorSpout extends BaseRichSpout {

    private SpoutOutputCollector collector;
    private LinkedBlockingQueue<Status> queue = null;
    private TwitterStream twitterStream;

    // TODO: Initialize twitter credentials.
    private String consumerKey = "<<YOUR_CONSUMER_KEY>>";
    private String consumerSecret = "<<YOUR_CONSUMER_SECRET>>";
    private String accessToken = "<<YOUR_ACCESS_TOKEN>>";
    private String accessTokenSecret = "<<YOUR_TOKEN_SECRET>>";
    private String[] keyWords = {};

    public TweetsCollectorSpout() {
    }

    @Override
    public void open(Map conf, TopologyContext context, SpoutOutputCollector collector) {
        queue = new LinkedBlockingQueue<Status>(1000);
        this.collector = collector;

        StatusListener listener = new StatusAdapter() {

            public void onStatus(Status status) {
                queue.offer(status);
            }

        };

        twitterStream = new TwitterStreamFactory(
                new ConfigurationBuilder().setJSONStoreEnabled(true).build())
                .getInstance();

        twitterStream.addListener(listener);
        twitterStream.setOAuthConsumer(consumerKey, consumerSecret);
        AccessToken token = new AccessToken(accessToken, accessTokenSecret);
        twitterStream.setOAuthAccessToken(token);

        if (keyWords.length == 0) {
            twitterStream.sample();
        } else {
            FilterQuery query = new FilterQuery().track(keyWords);
            twitterStream.filter(query);
        }

    }

    public void nextTuple() {
        Status status = queue.poll();
        if (status == null) {
            Utils.sleep(50);
        } else {
            collector.emit(new Values(status));
        }
    }


    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        declarer.declare(new Fields("tweet"));
    }

    @Override
    public Map<String, Object> getComponentConfiguration() {
        Config config = new Config();
        config.setMaxTaskParallelism(1);
        return config;
    }

    @Override
    public void close() {
        twitterStream.shutdown();
    }


    @Override
    public void ack(Object id) {
    }

    @Override
    public void fail(Object id) {
    }

}
