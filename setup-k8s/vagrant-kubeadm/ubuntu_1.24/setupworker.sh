#!/bin/bash

echo "[TASK 1] Join node to Kubernetes Cluster"
cat >>~/.ssh/id_rsa<<EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA1VbMFF4ddcW5/Frbo9I2XhLQlxpW31N3j/TSiAM44+R9yIGc
VhnG0r8/nQZFHz+dAkY0Meb9ZOL6XtQwsdyvpy9s4nZOqqLZSqhsm58/VB0utRBr
ir8bgzsAsFjCtThJJq42HWVSoAp9alDHyN1MyJ9DfQ1UxaJS5v746UmdDV/Ty5Mz
G1L/zDDuBmOn5ODvS6P3KIPS+ab7RkpeHnBZd0Sfmv6N4Fhi2FsCXVf9raU6bN/4
YeefZwFanZNBD5BbySZJRYc4y+AeZKR7JNsLyhm4KXGtj1JhOoVRJYwYr1H1e0Qr
hSQftDVbCYTutU7BK0Tre4ftriVoRsIj+2CU5wIDAQABAoIBAFe0wlvRQW1Mp6Se
udOEtYNBWu30DyjrCKlvLipqoLXYFvoahupC2KGFrKJilII/Rc5MjGLDowMZ6XKY
65gDsVcbQTltB/RQ1OJDkbr84i0zfiNEJ+I3pRjzZdoZ85pLFI/JaUf2gtx2046k
vS3QBSQpjbZYh7Rkgo6i3jQSZnW7YkIqTzIYuREGRTlzfXLwhWov468YcjpbdRXb
/ReNHZxv1py2Z42rx4zM65VfZUWUxBEk7QVIN7dIcGR5LcECdha8TQChmfMk8N7W
NQIospYvVNdT/vexnEY0/Cqp9lLg8+939MIEhvqGHr30FKBon2wlHu1PxSfvxS41
AVD275ECgYEA90Y1BV+0ms90BI1PPRfBJBkOvyxwVrcmf+hTiCLUjjxbbo2HeoQj
o7RSWxR1S2sPnlGZmF0w33XU8bms7i616WtpwhHAof+Gp2QJWEHnzuSs3dTwMOYj
maIepJItVDrzylYgHo5JivVEC1Xgmt3m16Iffld9Le2thnatn1AMgYkCgYEA3N4H
5rbqjqnVc731icNAm9Nf40TimzyV3ZwmrTTkMa4TJmL6lXupmDA9IuWfhhjfTpzi
ru+s2WRXFZADweIO1llX0HWzgSMb7Fk3dQOtHnHjIyTFiL/xY/kw2CcvNlndjEZ7
lg/vaJAvQkQOuGHP/mTRD7yN2MqKZkO2TjTq9u8CgYBZgg1xS4qJu2yItUoomC+u
zG89Hm3vxc5m4IdUMR91+T0zkIGpBKoN+RkSpR4sVa3KpkkOETW+vd1+PrLtaPUq
cFpRCLINMfzhHOIRE5JAnyBAEHN9j+D1HO0wr0U/RzO2W2S3CtRuO4gM/mIWTRrh
lWsHBc5nULDOiqkgkQ5l2QKBgQDaMQHvO062xzKWV9fEU7508jktBLU0lIKc3hEb
VUAFkClc57UTjYn6TdVnrx6L0/Bu8e/C0AWa8VRSeeYsWE0+Fh75Uf2WGoAQWga+
M3aHuAyigEYglTY8BEXrk7JBaD/EvzCCC5YAX0hAl4lPP1nBwAkEGcqrm1NkOYpU
8lQYwwKBgBsHJyMXQIlZ0B4vtr7rKSd9Umq1ZRZEVUqBiZDq5i1yJrEj2G3iqWB0
7EnbdPT9npAkwmhzdN9spK+8kGzvTzJfbRISpl4fBt9b/UoZ08S+7mMsE98EcWux
o0gwlCqbzGbjRK0vHHkyZwUCaxp4/f46ogEm3kVtVHACm26Vkt0J
-----END RSA PRIVATE KEY-----
EOF

echo "[TASK 2] Change private key permission"
chmod 400 ~/.ssh/id_rsa

echo "[TASK 3] Pull cluster connection token"
scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no root@192.168.56.2:/joincluster.sh /joincluster.sh

echo "[Task 4] Join the cluster"
#bash /joincluster.sh
#kubectl label node $(hostname -s)  node-role.kubernetes.io/worker=worker
#apt-mark hold kubeadm kubelet containerd kubectl