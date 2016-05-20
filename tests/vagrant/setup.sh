# !/bin/bash

# Setup S3 proxy for testing key download

apt-get update
apt-get install -y git python-pip openssl openjdk-7-jre
pip install awscli --upgrade

if [ ! -d "$HOME/s3proxy" ]; then
  mkdir -p $HOME/s3proxy
  cd $HOME/s3proxy

  wget https://github.com/andrewgaul/s3proxy/releases/download/s3proxy-1.4.0/s3proxy
  chmod +x $HOME/s3proxy/s3proxy

  echo "
  s3proxy.authorization=none
  s3proxy.endpoint=http://127.0.0.1:8080
  jclouds.provider=filesystem
  jclouds.identity=identity
  jclouds.credential=credential
  jclouds.filesystem.basedir=/tmp/s3proxy
  " > $HOME/s3proxy/s3props.conf
fi

if [ ! -d "$HOME/openvpn/keys" ]; then
  cd $HOME
  wget http://build.openvpn.net/downloads/releases/easy-rsa-2.2.0_master.tar.gz
  tar xvzf easy-rsa-2.2.0_master.tar.gz

  echo "
  # easy-rsa parameter settings
  export EASY_RSA=\"$HOME/easy-rsa-2.2.0_master/easy-rsa/2.0\"

  # This variable should point to
  # the requested executables
  export OPENSSL=\"openssl\"
  export PKCS11TOOL=\"pkcs11-tool\"
  export GREP=\"grep\"

  # This variable should point to
  # the openssl.cnf file included
  # with easy-rsa.
  export KEY_CONFIG=\"$HOME/easy-rsa-2.2.0_master/easy-rsa/2.0/openssl-1.0.0.cnf\"

  # Edit this variable to point to
  # your soon-to-be-created key
  # directory.
  #
  # WARNING: clean-all will do
  # a rm -rf on this directory
  # so make sure you define
  # it correctly!
  export KEY_DIR=\"$HOME/openvpn/keys\"

  # Issue rm -rf warning
  echo NOTE: If you run ./clean-all, I will be doing a rm -rf on $KEY_DIR

  # PKCS11 fixes
  export PKCS11_MODULE_PATH=\"dummy\"
  export PKCS11_PIN=\"dummy\"

  # Increase this to 2048 if you
  # are paranoid.  This will slow
  # down TLS negotiation performance
  # as well as the one-time DH parms
  # generation process.
  export KEY_SIZE=2048

  # In how many days should the root CA key expire?
  export CA_EXPIRE=3650

  # In how many days should certificates expire?
  export KEY_EXPIRE=3650

  # These are the default values for fields
  # which will be placed in the certificate.
  # Don't leave any of these fields blank.
  export KEY_COUNTRY=\"GB\"
  export KEY_PROVINCE=\"London\"
  export KEY_CITY=\"London\"
  export KEY_ORG=\"Lobsterdore\"
  export KEY_EMAIL=\"dreed@techpunch.co.uk\"
  export KEY_OU=\"Lobsterdore\"

  # X509 Subject Field
  export KEY_NAME=\"EasyRSA\"
  " > $HOME/vpnvars

  source $HOME/vpnvars

  mkdir -p ${KEY_DIR}
  chmod o-rwx ${KEY_DIR}

  rm -rf ${KEY_DIR}/index.txt
  touch ${KEY_DIR}/index.txt
  echo 01 > ${KEY_DIR}/serial

  $EASY_RSA/pkitool --initca
  $OPENSSL dhparam -out ${KEY_DIR}/dh${KEY_SIZE}.pem ${KEY_SIZE}
  $EASY_RSA/pkitool --server server
fi

RUNNING=$(ps -ef | grep s3proxy | grep -v 'grep')

if [ -z "$RUNNING" ]; then
  ( $HOME/s3proxy/s3proxy --properties $HOME/s3proxy/s3props.conf & ) > /dev/null 2>&1
fi

if [ ! -d "/tmp/s3proxy/openvpn-test-bucket" ]; then
  source $HOME/vpnvars
  mkdir -p /tmp/s3proxy/openvpn-test-bucket
  aws s3 cp --no-sign-request --endpoint-url http://localhost:8080 --no-verify-ssl ${KEY_DIR}/ca.crt s3://openvpn-test-bucket
  aws s3 cp --no-sign-request --endpoint-url http://localhost:8080 --no-verify-ssl ${KEY_DIR}/dh2048.pem s3://openvpn-test-bucket
  aws s3 cp --no-sign-request --endpoint-url http://localhost:8080 --no-verify-ssl ${KEY_DIR}/server.crt s3://openvpn-test-bucket
  aws s3 cp --no-sign-request --endpoint-url http://localhost:8080 --no-verify-ssl ${KEY_DIR}/server.key s3://openvpn-test-bucket
fi
