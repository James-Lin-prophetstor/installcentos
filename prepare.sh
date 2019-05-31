# Prepare system before openshift 3.11 installation.
# On centos 7.6 1810 and later.
# Should run this script on every openshift nodes.

select_role()
{
    echo "Is opehshift master node? "
    echo "1) Master and Compute node."
    echo "2) Compute node only."
    read R
    case "$R" in
        1) echo "set Master node."
        ;;
        2) echo "set Compute node."
        ;;
        *) echo "enter 1 or 2:"
            until [  $R -eq 1 ] || [ $R -eq 2 ]
            do
            select_role
            done
    esac
}

select_role
echo " "
echo "##############################################################"
echo "# Step:1:install compute node requirements."

yum install -y  wget git zile nano net-tools docker-1.13.1\
				bind-utils iptables-services \
				bridge-utils bash-completion \
				kexec-tools sos psacct openssl-devel \
				httpd-tools NetworkManager \
				python-cryptography python2-pip python-devel  python-passlib \
				java-1.8.0-openjdk-headless "@Development Tools"

yum -y install epel-release
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo

systemctl restart docker
systemctl enable docker

ssh-keygen -q -f ~/.ssh/id_rsa -N ""

echo " "
echo "##############################################################"
if [ $R -eq 1 ]
then
    echo "# step:2:install Master node requirements."
    yum install -y git \
                   pyOpenSSL
    curl -o ansible.rpm https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.6.5-1.el7.ans.noarch.rpm
    yum -y --enablerepo=epel install ansible.rpm
    export VERSION=3.11
    git clone https://github.com/openshift/openshift-ansible.git
    cd openshift-ansible && git fetch && git checkout release-${VERSION}
	
	mkdir -p /etc/origin/master/
	touch /etc/origin/master/htpasswd
fi

echo " "
