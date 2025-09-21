# 오픈스택 AIO 설치

이 설치는 kolla-ansible 기반으로 설치를 진행. 설치 조건은 다음과 같음.

1. Rocky 9 리눅스
2. ansible-core
3. Python3 PIP
4. kolla-ansible

로컬로 설치할 예정이기 때문에 아래와 같이 간단하게 실행 및 구성. 매우 기본적인 컴포넌트만 설치 예정.

VLAB 오픈스택에서 구성하는 경우 다음과 같이 자원 선택 후 설치 및 구성 시작.

- NETWORK: net-infra
- FLAVOR: t1.osp.aio
- IMAGE: lab-rocky-9-rev2
- SECURITY GROUP: TCP/UDP ALL

먼저, O/S 모든 패키지 업데이트 시작.

```bash
dnf update -y
```

OSP에서 사용할 가상 네트워크 구성. 이 네트워크는 OVS에서 사용할 예정.
```bash
# /etc/systemd/system/veth-ex.service
cat >/etc/systemd/system/veth-ex.service <<'EOF'
[Unit]
Description=Create veth pair for Neutron external network
After=network-pre.target
Before=network.target
Wants=network-pre.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/ip link add veth-ex type veth peer name veth-expeer
ExecStart=/usr/sbin/ip link set veth-ex up
ExecStart=/usr/sbin/ip link set veth-expeer up
ExecStop=/usr/sbin/ip link del veth-ex

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now veth-ex.service

ip link

hostnamectl set-hostname aio.example.com
cat <<EOF>> /etc/hosts
<IP_ADDRESS> aio aio.example.com
EOF
```

```bash
cinder에서 사용할 블록 장치 확인
lsblk
umount /mnt
dnf install lvm2 -y
pvcreate /dev/vdb
vgcreate cinder-volumes /dev/vdb
```

```yaml
cat > /root/globals.yaml <<'EOF'

kolla_base_distro: "rocky"
openstack_release: "2025.1"

# 단일 NIC
network_interface: "ens3"
api_interface: "{{ network_interface }}"
storage_interface: "{{ network_interface }}"
cluster_interface: "{{ network_interface }}"

# VIP 미사용(단일 IP 모드)
enable_haproxy: "no"
kolla_internal_vip_address: "192.168.10.10"   # ← 여기를 호스트 ens3 IP로

# Neutron (외부망은 veth-ex로)
neutron_plugin_agent: "openvswitch"
neutron_external_interface: "veth-ex"
neutron_bridge_name: "br-ex"

# Cinder (AIO 체험용)
enable_cinder: "yes"
enable_cinder_backend_lvm: "yes"
cinder_volume_group: "cinder-volumes"

# Nova
nova_compute_virt_type: "kvm"

# 모니터링 비활성
enable_central_logging: "no"
enable_prometheus: "no"
enable_grafana: "no"
EOF
```


```bash
# 0) 의존 패키지
dnf install python3-pip git -y
pip3 install 'ansible<10'  # 배포 가이드에 맞춰 조정
pip3 install kolla-ansible

# 1) kolla 디렉토리
mkdir -p /etc/kolla/inventory
cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla/
cp /usr/local/share/kolla-ansible/ansible/inventory/all-in-one /etc/kolla/inventory/

cp ~/globals.yaml /etc/kolla/globals.yml

# 2`)` collection 의존성 설치
kolla-ansible install-deps

# 3) 위에서 만든 인벤토리/글로벌 적용
#    /etc/kolla/inventory/all-in-one, /etc/kolla/globals.yml 반영

# 4) 패스워드 생성
kolla-genpwd

# 5) 부트스트랩 & 프리체크
kolla-ansible -i /etc/kolla/inventory/all-in-one bootstrap-servers
kolla-ansible -i /etc/kolla/inventory/all-in-one prechecks

# 6) 배포
kolla-ansible -i /etc/kolla/inventory/all-in-one deploy

# 7) Post-deploy (admin-openrc 등)
kolla-ansible -i /etc/kolla/inventory/all-in-one post-deploy

pip install python-openstackclient
```