get_object() {
    out_file=$1
    os_uri=$2
    success=1
    for i in $(seq 1 9); do
        echo "trying ($i) $2"
        http_status=$(curl -w '%%{http_code}' -L -s -o $1 $2)
        if [ "$http_status" -eq "200" ]; then
            success=0
            echo "saved to $1"
            break 
        else
             sleep 15
        fi
    done
    return $success
}

yum clean metadata
yum-config-manager --enable ol7_latest

yum -y install oracle-release-el7
yum-config-manager --enable ol7_oracle_instantclient
yum -y install oracle-instantclient${oracle_client_version}-basic oracle-instantclient${oracle_client_version}-jdbc oracle-instantclient${oracle_client_version}-sqlplus


# get artifacts from object storage
get_object /root/wallet.64 ${wallet_par}
# Setup ATP wallet files
base64 --decode /root/wallet.64 > /root/wallet.zip
unzip -o /root/wallet.zip -d /usr/lib/oracle/${oracle_client_version}/client64/lib/network/admin/

# Init DB
sqlplus ADMIN/"${atp_pw}"@${db_name}_tp @/root/catalogue.sql
sqlplus ADMIN/"${atp_pw}"@${db_name}_tp @/root/sql_performance.sql 