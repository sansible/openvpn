# OpenVPN

Master: [![Build Status](https://travis-ci.org/sansible/openvpn.svg?branch=master)](https://travis-ci.org/sansible/openvpn)
Develop: [![Build Status](https://travis-ci.org/sansible/openvpn.svg?branch=develop)](https://travis-ci.org/sansible/openvpn)

* [ansible.cfg](#ansible-cfg)
* [Installation and Dependencies](#installation-and-dependencies)
* [Tags](#tags)
* [Examples](#examples)

This roles installs Openvpn.




## ansible.cfg

This role is designed to work with merge "hash_behaviour". Make sure your
ansible.cfg contains these settings

```INI
[defaults]
hash_behaviour = merge
```




## Installation and Dependencies

To install run `ansible-galaxy install sansible.openvpn` or add this to your
`roles.yml`.

```YAML
- name: sansible.openvpn
  version: v1.0
```

and run `ansible-galaxy install -p ./roles -r roles.yml`




## Tags

This role uses two tags: **build** and **configure**

* `build` - Installs Openvpn and all it's dependencies.
* `configure` - Configure and ensures that the Openvpn service is running.




## Examples

To install:

```YAML
- name: Install and configure Openvpn
  hosts: "somehost"

  roles:
    - role: sansible.openvpn
```

With keys in S3 and EIP:

```YAML
- name: Install and configure Openvpn
  hosts: "somehost"

  roles:
    - role: sansible.openvpn
      openvpn:
        aws_s3_path: "s3://secrets/vpn"
        aws_ec2_elastic_ip: "52.14.28.119"
        bastion_route_subnet: "172.1.0.0/16"
        subnet: "10.1.0.0/16"
        tls_auth_enabled: yes
```
