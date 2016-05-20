# Elasticsearch

Master: [![Build Status](https://travis-ci.org/sansible/elasticsearch.svg?branch=master)](https://travis-ci.org/sansible/elasticsearch)  
Develop: [![Build Status](https://travis-ci.org/sansible/elasticsearch.svg?branch=develop)](https://travis-ci.org/sansible/elasticsearch)

* [ansible.cfg](#ansible-cfg)
* [Installation and Dependencies](#installation-and-dependencies)
* [Tags](#tags)
* [Examples](#examples)

This roles installs Elasticsearch.

For more information on Elasticsearch please visit [elastic elasticsearch](https://www.elastic.co/products/elasticsearch).




## ansible.cfg

This role is designed to work with merge "hash_behaviour". Make sure your
ansible.cfg contains these settings

```INI
[defaults]
hash_behaviour = merge
```




## Installation and Dependencies

To install run `ansible-galaxy install sansible.elasticsearch` or add this to your
`roles.yml` and `sansible.java` for installing java.

```YAML
- name: sansible.elasticsearch
  version: v1.0
```

and run `ansible-galaxy install -p ./roles -r roles.yml`




## Tags

This role uses two tags: **build** and **configure**

* `build` - Installs Elasticsearch and all it's dependencies.
* `configure` - Configure and ensures that the Elasticsearch service is running.




## Examples

To install:

```YAML
- name: Install and configure ElasticSearch
  hosts: "somehost"

  roles:
    - role: sansible.elasticsearch
```

With AWS EC2 plugin:

```YAML
- name: Install and configure ElasticSearch
  hosts: "somehost"

  roles:
    - role: sansible.elasticsearch
  elasticsearch:
    discovery_zen_ping_multicast_enabled: false
    index:
      number_of_shards: 6
      number_of_replicas: 2
    plugins:
      - plugin_name: mobz/elasticsearch-head
        plugin_dir:  head
      - plugin_name: royrusso/elasticsearch-HQ
        plugin_dir:  HQ
      - plugin_name: elasticsearch/elasticsearch-cloud-aws/2.4.2
        plugin_dir: cloud-aws
    plugin_config:
      aws:
        enabled: true
        cloud_aws_region: "eu-west-1"
        discovery:
          enabled: true
          ec2_tags:
            Stack: "services-dev-elasticsearch-v2"
          ec2_ping_timeout: "30s"
```
