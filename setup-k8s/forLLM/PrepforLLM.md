## Prep a K8s **LLM inference node**
- Objective: Prep a Kubernetes **LLM inference node**, or any GPU workload node in EKS/ECS/Kubeadm clusters.

---

### 🧩 Goal

> Enable `containerd` to run GPU containers using **NVIDIA drivers** and **NVIDIA container runtime** (no Docker).

### ✅ Step 1. Install NVIDIA GPU Drivers

You need the kernel-level driver stack first — this is **mandatory**.

#### Ubuntu (22.04+)

```bash
sudo apt update
sudo apt install -y ubuntu-drivers-common
sudo ubuntu-drivers autoinstall
```

Or install a specific version:

```bash
sudo apt install -y nvidia-driver-550
```

Then verify:

```bash
nvidia-smi
```

You should see the GPU recognized, e.g.:

```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 550.54       Driver Version: 550.54.14       CUDA Version: 12.4  |
+-----------------------------------------------------------------------------+
```


### ✅ Step 2. Install NVIDIA Container Toolkit

This toolkit provides the **`nvidia-container-runtime`** — which integrates with `containerd` (and Docker).

#### Install via official NVIDIA repo

```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/stable/$distribution/libnvidia-container.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt update
sudo apt install -y nvidia-container-toolkit
```


### ✅ Step 3. Configure `containerd` to use NVIDIA runtime

Now integrate the runtime into **containerd’s `config.toml`**.

Generate a base config if not already present:

```bash
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
```

#### Edit the runtime section

Look for this section inside `/etc/containerd/config.toml`:

```toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
```

Add the NVIDIA runtime:

```toml
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
    privileged_without_host_devices = false
    runtime_engine = ""
    runtime_root = ""
    runtime_type = "io.containerd.runc.v2"
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
      BinaryName = "/usr/bin/nvidia-container-runtime"
```

Then **set it as the default runtime** (optional but useful):

```toml
[plugins."io.containerd.grpc.v1.cri"]
  ...
  default_runtime_name = "nvidia"
```


### ✅ Step 4. Restart and Verify
- Pre-check
```bash
lspci | grep -i nvidia
```
but if there's no output
```bash
sudo update-pciids
lspci | grep -i nvidia
```


- Restart containerd (or reboot):

```bash
sudo ubuntu-drivers devices
```

```bash
sudo systemctl restart containerd
```

- Verify NVIDIA runtime is functional:
  - This used ctr (containerd) [see Reference in regard to ctr vs nerdctl]
```bash
sudo ctr run --rm --gpus all docker.io/nvidia/cuda:12.4.0-base-ubuntu22.04 cuda-test nvidia-smi
```

- Expected output:

```
Tue Oct 08 21:52:39 2025
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 550.54       Driver Version: 550.54.14       CUDA Version: 12.4  |
+-----------------------------------------------------------------------------+
```


### ✅ Step 5. (Optional) — For Kubernetes Nodes

When running under **Kubernetes**, also install the NVIDIA device plugin DaemonSet:

```bash
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.15.0/nvidia-device-plugin.yml
```

Check GPU exposure:

```bash
kubectl describe node <node> | grep -A4 "Capacity"
```

Expected:

```
nvidia.com/gpu: 1
```


## 🧠 Summary

| Component                    | Purpose                                | Install Command                             |
| ---------------------------- | -------------------------------------- | ------------------------------------------- |
| **NVIDIA Driver**            | Kernel module for GPU                  | `sudo apt install nvidia-driver-550`        |
| **CUDA Toolkit (optional)**  | Libraries for GPU compute              | `sudo apt install cuda-toolkit-12-4`        |
| **NVIDIA Container Toolkit** | Integrates GPU with container runtimes | `sudo apt install nvidia-container-toolkit` |
| **containerd config**        | Adds `nvidia` runtime under CRI        | edit `/etc/containerd/config.toml`          |
| **NVIDIA K8s Device Plugin** | Exposes GPUs to Pods                   | `kubectl apply -f nvidia-device-plugin.yml` |

### Reference
- Youtube: https://youtu.be/boWxlJbJ47k?si=Jqm1tN0w0eCY38Jc
- Medium: https://medium.com/@purnachandrasharma1/mastering-container-management-exploring-ctr-nerdctl-and-crictl-e12703a606d0

---

## 🚀 Example: Minimal Working `config.toml` Snippet

```toml
[plugins."io.containerd.grpc.v1.cri"]
  sandbox_image = "registry.k8s.io/pause:3.9"
  default_runtime_name = "nvidia"

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
    runtime_type = "io.containerd.runc.v2"
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
      BinaryName = "/usr/bin/nvidia-container-runtime"
```



