# raft-consul-demo

This project uses Docker to spin up a three node [Consul](https://www.consul.io/) cluster in order to view the logs of a [Raft](https://raftconsensus.github.io/) leader election sequence.

## Usage

First, build the Consul container image and bring up three Consul server nodes. Note, we're filtering the `DEBUG` level log output with `grep`:

```
$ docker-compose build
$ docker-compose up | grep raft
Creating raftconsuldemo_consul3_1...
Creating raftconsuldemo_consul2_1...
Creating raftconsuldemo_consul1_1...
```

Next, we need to determine the IP address of the second and third nodes in another terminal window:

```
$ docker exec -ti raftconsuldemo_consul2_1 consul members
Node          Address           Status  Type    Build  Protocol  DC
ae073b0506f3  172.17.0.44:8301  alive   server  0.5.2  2         dc1
$ docker exec -ti raftconsuldemo_consul3_1 consul members
Node          Address           Status  Type    Build  Protocol  DC
83e5a9090b7a  172.17.0.43:8301  alive   server  0.5.2  2         dc1
```

Now that we have the two IP addresses, we can attempt to join them to the cluster using the first node:

```
$ docker exec -ti raftconsuldemo_consul1_1 consul join 172.17.0.44 172.17.0.43
$ docker exec -ti raftconsuldemo_consul1_1 consul members
Node          Address           Status  Type    Build  Protocol  DC
bb22968c008b  172.17.0.45:8301  alive   server  0.5.2  2         dc1
ae073b0506f3  172.17.0.44:8301  alive   server  0.5.2  2         dc1
83e5a9090b7a  172.17.0.43:8301  alive   server  0.5.2  2         dc1
```

Now, watch the output of the terminal window that was used to bring up the Consul cluster. You should start seeing log messages detailing the Raft leading election process after 20-30 seconds:

```
Attaching to raftconsuldemo_consul3_1, raftconsuldemo_consul2_1, raftconsuldemo_consul1_1
consul1_1 |     2015/08/09 01:29:04 [INFO] raft: Node at 172.17.0.45:8300 [Follower] entering Follower state
consul2_1 |     2015/08/09 01:29:04 [INFO] raft: Node at 172.17.0.44:8300 [Follower] entering Follower state
consul3_1 |     2015/08/09 01:29:04 [INFO] raft: Node at 172.17.0.43:8300 [Follower] entering Follower state
consul3_1 |     2015/08/09 01:29:05 [WARN] raft: EnableSingleNode disabled, and no known peers. Aborting election.
consul1_1 |     2015/08/09 01:29:06 [WARN] raft: EnableSingleNode disabled, and no known peers. Aborting election.
consul2_1 |     2015/08/09 01:29:06 [WARN] raft: EnableSingleNode disabled, and no known peers. Aborting election.
consul2_1 |     2015/08/09 01:31:32 [DEBUG] raft-net: 172.17.0.44:8300 accepted connection from: 172.17.0.45:38117
consul1_1 |     2015/08/09 01:31:32 [WARN] raft: Heartbeat timeout reached, starting election
consul1_1 |     2015/08/09 01:31:32 [INFO] raft: Node at 172.17.0.45:8300 [Candidate] entering Candidate state
consul3_1 |     2015/08/09 01:31:32 [DEBUG] raft-net: 172.17.0.43:8300 accepted connection from: 172.17.0.45:45295
consul1_1 |     2015/08/09 01:31:32 [WARN] raft: Remote peer 172.17.0.44:8300 does not have local node 172.17.0.45:8300 as a peer
consul1_1 |     2015/08/09 01:31:32 [DEBUG] raft: Votes needed: 2
consul1_1 |     2015/08/09 01:31:32 [DEBUG] raft: Vote granted. Tally: 1
consul1_1 |     2015/08/09 01:31:32 [DEBUG] raft: Vote granted. Tally: 2
consul1_1 |     2015/08/09 01:31:32 [INFO] raft: Election won. Tally: 2
consul1_1 |     2015/08/09 01:31:32 [INFO] raft: Node at 172.17.0.45:8300 [Leader] entering Leader state
consul1_1 |     2015/08/09 01:31:32 [INFO] raft: pipelining replication to peer 172.17.0.44:8300
consul1_1 |     2015/08/09 01:31:32 [INFO] raft: pipelining replication to peer 172.17.0.43:8300
consul1_1 |     2015/08/09 01:31:32 [DEBUG] raft: Node 172.17.0.45:8300 updated peer set (2): [172.17.0.45:8300 172.17.0.44:8300 172.17.0.43:8300]
consul2_1 |     2015/08/09 01:31:32 [DEBUG] raft: Node 172.17.0.44:8300 updated peer set (2): [172.17.0.45:8300 172.17.0.44:8300 172.17.0.43:8300]
consul3_1 |     2015/08/09 01:31:32 [DEBUG] raft: Node 172.17.0.43:8300 updated peer set (2): [172.17.0.45:8300 172.17.0.44:8300 172.17.0.43:8300]
consul3_1 |     2015/08/09 01:31:33 [DEBUG] raft-net: 172.17.0.43:8300 accepted connection from: 172.17.0.45:45296
consul2_1 |     2015/08/09 01:31:33 [DEBUG] raft-net: 172.17.0.44:8300 accepted connection from: 172.17.0.45:38120
```
