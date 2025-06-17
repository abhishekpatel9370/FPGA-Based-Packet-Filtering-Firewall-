# FPGA-Based Packet Filtering Firewall

This project demonstrates a simple yet powerful hardware firewall implemented using Verilog HDL on an FPGA. It filters incoming network packets in real time based on source IP addresses, making it suitable for high-speed, low-latency security applications.

---

## 🔧 Features

- Packet inspection at wire speed
- Filtering based on source IPv4 address
- Uses on-chip Block RAM (BRAM) to store blacklist IPs
- Implemented purely in Verilog
- Easy integration into AXI/SoC environments
- Suitable for simulation (ModelSim/Vivado) and hardware deployment (e.g., Artix-7)

---

## 🧠 How It Works

1. **Input Stream:**  
   The firewall receives Ethernet frames byte-by-byte through a streaming input.

2. **IP Extraction:**  
   It extracts bytes **26 to 29**, which correspond to the **source IP address** in an IPv4 packet.

3. **IP Concatenation:**  
   These 4 bytes are combined to form a 32-bit IP:
src_ip = {byte26, byte27, byte28, byte29};

markdown
Copy
Edit

**Example:**  
`192.168.1.100` → `0xC0A80164`

4. **Blacklist Comparison:**  
The 32-bit IP is compared against entries in the BRAM-based **IP blacklist**.

5. **Packet Decision:**
- If the IP is blacklisted, the packet is **blocked**.
- Otherwise, it is **allowed**.

6. **Output Signals:**
- `packet_allowed`: High for allowed packets, Low for blocked.
- `done`: Goes high after packet evaluation.

---

## 🧪 Testbench

The included testbench simulates a 40-byte Ethernet packet with:
- A mock IPv4 source address at bytes 26–29.
- Controlled IPs to validate both **blocked** and **allowed** cases.
- Checks output signals (`packet_allowed` and `done`) for verification.

### 🔍 Packet Layout Example (Simplified):

| Byte Index | Content             |
|------------|---------------------|
| 0–25       | Ethernet/IP headers |
| 26         | Source IP Byte 1    |
| 27         | Source IP Byte 2    |
| 28         | Source IP Byte 3    |
| 29         | Source IP Byte 4    |
| 30–39      | Remaining data      |

---

## 🧾 Real-World Applications

- ✅ **Edge Routers**: Enforce firewall rules at ingress points.
- ✅ **IoT Security**: Lightweight filtering in embedded systems.
- ✅ **Low-Latency Systems**: Hardware-level inspection avoids OS overhead.
- ✅ **Scalable Security**: Dynamic BRAM updates enable flexible rule changes.

---

## 🚀 Getting Started

1. Open project in Vivado or ModelSim.
2. Edit the blacklist BRAM with desired IPs (in 32-bit format).
3. Simulate using the testbench or deploy to FPGA.
4. Observe output (`packet_allowed`, `done`) based on test packets.



## 🧑‍💻 Author

**Abhishek Patel**  
Specializing in VLSI design & digital hardware systems.
