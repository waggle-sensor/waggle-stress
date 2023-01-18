# Stressing Waggle
This repository adds some tools to stress Waggle nodes -- basically any ubuntu-based system. The added tools are,

- __stress-ng__: stress CPU and memory
- __hdparm__: stress hard disk (e.g., NVME)
- __iperf3__: stress network; this takes server-client model

_NOTE: This container does not support for GPU stress. Please go to [gpu-stress-test](https://github.com/waggle-sensor/gpu-stress-test) for it._

# Examples
Some examples to run a particular stress test using this container are described in the following subsections.

## CPU stress
This example stressts logical CPU cores. It uses whatever core frequency it is set. nvpmodel in Nvidia may be used to set desired cpu frequency before running this stress test.
```bash
# stress 1 full logical core for 30 seconds
docker run --rm waggle/waggle-stress:0.1.0 --cpu 1 --timeout 30

# stress 50% on each of 2 logical cores for 60 seconds
docker run --rm waggle/waggle-stress:0.1.0 --cpu 2 -l 50  --timeout 60
```

## Memory stress
This can be updated as needed.

## Hard disk stress
1. NVME reading test

We need to access `/dev/nvme0n1`. So we have to add `--privileged` to get access to host's `/dev`.
```bash
docker run --rm --privileged waggle/waggle-stress:0.1.0 hdparm -Tt --direct /dev/nvme0n1
```

Output would look like,
```bash
/dev/nvme0n1:
 Timing O_DIRECT cached reads:   4428 MB in  2.00 seconds = 2217.01 MB/sec
 HDIO_DRIVE_CMD(identify) failed: Inappropriate ioctl for device
 Timing O_DIRECT disk reads: 6358 MB in  3.00 seconds = 2119.32 MB/sec
```

2. NVME writing test

We need to mount the NVME volume into the container to test.

_NOTE: In Waggle node, we use Kubernetes to run containers. In this configuration, the NVME is already mounted in `/run/waggle/uploads`_
```bash
docker run --rm -v /path/to/nvme:/run/waggle/uploads waggle/waggle-stress:0.1.0 bash -c 'mkdir -p /run/waggle/uploads/.stress-test; dd if=/dev/zero of=/run/waggle/uploads/.stress-test/tempfile bs=10M count=512; sync; rm /run/waggle/uploads/.stress-test/tempfile; sync'
```

## Network stress
We need 2 containers running on different devices to stress the network.

```bash
# on the server side in one of the devices
docker run -d --rm waggle/waggle-stress:0.1.0 iperf -s
```

```bash
# on the client side in the other device
# we assume the server is at 10.31.81.1
docker run --rm waggle/waggle-stress:0.1.0 iperf -c 10.31.81.1
```